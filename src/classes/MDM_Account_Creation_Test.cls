@isTest (seeAllData = false)
private class MDM_Account_Creation_Test
{

	public static void insertSettings(){
		//Create the Account creation 
		MDM_Account_Creation_Setting__c Creation = new MDM_Account_Creation_Setting__c(name = 'Active', Active__c = true, Enable_Account_Creation__c = true, Enable_Auto_match_Beans__c = true, Enable_Logging__c = true, Enable_Synch__c = true, Update_Accounts_on_Field_Change_only__c = true);
		insert Creation;

		list<MDM_Custom_Synchronisation_settings__c> listSynch = new list<MDM_Custom_Synchronisation_settings__c>();

		MDM_Custom_Synchronisation_settings__c BusField = new MDM_Custom_Synchronisation_settings__c(name = '1', Bean_Field__c = 'DSE__DS_Company__c', Object__c = 'BusinessAccount', Object_Field__c = 'Name');
		listSynch.add(BusField);

		MDM_Custom_Synchronisation_settings__c BusField2 = new MDM_Custom_Synchronisation_settings__c(name = '2', Bean_Field__c = 'DSE__DS_Custom_Field_4__c', Object__c = 'PersonAccount', Object_Field__c = 'lastName');
		listSynch.add(BusField2);

		MDM_Custom_Synchronisation_settings__c BusField3 = new MDM_Custom_Synchronisation_settings__c(name = '3', Bean_Field__c = 'DSE__DS_Custom_Field_3__c', Object__c = 'PersonAccount', Object_Field__c = 'firstName');
		listSynch.add(BusField3);

		MDM_Custom_Synchronisation_settings__c BusField4 = new MDM_Custom_Synchronisation_settings__c(name = '4', Bean_Field__c = 'ERROR', Object__c = 'PersonAccount', Object_Field__c = 'firstName');
		listSynch.add(BusField4);

		MDM_Custom_Synchronisation_settings__c BusField5 = new MDM_Custom_Synchronisation_settings__c(name = '5', Bean_Field__c = 'DSE__DS_Company__c', Object__c = 'PersonAccount', Object_Field__c = 'ERROR');
		listSynch.add(BusField5);

		insert listSynch;

		//insert sources
		DSE__DS_Sources__c source = new DSE__DS_Sources__c(name = 'test');
		insert source;

		//enable cloud MDM
		DSE__DS_Settings__c setup = new DSE__DS_Settings__c(name = 'Active', DSE__DS_Setup_Completed__c = true, DSE__DS_Standardize_Billing_Country__c = false, DSE__DS_Validate_Billing_Country__c = false);
		insert setup;

		//Diable Account Trigger
		DSE.API_AccountTriggerHandler API1 = new DSE.API_AccountTriggerHandler();
		API1.disableCloudMDMTrigger();

		//License MDM
		DSE.API_LicenseManager.setFeature('Production',true,'BLO4v1xz27');
		DSE.API_LicenseManager.setFeature('Sandbox',true,'BLO4v1xz27');
		DSE.API_LicenseManager.setFeature('FullCopy',true,'BLO4v1xz27'); 
	}


	@isTest
	static void CreateCustomer()
	{
		insertSettings();

		//get Account record Types
		map<string, id> mapRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
			mapRT.put(RT.DeveloperName, RT.id);
		}

		//Create the Account creation 
		MDM_Account_Creation_Setting__c Creation = MDM_Account_Creation_Setting__c.getValues('Active');
		if(Creation != null){
			delete Creation;
		}
		Creation = new MDM_Account_Creation_Setting__c(name = 'Active', Active__c = true, Enable_Account_Creation__c = true, Enable_Auto_match_Beans__c = true, Enable_Logging__c = true, Enable_Synch__c = true, Update_Accounts_on_Field_Change_only__c = true);
		insert Creation;
		
		test.startTest();
		//Create Customer
		DSE__DS_Master_Bean__c MB = new DSE__DS_Master_Bean__c(DSE__DS_Custom_Field_3__c = 'FirstCustomer', DSE__DS_Custom_Field_4__c = 'Last', DSE__DS_Company__c = 'Company', DSE__DS_Record_Type_Name__c = 'Customer');
		insert MB;

		MB.Create_Update_Account__c = TRUE;

		update MB;

		list<Account> Acc = [select id, recordTypeID from Account where firstName = 'FirstCustomer'];
		system.debug(loggingLevel.ERROR,'Accounts found: '+Acc.size());
		system.assert(Acc.size() == 1);
		system.assert(Acc[0].recordTypeID == mapRT.get('Customer'));
		

		//Update Customer
		MB.DSE__DS_Billing_Street__c = 'Street';
		update MB;

		test.stopTest();
	
	}

	@isTest
	static void CreateProspect()
	{
		insertSettings();


		//get Account record Types
		map<string, id> mapRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
			mapRT.put(RT.DeveloperName, RT.id);
		}

		//Create the Account creation 
		MDM_Account_Creation_Setting__c Creation = MDM_Account_Creation_Setting__c.getValues('Active');
		if(Creation != null){
			delete Creation;
		}
		Creation = new MDM_Account_Creation_Setting__c(name = 'Active', Active__c = true, Enable_Account_Creation__c = true, Enable_Auto_match_Beans__c = true, Enable_Logging__c = true, Enable_Synch__c = true, Update_Accounts_on_Field_Change_only__c = true);
		insert Creation;
		
		test.startTest();
		//Create Prospect
		DSE__DS_Master_Bean__c MB2 = new DSE__DS_Master_Bean__c(DSE__DS_Custom_Field_3__c = 'FirstProspect', DSE__DS_Custom_Field_4__c = 'Last', DSE__DS_Company__c = 'Company', DSE__DS_Record_Type_Name__c = 'Prospect');
		insert MB2;

		MB2.Create_Update_Account__c = TRUE;

		update MB2;

		list<Account> AccPros = [select id, recordTypeID from Account where firstName = 'FirstProspect'];
		system.assert(AccPros.size() == 1);
		system.assert(AccPros[0].recordTypeID == mapRT.get('Prospect'));

		test.stopTest();
	
	}

	@isTest
	static void CreateAgency()
	{
		insertSettings();
		//get Account record Types
		map<string, id> mapRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
			mapRT.put(RT.DeveloperName, RT.id);
		}

		//Create the Account creation 
		MDM_Account_Creation_Setting__c Creation = MDM_Account_Creation_Setting__c.getValues('Active');
		if(Creation != null){
			delete Creation;
		}
		Creation = new MDM_Account_Creation_Setting__c(name = 'Active', Active__c = true, Enable_Account_Creation__c = true, Enable_Auto_match_Beans__c = true, Enable_Logging__c = true, Enable_Synch__c = true, Update_Accounts_on_Field_Change_only__c = true);
		insert Creation;

		test.startTest();
		//Create Agency
		DSE__DS_Master_Bean__c MB3 = new DSE__DS_Master_Bean__c(DSE__DS_Custom_Field_3__c = 'FirstProspect', DSE__DS_Custom_Field_4__c = 'Last', DSE__DS_Company__c = 'CompanyAgencyTest', DSE__DS_Record_Type_Name__c = 'Agency');
		insert MB3;

		MB3.Create_Update_Account__c = TRUE;

		update MB3;

		list<Account> AccAgency = [select id, recordTypeID from Account where name = 'CompanyAgencyTest'];
		system.assert(AccAgency.size() == 1);
		system.assert(AccAgency[0].recordTypeID == mapRT.get('Agency'));

		test.stopTest();
	
	}

	@isTest
	static void CreateAccount()
	{
		insertSettings();
		test.startTest();
		Account AccInsert = new Account (Name = 'Test Insert');
		insert AccInsert;

		delete AccInsert;

		test.stopTest();
	}

	@isTest
	static void CauseErrors()
	{
		insertSettings();
		test.startTest();
		MDM_Debug_Logs_Class Dlog = new MDM_Debug_Logs_Class('Test', 'Test', false);
		MDM_Person_Account_Conversion_Class Conversion = new MDM_Person_Account_Conversion_Class(Dlog);

		test.stopTest();
	}

}