//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_PersonalMenusPDFController
// Description: Used in get list of passenger and generate the personal menu pdf
//
// 3rd Feb 2016   Kirti Agarwal  Original (Task # T-467738)
// 21st November 2016   Ravi Jain  Original (Story # S-428350)
// Mar 10, 2017        Abhishek Saxena     T-568302
// 20th June 2017    Maksud Ali Origianl (Story # S-487869)

public without sharing class TOPS_PersonalMenusPDFController {

  String tourOptional , tourInstance, regionCode;
  Tour_Instance__c tourRecord;

  public String colourCodeVal {get; set;}
  public String footerlogo{get; set;}
  public List<String>footerlogoList {get; set;}
  public Map<Integer, List<Passenger_Optional__c>> passengerOptionalmap{get;set;}
  public List<Integer> listOfKeys{get; set;}
  public String supplierName{get; set;}
  public String fontSize{get; set;}
  public String hashTag{get; set;}
  public static Boolean isV2Status;
  public static Integer dayNumber;

  //constructor
  public TOPS_PersonalMenusPDFController() {
    Map < String, String > parameters = ApexPages.currentPage().getParameters();
    tourOptional = parameters.get('relatedObjectId');
    supplierName = '';
    footerlogo = '';
    String query = 'SELECT Id,Tour_Instance__c, Supplier__r.Name, day__c FROM Tour_Optional__c Where id =\'' + tourOptional + '\' AND Duplicate__c = false';
    for (Tour_Optional__c tii: database.query(query)) {
      tourInstance = tii.Tour_Instance__c;
      supplierName = tii.Supplier__r.Name;
      dayNumber = Integer.valueOf(tii.day__c);
    }
    // Mar 10, 2017        Abhishek Saxena     T-568302
    isV2Status = false;
    if(parameters.get('Parameters') != null){
        String parametersValue = parameters.get('Parameters');
        List < String > columnValues = parametersValue.split(',');
        if (parametersValue != null && parametersValue != '') {
            for (String str: columnValues) {
                if (str.containsIgnoreCase('V2')) {
                    isV2Status = true;
                }
            }
        }
    }    
    getPassenger();
    getColourCode();
    getFontSize();
  }

  /**
   * @description  This method is used to get font size
   * @created By : Kirti Agarwal
   * @created Date : 3rd Feb 2016
   * @return       : void
   */
  public void getFontSize() {
    fontSize = '18px';
    if (supplierName != '' && supplierName !=null && supplierName.length() > 20 && supplierName.length() <= 30) {
      fontSize = '15px';
    }
    else if (supplierName != '' && supplierName !=null && supplierName.length() > 30 && supplierName.length() <= 40) {
      fontSize = '12px';
    }
    
     // Code changes done by Ravi Jain for case 00194182
    // Start - Ravi Jain - 00194182 - May 31,2017 - If Supplier Name length is greater than 40 then font size should be 11px
     else if (supplierName != '' && supplierName !=null && supplierName.length() > 40) {
      fontSize = '11px';
    }
    // Code changes end here
  }

  /**
   * @description  This method is used to get passenger list
   * @created By : Kirti Agarwal
   * @created Date : 3rd Feb 2016
   * @return       : void
   */
  public void getPassenger() {
    passengerOptionalmap = new Map < Integer, List < Passenger_Optional__c >> ();
    listOfKeys = new List < Integer > ();
    Integer firstLoop = 1;

    /*for (Passenger_Optional__c passOpt: [SELECT Id, Passenger__c,
                                                Selected_Starter__c, Passenger__r.Preferred_Name__c,
                                                Passenger__r.Family_Name__c, Passenger__r.First_Name__c,
                                                Selected_Dessert__c, Selected_Soup__c,
                                                Selected_Main__c,
                                                Passenger__r.Dietary_Requirements__c
                                                FROM Passenger_Optional__c
                                                WHERE Tour_Optional__c = : tourOptional
                                                AND Status__c != 'Cancelled'
                                              ])*/
     // Code commented and canges done by Ravi Jain for story S-428350
    // Code changes start here
     
     for (Passenger_Optional__c passOpt: [SELECT Id, Passenger__c,
                                                Selected_Starter__c, Passenger__r.Preferred_Name__c,
                                                Passenger__r.Family_Name__c, Passenger__r.First_Name__c,
                                                Selected_Dessert__c, Selected_Soup__c,
                                                Selected_Main__c,
                                                Passenger__r.Dietary_Requirements__c,
                                                Passenger__r.PAX_Timeline__c,
                                                Menu_Notes__c //Menu_Notes__c added by Maksud Ali for the story : S-487869
                                                FROM Passenger_Optional__c
                                                WHERE Tour_Optional__c = : tourOptional
                                                AND Status__c != 'Cancelled'
                                                Order By Passenger__r.Family_Name__c, Passenger__r.Preferred_Name__c,
                                                Passenger__r.First_Name__c
                                              ]) 
    // Code changes end here
    
    {
      // Mar 10, 2017        Abhishek Saxena     T-568302    
      if(isV2Status && !TOPS_MealSelectionsProcessor.checkPaxPresent(passOpt.Passenger__r.PAX_Timeline__c, dayNumber)){
          continue;
      }
      if (!passengerOptionalmap.containsKey(firstLoop)) {
        passengerOptionalmap.put(firstLoop, new List < Passenger_Optional__c > {
          passOpt
        });
      } else {
        passengerOptionalmap.get(firstLoop).add(passOpt);
        firstLoop++;
      }
    }
    listOfKeys.addAll(passengerOptionalmap.keyset());

  }


  /**
   * @description  This method is used to get colour code of personal menu pdf
   * @created By : Kirti Agarwal
   * @created Date : 3rd Feb 2016
   * @return       : void
   */
  public void getColourCode() {
    String productCode = '';
    footerlogoList = new List < String > ();

    for (Tour_Instance__c tour: [SELECT id, Name, Product_Name__c,
                                        Operating_Product_Code__c,
                                        Travel_Director__c,
                                        Instance_Code__c
                                 FROM Tour_Instance__c
                                 WHERE id = : tourInstance
                                ]) {
      productCode = tour.Operating_Product_Code__c;
      tourRecord = tour;
    }

    if (productCode != '' && productCode.length() >= 2) {
      regionCode = productCode.subString(0, 2);
    }

    for (Region_Code_Brand_Mapping__mdt mapRec: [SELECT DeveloperName, Brand__c,
                                                        Colour__c, Logos__c, Hashtag__c
                                                 FROM Region_Code_Brand_Mapping__mdt
                                                 WHERE DeveloperName = : regionCode
                                                ]) {
      colourCodeVal = mapRec.Colour__c;
      hashTag = mapRec.Hashtag__c;
      if (mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
        footerlogoList = mapRec.Logos__c.split(',');
      } else {
        footerlogoList.add(mapRec.Logos__c);
      }
    }

  }

}