@isTest
public class ActivityBrandStamping_Tests 
{

	static void createCustomSettings(){
		list<Branded_Notes__c> brands = new list<Branded_Notes__c>();
		Branded_Notes__c brLead = new Branded_Notes__c(name = 'Lead', Attachment_Lookup__c = 'Lead__c');
		brands.add(brLead);
		Branded_Notes__c brOpp = new Branded_Notes__c(name = 'Opportunity', Attachment_Lookup__c = 'Opportunity__c');
		brands.add(brOpp);
		Branded_Notes__c brCont = new Branded_Notes__c(name = 'Contact', Attachment_Lookup__c = 'Contact__c');
		brands.add(brCont);
		Branded_Notes__c brAcc = new Branded_Notes__c(name = 'Account', Attachment_Lookup__c = 'Account__c');
		brands.add(brAcc);
		insert brands;
	}

	@isTest static void TestTriggers1()
	{
		createCustomSettings();
		account ac1 = new account();
		ac1.Name = 'The Name';
		insert ac1;
		update ac1;

		contact con = new contact();
		con.accountid = ac1.id;
		con.firstname = 'Firt';
		con.lastname = 'last';
		insert con;
		update con;

		Blob b = Blob.valueOf('Test Data');      
		attachment a = new attachment();
		a.parentID = ac1.id;
		a.name = 'test at';
		a.Body = b;  
		insert a;
		update a;

		

	}

	@isTest static void TestTriggers2()
	{
		createCustomSettings();
		account ac1 = new account();
		ac1.Name = 'The Name';
		insert ac1;
		update ac1;

		contact con = new contact();
		con.accountid = ac1.id;
		con.firstname = 'Firt';
		con.lastname = 'last';
		insert con;
		update con;


		note n = new note();
		n.parentID = ac1.id;
		n.title = 'test';
		insert n;
		update n;

		

	}

	@isTest static void TestTriggers3()
	{
		createCustomSettings();
		account ac1 = new account();
		ac1.Name = 'The Name';
		insert ac1;
		update ac1;

		contact con = new contact();
		con.accountid = ac1.id;
		con.firstname = 'Firt';
		con.lastname = 'last'; 
		insert con;
		update con;



		task t = new task();
		t.subject = 'test';
		t.activitydate = system.today();
		t.whatid = ac1.id;
		insert t;
		update t;


		
	}

	@isTest static void TestTriggers4()
	{
		createCustomSettings();
		account ac1 = new account();
		ac1.Name = 'The Name';
		insert ac1;
		update ac1;

		contact con = new contact();
		con.accountid = ac1.id;
		con.firstname = 'Firt';
		con.lastname = 'last'; 
		insert con;
		update con;



		event e = new event();
		e.subject = 'test';
		e.activitydate = system.today();
		e.activitydatetime = system.now();
		e.durationinminutes = 3;
		e.whatid = ac1.id;
		insert e;
		update e;

	}

	@isTest static void TestVFPages1()
	{
		createCustomSettings();
		account ac1 = new account();
		ac1.Name = 'The Name';
		insert ac1;

		RecordType RT = [select id from recordtype where name='Brand' and sobjecttype = 'Account' limit 1];
		account ac2 = new account();
		ac2.Name = 'The Name2';
		ac2.recordtypeid = rt.id;
		insert ac2;

		contact con = new contact();
		con.accountid = ac1.id;
		con.firstname = 'Firt';
		con.lastname = 'last'; 
		insert con;

		Blob b = Blob.valueOf('Test Data');      
		attachment a = new attachment();
		a.parentID = ac1.id;
		a.name = 'test at';
		a.Body = b;  
		insert a;

		note n = new note();
		n.parentID = ac1.id;
		n.title = 'test';
		insert n;

		note n2 = new note();
		n2.parentID = ac1.id;
		n2.title = 'test';
		insert n2;

		task t = new task();
		t.subject = 'test';
		t.activitydate = system.today();
		t.whatid = ac1.id;
		insert t;

		task t2 = new task();
		t2.subject = 'test';
		t2.activitydate = system.today();
		t2.whatid = ac1.id;
		insert t2;

		event e = new event();
		e.subject = 'test';
		e.activitydate = system.today();
		e.activitydatetime = system.now();
		e.durationinminutes = 3;
		e.whatid = ac1.id;
		insert e;

		event e2 = new event();
		e2.subject = 'test';
		e2.activitydate = system.today();
		e2.activitydatetime = system.now();
		e2.durationinminutes = 3;
		e2.whatid = ac1.id;
		insert e2;


        PageReference Act1 = Page.Account_Activities;
        Test.setCurrentPage(Act1);
        ApexPages.currentPage().getParameters().put('id', ac1.id);
        
        ActivitiesByBrand_Controller cpc = new ActivitiesByBrand_Controller(); 
        cpc.sobjectid = ac1.id;
        cpc.sObjectType = 'Account';
        cpc.getActivitywList();
        cpc.SelectedDisplay = 'NotesAttachments';
        cpc.getActivitywList();
        cpc.SelectedDisplay = 'History';
        cpc.getActivitywList();

        // Do Change Brand Edit Stuff
        ApexPages.currentPage().getParameters().put('ActivityAction', 'Cancel');
		cpc.s_EditBrands();
        ApexPages.currentPage().getParameters().put('ActivityAction', 'Edit');
        ApexPages.currentPage().getParameters().put('ActivityID', t.id);
        ApexPages.currentPage().getParameters().put('ObjectType', 'Task');
        ApexPages.currentPage().getParameters().put('ExistingBrands','The Name2');
        cpc.s_EditBrands();
        ApexPages.currentPage().getParameters().put('ActivityAction', 'Save');
        list<string> newlist = new list<string>();
        newlist.add('The Name2');
        cpc.SelectedBrandsOpt = Newlist;
		cpc.s_EditBrands();
	    ApexPages.currentPage().getParameters().put('ActivityID', e.id);
        ApexPages.currentPage().getParameters().put('ObjectType', 'Event');
        ApexPages.currentPage().getParameters().put('ActivityAction', 'Edit');
        cpc.s_EditBrands();
	    ApexPages.currentPage().getParameters().put('ActivityAction', 'Save');
        cpc.s_EditBrands();
        ApexPages.currentPage().getParameters().put('ActivityID', n.id);
        ApexPages.currentPage().getParameters().put('ObjectType', 'Note');
        ApexPages.currentPage().getParameters().put('ActivityAction', 'Edit');
        cpc.s_EditBrands();
	    ApexPages.currentPage().getParameters().put('ActivityAction', 'Save');
        cpc.s_EditBrands();
	    ApexPages.currentPage().getParameters().put('ActivityID', a.id);
        ApexPages.currentPage().getParameters().put('ObjectType', 'Attachment');
        ApexPages.currentPage().getParameters().put('ActivityAction', 'Edit');
        cpc.s_EditBrands();
	    ApexPages.currentPage().getParameters().put('ActivityAction', 'Save');
        cpc.s_EditBrands();
       
		// now do the stuff for the MORE screen
		PageReference Act2 = Page.ActivitiesByBrandMore;
        Test.setCurrentPage(Act2);
        ApexPages.currentPage().getParameters().put('id', ac1.id);
        ApexPages.currentPage().getParameters().put('Type', 'Task');
        ApexPages.currentPage().getParameters().put('SourceObjectType','Account');
        cpc.s_GetMoreRecords();
        ApexPages.currentPage().getParameters().put('id', ac1.id);
        ApexPages.currentPage().getParameters().put('Type', 'Event');
        ApexPages.currentPage().getParameters().put('SourceObjectType','Account');
        cpc.s_GetMoreRecords();
        ApexPages.currentPage().getParameters().put('id', ac1.id);
        ApexPages.currentPage().getParameters().put('Type', 'Attachment');
        ApexPages.currentPage().getParameters().put('SourceObjectType','Account');
        cpc.s_GetMoreRecords();
        ApexPages.currentPage().getParameters().put('id', ac1.id);
        ApexPages.currentPage().getParameters().put('Type', 'Note');
        ApexPages.currentPage().getParameters().put('SourceObjectType','Account');
        cpc.s_GetMoreRecords();
        ApexPages.currentPage().getParameters().put('id', con.id);
        ApexPages.currentPage().getParameters().put('Type', 'Task');
        ApexPages.currentPage().getParameters().put('SourceObjectType','Contact');
        cpc.s_GetMoreRecords();

        // Test Delete And Change Brands
         ApexPages.currentPage().getParameters().put('ActivityAction',t.id);
		ApexPages.currentPage().getParameters().put('ObjectType','Task');
		cpc.s_delete();
		ApexPages.currentPage().getParameters().put('ActivityAction',e.id);
		ApexPages.currentPage().getParameters().put('ObjectType','Event');
		cpc.s_delete();
		ApexPages.currentPage().getParameters().put('ActivityAction',n.id);
		ApexPages.currentPage().getParameters().put('ObjectType','Note');
		cpc.s_delete();
		ApexPages.currentPage().getParameters().put('ActivityAction',a.id);
		ApexPages.currentPage().getParameters().put('ObjectType','Attachment');
		cpc.s_delete();

	}

}