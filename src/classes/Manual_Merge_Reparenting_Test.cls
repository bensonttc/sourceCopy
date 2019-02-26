@isTest
private class Manual_Merge_Reparenting_Test{

	public static void createTestData(){
		
		//----INSERT test user to share records to----
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
 
			list<Profile> Profiles = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

			User usr1 = new User(FirstName = 'User1', LastName = String.valueof(DateTime.Now()), Username='CPtestUser1@cloudperspective.co.uk', Email='CPtestUser1@cloudperspective.co.uk', Alias='testUsr1', CommunityNickname='CPtestUser1', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_GB', EmailEncodingKey = 'ISO-8859-1', ProfileId = Profiles[0].Id, LanguageLocaleKey = 'en_US');
			Insert usr1;
			User usr2 = new User(FirstName = 'User2', LastName = String.valueof(DateTime.Now()), Username='CPtestUser2@cloudperspective.co.uk', Email='CPtestUser2@cloudperspective.co.uk', Alias='testUsr2', CommunityNickname='CPtestUser2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_GB', EmailEncodingKey = 'ISO-8859-1', ProfileId = Profiles[0].Id, LanguageLocaleKey = 'en_US');
			Insert usr2;
		}
		User usr1 = [SELECT Id FROM User WHERE Username='CPtestUser1@cloudperspective.co.uk' LIMIT 1];
		User usr2 = [SELECT Id FROM User WHERE Username='CPtestUser2@cloudperspective.co.uk' LIMIT 1];
		//--------------------------------------------

		//------Get Account record Types------
		map<string, id> mapRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
			mapRT.put(RT.DeveloperName, RT.id);
		}
		//------------------------------------

		//------Get Marketing Consent record Types------
		map<string, id> mapMCRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Marketing_Consent__c']){
			mapMCRT.put(RT.DeveloperName, RT.id);
		}
		//----------------------------------------------

		//------Get Booking record Types------
        map<string, id> BookRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking__c']){
            BookRT.put(RT.DeveloperName, RT.id);
        }
        //------------------------------------

		//--------------INSERT Accounts to be duplicates-------------------
		Account accA = new Account(FirstName= 'Account', LastName = String.valueof(DateTime.Now()), PersonEmail='test@cloudperspective.co.uk', RecordTypeID = mapRT.get('Customer'));
		Insert accA;
		Account accB = new Account(FirstName= 'Account', LastName = String.valueof(DateTime.Now()), PersonEmail='test@cloudperspective.co.uk', RecordTypeID = mapRT.get('Customer'));
		Insert accB;
		//-----------------------------------------------------------------

		//--------------INSERT Accounts to be Selling Companies (for Marketing Consent)---------------
        Account Brand = new Account (Name = 'Brand', RecordTypeID = mapRT.get('Brand'));
        insert Brand;

		Account BU1 = new Account(Name = 'BU1', CurrencyIsoCode = 'GBP', RecordTypeId = mapRT.get('Selling_Company'), parentID = Brand.ID);
		Insert BU1;
		Account BU2 = new Account(Name = 'BU2', CurrencyIsoCode = 'GBP', RecordTypeId = mapRT.get('Selling_Company'), parentID = Brand.ID);
		Insert BU2;
		//--------------------------------------------------------------------------------------------

		//------INSERT Manual Account Sharing Rules------
		AccountShare accShare1 = new AccountShare(
			AccountAccessLevel = 'Edit',
			AccountId = accA.Id,
			OpportunityAccessLevel = 'Edit',
			//RowCause = 'Manual',
			UserOrGroupId = usr1.ID
		);
		Insert accShare1;

		AccountShare accShare2 = new AccountShare(
			AccountAccessLevel = 'Edit',
			AccountId = accB.Id,
			OpportunityAccessLevel = 'Edit',
			//RowCause = 'Manual',
			UserOrGroupId = usr2.Id
		);
		Insert accShare2;
		//-----------------------------------------------

 		//----INSERT Bookings for Marketing Consent-----
		Booking__c ConfirmedBook1 = new Booking__c(Selling_Company__c = BU1.ID, Original_booking_Date__c = date.today().addDays(1), Name = '1', RecordTypeID = BookRT.get('Booking'), status__c = 'CO', lead_passenger__C = accA.id);
        Insert ConfirmedBook1;
        Booking__c ConfirmedBook2 = new Booking__c(Selling_Company__c = BU1.ID, Original_booking_Date__c = date.today().addDays(2), Name = '2', RecordTypeID = BookRT.get('Booking'), status__c = 'CO', lead_passenger__C = accB.id);
        Insert ConfirmedBook2;
        Booking__c ConfirmedBook3 = new Booking__c(Selling_Company__c = BU2.ID, Original_booking_Date__c = date.today().addDays(3), Name = '3', RecordTypeID = BookRT.get('Booking'), status__c = 'CO', lead_passenger__C = accB.id);
        Insert ConfirmedBook3;
		//----------------------------------------------

		//----------Booking Passenger----------
        Booking_Passenger__c PaxCustomer1 = new Booking_Passenger__c(Booking__c = ConfirmedBook1.id, name = 'test1', Address_1__c = 'Test Street', Country__c = 'UK', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com', customer__c = accA.id);
        insert PaxCustomer1;
        Booking_Passenger__c PaxCustomer2 = new Booking_Passenger__c(Booking__c = ConfirmedBook2.id, name = 'test2', Address_1__c = 'Test Street', Country__c = 'UK', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com', customer__c = accB.id);
        insert PaxCustomer2;
		Booking_Passenger__c PaxCustomer3 = new Booking_Passenger__c(Booking__c = ConfirmedBook3.id, name = 'test3', Address_1__c = 'Test Street', Country__c = 'UK', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com', customer__c = accB.id);
        insert PaxCustomer3;
		//-------------------------------------

		for (Marketing_Consent__c MCrec : [SELECT Id, Customer_or_Prospect__r.Name, Selling_Company__r.Name, External_ID__c FROM Marketing_Consent__c LIMIT 10]){
			System.debug('DW--MC--Customer_or_Prospect='+MCrec.Customer_or_Prospect__r.Name);
			System.debug('DW--MC--Selling_Company='+MCrec.Selling_Company__r.Name);
			System.debug('DW--MC--External_ID='+MCrec.External_ID__c);
		}

		//---INSERT Marketing Consents---
		list<Marketing_Consent__c> mc_list = new list<Marketing_Consent__c>();
    
		mc_list.add(new Marketing_Consent__c(
		    Customer_or_Prospect__c=accA.Id,
		    Assumed_Opt_in__c=FALSE,
		    Opt_In__c=TRUE,
		    Customer_Active__c=accA.Id,
		    Date_Entered__c=system.today(),
		    Selling_Company__c=BU1.Id,
		    External_ID__c=BU1.Id+'#'+accA.Id,
		    Do_Not_Archive_On_Save__c=TRUE,
		    RecordTypeId=mapMCRT.get('ActivePreference'),
		    Source__c = 'Booking',
		    Booking_Passenger__c = PaxCustomer1.Id
		));

		mc_list.add(new Marketing_Consent__c(
		    Customer_or_Prospect__c=accB.Id,
		    Assumed_Opt_in__c=FALSE,
		    Opt_In__c=TRUE,
		    Customer_Active__c=accB.Id,
		    Date_Entered__c=system.today(),
		    Selling_Company__c=BU1.Id,
		    External_ID__c=BU1.Id+'#'+accB.Id,
		    Do_Not_Archive_On_Save__c=TRUE,
		    RecordTypeId=mapMCRT.get('ActivePreference'),
		    Source__c = 'Booking',
		    Booking_Passenger__c = PaxCustomer2.Id
		));

		mc_list.add(new Marketing_Consent__c(
		    Customer_or_Prospect__c=accB.Id,
		    Assumed_Opt_in__c=FALSE,
		    Opt_In__c=TRUE,
		    Customer_Active__c=accB.Id,
		    Date_Entered__c=system.today(),
		    Selling_Company__c=BU2.Id,
		    External_ID__c=BU2.Id+'#'+accB.Id,
		    Do_Not_Archive_On_Save__c=TRUE,
		    RecordTypeId=mapMCRT.get('ActivePreference'),
		    Source__c = 'Booking',
		    Booking_Passenger__c = PaxCustomer3.Id
		));
		Insert mc_list;
		//-------------------------------

	}

	@isTest
	static void mergeMarketingConsent(){

		//Create test data
		createTestData();

		//Get duplicate accounts
		list<Account> dupAccts = [SELECT Id, FirstName FROM Account WHERE FirstName = 'Account' LIMIT 2];
		

		test.startTest();
		// Merge the Duplicates
		merge dupAccts[0] dupAccts[1];
		test.stopTest();


		//Get master account
		list<Account> masterAcct = [SELECT Id, FirstName, External_ID__c FROM Account WHERE FirstName = 'Account' LIMIT 2];
		String externalID_query = '%'+masterAcct[0].Id;

		//Check Customer now has 2 active Marketing Consent Records (with valid external Ids - others will be deleted post merge)
		list<Marketing_Consent__c> activeMCs = [SELECT Id,Selling_Company__c FROM Marketing_Consent__c WHERE Customer_or_Prospect__c=:masterAcct[0].Id AND External_ID__c LIKE :externalID_query AND Archived__c = false];
		//list<Marketing_Consent__c> activeMCs = [SELECT Id,Selling_Company__c FROM Marketing_Consent__c WHERE Customer_or_Prospect__c=:masterAcct[0].Id AND Archived__c = false];
		System.debug('--->'+activeMCs.size());
		System.assert(activeMCs.size()==2);

		//Confirm the Marketing Consent Records are for different Selling Companies
		System.assert(activeMCs[0].Selling_Company__c!=activeMCs[1].Selling_Company__c);

	}

	@isTest
	static void mergeManualShare(){

		//Create test data
		createTestData();

		User testUser1 = [SELECT Id FROM User WHERE Username = 'CPtestUser1@cloudperspective.co.uk' LIMIT 1];
		User testUser2 = [SELECT Id FROM User WHERE Username = 'CPtestUser2@cloudperspective.co.uk' LIMIT 1];
		Boolean usr1HasAccess = false;
		Boolean usr2HasAccess = false;

		//Get duplicate accounts
		list<Account> dupAccts = [SELECT Id, FirstName FROM Account WHERE FirstName = 'Account' LIMIT 2];
		
		test.startTest();
		// Merge the Duplicates
		merge dupAccts[0] dupAccts[1];
		test.stopTest();

		//Get master account
		list<Account> masterAcct = [SELECT Id, FirstName FROM Account WHERE FirstName = 'Account' LIMIT 2];

		//Check there are now 2 manual sharing rules for the Master Account
		list<AccountShare> manualShares = [SELECT AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,OpportunityAccessLevel,RowCause,UserOrGroupId FROM AccountShare WHERE RowCause = 'Manual' AND AccountId=:masterAcct[0].Id];
		// **********************************************************
		// ** Marketing consent being directly upserted in         ** 
		// ** Marketing_Consent_Delete class. Not being handled    **
		// ** the same as in practice due to qeueable test         **
		// ** limits.           								   **
		// **********************************************************
		System.assert(manualShares.size()==2);


		//------Check both Users have access------
		for (AccountShare x: manualShares){
			if (x.UserOrGroupId == testUser1.Id) usr1HasAccess = true;
			if (x.UserOrGroupId == testUser2.Id) usr2HasAccess = true;
		}
		System.assert(usr1HasAccess);
		System.assert(usr2HasAccess);
		//----------------------------------------
	}
}