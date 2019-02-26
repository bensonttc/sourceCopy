//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_SuppliersListPDFController
// Description: Used in get list of passenger and other information the get PDF data for passengers
//
// 27th January 2016   Kirti Agarwal  Original (Task # T-465523)
//
// 17 Feb 2016, Maksud Ali Modified (Story# S-455965) - Please see the story description for more details.
// 11 May 2018 Calvin Goodenough Modified to make suppliers list

public without sharing class TOPS_SuppliersListPDFController{

    public Map<String, String> genderMap { get; set;}
    public String brandName { get; private set; }
    public String colourCodeVal{get; set;}
    public String fontSize{get; set;}
    public String languageParam{get; set;}
    public String driverName{get; set;}
    public String travelDirectorName{get; set;}
    public Tour_Instance__c tourRecord{get; set;}
    public String blankSupplierCSS {get; set;}
    public String tdRole {get; set;}
    public List<Tour_Instance_Itinerary__c> blankSupplier {get; set;}
    public List<Tour_Instance_Itinerary__c> supplierList {get; set;} 
    //Changes Start,Done by Maksud Ali for Story : S-455965
    public List<StaticImageManager> footerlogoList {get; set;}
    //End changes.
    
    String tourInstance, regionCode;
    
    public static final String DRIVER = 'Driver';
    public static final String TOUR_DIRECTOR = 'Tour Director';
    public static final String roomType = 'RoomingList';
    public static final String itinType = 'Itinerary';

    //constructor
    public TOPS_SuppliersListPDFController() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        Id relatedObjectId = (Id)parameters.get('relatedObjectId');
        if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance__c')
            tourInstance = parameters.get('relatedObjectId');
        else if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance_Itinerary__c')
            tourInstance = [SELECT Id, Tour_Instance__c from Tour_Instance_Itinerary__c WHERE Id=: relatedObjectId].Tour_Instance__c;
        fontSize = '14px';
        //used to get passengers list
        getSuppliers();
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
    public void getSuppliers(){
        supplierList = new List<Tour_Instance_Itinerary__c>();
        travelDirectorName = '';    
        String query = 'SELECT Tour_Instance__c, Tour_Code_txt__c, Service_Start_Date__c,Depart_Time__c, ' 
                    + 'Duration__c, Day_Number__c, '
                    + 'Component_Type__c,  IsDeleted , Supplier__c , Supplier__r.Name, '
                    + 'Operating_Product_Code__c, '
                    + 'Supply_Purpose__c, Location__c, City__c, Supplier_Address__c, Supplier_Phone_Number__c, supplier__r.Email__c, supplier__r.fax '
                    + 'FROM Tour_Instance_Itinerary__c '
                    + 'WHERE Component_Type__c != :roomType '
                    + 'AND Component_Type__c != :itinType '
                    + 'AND Tour_Instance__c = :tourInstance ' 
                    + 'AND Archive__c = false ' 
                    + 'ORDER BY Day_Number__c, Depart_Time__c';   
                         
        for(Tour_Instance_Itinerary__c supp: Database.query(query)) {
             supplierList.add(supp);
        }
        getBlankSupplierList();
        getCSS();
        getFontSizeBasedOnRecords(Integer.valueOf(supplierList.size()));      
    }
    
     /**
     * @description  This method is used to get blank passenger list
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */ 
    private void getBlankSupplierList() {
       blankSupplier = new List<Tour_Instance_Itinerary__c >();
       if(supplierList.size() < 42) {
          Integer listSize = supplierList.size();
          blankSupplier =  new List<Tour_Instance_Itinerary__c>();
          for(integer i=listSize; i<=42; i++) {
            blankSupplier.add(new Tour_Instance_Itinerary__c (Tour_Code_txt__c='test'));
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
        if(supplierList.size() > 0 && blankSupplier.size() > 0) {
          if(Math.mod(supplierList.size(), 2) == 0) {
            blankSupplierCSS = 'pRowEven,pRowOdd';
          }
          else{ 
            blankSupplierCSS = 'pRowOdd,pRowEven';
          }
        }
        integer totalSize = supplierList.size() + blankSupplier.size();
   }
    
    /**
     * @description  This method is used to get font size of passengers pdf
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */ 
    private void getFontSizeBasedOnRecords(Integer listSize) {
 /**       if(listSize <= 40 && listSize >= 0) {
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
         */ 
         fontSize = '12px';

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