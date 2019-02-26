//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_OptionalSignUpContikiPDFController
// Description: Used in get Print Optional-SignUp-Contiki and other information the get PDF data
//
// 2nd Feburary 2016   Anuj Khanna  Original (Task # T-469466)
//
public without sharing class TOPS_OptionalSignUpContikiPDFController {

    public String colourCodeVal{get; set;}
    public String fontSize{get; set;}
    public String languageParam{get; set;}


    public Tour_Instance__c tourRecord{get; set;}
    public String parameters{get; set;}
    public String footerlogo {get; set;}
    public String headerLogo {get; set;}

    public boolean isChecked {get; set;}

    public List<Tour_Optional__c> blankOptionalList {get; set;}
    public List<Tour_Optional__c> tourOptionalList {get; set;}
    public List<Tour_Optional__c> footOptionalList {get; set;}
    public List<String> footerlogoList {get; set;}

    String tourInstance, regionCode;
    
    public Boolean isV2Status {get; private set;}
    String parametersValue, jsonData, processingData;
    
    public String totalPaid {get;set;}
  public String adultPrice{get;set;}
  public String childPrice{get;set;}
  public String averageCost {get; set;}
   public Decimal totalAdultPrice{get;set;}
  public Decimal totalChildPrice{get;set;}
  public String theAverageLabel {get; set;}

    //constructor
    public TOPS_OptionalSignUpContikiPDFController() {
      parameters = '';
      isChecked = false;
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        tourInstance = parameters.get('relatedObjectId');
        fontSize = '10px';
        footerlogo = 'Contiki';
        parametersValue = parameters.get('Parameters');
        processingData = parameters.get('processingData');
        if(parametersValue.containsIgnoreCase('V2'))
            isV2Status = true;
        //used to get passengers list
        getTourOptionals();
        //used to get color code
        getColourCode();
        //used to get language
        getlanguage();
    }

    /**
     * @description  This method is used to get list of passengers
    * @created By : Anuj Khanna
     * @created Date : 03rd Feb 2015
     * @return       : void
     */
    public void getTourOptionals(){
      totalChildPrice = 0.0;
    totalAdultPrice = 0.0;
     Integer dayFrom,dayTo;
       tourOptionalList = new List < Tour_Optional__c > ();
    Tour_Instance__c tour;
    List<Tour_Optional__c> tourOptionals;
            if(isV2Status && !String.IsBlank(processingData)){
          //Retrieving dates from the JSON data
          Map<String, Object> jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped(processingData);
          System.debug(jsonUntyped.get('dayFrom'));
          System.debug(jsonUntyped.get('dayTo'));
          dayFrom = Integer.valueOf(jsonUntyped.get('dayFrom'));
          dayTo = Integer.valueOf(jsonUntyped.get('dayTo'));
          tourOptionalList = [SELECT id, Name, Location__c, Short_description__c,
                            Tour_Optional_Date__c,  Time__c,  Adult_Price__c,
                            Child_Price__c, Tour_Instance__r.Start_Date__c,
                            Tour_Instance__r.End_Date__c, Tour_Instance__r.Product_Name__c
                            FROM Tour_Optional__c
                            WHERE Tour_Instance__c = : Id.valueOf(tourInstance)
                            AND Day__c >= :dayFrom
                            AND Day__c <= :dayTo
                            AND Duplicate__c = false
                            AND Included_in_Tour__c = False 
                            AND Use_Optional__c = True
                            ORDER By Tour_Optional_Date__c,Time_Order__c];
         // System.assert(false,tourSeriesName);
        }
        else{
                 tourOptionals = [SELECT id, Name, Location__c, Short_description__c,
                        Tour_Optional_Date__c,  Time__c,  Adult_Price__c,
                        Child_Price__c, Tour_Instance__r.Start_Date__c,
                        Tour_Instance__r.End_Date__c
                        FROM Tour_Optional__c
                        WHERE Tour_Instance__c = :tourInstance
                        AND Duplicate__c = false
                        AND Included_in_Tour__c = False 
                        AND Use_Optional__c = True 
                        ORDER By Tour_Optional_Date__c,Time_Order__c];
            for (Tour_Optional__c topt : tourOptionals) {
                  if (tour == null)
                  {
                      tour = new Tour_Instance__c();
                      tour.Start_Date__c = topt.Tour_Instance__r.Start_Date__c;
                      tour.End_Date__c = topt.Tour_Instance__r.End_Date__c;
                  }
                  tourOptionalList.add(topt);
                  if (topt.Adult_Price__c != null) {
                    totalAdultPrice += topt.Adult_Price__c;
            
                  }
                  if (topt.Child_Price__c != null) {
                    totalChildPrice += topt.Child_Price__c;
                  }                           
                if(dayTo!=null && dayFrom!=null){
                  Integer numberofDays=(dayTo-dayFrom)+1;
                  averageCost = '' + (totalAdultPrice/(numberofDays)).setScale(2);
                }else if(tour.start_Date__c !=null && tour.end_Date__c !=null){
                           averageCost = '' + (totalAdultPrice/(tour.start_Date__c.daysBetween(tour.end_Date__c)+1)).setScale(2);
                  
                  }          
                } }
                getBlankOptionalList();

        getFontSizeBasedOnRecords(Integer.valueOf(tourOptionalList.size()));
    }

     /**
     * @description  This method is used to get blank passenger list
     * @created By : Anuj Khanna
     * @created Date : 03rd Feb 2015
     * @return       : void
     */
    private void getblankOptionalList() {
       footOptionalList = new List<Tour_Optional__c >();
       String footerText = Label.Contiki_Mantra;
       List<String> params = new list<String>();
       params.add(' &#9745 ');
       params.add(' &#10132 ');
        ID myAccount;
    String showAverageLabel = '';
     myAccount =  [select Allocated_TD__c from tour_instance__C WHERE ID= :tourInstance LIMIT 1].Allocated_TD__c;
    if (myAccount != null) { 
       showAverageLabel = [select ID, OptionalSignupAverageCostLabel__c from account where ID = :myaccount LIMIT 1].OptionalSignupAverageCostLabel__c;
    }
    if (showAverageLabel == 'Display Average Cost') {
       theAverageLabel = 'Cost Per Day' ;
       }

       String labelVal = String.format(footerText, params);
      footOptionalList.add(new Tour_Optional__c (Name=labelVal));
      blankOptionalList =  new List<Tour_Optional__c>();
      blankOptionalList.add(new Tour_Optional__c (Name='Total For All Optionals'));
      blankOptionalList.add(new Tour_Optional__c (Name=theAverageLabel));



    }

    /**
     * @description  This method is used to get font size of passengers pdf
     * @created By : Anuj Khanna
     * @created Date : 03rd Feb 2015
     * @return       : void
     */
    private void getFontSizeBasedOnRecords(Integer listSize) {
        if(listSize <= 15 && listSize >= 0) {
            fontSize = '11px';
        }else if(listSize <= 20 && listSize > 15) {
            fontSize = '11px';
        }else if(listSize <= 25 && listSize > 20) {
            fontSize = '10px';
        }else if(listSize <= 30 && listSize > 25) {
            fontSize = '9px';
        }else if(listSize <= 35 && listSize > 30) {
            fontSize = '8px';
        }else{
           fontSize = '7px';
        }
    }

    /**
     * @description  This method is used to get colour code of passengers pdf
     * @created By : Anuj Khanna
     * @created Date : 03rd Feb 2015
     * @return       : void
     */
    public void getColourCode() {
        String productCode = '';
        footerlogoList = new List<String>();

        for(Tour_Instance__c  tour : [SELECT id,Name, Product_Name__c, Operating_Product_Code__c,Travel_Director__c,Instance_Code__c
                                      FROM Tour_Instance__c
                                      WHERE id=: tourInstance]) {
          productCode = tour.Operating_Product_Code__c;
          tourRecord = tour;
        }
        if(productCode != '' && productCode.length() >= 2) {
          regionCode = productCode.subString(0,2);
        }
        for(Region_Code_Brand_Mapping__mdt mapRec : [SELECT DeveloperName, Brand__c, Colour__c,Logos__c, hashtag__c
                                                     FROM Region_Code_Brand_Mapping__mdt
                                                     WHERE Brand__c =: footerlogo]) {
          colourCodeVal= mapRec.Colour__c;
          /*if(mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
            footerlogoList = mapRec.Logos__c.split(',');
          }else {
            footerlogoList.add(mapRec.Logos__c);
          }*/
          String hashVal = mapRec.hashtag__c;
          Integer indexVal = hashVal.indexOf('#');
          String finalValue = hashVal.substring(indexVal);
          headerLogo= finalValue.toUpperCase();

          break;
        }
           }

    /**
     * @description  This method is used to get language of passengers pdf
     * @created By : Anuj Khanna
     * @created Date : 03rd Feb 2015
     * @return       : void
     */
    private void getlanguage() {
      languageParam = '';
      if(regionCode == 'VB' || regionCode == 'VE' ) {
        languageParam = 'fr';
      }
    }


}