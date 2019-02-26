//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_OptionalSignUpPDFController
// Description: Used in get list of passenger and generate the optional signup pdf
//
// 4th Feb 2016   Kirti Agarwal  Original (Task # T-469481)
// 15 Feb 2017    Maksud Ali Modified (Story# S-461773) - Please see the story description for more details.
// 1st Mar 2017   Abhishek Saxena       Modified(T-568301)
// 2 June 2017    Richard Boyd  I-276189 Fix sort and filters on optionals
// 20 September 2017 Neeraj Kumawat I-293820 Calculating averageCost based on number of tour optional
// 30-Oct 2017 Neeraj Kumawat I-293820 Calculating averageCost based on days between from date and to date
// 15 April 2018 Calvin Goodenough Added filers for discount and average cost for AAT Kings launch

public without sharing class TOPS_OptionalSignUpPDFController {
  public List<Tour_Optional__c> tourOptionalList{get;set;}
  public String tourSeriesName {get;set;}
  public String fontSize{get;set;}
  public String regionCode{get;set;}
  public Tour_Instance__c tourRecord{get;set;}
  public boolean isDayColumn{get;set;}
  public boolean isTimeColumn{get;set;}
  public boolean isAdultPriceColumn{get;set;}
  public boolean isChildPriceColumn{get;set;}
  public boolean isAdultsColumn{get;set;}
  public boolean isKidsColumn{get;set;}
  public Decimal totalAdultPrice{get;set;}
  public Decimal totalChildPrice{get;set;}
  public List<Integer> singleList{get;set;}
  public String theDepartureReference { get; private set; }
  public String tourCurrency {get; set;}
  public String signatureLabel{get;set;}
  public String chargeTd{get;set;}
  public String numberOfKids{get;set;}
  public String totalPaid {get;set;}
  public String adultPrice{get;set;}
  public String childPrice{get;set;}
  public String averageCost {get; set;}
  public String tourBrand {get; private set;}
  public Boolean showRates { get; private set; }
  public Boolean isV2Status {get; private set;}
  public String theAverageLabel {get; set;}
  public String theDiscountLabel {get; set;}
  public String userLocale { get; private set; }  
  public String theOpCompany {get; set;}
  public boolean isNormalFooter{get;set;}
  public String theDisplay {get; set;}
  public String showHand {get; set;}
  public String showCash {get; set;}
  public String onlyAATNZ {get; set;}
  public Integer totalChars {get;set;} 
  public Integer totalLines {get;set;}
  public Boolean showCHF {get; set;}
  public Boolean showGBP {get; set;}
  public String kidsDisplay {get; set;}



  
  String tourInstance, parametersValue, brandName, jsonData, processingData;
  Integer columnVisible;
  Set<String> regionCodeList = new Set<String>{'TE', 'TB', 'IE', 'IB', 'BI', 'TX', 'TY', 'IX', 'IY', 'BX', 'BY'};
  Set<String> allowedRegionCodesToDisplayRates = new Set<String>{'IB', 'IE', 'TE', 'TB'};

  /**
   * @description  This method is used to initailize param
   * @created By : Kirti Agarwal
   * @created Date : 5th Feb 2016
   * @return       : void
   */
  public void init() {
    columnVisible = 0;
    isDayColumn = false;
    isTimeColumn = false;
    isAdultPriceColumn = false;
    isChildPriceColumn = false;
    isAdultsColumn = false;
    isKidsColumn = false;
    isV2Status = false;
    isNormalFooter = true;
    theOpCompany = '';
    theDisplay = '';
    showHand = '';
    showCash='';
    kidsDisplay = 'display: none;';
    onlyAATNZ = 'display: none;';
    singleList = new List < Integer > {
      1
    };
    theAverageLabel = '';
    theDiscountLabel = '';
    totalChars = 0;
    totalLines = 0;
    showCHF = false;
    showGBP = false;
    showRates = false;
  }

  /**
   * @description  This method is used to get column visibilty
   * @created By : Kirti Agarwal
   * @created Date : 5th Feb 2016
   * @return       : void
   */
  public void getColumnVisibility() {
    if (parametersValue != null && parametersValue != '') {
      List < String > columnValues = parametersValue.split(',');

      for (String str: columnValues) {
        //Added by Abhishek Saxena - T-568301
        if (str.containsIgnoreCase('V2')) {
          isV2Status = true;
        }
        if (str.contains('Day')) {
          isDayColumn = true;
          columnVisible++;
        } else if (str.contains('Day')) {
          isDayColumn = true;
          columnVisible++;
        } else if (str.contains('Time')) {
          isTimeColumn = true;
          columnVisible++;
        } else if (str.contains('Adult Price')) {
          isAdultPriceColumn = true;
          columnVisible++;
          columnVisible++;
        } else if (str.contains('Child Price')) {
          isChildPriceColumn = true;
          columnVisible++;
        } else if (str.contains('Adults')) {
          isAdultsColumn = true;
          columnVisible++;
        } else if (str.contains('Kids')) {
          isKidsColumn = true;
          columnVisible++;
          kidsDisplay = '';
        }
      }
    }
  }

  //constructor
  public TOPS_OptionalSignUpPDFController () {
    init();
    Map < String, String > parameters = ApexPages.currentPage().getParameters();
    tourInstance = parameters.get('relatedObjectId');
    tourOptionalList = new List < Tour_Optional__c > ();
    parametersValue = parameters.get('Parameters');
    processingData = parameters.get('processingData');
    getColumnVisibility();
    getRegionCode();
    getTourOptionals();
    getFontSize();
    getAllCustomLabelValues();
  }

  /**
   * @description  This method is used to get tour optional list
   * @created By : Kirti Agarwal
   * @created Date : 5th Feb 2016
   * @return       : void
   */
  public void getFontSize() {
    //Changes start, Done by Maksud Ali for Story : S-461773
    // further changes by Calvin to check for total lines displayed rather than number of optionals for more acurate dynamic sizing
    fontSize = '15px';
    if (totalLines <= 20) {
      fontSize = '15px';
    } else if (totalLines >= 21 && totalLines <= 22) {
      fontSize = '14px';
    } else if (totalLines >= 23 && totalLines <= 26) {
      fontSize = '13px';
    } else if (totalLines >= 27 && totalLines  <= 30) {
      fontSize = '12px';
    } else if (totalLines >= 31) {
      fontSize = '11px';
    }
    //End changes
    //fontSize = '13px';
  }

  /**
   * @description  This method is used to get tour optional list
   * @created By : Kirti Agarwal
   * @created Date : 5th Feb 2016
   * @return       : void
   */
  public void getTourOptionals() {
    totalChildPrice = 0.0;
    totalAdultPrice = 0.0;
    Integer dayFrom,dayTo;
    tourOptionalList = new List < Tour_Optional__c > ();
    Tour_Instance__c tour;
    List<Tour_Optional__c> tourOptionals;
    if(isV2Status && !String.IsBlank(processingData)){
      //Retrieving dates from the JSON data
      Map<String, Object> jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped(processingData);
      System.debug('dayFrom Value='+jsonUntyped.get('dayFrom'));
      System.debug('dayTo Value='+jsonUntyped.get('dayTo'));
       dayFrom = Integer.valueOf(jsonUntyped.get('dayFrom'));
       dayTo = Integer.valueOf(jsonUntyped.get('dayTo'));
      tourOptionals = [SELECT id, Name, Location__c, Short_description__c,
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
      if(String.IsBlank((String)jsonUntyped.get('title'))){
          tourSeriesName = tourOptionals != null && tourOptionals[0].Tour_Instance__r.Product_Name__c != null ? 
                               tourOptionals[0].Tour_Instance__r.Product_Name__c : ' ' ;
      }else{
          tourSeriesName = (String)jsonUntyped.get('title');
      }
     // System.assert(false,tourSeriesName);
    }else{
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
    }
    
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
      if (topt.Name != null) {
          totalLines += math.round(topt.Name.length()/50) + 1;
      }
      if (topt.Short_description__C != null) {
          totalLines += math.round(topt.Short_description__C.length()/50) + 1;
      }
     }
      
    //averageCost = tourCurrency + ' ' + (totalAdultPrice/(tour.start_Date__c.daysBetween(tour.end_Date__c)+1)).round(System.roundingMode.HALF_EVEN);
    
    // Code Commented and changes made by Ravi Jain for Case - 00176378
    // Code Changes start from here
    // 20 September 2017 Neeraj Kumawat I-293820 Calculating averageCost based on number of tour optional
    // 30-Oct 2017 Neeraj Kumawat I-293820 Calculating averageCost based on days between from date and to date
      if(dayTo!=null && dayFrom!=null){
          Integer numberofDays=(dayTo-dayFrom)+1;
          averageCost = tourCurrency + ' ' + (totalAdultPrice/(numberofDays)).setScale(2);
          //averageCost = tourCurrency + ' ' + (totalAdultPrice/(tourOptionals.size())).setScale(2);
        }else if(tour.start_Date__c !=null && tour.end_Date__c !=null){
          averageCost = tourCurrency + ' ' + (totalAdultPrice/(tour.start_Date__c.daysBetween(tour.end_Date__c)+1)).setScale(2);
      }
      // Code Changes end here
  }

  /**
   * @description  This method is used to get region code
   * @created By : Kirti Agarwal
   * @created Date : 5th Feb 2016
   * @return       : void
   */
  public void getRegionCode() {
    String productCode = '';
    tourSeriesName = '';
    theDepartureReference = '';
    for (Tour_Instance__c tour: [SELECT id, Name, Product_Name__c,
                                        Operating_Product_Code__c,
                                        Operating_Company_Code__c,
                                        Travel_Director__c,
                                        Start_Date__c,
                                        Instance_Code__c, Tour_Series__c,
                                        EUR_CHF__c, EUR_GBP__c,
                                        Tour_Series__r.Name, Currency__c,
                                        Count_CHF_on_EUR_Trip__c,
                                        Count_EUR_on_GBP_Trip__c,
                                        Count_GBP_on_EUR_Trip__c
                                FROM Tour_Instance__c
                                WHERE id = : tourInstance
                              ]) {
      productCode = tour.Operating_Product_Code__c;
      theDepartureReference = tour.Instance_Code__c;
      tourRecord = tour;
      tourCurrency = tour.Currency__c;
      theOpCompany = tour.Operating_Company_Code__c;
      if (theOpCompany != null && theOpCompany == 'AANZLO') {
         isNormalFooter = false;
         theDisplay = 'display: none;';
         showHand= 'display: none;';
         showCash= 'display: none;';
         onlyAATNZ = '';
      }  
      if (tour.Tour_Series__c != null) {
        tourSeriesName = tour.Tour_Series__r.Name;
        if (tour.Count_CHF_on_EUR_Trip__c> 0){
           showCHF = true;
        }
        if (tour.Count_EUR_on_GBP_Trip__c > 0 || tour.Count_GBP_on_EUR_Trip__c > 0 ){
           showGBP = true;
        }

      }
    }

    if (productCode != '' && productCode.length() >= 2) {
      regionCode = productCode.subString(0, 2);
    }

 //   showRates = false;
    if(
      String.isNotBlank(regionCode) &&
      allowedRegionCodesToDisplayRates.contains(regionCode.toUpperCase()) &&
      parametersValue.contains('Kids')
    ) {
    //  showRates = true;
      theDiscountLabel = system.label.X25_Discount;
    }

    for (Region_Code_Brand_Mapping__mdt mapRec: [SELECT DeveloperName,
                                                        Brand__c, Tour_Type_Brand__c
                                                 FROM Region_Code_Brand_Mapping__mdt
                                                 WHERE DeveloperName = : regionCode
                                              ]) {
      brandName = mapRec.Brand__c;
      tourBrand = mapRec.Tour_Type_Brand__c;
    }
  }

  /**
   * @description  This method is used to get all custom label values
   * @created By : Kirti Agarwal
   * @created Date : 8th Feb 2016
   * @return       : void
   */
  public void getAllCustomLabelValues() {
    String director = 'Travel Director';
    chargeTd = '';
    Totalpaid = '';
    ID myAccount;
    String showAverageLabel = '';
    numberOfKids  = Label.No_of_Kids_17_and_Under;
// Commented out as Insight now has Travel Directors as well
//    if (brandName == 'Insight') {
//      director = 'Tour Director';
//    }

    if(brandName == 'AAT Kings') {
      numberOfKids = Label.No_of_Kids_17_and_Under.replace('(17 and Under)', '(15 and Under)');
      theDiscountLabel = '';
      showCash= 'display: none;';
    }

    signatureLabel = String.format(Label.TD_Signature, new List < String > {
      director
    });

    if(regionCodeList.contains(regionCode)) {
      chargeTd = String.format(Label.Charges_TD, new List < String > {
        director + '\'s'
      });
    }
    totalPaid = String.format(Label.Total_Euros_paid_by_credit_card,new List < String > {tourCurrency});
    adultPrice = String.format(Label.Adult_Price_in_0, new List < String > {tourCurrency});
    childPrice = String.format(Label.Child_Price_in_0, new List < String > {tourCurrency});
    
    myAccount =  [select Allocated_TD__c from tour_instance__C WHERE ID= :tourInstance LIMIT 1].Allocated_TD__c;
    if (myAccount != null) { 
       showAverageLabel = [select ID, OptionalSignupAverageCostLabel__c from account where ID = :myaccount LIMIT 1].OptionalSignupAverageCostLabel__c;
    }
 //   theAverageLabel = myAccount;
    if (showAverageLabel == 'Display Average Cost') {
       theAverageLabel = system.label.purchased_optional_experiences + ' ' + averageCost;
    }  
    userLocale = UserInfo.getLocale();  
    
  }
}