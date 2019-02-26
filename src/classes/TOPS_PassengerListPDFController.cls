//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_PassengerListPDFController
// Description: Used in get list of passenger and other information the get PDF data for passengers
//
// 27th January 2016   Kirti Agarwal  Original (Task # T-465523)
//
// 17 Feb 2016, Maksud Ali Modified (Story# S-455965) - Please see the story description for more details.
//
public without sharing class TOPS_PassengerListPDFController {

    public Map<String, String> genderMap { get; set;}
    public String brandName { get; private set; }
    public String colourCodeVal{get; set;}
    public String fontSize{get; set;}
    public String languageParam{get; set;}
    public String driverName{get; set;}
    public String travelDirectorName{get; set;}
    public Tour_Instance__c tourRecord{get; set;}
    public String blankPassangerCSS {get; set;}
    public String tourDriverCSS {get; set;}
    public String tourDirectorCSS {get; set;}
    public String tdRole {get; set;}
    public List<Passenger__c> tourDirector{get; set;}
    public List<Passenger__c> tourDriver{get; set;}
    public List<Passenger__c> blankPassanger {get; set;}
    public List<Passenger__c> passengerList {get; set;} 
    //Changes Start,Done by Maksud Ali for Story : S-455965
    public List<StaticImageManager> footerlogoList {get; set;}
    //End changes.
    
    String tourInstance, regionCode;
    
    public static final String DRIVER = 'Driver';
    public static final String TOUR_DIRECTOR = 'Tour Director';

    //constructor
    public TOPS_PassengerListPDFController() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        Id relatedObjectId = (Id)parameters.get('relatedObjectId');
        if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance__c')
            tourInstance = parameters.get('relatedObjectId');
        else if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance_Itinerary__c')
            tourInstance = [SELECT Id, Tour_Instance__c from Tour_Instance_Itinerary__c WHERE Id=: relatedObjectId].Tour_Instance__c;
        fontSize = '14px';
        //used to get passengers list
        getPassengers();
        //used to get color code
        getColourCode();
        //used to get language
        getlanguage();
        genderMap = new Map<String, String>();
        genderMap.put('Male', 'M');
        genderMap.put('Female', 'F');
        genderMap.put('M', 'M');
        genderMap.put('F', 'F');
        genderMap.put(null, '');
    }
    
    /**
     * @description  This method is used to get list of passengers
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */ 
    public void getPassengers(){
        passengerList = new List<Passenger__c>();
        tourDriver = new List<Passenger__c>();
        tourDirector = new List<Passenger__c>();
        travelDirectorName = '';    
        String query = 'SELECT Family_Name__c,Name, First_Name__c, Gender__c, Nationality__c, Passport_Issue_Date__c, Passport_Expiry_Date__c,';
        query += 'Passport_Number__c,Country_of_Issue__c, Date_of_Birth__c,Passenger_Class__c, Id FROM Passenger__c Where Status__c != \'CX\' and Tour_Instance__c =: tourInstance and Passenger_Status__c != \'Deleted\' order by Family_Name__c';
        
        for(Passenger__c pass : Database.query(query)) {
          if(pass.Passenger_Class__c ==  DRIVER) {
            driverName = pass.Name;
            tourDriver = new List<Passenger__c>();
            tourDriver.add(pass);
          }else if(pass.Passenger_Class__c == TOUR_DIRECTOR) {
            if(pass.First_Name__c != null) {
             travelDirectorName = pass.First_Name__c + ' ';
            }
            if(pass.Family_Name__c != null) {
             travelDirectorName += pass.Family_Name__c;
            }
            
            tourDirector = new List<Passenger__c>();
            tourDirector.add(pass);
          }else {
            passengerList.add(pass);
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
     * @description  This method is used to get blank passenger list
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
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
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
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
            fontSize = '10px';
        }else{
           fontSize = '9px';
        }
    }
    
    /**
     * @description  This method is used to get colour code of passengers pdf
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */ 
     //Changes Start,Done by Maksud Ali for Story : S-455965
    public void getColourCode() {
        String productCode = '';
        footerlogoList = new List<StaticImageManager>();

        for(Tour_Instance__c  tour : [SELECT id,Name, Special_Brand__c, Product_Name__c, Operating_Product_Code__c,Travel_Director__c,Instance_Code__c 
                                      FROM Tour_Instance__c 
                                      WHERE id=: tourInstance]) {
          productCode = tour.Operating_Product_Code__c;
          tourRecord = tour;
        }
        if(productCode != '' && productCode.length() >= 2) {
          regionCode = productCode.subString(0,2);
        }
        brandName = '';
        for(Region_Code_Brand_Mapping__mdt mapRec : [SELECT DeveloperName, Brand__c, Colour__c,Logos__c, Td_Role_Name__c
                                                     FROM Region_Code_Brand_Mapping__mdt 
                                                     WHERE DeveloperName =: regionCode]) {
          brandName = mapRec.Brand__c;
          colourCodeVal= mapRec.Colour__c;
          tdRole = mapRec.Td_Role_Name__c;
          if(mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
            List<String> tmpSplitedLogoName = mapRec.Logos__c.split(',');
            for(String logoName : tmpSplitedLogoName) {
                footerlogoList.add(new StaticImageManager(logoName,tourRecord.Special_Brand__c));
            }
          }else {
            footerlogoList.add(new StaticImageManager(mapRec.Logos__c,tourRecord.Special_Brand__c));
          }
        }
        //End changes
    }
    
    /**
     * @description  This method is used to get language of passengers pdf
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */ 
    private void getlanguage() {
      languageParam = '';
      if(regionCode == 'VB' || regionCode == 'VE' ) {
        languageParam = 'fr';
      }
    }
    
    
}