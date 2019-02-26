//
// 
//
// Class Name: TOPS_GuestChecklistPDFController
// Description: Used in get list of passenger and other information the get PDF data for passengers
//
// Based on Class TOPS_PassengerListPDFController(c) 2016 Appirio, Inc.
// 1 September 2016 Modified by Calvin Goodenough
// 31st Jan 2017    Ravi Jain              Modified (Story# S-461046) - Please see the story description for more details.
//
public without sharing class TOPS_GuestChecklistPDFController {

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
    public List<String> footerlogoList {get; set;}
    //Changes Start,Done by Calvin Goodenough for new IV & GET logos 2018 based on work by Maksud Ali for Story : S-455965
    public List<StaticImageManager> theFooterLogoList { get; private set; }
    private String theTourInstanceId { get; set; }
     public String theInstanceCode { get; private set; }
      private String theRegionCode { get; set; }

    //End changes
    
    String tourInstance, regionCode;
    
    public static final String DRIVER = 'Driver';
    public static final String TOUR_DIRECTOR = 'Tour Director';

    //constructor
    public TOPS_GuestChecklistPDFController() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        Id relatedObjectId = (Id)parameters.get('relatedObjectId');
        if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance__c')
            tourInstance = parameters.get('relatedObjectId');
        else if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance_Itinerary__c')
            tourInstance = [SELECT Id, Tour_Instance__c from Tour_Instance_Itinerary__c WHERE Id=: relatedObjectId].Tour_Instance__c;
        fontSize = '13pt';
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
     * Modified Calvin Goodenough 1 Sep 2016
     */ 
    public void getPassengers(){
        passengerList = new List<Passenger__c>();
        tourDriver = new List<Passenger__c>();
        tourDirector = new List<Passenger__c>();
        travelDirectorName = '';    
        /*String query = 'SELECT Family_Name__c,Name, First_Name__c, Middle_Name__c, Preferred_Name__c, Tour_Product_Code__c, ';
        query += ' Salutation__c, Bag_Number__c, TD_Notes__c, Selling_company_code__c, Booking_Number__c, Passenger_Class__c, Id FROM Passenger__c Where Status__c != \'CX\' and Tour_Instance__c =: tourInstance and Passenger_Status__c != \'Deleted\' and Passenger_Class__c = \'Passenger\' order by Family_Name__c, First_name__C';*/
        
        // Code commented and changes done by Ravi Jain for Story S-461046
       // Code changes start here
         String query = 'SELECT Family_Name__c,Name, First_Name__c, Middle_Name__c, Preferred_Name__c, Tour_Product_Code__c, Start_Date__c, ';
         query += ' Salutation__c, Bag_Number__c, TD_Notes__c, Selling_company_code__c, Booking_Number__c, Passenger_Class__c, Id FROM Passenger__c Where Status__c != \'CX\' and Tour_Instance__c =: tourInstance and Passenger_Status__c != \'Deleted\' order by Family_Name__c, First_name__C';
        // Code changes end here
        
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
          }else if(pass.Passenger_Class__c == 'Passenger') {
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
       if(passengerList.size() < 40) {
          Integer listSize = passengerList.size();
          blankPassanger =  new List<Passenger__c>();
          for(integer i=listSize; i<=40; i++) {
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
            fontSize = '10pt';
        }else if(listSize <= 45 && listSize > 40) {
            fontSize = '11pt';
        }else if(listSize <= 50 && listSize > 45) {
            fontSize = '10pt';
        }else if(listSize <= 55 && listSize > 50) {
            fontSize = '9pt';
        }else if(listSize <= 60 && listSize > 55) {
            fontSize = '8.5pt';
        }else{
           fontSize = '8pt';
        }
    }
    
    /**
     * @description  This method is used to get colour code of passengers pdf
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */ 
    public void getColourCode() {
        String productCode = '';
        footerlogoList = new List<String>();
        //change for 2018 logos
        theFooterLogoList = new List<StaticImageManager>();
  //      String theOperatingProductCode;
        String specialBrand = '';
        for(Tour_Instance__c  theRecord : [SELECT Instance_Code__c, Special_Brand__c,Operating_Product_Code__c,Brand__c, product_name__C FROM Tour_Instance__c WHERE Id = :tourInstance]) {
           productCode = theRecord.Operating_Product_Code__c;
           theInstanceCode = theRecord.Instance_Code__c;
           specialBrand = theRecord.Special_Brand__c;
           tourRecord = theRecord;
           // Determining the region code.
           if(String.isNotBlank(productCode) && productCode.length() >= 2) {
              regionCode = productCode.subString(0, 2);
           }
        }
        // Extracting configuration information.
        for(Region_Code_Brand_Mapping__mdt theRecord : [SELECT DeveloperName, Brand__c, Colour__c, Logos__c,Td_Role_Name__c FROM Region_Code_Brand_Mapping__mdt 
                                                    WHERE DeveloperName = :regionCode ]) {
           colourCodeVal= theRecord.Colour__c;
           tdRole = theRecord .Td_Role_Name__c;
           brandName = theRecord.Brand__c;
           if(String.isNotBlank(theRecord.Logos__c) && theRecord.Logos__c.contains(',')) {
              List<String> tmpSplitedLogoName = theRecord.Logos__c.split(',');
              for(String logoName : tmpSplitedLogoName) {
                theFooterLogoList.add(new StaticImageManager(logoName,specialBrand));
              }
           }
           else {
              theFooterLogoList.add(new StaticImageManager(theRecord.Logos__c,specialBrand));
           }
        }
    }     
        // end changes  
        
 //       for(Tour_Instance__c  tour : [SELECT id,Name, Product_Name__c, Operating_Product_Code__c,Travel_Director__c,Instance_Code__c 
  //                                    FROM Tour_Instance__c 
   //                                   WHERE id=: tourInstance]) {
    //      productCode = tour.Operating_Product_Code__c;
     //     tourRecord = tour;
      //  }
    //    if(productCode != '' && productCode.length() >= 2) {
     //     regionCode = productCode.subString(0,2);
      //  }

     //   for(Region_Code_Brand_Mapping__mdt mapRec : [SELECT DeveloperName, Brand__c, Colour__c,Logos__c, Td_Role_Name__c
      //                                               FROM Region_Code_Brand_Mapping__mdt 
       //                                              WHERE DeveloperName =: regionCode]) {
      //    brandName = mapRec.Brand__c;

     //     if(mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
     //       footerlogoList = mapRec.Logos__c.split(',');
    //      }else {
    //        footerlogoList.add(mapRec.Logos__c);
     //     }
      //  }

  //  }
    
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