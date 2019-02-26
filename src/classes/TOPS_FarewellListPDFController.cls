//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_FarewellListPDFController
// Description: Used to get list of passenger for farewell pdf
//
// 29th January 2016   Manisha Gupta  Original (Task # T-467683)
// 18th November 2016  Ravi Jain      Original (Story # S-443725)
//
// 17 Feb 2016, Maksud Ali Modified (Story# S-455965) - Please see the story description for more details.
// 12 Jul 2018, Calvin Goodenough added new variable and logic to use a module name where applicable instead of mother trip name
//
public without sharing class TOPS_FarewellListPDFController {

    public String[] fields {get; set;}
    public String colourCodeVal{get; set;}
    public String fontSize{get; set;}
    public String languageParam{get; set;}
    public String driverName{get; set;}
    public String travelDirectorName{get; set;}
    public String travelEmail{get; set;}
    public Tour_Instance__c tourRecord{get; set;}
    public String blankPassangerCSS {get; set;}
    public String tourDriverCSS {get; set;}
    public String tourDirectorCSS {get; set;}
    public String hashTag {get; set;}
    public Passenger__c tourDirector{get; set;}
    public Passenger__c tourDriver{get; set;}
    public List<Passenger__c> blankPassanger {get; set;}
    public List<Passenger__c> passengerList {get; set;} 
    //Changes Start,Done by Maksud Ali for Story : S-455965
    public List<StaticImageManager> footerlogoList {get; set;}
    //End changes
    public String yourTripStartDate { get; private set; }
    public String yourTravelDirector { get; private set; }
    public String yourTrip { get; private set; }
    public String theTripName {get; set; } // new for module name
    public static String processingData;
    String tourInstance, regionCode;
    public static List<String> modulesFromJson;
    
    public static final String DRIVER = 'Driver';
    public static final String TOUR_DIRECTOR = 'Tour Director';
    public static final integer MAX_PESSANGER = 58;
    private string pdMap;
    
    //constructor
    public TOPS_FarewellListPDFController() {
        driverName = '';
        tourDirector = null;
        theTripName = '';
        yourTripStartDate = Label.Your_Trip_Start_Date;
        yourTravelDirector = Label.Your_Travel_Director;
        yourTrip = Label.Your_Trip;

        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        tourInstance = parameters.get('relatedObjectId');
        processingData = parameters.get('processingData');
        pdMap = ApexPages.currentPage().getParameters().get('processingData');
        system.debug('TI ' + tourInstance + ' PD ' + processingData + ' PARAM ' + parameters);
        system.debug('pdMap::' + ApexPages.currentPage().getParameters().get('processingData') );
        fields = new String[]{};
        fontSize = '14px';
        //used to get passengers list
        getPassengers();
        //used to get color code
        getColourCode();
        //used to get language
        getlanguage();
    }
    
    /**
     * @description  This method is used to get list of passengers
     * @created By : Manisha Gupta
     * @created Date : 29th jan 2015
     * @return       : void
     */ 
    public void getPassengers(){
    
        //Get JSON Data for Modules Or NonMOD
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
        passengerList = new List<Passenger__c>();
        //tourDriver = new List<Passenger__c>();
        //tourDirector = new List<Passenger__c>();
        travelDirectorName = '';    
        //Divyar: I-225190, Modified query to use tour director's email address as passenger email address
        /*String query = 'Select Name,Passenger_Class__c, Account__r.Crew_Email_guest__c, Email__c, First_Name__c, Family_Name__c, Address_Region__c, Address_Country__c '+
                        'FROM Passenger__c ' + 
                        'Where Status__c != \'CX\' and Tour_Instance__c =: tourInstance and (Email_Share_Opt_In__c = true OR Passenger_Class__c =: TOUR_DIRECTOR OR Passenger_Class__c =: DRIVER ) order by Family_Name__c';//*/
       
         // Code commented and changes done by Ravi Jain for story S-443725
        // Code changes start here
        //Added Account__r.known_As__pc new field into query. By Maksud Ali.
        String query = 'Select Name,Passenger_Class__c, Account__r.known_As__pc,Account__r.Crew_Email_guest__c, Email__c, First_Name__c, Family_Name__c, Address_Region__c, Address_Country__c, Preferred_Name__c,'+
                        // RJ Changes
                        ' Module_Start_Date__c, Module_End_Date__c, Start_Date__c, End_Date__c '+
                        // Calvin Changes next line
                        ', Module_Code__c, Module_Name__c '+ // added so can be used on document header
                        'FROM Passenger__c ' + 
                        'Where  V2_Status__c != \'CX\' and  Passenger_Status__c != \'Deleted\' and Tour_Instance__c =: tourInstance and (Email_Share_Opt_In__c = true OR Passenger_Class__c =: TOUR_DIRECTOR OR Passenger_Class__c =: DRIVER ) ' ;
                        if(modulesFromJson.size() != 0 && !modulesFromJson[0].containsIgnoreCase('NONMOD')){
                           // RJ Changes
                           //query +=  ' AND Module_Code__c IN :modulesFromJson ';
                           //query +=  ' AND End_Date__c >: Module_Start_Date__c AND Start_Date__c <: Module_Start_Date__c ';
                           //query +=  ' AND Farewell_Date_Validation_End_Date__c = True AND Farewell_Date_Validation_Start_Date__c = True ';
                        }
                        query += ' order by Family_Name__c';
       // Code changes end here     
       
       // Changes By Ravi
       
       String tiiData = [SELECT id, TII_Data__c from Tour_Instance_Itinerary__c where (Tour_Instance__c = :tourInstance AND Component_Type__c = 'Itinerary') Limit 1].TII_Data__c;
      
       system.debug('test tiiData Value'+tiiData);
       JSON2Apex touSummaryData = (JSON2Apex)JSON.deserialize(tiiData, JSON2Apex.Class);
        System.debug('Query Value'+' '+query);
        Map<String,List<Passenger__c>> mapPsngr = new Map<String,List<Passenger__c>>(); 
        for(Passenger__c pass : Database.query(query)) {
          if(pass.Passenger_Class__c ==  DRIVER) {
            tourDriver = pass;            
          }else if(pass.Passenger_Class__c == TOUR_DIRECTOR) {
            //Changes start done by Maksud Ali for case : 00184107
            if(pass.Account__r.known_As__pc != null) {
             travelDirectorName = pass.Account__r.known_As__pc + ' ';
            }
            else {
             travelDirectorName = pass.First_Name__c + ' ';
            }
            //End changes.
            if(pass.Family_Name__c != null) {
             travelDirectorName += pass.Family_Name__c;
            }
            if(pass.Passenger_Class__c == TOUR_DIRECTOR)
            {
                travelEmail=pass.Account__r.Crew_Email_guest__c;
            }
            else
            {
                travelEmail = pass.Email__c;
            }
            
            
            //tourDirector = new List<Passenger__c>();
            //tourDirector.add(pass);
          }else {
              
         
        // Changes Ravi   
        if(modulesFromJson.size() != 0 && !modulesFromJson[0].containsIgnoreCase('NONMOD')){
            for(Modules modules : touSummaryData.tourSummary.modules) { 
            String[] startDateComponent = modules.startDate.split('-');
            Date startDate = Date.newInstance(Integer.valueOf(startDateComponent[0]), Integer.valueOf(startDateComponent[1]), 
                                       Integer.valueOf(startDateComponent[2]));
                                       
            String[] endDateComponent = modules.endDate.split('-');
            Date endDate = Date.newInstance(Integer.valueOf(endDateComponent[0]), Integer.valueOf(endDateComponent[1]), 
                                       Integer.valueOf(endDateComponent[2]));
            system.debug('FAREWELL: pass mod code-' + pass.module_code__C + ' JSON mod:' + modulesFromJson[0] + ' ' + String.valueOf(modulesFromJson[0] == pass.module_code__C));
            // next line added to check if the modeule code of the request matches the passenger, if so module name is used for document name
            if (theTripName == '' && modulesFromJson.size() != 0 && modulesFromJson[0] == pass.module_code__C) { theTripName = pass.module_name__C;}
            //system.debug('Start Date is ' + startDate);
            //System.debug('DAtes Value'+' '+pass.Name+' - '+pass.Module_Start_Date__c +' > ' + startDate +' '+ pass.Module_End_Date__c +' < '+  endDate);
            if(startDate < pass.Module_End_Date__c && endDate > pass.Module_Start_Date__c)
            {
            //if((pass.Module_Start_Date__c >= startDate  && pass.Module_Start_Date__c <  endDate) ||(pass.Module_End_Date__c > startDate && pass.Module_End_Date__c < endDate))
                 //{
                    System.debug('Module From Json'+' '+modulesFromJson.size());
                    if(modulesFromJson.size() > 0)
                    {
                    if(modules.mcode == modulesFromJson[0])
                    {
                    System.debug('DAtes Value'+' '+modules.mcode+' -  '+pass.Name+' - '+pass.Module_Start_Date__c +' > ' + startDate +' '+ pass.Module_End_Date__c +' < '+  endDate);
                    passengerList.add(pass);
                    }
                    }
                 }
            }
         }
         else
         {
                 passengerList.add(pass);
         }
          }
        }
        getBlankPassengerList();
        getCSS();
        getFontSizeBasedOnRecords(Integer.valueOf(passengerList.size()));      
    }
    
     /**
     * @description  This method is used to get blank passenger list
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */ 
    private void getBlankPassengerList() {
       blankPassanger = new List<Passenger__c >();
       if(passengerList.size() < 42) {
          Integer listSize = passengerList.size();
          blankPassanger =  new List<Passenger__c>();
          for(integer i=listSize; i<=42; i++) {
            blankPassanger.add(new Passenger__c (Name='test'));
          }
        }
    }
    
     /**
     * @description  This method is used to get CSS `   
     * @created By : Manisha Gupta
     * @created Date : 29th jan 2015
     * @return       : void
     */ 
    private void getCSS() {
        if(passengerList.size() > 0 && blankPassanger.size() > 0) {
          if(Math.mod(passengerList.size(), 2) == 0) {
            blankPassangerCSS = 'pRowEven,pRowOdd';
          }
          else{ 
            blankPassangerCSS = 'pRowOdd,pRowEven';
          }
        }
        integer totalSize = passengerList.size() + blankPassanger.size();
        if(Math.mod(totalSize , 2) == 0) {
          tourDriverCSS = 'pRowEven';
          tourDirectorCSS = 'pRowOdd';
        }else {
          tourDriverCSS = 'pRowOdd';
          tourDirectorCSS = 'pRowEven';
        }
    }
    
    /**
     * @description  This method is used to get font size of passengers pdf
     * @created By : Manisha Gupta
     * @created Date : 29th jan 2015
     * @return       : void
     */ 
    private void getFontSizeBasedOnRecords(Integer listSize) {
        if(listSize <= 40 && listSize >= 0) {
            fontSize = '14px';
        }else if(listSize <= 45 && listSize > 40) {
            fontSize = '13px';
        }else if(listSize <= 50 && listSize > 45) {
            fontSize = '12px';
        }else if(listSize <= 55 && listSize > 50) {
            fontSize = '11px';
        }else if(listSize <= 60 && listSize > 55) {
            fontSize = '11px';
        }else{
           fontSize = '9px';
        }
    }
    
    /**
     * @description  This method is used to get colour code of passengers pdf
     * @created By : Manisha Gupta
     * @created Date : 29th jan 2015
     * @return       : void
     */
     
     //Changes Start,Done by Maksud Ali for Story : S-455965 
    public void getColourCode() {
        String productCode = '';
        footerlogoList = new List<StaticImageManager>();
        
        for(Tour_Instance__c  tour : [SELECT id,Name, Special_Brand__c,Operating_Product_Code__c,Travel_Director__c,Instance_Code__c, Product_Name__c,
                                        Start_Date__c  
                                      FROM Tour_Instance__c 
                                      WHERE id=: tourInstance]) {
          productCode = tour.Operating_Product_Code__c;
          tourRecord = tour;
          // next line added to check if it is non modular then document takes mother tour name
          if (theTripName == '') {theTripName = tourRecord.Product_Name__c;}
        }
        if(productCode != '' && productCode.length() >= 2) {
          regionCode = productCode.subString(0,2);
        }
        for(Region_Code_Brand_Mapping__mdt mapRec : [SELECT DeveloperName, Brand__c, Colour__c,Logos__c, HashTag__c,
                                                     Tour_Type_Brand__c, TD_Role_Name__c FROM Region_Code_Brand_Mapping__mdt 
                                                     WHERE DeveloperName = :regionCode]) {
          yourTripStartDate = yourTripStartDate.replace('{0}', mapRec.Tour_Type_Brand__c);
          yourTravelDirector = yourTravelDirector.replace('{0}', mapRec.TD_Role_Name__c);
          yourTrip = yourTrip.replace('{0}', mapRec.Tour_Type_Brand__c);

          colourCodeVal= mapRec.Colour__c;
          hashTag = mapRec.HashTag__c;
          if(mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
            List<String> tmpSplitedLogoName = mapRec.Logos__c.split(',');
            for(String logoName : tmpSplitedLogoName) {
                footerlogoList.add(new StaticImageManager(logoName,tourRecord.Special_Brand__c));
            }
          }else {
            footerlogoList.add(new StaticImageManager(mapRec.Logos__c,tourRecord.Special_Brand__c));
          }
        }
        //End Code here.
    }
    
    /**
     * @description  This method is used to get language of passengers pdf
     * @created By : Manisha Gupta
     * @created Date : 29th jan 2015
     * @return       : void
     */ 
    private void getlanguage() {
      languageParam = 'en-US';
      if(regionCode == 'VB' || regionCode == 'VE' ) {
        languageParam = 'fr';
      }
    }
    
// Changes By Ravi   
public class TourSummary {
        public TourType tourType;
        public List<Modules> modules;
}

public class Modules {
    public Boolean welcomeEmailSent;
    public String supplierPurpose;
    public String startLocation;
    public String startDay;
    public String startDate;
    public String name;
    public String mcode;
    public Boolean farewellEmailSent;
    public String endLocation;
    public String endDay;
    public String endDate;
    public List<Integer> days;
}

public class TourType {
    public String isModular;
    public String hasSplit;
    public String hasAccommodationClass;
}

public class JSON2Apex {
    public TourSummary tourSummary;
}
    
}