// **** Built By Ricky Lowe (Cloud Perspective) 08/09/2014
// **** Controller Extension aggregates the Bookings associated with a Travel Agent by Month.
// **** Results are then collected in a Class so that they can be presented on a VisualForce Page

// **** To Deploy:
// * Agency_Production_Report_Extension
// * Agency_Production_Report
// * Departure_Month_Year__c field on Booking

// **** To Do:
// 1) Add Departure_Month_Year__c field on the Booking object in Production.
// 2) Set ICS jobs that create the Bookings to set the Departure_Month_Year__c field
// 3) test code coverage


public with sharing class Agency_Production_Report_Extension {

    private final sObject mysObject;
    public date FutureDateFilter {get; set;}
    public date PastDateFilter {get; set;}
    public list<Aggregate> Agg {get; set;}
    public boolean ReportReady {get; set;}
    public list<selectOption> BusinessUnits {get;set;}
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
    public string ThisCurrency {get;set;}
    public Double conversionRate;
    public boolean IsNotSalesforce1 {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Agency_Production_Report_Extension(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        ReportReady = false;
        getBookings();
        showFilters = false;
        BusinessUnit = 'ALL';
        GroupBookingOnly = false;
        ContentType = '';
        RenderAs = '';
        RenderAsPDForExcel = false;

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
        showFilters = false;
    }


    public void GenerateFilters(){
        BusinessUnits = new list<selectOption>();
        BusinessUnits.add(new selectOption('ALL', 'ALL'));

        set<id> BUids = new set<id>();
        for(AggregateResult BU : [select Selling_Company__c from Booking__c where Travel_Agent__c = :mysObject.id AND First_Departure_Date__c >= :PastDateFilter AND First_Departure_Date__c <= :FutureDateFilter AND Status__c != 'CX' AND Status__c != 'AC' GROUP BY Selling_Company__c]){
            BUids.add((id)BU.get('Selling_Company__c'));
        }
        for(Account Acc:[select id, name from Account where id in : BUids]){
            BusinessUnits.add(new selectOption(Acc.id, Acc.name));
        }
        showFilters = true;
    }

    public void getBookings(){
        //Get a currency - fix for now
        list<booking__c> Book = [select currencyISOCode from Booking__c where Travel_Agent__c = :mysObject.id AND First_Departure_Date__c >= :PastDateFilter AND First_Departure_Date__c <= :FutureDateFilter AND Status__c != 'CX' AND Status__c != 'AC' limit 1];
        if(Book.size() ==1){
            ThisCurrency = book[0].currencyISOCode;
        }
        else{
            ThisCurrency = (string)mysObject.get('currencyISOCode');
        }
        conversionRate = [SELECT conversionrate FROM currencytype WHERE isocode =: ThisCurrency LIMIT 1].conversionRate;


        system.debug('Currency = '+ ThisCurrency);
        system.debug('Conversion rate = '+ conversionRate);
        //Need date range
        //Default will be + 1 year and - 2 years
        date dateToday = date.today();
        date dateEndOfNextYear = date.newInstance(dateToday.addYears(1).year() , 12, 31);
        date dateBeginningOfTwoYearsAgo = date.newInstance(dateToday.addYears(-2).year() , 01, 01);
        C_Year = string.valueof(date.today().year());
        CYMOne_Year = string.valueof(dateToday.addYears(-1).year());
        CYMTwo_Year = string.valueof(dateToday.addYears(-2).year());
        CYPOne_Year = string.valueof(dateToday.addYears(1).year());

        //Generate Aggregate list
        generateAgg();

        try{
            //Build Query
            //By Default use beginning of 2 years ago and end of next year
            FutureDateFilter = dateEndOfNextYear;
            PastDateFilter = dateBeginningOfTwoYearsAgo;

            string FutureDateFilterString = string.valueof(FutureDateFilter).replace(' ', 'T') + 'Z';
            string PastDateFilterString = string.valueof(PastDateFilter).replace(' ', 'T') + 'Z';

            string query = 'select Departure_Month_Year__c, Payment_Status__c, sum(Pax_Count_Tour__c), sum(Gross_Price_Tour__c), count(id) from Booking__c where Travel_Agent__c = \'' + mysObject.id + '\' AND First_Departure_Date__c >=  :PastDateFilter AND First_Departure_Date__c <= :FutureDateFilter AND Status__c != \'CX\' AND Status__c != \'AC\'';
            if(BusinessUnit != '' && BusinessUnit != null && BusinessUnit != 'ALL'){
                query += ' AND Selling_Company__c = \''+ BusinessUnit + '\'';
            }
            if(GroupBookingOnly != null){
                if(GroupBookingOnly){
                    query += ' AND Group_Booking__c = true ';
                }
            }

            query += ' GROUP BY ROLLUP(Departure_Month_Year__c, Payment_Status__c)';
            system.debug('Aggregate Query = '+ query);

            //Query Bookings and aggregate
            for(AggregateResult groupedResults : database.query(query)){
                string DepMonthYear = string.valueof(groupedResults.get('Departure_Month_Year__c'));
                string PayStatus = string.valueof(groupedResults.get('Payment_Status__c'));
                //We are not interested in the grand total (DepMonthYear == null)
                //Or the totals for any other payment status other thean Fully paid (FP) and null (the sub total)
                if(DepMonthYear != null && DepMonthYear != '' && (PayStatus == null || PayStatus =='FP')){
                    string theYear = DepMonthYear.substring(0,4);
                    integer theMonth = integer.valueof(DepMonthYear.substring(5));
                    integer thisPaxCount = integer.valueof(string.valueof(groupedResults.get('expr0')));
                    decimal thisValue = decimal.valueof(string.valueof(groupedResults.get('expr1'))).setScale(2) ;


                    if(theYear == C_Year){
                        //FP means Fully paid
                        if(PayStatus == 'FP'){
                            Agg[theMonth-1].CY_FPPax += thisPaxCount;
                        }
                        //If pay Status is null then it means that this is the total of all Payments for this Month/Year
                        else if(PayStatus == null){
                            Agg[theMonth-1].CY_Pax += thisPaxCount;
                            Agg[theMonth-1].CY_Value += thisValue;
                            Agg[12].CY_Pax += thisPaxCount;
                            Agg[12].CY_Value += thisValue;
                        }
                    }
                    else if(theYear == CYMOne_Year){
                        //FP means Fully paid
                        if(PayStatus == 'FP'){
                            Agg[theMonth-1].CYMOne_FPPax += thisPaxCount;
                        }
                        //If pay Status is null then it means that this is the total of all Payments for this Month/Year
                        else if(PayStatus == null){
                            Agg[theMonth-1].CYMOne_Pax += thisPaxCount;
                            Agg[theMonth-1].CYMOne_Value += thisValue;
                            Agg[12].CYMOne_Pax += thisPaxCount;
                            Agg[12].CYMOne_Value += thisValue;
                        }
                    }
                    else if(theYear == CYMTwo_Year){
                        //FP means Fully paid
                        if(PayStatus == 'FP'){
                            Agg[theMonth-1].CYMTwo_FPPax += thisPaxCount;
                        }
                        //If pay Status is null then it means that this is the total of all Payments for this Month/Year
                        else if(PayStatus == null){
                            Agg[12].CYMTwo_Pax += thisPaxCount;
                            Agg[12].CYMTwo_Value += thisValue;
                            Agg[theMonth-1].CYMTwo_Pax += thisPaxCount;
                            Agg[theMonth-1].CYMTwo_Value += thisValue;
                        }
                    }
                    else if(theYear == CYPOne_Year){
                        //FP means Fully paid
                        if(PayStatus == 'FP'){
                            Agg[theMonth-1].CYPOne_FPPax += thisPaxCount;
                        }
                        //If pay Status is null then it means that this is the total of all Payments for this Month/Year
                        else if(PayStatus == null){
                            Agg[12].CYPOne_Pax += thisPaxCount;
                            Agg[12].CYPOne_Value += thisValue;
                            Agg[theMonth-1].CYPOne_Pax += thisPaxCount;
                            Agg[theMonth-1].CYPOne_Value += thisValue;
                        }
                    }
                }
            }

            //Format the decimals
            for(Aggregate Ag:Agg){
                Ag.CalculateValues(conversionRate);
            }
            //Calculate the variances
            //CalcVariences();
            ReportReady = true;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'An untrapped erorr: ' + string.valueof(e.getcause())+ ' : ' + string.valueof(e.getLineNumber()) + ' : ' + e.getMessage() + ' : ' + e.getTypeName() + ' : ' + e.getStackTracestring()));          
        }

    }

    //Generate the Aggregation list iwth months
    public void generateAgg(){
        try{
            Agg = new list<Aggregate>();
            //Jan
            Aggregate janAgg = new Aggregate();
            janAgg.month = 'January';
            Agg.add(janAgg);
            //Feb
            Aggregate febAgg = new Aggregate();
            febAgg.month = 'February';
            Agg.add(febAgg);
            //Mar
            Aggregate MarAgg = new Aggregate();
            MarAgg.month = 'March';
            Agg.add(MarAgg);
            //Apr
            Aggregate AprAgg = new Aggregate();
            AprAgg.month = 'April';
            Agg.add(AprAgg);
            //May
            Aggregate MayAgg = new Aggregate();
            MayAgg.month = 'May';
            Agg.add(MayAgg);
            //Jun
            Aggregate JunAgg = new Aggregate();
            JunAgg.month = 'June';
            Agg.add(JunAgg);
            //Jul
            Aggregate JulAgg = new Aggregate();
            JulAgg.month = 'July';
            Agg.add(JulAgg);
            //Aug
            Aggregate AugAgg = new Aggregate();
            AugAgg.month = 'August';
            Agg.add(AugAgg);
            //Sep
            Aggregate SepAgg = new Aggregate();
            SepAgg.month = 'September';
            Agg.add(SepAgg);
            //Oct
            Aggregate OctAgg = new Aggregate();
            OctAgg.month = 'October';
            Agg.add(OctAgg);
            //Nov
            Aggregate NovAgg = new Aggregate();
            NovAgg.month = 'November';
            Agg.add(NovAgg);
            //Dec
            Aggregate DecAgg = new Aggregate();
            DecAgg.month = 'December';
            Agg.add(DecAgg);
            //Total
            Aggregate totAgg = new Aggregate();
            totAgg.month = 'Total';
            Agg.add(totAgg);

        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'An untrapped erorr: ' + string.valueof(e.getcause())+ ' : ' + string.valueof(e.getLineNumber()) + ' : ' + e.getMessage() + ' : ' + e.getTypeName() + ' : ' + e.getStackTracestring()));          
        }
        
    }


    //Aggregate inner class to hold results - am hard coding columns for now
    public class Aggregate
    {
        public string month {get;set;}
        public integer CY_Pax {get;set;}
        public decimal CY_Value {get;set;}
        public decimal CY_FPPax {get;set;}
        public string CY_ValueFormat {get;set;}

        public integer CYMOne_Pax {get;set;}
        public decimal CYMOne_Value {get;set;}
        public decimal CYMOne_FPPax {get;set;}
        public string CYMOne_ValueFormat {get;set;}

        public integer CYMTwo_Pax {get;set;}
        public decimal CYMTwo_Value {get;set;}
        public decimal CYMTwo_FPPax {get;set;}
        public string CYMTwo_ValueFormat {get;set;}

        public integer CYPOne_Pax {get;set;}
        public decimal CYPOne_Value {get;set;}
        public decimal CYPOne_FPPax {get;set;}
        public string CYPOne_ValueFormat {get;set;}

        public string CY_VarienceValue {get;set;}
        public decimal CY_VariencePax {get;set;}
        public string CY_VariencePaxFormat {get;set;}

        public boolean PaxNegative {get;set;}
        public boolean ValueNegative {get;set;}

        public Aggregate()
        {
            CY_Pax = 0;
            CY_Value = 0.00;
            CY_FPPax = 0;
            CYMOne_Pax = 0;
            CYMOne_Value = 0.00;
            CYMOne_FPPax = 0;
            CYMTwo_Pax = 0;
            CYMTwo_Value = 0.00;
            CYMTwo_FPPax = 0;
            CYPOne_Pax = 0;
            CYPOne_Value = 0.00;
            CYPOne_FPPax = 0;
            CY_VariencePax = 0;
            PaxNegative = false;
            ValueNegative = false;

        }

        public void CalculateValues(double conversionRate){
            //Calculate the values in the correct currency
            decimal CY_Conv = (CY_Value*conversionRate).setScale(2);
            decimal CYMOne_Conv = (CYMOne_Value*conversionRate).setScale(2);
            decimal CYMTwo_Conv = (CYMTwo_Value*conversionRate).setScale(2);
            decimal CYPOne_Conv = (CYPOne_Value*conversionRate).setScale(2);

            //format the Values
            CY_ValueFormat = Reports_Common_Code.formatTheCurrency(CY_Conv, true);
            CYMOne_ValueFormat = Reports_Common_Code.formatTheCurrency(CYMOne_Conv, true);
            CYMTwo_ValueFormat = Reports_Common_Code.formatTheCurrency(CYMTwo_Conv, true);
            CYPOne_ValueFormat = Reports_Common_Code.formatTheCurrency(CYPOne_Conv, true);

            //Calculate the difference for the Value
            decimal diff = CY_Conv - CYMOne_Conv;
            if(CY_Conv >= CYMOne_Conv){
                ValueNegative = false;
            }
            else{
                ValueNegative = true;
            }

            //Calculate Value varience 
            string CY_VarienceValDiff = Reports_Common_Code.formatTheCurrency(diff, !ValueNegative);
            decimal VarianceValPercentage;
            if(CY_Conv > 0){
                VarianceValPercentage = ((CY_Conv - CYMOne_Conv)/CY_Conv)*100;
            }
            else{
                VarianceValPercentage = 0;
            }

            CY_VarienceValue = CY_VarienceValDiff + ' ('+ VarianceValPercentage.setScale(2) + '%)';

            //Calculate Pax Count Varience
            CY_VariencePax = CY_Pax - CYMOne_Pax;
            if(CY_Pax >= CYMOne_Pax){
                PaxNegative = false;
            }
            else{
                PaxNegative = true;
            }

            decimal PaxVarPercentage;
            if(CYMOne_Pax > 0){
                PaxVarPercentage = (CY_VariencePax/CYMOne_Pax)*100;
            }
            else{
                PaxVarPercentage = 0;
            }

            
            CY_VariencePaxFormat = CY_VariencePax + ' ('+ PaxVarPercentage.setScale(2) + '%)';

            //Calculate Value Varience 
            system.debug('***Values for Month = '+ month);
            system.debug('CY_Conv = '+ CY_Conv);
            system.debug('CYMOne_Conv = '+ CYMOne_Conv);
            system.debug('CY_VarienceValue  = '+ CY_VarienceValue );
            system.debug('difference = '+ diff);
            system.debug('***End***');
        }

    }

 /*   public static String currency(String i) {
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
        return s.substring(0,s.length()-1);
    }*/



    public pageReference BackToAcc(){
        PageReference PR = new pageReference('/'+mysObject.id);
        return PR;
    }
    public pageReference RenderPdf(){
        RenderAsPDForExcel = true;
        RenderAs='PDF';
        return null;
    }
    public pageReference RenderExcel(){
        ContentType = 'application/vnd.ms-excel#Agency_Report_'+ (String)mysObject.get('name') + '.xls';
        RenderAsPDForExcel = true;
        return null;
    }

}