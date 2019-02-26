// **** Built By Ricky Lowe (Cloud Perspective) 08/09/2014
// **** Controller Extension aggregates the Bookings associated with a Travel Agent by Month.
// **** Results are then collected in a Class so that they can be presented on a VisualForce Page

// **** To Deploy:
// * Agency_Production_Report_Extension
// * Agency_Production_Report_page
// * Aggregate_Agencyprod class
// * Hidden_First_Departure_Month__c and Hidden_First_Departure_Year__c fields on Booking
// * Hidden_Start_Date_Year__c field on Booking Component
// * change booking and Booking component jobs to populate above fields

// **** To Do:

// 1) Need to widen brochure Column
// 2) highlighted variance row dissapears on render of pdf
// 3) Mobile link is rubbish - change from spannar


//Done:
// 1) Add Brochures
// 2) Add in proper variances from YTD formula
// 3) Add in option to switch between this vs last and this vs next years
// 4) need to query for Brochure name
// 5) order both reports
// 6) PDF broken - need to change page layout to horizontal - https://developer.salesforce.com/forums?id=906F0000000A0wnIAC
// 7) stop items from rendering on pdf
// 8) Group booking option should be hidden for Brochures - can't do
// 9) close filters needs to make clear there are still filters on - also need a clear filters option
// 10) need to fill month gaps if no data for that month
// 11) Currency sometimes comes up incorrect - need to set currency on Travel Agent - now going to users default

//

public with sharing class Agency_Production_V2 {

    private final sObject mysObject;
    public list<Aggregate_AgencyProd> Agg {get; set;}
    public list<Consortia> Cons;
    public list<Consortia> ConsToView {get; set;}

    private map<string, Aggregate_AgencyProd> AggMap;
    public list<selectOption> BusinessUnits {get;set;}
    public list<selectOption> Currencies {get;set;}
    private map<string, decimal> CurrencyRates;
    private double UserDefaultConversionRate;
    private Aggregate_AgencyProd TotalAgg;

    public boolean ReportReady {get; set;}
   
    public boolean showFilters {get;set;}
    public string BusinessUnit {get;set;}
    public boolean GroupBookingOnly {get;set;}
    public string RenderAs {get;set;}
    public boolean RenderAsPDForExcel {get;set;}
    public string ContentType {get;set;}
    public string C_Year {get;set;}
    public string CYMOne_Year {get;set;}
    public string CYMTwo_Year {get;set;}
    public string CYPOne_Year {get;set;}

    public string Type {get;set;}
    public string VarianceSelected {get;set;}
    private string query;
    private string GroupedBy;
    private string YearField;

    //private set<id> BrochureIds;
    public id RecordId {get;set;}

    //date range variables
    private date dateEndOfNextYear;
    private date dateBeginningOfTwoYearsAgo;
    private date dateEndOfThisYear;
    private date dateStartOfThisYear;
    private date dateEndOflastYear;
    private date dateStartOflastYear;
    private date dateTodayLastYear;
    private date PastDateFilter;
    private date FutureDateFilter;

    //public Double conversionRate;
    public string ChosenCurrency {get; set;}

    public boolean IsNotSalesforce1 {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Agency_Production_V2(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        Init();
        getBookings();
    }

    public void Init(){
        ReportReady = false;
        Type = 'Month';
        if(date.today().month() >= 9){
            VarianceSelected = 'Next';
        }
        else{
            VarianceSelected = 'Last';
        }
        showFilters = false;
        BusinessUnit = 'ALL';
        GroupBookingOnly = false;
        ContentType = '';
        RenderAs = '';
        RenderAsPDForExcel = false;
        Cons = new list<Consortia>();

        //try{
            //Build the currencies
            BuildCurrencies();

            //Get a list of Business Unit IDs
            set<id> BUids = new set<id>();
            for(AggregateResult BU : [select Business_unit__c from Summary_analysis_2__c where Account__c = :mysObject.id AND Type__c = 'Business Unit - Brochure - Agency - Split By Owner' AND Active__c = true GROUP BY Business_unit__c]){
                BUids.add((id)BU.get('Business_unit__c'));
            }

            //Get list of Consortia IDs
            set<id> Conids = new set<id>();
            for(AgencyConsortium__c AgCon : [SELECT Agency__c,Business_Unit__c,Consortium__c,Inactive__c FROM AgencyConsortium__c WHERE Inactive__c = false AND Agency__c = :mysObject.id AND Business_Unit__c in :BUids]){
                Cons.add(new Consortia(AgCon.Business_Unit__c, AgCon.Consortium__c));
                Conids.add(AgCon.Consortium__c);
            }

            //Get the names of the Business Units + Consortia 
            map<id, Account> AccMap = new map<id, Account>([select id, name from Account where id in : BUids OR id in :Conids]);
            
            //Add Business Units to the picklist options
            BusinessUnits = new list<selectOption>();
            BusinessUnits.add(new selectOption('ALL', 'ALL'));
            for(ID AccID: BUids){
                BusinessUnits.add(new selectOption(AccID, AccMap.get(AccID).Name));
            }

            //Add Consortia and BU names to the consortia list
            for(Consortia Con:Cons){
                Con.Consortium = AccMap.get(Con.ConsortiumID).Name;
                Con.BusinessUnit = AccMap.get(Con.BusinessUnitID).Name;
            }

            FormatConsortia();
        //}
        /*catch (exception e){
            showFilters = false;
            system.debug(loggingLevel.Error, 'Error when generating filters = '+ e.getMessage());
            system.debug(loggingLevel.Error, 'Line Number = '+ string.valueof(e.getLineNumber()) );
            system.debug(loggingLevel.Error, 'Error Type = '+ string.valueof(e.getTypeName()) );
            system.debug(loggingLevel.Error, 'Stack Track = '+ e.getStackTracestring() ); 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Error when generating filters - please notify a System Admin'));          
        }*/
    }



    public void FormatConsortia(){
        ConsToView = new list<Consortia>();
        for(Consortia Con:Cons){
            if(BusinessUnit != '' && BusinessUnit != null){
                if(BusinessUnit == 'ALL' || (Con.BusinessUnitID == BusinessUnit)){
                    ConsToView.add(Con);
                }
            }
            else{
                ConsToView.add(Con);
            }
        }
    }

    public void BuildCurrencies(){
        //variables
        Currencies = new list<selectOption>();
        CurrencyRates = new map<string, decimal>();
        set<string> CurrencySet = new set<string>();

        //Get users Currency
        ChosenCurrency = UserInfo.getDefaultCurrency();
        system.debug(loggingLevel.ERROR,'User Currency = '+ChosenCurrency);
        CurrencySet.add(ChosenCurrency);

        //Add in any currencies used by the booking - should only be one
        for(AggregateResult BUCur : [select currencyisocode from Summary_analysis_2__c where Account__c = :mysObject.id AND Type__c = 'Business Unit - Brochure - Agency - Split By Owner' AND Active__c = true GROUP BY currencyisocode]){
            string Cur = (string) BUCur.get('currencyisocode');
            if(!CurrencySet.contains(Cur)){
                CurrencySet.add(Cur);
            }
        }
        system.debug(loggingLevel.ERROR,'Currency Options = '+CurrencySet);

        //Find the Conversion rates for the currencies + Add to picklist
        for(currencytype Cur : [SELECT conversionrate, isocode FROM currencytype WHERE isocode in : CurrencySet]){
            CurrencyRates.put(Cur.isoCode, Cur.conversionrate);
            Currencies.add(new selectOption(Cur.isoCode, Cur.isoCode));
        }

        //Set default conversion rate
        //getCurrencyRate();
        UserDefaultConversionRate = CurrencyRates.get(ChosenCurrency);
    }

    public void getCurrencyRate(){
        //conversionRate = CurrencyRates.get(ChosenCurrency);
        system.debug(loggingLevel.ERROR,'Conversion rate = '+conversionRate);
    }

    public double ConversionRate{
        get{
            if(Type == 'Month'){
                ConversionRate = CurrencyRates.get(ChosenCurrency)/UserDefaultConversionRate;
            }
            else if(Type == 'Brochure Group'){
                ConversionRate = CurrencyRates.get(ChosenCurrency);
            }
            return ConversionRate;
        }
        set;
    }

    public class Consortia{
        public string BusinessUnit {get; set;}
        public string Consortium {get; set;}
        public string BusinessUnitID {get; set;}
        public string ConsortiumID {get; set;}

        public Consortia(ID BU, ID Con){
            BusinessUnitID = BU;
            ConsortiumID = Con;
        }
    }


    public string BusinessUnitName{
        get{
            if(BusinessUnit != null){
                if(BusinessUnit != 'ALL'){
                    list<Account> acc = [select name from Account where id = :BusinessUnit];
                    if(acc.size() ==1){
                        BusinessUnitName = acc[0].name;
                    }
                    else{
                        BusinessUnitName = 'ALL';
                    }
                }
                else{
                    BusinessUnitName = 'ALL';
                }
            }
            else{
                BusinessUnitName = 'ALL';
            }
            return BusinessUnitName;
        }
        set;
    }

    public void closeFilters(){
        GroupBookingOnly = false;
        BusinessUnit = 'ALL';
        getBookings();
        showFilters = false;
    }


    public void GenerateFilters(){
        showFilters = true;
    }

    public void getBookings(){
        FormatConsortia();

        //get dates
        date dateToday = date.today();
        dateTodayLastYear = date.newInstance(dateToday.addYears(-1).year() , dateToday.month(), datetoday.day());
        dateEndOfNextYear = date.newInstance(dateToday.addYears(1).year() , 12, 31);
        dateBeginningOfTwoYearsAgo = date.newInstance(dateToday.addYears(-2).year() , 01, 01);

        //Start and end of this year
        dateEndOfThisYear = date.newInstance(dateToday.year() , 12, 31);
        dateStartOfThisYear = date.newInstance(dateToday.year() , 01, 01);

        //Start and end of last year
        dateEndOflastYear = date.newInstance(dateToday.addYears(-1).year() , 12, 31);
        dateStartOflastYear = date.newInstance(dateToday.addYears(-1).year() , 01, 01);

        
        //year strings
        C_Year = string.valueof(date.today().year());
        CYMOne_Year = string.valueof(dateToday.addYears(-1).year());
        CYMTwo_Year = string.valueof(dateToday.addYears(-2).year());
        CYPOne_Year = string.valueof(dateToday.addYears(1).year());


        try{
            AddToList();                                //Add in the 4 year spread
            Agg.sort();                                 //Sort the list by name
            ReportReady = true;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Untrapped Erorr. Please notify a System Admin!'));  
            system.debug(loggingLevel.Error, 'Untrapped Error = '+ e.getMessage() );
            system.debug(loggingLevel.Error, 'Line Number = '+ string.valueof(e.getLineNumber()) );
            system.debug(loggingLevel.Error, 'Error Type = '+ string.valueof(e.getTypeName()) );
            system.debug(loggingLevel.Error, 'Stack Track = '+ e.getStackTracestring() );  
        }

    }

    public void AddToList(){
        try{
            if(Type == 'Month'){
                
                query = 'SELECT Account__c,Apr_CY_M1_Pax__c,convertCurrency(Apr_CY_M1_Sales__c),Apr_CY_M1_YTD_Pax__c,convertCurrency(Apr_CY_M1_YTD_Sales__c),Apr_CY_M2_Pax__c,convertCurrency(Apr_CY_M2_Sales__c),Apr_CY_P1_Pax__c,convertCurrency(Apr_CY_P1_Sales__c),Apr_CY_Pax__c,convertCurrency(Apr_CY_Sales__c),Apr_CY_YTD_Pax__c,convertCurrency(Apr_CY_YTD_Sales__c),Aug_CY_M1_Pax__c,convertCurrency(Aug_CY_M1_Sales__c),Aug_CY_M1_YTD_Pax__c,convertCurrency(Aug_CY_M1_YTD_Sales__c),Aug_CY_M2_Pax__c,convertCurrency(Aug_CY_M2_Sales__c),Aug_CY_P1_Pax__c,convertCurrency(Aug_CY_P1_Sales__c),Aug_CY_Pax__c,convertCurrency(Aug_CY_Sales__c),Aug_CY_YTD_Pax__c,convertCurrency(Aug_CY_YTD_Sales__c),Brochure_Text__c,Business_Unit__c,CY_Minus_1_Pax__c,convertCurrency(CY_Minus_1_Sales__c),CY_Minus_2_Pax__c,convertCurrency(CY_Minus_2_Sales__c),CY_Pax__c,CY_plus_1_Pax__c,convertCurrency(CY_Plus_1_Sales__c),convertCurrency(CY_Sales__c),Dec_CY_M1_Pax__c,convertCurrency(Dec_CY_M1_Sales__c),Dec_CY_M1_YTD_Pax__c,convertCurrency(Dec_CY_M1_YTD_Sales__c),Dec_CY_M2_Pax__c,convertCurrency(Dec_CY_M2_Sales__c),Dec_CY_P1_Pax__c,convertCurrency(Dec_CY_P1_Sales__c),Dec_CY_Pax__c,convertCurrency(Dec_CY_Sales__c),Dec_CY_YTD_Pax__c,convertCurrency(Dec_CY_YTD_Sales__c),convertCurrency(Departure_CY_Booked_Last_Value__c),Departure_this_year_booked_last_year__c,Feb_CY_M1_Pax__c,convertCurrency(Feb_CY_M1_Sales__c),Feb_CY_M1_YTD_Pax__c,convertCurrency(Feb_CY_M1_YTD_Sales__c),Feb_CY_M2_Pax__c,convertCurrency(Feb_CY_M2_Sales__c),Feb_CY_P1_Pax__c,convertCurrency(Feb_CY_P1_Sales__c),Feb_CY_Pax__c,convertCurrency(Feb_CY_Sales__c),Feb_CY_YTD_Pax__c,convertCurrency(Feb_CY_YTD_Sales__c),Group_Booking__c,Jan_CY_M1_Pax__c,convertCurrency(Jan_CY_M1_Sales__c),Jan_CY_M1_YTD_Pax__c,convertCurrency(Jan_CY_M1_YTD_Sales__c),Jan_CY_M2_Pax__c,convertCurrency(Jan_CY_M2_Sales__c),Jan_CY_P1_Pax__c,convertCurrency(Jan_CY_P1_Sales__c),Jan_CY_Pax__c,convertCurrency(Jan_CY_Sales__c),Jan_CY_YTD_Pax__c,convertCurrency(Jan_CY_YTD_Sales__c),Jul_CY_M1_Pax__c,convertCurrency(Jul_CY_M1_Sales__c),Jul_CY_M1_YTD_Pax__c,convertCurrency(Jul_CY_M1_YTD_Sales__c),Jul_CY_M2_Pax__c,convertCurrency(Jul_CY_M2_Sales__c),Jul_CY_P1_Pax__c,convertCurrency(Jul_CY_P1_Sales__c),Jul_CY_Pax__c,convertCurrency(Jul_CY_Sales__c),Jul_CY_YTD_Pax__c,convertCurrency(Jul_CY_YTD_Sales__c),Jun_CY_M1_Pax__c,convertCurrency(Jun_CY_M1_Sales__c),Jun_CY_M1_YTD_Pax__c,convertCurrency(Jun_CY_M1_YTD_Sales__c),Jun_CY_M2_Pax__c,convertCurrency(Jun_CY_M2_Sales__c),Jun_CY_P1_Pax__c,convertCurrency(Jun_CY_P1_Sales__c),Jun_CY_Pax__c,convertCurrency(Jun_CY_Sales__c),Jun_CY_YTD_Pax__c,convertCurrency(Jun_CY_YTD_Sales__c),Mar_CY_M1_Pax__c,convertCurrency(Mar_CY_M1_Sales__c),Mar_CY_M1_YTD_Pax__c,convertCurrency(Mar_CY_M1_YTD_Sales__c),Mar_CY_M2_Pax__c,convertCurrency(Mar_CY_M2_Sales__c),Mar_CY_P1_Pax__c,convertCurrency(Mar_CY_P1_Sales__c),Mar_CY_Pax__c,convertCurrency(Mar_CY_Sales__c),Mar_CY_YTD_Pax__c,convertCurrency(Mar_CY_YTD_Sales__c),May_CY_M1_Pax__c,convertCurrency(May_CY_M1_Sales__c),May_CY_M1_YTD_Pax__c,convertCurrency(May_CY_M1_YTD_Sales__c),May_CY_M2_Pax__c,convertCurrency(May_CY_M2_Sales__c),May_CY_P1_Pax__c,convertCurrency(May_CY_P1_Sales__c),May_CY_Pax__c,convertCurrency(May_CY_Sales__c),May_CY_YTD_Pax__c,convertCurrency(May_CY_YTD_Sales__c),Nov_CY_M1_Pax__c,convertCurrency(Nov_CY_M1_Sales__c),Nov_CY_M1_YTD_Pax__c,convertCurrency(Nov_CY_M1_YTD_Sales__c),Nov_CY_M2_Pax__c,convertCurrency(Nov_CY_M2_Sales__c),Nov_CY_P1_Pax__c,convertCurrency(Nov_CY_P1_Sales__c),Nov_CY_Pax__c,convertCurrency(Nov_CY_Sales__c),Nov_CY_YTD_Pax__c,convertCurrency(Nov_CY_YTD_Sales__c),Oct_CY_M1_Pax__c,convertCurrency(Oct_CY_M1_Sales__c),Oct_CY_M1_YTD_Pax__c,convertCurrency(Oct_CY_M1_YTD_Sales__c),Oct_CY_M2_Pax__c,convertCurrency(Oct_CY_M2_Sales__c),Oct_CY_P1_Pax__c,convertCurrency(Oct_CY_P1_Sales__c),Oct_CY_Pax__c,convertCurrency(Oct_CY_Sales__c),Oct_CY_YTD_Pax__c,convertCurrency(Oct_CY_YTD_Sales__c),Sep_CY_M1_Pax__c,convertCurrency(Sep_CY_M1_Sales__c),Sep_CY_M1_YTD_Pax__c,convertCurrency(Sep_CY_M1_YTD_Sales__c),Sep_CY_M2_Pax__c,convertCurrency(Sep_CY_M2_Sales__c),Sep_CY_P1_Pax__c,convertCurrency(Sep_CY_P1_Sales__c),Sep_CY_Pax__c,convertCurrency(Sep_CY_Sales__c),Sep_CY_YTD_Pax__c,convertCurrency(Sep_CY_YTD_Sales__c),Type__c,YTD_Previous_Year_Departure_Pax__c,convertCurrency(YTD_Previous_Year_Departure_Value__c) FROM Summary_analysis_2__c';
                query += ' WHERE Type__c = \'Business Unit - Brochure - Agency - Split By Owner\' AND Active__c = true AND Account__c = \''+(string)mysObject.id + '\'';
                if(BusinessUnit != '' && BusinessUnit != null && BusinessUnit != 'ALL'){
                    query += ' AND Business_Unit__c = \''+ BusinessUnit + '\'';
                }

                if(GroupBookingOnly != null){
                    if(GroupBookingOnly){
                        query += ' AND Group_Booking__c = true ';
                    }
                }
                system.debug(loggingLevel.Error,'Month Query = '+ query);

                Agg = new list<Aggregate_AgencyProd>();
                Agg.add(new Aggregate_AgencyProd('01','Month'));
                Agg.add(new Aggregate_AgencyProd('02','Month'));
                Agg.add(new Aggregate_AgencyProd('03','Month'));
                Agg.add(new Aggregate_AgencyProd('04','Month'));
                Agg.add(new Aggregate_AgencyProd('05','Month'));
                Agg.add(new Aggregate_AgencyProd('06','Month'));
                Agg.add(new Aggregate_AgencyProd('07','Month'));
                Agg.add(new Aggregate_AgencyProd('08','Month'));
                Agg.add(new Aggregate_AgencyProd('09','Month'));
                Agg.add(new Aggregate_AgencyProd('10','Month'));
                Agg.add(new Aggregate_AgencyProd('11','Month'));
                Agg.add(new Aggregate_AgencyProd('12','Month'));
                Agg.add(new Aggregate_AgencyProd('13','Month'));


                for(Summary_analysis_2__c SumAn : database.query(query)){
                    //January 
                    Agg[0].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jan_CY_M1_YTD_Pax__c);
                    Agg[0].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Jan_CY_M1_YTD_Sales__c);
                    Agg[0].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jan_CY_M1_Pax__c);
                    Agg[0].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Jan_CY_M1_Sales__c);
                    Agg[0].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jan_CY_M2_Pax__c);
                    Agg[0].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Jan_CY_M2_Sales__c);
                    Agg[0].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jan_CY_P1_Pax__c);
                    Agg[0].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Jan_CY_P1_Sales__c);
                    Agg[0].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jan_CY_Pax__c);
                    Agg[0].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Jan_CY_Sales__c);
                    Agg[0].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jan_CY_YTD_Pax__c);
                    Agg[0].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Jan_CY_YTD_Sales__c);
                    Agg[0].CalculateValues(conversionRate, VarianceSelected);

                    //Feburary  
                    Agg[1].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Feb_CY_M1_YTD_Pax__c);
                    Agg[1].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Feb_CY_M1_YTD_Sales__c);
                    Agg[1].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Feb_CY_M1_Pax__c);
                    Agg[1].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Feb_CY_M1_Sales__c);
                    Agg[1].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Feb_CY_M2_Pax__c);
                    Agg[1].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Feb_CY_M2_Sales__c);
                    Agg[1].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Feb_CY_P1_Pax__c);
                    Agg[1].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Feb_CY_P1_Sales__c);
                    Agg[1].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Feb_CY_Pax__c);
                    Agg[1].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Feb_CY_Sales__c);
                    Agg[1].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Feb_CY_YTD_Pax__c);
                    Agg[1].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Feb_CY_YTD_Sales__c);
                    Agg[1].CalculateValues(conversionRate, VarianceSelected);

                    //March 
                    Agg[2].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Mar_CY_M1_YTD_Pax__c);
                    Agg[2].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Mar_CY_M1_YTD_Sales__c);
                    Agg[2].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Mar_CY_M1_Pax__c);
                    Agg[2].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Mar_CY_M1_Sales__c);
                    Agg[2].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Mar_CY_M2_Pax__c);
                    Agg[2].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Mar_CY_M2_Sales__c);
                    Agg[2].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Mar_CY_P1_Pax__c);
                    Agg[2].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Mar_CY_P1_Sales__c);
                    Agg[2].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Mar_CY_Pax__c);
                    Agg[2].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Mar_CY_Sales__c);
                    Agg[2].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Mar_CY_YTD_Pax__c);
                    Agg[2].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Mar_CY_YTD_Sales__c);
                    Agg[2].CalculateValues(conversionRate, VarianceSelected);

                    //April 
                    Agg[3].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Apr_CY_M1_YTD_Pax__c);
                    Agg[3].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Apr_CY_M1_YTD_Sales__c);
                    Agg[3].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Apr_CY_M1_Pax__c);
                    Agg[3].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Apr_CY_M1_Sales__c);
                    Agg[3].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Apr_CY_M2_Pax__c);
                    Agg[3].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Apr_CY_M2_Sales__c);
                    Agg[3].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Apr_CY_P1_Pax__c);
                    Agg[3].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Apr_CY_P1_Sales__c);
                    Agg[3].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Apr_CY_Pax__c);
                    Agg[3].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Apr_CY_Sales__c);
                    Agg[3].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Apr_CY_YTD_Pax__c);
                    Agg[3].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Apr_CY_YTD_Sales__c);
                    Agg[3].CalculateValues(conversionRate, VarianceSelected);

                    //May 
                    Agg[4].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.May_CY_M1_YTD_Pax__c);
                    Agg[4].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.May_CY_M1_YTD_Sales__c);
                    Agg[4].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.May_CY_M1_Pax__c);
                    Agg[4].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.May_CY_M1_Sales__c);
                    Agg[4].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.May_CY_M2_Pax__c);
                    Agg[4].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.May_CY_M2_Sales__c);
                    Agg[4].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.May_CY_P1_Pax__c);
                    Agg[4].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.May_CY_P1_Sales__c);
                    Agg[4].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.May_CY_Pax__c);
                    Agg[4].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.May_CY_Sales__c);
                    Agg[4].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.May_CY_YTD_Pax__c);
                    Agg[4].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.May_CY_YTD_Sales__c);
                    Agg[4].CalculateValues(conversionRate, VarianceSelected);

                    //June
                    Agg[5].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jun_CY_M1_YTD_Pax__c);
                    Agg[5].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Jun_CY_M1_YTD_Sales__c);
                    Agg[5].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jun_CY_M1_Pax__c);
                    Agg[5].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Jun_CY_M1_Sales__c);
                    Agg[5].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jun_CY_M2_Pax__c);
                    Agg[5].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Jun_CY_M2_Sales__c);
                    Agg[5].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jun_CY_P1_Pax__c);
                    Agg[5].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Jun_CY_P1_Sales__c);
                    Agg[5].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jun_CY_Pax__c);
                    Agg[5].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Jun_CY_Sales__c);
                    Agg[5].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jun_CY_YTD_Pax__c);
                    Agg[5].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Jun_CY_YTD_Sales__c);
                    Agg[5].CalculateValues(conversionRate, VarianceSelected);

                    //July 
                    Agg[6].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jul_CY_M1_YTD_Pax__c);
                    Agg[6].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Jul_CY_M1_YTD_Sales__c);
                    Agg[6].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jul_CY_M1_Pax__c);
                    Agg[6].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Jul_CY_M1_Sales__c);
                    Agg[6].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jul_CY_M2_Pax__c);
                    Agg[6].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Jul_CY_M2_Sales__c);
                    Agg[6].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jul_CY_P1_Pax__c);
                    Agg[6].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Jul_CY_P1_Sales__c);
                    Agg[6].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jul_CY_Pax__c);
                    Agg[6].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Jul_CY_Sales__c);
                    Agg[6].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Jul_CY_YTD_Pax__c);
                    Agg[6].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Jul_CY_YTD_Sales__c);
                    Agg[6].CalculateValues(conversionRate, VarianceSelected);

                    //August
                    Agg[7].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Aug_CY_M1_YTD_Pax__c);
                    Agg[7].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Aug_CY_M1_YTD_Sales__c);
                    Agg[7].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Aug_CY_M1_Pax__c);
                    Agg[7].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Aug_CY_M1_Sales__c);
                    Agg[7].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Aug_CY_M2_Pax__c);
                    Agg[7].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Aug_CY_M2_Sales__c);
                    Agg[7].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Aug_CY_P1_Pax__c);
                    Agg[7].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Aug_CY_P1_Sales__c);
                    Agg[7].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Aug_CY_Pax__c);
                    Agg[7].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Aug_CY_Sales__c);
                    Agg[7].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Aug_CY_YTD_Pax__c);
                    Agg[7].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Aug_CY_YTD_Sales__c);
                    Agg[7].CalculateValues(conversionRate, VarianceSelected);

                    //September
                    Agg[8].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Sep_CY_M1_YTD_Pax__c);
                    Agg[8].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Sep_CY_M1_YTD_Sales__c);
                    Agg[8].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Sep_CY_M1_Pax__c);
                    Agg[8].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Sep_CY_M1_Sales__c);
                    Agg[8].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Sep_CY_M2_Pax__c);
                    Agg[8].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Sep_CY_M2_Sales__c);
                    Agg[8].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Sep_CY_P1_Pax__c);
                    Agg[8].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Sep_CY_P1_Sales__c);
                    Agg[8].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Sep_CY_Pax__c);
                    Agg[8].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Sep_CY_Sales__c);
                    Agg[8].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Sep_CY_YTD_Pax__c);
                    Agg[8].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Sep_CY_YTD_Sales__c);
                    Agg[8].CalculateValues(conversionRate, VarianceSelected);

                    //October
                    Agg[9].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Oct_CY_M1_YTD_Pax__c);
                    Agg[9].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Oct_CY_M1_YTD_Sales__c);
                    Agg[9].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Oct_CY_M1_Pax__c);
                    Agg[9].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Oct_CY_M1_Sales__c);
                    Agg[9].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Oct_CY_M2_Pax__c);
                    Agg[9].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Oct_CY_M2_Sales__c);
                    Agg[9].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Oct_CY_P1_Pax__c);
                    Agg[9].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Oct_CY_P1_Sales__c);
                    Agg[9].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Oct_CY_Pax__c);
                    Agg[9].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Oct_CY_Sales__c);
                    Agg[9].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Oct_CY_YTD_Pax__c);
                    Agg[9].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Oct_CY_YTD_Sales__c);
                    Agg[9].CalculateValues(conversionRate, VarianceSelected);

                    //November
                    Agg[10].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Nov_CY_M1_YTD_Pax__c);
                    Agg[10].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Nov_CY_M1_YTD_Sales__c);
                    Agg[10].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Nov_CY_M1_Pax__c);
                    Agg[10].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Nov_CY_M1_Sales__c);
                    Agg[10].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Nov_CY_M2_Pax__c);
                    Agg[10].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Nov_CY_M2_Sales__c);
                    Agg[10].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Nov_CY_P1_Pax__c);
                    Agg[10].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Nov_CY_P1_Sales__c);
                    Agg[10].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Nov_CY_Pax__c);
                    Agg[10].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Nov_CY_Sales__c);
                    Agg[10].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Nov_CY_YTD_Pax__c);
                    Agg[10].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Nov_CY_YTD_Sales__c);
                    Agg[10].CalculateValues(conversionRate, VarianceSelected);

                    //December 
                    Agg[11].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Dec_CY_M1_YTD_Pax__c);
                    Agg[11].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.Dec_CY_M1_YTD_Sales__c);
                    Agg[11].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Dec_CY_M1_Pax__c);
                    Agg[11].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Dec_CY_M1_Sales__c);
                    Agg[11].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Dec_CY_M2_Pax__c);
                    Agg[11].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.Dec_CY_M2_Sales__c);
                    Agg[11].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Dec_CY_P1_Pax__c);
                    Agg[11].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.Dec_CY_P1_Sales__c);
                    Agg[11].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Dec_CY_Pax__c);
                    Agg[11].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.Dec_CY_Sales__c);
                    Agg[11].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Dec_CY_YTD_Pax__c);
                    Agg[11].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Dec_CY_YTD_Sales__c);
                    Agg[11].CalculateValues(conversionRate, VarianceSelected);

                    //Total
                    Agg[12].YTD_CYM1_Pax += Reports_Common_Code.ConvertToInteger(SumAn.YTD_Previous_Year_Departure_Pax__c);
                    Agg[12].YTD_CYM1_Val += Reports_Common_Code.SetNullToZero(SumAn.YTD_Previous_Year_Departure_Value__c);
                    Agg[12].CYMOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.CY_Minus_1_Pax__c);
                    Agg[12].CYMOne_Value += Reports_Common_Code.SetNullToZero(SumAn.CY_Minus_1_Sales__c);
                    Agg[12].CYMTwo_Pax += Reports_Common_Code.ConvertToInteger(SumAn.CY_Minus_2_Pax__c);
                    Agg[12].CYMTwo_Value += Reports_Common_Code.SetNullToZero(SumAn.CY_Minus_2_Sales__c);
                    Agg[12].CYPOne_Pax += Reports_Common_Code.ConvertToInteger(SumAn.CY_plus_1_Pax__c);
                    Agg[12].CYPOne_Value += Reports_Common_Code.SetNullToZero(SumAn.CY_Plus_1_Sales__c);
                    Agg[12].CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.CY_Pax__c);
                    Agg[12].CY_Value += Reports_Common_Code.SetNullToZero(SumAn.CY_Sales__c);
                    Agg[12].YTD_CY_Pax += Reports_Common_Code.ConvertToInteger(SumAn.Departure_this_year_booked_last_year__c);
                    Agg[12].YTD_CY_Val += Reports_Common_Code.SetNullToZero(SumAn.Departure_CY_Booked_Last_Value__c);
                    Agg[12].CalculateValues(conversionRate, VarianceSelected);
                }
            }
            else if(Type == 'Brochure Group'){
                query = 'select Brochure_Text__c, SUM(YTD_Previous_Year_Departure_Pax__c) YTD_Previous_Pax,SUM(YTD_Previous_Year_Departure_Value__c) YTD_Previous_Value, SUM(CY_Minus_1_Pax__c) CY_Minus_1_Pax,SUM(CY_Minus_1_Sales__c) CY_Minus_1_Sales,SUM(CY_Minus_2_Pax__c) CY_Minus_2_Pax,SUM(CY_Minus_2_Sales__c) CY_Minus_2_Sales,SUM(CY_plus_1_Pax__c) CY_plus_1_Pax,SUM(CY_Plus_1_Sales__c) CY_Plus_1_Sales,SUM(CY_Pax__c) CY_Pax,SUM(CY_Sales__c) CY_Sales,SUM(Departure_this_year_booked_last_year__c) Departure_this_pax,SUM(Departure_CY_Booked_Last_Value__c) Departure_CY_Value FROM Summary_analysis_2__c';
                query += ' WHERE Type__c = \'Business Unit - Brochure - Agency - Split By Owner\' AND Active__c = true AND Account__c = \''+(string)mysObject.id + '\'';
                
                if(BusinessUnit != '' && BusinessUnit != null && BusinessUnit != 'ALL'){
                    query += ' AND Business_Unit__c = \''+ BusinessUnit + '\'';
                }

                if(GroupBookingOnly != null){
                    if(GroupBookingOnly){
                        query += ' AND Group_Booking__c = true ';
                    }
                }

                query += ' GROUP BY ROLLUP(Brochure_Text__c)';
                system.debug('Brochure Query = '+ query);

                Agg = new list<Aggregate_AgencyProd>();

                for(AggregateResult groupedResults : database.query(query)){
                    string GroupedByVal = (string) groupedResults.get('Brochure_Text__c');
                    if(GroupedByVal == null) GroupedByVal = 'Total';
                    Aggregate_AgencyProd AggProd = new Aggregate_AgencyProd(GroupedByVal,'Brochure Group');
                    
                    AggProd.YTD_CYM1_Pax = Reports_Common_Code.ConvertToInteger((decimal) groupedResults.get('YTD_Previous_Pax'));
                    AggProd.YTD_CYM1_Val = Reports_Common_Code.SetNullToZero((decimal) groupedResults.get('YTD_Previous_Value'));
                    AggProd.CYMOne_Pax = Reports_Common_Code.ConvertToInteger((decimal) groupedResults.get('CY_Minus_1_Pax'));
                    AggProd.CYMOne_Value = Reports_Common_Code.SetNullToZero((decimal) groupedResults.get('CY_Minus_1_Sales'));
                    AggProd.CYMTwo_Pax = Reports_Common_Code.ConvertToInteger((decimal) groupedResults.get('CY_Minus_2_Pax'));
                    AggProd.CYMTwo_Value = Reports_Common_Code.SetNullToZero((decimal) groupedResults.get('CY_Minus_2_Sales'));
                    AggProd.CYPOne_Pax = Reports_Common_Code.ConvertToInteger((decimal) groupedResults.get('CY_plus_1_Pax'));
                    AggProd.CYPOne_Value = Reports_Common_Code.SetNullToZero((decimal) groupedResults.get('CY_Plus_1_Sales'));
                    AggProd.CY_Pax = Reports_Common_Code.ConvertToInteger((decimal) groupedResults.get('CY_Pax'));
                    AggProd.CY_Value = Reports_Common_Code.SetNullToZero((decimal) groupedResults.get('CY_Sales'));
                    AggProd.YTD_CY_Pax = Reports_Common_Code.ConvertToInteger((decimal) groupedResults.get('Departure_this_pax'));
                    AggProd.YTD_CY_Val = Reports_Common_Code.SetNullToZero((decimal) groupedResults.get('Departure_CY_Value'));
                    AggProd.CalculateValues(conversionRate, VarianceSelected);
                    Agg.add(AggProd);
                }
            }
        }
        catch(exception e){
            system.debug(loggingLevel.Error, 'Error when building the table of results = '+ e.getMessage());
            system.debug(loggingLevel.Error, 'Line Number = '+ string.valueof(e.getLineNumber()) );
            system.debug(loggingLevel.Error, 'Error Type = '+ string.valueof(e.getTypeName()) );
            system.debug(loggingLevel.Error, 'Stack Track = '+ e.getStackTracestring() ); 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'Error when building the table of results - please notify a System Admin'));  
        }
    }


    public pageReference GoToRecord(){
        PageReference PR = new pageReference('/'+ RecordId);
        return PR;
    }


    public void switchVariance(){
        getCurrencyRate();
        for(Aggregate_AgencyProd Ag: Agg){
            Ag.CalculateValues(conversionRate, VarianceSelected);
        }
        ReportReady = true;
    }



    public List<SelectOption> getTypeOptions() {
        List<SelectOption> opt = new List<SelectOption>(); 
        opt.add(new SelectOption('Month','Month')); 
        opt.add(new SelectOption('Brochure Group','Brochure')); return opt; 
    }

    public List<SelectOption> getVarianceOptions() {
        List<SelectOption> opt = new List<SelectOption>(); 
        integer ThisYear = date.today().year();
        integer NextYear = thisYear+1;
        integer LastYear = thisYear-1;
        opt.add(new SelectOption('Next', NextYear + ' v ' + ThisYear)); 
        opt.add(new SelectOption('Last', ThisYear + ' v ' + LastYear)); 
        return opt; 
    }

    public string getVarianceLabel(){
        integer ThisYear = date.today().year();
        integer NextYear = thisYear+1;
        integer LastYear = thisYear-1;
        string varianceUI;
        if(VarianceSelected == 'Next'){
            varianceUI = NextYear + ' v ' + ThisYear;
        }
        else if(VarianceSelected == 'Last'){
            varianceUI = ThisYear + ' v ' + LastYear;
        }
        return varianceUI;
    }

    public pageReference BackToAcc(){
        PageReference PR = new pageReference('/'+mysObject.id);
        return PR;
    }
    public pageReference RenderPdf(){
        RenderAsPDForExcel = true;
        RenderAs='PDF';
        return null;

        /*PageReference PR = new pageReference('/apex/Agency_Production_Report_Page_V2?id='+mysObject.id);
        pR.setRedirect(true);
        return PR;*/
        
    }
    public pageReference RenderExcel(){
        ContentType = 'application/vnd.ms-excel#Agency_Report_'+ (String)mysObject.get('name') + '.xls';
        RenderAsPDForExcel = true;
        return null;
    }

}