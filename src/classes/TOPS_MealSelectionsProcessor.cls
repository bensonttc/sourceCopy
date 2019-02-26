/*
* Class Name        : TOPS_MealSelectionsProcessor
* Purpose           : T-467679
* Created Date  : 02/12/2016
* Created By        : Nitish Bansal
* Date Modified       Modified by         Description
* Mar 10, 2017        Abhishek Saxena     T-568302
*/
//20th June 2017    Maksud Ali Origianl (Story # S-487869)
//
//10th July 2017    Aditya Tiwari Case#00189145
// 10th Aug 2018    Jai Gupta       Modified (Story S-568616) - Send email to cc email addresses

public without sharing class TOPS_MealSelectionsProcessor implements TOPS_EmailProcessorInterface{

  public static Tour_Optional__c tourOptionalInstance;
  public static String tourInstanceId;
  public static String brandName;
  public static String toEmail;
  public static String fromEmail;
  public static String ccEmail;
  public static String regionCode;
  public static String tdId;
  public static boolean preview;
  public static final String RESTAURANT_NAME = '[Restaurant name]';
  public static final String TOUR_CODE = '[TourCode]';
  public static final String TD_FULL_NAME = '[TDfullName]';
  public static final String TD_SHORT_TITLE = '[TDshortTitle]';
  public static final String TD_BUSINESS_CONTACT_NUM = '[TDBusinessContactNum]';
  public static final String TD_BUSINESS_EMAIL = '[TDBusinessEmail]';
  public static final String BOOKED_TIME = '[BookedTime]';
  public static final String BOOKED_DATE = '[BookedDate]';
  public static final String GUEST_NAME = '[GuestName]';
  public static final String GUEST_PREFERENCE = '[Guest preference]';
  public static final String GUEST_DIET = '[guestDiet]';
  public static final String GUEST_MEAL_CHOICES = '[Guest meal choices]';
  public static final String STARTERS = '[Starters]';
  public static final String SOUP = '[Soups]';
  public static final String DESSERTS = '[Desserts]';
  public static final String MAIN_COURSES = '[Main courses]';
  public static final String MAIN_DETAIL_STRING = '[Summary meals guest]';
  public static final string KIDS_MENU_COUNT = '[Kids Count]';//Added by Aditya Tiwari for Case#00189145
  public static Boolean isV2Status;
  /**
   * @description  Used to generate emails.
   *
   * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
   * @return       TOPS_EmailWrapper
   */
    public TOPS_EmailWrapper createEmailWrapper(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    String defaultBody = TOPS_MealSelectionsProcessor.mergeFields(request, configRecord);
    
    //Mar 10, 2017        Abhishek Saxena     T-568302
    //isV2Status = false;
    //if(request.Parameters__c.containsIgnoreCase('V2')){
      //  isV2Status = true;
    //}
    
    PageReference emailPage = new PageReference('/apex/TOPS_Email' + '?data=' + EncodingUtil.urlEncode(defaultBody.unescapeHtml4(), 'UTF-8') + '&Brand='+brandName);
    String emailContent = Test.isRunningTest() ? 'Test Email Content' : emailPage.getContent().toString();
    String emailBody = EncodingUtil.urlDecode(emailContent, 'UTF-8');
    System.debug('emailBody ' + emailBody);

    fromEmail = '';
    if(String.isNotBlank(tourInstanceId)) {
      for(Tour_Instance__c theRecord : [SELECT Allocated_TD__c, Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c, Operating_Product_Code__c FROM Tour_Instance__c
                                        WHERE Allocated_TD__c != null AND Id = :tourInstanceId]) {
        fromEmail = theRecord.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c;
        regionCode = theRecord.Operating_Product_Code__c.subString(0, 2);
        tdId = theRecord.Allocated_TD__c;
      }
    }

    if(request.Preview__c) {
      toEmail = fromEmail;
    }
  // Start - Jai S-568616 - Parsing cc emails and sending email to these addresses as well - Aug 09,2018
      if(String.isNotBlank(request.Additional_Emails__c)) {
        Map<String,Object> additionalEmails = (Map<String, Object>)JSON.deserializeUntyped(request.Additional_Emails__c);
        if(additionalEmails.containsKey('cc')) {
          if(String.isNotBlank(ccEmail)) {
            ccEmail += ',';
          } else {
            ccEmail = '' ;
          }
          ccEmail += (String)additionalEmails.get('cc');
        }
      }
      // End S-568616
    TOPS_EmailWrapper theEmailWrapper = new TOPS_EmailWrapper(
      toEmail,
      '',
      'Meal Selections Email',
      emailBody,
      null
    );
    theEmailWrapper.replyTo = fromEmail;
    theEmailWrapper.regionCode = regionCode;
    theEmailWrapper.tdId = tdId;
    theEmailWrapper.cc = ccEmail;
    theEmailWrapper.brand = brandName;
    theEmailWrapper.emailSubject = tourOptionalInstance.Supplier_Email_Subject__c;
    return theEmailWrapper;
  }



  /**
   * @description  Used to get Fields
   * @param        void
   * @return       void
   */
  private static List < String > getFields() {

    List < String > fields = new List < String > {
      RESTAURANT_NAME,
      TOUR_CODE,
      TD_FULL_NAME,
      TD_SHORT_TITLE,
      TD_BUSINESS_CONTACT_NUM,
      TD_BUSINESS_EMAIL,
      BOOKED_TIME,
      BOOKED_DATE,
      GUEST_NAME,
      GUEST_PREFERENCE,
      GUEST_DIET,
      GUEST_MEAL_CHOICES,
      STARTERS,
      SOUP,
      DESSERTS,
      MAIN_COURSES,
      MAIN_DETAIL_STRING,
      KIDS_MENU_COUNT //Modified by Aditya Tiwari for Case#00189145
    };

    return fields;
  }


  /**
   * @description  Used to process merge fields.
   *
   * @param        void
   * @return       void
   */
  public static String mergeFields(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    Map < String, String > fieldMapping = getFieldMapping(request);
    List<Passenger_Optional__c> passengerOptionalList = getPasserngerOptionalList(request);
    system.debug('-------passengerOptionalList------'+passengerOptionalList);
    fieldMapping.put(STARTERS, getStartersDetail(passengerOptionalList));
    fieldMapping.put(DESSERTS, getdessertsDetail(passengerOptionalList));
    fieldMapping.put(SOUP, getsoupsDetail(passengerOptionalList));
    fieldMapping.put(MAIN_COURSES, getmainsDetail(passengerOptionalList));
    fieldMapping.put(MAIN_DETAIL_STRING, getGuestDetail(passengerOptionalList));
    //Modified by Aditya Tiwari for Case#00189145 start
    fieldMapping.put(KIDS_MENU_COUNT, String.valueOf(getKidsMenuCount(passengerOptionalList)));
    //Modified by Aditya Tiwari for Case#00189145 End

   // fieldMapping.put(summaryOfDietaryNeedsField, summaryOfDietaryNeeds);

    String defaultBody = '';
    if (configRecord.Default_Body__c != null) {
      defaultBody = configRecord.Default_Body__c;
      for (String field: fieldMapping.keyset()) {
        if(field.contains(MAIN_DETAIL_STRING)){
            if(fieldMapping.get(field) != null && fieldMapping.get(field) != ''){
                defaultBody = defaultBody.replace(field, System.Label.Summary_Guest_Meals + fieldMapping.get(field));
            } else {
                defaultBody = defaultBody.replace(field, '');
            }
        }
        else if (fieldMapping.get(field) != null) {
          defaultBody = defaultBody.replace(field, fieldMapping.get(field));
        } else {
          defaultBody = defaultBody.replace(field, '');
        }
      }
      return defaultBody;
    }

    return null;
  }

  /**
   * @description  Used to get field mapping
   * @param        void
   * @return       void
   */
  private static Map < String, String > getFieldMapping(Email_Print_Request__c request) {
    Map < String, String > fieldMapping = new Map < String, String > ();
    List < String > fields = getFields();
    for (String field: fields) {
      fieldMapping.put(field, '');
    }

    brandName = '';
    for(Tour_Optional__c tourOptional : [Select Id, Supplier__c, Tour_Instance__r.Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c, Tour_Instance__c,
                                          Tour_Instance__r.Allocated_TD__c, Time__c, Tour_Optional_Date__c, Supplier__r.PersonEmail,
                                          Tour_Instance__r.Allocated_TD__r.Known_As__pc, Tour_Instance__r.Allocated_TD__r.Crew_Contact_Number_1__c,
                                          Tour_Instance__r.Allocated_TD__r.PersonEmail, Tour_Instance__r.Allocated_TD__r.Name, Optional__c,
                                          Supplier_Menu__r.Dessert_Text_1__c, Supplier_Menu__r.Dessert_Text_2__c, Supplier_Menu__r.Dessert_Text_3__c,
                                          Supplier_Menu__r.Dessert_Text_4__c, Supplier_Menu__r.Dessert_Text_5__c, Supplier_Menu__r.Starter_Text_1__c,
                                          Supplier_Menu__r.Starter_Text_2__c, Supplier_Menu__r.Starter_Text_3__c, Supplier_Menu__r.Starter_Text_4__c,
                                          Supplier_Menu__r.Starter_Text_5__c, Supplier_Menu__r.Soup_Text_1__c, Supplier_Menu__r.Soup_Text_2__c,
                                          Supplier_Menu__r.Main_Text_1__c, Supplier_Menu__r.Main_Text_2__c, Supplier_Menu__r.Main_Text_3__c,
                                          Supplier_Menu__r.Main_Text_4__c, Supplier_Menu__r.Main_Text_5__c, Tour_Instance__r.Brand__r.Name,
                                          Tour_Instance__r.Brand_Name__c, Supplier__r.Name, Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c,
                        Supplier__r.Email__c, Supplier_Email_Subject__c
                                          From Tour_Optional__c
                                          WHERE Id = : request.Related_Object_Id__c
                                          AND Duplicate__c = false]){//Single record
    tourInstanceId = tourOptional.Tour_Instance__c;
        if(tourOptional.Tour_Instance__r.Brand_Name__c != null){
            brandName = tourOptional.Tour_Instance__r.Brand_Name__c;
        }
        tourOptionalInstance = tourOptional;
      if(tourOptional.Supplier__c != null && tourOptional.Supplier__r.Name != null){
        fieldMapping.put(RESTAURANT_NAME, tourOptional.Supplier__r.Name);
      }
      if(tourOptional.Tour_Instance__c != null && tourOptional.Tour_Instance__r.Operating_Product_Code__c != null){
        fieldMapping.put(TOUR_CODE, tourOptional.Tour_Instance__r.Operating_Product_Code__c + '/' + tourOptional.Tour_Instance__r.Departure_Code__c);
      }
      if(tourOptional.Tour_Instance__c != null && tourOptional.Tour_Instance__r.Allocated_TD__c != null && tourOptional.Tour_Instance__r.Allocated_TD__r.Name != null){
        fieldMapping.put(TD_FULL_NAME, tourOptional.Tour_Instance__r.Allocated_TD__r.Name);
      }
        if(tourOptional.Tour_Instance__c != null && tourOptional.Tour_Instance__r.Allocated_TD__c != null && tourOptional.Tour_Instance__r.Allocated_TD__r.Known_As__pc != null){
        fieldMapping.put(TD_SHORT_TITLE, tourOptional.Tour_Instance__r.Allocated_TD__r.Known_As__pc);
      }
      if(tourOptional.Tour_Instance__c != null && tourOptional.Tour_Instance__r.Allocated_TD__c != null && tourOptional.Tour_Instance__r.Allocated_TD__r.Crew_Contact_Number_1__c != null){
        fieldMapping.put(TD_BUSINESS_CONTACT_NUM, tourOptional.Tour_Instance__r.Allocated_TD__r.Crew_Contact_Number_1__c);
      }
        if(tourOptional.Tour_Instance__c != null && tourOptional.Tour_Instance__r.Allocated_TD__c != null && tourOptional.Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c != null){
        fieldMapping.put(TD_BUSINESS_EMAIL, tourOptional.Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c);
        fromEmail = tourOptional.Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c;
        ccEmail = tourOptional.Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c;
        if(!request.Preview__c){
          toEmail = tourOptional.Supplier__r.Email__c;
        }
      }
        if(tourOptional.Time__c != null){
        fieldMapping.put(BOOKED_TIME, tourOptional.Time__c);
      }
        if(tourOptional.Tour_Optional_Date__c != null){
        fieldMapping.put(BOOKED_DATE, tourOptional.Tour_Optional_Date__c.format());
      }
    }

    return fieldMapping;
  }

  /**
   * @description  Used to get Passernger Optional List
   * @param        void
   * @return       void
   */
  private static List<Passenger_Optional__c> getPasserngerOptionalList(Email_Print_Request__c request) {
    List < Passenger_Optional__c > passengerOptoinalList = new List < Passenger_Optional__c > ();
    /*for(Passenger_Optional__c passOpt : [Select Id, Passenger__c, Passenger__r.Dietary_Requirements__c,
                                                    Passenger__r.Passenger_Class__c, Passenger__r.First_Name__c,
                                                    Passenger__r.Account__c, Passenger__r.Account__r.Email__c, Selected_Soup__c,
                                                    Passenger__r.Account__r.PersonEmail, Selected_Starter__c, Selected_Main__c,
                                                    Selected_Dessert__c, Kids_Menu_Selected__c, Passenger__r.Family_Name__c,
                              Passenger__r.Account__r.Crew_Email_for_Supplier_Office_use__c
                                                    From Passenger_Optional__c
                                                    Where Tour_Optional__c = :request.Related_Object_Id__c
                            AND Status__c != 'Cancelled'])*/
      
    // Code Commented and changes done by Ravi Jain for Case - 00176375
    // Code changes starts here
    
      for(Passenger_Optional__c passOpt : [Select Id, Passenger__c, Passenger__r.Dietary_Requirements__c,
                                                    Passenger__r.Passenger_Class__c, Passenger__r.First_Name__c,
                                                    Passenger__r.Account__c, Passenger__r.Account__r.Email__c, Selected_Soup__c,
                                                    Passenger__r.Account__r.PersonEmail, Selected_Starter__c, Selected_Main__c,
                                                    Selected_Dessert__c, Kids_Menu_Selected__c, Passenger__r.Family_Name__c,
                                                    Passenger__r.Account__r.Crew_Email_for_Supplier_Office_use__c,
                                                    Passenger__r.PAX_Timeline__c,
                                                    Menu_Notes__c //This field Menu_Notes__c added by maksud ali in the query for story : S-487869
                                                    From Passenger_Optional__c
                                                    Where Tour_Optional__c = :request.Related_Object_Id__c
                            AND Status__c != 'Cancelled' and Passenger__r.Status__c != 'CX'])
      //Code changes end here
      
      {
        System.debug('Passenger Optional Query:'+passOpt);
        //Mar 10, 2017        Abhishek Saxena     T-568302
        //if(isV2Status && !checkPaxPresent(passOpt.Passenger__r.PAX_Timeline__c, request.Related_Object_Id__c)){
            //continue;
        //}
        passengerOptoinalList.add(passOpt);
        if(request.Preview__c){
            if(passOpt.Passenger__r.Passenger_Class__c == 'Tour Director'){
                toEmail = passOpt.Passenger__r.Account__r.Crew_Email_for_Supplier_Office_use__c;
            }
        }
    }
    return passengerOptoinalList;

  }

  //================================================================      
  // Name         : checkPaxPresent
  // Description  : Checks if the Passenger is present on the day of optional
  // Created Date : 10th Mar 2017
  // Created By   : Abhishek Saxena (Appirio)
  // Task         : T-568302
  //==================================================================
  public static Boolean checkPaxPresent(String paxTimeline, Integer tourOptionalday){
      if(paxTimeline != null && !String.isEmpty(paxTimeline)){
        Map<String, Object> timeline = (Map<String, Object>) JSON.deserializeUntyped(paxTimeline);
        Map<String, Object> days = (Map<String, Object>)timeline.get('days');
        for(String day : days.keySet()){
            Map<String, Object> eachDay = (Map<String, Object>)days.get(day);
            if(Integer.valueOf(day) == tourOptionalday
              && eachDay.get('PAX_On_Tour') != null
              && eachDay.get('PAX_On_Tour') == true){
                  return true;
          }
        }
      }
      return false;
  }    
    
  /**
   * @description  Used to get Starters Deatils
   * @param        void
   * @return       void
   */
  private static String getStartersDetail(List < Passenger_Optional__c > passengerOptoinalList) {
    String starterDetails = '';
    Integer count1, count2, count3, count4, count5;
    count1 = count2 = count3 = count4 = count5 = 0;
    Map < String, Integer > starterDetailsMap = new Map < String, Integer > ();
    for (Passenger_Optional__c passOptional: passengerOptoinalList) {
        if(passOptional.Selected_Starter__c != null && tourOptionalInstance.Optional__c != null){
            if(tourOptionalInstance.Supplier_Menu__r.Starter_Text_1__c != null && tourOptionalInstance.Supplier_Menu__r.Starter_Text_1__c == passOptional.Selected_Starter__c) {
                if (!starterDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.Starter_Text_1__c)) {
                  count1++;
              starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_1__c, count1);
                } else {
                  count1 = starterDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.Starter_Text_1__c);
                  count1++;
                  starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_1__c, count1);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.Starter_Text_2__c != null && tourOptionalInstance.Supplier_Menu__r.Starter_Text_2__c == passOptional.Selected_Starter__c) {
                if (!starterDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.Starter_Text_2__c)) {
              count2++;
                  starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_2__c, count2);
                } else {
                  count2 = starterDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.Starter_Text_2__c);
                  count2++;
                  starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_2__c, count2);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.Starter_Text_3__c != null && tourOptionalInstance.Supplier_Menu__r.Starter_Text_3__c == passOptional.Selected_Starter__c) {
                if (!starterDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.Starter_Text_3__c)) {
                  count3++;
              starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_3__c, count3);
                } else {
                  count3 = starterDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.Starter_Text_3__c);
                  count3++;
                  starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_3__c, count3);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.Starter_Text_4__c != null && tourOptionalInstance.Supplier_Menu__r.Starter_Text_4__c == passOptional.Selected_Starter__c) {
                if (!starterDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.Starter_Text_4__c)) {
                  count4++;
              starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_4__c, count4);
                } else {
                  count4 = starterDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.Starter_Text_4__c);
                  count4++;
                  starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_4__c, count4);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.Starter_Text_5__c != null && tourOptionalInstance.Supplier_Menu__r.Starter_Text_5__c == passOptional.Selected_Starter__c) {
                if (!starterDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.Starter_Text_5__c)) {
                  count5++;
              starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_5__c, count5);
                } else {
                  count5 = starterDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.Starter_Text_5__c);
                  count5++;
                  starterDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.Starter_Text_5__c, count5);
                }
            }
        }
    }

    for (String starter: starterDetailsMap.keyset()) {
        if(starterDetailsMap.get(starter) > 0) {
            starterDetails += starter + ' - ' + starterDetailsMap.get(starter) + '<br>';
        }
    }

    return starterDetails;
  }

  /**
   * @description  Used to get desserts Deatils
   * @param        void
   * @return       void
   */
  private static String getdessertsDetail(List < Passenger_Optional__c > passengerOptoinalList) {
    String dessertDetails = '';
    Integer count1, count2, count3, count4, count5;
    count1 = count2 = count3 = count4 = count5 = 0;
    Map < String, Integer > dessertDetailsMap = new Map < String, Integer > ();
    for (Passenger_Optional__c passOptional: passengerOptoinalList) {
        if(passOptional.Selected_dessert__c != null && tourOptionalInstance.Optional__c != null){
            if(tourOptionalInstance.Supplier_Menu__r.dessert_Text_1__c != null && tourOptionalInstance.Supplier_Menu__r.dessert_Text_1__c == passOptional.Selected_dessert__c) {
                if (!dessertDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.dessert_Text_1__c)) {
                  count1++;
              dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_1__c, count1);
                } else {
                  count1 = dessertDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.dessert_Text_1__c);
                  count1++;
                  dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_1__c, count1);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.dessert_Text_2__c != null && tourOptionalInstance.Supplier_Menu__r.dessert_Text_2__c == passOptional.Selected_dessert__c) {
                if (!dessertDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.dessert_Text_2__c)) {
                  count2++;
              dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_2__c, count2);
                } else {
                  count2 = dessertDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.dessert_Text_2__c);
                  count2++;
                  dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_2__c, count2);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.dessert_Text_3__c != null && tourOptionalInstance.Supplier_Menu__r.dessert_Text_3__c == passOptional.Selected_dessert__c) {
                if (!dessertDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.dessert_Text_3__c)) {
                  count3++;
              dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_3__c, count3);
                } else {
                  count3 = dessertDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.dessert_Text_3__c);
                  count3++;
                  dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_3__c, count3);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.dessert_Text_4__c != null && tourOptionalInstance.Supplier_Menu__r.dessert_Text_4__c == passOptional.Selected_dessert__c) {
                if (!dessertDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.dessert_Text_4__c)) {
                  count4++;
              dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_4__c, count4);
                } else {
                  count4 = dessertDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.dessert_Text_4__c);
                  count4++;
                  dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_4__c, count4);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.dessert_Text_5__c != null && tourOptionalInstance.Supplier_Menu__r.dessert_Text_5__c == passOptional.Selected_dessert__c) {
                if (!dessertDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.dessert_Text_5__c)) {
                  count5++;
              dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_5__c, count5);
                } else {
                  count5 = dessertDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.dessert_Text_5__c);
                  count5++;
                  dessertDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.dessert_Text_5__c, count5);
                }
            }
        }
    }

    for (String dessert: dessertDetailsMap.keyset()) {
        if(dessertDetailsMap.get(dessert) > 0){
            dessertDetails += dessert + ' - ' + dessertDetailsMap.get(dessert) + '<br>';
        }
    }

    return dessertDetails;
  }

  /**
   * @description  Used to get mains Deatils
   * @param        void
   * @return       void
   */
  private static String getmainsDetail(List < Passenger_Optional__c > passengerOptoinalList) {
    String mainDetails = '';
    Integer count1, count2, count3, count4, count5;
    count1 = count2 = count3 = count4 = count5 = 0;
    Map < String, Integer > mainCourseDetailsMap = new Map < String, Integer > ();
    for (Passenger_Optional__c passOptional: passengerOptoinalList) {
        if(passOptional.Selected_main__c != null && tourOptionalInstance.Optional__c != null){
            if(tourOptionalInstance.Supplier_Menu__r.main_Text_1__c != null && tourOptionalInstance.Supplier_Menu__r.main_Text_1__c == passOptional.Selected_main__c) {
                if (!mainCourseDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.main_Text_1__c)) {
              count1++;
                  mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_1__c, count1);
                } else {
                  count1 = mainCourseDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.main_Text_1__c);
                  count1++;
                  mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_1__c, count1);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.main_Text_2__c != null && tourOptionalInstance.Supplier_Menu__r.main_Text_2__c == passOptional.Selected_main__c) {
                if (!mainCourseDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.main_Text_2__c)) {
              count2++;
                  mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_2__c, count2);
                } else {
                  count2 = mainCourseDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.main_Text_2__c);
                  count2++;
                  mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_2__c, count2);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.main_Text_3__c != null && tourOptionalInstance.Supplier_Menu__r.main_Text_3__c == passOptional.Selected_main__c) {
                if (!mainCourseDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.main_Text_3__c)) {
                  count3++;
              mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_3__c, count3);
                } else {
                  count3 = mainCourseDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.main_Text_3__c);
                  count3++;
                  mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_3__c, count3);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.main_Text_4__c != null && tourOptionalInstance.Supplier_Menu__r.main_Text_4__c == passOptional.Selected_main__c) {
                if (!mainCourseDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.main_Text_4__c)) {
                  count4++;
              mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_4__c, count4);
                } else {
                  count4 = mainCourseDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.main_Text_4__c);
                  count4++;
                  mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_4__c, count4);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.main_Text_5__c != null && tourOptionalInstance.Supplier_Menu__r.main_Text_5__c == passOptional.Selected_main__c) {
                if (!mainCourseDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.main_Text_5__c)) {
                  count5++;
              mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_5__c, count5);
                } else {
                  count5 = mainCourseDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.main_Text_5__c);
                  count5++;
                  mainCourseDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.main_Text_5__c, count5);
                }
            }
        }
    }

    for (String main: mainCourseDetailsMap.keyset()) {
        if(mainCourseDetailsMap.get(main) > 0){
            mainDetails += main + ' - ' + mainCourseDetailsMap.get(main) + '<br>';
        }
    }

    return mainDetails;
  }

  /**
   * @description  Used to get soups Deatils
   * @param        void
   * @return       void
   */
  private static String getsoupsDetail(List < Passenger_Optional__c > passengerOptoinalList) {
    String soupDetails = '';
    Integer count1, count2;
    count1 = count2 = 0;
    Map < String, Integer > soupDetailsMap = new Map < String, Integer > ();
    for (Passenger_Optional__c passOptional: passengerOptoinalList) {
        if(passOptional.Selected_soup__c != null && tourOptionalInstance.Optional__c != null){
            if(tourOptionalInstance.Supplier_Menu__r.soup_Text_1__c != null && tourOptionalInstance.Supplier_Menu__r.soup_Text_1__c == passOptional.Selected_soup__c) {
                if (!soupDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.soup_Text_1__c)) {
                  soupDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.soup_Text_1__c, count1++);
                } else {
                  count1 = soupDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.soup_Text_1__c);
                  count1++;
                  soupDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.soup_Text_1__c, count1);
                }
            } else if(tourOptionalInstance.Supplier_Menu__r.soup_Text_2__c != null && tourOptionalInstance.Supplier_Menu__r.soup_Text_2__c == passOptional.Selected_soup__c) {
                if (!soupDetailsMap.containsKey(tourOptionalInstance.Supplier_Menu__r.soup_Text_2__c)) {
                  soupDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.soup_Text_2__c, count2++);
                } else {
                  count2 = soupDetailsMap.get(tourOptionalInstance.Supplier_Menu__r.soup_Text_2__c);
                  count2++;
                  soupDetailsMap.put(tourOptionalInstance.Supplier_Menu__r.soup_Text_2__c, count2);
                }
            }
        }
    }

    for (String soupVar: soupDetailsMap.keyset()) {
        if(soupDetailsMap.get(soupVar) > 0){
            soupDetails += soupVar + ' - ' + soupDetailsMap.get(soupVar) + '<br>';
        }
    }

    return soupDetails;
 }

 /**
   * @description  Used to get Guest Details
   * @param        void
   * @return       void
   */
  private static String getGuestDetail(List < Passenger_Optional__c > passengerOptoinalList) {
    String guestDetails = '';
    Map < String, String > guestDetailsMap = new Map < String, String > ();
    Map < String, String > guestMealDetailsMap = new Map < String, String > ();
    String mealValues = '';
    for (Passenger_Optional__c passOptional: passengerOptoinalList) {
        if(passOptional.Passenger__c != null){
        
        //Changes Start, Done by Maksud Ali for Story :S-487869 (I've replaced Dietary_Requirements__c with Menu_Notes__c)
            if (!guestDetailsMap.containsKey(passOptional.passenger__r.First_Name__c + ' ' + passOptional.Passenger__r.Family_Name__c) &&
            passOptional.Menu_Notes__c != null) {
                guestDetailsMap.put(
                  passOptional.passenger__r.First_Name__c + ' ' + passOptional.Passenger__r.Family_Name__c,
                  String.isNotEmpty(passOptional.Menu_Notes__c) ? passOptional.Menu_Notes__c : ''
                );
                //End changes of the story : S-487869
                mealValues = '';
                if(passOptional.Selected_Starter__c != null){
                    mealValues += passOptional.Selected_Starter__c + '<br>';
                }
                if(passOptional.Selected_Soup__c != null){
                    mealValues += passOptional.Selected_Soup__c + '<br>';
                }
                if(passOptional.Selected_Dessert__c != null){
                    mealValues += passOptional.Selected_Dessert__c + '<br>';
                }
                if(passOptional.Selected_Main__c != null){
                    mealValues += passOptional.Selected_Main__c + '<br>';
                }
                guestMealDetailsMap.put(passOptional.passenger__r.First_Name__c + ' ' + passOptional.Passenger__r.Family_Name__c,  mealValues);
            }
        }
    }

    for(String guest: guestDetailsMap.keyset()) {
        guestDetails += '<u>' + guest + '</u>';
      guestDetails += String.isNotBlank(guestDetailsMap.get(guest)) ? ', ' + guestDetailsMap.get(guest) + '<br>' : '<br>';
        guestDetails += guestMealDetailsMap.get(guest) + '<br>';
    }
    return guestDetails;
 }
    
        //Modified by Aditya Tiwari for Case#00189145 start
        //Added getKidsMenuCount function to count the kids menu
        /*
        * @description  Used to count the Kids Menu
        * @param        void
        * @return       void
        */
        
        private static integer getKidsMenuCount(List < Passenger_Optional__c > passengerOptoinalList){
            
            integer countkids = 0;
            for (Passenger_Optional__c ac : passengerOptoinalList)
            {
                if(ac.Kids_Menu_Selected__c ==  true)
                {
                    countkids++;
                }
            }
            System.debug('countinkids'+ countkids);
        
             return countkids;
        } 

        //Modified by Aditya Tiwari for Case#00189145 End    

}