/*
* Test Class Name   : TOPS_FarewellEmailProcessorTest
* For Apex Class    : TOPS_FarewellEmailProcessor
* Created By        : Nitish Bansal 
* Date              : 02/11/2016 
* Purpose           : T-465485
*/
@isTest
private class TOPS_FarewellEmailProcessorTest {
  // Private Data Members.
    private static final Id ACCOUNT_BRAND_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
    private static Tour_Instance__c test_TourInstance;
	private static Email_Print_Request_Config__c testEmailPrintConfig;
	private static Email_Print_Request_Config__c testEmailPrintConfig2;
	private static TestDataFactory theTestDataFactory;
	private static list<Passenger__c> lstPassanger;
	private static TOPS_FarewellEmailProcessor objFarewellProcessor;
	
	
	static void createTestData(){
		theTestDataFactory = new TestDataFactory();
        objFarewellProcessor = new TOPS_FarewellEmailProcessor();
         testEmailPrintConfig =  theTestDataFactory.createEmailPrintRequestConfig(
          'testFarewellEmail',
          'TOPS_FarewellEmailProcessor',
          'testFieldset',
      'testSubject',
      'testBody',
      'Farewell Email',
      'Email',
      true
    );
        testEmailPrintConfig2 =  theTestDataFactory.createEmailPrintRequestConfig(
          'testFarewellEmailOptOut',
          'TOPS_FarewellEmailProcessor',
          'testFieldset',
      'testSubject',
      'testBody',
      'Farewell Email - Opt Out',
      'Email',
      true
    );

    // Instantiating Test Account.
        Account acc = new Account(LastName = 'Account', FirstName = 'Test');
        acc.Email__c = 'nitish.bansal@appirio.com';
        acc.PersonEmail = 'nitish.bansal@appirio.com';
        acc.Farewell_Email_Salutation__c = 'Mr.';
        acc.Farewell_Email_Body__c = 'Test Farewell Email Body';
        acc.Farewell_Email_Signoff__c = 'Test Farewell Email Signoff';

    // Instantiating Test Brand Account.
    Account theTestBrand = new Account(
      Name = 'Test Brand',
      Website = 'http://www.website.com',
      RecordTypeId = ACCOUNT_BRAND_RECORD_TYPE_ID
    );

    // Inserting Test Accounts.
    insert new List<Account> {
      acc,
      theTestBrand
    };

    // Inserting Test Tour Series.
    Tour_Series__c theTestTourSeries = new Tour_Series__c(
      Brand_Welcome_Message__c = 'Test Brand Welcome Message',
      Brand_farewell_message__c = 'Test Brand farewell message'
    );
    insert theTestTourSeries;

    test_TourInstance = theTestDataFactory.createTourInstance('test nick', 'Abcd', false);
        test_TourInstance.Allocated_TD__c = acc.id;
        test_TourInstance.Tour_Series__c = theTestTourSeries.Id;
        test_TourInstance.Brand__c = theTestBrand.Id;
        test_TourInstance.Operating_Product_Code__c = 'AAE49023';
        insert test_TourInstance;

    Passenger__c p = null;
    lstPassanger = new list<Passenger__c>();
    for(integer i = 1;i < 10;i++) {
      p = theTestDataFactory.createPassenger('test pessanger' + String.valueOf(i), test_TourInstance.Id, false);
      p.Email_Share_Opt_In__c = true;
      p.Dietary_Requirements__c = 'I would prefer green meal';
       p.Email__c = 'test@tGmal.com';
       p.Farewell_Email_Send_Status__c = null;

      if( i== 1 || i == 4 || i == 7) {
        p.Actual_Room_Type__c = 'Double';
        p.Email_Share_Opt_In__c = false;
        p.Account__c = acc.id;
      }
      else if( i == 2 || i == 5 || i == 8) {
        p.Actual_Room_Type__c = 'Triple';
        p.Email_Share_Opt_In__c = true;
        p.Account__c = acc.id;
      }
      else if( i == 3 || i == 6 || i == 9) {
        p.Actual_Room_Type__c = 'Quad';
      }

      if(i == 1) {
        p.Passenger_Class__c = 'Tour Director';
      }
      if(i == 2) {
        p.Passenger_Class__c = 'Tour Director';
        p.Account__c = acc.id;
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
        // Create Test Data. 
    	createTestData();

        // Inserting Test Email Print Request.
        List<Email_Print_Request__c> listTestEmailPrintRequest = new List<Email_Print_Request__c>();
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
        theTestEmailPrintRequest.Data__c = theTestEmailPrintRequest.Data__c + TOPS_FarewellEmailProcessor.BrandMessage +
                                           TOPS_FarewellEmailProcessor.TDFW_Body + TOPS_FarewellEmailProcessor.TDFW_BrHashTag +
                                       TOPS_FarewellEmailProcessor.TDFW_BrName + TOPS_FarewellEmailProcessor.TDFW_BrRegMessage +
                                       TOPS_FarewellEmailProcessor.TDFW_BrRole + TOPS_FarewellEmailProcessor.TDFW_BrWebSite +
                                       TOPS_FarewellEmailProcessor.TDFW_FName + TOPS_FarewellEmailProcessor.TDFW_GoodBye +
                                       TOPS_FarewellEmailProcessor.TDFW_Salutation;
    listTestEmailPrintRequest.add(theTestEmailPrintRequest);

        theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'nitish.bansal@appirio.com',
      'New',
      'Welcome Email',
      false
    );
        theTestEmailPrintRequest.Related_Object_Id__c = test_TourInstance.Id;
        theTestEmailPrintRequest.Parameters__c = 'Lost in City Subject: Test email';
        theTestEmailPrintRequest.Preview__c = true;
        listTestEmailPrintRequest.add(theTestEmailPrintRequest);
        insert listTestEmailPrintRequest;

        TOPS_EmailWrapper testEmailWrapper = objFarewellProcessor.createEmailWrapper(listTestEmailPrintRequest[0], testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);

        testEmailWrapper = objFarewellProcessor.createEmailWrapper(listTestEmailPrintRequest[0], testEmailPrintConfig2);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);

        testEmailWrapper = objFarewellProcessor.createEmailWrapper(listTestEmailPrintRequest[1], testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);
    }
    
    
    
    
    /**
  * @description  This method V2 Status functionality.
  *
  * @param        void
  * @return       void
  */
    @isTest static void validteV2Status() {
        // Create Test Data. 
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
        List<Email_Print_Request__c> listTestEmailPrintRequest = new List<Email_Print_Request__c>();
    	Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      	'Test Email Subject',
      	'This is a test email print request data string.',
      	'nitish.bansal@appirio.com',
      	'New',
      	'Welcome Email',
      	false
    	);
        theTestEmailPrintRequest.Related_Object_Id__c = test_TourInstance.Id;
        theTestEmailPrintRequest.Parameters__c = 'V2 - Lost in City Subject: Test email';
        theTestEmailPrintRequest.Processing_Data__c = '{"modules": ["m1","m2","m3"],"modular": true,"booking": "New"}';
    	
        theTestEmailPrintRequest.Data__c = theTestEmailPrintRequest.Data__c + TOPS_FarewellEmailProcessor.BrandMessage +
                                           TOPS_FarewellEmailProcessor.TDFW_Body + TOPS_FarewellEmailProcessor.TDFW_BrHashTag +
                                       TOPS_FarewellEmailProcessor.TDFW_BrName + TOPS_FarewellEmailProcessor.TDFW_BrRegMessage +
                                       TOPS_FarewellEmailProcessor.TDFW_BrRole + TOPS_FarewellEmailProcessor.TDFW_BrWebSite +
                                       TOPS_FarewellEmailProcessor.TDFW_FName + TOPS_FarewellEmailProcessor.TDFW_GoodBye +
                                       TOPS_FarewellEmailProcessor.TDFW_Salutation;
    	listTestEmailPrintRequest.add(theTestEmailPrintRequest);

        theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      	'Test Email Subject',
      	'This is a test email print request data string.',
      	'nitish.bansal@appirio.com',
      	'New',
      	'Welcome Email',
      	false
    	);
        theTestEmailPrintRequest.Related_Object_Id__c = test_TourInstance.Id;
        theTestEmailPrintRequest.Parameters__c = 'V2 - Lost in City Subject: Test email';
        theTestEmailPrintRequest.Processing_Data__c = '{"modules": ["m1","m2","m3"],"modular": true,"booking": "New"}';
    	theTestEmailPrintRequest.Preview__c = true;
        listTestEmailPrintRequest.add(theTestEmailPrintRequest);
        insert listTestEmailPrintRequest;

        TOPS_EmailWrapper testEmailWrapper = objFarewellProcessor.createEmailWrapper(listTestEmailPrintRequest[0], testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);

        testEmailWrapper = objFarewellProcessor.createEmailWrapper(listTestEmailPrintRequest[0], testEmailPrintConfig2);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);

        testEmailWrapper = objFarewellProcessor.createEmailWrapper(listTestEmailPrintRequest[1], testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);
    }
}