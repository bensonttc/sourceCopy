//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_WelcomeEmailProcessor
// Description: Used in email print service.
//
// 8th Feb 2016    Kirti Agarwal    Modified (Task # T-467665)
//11th Feb 2016    Nitish Bansal    Modified (Task # T-465528)
// 28th Dec 2016   Ravi Jain        Modified (Story# S-455844) - Please see the story description for more details.
// 27th Feb 2017   Anuj Khanna      Modified (Story# S-458922 / T-568314) V2 Status Logic for Specific Pax's
// 2 June 2017     Richard Boyd     I-276154 Removed Null filter on account query
// 12th June 2017   Ravi Jain       Modified (Story# S-485985)
// 14th June 2017   Ravi Jain       Modified (Story# S-485984)
// 22th June 2017   Abhishek Saxena Modified (T-624297, T-621430, T-624302) - Uncommented the code and 
//                                  added future call in TOPS_SendGridOutboundRequestDispFuture

public without sharing class TOPS_WelcomeEmailProcessor implements TOPS_EmailProcessorInterface {

  public static final String TDwelcomeSalutation = '[TDwelcomeSalutation]';
  public static final String TDfullname = '[TDfullname]';
  public static final String TourName = '[TourName]';
  public static final String TourStartDate = '[TourStartDate]';
  public static final String TDWelcomeBody = '[TDWelcomeBody]';
  public static final String lengthofTour = '[lengthofTour]';
  public static final String TDWelcomeSignoff = '[TDWelcomeSignoff]';
  public static final String TDContactNumber = '[TDContactNumber for guests]';
  public static final String BrandWebsite = '[BrandWebsite]';
  public static final String BrandHashTag = '[BrandHashTag]';
  public static final String TDroleName = '[TDroleName]';
  public static final String TourRegion = '[TourRegion]';
  public static final String TourTypeByBrand = '[TourTypeByBrand]';
  public static final String BRANDMESSAGE = '[BrandMessage]'; // NB - 02/10
  public static final String TourBrandName = '[TourBrandName]';
  
   // Code changes done by Ravi Jain for story S-485985
  // Start - Ravi Jain - S-485985 - June 12,2017  - Pass the RegionBrandFarewellMessage in String
    public static string Region_Brand_Welcome_Message = '[RegionBrandWelcomeMessage]';
  // End - Ravi Jain - S-485985 - June 12,2017
    
  public static Map<String, String> fieldMapping;
  public static String regionCode;
  public static String tdId;
  public static String toEmail;
  public static String fromEmail;
  public static String bccEmail;
  public static String brandName;
  public static String ccEmail;
  public static String emailSubject;
  /**
  * @description  Used to generate emails.
  *
  * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
  * @return       TOPS_EmailWrapper
  */
  public TOPS_EmailWrapper createEmailWrapper(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    system.debug('@@@ req ' + request);
    system.debug('@@@ req ' + configRecord);
    String defaultBody = TOPS_WelcomeEmailProcessor.mergeFields(request, configRecord);
    defaultBody = defaultBody.replaceAll('\n', '<br>');
    system.debug('-----defaultBody-------'+defaultBody);
    system.debug('----brandName-------'+brandName);
      
    // Code commented and changes done by Ravi Jain for story S-485984
    //PageReference emailPage = new PageReference('/apex/TOPS_Email' + '?data=' + EncodingUtil.urlEncode(defaultBody.unescapeHtml4(), 'UTF-8') + '&Brand='+brandName);
    // Start - Ravi Jain - S-485984 - June 14,2017  - Pass the emailTemplate and TourDirectorId in the PageReference
    String emailTemplate = configRecord.Template__c;  
    PageReference emailPage = new PageReference('/apex/TOPS_Email' + '?data=' + EncodingUtil.urlEncode(defaultBody.unescapeHtml4(), 'UTF-8') + '&Brand='+brandName + '&TourDirectorId='+tdId + '&emailTemplate='+emailTemplate); 
    // End - Ravi Jain - S-485984 - June 14,2017
    
    String emailContent = Test.isRunningTest() ? 'Test Email Content' : emailPage.getContent().toString();
    System.debug('emailContent: ' + emailContent);
    String emailBody = EncodingUtil.urlDecode(emailContent, 'UTF-8');
    if(request.Subject__c != null){
      emailSubject = request.Subject__c;
    }
    if(emailSubject == null){
      emailSubject = 'Welcome Email';
    }
    //toEmail = 'nitishbansal9@gmail.com';//Added for testing purpose
    system.debug('----emailBody-------'+emailBody);
    system.debug('----toEmail-------'+toEmail);
    system.debug('----fromEmail-------'+fromEmail);
    TOPS_EmailWrapper theEmailWrapper = new TOPS_EmailWrapper(
      toEmail,
      '',
      emailSubject,
      emailBody,
      null
    );
    theEmailWrapper.replyTo = fromEmail;
    theEmailWrapper.regionCode = regionCode;
    theEmailWrapper.tdId = tdId;
    theEmailWrapper.cc = ccEmail;
    theEmailWrapper.bcc = bccEmail;
    theEmailWrapper.brand = brandName;
    return theEmailWrapper;
  }

  /**
  * @description  Used to process merge fields.
  *
  * @param        void
  * @return       void
  */
  public static String mergeFields(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    system.debug('@@@@ start merge');
    fieldMapping = new Map < String, String > ();
    List < String > fields = getFields();
    regionCode = '';
    system.debug('@@@@ fields ' + fields);
    
    for (String field: fields) {
      fieldMapping.put(field, '');
    }
    mergeTourInstanceField(request.Related_Object_Id__c);
    mergeRegionCodeField();
    mergeBrandMessage();
    mergeTDFields(request.Related_Object_Id__c);
          
    if(!request.Preview__c){
        system.debug('@@@ Process email ' + request);
      if(request.Parameters__c.containsIgnoreCase('V2')){ 
        getPassengersEmail(request);
      }else{
        system.debug('@@@ v1 ');
        setEmailBccAddr(request);
      }
    }
    setEmailToFromAddr(request);
    String defaultBody = '';
    if (request.Data__c != null) {
      defaultBody = request.Data__c;
      defaultBody = defaultBody.replace(BrandMessage, fieldMapping.get(BrandMessage));
      for (String field: fieldMapping.keyset()) {
        if (fieldMapping.get(field) != null) {
          defaultBody = defaultBody.replace(field, fieldMapping.get(field));
        } else {
          defaultBody = defaultBody.replace(field, '');
        }
      }
      return defaultBody;
    }
    System.debug('fieldMapping ' + fieldMapping);
    return null;
  }

   /**
   * @description  Used to get Fields
   * @param        void
   * @return       void
   */
  private static void mergeTDFields(String tourId) {
     for(Passenger__c pass : [SELECT Id, Actual_Room_Type__c,
                              Dietary_Requirements__c,
                              Passenger_Class__c,
                              Account__c, Account__r.PersonEmail,
                              Account__r.Welcome_Email_Salutation__c,
                              Account__r.Welcome_Email_Body__c,
                              Account__r.Welcome_Email_Signoff__c,
                              Account__r.Crew_Email_guest__c,
                              Account__r.Website
                              FROM Passenger__c
                              WHERE Tour_Instance__c = : tourId
                              AND Passenger_Class__c = 'Tour Director' AND Status__c != 'CX']) {
         fieldMapping.put(TDwelcomeSalutation, pass.Account__r.Welcome_Email_Salutation__c);
         fieldMapping.put(TDWelcomeBody, pass.Account__r.Welcome_Email_Body__c);
         fieldMapping.put(TDWelcomeSignoff, pass.Account__r.Welcome_Email_Signoff__c);
         fieldMapping.put(BrandWebsite, pass.Account__r.Website );
         fieldMapping.put(TDContactNumber, pass.Account__r.Crew_Email_guest__c );

     }
  }

   /**
   * @description  Used to get Fields
   * @param        void
   * @return       void
   */
  private static void mergeRegionCodeField() {
    for (Region_Code_Brand_Mapping__mdt mapRec: [SELECT DeveloperName, Brand__c, TD_Role_Name__c,
                                                 // Code commented and changes done by Ravi Jain for story S-485985 
                                                        //Hashtag__c, Tour_Type_Brand__c
                                                  // Start - Ravi Jain - S-485985 - June 12,2017  - Fetch the field Welcome_Email_Region_Brand_Message__c from custom metadata
                                                  Hashtag__c, Tour_Type_Brand__c, Welcome_Email_Region_Brand_Message__c
                                                  // End - Ravi Jain - S-485985 - June 12,2017
        FROM Region_Code_Brand_Mapping__mdt
        WHERE DeveloperName = : regionCode
      ]) {
        fieldMapping.put(BrandHashTag, mapRec.Hashtag__c);
        fieldMapping.put(TDroleName, mapRec.TD_Role_Name__c);
        fieldMapping.put(TourRegion, mapRec.DeveloperName);
        fieldMapping.put(TourTypeByBrand, mapRec.Tour_Type_Brand__c);
        fieldMapping.put(TourBrandName, mapRec.Brand__c);
        // Code changes done by Ravi Jain for story S-485985 
        // Start - Ravi Jain - S-485985 - June 12,2017  - Display the Region_Brand_Welcome_Message
        System.debug('Welcome Email Region Code'+' '+mapRec.Welcome_Email_Region_Brand_Message__c);
        if(mapRec.Welcome_Email_Region_Brand_Message__c != null)
        {
            fieldMapping.put(Region_Brand_Welcome_Message, mapRec.Welcome_Email_Region_Brand_Message__c);
        }
        else
        {
            fieldMapping.put(Region_Brand_Welcome_Message, '');
        }
        // End - Ravi Jain - S-485985 - June 12,2017
          
        brandName = mapRec.Brand__c;
      }
  }

  // Code changes done by Ravi Jain for story S-455844
  // Code changes start here
  
  private static String getMonth(Integer month)
  {
      String startMonth = '';
      if(month == 1)
      {
        startMonth = 'January';     
      }
      else if(month == 2)
      {
        startMonth = 'February';     
      }
      else if(month == 3)
      {
        startMonth = 'March';     
      }
      else if(month == 4)
      {
        startMonth = 'April';     
      }
      else if(month == 5)
      {
        startMonth = 'May';     
      }
      else if(month == 6)
      {
        startMonth = 'June';     
      }
      else if(month == 7)
      {
        startMonth = 'July';     
      }
      else if(month == 8)
      {
        startMonth = 'August';     
      }
      else if(month == 9)
      {
        startMonth = 'September';     
      }
      else if(month == 10)
      {
        startMonth = 'October';     
      }
      else if(month == 11)
      {
        startMonth = 'November';     
      }
      else
      {
          startMonth = 'December';
      }
      return startMonth;
  }
  // Code changes end here
    
  /**
   * @description  Used to get Fields
   * @param        void
   * @return       void
   */
  private static void mergeTourInstanceField(String tourId) {
   for(Tour_Instance__c tour : [SELECT Id, Tour_Series__c, Tour_Series__r.Name,
                                        Start_Date__c, Duration__c, Allocated_TD__c,
                                        Allocated_TD__r.Name, Operating_Product_Code__c,
                                        Tour_Series__r.Brand_Welcome_Message__c
                                 FROM Tour_Instance__c
                                 WHERE Id = : tourId]) { // NB - 02/10 - Queried Brand messgae field
         tdId = tour.Allocated_TD__c;
        if(tour.Allocated_TD__c != null)
          fieldMapping.put(TDfullname, tour.Allocated_TD__r.Name);

        if(tour.Tour_Series__c != null)
          fieldMapping.put(TourName, tour.Tour_Series__r.Name);

        if(tour.Start_Date__c != null)
        // Code changes done by Ravi Jain for story S-455844
        {    
          //fieldMapping.put(TourStartDate, tour.Start_Date__c.format());
          // Code changes done by Ravi Jain for story S-455844
         // Code changes start here
          
          Integer startday = tour.Start_Date__c.day();
          Integer startYear = tour.Start_Date__c.year();
          Integer startMonth = tour.Start_Date__c.month();  
          String startMonthString = getMonth(startMonth);
          fieldMapping.put(TourStartDate, (startday + ' ' + startMonthString + ' ' + startYear));                                    
        }
        // Code changes end here  

        fieldMapping.put(lengthofTour, String.valueOf(tour.Duration__c));

        if(tour.Operating_Product_Code__c != null && tour.Operating_Product_Code__c.length() >= 2) {
          regionCode = tour.Operating_Product_Code__c.subString(0,2);
        }
    }

  }

  private static void mergeBrandMessage(){
    Id recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Brand').getRecordTypeId();
    for (Account a : [SELECT Name, Brand_Welcome_Message__c FROM Account WHERE Name =: brandName AND recordTypeId =: recordTypeId limit 1]){
      if (a.Brand_Welcome_Message__c != null)
        fieldMapping.put(BrandMessage, a.Brand_Welcome_Message__c);
      else
        fieldMapping.put(BrandMessage, '');
    }
  }

   /**
   * @description  Used to get Fields
   * @param        void
   * @return       void
   */
  private static List < String > getFields() {

    List < String > fields = new List < String > {
      TDwelcomeSalutation,
      TDfullname,
      TourName,
      TourStartDate,
      TDWelcomeBody,
      lengthofTour,
      TDWelcomeSignoff,
      TDContactNumber,
      BrandWebsite,
      BrandHashTag,
      TDroleName,
      TourRegion,
      TourTypeByBrand,
      BRANDMESSAGE,
      TourBrandName
    };// NB - 02/10 - Added BrandMessage to this list

    return fields;
  }

  /**
  * @description  Used to set Email BCC Address
  * @param        void
  * @return       void
  */
  private static void setEmailBccAddr(Email_Print_Request__c request) {
    Set<String> theBccEmailAddressesSet = new Set<String>();
    //for(Passenger__c pass : [SELECT Passenger_Class__c, Email__c FROM Passenger__c
    //                         WHERE Tour_Instance__c = :request.Related_Object_Id__c AND Status__c != 'CX' AND Account__c != null AND Passenger_Class__c != 'Tour Director']) {
    //I-276154 Richard Boyd removed Account__c != null
      for(Passenger__c pass : [SELECT Passenger_Class__c, Email__c FROM Passenger__c
                             WHERE Tour_Instance__c = :request.Related_Object_Id__c AND Status__c != 'CX' AND Passenger_Class__c != 'Tour Director']) {
      if(pass.Email__c != null) {
        theBccEmailAddressesSet.add(pass.Email__c);
      }
    }
    system.debug('TRACE: TOPS_WelcomeEmailProcessor - setEmailBccAddr - theBccEmailAddressesSet - ' + theBccEmailAddressesSet);

    List<String> theBccEmailAddressesList = new List<String>();
    theBccEmailAddressesList.addAll(theBccEmailAddressesSet);

    bccEmail = theBccEmailAddressesList.size() > 0 ? String.join(theBccEmailAddressesList, ',') : '';
    system.debug('TRACE: TOPS_WelcomeEmailProcessor - setEmailBccAddr - bccEmail - ' + bccEmail);
  }

  /**
  * @description  Set From and CC Email Address
  * @param        void
  * @return       void
  */
  private static void setEmailToFromAddr(Email_Print_Request__c request) {
    toEmail = fromEmail = '';
    for(Tour_Instance__c theRecord : [SELECT Allocated_TD__r.Crew_Email_guest__c FROM Tour_Instance__c
                                      WHERE Allocated_TD__c != null AND Id = :request.Related_Object_Id__c]) {
      toEmail = fromEmail = ccEmail = theRecord.Allocated_TD__r.Crew_Email_guest__c;
    }
  }
  
  
  /*
  Modular tours
        '{"modules": ["m1","m2","m3"],"modular": true,"booking": "New"}'
        '{"modules": ["m1","m2","m3"],"modular": true,"booking": "All"}'
  Non-modular tours
        '{"modules": ["NONMOD"],"modular": false,"booking": "All"}'
  
  Ref : (Story# S-458922 / T-568314)
  */
  private static void getPassengersEmail(Email_Print_Request__c request){
        BookingModule bModule;
        if(request.Processing_Data__c != null){
             bModule = (BookingModule)JSON.deserializeStrict(request.Processing_Data__c, BookingModule.class);
        }
        //Creating a Map of Modules to Passengers
         Map<String, List<Passenger__c>> mapModtoPax = new Map<String, List<Passenger__c>>();
         
         List<String> modulesFromJson = new List<String>();
        for(String module : bModule.modules){
            modulesFromJson.add(module+'');
        }
         
          String queryString  = 'SELECT ID, Module_Code__c, Start_Date__c, End_Date__c, ';
               queryString += 'Actual_Room_Type__c,Room_Type_Booked__c, Bag_Number__c, ';
               queryString += 'Room_Number__c, PAX_Timeline__c, Salutation__c, Email__c, ';
               queryString += 'Family_Name__c, First_Name__c, Preferred_Name__c, Room_Near_Group__c, ';
               queryString += 'Passenger_Class__c, Room_Preference__c, Welcome_Email_Send_Status__c ';
               queryString += 'FROM Passenger__c ';
               queryString += 'WHERE Tour_Instance__c = \''+ request.Related_Object_Id__c +'\' ';
               queryString += 'AND Status__c != \'CX\' AND Passenger_Class__c != \'Tour Director\' ';
        if(bModule.modules.size() != 0 && !bModule.modules[0].containsIgnoreCase('NONMOD')){
               queryString +=  ' AND Module_Code__c IN : modulesFromJson ';
         }
         
          System.debug('queryString'+queryString); 
         
         for(Passenger__c pax : Database.query(queryString)){
           if(pax.Module_Code__c != null){      
             if(mapModtoPax.get(pax.Module_Code__c) == null){
               mapModtoPax.put(pax.Module_Code__c, new List<Passenger__c>());
             }
             mapModtoPax.get(pax.Module_Code__c).add(pax);
           }
         }
     
         //Handling cases where there was no Passenger for a particular Module
         for(String module : bModule.modules){
           if(mapModtoPax.get(module) == null)
             mapModtoPax.put(module, new List<Passenger__c>());
         }
         System.debug('mapModtoPax'+mapModtoPax);
        
        
        List<Passenger__c> allModulePAX = new List<Passenger__c>();
        for(String mods : mapModtoPax.keySet()){
            for(Passenger__c pass: mapModtoPax.get(mods)){
                allModulePAX.add(pass);
            }
        }
        List<Passenger__c> emailToPAX = new List<Passenger__c>();
        if(bModule.booking == 'New'){
            for(Passenger__c pax : allModulePAX){
                if(pax.Welcome_Email_Send_Status__c == null 
                    || pax.Welcome_Email_Send_Status__c == 'Not Sent'){
                    emailToPAX.add(pax);
                }
            }
        }
        if(bModule.booking == 'All'){
            emailToPAX.addAll(allModulePAX);            
        }
        
        Set<String> theBccEmailAddressesSet = new Set<String>();
        List<Passenger__c> updatePAXs = new List<Passenger__c>();
        for(Passenger__c pax : emailToPAX){
            if(pax.Email__c != null) {
                theBccEmailAddressesSet.add(pax.Email__c);
                pax.Welcome_Email_Send_Status__c = 'Requested - Request has been sent to API from TOPS';
                pax.Welcome_Email_Send_Date__c = DateTime.now();
                updatePAXs.add(pax);
            }
        }
        system.debug('TRACE: TOPS_WelcomeEmailProcessor - getPassengersEmail - theBccEmailAddressesSet - ' + theBccEmailAddressesSet);
    
        List<String> theBccEmailAddressesList = new List<String>();
        theBccEmailAddressesList.addAll(theBccEmailAddressesSet);
    
        bccEmail = theBccEmailAddressesList.size() > 0 ? String.join(theBccEmailAddressesList, ',') : '';
        system.debug('TRACE: TOPS_WelcomeEmailProcessor - getPassengersEmail - bccEmail - ' + bccEmail);    
    
        try{
            //RB causes an issue with Callout use @future
            // 22th June 2017   Abhishek Saxena (T-624297, T-621430, T-624302)
            update updatePAXs;
        }catch(DMLException ex){
            system.debug('TRACE: TOPS_WelcomeEmailProcessor - getPassengersEmail - bccEmail - ' + ex.getDmlMessage(0));
        }
  }
  
  public class BookingModule{
    public List<String> modules{get; set;}
    public String modular{get; set;}
    public String booking{get; set;}
    public BookingModule(List<String> mods , String isMod , String book){
        modules = mods;
        modular = isMod;
        booking = book;
    }
  }
  
  
}