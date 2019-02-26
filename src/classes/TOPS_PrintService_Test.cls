//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_PrintService_Test
// For Apex Classes: TOPS_PrintService, TOPS_EmailPrintEngine
// Description: Used in email print service.
//
// 27th January 2016    Hemendra Singh Bhati  Original (Task # T-465464)
// 21st October 2016    Ravi Jain               Modified (Story# S-428354) - Please see the story description for more details.
//
@isTest(seeAllData=false)
private class TOPS_PrintService_Test {
  // Private Data Members.
  private static final Id ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Supplier - Hotel').RecordTypeId;

  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void validateClassFunctionality() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Supplier Hotel Account.
    Account theSupplier = new Account(
      Name = 'Executive Style Hotel Rome',
      Crew_Email_for_Supplier_Office_use__c = 'hsingh@appirio.com',
      RecordTypeId = ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID
    );
    insert theSupplier;

    // Inserting Test Tour Instance.
    Tour_Instance__c theTestTourInstance = theTestDataFactory.createTourInstance('Test Tour', 'IEW93210', false);
    theTestTourInstance.Start_Date__c = Date.today();
    theTestTourInstance.Allocated_TD__c = theSupplier.Id;
    insert theTestTourInstance;

    // Inserting Test Tour Instance Itinerary.
    Tour_Instance_Itinerary__c theTourInstanceItinerary = new Tour_Instance_Itinerary__c(
      Tour_Instance__c = theTestTourInstance.Id,
      Supplier__c = theSupplier.Id,
      City__c = 'Rome',
      Arrival_Time__c = '07:00',
      Dinner_Time__c = '20:00',
      Morning_Call_Time__c = '08:00',
      Bags_Time__c = '07:30',
      Depart_Time__c = '10:00',
      Breakfast_time__c = '08:00',
      Day_Number__c = 1,
      Component_Type__c = 'Itinerary'  
    );
    insert theTourInstanceItinerary;

    // Inserting Test Email Print Request Config Records.
    List<Email_Print_Request_Config__c> theTestEmailPrintRequestConfigRecords = new List<Email_Print_Request_Config__c> {
      theTestDataFactory.createEmailPrintRequestConfig(
        'Room List',
        'TOPS_RoomListPDF',
        '',
        '',
        '',
        'Room List',
        'Print',
        false
      ),
      theTestDataFactory.createEmailPrintRequestConfig(
        'Ferry List',
        'TOPS_FarewellListPDF',
        '',
        '',
        '',
        'Farewell List',
        'Print',
        false
      ),
      theTestDataFactory.createEmailPrintRequestConfig(
        'Welcome Email',
        'TOPS_WelcomeEmailProcessor',
        '',
        '',
        '',
        'Welcome Email',
        'Email',
        false
      ),
          
      // Code changes done by Ravi Jain for Story S-428354
     // Code changes start here      
     theTestDataFactory.createEmailPrintRequestConfig(
        'Passport List',
        'TOPS_PassportListPDF',
        '',
        '',
        '',
        'Passport List',
        'Print',
        false
      ),
      // Code changes end here
      
      // Code changes done by Ravi Jain for Story S-428354
     // Code changes start here      
     theTestDataFactory.createEmailPrintRequestConfig(
        'Seating Plan',
        'TOPS_seatRotationPDF',
        '',
        '',
        '',
        'Seating Plan',
        'Print',
        false
      )
      // Code changes end here    
         
    };
    insert theTestEmailPrintRequestConfigRecords;

    // Instantiating Test Email Print Request - Room List.
    Email_Print_Request__c theRoomListEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      '',
      '',
      'hsingh@appirio.com',
      'New',
      'Room List',
      false
    );
    theRoomListEmailPrintRequest.Related_Object_Id__c = theTourInstanceItinerary.Id;
    theRoomListEmailPrintRequest.Parameters__c = null;
    theRoomListEmailPrintRequest.Preview__c = true;

    // Instantiating Test Email Print Request - Farewell List.
    Email_Print_Request__c theFarewellListEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      '',
      '',
      'hsingh@appirio.com',
      'New',
      'Farewell List',
      false
    );
    theFarewellListEmailPrintRequest.Related_Object_Id__c = theTestTourInstance.Id;
    theFarewellListEmailPrintRequest.Parameters__c = null;
    theFarewellListEmailPrintRequest.Preview__c = true;

    // Instantiating Test Email Print Request - Welcome Email.
    Email_Print_Request__c theWelcomeEmailEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Welcome Email - Test Subject',
      'My name is [TDfullname] and I am your [TDrole] for the [TourBrandName] [TourName] starting in [TourRegion] [TourStartDate].',
      'hsingh@appirio.com',
      'New',
      'Welcome Email',
      false
    );
    theWelcomeEmailEmailPrintRequest.Related_Object_Id__c = theTestTourInstance.Id;
    theWelcomeEmailEmailPrintRequest.Parameters__c = null;
    theWelcomeEmailEmailPrintRequest.Preview__c = true;

    // Code changes done by Ravi Jain for Story S-428354
    // Code changes start here  
    // Instantiating Test Email Print Request - Passport List.
    Email_Print_Request__c thePassportListEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      '',
      '',
      'ravi.jain@appirio.com',
      'New',
      'Passport List',
      false
    );
    thePassportListEmailPrintRequest.Related_Object_Id__c = theTourInstanceItinerary.Id;
    thePassportListEmailPrintRequest.Parameters__c = null;
    thePassportListEmailPrintRequest.Preview__c = true;
    // Code changes end here
    
    // Code changes done by Ravi Jain for Story S-428354
    // Code changes start here  
    // Instantiating Test Email Print Request - Passport List.
    Email_Print_Request__c theSeatingPlanPrintRequest = theTestDataFactory.createEmailPrintRequest(
      '',
      '',
      'ravi.jain@appirio.com',
      'New',
      'Seating Plan',
      false
    );
    theSeatingPlanPrintRequest.Related_Object_Id__c = theTourInstanceItinerary.Id;
    theSeatingPlanPrintRequest.Parameters__c = null;
    theSeatingPlanPrintRequest.Preview__c = true;
    theSeatingPlanPrintRequest.Data__c = 'Test';
    theSeatingPlanPrintRequest.Subject__c = 'Test Subject';  
    // Code changes end here  
        
    // Inserting Test Email Print Request Records.
    insert new List<Email_Print_Request__c> {
      theRoomListEmailPrintRequest,
      theFarewellListEmailPrintRequest,
      theWelcomeEmailEmailPrintRequest,
      theSeatingPlanPrintRequest,
     // Code changes done by Ravi Jain for Story S-428354
    // Code changes start here  
    
      thePassportListEmailPrintRequest
    // Code changes end here     
     
    };

    Test.startTest();

    // Generating Email Attachment PDF For The Provided Email Print Request And Config.
    Blob thePDF = TOPS_PrintService.processAttachment(theRoomListEmailPrintRequest, theTestEmailPrintRequestConfigRecords.get(0));
    system.assert(
      thePDF != null,
      'Error: The email print service failed to generate the required PDF.'
    );

    // Generating An Instance of Email Wrapper.
    TOPS_EmailWrapper theEmailWrapper = TOPS_PrintService.createEmailWrapper(theRoomListEmailPrintRequest, theTestEmailPrintRequestConfigRecords.get(0));
    system.assert(
      theEmailWrapper != null,
      'Error: The email print service failed to generate an instance of email wrapper.'
    );

    Test.stopTest();
    }
}