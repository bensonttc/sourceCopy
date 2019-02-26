//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_FarewellEmailProcessor
// For Apex Interface: TOPS_EmailProcessorInterface
// Description: Used in email print service.
//
// 25th Jan 2016    Hemendra Bhati  Modified (Task # T-468823)
// 11th Feb 2016    Nitish Bansal   Modified (Task # T-465485)
// 28th Feb 2017    Anuj Khanna     Modified(Task #T-568315)
// 12th June 2017   Ravi Jain       Modified (Story# S-485985)
// 14th June 2017   Ravi Jain       Modified (Story# S-485984)
// 22th June 2017   Abhishek Saxena Modified (T-624298, T-621431) - Uncommented the code and 
//                                  added future call in TOPS_SendGridOutboundRequestDispFuture
//09rd Nov 2017     Neeraj Kumawat  Added check for Farewell Email Merge field(I-299931)

public without sharing class TOPS_FarewellEmailProcessor implements TOPS_EmailProcessorInterface {
  // Private Data Members.

  // Public Data Members.
  public static string TDFW_Salutation = '[TDFarewellSalutation]';
  public static string TDFW_Body = '[TDFarewellBody]';
  public static string TDFW_GoodBye = '[TDFarewellGoodbye]';
  public static string TDFW_FName = '[TDFirstName]';
  public static string TDFW_BrName = '[BrandName]';
  public static string TDFW_BrWebSite = '[BrandWebsite]';
  public static string TDFW_BrHashTag = '[BrandHashTag]';
  public static string TDFW_BrRegMessage = '[BrandRegionMessage]';
  public static string TDFW_BrRole = '[Tour Brand Role]';
  public static string BrandMessage = '[BrandMessage]';
  public static string TDFW_Instagram = '[Instagram]';
  public static string TDFW_Twitter = '[Twitter]';
  public static string TDFW_Facebook = '[Facebook]';
   
   // Code changes done by Ravi Jain for story S-485985
  // Start - Ravi Jain - S-485985 - June 12,2017  - Pass the RegionBrandFarewellMessage in String
  public static string Region_Brand_Farewell_Message = '[RegionBrandFarewellMessage]';
  // End - Ravi Jain - S-485985 - June 12,2017
    
  public static string TOPS_EMAIL = 'TOPS_Email';  
  public static String bccEmail;
  public static List<Tour_Instance__c> tourIns;
  public static List<Passenger__c> passLst;
  public static Passenger__c passTD;
  public static set<Passenger__c> emailPassengers;
  public static String brandName;
  public static String regionCode;
  public static String tdId;

  /**
  * @description  Used to generate emails.
  *
  * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
  * @return       TOPS_EmailWrapper
  */
  public TOPS_EmailWrapper createEmailWrapper(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    // Merging Required Fields.
    String emailBodyContent = mergeFields(request, configRecord);
    emailBodyContent = emailBodyContent.replaceAll('\n', '<br>');

    // Instantiating Email Wrapper Class.
    TOPS_EmailWrapper theEmailWrapper = new TOPS_EmailWrapper(
      request.Email_Addresses__c,
      '',
      'Farewell Email',
      emailBodyContent,
      null
    );
     System.debug('brandName ' + brandName);

    // Generating Email Body.
    // Code commented and changes done by Ravi Jain for story S-485984
    //PageReference pgEmail = new PageReference('/apex/' + TOPS_EMAIL + '?data=' + EncodingUtil.urlEncode(emailBodyContent.unescapeHtml4(), 'UTF-8') + '&Brand='+brandName);
    // Start - Ravi Jain - S-485984 - June 14,2017  - Pass the emailTemplate and TourDirectorId in the PageReference
    
    String emailTemplate = configRecord.Template__c; 
    PageReference pgEmail = new PageReference('/apex/' + TOPS_EMAIL + '?data=' + EncodingUtil.urlEncode(emailBodyContent.unescapeHtml4(), 'UTF-8') + '&Brand='+brandName + '&TourDirectorId='+tdId + '&emailTemplate='+emailTemplate);
    // End - Ravi Jain - S-485984 - June 14,2017
    String emailContent = Test.isRunningTest() ? 'Test Email Content' : pgEmail.getContent().toString();
    String emailBody = EncodingUtil.urlDecode(emailContent, 'UTF-8');
    System.debug('emailBody ' + emailBody);

    // Updating Email Wrapper Instance.
    theEmailWrapper.emailBody =  emailBody;

    theEmailWrapper.replyTo = (tourIns.size() > 0 && tourIns.get(0).Allocated_TD__c != null) ? tourIns.get(0).Allocated_TD__r.Crew_Email_guest__c : ' ';
    if(request.Preview__c) {
      theEmailWrapper.toEmail = theEmailWrapper.replyTo;
    }
    else {
      theEmailWrapper.cc = theEmailWrapper.replyTo;
      if(configRecord.Template__c == 'Farewell Email') {
        for(Passenger__c pass : emailPassengers) {
          if(pass.Email_Share_Opt_In__c == true  && pass.Email__c != null) {
            theEmailWrapper.toEmail = theEmailWrapper.toEmail + ',' + pass.Email__c;
          }
        }
      }
      else if(configRecord.Template__c == 'Farewell Email - Opt Out') {
        theEmailWrapper.toEmail = theEmailWrapper.replyTo;
        for(Passenger__c pass : emailPassengers) {
          if(pass.Email_Share_Opt_In__c == false && pass.Email__c != null) {
            theEmailWrapper.bcc = theEmailWrapper.bcc + ', ' + pass.Email__c;
          }
        }
      }
    }
    if(request.Subject__c != null) {
      String emailSubject = request.Subject__c;
      theEmailWrapper.emailSubject = emailSubject;
    } else {
      theEmailWrapper.emailSubject = 'Farewell Email';
    }
    theEmailWrapper.relatedObjectId = request.Related_Object_Id__c;
    theEmailWrapper.brand = brandName;
    theEmailWrapper.regionCode = regionCode;
    theEmailWrapper.tdId = tdId;

    //Updating passenger getting farewell email status.
    List<Passenger__c> updatePAXs = new List<Passenger__c>();
    for(Passenger__c pax : emailPassengers){
        if(pax.Email__c != null) {
            pax.Farewell_Email_Send_Status__c = 'Requested - Request has been sent to API from TOPS';
            pax.Farewell_Email_Send_Date__c = DateTime.now();
            updatePAXs.add(pax);
        }
    }

    try{
        //RB causes an issue with Callout use @future
        //Abhishek Saxena T-624298, T-621431
        update updatePAXs;
    }catch(DMLException ex){
        system.debug('TRACE: TOPS_FarewellEmailProcessor - getPassengersEmail - bccEmail - ' + ex.getDmlMessage(0));
    }

    return theEmailWrapper;
  }

  /**
  * @description  Used to process merge fields.
  *
  * @param        void
  * @return       void
  */
  public static String mergeFields(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    Id relatedObjId = request.Related_Object_Id__c;
    brandName = [SELECT Brand_Name__c from Tour_Instance__c WHERE Id =: relatedObjId].Brand_Name__c;
    String detailEmailTemplate = request.Data__c;
    Id recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Brand').getRecordTypeId();
    for (Account a : [SELECT Brand_Farewell_Message__c FROM Account WHERE Name =: brandName AND recordTypeId =: recordTypeId limit 1]){
      if (a.Brand_Farewell_Message__c != null)
        detailEmailTemplate = detailEmailTemplate.replace(BrandMessage, a.Brand_Farewell_Message__c);
      else
        detailEmailTemplate = detailEmailTemplate.replace(BrandMessage, '');
    }

    tourIns = [SELECT Id,Farewell_Email_Merge__c, Allocated_TD__c, Allocated_TD__r.Farewell_Email_Salutation__c, Allocated_TD__r.Crew_Email_guest__c,
               Allocated_TD__r.Farewell_Email_Body__c, Allocated_TD__r.Farewell_Email_Signoff__c,
               Allocated_TD__r.Name, Brand__r.Name, Brand__r.Website, Region_Code__c, Brand_Name__c,
               Tour_Series__r.Brand_farewell_message__c, Allocated_TD__r.Email__c, Tour_Series__c, Brand__c,
               Allocated_TD__r.Instagram__c, Allocated_TD__r.Twitter__c, Allocated_TD__r.Facebook__c
               FROM Tour_Instance__c WHERE Id =: relatedObjId];
   tdId = tourIns[0].Allocated_TD__c;
   
   if(!request.Parameters__c.containsIgnoreCase('V2')){
    passLst = [Select Id, Account__c, passenger_class__c, Email_Share_Opt_In__c, tour_instance__c, Email__c
                from Passenger__c
                where tour_instance__c =: relatedObjId AND Status__c != 'CX'];
    emailPassengers = new set<Passenger__c>();
    for(Passenger__c pass : passLst){

        if(pass.passenger_class__c == 'Tour Director'){
            passTD = pass;
        }else{
            emailPassengers.add(pass);
        }
    }
   }else{
        emailPassengers = getPassengersEmail(request);
   }
    if(tourIns.size() > 0 && tourIns[0].Region_Code__c != null) {
        regionCode = tourIns[0].Region_Code__c;

    }

     // Code commented and changes done by Ravi Jain for story S-485985 
    /*List<Region_Code_Brand_Mapping__mdt> regCodeBrMap = [SELECT Id, hashtag__c, DeveloperName, Brand__c, TD_Role_Name__c FROM
                                                         Region_Code_Brand_Mapping__mdt WHERE DeveloperName = :regionCode];*/
     
    // Start - Ravi Jain - S-485985 - June 12,2017  - Fetch the field Farewell_Email_Region_Brand_Message__c from custom metadata Region_Code_Brand_Mapping__mdt
    List<Region_Code_Brand_Mapping__mdt> regCodeBrMap = [SELECT Id, hashtag__c, DeveloperName, Brand__c, TD_Role_Name__c, Farewell_Email_Region_Brand_Message__c FROM
                                                         Region_Code_Brand_Mapping__mdt WHERE DeveloperName = :regionCode];
   // End - Ravi Jain - S-485985 - June 12,2017  

    if(tourIns.size() > 0) {
      Tour_Instance__c tIns = tourIns[0];
      if (detailEmailTemplate.contains(TDFW_BrRegMessage) && tIns.Tour_Series__c != null && tIns.Tour_Series__r.Brand_farewell_message__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_BrRegMessage, tIns.Tour_Series__r.Brand_farewell_message__c);
      }

      if (detailEmailTemplate.contains(TDFW_Salutation) && tIns.Allocated_TD__c != null && tIns.Allocated_TD__r.Farewell_Email_Salutation__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_Salutation, tIns.Allocated_TD__r.Farewell_Email_Salutation__c);
      }
      if (detailEmailTemplate.contains(TDFW_Body) && tIns.Allocated_TD__c != null && tIns.Allocated_TD__r.Farewell_Email_Body__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_Body, tIns.Allocated_TD__r.Farewell_Email_Body__c);
      }
      if (detailEmailTemplate.contains(TDFW_GoodBye) && tIns.Allocated_TD__c != null && tIns.Allocated_TD__r.Farewell_Email_Signoff__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_GoodBye, tIns.Allocated_TD__r.Farewell_Email_Signoff__c);
      }
      if (detailEmailTemplate.contains(TDFW_FName) && tIns.Allocated_TD__c != null && tIns.Allocated_TD__r.Name != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_FName, tIns.Allocated_TD__r.Name);
      }
      if (detailEmailTemplate.contains(TDFW_BrName) && tIns.Brand_Name__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_BrName, tIns.Brand_Name__c);

      }
      if (detailEmailTemplate.contains(TDFW_BrWebSite)  && tIns.Brand__c != null && tIns.Brand__r.Website != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_BrWebSite, tIns.Brand__r.Website);
      }
      if (detailEmailTemplate.contains(TDFW_Facebook)  && tIns.Allocated_TD__c != null && tIns.Allocated_TD__r.Facebook__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_Facebook, tIns.Allocated_TD__r.Facebook__c);
      }
      if (detailEmailTemplate.contains(TDFW_Twitter)  && tIns.Allocated_TD__c != null && tIns.Allocated_TD__r.Twitter__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_Twitter, tIns.Allocated_TD__r.Twitter__c);
      }
      if (detailEmailTemplate.contains(TDFW_Instagram)  && tIns.Allocated_TD__c != null && tIns.Allocated_TD__r.Instagram__c != null){
        detailEmailTemplate = detailEmailTemplate.replace(TDFW_Instagram, tIns.Allocated_TD__r.Instagram__c);
      }
        
      if(regCodeBrMap.size() > 0) {
        if(regCodeBrMap[0].Brand__c != null){
          brandName = regCodeBrMap[0].Brand__c;
        }
        if (detailEmailTemplate.contains(TDFW_BrHashTag) && regCodeBrMap[0].hashtag__c != null){
          detailEmailTemplate = detailEmailTemplate.replace(TDFW_BrHashTag, regCodeBrMap[0].hashtag__c);
        }
        if (detailEmailTemplate.contains(TDFW_BrRole) && regCodeBrMap[0].TD_Role_Name__c != null){
          detailEmailTemplate = detailEmailTemplate.replace(TDFW_BrRole, regCodeBrMap[0].TD_Role_Name__c);
        }
        // Code changes done by Ravi Jain for story S-485985 
        // Start - Ravi Jain - S-485985 - June 12,2017  - Display the Region_Brand_Farewell_Message if Farewell_Email_Region_Brand_Message__c is not null
        System.debug('Farewell Email Region Code'+' '+regCodeBrMap[0].Farewell_Email_Region_Brand_Message__c);
        if (detailEmailTemplate.contains(Region_Brand_Farewell_Message) && regCodeBrMap[0].Farewell_Email_Region_Brand_Message__c != null){
          detailEmailTemplate = detailEmailTemplate.replace(Region_Brand_Farewell_Message, regCodeBrMap[0].Farewell_Email_Region_Brand_Message__c);
        }
        else
        {
            detailEmailTemplate = detailEmailTemplate.replace(Region_Brand_Farewell_Message, '');
        }
              
        // End - Ravi Jain - S-485985 - June 12,2017 
      }

    }


    //request.Data__c = detailEmailTemplate;
    return detailEmailTemplate;
  }
  
    
  /*
  Modular tours
        '{"modules": ["m1","m2","m3"],"modular": true,"booking": "New"}'
        '{"modules": ["m1","m2","m3"],"modular": true,"booking": "All"}'
  Non-modular tours
        '{"modules": ["NONMOD"],"modular": false,"booking": "All"}'
  
  Ref : (Story# S-458922 / T-568314) 
  */
  private static set<Passenger__c> getPassengersEmail(Email_Print_Request__c request){
        TOPS_WelcomeEmailProcessor.BookingModule bModule;
        String FarewellEmailMerge='';
        if(tourIns.size()>0){
              FarewellEmailMerge=tourIns[0].Farewell_Email_Merge__c;
        }
        if(request.Processing_Data__c != null){
             bModule = (TOPS_WelcomeEmailProcessor.BookingModule)JSON.deserializeStrict(request.Processing_Data__c, TOPS_WelcomeEmailProcessor.BookingModule.class);
        }
        
          List<String> modulesFromJson = new List<String>();
        for(String module : bModule.modules){
            modulesFromJson.add(module+'');
        }
         
          String queryString  = 'SELECT ID, Module_Code__c, Start_Date__c, End_Date__c, ';
               queryString += 'Actual_Room_Type__c,Room_Type_Booked__c, Bag_Number__c, ';
               queryString += 'Room_Number__c, PAX_Timeline__c, Salutation__c, Email__c, ';
               queryString += 'Family_Name__c, First_Name__c, Preferred_Name__c, Room_Near_Group__c, ';
               queryString += 'Passenger_Class__c, Room_Preference__c,  Farewell_Email_Send_Status__c, Email_Share_Opt_In__c ';
               queryString += 'FROM Passenger__c ';
               queryString += 'WHERE Tour_Instance__c = \''+ request.Related_Object_Id__c +'\' ';
               queryString += 'AND Status__c != \'CX\' AND Passenger_Class__c != \'Tour Director\' ';
          if(bModule.modules.size() != 0 && !bModule.modules[0].containsIgnoreCase('NONMOD') &&  !(FarewellEmailMerge=='Only one farewell email for whole tour/trip' && (request.Template__c == 'Farewell Email' ||   request.Template__c == 'Farewell Email - Opt Out'))){
               queryString +=  ' AND Module_Code__c IN : modulesFromJson ';
         }
         
          System.debug('queryString'+queryString); 
        
        //Creating a Map of Modules to Passengers
         Map<String, List<Passenger__c>> mapModtoPax = new Map<String, List<Passenger__c>>();
         for(Passenger__c pax : database.query(queryString)){
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
        set<Passenger__c> emailToPAX = new set<Passenger__c>();
        if(bModule.booking == 'New'){
            for(Passenger__c pax : allModulePAX){
                if(pax.Farewell_Email_Send_Status__c == null 
                    || pax.Farewell_Email_Send_Status__c == 'Not Sent'){
                    emailToPAX.add(pax);
                }
            }
        }
        if(bModule.booking == 'All'){
            emailToPAX.addAll(allModulePAX);            
        }
        return emailToPAX;
  }

}