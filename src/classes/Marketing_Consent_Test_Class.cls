@isTest (seeAllData = false)
private class Marketing_Consent_Test_Class
{
	static void CreateRecords()
	{
		//get Account record Types
		map<string, id> mapRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
			mapRT.put(RT.DeveloperName, RT.id);
		}

		//get Account record Types
		map<string, id> BookRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking__c']){
			BookRT.put(RT.DeveloperName, RT.id);
		}

		Account Cust = new Account (FirstName = 'Customer', LastName = 'Marketing Consent', RecordTypeID = mapRT.get('Customer'));
		insert Cust;

		Account Brand = new Account (Name = 'Brand', RecordTypeID = mapRT.get('Brand'));
		insert Brand;

		Account BU = new Account (Name = 'Business Unit', recordTYpeiD = mapRT.get('Selling_Company'), parentID = Brand.ID, External_ID__C = 'BU');
		insert BU;

		Booking__c Book = new Booking__c(Selling_Company__c = BU.ID, Original_booking_Date__c = date.today(), name = '1', RecordTypeID = BookRT.get('Booking'));
		Insert Book;

		Booking__c Book2 = new Booking__c(Selling_Company__c = BU.ID, Original_booking_Date__c = date.today().addDays(1), name = '2', RecordTypeID = BookRT.get('Booking'));
		Insert Book2;

		MDM_Account_Creation_Setting__c Creation = new MDM_Account_Creation_Setting__c(Active__c = true, Enable_Preference_Management__C = true, Name = 'Active');
	    insert Creation;

	}

	@isTest
	static void TestCreatingMC()
	{
		//Create Records
		CreateRecords();

		//Get Customer
		Account Cust = [Select ID from Account where FirstName = 'Customer'];
		test.startTest();

		//---Request---
		//Create Request
		Request__c Req = new Request__c(Date_Ordered__c = date.today(), customer__c = Cust.ID, Selling_Company__c = 'BU', Would_Not_Like_Info__c = false, Request_Type__c = 'BRQ');
		Insert Req;
		TriggerHandlerV2.clearExecutedObjects();
		Update Req;
		TriggerHandlerV2.clearExecutedObjects();

		//Check the MC record has been created
		list<Marketing_Consent__c> MC1 = [Select ID from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID AND Request__c = :Req.ID];
		system.debug('Size of MC = '+ MC1.size());
		system.assert(MC1.size() == 1);

		//ID ActiveMC = 

		//check that the Req is connected to the MC
		Request__c ReqUpdate = [Select id, Marketing_consent__c from Request__c where id = :Req.ID];
		system.assert(ReqUpdate.Marketing_Consent__c != null);
		system.assert(ReqUpdate.Marketing_Consent__c == MC1[0].ID);


		//---Booking Passenger---
		//Create Booking Pax with later date
		Booking__c Book = [select ID from Booking__c where name = '1'];
		
		//get Account record Types
		map<string, id> PaxRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking_Passenger__c']){
			PaxRT.put(RT.DeveloperName, RT.id);
		}

		Booking_Passenger__c Pax = new Booking_Passenger__c(RecordTypeID = PaxRT.get('Booking_Passengers'), Booking__c = Book.ID, name = '1', Customer__c = Cust.ID);
		insert Pax;
		TriggerHandlerV2.clearExecutedObjects();
		update Pax;
		TriggerHandlerV2.clearExecutedObjects();

		//Check the Request remains active - because the Pax is assumed opt in
		list<Marketing_Consent__c> MC2 = [Select ID from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID AND Request__c = :Req.ID];
		system.assert(MC2.size() == 1);

		//---Questionnaire---

		//Create Questionnaire with earlier date
		Questionnaire__c Quest = new Questionnaire__c(Selling_Company_Code__c = 'BU', name = '1', Customer__c = Cust.ID,Comms__c = 'Y', Departure_Date__c = date.today().addDays(-1));
		insert Quest;
		TriggerHandlerV2.clearExecutedObjects();
		update Quest;
		TriggerHandlerV2.clearExecutedObjects();

		//Check Request is still Active
		list<Marketing_Consent__c> MC4 = [Select ID from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID AND Request__c = :Req.ID];
		system.assert(MC4.size() == 1);

		//Create Questionnaire with Later date
		Questionnaire__c Quest2 = new Questionnaire__c(Selling_Company_Code__c = 'BU', name = '2', Customer__c = Cust.ID,Comms__c = 'N', Departure_Date__c = date.today().addDays(+5));
		insert Quest2;
		TriggerHandlerV2.clearExecutedObjects();
		update Quest2;
		TriggerHandlerV2.clearExecutedObjects();

		//Check the Questionnaire is Active
		list<Marketing_Consent__c> MC5 = [Select ID, Opt_In__c  from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID AND Questionnaire__c = :Quest2.ID];
		system.assert(MC5.size() == 1);

		//Edit MC directly
		Marketing_Consent__c ActiveMC = MC5[0];
		ActiveMC.Opt_In__c = !ActiveMC.Opt_In__c;
		Update ActiveMC;
		TriggerHandlerV2.clearExecutedObjects();


		test.stopTest();

		//Check that the 1st Questionnaire has been archived
		list<Marketing_Consent__c> MC3 = [Select ID from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID AND Archived_Questionnaire__c = :Quest.ID];
		system.debug(loggingLevel.Error, 'TEST: Size of Marketing Consent = '+ MC3.size());
		system.assert(MC3.size() == 1);

		//Check the Request has been archived
		list<Marketing_Consent__c> MC7 = [Select ID from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID AND Request_Archived__c = :Req.ID];
		system.assert(MC7.size() == 1);

		//Check the Second Questionnaire has been archived
		list<Marketing_Consent__c> MC6 = [Select ID from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID AND Archived_Questionnaire__c = :Quest2.ID];
		system.assert(MC6.size() == 1);

	}


	@isTest
	static void TestCreating2Pax()
	{
		//Create Records
		CreateRecords();

		//Get Customer
		Account Cust = [Select ID from Account where FirstName = 'Customer'];
		test.startTest();

		//---Booking Passenger---
		//Create Booking Pax with later date
		Booking__c Book = [select ID from Booking__c where name = '1'];
		
		//get Account record Types
		map<string, id> PaxRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking_Passenger__c']){
			PaxRT.put(RT.DeveloperName, RT.id);
		}

		Booking_Passenger__c Pax = new Booking_Passenger__c(RecordTypeID = PaxRT.get('Booking_Passengers'), Booking__c = Book.ID, name = '1', Customer__c = Cust.ID);
		insert Pax;
		Update Pax;

		Booking__c Book2 = [select ID from Booking__c where name = '2'];

		Booking_Passenger__c Pax2 = new Booking_Passenger__c(RecordTypeID = PaxRT.get('Booking_Passengers'), Booking__c = Book2.ID, name = '2', Customer__c = Cust.ID);
		insert Pax2;
		Update Pax2;

		test.stopTest();
	}

	/*@isTest
	static void TestMultipleRequest()
	{
		//Create Records
		CreateRecords();

		//Get Customer
		Account Cust = [Select ID from Account where FirstName = 'Customer'];
		test.startTest();

		//---Request---
		//Create 200 requests
		list<Request__c> ReqList = new list<Request__c>();
		integer i;
		for(i = 1; i==200; i++){
			Request__c Req = new Request__c(Date_Ordered__c = date.today().addDays(+i), customer__c = Cust.ID, Selling_Company__c = 'BU', Would_Not_Like_Info__c = false, Request_Type__c = 'BRQ');	
			ReqList.add(Req);
		}
		
		Insert ReqList;
		TriggerHandlerV2.clearExecutedObjects();
		Update ReqList;
		TriggerHandlerV2.clearExecutedObjects();

		//Check 1 MC is created
		list<Marketing_Consent__c> MC1 = [Select ID from Marketing_Consent__c where Customer_or_Prospect__c = :Cust.ID];
		system.debug('Size of MC group test = '+ MC1.size());
		system.assert(MC1.size() == 1);
		ID MCID = MC1[0].ID;

		//Check that all the requests are attached to the MC
		list<Request__c> ReqList2 = [Select id, Marketing_consent__c from Request__c];
		for(Request__c Req: ReqList2){
			system.assert(Req.Marketing_consent__c == MCID);
		}

		test.stopTest();

	}
	*/
}