//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_EmailService
// Description: Used in email print service.
//
// 25th January 2016    Hemendra Singh Bhati    Modified (Task # T-468823) - Please see the task description for more details.
// 9th February 2016    Hemendra Singh Bhati    Modified (Task # T-471063) - Please see the task description for more details.
// 21st October 2016    Ravi Jain               Modified (Story# S-428354) - Please see the story description for more details.
// 20th October 2016    Ravi Jain               Modified (Story# S-428449) - Please see the story description for more details.
// 21 Sep 2017          Neeraj Kumawat          #I-293817(#T-633100) Adding optionalTitle parameter in generatePDFFileName
// 31 OCt 2017          Neeraj Kumawat          #I-299936 Adding module name in the Hotel list PDF Name on welcome email
// 10th Aug 2018      Jai Gupta                 Modified (Story S-568616) - Send email to cc email addresses
public without sharing class TOPS_EmailService {
  // Private Data Members.
  private static final String EPR_TEMPLATE_FAREWELL_EMAIL_OPT_OUT = 'Farewell Email - Opt Out';
  private static final String EPR_TEMPLATE_WELCOME_EMAIL = 'Welcome Email';

  /**
  * @description  Used to process email requests.
  *
  * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
  * @return       TOPS_EmailWrapper theEmailWrapper
  */
  public static TOPS_EmailWrapper createEmailWrapper(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    TOPS_EmailWrapper theEmailWrapper = null;
    try {
      system.debug('TRACE: TOPS_EmailService - createEmailWrapper - request - ' + request);
      system.debug('TRACE: TOPS_EmailService - createEmailWrapper - configRecord - ' + configRecord);

      // Instantiating Email Wrapper Class.
      theEmailWrapper = ((TOPS_EmailProcessorInterface)Type.forName(configRecord.Page_Or_Class__c).newInstance()).createEmailWrapper(request, configRecord);
      theEmailWrapper.attachments = new Map<String, Blob>();
	system.debug('test1');
      // Updating TO Email Address.
      if(String.isNotBlank(request.Email_Addresses__c) && !request.Preview__c) {
        theEmailWrapper.toEmail = request.Email_Addresses__c;
      }
      
		system.debug('test2');
      // Adding Support For Attachments Using Static Attachments.
      if(String.isNotBlank(request.Static_Attachments__c)) {
        String theIdType = null;
        Id theAttachmentId = null;
        Set<Id> theAttachmentIds = new Set<Id>();
        for(String theAttachment : request.Static_Attachments__c.trim().split(',')) {
          theAttachmentId = Id.valueOf(theAttachment.trim());
          theIdType = theAttachmentId.getSObjectType().getDescribe().getName();
          if(theIdType.equalsIgnoreCase('FeedItem')) {
            theAttachmentIds.add(theAttachmentId);
          }
        }
        system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Static Attachments - theAttachmentIds - ' + theAttachmentIds);

        // Processing Valid Attachment Ids.
        if(theAttachmentIds.size() > 0) {
          String theFileName = '';
          String theContentType = '';
          Map<String, Blob> emailAttachments = new Map<String, Blob>();
          for(FeedItem theRecord : [SELECT ContentFileName, ContentType, ContentData FROM FeedItem
                                    WHERE Id IN :theAttachmentIds AND Type = 'ContentPost']) {
            // Extracting Chatter Filename Without Extension.
            theFileName = theRecord.ContentFileName;
            if(theFileName.indexOf('.') != -1) {
              theFileName = theFileName.subString(0, theFileName.indexOf('.'));
            }

            // Determining File Extension Using Content Type.
            theContentType = theRecord.ContentType;
            theContentType = theContentType.subString(theContentType.indexOf('/') + 1, theContentType.length());

            // Generating Filename With Extension.
            theFileName = theFileName + '.' + theContentType;
            system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Static Attachments - theFileName - ' + theFileName);

            emailAttachments.put(theFileName, theRecord.ContentData);
          }

          // Adding Email Attachments To Email Wrapper Instance.
          if(emailAttachments.size() > 0) {
            theEmailWrapper.attachments.putAll(emailAttachments);
          }
        }
      }

      // Adding Support For Attachments Using Dynamic Attachments And Attachments To Include.
      if(String.isNotBlank(request.Dynamic_Attachments__c) || String.isNotBlank(configRecord.Attachments_to_include__c)) {
        Set<String> theTemplateNames = new Set<String>();

        // Processing Attachments To Include.
        if(String.isNotBlank(configRecord.Attachments_to_include__c)) {
          for(String theTemplateName : configRecord.Attachments_to_include__c.trim().split(',')) {
            if(String.isNotBlank(theTemplateName.trim())) {
              theTemplateNames.add(theTemplateName.trim());
            }
          }
          system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Attachments To Include - theTemplateNames - ' + theTemplateNames);
        }

        // Processing Dynamic Attachments.
        if(String.isNotBlank(request.Dynamic_Attachments__c)) {
          for(String theTemplateName : request.Dynamic_Attachments__c.trim().split(',')) {
            if(String.isNotBlank(theTemplateName.trim())) {
              theTemplateNames.add(theTemplateName.trim());
            }
          }
          system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Dynamic Attachments - 1 - theTemplateNames - ' + theTemplateNames);
        }

        // Determining Attachments To Include In Email.
        Map<String, Blob> emailAttachments = new Map<String, Blob>();
        if(theTemplateNames.size() > 0) {
          for(Email_Print_Request_Config__c theConfigRecord : [SELECT Attachments_to_include__c FROM Email_Print_Request_Config__c
                                                               WHERE Template__c IN :theTemplateNames AND Attachments_to_include__c != null]) {
            for(String theTemplateName : theConfigRecord.Attachments_to_include__c.trim().split(',')) {
              if(String.isNotBlank(theTemplateName.trim())) {
                theTemplateNames.add(theTemplateName.trim());
              }
            }
          }
          system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Dynamic Attachments - 2 - theTemplateNames - ' + theTemplateNames);

          // Extracting Email Print Request Config Records.
          Blob thePDFContent;
          String theFileName = '';
          for(Email_Print_Request_Config__c theConfigRecord : [SELECT Template__c, Page_or_Class__c FROM Email_Print_Request_Config__c
                           
                                                               WHERE Template__c IN :theTemplateNames]) {
             // Code changes done by Ravi Jain for Story S-428449 and S-428354
            // Code changes start here        
                                                          
            if(theConfigRecord.Template__c.equalsIgnoreCase('Multi Room List') || theConfigRecord.Template__c.equalsIgnoreCase('Passport List'))
            {
                String optionalTitle=TOPS_PrintService.getOptionalTitle(request);
                theFileName = TOPS_PrintService.generatePDFFileName(String.valueOf(request.Related_Object_Id__c),String.valueOf(theConfigRecord.Template__c),optionalTitle) + '.pdf';
            }
            else
            {
                // #I-299936 Adding module name in the Hotel list PDF Name on welcome email
                String dynamicAttachment=request.Dynamic_Attachments__c;
                if(dynamicAttachment!=null && dynamicAttachment=='Hotel Contact List'){
                    String moduleName=getModuleName(request, configRecord);
                    if(moduleName==''){
                        theFileName = theConfigRecord.Template__c.replace(' ', '_') + '.pdf';
                    }else{
                        theFileName = moduleName+'-'+theConfigRecord.Template__c.replace(' ', '_') + '.pdf';
                    }
                    
                }else{
                    theFileName = theConfigRecord.Template__c.replace(' ', '_') + '.pdf';
                }
            }
            // Code changes end here                                                       
            
            system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Dynamic Attachments - theFileName - ' + theFileName);
            system.debug('TRACE: TOPS_EmailService - createEmailWrapper - request'+request);
            system.debug('TRACE: TOPS_EmailService - createEmailWrapper - theConfigRecord'+theConfigRecord);
            thePDFContent = TOPS_PrintService.processAttachment(request, theConfigRecord);
            emailAttachments.put(theFileName, thePDFContent);
          }
        }

        // Adding Email Attachments To Email Wrapper Instance.
        if(emailAttachments.size() > 0) {
          theEmailWrapper.attachments.putAll(emailAttachments);
        }
      }
    }
    catch(Exception e) {
        system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Exception Message - ' + e.getMessage());
        system.debug('TRACE: TOPS_EmailService - createEmailWrapper - Exception Stack Trace - ' + e.getStackTraceString());
    }
      System.debug('Email Wrapper'+theEmailWrapper);
    return theEmailWrapper;
  }
    /**
  * @description  Used To get The Module Name
  *
  * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
  * @return       Module Name
  */
    public static String getModuleName(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
        TOPS_WelcomeEmailProcessor.BookingModule deserializedData;
        String moduleName='';
        List<String> modulesFromJson = new List<String>();
        String processingData=request.Processing_Data__c;
        Id tourInstanceId=request.Related_Object_Id__c;
        if(!String.isBlank(processingData)){
            deserializedData = (TOPS_WelcomeEmailProcessor.BookingModule)JSON.deserializeStrict(processingData, TOPS_WelcomeEmailProcessor.BookingModule.class);
        }
        for(String module : deserializedData.modules){
            modulesFromJson.add(module+'');
        }
        System.debug('modulesFromJson Value in getModuleName='+modulesFromJson);
        if(modulesFromJson.size() != 0 && !modulesFromJson[0].containsIgnoreCase('NONMOD')){
            //Neeraj Kumawat Getting module name for modular tour
            List<Tour_Instance_Itinerary__c> tourInstanceItineraryList =[SELECT Id, Supplier__c, Module_Name__c, Start_date_of_service__c  
                                                                         FROM Tour_Instance_Itinerary__c 
                                                                         Where Tour_Instance__c =: tourInstanceId 
                                                                         AND Component_Type__c = 'Hotel' 
                                                                         AND Archive__c != TRUE 
                                                                         AND Module_Code__c IN :modulesFromJson];
            System.debug('tourInstanceItineraryList Value='+tourInstanceItineraryList);
            if(tourInstanceItineraryList.size()>0){
                moduleName=tourInstanceItineraryList[0].Module_Name__c;
                return moduleName;
            }
        }else{
            //Neeraj Kumawat Getting module name as tour instance product name for non modular tour
            List<Tour_Instance__c> tourInstanceList =[SELECT id, Name, Special_Brand__c,Operating_Product_Code__c,Product_Name__c, 
                                                      Travel_Director__c,Instance_Code__c,Start_Date__c
                                                      FROM Tour_Instance__c 
                                                      WHERE id=: tourInstanceId];
            if(tourInstanceList.size()>0){
                Tour_Instance__c tourRecord=tourInstanceList[0];
                if(tourRecord.Product_Name__c != null) {
                    moduleName= tourRecord.Product_Name__c;
                }
                
            }
        }
        return moduleName;
    }
}