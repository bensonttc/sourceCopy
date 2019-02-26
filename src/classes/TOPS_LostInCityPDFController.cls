//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_LostInCityPDFController 
// Description: Used in get list of passenger and other information the get PDF data for passengers
//
// 29th January 2016   Kirti Agarwal  Original (Task # T-467663)
//
// 14 Feb 2017    Maksud Ali Modified (Story# S-461774) - Please see the story description for more details.
//
// 17 Feb 2016, Maksud Ali Modified (Story# S-455965) - Please see the story description for more details.
//
// 2nd Mar 2016 Abhishek Saxena Modified(T-568313)
// 27 Oct 2017 Neeraj Kumawat Modified (I-299335)
// 1 Nov 2017 Neeraj Kumawat Adding pdf title when tour is non modular #I-299335

public without sharing class TOPS_LostInCityPDFController {
    public String driverName{get; set;}
    public String travelDirectorName{get; set;}
    public Tour_Instance__c tourRecord{get; set;}
    public String cityTitle{get; set;}
    public String citySubTitle{get; set;}
    public String emergency_no{get; set;}
    public String alternative_emergency_no{get; set;}
    public String regionalEmergencyText {get; set;}
    public String emergencyContactInfo {get; set;}
    public String hashTag {get; set;}
    public static Boolean isV2Status {get; set;}
    public static String parametersValue;
    public static String processingData;
    public List<Wrapper> wrapperList{get; set;} 
    public static List<String> modulesFromJson;
    public Map<String,Wrapper> wrapperMap{get; set;} 
    public static Map<Id, Boolean> hotelToStar;
    //Changes Start,Done by Maksud Ali for Story : S-455965
    public List<StaticImageManager> footerlogoList {get; set;}
    //End changes
    
    
    public static String tourInstance, regionCode, tourDirectorPhone;
    public Passenger__c tourDriver;
    public Passenger__c tourDirector;
    
    public static final String DRIVER = 'Driver';
    public static final String TOUR_DIRECTOR = 'Tour Director';
    
    private boolean hasDriver;
    //constructor
    public TOPS_LostInCityPDFController () {
        alternative_emergency_no = '';
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        Id relatedObjectId = (Id)parameters.get('relatedObjectId');
        if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance__c')
            tourInstance = parameters.get('relatedObjectId');
        else if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance_Itinerary__c')
            tourInstance = [SELECT Id, Tour_Instance__c from Tour_Instance_Itinerary__c WHERE Id=: relatedObjectId].Tour_Instance__c;
        isV2Status = false;
        if(parameters.get('Parameters') != null){
            parametersValue = parameters.get('Parameters');
            List < String > columnValues = parametersValue.split(',');
            if (parametersValue != null && parametersValue != '') {
                for (String str: columnValues) {
                    if (str.containsIgnoreCase('V2')) {
                        isV2Status = true;
                    }
                }
            }
            processingData = parameters.get('processingData');
        }
        System.debug('parametersValue'+parametersValue);
        System.debug('isV2Status'+isV2Status);
        hasDriver = false;
        cityTitle = '';
        citySubTitle = '';
        //used to get lost city list
        getAccounts();
        //used to get region code
        getRegionCode();
    }
    public static void sendHotelsList(){
        TOPS_WelcomeEmailProcessor.BookingModule deserializedData;
        
        if(!String.isBlank(processingData)){
            deserializedData = (TOPS_WelcomeEmailProcessor.BookingModule)JSON.deserializeStrict(processingData, TOPS_WelcomeEmailProcessor.BookingModule.class);
        }
        
        //List<Object> modulesFromJson = (List<Object>)deserializedData.get('modules');
        modulesFromJson = new List<String>();
        for(String module : deserializedData.modules){
            modulesFromJson.add(module+'');
        }
        
        System.debug('modulesFromJson'+modulesFromJson);
        //Creating a map of Modules to Passengers
        Map<String, List<Passenger__c>> modToPax = new Map<String, List<Passenger__c>>();
        //System.assert(false,'tourInstance'+tourInstance+'modToPax'+modToPax);
        String queryString  = 'SELECT Id, PAX_Timeline__c, Module_Code__c, ';
        queryString += 'Start_Date__c, End_Date__c ';
        queryString += 'FROM Passenger__c ';
        queryString += 'WHERE Tour_Instance__c = \''+tourInstance+'\' ';
        if(modulesFromJson.size() != 0 && !modulesFromJson[0].containsIgnoreCase('NONMOD'))
            queryString +=  'AND Module_Code__c IN :modulesFromJson';
        System.debug('queryString'+queryString); 
        
        for(Passenger__c pax:   Database.query(queryString)){
            if(modToPax.get(pax.Module_Code__c) == null){
                modToPax.put(pax.Module_Code__c, new List<Passenger__c>());
            }
            modToPax.get(pax.Module_Code__c).add(pax);
        }
        
        
        
        //Creating a map of Modules to TII
        Map<String, List<Tour_Instance_Itinerary__c>> modToTII = new Map<String, List<Tour_Instance_Itinerary__c>>();
        //List of relevant Component_Type__c
        List<String> compType = new List<String>{'Hotel', 'Train', 'Ferry/Cruise'};
            queryString  = 'SELECT ID, Supplier__c, Module_Code__c, ';
        queryString += 'Service_Start_Date__c, Day_Number__c ';
        queryString += 'FROM Tour_Instance_Itinerary__c ';
        queryString += 'WHERE Component_Type__c IN :compType ';
        queryString += 'AND Tour_Instance__c = \''+tourInstance+'\' ';
        if(modulesFromJson.size() != 0 && !modulesFromJson[0].containsIgnoreCase('NONMOD'))
            queryString +=  'AND Module_Code__c IN :modulesFromJson';
        
        System.debug('queryString'+queryString);
        for(Tour_Instance_Itinerary__c tii : Database.query(queryString)){
            if(modToTII.get(tii.Module_Code__c) == null){
                modToTII.put(tii.Module_Code__c, new List<Tour_Instance_Itinerary__c>());
            }
            modToTII.get(tii.Module_Code__c).add(tii);                                                    
        }
        System.debug('modToTII'+modToTII);
        
        
        hotelToStar = new Map<Id, Boolean>(); 
        for(String module : modToTII.keySet()){
            for(Tour_Instance_Itinerary__c tii : modToTII.get(module)){
                for(Passenger__c pax : modToPax.get(module)){
                    if(pax.PAX_Timeline__c != null && !String.isEmpty(pax.PAX_Timeline__c)){
                        String jsonInput = pax.PAX_Timeline__c;
                        Map<String, Object> timeline = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
                        Map<String, Object> days = (Map<String, Object>)timeline.get('days');
                        for(String day : days.keySet()){
                            Map<String, Object> eachDay = (Map<String, Object>)days.get(day);
                            if(Integer.valueOf(day) == tii.Day_Number__c
                               && eachDay.get('PAX_On_Tour') != null && eachDay.get('PAX_On_Tour') == false
                               && pax.Start_Date__c != null && pax.End_Date__c != null 
                               && pax.Start_Date__c <= tii.Service_Start_Date__c  && pax.End_Date__c >= tii.Service_Start_Date__c){
                                   hotelToStar.put(tii.Supplier__c, false);
                               }
                        } 
                    }
                }
                if(hotelToStar.get(tii.Supplier__c) == null){
                    hotelToStar.put(tii.Supplier__c, true);
                }
            }
        }
        
        
        
        
    }
    /**
* @description  This method is used to get list of lost city
* @created By : Kirti Agarwal
* @created Date : 27th jan 2016
* @return       : void
*/ 
    public void getAccounts(){
        wrapperList = new List<Wrapper>();
        wrapperMap=new Map<String, Wrapper>();
        travelDirectorName = '';   
        List<Id> supplyIds = new List<Id>();
        String shippingAdd;
        //Changes Done by Nishant Singh for 00195815 and 00196158, Archive__c filter added and Map changed to List<Tour_Instance_Itinerary__c>
        //Changes Start
        String query = 'SELECT Id, Supplier__c, Module_Name__c, Start_date_of_service__c  FROM Tour_Instance_Itinerary__c Where Tour_Instance__c =: tourInstance and Component_Type__c = \'Hotel\' AND Archive__c != TRUE ';
        //Map<Id, Tour_Instance_Itinerary__c> accountAndArrivalDate = new Map<Id, Tour_Instance_Itinerary__c>();
        Map<Id, List<Tour_Instance_Itinerary__c>> accountToItenaries = new Map<Id, List<Tour_Instance_Itinerary__c>>();
        //Changes End
        
        if(isV2Status){
            System.debug('V2 status');
            sendHotelsList();
            supplyIds.addAll(hotelToStar.keySet());
            // Added Module code condition in query (I-299335)
            if(modulesFromJson.size() != 0 && !modulesFromJson[0].containsIgnoreCase('NONMOD')){
                query +=  ' AND Module_Code__c IN :modulesFromJson';
            }
            query+=' order by Start_date_of_service__c';
            for(Tour_Instance_Itinerary__c itiner : Database.query(query)) {
                if(hotelToStar.get(itiner.Supplier__c) != null){
                    //Changes Done by Nishant Singh for 00195815 
                    //Changes Start
                    List<Tour_Instance_Itinerary__c> tempList = new List<Tour_Instance_Itinerary__c>();
                    if(accountToItenaries.get(itiner.Supplier__c)!=NULL){
                        tempList.addAll(accountToItenaries.get(itiner.Supplier__c));
                        tempList.add(itiner);
                        accountToItenaries.put(itiner.Supplier__c, tempList);
                    }
                    else{
                        tempList.add(itiner);
                        accountToItenaries.put(itiner.Supplier__c, tempList);
                    }
                    //accountAndArrivalDate.put(itiner.Supplier__c, itiner);
                    //Changes End
                }
            }
        }
        else{
            query+=' order by Start_date_of_service__c';
            for(Tour_Instance_Itinerary__c itiner : Database.query(query)) {
                if(itiner.Supplier__c != null){  
                    supplyIds.add(itiner.Supplier__c);
                }
                //Changes Done by Nishant Singh for 00195815 
                //Changes Start
                List<Tour_Instance_Itinerary__c> tempList = new List<Tour_Instance_Itinerary__c>();
                if(accountToItenaries.get(itiner.Supplier__c)!=NULL){
                    tempList.addAll(accountToItenaries.get(itiner.Supplier__c));
                    tempList.add(itiner);
                    accountToItenaries.put(itiner.Supplier__c, tempList);
                }
                else{
                    tempList.add(itiner);
                    accountToItenaries.put(itiner.Supplier__c, tempList);
                }
                //accountAndArrivalDate.put(itiner.Supplier__c, itiner);  
                //Changes End
            }
        }
        
        for(Account acc : [SELECT Id , Name, BillingCity,
                           Phone, External_ID__c, BillingStreet,
                           BillingCountry, BillingPostalCode,
                           BillingState, Reception_Phone__c
                           FROM Account 
                           WHERE Id IN: supplyIds]) {
                               shippingAdd = getBillingAddress(acc);
                               
                               //Changes Done by Nishant Singh for 00195815 
                               //Changes Start
                               if(isV2Status){
                                   if(!hotelToStar.get(acc.Id)){
                                       if(accountToItenaries.containsKey(acc.id)){
                                           for(Tour_Instance_Itinerary__c itr : accountToItenaries.get(acc.id)){
                                               //Neeraj Kumawat (I-299335)
                                               //Added Value in the map based on date of Itinerary
                                               if(itr.Start_Date_of_Service__c!=null){
                                                   wrapperMap.put(String.valueOf(itr.Start_Date_of_Service__c), new Wrapper(acc, shippingAdd, itr,'*'));
                                               }
                                               //wrapperList.add(new Wrapper(acc, shippingAdd, itr,'*'));
                                           }
                                       }
                                       //wrapperList.add(new Wrapper(acc, shippingAdd, accountAndArrivalDate.get(acc.id),'*'));
                                   }
                                   else{
                                       if(accountToItenaries.containsKey(acc.id)){
                                           //Neeraj Kumawat (I-299335)
                                           //Added Value in the map based on date of Itinerary
                                           for(Tour_Instance_Itinerary__c itr : accountToItenaries.get(acc.id)){
                                               if(itr.Start_Date_of_Service__c!=null){
                                                   wrapperMap.put(String.valueOf(itr.Start_Date_of_Service__c),new Wrapper(acc, shippingAdd, itr));
                                               }
                                               //wrapperList.add(new Wrapper(acc, shippingAdd, itr));
                                           }
                                       }
                                       //wrapperList.add(new Wrapper(acc, shippingAdd, accountAndArrivalDate.get(acc.id)));
                                   }
                               }
                               else{
                                   if(accountToItenaries.containsKey(acc.id)){
                                       for(Tour_Instance_Itinerary__c itr : accountToItenaries.get(acc.id)){
                                           //Neeraj Kumawat (I-299335)
                                           //Added Value in the map based on date of Itinerary
                                           if(itr.Start_Date_of_Service__c!=null){
                                               wrapperMap.put(String.valueOf(itr.Start_Date_of_Service__c),  new Wrapper(acc, shippingAdd, itr));
                                           }
                                           // wrapperList.add(new Wrapper(acc, shippingAdd, itr));
                                       }
                                   }
                                   //wrapperList.add(new Wrapper(acc, shippingAdd, accountAndArrivalDate.get(acc.id)));
                               }
                               // Changes End
                           } 
        //Neeraj Kumawat (I-299335)
        //Added Map values to the list
        for(String key: wrapperMap.keySet()){
            wrapperList.add(wrapperMap.get(key));
        }
        wrapperList.sort();
        //Neeraj Kumawat (I-299335)
        //Updated module name on the title of the PDF instead of Tour instance Product name
        if(wrapperList.size()>0 && isV2Status){
            Tour_Instance_Itinerary__c tii= wrapperList[0].itiner;
            //Neeraj Kumawat Adding modular tour condition
            if(modulesFromJson.size() != 0 && !modulesFromJson[0].containsIgnoreCase('NONMOD')){            
                String dateVal;
                if(tii!=null && tii.Module_Name__c!=null){
                    if(tii.Start_date_of_service__c != null) {
                        Datetime temp = Datetime.newInstance(tii.Start_date_of_service__c.year(), tii.Start_date_of_service__c.month(), tii.Start_date_of_service__c.day());  
                        dateVal = temp.format('d MMMM yyyy');
                    }
                    cityTitle = string.format(Label.Lost_in_City_Title, new String[]{tii.Module_Name__c, String.format(dateVal, new String[]{'d MMMM yyyy'})});
                }
            }
        }
    }
    
    /**
* @description  This method is used to get billing address
* @created By : Kirti Agarwal
* @created Date : 1st feb 2016
* @return       : void
*/ 
    public String  getBillingAddress(Account acc) {
        String billingAdd  = '';
        if(acc.BillingStreet != null) {
            billingAdd += acc.BillingStreet.trim();
        } 
        
        if(acc.BillingCity!= null) {
            if(billingAdd != '') {
                billingAdd += ', ';
            }
            billingAdd += acc.BillingCity.trim();
        }   
        
        if(acc.BillingState!= null) {
            if(billingAdd != '') {
                billingAdd += ', ';
            }
            billingAdd += acc.BillingState.trim();
        }   
        
        if(acc.BillingPostalCode!= null) {
            if(billingAdd != '') {
                billingAdd += ', ';
            }
            billingAdd += acc.BillingPostalCode.trim();
        }
        if(acc.BillingCountry!= null) {
            if(billingAdd != '') {
                billingAdd += ', ';
            }
            billingAdd += acc.BillingCountry.trim();
        }   
        return  billingAdd;        
    }
    
    /**
* @description  This method is used to get colour code of passengers pdf
* @created By : Kirti Agarwal
* @created Date : 27th jan 2016
* @return       : void
*/ 
    //Changes Start,Done by Maksud Ali for Story : S-455965 
    public void getRegionCode() {
        String productCode = '';
        footerlogoList = new List<StaticImageManager>();
        String dateVal;
        for(Tour_Instance__c  tour : [SELECT id, Name, Special_Brand__c,Operating_Product_Code__c,Product_Name__c, 
                                      Travel_Director__c,Instance_Code__c,Start_Date__c
                                      FROM Tour_Instance__c 
                                      WHERE id=: tourInstance]) {
                                          productCode = tour.Operating_Product_Code__c;
                                          tourRecord = tour;
                                      }
        
        if(productCode != '' && productCode.length() >= 2) {
            regionCode = productCode.subString(0,2);
        }
        getAllCustomLabelFormat();
        getFooterLogo();
    }
    //End changes
    
    /**
* @description  This method is used to get footer logos
* @created By : Kirti Agarwal
* @created Date : 27th jan 2016
* @return       : void
*/ 
    private void getAllCustomLabelFormat() {
        String dateVal;
        populateDriverAndTourDirector();
        
        if(tourRecord != null) {
            if(tourRecord.Start_Date__c != null) {
                Datetime temp = Datetime.newInstance(tourRecord.Start_Date__c.year(), tourRecord.Start_Date__c.month(), tourRecord.Start_Date__c.day());  
                dateVal = temp.format('d MMMM yyyy');
            }
            //Neeraj Kumawat Adding pdf title when tour is non modular #I-299335
            if(modulesFromJson==null){
                if(tourRecord.Product_Name__c != null) {
                        cityTitle = string.format(Label.Lost_in_City_Title, new String[]{tourRecord.Product_Name__c, String.format(dateVal, new String[]{'d MMMM yyyy'})});
                    }
            }else if(modulesFromJson.size() != 0 && modulesFromJson[0].containsIgnoreCase('NONMOD')){
                    if(tourRecord.Product_Name__c != null) {
                        cityTitle = string.format(Label.Lost_in_City_Title, new String[]{tourRecord.Product_Name__c, String.format(dateVal, new String[]{'d MMMM yyyy'})});
                    }
            }
            /*Changes start, Done by Maksud Ali for Story :S-461774 */
            if (hasDriver)
                citySubTitle = string.format(Label.Lost_in_city_subtitle, new String[]{'','',travelDirectorName + ' and ' + driverName});
            else
                citySubTitle = string.format(Label.Lost_in_city_subtitle, new String[]{'','',travelDirectorName});
            //End changes
            emergency_no = string.format(Label.Lost_in_city_TD_emergency_no.replaceAll('\'', 'replaceSingleQuote'), new String[]{travelDirectorName, tourDirectorPhone});
            
            emergency_no = emergency_no.replace('replaceSingleQuote', '\'' );
        }
    }
    
    /**
* @description  This method is used to get shipping address
* @created By : Kirti Agarwal
* @created Date : 1st feb 2016
* @return       : void
*/ 
    private void populateDriverAndTourDirector() {
        //Added Account__r.known_As__pc new field into query. By Maksud Ali.
        String query = 'SELECT Family_Name__c,Account__c, Account__r.known_As__pc,Account__r.Crew_Contact_number_2__c, Name, First_Name__c, Gender__c, Nationality__c, Passport_Issue_Date__c, Passport_Expiry_Date__c,';
        query += 'Passport_Number__c,Country_of_Issue__c, Date_of_Birth__c,Passenger_Class__c, Id FROM Passenger__c Where Status__c != \'CX\' and Passenger_Status__c != \'Deleted\' and Tour_Instance__c =: tourInstance';
        driverName = '';
        travelDirectorName = '';
        tourDirectorPhone = '';
        for(Passenger__c pass : Database.query(query)) {
            if(pass.Passenger_Class__c ==  DRIVER) {
                tourDriver = pass;
                hasDriver = true;
                if(pass.First_Name__c != null) {
                    driverName = pass.First_Name__c + ' ';
                }
            } //Changes start done by Maksud Ali for case : 00184107
            else if(pass.Passenger_Class__c == TOUR_DIRECTOR) {
                
                if(pass.Account__r.known_As__pc != null) {
                    travelDirectorName = pass.Account__r.known_As__pc + ' ';
                }
                else {
                    travelDirectorName = pass.First_Name__c == null ? '' : pass.First_Name__c + ' ';
                }
                //End changes.
                
                if(pass.Family_Name__c != null) {
                    travelDirectorName += pass.Family_Name__c;
                }
                
                tourDirector = pass;
                if(tourDirector != null && tourDirector.Account__c != null && tourDirector.Account__r.Crew_Contact_number_2__c != null) {
                    tourDirectorPhone = tourDirector.Account__r.Crew_Contact_number_2__c;
                }
            }
        }
    }
    
    /**
* @description  This method is used to get footer logos
* @created By : Kirti Agarwal
* @created Date : 27th jan 2016
* @return       : void
*/ 
    public void getFooterLogo() {
        for(Region_Code_Brand_Mapping__mdt mapRec : [SELECT DeveloperName, HashTag__c ,Brand__c, Colour__c,Logos__c,LICS_Emergency_Contact__c, LICS_Emergency_Text__c
                                                     FROM Region_Code_Brand_Mapping__mdt 
                                                     WHERE DeveloperName =: regionCode]) {
                                                         emergencyContactInfo = mapRec.LICS_Emergency_Contact__c;
                                                         regionalEmergencyText = mapRec.LICS_Emergency_Text__c;
                                                         hashTag = mapRec.Hashtag__c;
                                                         //Changes Start,Done by Maksud Ali for Story : S-455965
                                                         if(mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
                                                             List<String> tmpSplitedLogoName = mapRec.Logos__c.split(',');
                                                             for(String logoName : tmpSplitedLogoName) {
                                                                 footerlogoList.add(new StaticImageManager(logoName,tourRecord.Special_Brand__c));
                                                             }
                                                         }else {
                                                             footerlogoList.add(new StaticImageManager(mapRec.Logos__c,tourRecord.Special_Brand__c));
                                                         }
                                                         //End changes
                                                     }
    }
    
    //
    // (c) 2016 Appirio, Inc.
    //
    // Class Name: Wrapper 
    // Description: Used to wrap account and arrival date info
    //
    // 29th January 2016   Kirti Agarwal  Original (Task # T-467663)
    //  
    class Wrapper implements Comparable {
        public Account accountRec {get;set;}
        public Tour_Instance_Itinerary__c itiner{get;set;}
        public Date arrivalDate{get;set;}
        public String address{get;set;}
        public String isPaxAbsent{get;set;}
        //public String spplyBId{get;set;}
        
        public Wrapper (Account accountP, String addressP, Tour_Instance_Itinerary__c itinerP){
            accountRec = accountP;
            address = addressP;
            itiner = itinerP;
            isPaxAbsent = '';
        }
        
        public Wrapper(Account accountP, String addressP, Tour_Instance_Itinerary__c itinerP, String isPaxAbsentP){
            accountRec = accountP;
            address = addressP;
            itiner = itinerP;
            isPaxAbsent = isPaxAbsentP;
        }
        public Integer compareTo(Object objectToCompareTo)
        {
            Wrapper compareToWrapper = (Wrapper) objectToCompareTo;
            if (itiner.Start_date_of_service__c == compareToWrapper.itiner.Start_date_of_service__c) return 0;
            if (itiner.Start_date_of_service__c > compareToWrapper.itiner.Start_date_of_service__c) return 1;
            return -1;
        }
    }
}