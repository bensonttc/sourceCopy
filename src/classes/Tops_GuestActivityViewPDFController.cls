//
// Class Name: Tops_GuestActivityViewPDFController
// Description: It will help to generate guest acitvity list on vf page based on tour instance.
//
// 25th Nov 2016   Maksud Ali  (Story# - S-453096)
// 21st June 2017    Maksud Ali Origianl (Story # S-485982)

public class Tops_GuestActivityViewPDFController {

    
    public List<tourOptionalWrapper> lstSplitTableColumns {get;set;}
    public List<passengerWrapper> splitedPassenger { get; set; }
    public List<decimal> splitedTotal { get; set; }
    public List<SplitColumns> splitColumnsList { get; set; }
    public List<Integer> pageBreak { get; set; }
    public List<Integer> tmpStartFrom { get; set; }
    public string fontSize { get; set; }
    public string debugMsg { get; set; }
    public GuestsWrapper guestsView {get;set;}
    public List<Passenger__c> passengerList { get; set; }

    public string errMsg { get; set; }
    
    public Tops_GuestActivityViewPDFController(ApexPages.StandardController controller) {
        
        fontSize = '14px';
        Tour_Instance__c tiController = (Tour_Instance__c)controller.getRecord();
        
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
                
        string tourInstanceId = parameters.get('id');
        
        //Changes start, Done by Maksud Ali for Story : S-485982 (21st June 2017 updated limit 110)
        passengerList = [Select Id, Preferred_Name__c,First_Name__c,Family_Name__c,Passenger_Type__c ,Passenger_Class__c ,Passenger_Status__c,Status__c,
        (Select Id, Sales_Price__c,Name,Tour_Optional__r.Name,status__c from Passenger_Optionals__r where status__C != 'Cancelled') from Passenger__c where Tour_Instance__r.Id = :tourInstanceId 
        and Passenger_Class__c = 'Passenger' and status__c != 'CX' and Passenger_status__c != 'Deleted'   Order by Family_Name__c,First_Name__c
        limit : 110];
        //limit : Integer.valueOf(System.Label.GuestLimit)
        
        if(passengerList.size() > 95 ) {
            fontSize = '12px';
        }
        //End changes for story : S-485982 - 21st June 2017
        
        try {
            guestsView = new GuestsWrapper(passengerList,tiController);
            calculateTableColumns();
            
        }
        catch(Exception ex) {
            errMsg = ex.getMessage() + ' Line Number : ' + ex.getLineNumber();
        }
    }
    
    List<Integer> getPageBreakList(List<Tour_Optional__c> tourList) {
        
        List<Integer> lstCounter = new List<Integer>();
        Integer characterSize = 0;
        Integer currnetIndex = 0;
        Integer columnCounter = 0 ;
        lstCounter.add(0);
        boolean isFirstPage = true;

        for(Integer i=0; i<tourList.size();i++) {
            string subStr20 = tourList[i].Name;//.substring(0,20);
            
            string[] arrSplitName = subStr20.split(' ');
            integer maxWordLength = 0;
            for(string str : arrSplitName) {                
                if(maxWordLength < str.length()) {
                    maxWordLength = str.length();
                }
            }
            characterSize = characterSize + (maxWordLength * 12);
            characterSize += 20; //20 is extra space;
            
            
            //first page have 2 extra column such as guest name and guest type so I assume that rest page size will be 1100 left
            if(characterSize > 1100 && isFirstPage) {
                currnetIndex++;
                lstCounter.add(0);
                isFirstPage = false;
                characterSize = 0;
                columnCounter = 1;
            }
            
            if(characterSize > 1140) {
                currnetIndex++;
                lstCounter.add(0);
                characterSize = 0;
                columnCounter = 1;
            }
            
            lstCounter[currnetIndex] = columnCounter;
            columnCounter++;
            
            
        }
        
        //If there is no tour optioanl then below condition run.
        if(tourList.size() == 6){
            lstCounter[0] = 6; //it will print all col on single page.
        }
        else {
            //last page is missing one column so we add plus one on last index value.
            lstCounter[lstCounter.size() - 1] = lstCounter[lstCounter.size() - 1] + 1;
        }
        //debugMsg = ' ' + lstCounter;
        pageBreak = lstCounter;
        return lstCounter;
    }
    
    void calculateTableColumns() {
        GuestsWrapper tmpGuestWrapper = new GuestsWrapper();
        
        List<Integer> lstColumns = getPageBreakList(guestsView.lstToursOptional);
        
        tmpStartFrom = new List<Integer>();
        
        lstSplitTableColumns = new List<tourOptionalWrapper>();
        splitedPassenger = new List<passengerWrapper>();
        integer count = 0;
        integer columBreakSize = 0;
        integer characterSize = 0;
        
        
        for(Tour_Optional__c tour : guestsView.lstToursOptional) {
            string[] arrSplitName = tour.Name.split(' ');
            
            characterSize = characterSize + (arrSplitName[0].length() * 12);
            characterSize += 20; //20 is extra space;
            
            if(characterSize > 1100 && columBreakSize == 0) {
                columBreakSize = count;
                break;
            }
            count++;
        }
        
        count = 0;
        
        
        Integer splitColIndex = 0;
        boolean isFirstPageData = true;
        boolean isIncrease = true;
        boolean isIncreaseCount = true;
        for(Tour_Optional__c tour : guestsView.lstToursOptional) {
            
            if(count < lstColumns[0] && isFirstPageData) {
                   
                if(tmpGuestWrapper.lstToursOptional == null) {
                   tmpGuestWrapper.lstToursOptional = new List<Tour_Optional__c>();
                }
                tmpGuestWrapper.lstToursOptional.add(tour);   
            }
            else {
                
                tourOptionalWrapper tmpOptionalWrapper = new tourOptionalWrapper();
                tmpOptionalWrapper.passengerOptional = tour.Name;
                tmpOptionalWrapper.salesPrice = tour.Adult_Price__c;
                lstSplitTableColumns.add(tmpOptionalWrapper);
            }
            count++;
            
        }
        
        
        splitColIndex = 0;
        isFirstPageData = true;
        boolean isIncreasePsngrOptional = true;
        isIncreaseCount = true;
        count = 0;
        tmpGuestWrapper.lstPassenger = new List<passengerWrapper>();
       
        for(passengerWrapper psngr : guestsView.lstPassenger) {
            count = 0;
            integer tourOptionalCounter = 0;
            List<tourOptionalWrapper> tmpListTourOptional = new List<tourOptionalWrapper>();
            List<tourOptionalWrapper> tmpSplittedListTourOptional = new List<tourOptionalWrapper>();
            passengerWrapper tmpPsngr = new passengerWrapper();
            passengerWrapper tmpSplitPsngr = new passengerWrapper();
            for(tourOptionalWrapper psngrOption : psngr.lstTourOptional) {
                if(count < lstColumns[0]) {
                    tmpListTourOptional.add(psngrOption);
                }
                else {
                    tmpSplittedListTourOptional.add(psngrOption);
                }
                
                count++;
            }
            
            tmpPsngr = psngr;
            //adding into guest view
            tmpPsngr.lstTourOptional = tmpListTourOptional;
            tmpGuestWrapper.lstPassenger.add(tmpPsngr);
            
                
            //addinn into splitted columns
              tmpSplitPsngr = psngr.clone();  
              tmpSplitPsngr.lstTourOptional = tmpSplittedListTourOptional;
              splitedPassenger.add(tmpSplitPsngr);
            
        }
        
        
        //tmpGuestWrapper.lstPassenger = guestsView.lstPassenger;
        tmpGuestWrapper.guestHeader = guestsView.guestHeader;
        tmpGuestWrapper.lstTotals = guestsView.lstTotals;
        tmpGuestWrapper.todaysDate = guestsView.todaysDate;
        tmpGuestWrapper.totalAdults = guestsView.totalAdults;
        guestsView = tmpGuestWrapper;
        
        
        //total row calculation.
       
        List<decimal> tmpTotals = new List<decimal>();
        splitedTotal = new List<decimal>();
        count = 0;
        for(decimal total : guestsView.lstTotals) {
            
            if(count < lstColumns[0]) {
                tmpTotals.add(total);
            }
            else {
                splitedTotal.add(total);
            }
            count++;
        }
        guestsView.lstTotals = tmpTotals; 
        
        
        splitColumnsList = new List<SplitColumns>();
        Integer startFrom = 0;//lstColumns[1];
        Integer indexCounter = 0;
        integer tmpStartWith = 0;
        Integer maxLength = 0;
        
        for(Integer pageCounter = 1; pageCounter < lstColumns.size(); pageCounter++) {
            //tmpStartFrom.add(lstColumns[pageCounter]);
            SplitColumns headerSplitCols = new SplitColumns();
            headerSplitCols.lstSplitTableColumns = new List<tourOptionalWrapper>(); //that will use to render header of tour optional
            //Integer indexCounter = pageCounter;
            
            
            maxLength += lstColumns[pageCounter];
           // tmpStartFrom.add(tmpStartWith);
                        
            //header rendering logic lstSplitTableColumns.size();
            indexCounter = 0;
            for(Integer headerColCounter = tmpStartWith; headerColCounter < maxLength; headerColCounter++){   
               headerSplitCols.lstSplitTableColumns.add(lstSplitTableColumns[headerColCounter]);
            }
           
            //psngr tour optional rendering logic.
            headerSplitCols.lstSplitPsngrColumns = new List<passengerWrapper>();
            
            for(Integer psngrCounter = 0; psngrCounter < splitedPassenger.size(); psngrCounter++){
                passengerWrapper tmpPsnr = splitedPassenger[psngrCounter].clone();
                List<tourOptionalWrapper> tmpOptionals = new List<tourOptionalWrapper>();
                tmpStartFrom.add(tmpStartWith);
                tmpStartFrom.add(maxLength);
                for(Integer psngrTourCounter = tmpStartWith; psngrTourCounter < maxLength; psngrTourCounter++){
                    tmpOptionals.add(splitedPassenger[psngrCounter].lstTourOptional[psngrTourCounter]);
                }
                
                tmpPsnr.lstTourOptional =  tmpOptionals;
                headerSplitCols.lstSplitPsngrColumns.add(tmpPsnr);
            }
            
            
            //total of salesprice rendering
            indexCounter = 0;
            headerSplitCols.splitedTotal = new List<decimal>();
            for(Integer totalCounter = tmpStartWith; totalCounter < maxLength; totalCounter++){
                headerSplitCols.splitedTotal.add(splitedTotal[totalCounter]);
            }
            
            tmpStartWith = tmpStartWith + lstColumns[pageCounter];
            //tmpStartWith++;
            splitColumnsList.add(headerSplitCols);
            
        }
        
        
    }
    
    
    
    
    public class GuestsWrapper {
    
        public List<passengerWrapper> lstPassenger { get; set; }
        public List<Tour_Optional__c> lstToursOptional { get; set; }
        public List<decimal> lstTotals { get; set; }
        public string guestHeader {get;set;}
        public string todaysDate { get; set; }
        public string totalAdults { get; set; }
        
        
        public GuestsWrapper() {
            lstPassenger = new List<passengerWrapper>();
        }
        
        
        
        public GuestsWrapper(List<Passenger__c> passengrList,Tour_Instance__c stdController) {
            lstPassenger = new List<passengerWrapper>();
            
            //we will only get first 35 records of Tour_Optional__c as per customer requirment
            lstToursOptional = [Select Id,Name,Adult_Price__c from Tour_Optional__c where Tour_Instance__r.Id = : stdController.Id AND Included_in_Tour__c = false AND Use_Optional__c = true AND Duplicate__c = false order by Tour_Optional_Date__c,Time_order__c asc limit :Integer.valueOf(System.Label.Tour_Optional_limit)];

            //adding last 6 columns BPrice and rest 5 are empty
            lstToursOptional.add(new Tour_Optional__c(Name = System.Label.Total_less_child_discount));
            lstToursOptional.add(new Tour_Optional__c(Name = System.Label.Credit_Card));
            lstToursOptional.add(new Tour_Optional__c(Name = System.Label.Voucher));
            lstToursOptional.add(new Tour_Optional__c(Name = System.Label.Cash1));
            lstToursOptional.add(new Tour_Optional__c(Name = System.Label.Cash2));
            lstToursOptional.add(new Tour_Optional__c(Name = System.Label.Cash3));
            
            for(Passenger__c passengr : passengrList) {
              lstPassenger.add(new passengerWrapper(passengr,stdController,lstToursOptional));
            }
            
            
            if(stdController.Operating_Product_Code__c.toLowerCase().substring(0,1) == 'c'){
                guestHeader = System.Label.Traveler_Name;
            }
            else {
                guestHeader = System.Label.Guest_s_Name;
            }
            
            
            //adding last row which contain the date,total A and C and othe totals
            DateTime d = Date.Today() ;
            todaysDate = d.format('dd MMM yy') ; // assigning current date to full name so it will render just below the full column.
            
            //calculating total number of adult and child
            integer totalAdult = 0;
            integer counter = -1;
            lstTotals = new List<decimal>();
            for(passengerWrapper pwObj : lstPassenger) {
                if(pwObj.passengerType == 'AD') {
                    totalAdult = totalAdult + 1;    
                }
                
                if(pwObj.lstTourOptional != null) {
                    for(tourOptionalWrapper tOptional : pwObj.lstTourOptional) {
                        if(counter == -1) {
                            lstTotals.add(tOptional.isExistInOptionalPassenger == 'Y' ? 1 : 0);
                        }
                        else {
                            
                            lstTotals[counter] = tOptional.isExistInOptionalPassenger == 'Y' ? lstTotals[counter] + 1 : lstTotals[counter];
                            counter++;
                        }
                    }
                    counter=0;
                }
            }
            
            totalAdults = String.valueOf(totalAdult) + 'A - ' + String.valueOf(lstPassenger.size() - totalAdult) + 'C';
            
        }
    }
    
    public class passengerWrapper {
    
        public Id prodcutId { get; set; }
        public string fullName { get; set; }
        public string preferredName { get; set; }
        public string firstName { get; set; }
        public string familyName { get; set; }
        public string passengerType { get; set; }
        public List<tourOptionalWrapper> lstTourOptional { get; set; }
        public decimal totalSalesPrice { get; set; }    
        
        public passengerWrapper() { }
        
        public passengerWrapper(Passenger__c objPassenger, Tour_Instance__c tiController,List<Tour_Optional__c> lstToursOptional ) {
        
        
            prodcutId = objPassenger.Id;
            
            preferredName = String.isEmpty(objPassenger.Preferred_Name__c) ? '' : objPassenger.Preferred_Name__c;
            
            firstName = String.isEmpty(objPassenger.First_Name__c) ? '' : objPassenger.First_Name__c;
            
            familyName = String.isEmpty(objPassenger.Family_Name__c) ? '' : objPassenger.Family_Name__c;
            
            fullName = String.isEmpty(preferredName) ? firstName + ' ' + familyName : preferredName + ' ' + familyName;
            fullName = capitalizeWords(fullName);
            passengerType = objPassenger.Passenger_Type__c; 
            
            
            
            
            
            lstTourOptional = new List<tourOptionalWrapper>();
            totalSalesPrice = 0;
            
            for(Tour_Optional__c tOptional : lstToursOptional) {
                
                if(tOptional.Id != null)
                {
                
                    if(objPassenger.Passenger_Optionals__r == null || objPassenger.Passenger_Optionals__r.size() == 0) {
                        lstTourOptional.add(new tourOptionalWrapper());    
                    }
                    else {
                        tourOptionalWrapper newInstance = new tourOptionalWrapper();
                        
                        for(Passenger_Optional__c optional : objPassenger.Passenger_Optionals__r) {
                            //tourOptionalWrapper newInstance = new tourOptionalWrapper(optional,tOptional.Name);                        
                            
                            newInstance.initValuesOfTourOptionalWrapper(optional);
                            
                            
                            if(optional.Tour_Optional__r.Name == tOptional.Name && (optional.status__c != 'Included' || optional.status__c != 'Cancelled')) {
                                newInstance.passengerOptional = '1';
                                newInstance.salesPrice = optional.Sales_Price__c;
                                newInstance.isExistInOptionalPassenger = 'Y';
                                break;
                            }
                            
                        }
                        
                        
                        if(newInstance.salesPrice > 0) {
                        
                            totalSalesPrice = totalSalesPrice + newInstance.salesPrice;
                        }
                        
                        lstTourOptional.add(newInstance);
                    }
                }    
            }
            
            
            //adding last 6 columns Total salesprice and rest 5 are empty
            lstTourOptional.add(new tourOptionalWrapper(totalSalesPrice == 0 ? '' : string.valueOf(totalSalesPrice.setScale(2))));
            lstTourOptional.add(new tourOptionalWrapper(''));
            lstTourOptional.add(new tourOptionalWrapper(''));
            lstTourOptional.add(new tourOptionalWrapper(''));
            lstTourOptional.add(new tourOptionalWrapper(''));
            lstTourOptional.add(new tourOptionalWrapper(''));
        }
        
        String capitalizeWords(String input)
        {
            
            String output = '';
            Matcher m = Pattern.compile('(\\w+|\\W+)').matcher(input.toLowerCase());
            while (m.find()) output += m.group().capitalize();
            return output;
        }
    }
    
    public class tourOptionalWrapper {
    
        public Id tourOptionalId { get; set; }
        
        public string tourName { get; set; }
        
        public string tourInstanceName { get; set; }
        
        public double salesPrice { get; set; }
        
        public string passengerOptional { get; set; }
        
        public string isExistInOptionalPassenger { get; set; }
        
        public tourOptionalWrapper() {
            passengerOptional = '';
            salesPrice= 0.0;
        }
        
        public tourOptionalWrapper(string strPassengerOptional) {
            passengerOptional = strPassengerOptional;
        }
        
        public tourOptionalWrapper(Passenger_Optional__c objPassengerOptional,string tourOptional) {
        
            tourOptionalId = objPassengerOptional.Id;
            
            tourName = objPassengerOptional.Name;
            
            tourInstanceName = objPassengerOptional.Tour_Optional__r.Name;
            
            if(objPassengerOptional.Tour_Optional__r.Name == tourOptional && objPassengerOptional.status__c != 'Included' && objPassengerOptional.status__c != 'Cancelled') {
                passengerOptional = '1';
                salesPrice = objPassengerOptional.Sales_Price__c;
            }
        }
        
        public void initValuesOfTourOptionalWrapper(Passenger_Optional__c objPassengerOptional) {
        
            tourOptionalId = objPassengerOptional.Id;
            
            tourName = objPassengerOptional.Name;
            
            tourInstanceName = objPassengerOptional.Tour_Optional__r.Name;
            
            isExistInOptionalPassenger = 'N';
        }
    }
    
    public class SplitColumns {
    
        public List<tourOptionalWrapper> lstSplitTableColumns {get;set;}
        
        public List<passengerWrapper> lstSplitPsngrColumns {get;set;}
        
        public List<decimal> splitedTotal { get; set; }
        
        public SplitColumns () { } 
    }
}