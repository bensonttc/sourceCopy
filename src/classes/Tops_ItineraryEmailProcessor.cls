/**
* For Apex Class    : Tops_ItineraryEmailProcessor
* Created By        : Ravi Jain
* Date              : 06/02/2017 
* Purpose           : S-455963 and S-458016
*/
// 10th Feb 2016    Ravi Jain       Modified (Story# S-455955) - Please see the story description for more details.
// 10th Aug 2018    Jai Gupta       Modified (Story S-568616) - Send email to cc email addresses

public class Tops_ItineraryEmailProcessor implements TOPS_EmailProcessorInterface {

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
  public static Map<String, String> fieldMapping;
  public static String regionCode;
  public static String tdId;
  public static String toEmail;
  public static String fromEmail;
  //public static String bccEmail;
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
    String defaultBody = Tops_ItineraryEmailProcessor.mergeFields(request, configRecord);
    defaultBody = defaultBody.replaceAll('\n', '<br>');
    system.debug('-----defaultBody-------'+defaultBody);
    system.debug('----brandName-------'+brandName);
    PageReference emailPage = new PageReference('/apex/TOPS_Email' + '?data=' + EncodingUtil.urlEncode(defaultBody.unescapeHtml4(), 'UTF-8') + '&Brand='+brandName);
    String emailContent = Test.isRunningTest() ? 'Test Email Content' : emailPage.getContent().toString();
    System.debug('emailContent: ' + emailContent);
    String emailBody = EncodingUtil.urlDecode(emailContent, 'UTF-8');
    if(request.Subject__c != null){
      emailSubject = request.Subject__c;
    }
    if(emailSubject == null){
      emailSubject = '(no subject)';
    }

    system.debug('----emailBody-------'+emailBody);
    system.debug('----toEmail-------'+toEmail);
    system.debug('----fromEmail-------'+fromEmail);
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
      emailSubject,
      emailBody,
      null
    );
    theEmailWrapper.replyTo = fromEmail;
    theEmailWrapper.regionCode = regionCode;
    theEmailWrapper.tdId = tdId;
    theEmailWrapper.cc = ccEmail;
    //theEmailWrapper.bcc = bccEmail;
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
    fieldMapping = new Map < String, String > ();
    List < String > fields = getFields();
    regionCode = '';

    for (String field: fields) {
      fieldMapping.put(field, '');
    }
     
    // Code changes done by Ravi Jain for story S-455955
  // Code changes start here
  
    if(request.Related_Object_Id__c.startsWith('001'))
    {    
         tdId = request.Related_Object_Id__c;
         getBrandName();
         mergeRegionCodeFieldTour();
         System.debug('Request Name Value'+' '+tdId);
    }
    else
    {
   // Code changes end here  
    mergeTourInstanceField(request.Related_Object_Id__c);
    mergeRegionCodeField();
    mergeBrandMessage();
    mergeTDFields(request.Related_Object_Id__c);
    }
     // Code changes done by Ravi Jain for story S-455955
    // Code changes start here  
    
    if(!request.Related_Object_Id__c.startsWith('001'))
    {
    setEmailToFromAddr(request);
    }   
    else
    {
         
    }
   // Code changes end here
   
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

  // Code changes done by Ravi Jain for story S-455955
  // Code changes start here
  
  /**
   * @description  Used to get Region Code
   * @param        void
   * @return       void
   */
  private static void mergeRegionCodeFieldTour() {
    for (Region_Code_Brand_Mapping__mdt mapRec: [SELECT DeveloperName, Brand__c, TD_Role_Name__c,
                                                        Hashtag__c, Tour_Type_Brand__c
        FROM Region_Code_Brand_Mapping__mdt
        WHERE Brand__c = : brandName Limit 1
      ]) {
        fieldMapping.put(BrandHashTag, mapRec.Hashtag__c);
        fieldMapping.put(TDroleName, mapRec.TD_Role_Name__c);
        fieldMapping.put(TourRegion, mapRec.DeveloperName);
        fieldMapping.put(TourTypeByBrand, mapRec.Tour_Type_Brand__c);
        fieldMapping.put(TourBrandName, mapRec.Brand__c);
        brandName = mapRec.Brand__c;
        regionCode = mapRec.DeveloperName;
      }
  }  
 // Code changes end here   
   
   /**
   * @description  Used to get Fields
   * @param        void
   * @return       void
   */
  private static void mergeRegionCodeField() {
    for (Region_Code_Brand_Mapping__mdt mapRec: [SELECT DeveloperName, Brand__c, TD_Role_Name__c,
                                                        Hashtag__c, Tour_Type_Brand__c
        FROM Region_Code_Brand_Mapping__mdt
        WHERE DeveloperName = : regionCode
      ]) {
        fieldMapping.put(BrandHashTag, mapRec.Hashtag__c);
        fieldMapping.put(TDroleName, mapRec.TD_Role_Name__c);
        fieldMapping.put(TourRegion, mapRec.DeveloperName);
        fieldMapping.put(TourTypeByBrand, mapRec.Tour_Type_Brand__c);
        fieldMapping.put(TourBrandName, mapRec.Brand__c);
        brandName = mapRec.Brand__c;
      }
  }

 
    
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
        {    
          Integer startday = tour.Start_Date__c.day();
          Integer startYear = tour.Start_Date__c.year();
          Integer startMonth = tour.Start_Date__c.month();  
          String startMonthString = 'Jan';
          fieldMapping.put(TourStartDate, (startday + ' ' + startMonthString + ' ' + startYear));                                    
        }  

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
    
    // Code changes done by Ravi Jain for story S-455955
  // Code changes start here
    
  private static void getBrandName(){
    for (Account a : [SELECT Id, Name, Primary_Brand__c, Crew_Email_for_Supplier_Office_use__c FROM Account WHERE Id =: tdId AND Primary_Brand__c !=null limit 1]){
      brandName = a.Primary_Brand__c;
      toEmail = fromEmail = ccEmail = a.Crew_Email_for_Supplier_Office_use__c;
    }
  }  
 // Code changes end here 

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
  * @description  Set From and CC Email Address
  * @param        void
  * @return       void
  */
  private static void setEmailToFromAddr(Email_Print_Request__c request) {
    toEmail = fromEmail = '';
    for(Tour_Instance__c theRecord : [SELECT Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c FROM Tour_Instance__c
                                      WHERE Allocated_TD__c != null AND Id = :request.Related_Object_Id__c]) {
      toEmail = fromEmail = ccEmail = theRecord.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c;
    }
  }
}