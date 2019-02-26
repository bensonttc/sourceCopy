/**
 *  Test class for the Attachment Controller
 */
@isTest
private class TQAttachmentControllerTest {
	
	/*
	 *	Test the creation / deletion with attachments
	 */
	@isTest static void testAttachments() {
		// Create the data set
		Account account = TQTestUtils.createAccount('Testing', 'Attachments', 'acn@suppo.rt');
		insert account;
		System.debug('' + account);
		System.assertNotEquals(account.Id, null);
		
		Attachment attachment = TQTestUtils.createAttachment(account.Id);
		attachment.IsPrivate = false;
		insert attachment;
		System.debug('' + attachment);
		System.assertNotEquals(attachment.Id, null);

		Test.startTest();

		// Initiate the controller / page
		TQAttachmentController attachmentController = new TQAttachmentController();
		PageReference tpageRef = Page.TQAttachment;
        Test.setCurrentPage(tpageRef);

		// Share the attachment
		ApexPages.currentPage().getParameters().put('operation', 'share');
		ApexPages.currentPage().getParameters().put('recordID', account.Id);
		
		attachmentController.dispatch();
		//System.assertNotEquals(attachmentController.result, null);

		//// Delete the attachment
		ApexPages.currentPage().getParameters().put('operation', 'delete');
		attachmentController.dispatch();
		//System.assertEquals(attachmentController.result, 'O');

		Test.stopTest();
	}
	
	/*
	 *	Test the creation / deletion with Chatter feed items
	 */
	@isTest static void testFeedItems() {
		// Create the data set
		Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Testing', null, 'OpCode', 'DepCode', null, null, false);
		insert tourInstance;

		FeedItem feedItem = TQTestUtils.createFeedItem(tourInstance.Id);
		insert feedItem;

		Test.startTest();

		// Initiate the controller / page
		TQAttachmentController attachmentController = new TQAttachmentController();
		PageReference tpageRef = Page.TQAttachment;
        Test.setCurrentPage(tpageRef);

		// Share the attachment
		ApexPages.currentPage().getParameters().put('operation', 'share');
		ApexPages.currentPage().getParameters().put('recordID', feedItem.Id);
		
		attachmentController.dispatch();
		System.assertNotEquals(attachmentController.result, null);

		// Delete the attachment
		ApexPages.currentPage().getParameters().put('operation', 'delete');
		attachmentController.dispatch();
		System.assertEquals(attachmentController.result, '{"result":"0"}');

		Test.stopTest();
	}
	
	static testMethod void testSharedMoment(){
	  	String accountEmail='test@donotexists.com', accountName = 'Pablo', accountSurname = 'Escabar';
	  	
	    Account personAccount = TQTestUtils.createAccount(accountName, accountSurname, accountEmail);
	    insert personAccount;
	    
	    User communityUser = TQTestUtils.createUser(personAccount.Id, accountName, accountSurname, accountEmail, accountEmail);
	  	communityUser.Show_My_Email_Address__c = false;
	  	communityUser.Email__c = accountEmail;
	  	insert communityUser;

	  	
	  	Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', null, 'opeProCode123', 'departureCode234',
	                					Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
	    insert tourInstance;    
	    
	    Passenger__c newPassenger = new Passenger__c();
	    newPassenger.Account__c = personAccount.Id;
	    newPassenger.Tour_Instance__c = tourInstance.Id;
	    newPassenger.User__c = communityUser.Id;
	    newPassenger.Passenger_External_Id__c = 'TESTEXTERNALID';
	    insert newPassenger;
	    
	    Moment__c testMoment = new Moment__c();
	    testMoment.Body__c = 'Hello World';
	    testMoment.Passenger__c = newPassenger.Id;
	    insert testMoment;
	    
	    PageReference testPage = Page.TQShare;
	    testPage.getParameters().put('recordID', testMoment.Id);
	    
	    Test.setCurrentPageReference(testPage);
	  	Test.startTest();
	  	TQAttachmentController controller = new TQAttachmentController();
	  	controller.initSharePage();
	  	Test.stopTest();
	  	
	  	System.assertEquals('Hello World', controller.attachmentInfo.text);
	  	System.assertEquals(UserInfo.getName(), controller.attachmentInfo.userName);
	}
	
		
	static testMethod void testSharedAttachment(){
	  	String accountEmail='test@donotexists.com', accountName = 'Pablo', accountSurname = 'Escabar';
	  	
	    Account personAccount = TQTestUtils.createAccount(accountName, accountSurname, accountEmail);
	    insert personAccount;
	    
	    User communityUser = TQTestUtils.createUser(personAccount.Id, accountName, accountSurname, accountEmail, accountEmail);
	  	communityUser.Show_My_Email_Address__c = false;
	  	communityUser.Email__c = accountEmail;
	  	insert communityUser;

	  	
	  	Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', null, 'opeProCode123', 'departureCode234',
	                					Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
	    insert tourInstance;    
	    
	    Passenger__c newPassenger = new Passenger__c();
	    newPassenger.Account__c = personAccount.Id;
	    newPassenger.Tour_Instance__c = tourInstance.Id;
	    newPassenger.User__c = communityUser.Id;
	    newPassenger.Passenger_External_Id__c = 'TESTEXTERNALID';
	    insert newPassenger;
	    
	    Moment__c testMoment = new Moment__c();
	    testMoment.Body__c = 'Hello World';
	    testMoment.Passenger__c = newPassenger.Id;
	    insert testMoment;
	    
	   	Attachment attachment = TQTestUtils.createAttachment(testMoment.Id);
		attachment.IsPrivate = false;
		insert attachment;
	    
	    
	    PageReference testPage = Page.TQShare;
	    testPage.getParameters().put('recordID', testMoment.Id);
	    
	    Test.setCurrentPageReference(testPage);
	  	Test.startTest();
	  	TQAttachmentController controller = new TQAttachmentController();
	  	controller.attachmentID = null;
	  	controller.initSharePage();
	  	Test.stopTest();
	  	
	  	System.assertEquals('Hello World', controller.attachmentInfo.text);
	  	System.assertEquals(UserInfo.getName(), controller.attachmentInfo.userName);
	  	System.assertNotEquals(null, controller.attachmentBase64);
	}
	
	static testMethod void testEmptyOperation(){
		PageReference tpageRef = Page.TQAttachment;
        Test.setCurrentPage(tpageRef);

		// Share the attachment
		ApexPages.currentPage().getParameters().put('operation', 'emptyOperation');
		ApexPages.currentPage().getParameters().put('recordID', null);
		
	  	TQAttachmentController controller = new TQAttachmentController();
		PageReference resultPageReference = controller.dispatch();
		System.assertEquals(null, resultPageReference);		
	}
	
		
	static testMethod void testWrongRecordId(){
		PageReference tpageRef = Page.TQAttachment;
        Test.setCurrentPage(tpageRef);

		// Share the attachment
		ApexPages.currentPage().getParameters().put('operation', 'share');
		ApexPages.currentPage().getParameters().put('recordID', '$$$WRONG_ID$$$$');
		
	  	TQAttachmentController controller = new TQAttachmentController();
		PageReference resultPageReference = controller.dispatch();
		System.assertEquals(null, resultPageReference);		
	}
	
	static testMethod void testShareError(){
		PageReference testPage = Page.TQShare;
	    testPage.getParameters().put('recordID', '$$$WRONG_ID$$$$');		
		
		Test.setCurrentPageReference(testPage);
	  	TQAttachmentController controller = new TQAttachmentController();
		PageReference resultPageReference = controller.initSharePage();
		System.assertEquals(null, resultPageReference);		
		
	}
}