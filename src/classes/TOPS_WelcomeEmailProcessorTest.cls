/*
Test Class Name         : TOPS_WelcomeEmailProcessorTest
For Apex Class          : TOPS_WelcomeEmailProcessor
Created By              : Nitish Bansal 
Date                    : 02/11/2016 
Purpose                 : T-467665
*/
// 04th Jan 2017    Ravi Jain              Modified (Story# S-455844) - Please see the story description for more details.
// 
@isTest
private class TOPS_WelcomeEmailProcessorTest {
  // Private Data Members.
  private static final Id ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Business Unit').RecordTypeId;
	private static Tour_Instance__c test_TourInstance;
	private static Email_Print_Request_Config__c testEmailPrintConfig;
	private static TestDataFactory theTestDataFactory;
	private static list<Passenger__c> lstPassanger;
	static void createTestData(){
		// Create test data
        theTestDataFactory = new TestDataFactory();
        testEmailPrintConfig =  theTestDataFactory.createEmailPrintRequestConfig('testWelComeEmail','TOPS_WelcomeEmailProcessor','testFieldset',
                                                                'testSubject','testBody','Welcome Email','Email',true);
        
    // Inserting Test Selling Company Account.
    Account theTestSellingCompany = new Account(
      Name = 'Test Selling Company',
      Selling_Company_Short_Name__c = 'GE',
      RecordTypeId = ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID
    );

        Account acc = new Account( LastName='myTest', FirstName='account');
        acc.Email__c = 'nitish.bansal@appirio.com';

    insert new List<Account> {
      theTestSellingCompany,
      acc
    };

    // Inserting Test Tour Series.
    Tour_Series__c theTestTourSeries = new Tour_Series__c(
      Name = 'AAERYF2341',
      Brand_Welcome_Message__c = 'Test Brand Welcome Message'
    );
    insert theTestTourSeries;

    test_TourInstance = theTestDataFactory.createTourInstance('test nick','Abcd', false); 
    /*test_TourInstance.Allocated_TD__c = acc.id;
    test_TourInstance.Operating_Product_Code__c = 'AAER2341';
    test_TourInstance.Start_Date__c = Date.today();
    test_TourInstance.Tour_Series__c = theTestTourSeries.Id;*/
    
    // Code changes done by Ravi Jain for story S-455844 
    // Code changes start here
    for(Integer i=0;i<12;i++)
    {
    test_TourInstance.Allocated_TD__c = acc.id;
    test_TourInstance.Operating_Product_Code__c = 'AAER2341';
    test_TourInstance.Start_Date__c = Date.today().addMonths(i);
    test_TourInstance.Tour_Series__c = theTestTourSeries.Id;
    }   
    // Code changes end here
    
    insert test_TourInstance;

    // Inserting Test Booking.
    Booking__c theTestBooking = new Booking__c(
      Name = 'Test Booking',
      Selling_Company__c = theTestSellingCompany.Id
    );
    insert theTestBooking;

    // Inserting Test Booking Passenger.
    Booking_Passenger__c theTestBookingPassenger = new Booking_Passenger__c(
      Name = 'Test Booking Passenger',
      Booking__c = theTestBooking.Id
    );
    insert theTestBookingPassenger;

    // Inserting Test Booking Component.
    Booking_Component__c theTestBookingComponent = new Booking_Component__c(
      Name = 'Test Booking Component',
      Booking_Passenger__c = theTestBookingPassenger.Id,
      Status__c = 'CF'
    );
    insert theTestBookingComponent;

    lstPassanger = new list<Passenger__c>();
    for(integer i = 1; i< 10;i++) {
      Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+String.valueOf(i),test_TourInstance.Id,false);
      p.Email_Share_Opt_In__c = true;
      p.Dietary_Requirements__c = 'I would prefer green meal';
      p.Booking_Passenger__c = theTestBookingPassenger.Id;
      p.Account__c = acc.id;
	  p.Email__c = 'test@tGmal.com';
	  p.Welcome_Email_Send_Status__c = null;
      if(i== 1 || i == 4 || i == 7) {
        p.Actual_Room_Type__c = 'Double';
      }
      else if( i == 2 || i == 5 || i == 8) {
        p.Actual_Room_Type__c = 'Triple';
      }
      else if( i == 3 || i == 6 || i == 9) {
        p.Actual_Room_Type__c = 'Quad';
      }

      if(i == 1) {
        p.Passenger_Class__c = 'Tour Director';
      }
      else if(i == 2) {
        p.Passenger_Class__c = 'Driver';
      }
      lstPassanger.add(p);
    } 
    insert lstPassanger;
	}


  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
    @isTest static void validteClassFunctionality() {
        
        createTestData();

    // Inserting Test Email Print Request.
    Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'nitish.bansal@appirio.com',
      'New',
      'Welcome Email',
      false
    );
    theTestEmailPrintRequest.Related_Object_Id__c = test_TourInstance.Id;
    theTestEmailPrintRequest.Parameters__c = 'Lost in City Subject: Test email';
    insert theTestEmailPrintRequest;

        TOPS_WelcomeEmailProcessor objWelcomeProcessor = new TOPS_WelcomeEmailProcessor();
        TOPS_EmailWrapper testEmailWrapper = objWelcomeProcessor.createEmailWrapper(theTestEmailPrintRequest,testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);
    }
    
    static testMethod void validateV2Func(){
    	    createTestData();
	
	List<Passenger__c> updatePAX = new List<Passenger__c>();
	Integer ct = 0;
	for(Passenger__c pax : lstPassanger){
		pax.Passenger_Class__c = 'Passenger';
		if(ct< 4){
			pax.Module_Code__c = 'm2';
		}else if(ct > 3 && ct < 8){
			pax.Module_Code__c = 'm3';
		}else{
			pax.Module_Code__c = 'm4';
		}
		updatePAX.add(pax);
		ct++;
	}
	
	update updatePAX;

    // Inserting Test Email Print Request.
    Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'nitish.bansal@appirio.com',
      'New',
      'Welcome Email',
      false
    );
    theTestEmailPrintRequest.Related_Object_Id__c = test_TourInstance.Id;
    theTestEmailPrintRequest.Processing_Data__c = '{"modules": ["m1","m2","m3"],"modular": true,"booking": "New"}';
    theTestEmailPrintRequest.Parameters__c = 'V2-Lost in City Subject: Test email';
    insert theTestEmailPrintRequest;
		system.debug('@@@  request ' + theTestEmailPrintRequest);
        TOPS_WelcomeEmailProcessor objWelcomeProcessor = new TOPS_WelcomeEmailProcessor();
        TOPS_EmailWrapper testEmailWrapper = objWelcomeProcessor.createEmailWrapper(theTestEmailPrintRequest,testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);
    
    }
    static testMethod void validateV1Func(){
    	    createTestData();
	
	List<Passenger__c> updatePAX = new List<Passenger__c>();
	Integer ct = 0;
	for(Passenger__c pax : lstPassanger){
		pax.Passenger_Class__c = 'Passenger';
		if(ct< 4){
			pax.Module_Code__c = 'm2';
		}else if(ct > 3 && ct < 8){
			pax.Module_Code__c = 'm3';
		}else{
			pax.Module_Code__c = 'm4';
		}
		updatePAX.add(pax);
		ct++;
	}
	
	update updatePAX;

    // Inserting Test Email Print Request.
    Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'nitish.bansal@appirio.com',
      'New',
      'Welcome Email',
      false
    );
    theTestEmailPrintRequest.Related_Object_Id__c = test_TourInstance.Id;
    theTestEmailPrintRequest.Processing_Data__c = ''; // '{"modules": ["m1","m2","m3"],"modular": true,"booking": "New"}';
    theTestEmailPrintRequest.Parameters__c = ''; //V2-Lost in City Subject: Test email';
    insert theTestEmailPrintRequest;
    //update theTestEmailPrintRequest;

        TOPS_WelcomeEmailProcessor objWelcomeProcessor = new TOPS_WelcomeEmailProcessor();
        system.debug('@@@@ v1 call wrapper ' + theTestEmailPrintRequest + ' config '  + testEmailPrintConfig );
        TOPS_EmailWrapper testEmailWrapper = objWelcomeProcessor.createEmailWrapper(theTestEmailPrintRequest,testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);
    
    }
}