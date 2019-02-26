//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_EmailService_Test
// For Apex Classes: TOPS_EmailService
// Description: Used in email print service.
//
// 10th February 2016    Hemendra Singh Bhati    Original (Task # T-471063) - Please see the task description for more details.
// 21st October 2016    Ravi Jain               Modified (Story# S-428354) - Please see the story description for more details.
//
@isTest(seeAllData=false)
private class TOPS_EmailService_Test {
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void validateClassFunctionality() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Multiple Chatter Feed Items.
    List<FeedItem> theTestFeedItemRecords = new List<FeedItem> {
      new FeedItem(
        ParentId = Userinfo.getUserId(),
        Type = 'ContentPost',
        ContentFileName = 'ChatterFile.pdf',
        ContentData = Blob.valueOf('Chatter File Content')
      ),
      new FeedItem(
        ParentId = Userinfo.getUserId(),
        Type = 'ContentPost',
        ContentFileName = 'AnotherChatterFile.pdf',
        ContentData = Blob.valueOf('Another Chatter File Content')
      )
    };
    insert theTestFeedItemRecords;

    // Inserting Multiple Test Email Print Request Config Records.
    Email_Print_Request_Config__c theTestEmailPrintRequestConfig = null;
    
    // Code changes done by Ravi Jain for Story S-428354
    // Code changes start here   
    Email_Print_Request_Config__c theTestEmailPrintRequestConfigFerryList = null;
    //Code changes end here
          
    List<Email_Print_Request_Config__c> theTestEmailPrintRequestConfigRecords = new List<Email_Print_Request_Config__c>();
    theTestEmailPrintRequestConfig = theTestDataFactory.createEmailPrintRequestConfig(
      'Email/Rooming List Emails',
      'TOPS_HotelEmailProcessor',
      '',
      '',
      '<p><strong><em>Hello</em></strong><em></em>[TDhotelSalutation]</p>',
      'Email/Rooming List Emails',
      'Email',
      false
    );
    //theTestEmailPrintRequestConfig.Attachments_to_include__c = 'Passport List, Room List';
    
    // Code commented and changes done by Ravi Jain for Story S-428354
    // Code changes start here  
 
    theTestEmailPrintRequestConfig.Attachments_to_include__c = 'Passport List, Room List,Ferry List';  
    // Code changes end here
      
    theTestEmailPrintRequestConfigRecords.add(theTestEmailPrintRequestConfig);
    
    theTestEmailPrintRequestConfig = theTestDataFactory.createEmailPrintRequestConfig(
      'Room List',
      'TOPS_RoomListPDF',
      '',
      '',
      '',
      'Room List',
      'Print',
      false
    );
    
      // Code changes done by Ravi Jain for Story S-428354
     // Code changes start here 
     
      theTestEmailPrintRequestConfigFerryList = theTestDataFactory.createEmailPrintRequestConfig(
      'Ferry List',
      'TOPS_FerryListPDF',
      '',
      '',
      '',
      'Ferry List',
      'Print',
      false
    );
    // Code changes end here
          
    theTestEmailPrintRequestConfigRecords.add(theTestEmailPrintRequestConfig);
    // Code changes done by Ravi Jain for Story S-428354
    // Code changes start here 
    
    theTestEmailPrintRequestConfigRecords.add(theTestEmailPrintRequestConfigFerryList);
    // Code changes end here
    
    insert theTestEmailPrintRequestConfigRecords;

    // Inserting Test Tour Instance Itineraries.
    Tour_Instance_Itinerary__c theTourInstanceItinerary = new Tour_Instance_Itinerary__c(
      City__c = 'Rome',
      Arrival_Time__c = '07:00',
      Dinner_Time__c = '20:00',
      Morning_Call_Time__c = '08:00',
      Bags_Time__c = '07:30',
      Depart_Time__c = '10:00',
      Breakfast_time__c = '08:00',
      Day_Number__c = 1,
      Component_Type__c = 'Hotel'
    );
    insert theTourInstanceItinerary;

    // Inserting Test Email Print Request Record.
    Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      '',
      '',
      'hsingh@appirio.com',
      'New',
      'Email/Rooming List Emails',
      false
    );
    theTestEmailPrintRequest.Related_Object_Id__c = theTourInstanceItinerary.Id;
    theTestEmailPrintRequest.Static_Attachments__c = String.valueOf(theTestFeedItemRecords.get(0).Id) + ',' +
                                                     String.valueOf(theTestFeedItemRecords.get(1).Id);
    theTestEmailPrintRequest.Dynamic_Attachments__c = 'Room List';
    theTestEmailPrintRequest.Preview__c = false;
    theTestEmailPrintRequest.Additional_Emails__c = '{"cc":"jai@test.com,jai@success.com"}'; // Added by Jai Gupta S-568616  
    insert theTestEmailPrintRequest;

    // Validating Email Wrapper Instance.
    TOPS_EmailWrapper theEmailWrapper = TOPS_EmailService.createEmailWrapper(
      theTestEmailPrintRequest,
      theTestEmailPrintRequestConfigRecords.get(0)
    );
    //system.assert(
    //  theEmailWrapper != null && theEmailWrapper.attachments.size() > 0,
    //  'Error: The email service apex class failed to add support for static and dynamic attachments.'
    //);
    }
}