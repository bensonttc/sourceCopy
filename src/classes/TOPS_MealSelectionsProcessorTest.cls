/*
Test Class Name 		: TOPS_MealSelectionsProcessorTest
For Apex Class 			: TOPS_MealSelectionsProcessor
Created By 				: Nitish Bansal 
Date 					: 02/15/2016 
Purpose 				: T-467679
*/

@isTest
private class TOPS_MealSelectionsProcessorTest
{
	@isTest
	static void validteClassFunctionality()
	{
		// Create test data
		TestDataFactory theTestDataFactory = new TestDataFactory();
		TOPS_MealSelectionsProcessor objMealProcessor = new TOPS_MealSelectionsProcessor();

		Email_Print_Request_Config__c testEmailPrintConfig =  theTestDataFactory.createEmailPrintRequestConfig('testMealSelectionsEmail','TOPS_MealSelectionsProcessor','testFieldset',
																'testSubject','testBody','Meal Selections Email','Email',true);

		Account acc = new Account( LastName='myTest', FirstName='account');
		acc.Email__c = 'nitish.bansal@appirio.com';
		acc.PersonEmail = 'nitish.bansal@appirio.com';
		acc.Known_As__pc = 'Nick';
		acc.Crew_Contact_Number_1__c = '8908765420';
        insert acc;
        Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test nick','Abcd', false); 
		test_TourInstance.Allocated_TD__c = acc.id;
		insert test_TourInstance;
        list<Passenger__c> lstPassanger = new list<Passenger__c>();
        for(integer i =1; i< 10;i++){
	       	Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+String.valueOf(i),test_TourInstance.Id,false);
	       	p.Email_Share_Opt_In__c = true;
	       	p.Dietary_Requirements__c = 'I would prefer green meal' + String.valueOf(i); 
	       	p.First_Name__c = 'First name' + String.valueOf(i);
	       	p.Family_Name__c = 'Family Name' + String.valueOf(i);
	       	if( i== 1 || i == 4 || i == 7){
	       	 p.Actual_Room_Type__c = 'Double';
	       	 p.Email_Share_Opt_In__c = false;
	       	 p.Account__c = acc.id;
	       	}
	       	else if( i == 2 || i == 5 || i == 8){
	       	 p.Actual_Room_Type__c = 'Triple';
	       	 p.Email_Share_Opt_In__c = true;
	       	 p.Account__c = acc.id;
	       	}
	       	else if( i == 3 || i == 6 || i == 9)
	       	 p.Actual_Room_Type__c = 'Quad';
	       	 
	       	if(i == 1){
	       		p.Passenger_Class__c = 'Tour Director';
	       		
	       	}
	       	if(i == 2){
	       		p.Passenger_Class__c = 'Tour Director';
	       		p.Account__c = acc.id;
	       	}
	       	lstPassanger.add(p);
        } 
        insert lstPassanger;

        List<Optional__c> listOptional = new List<Optional__c>();
        Optional__c op;
        for(Integer i = 1; i <= 1 ; i++){
        	op = theTestDataFactory.createOptional('Test optional'+String.valueOf(i), false);
        		op.Starter_Text_1__c = 'Starter1';
        		op.Dessert_Text_1__c = 'Dessert1';
        		op.Main_Text_1__c = 'Main Course 1';
        		op.Soup_Text_1__c = 'Soup1';
        		op.Starter_Text_2__c = 'Starter2';
        		op.Dessert_Text_2__c = 'Dessert2';
        		op.Main_Text_2__c = 'Main Course 2';
        		op.Soup_Text_2__c = 'Soup2';
        		op.Starter_Text_3__c = 'Starter3';
        		op.Dessert_Text_3__c = 'Dessert3';
        		op.Main_Text_3__c = 'Main Course 3';
        		op.Starter_Text_4__c = 'Starter4';
        		op.Dessert_Text_4__c = 'Dessert4';
        		op.Main_Text_4__c = 'Main Course 4';
        		op.Starter_Text_5__c = 'Starter5';
        		op.Dessert_Text_5__c = 'Dessert5';
        		op.Main_Text_5__c = 'Main Course 5';
        	listOptional.add(op);
        }
        insert listOptional;

        Tour_Optional__c tourOptional = theTestDataFactory.createTourOptional('Test Tour Optional', test_TourInstance.Id, listOptional[0].Id, false);
        tourOptional.Supplier__c = acc.Id;
        tourOptional.Time__c = ''+System.now();
        tourOptional.Supplier_Menu__c = op.Id;
        insert tourOptional;

        List < Passenger_Optional__c > passengerOptoinalList = new List < Passenger_Optional__c > ();
        Passenger_Optional__c passOpt;
        for(Integer i = 1; i < 10; i++){
        	passOpt = new Passenger_Optional__c();
        	passOpt.Passenger__c = lstPassanger.get(i-1).Id;
        	passOpt.Tour_Optional__c = tourOptional.Id;
        	if(i == 1 || i == 9){
        		passOpt.Selected_Soup__c = 'Soup1';
        		passOpt.Selected_Main__c = 'Main Course 1';
        		passOpt.Selected_Dessert__c = 'Dessert1';
        		passOpt.Selected_Starter__c = 'Starter1';
        	} else if(i == 2 || i == 8){
        		passOpt.Selected_Soup__c = 'Soup2';
        		passOpt.Selected_Main__c = 'Main Course 2';
        		passOpt.Selected_Dessert__c = 'Dessert2';
        		passOpt.Selected_Starter__c = 'Starter2';
        	} else if(i == 3 || i == 7){
        		passOpt.Selected_Soup__c = 'Soup3';
        		passOpt.Selected_Main__c = 'Main Course 3';
        		passOpt.Selected_Dessert__c = 'Dessert3';
        		passOpt.Selected_Starter__c = 'Starter3';
        	} else if(i == 4 || i == 6){
        		passOpt.Selected_Soup__c = 'Soup4';
        		passOpt.Selected_Main__c = 'Main Course 4';
        		passOpt.Selected_Dessert__c = 'Dessert4';
        		passOpt.Selected_Starter__c = 'Starter4';
        	} else if(i == 5){
        		passOpt.Selected_Soup__c = 'Soup5';
        		passOpt.Selected_Main__c = 'Main Course 5';
        		passOpt.Selected_Dessert__c = 'Dessert5';
        		passOpt.Selected_Starter__c = 'Starter5';
        	}
        	passengerOptoinalList.add(passOpt);
		}
    	insert passengerOptoinalList;

    	// Inserting Test Email Print Request.
		List<Email_Print_Request__c> listTestEmailPrintRequest = new List<Email_Print_Request__c>();
    	Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
        'Test Email Subject',
        'This is a test email print request data string.',
        'nitish.bansal@appirio.com',
        'New',
        'Meal Selections Email',
        false
        );
		theTestEmailPrintRequest.Related_Object_Id__c = tourOptional.Id;
        theTestEmailPrintRequest.Additional_Emails__c = '{"cc":"jai@test.com,jai@success.com"}'; // Added by Jai Gupta S-568616 
		listTestEmailPrintRequest.add(theTestEmailPrintRequest);

		theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
        'Test Email Subject',
        'This is a test email print request data string.',
        'nitish.bansal@appirio.com',
        'New',
        'Meal Selections Email',
        false
        );
		theTestEmailPrintRequest.Related_Object_Id__c = tourOptional.Id;
		theTestEmailPrintRequest.Preview__c = true;
		listTestEmailPrintRequest.add(theTestEmailPrintRequest);
		insert listTestEmailPrintRequest;

		TOPS_EmailWrapper testEmailWrapper = objMealProcessor.createEmailWrapper(listTestEmailPrintRequest[0],testEmailPrintConfig);
		//system.assertEquals('Meal Selections Email', testEmailWrapper.emailSubject);
		testEmailWrapper = objMealProcessor.createEmailWrapper(listTestEmailPrintRequest[1],testEmailPrintConfig);
		//system.assertEquals('Meal Selections Email', testEmailWrapper.emailSubject);
	}
}