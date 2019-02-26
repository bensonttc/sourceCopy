@isTest (SeeAllData=false)
private class MDM_Test_Custom_Sync
{


    //@isTest
    static void CreateCustomSettings()
    {
        //Create Data Sources if they don't exist
        list<DSE__DS_Sources__c> ListSource = new list<DSE__DS_Sources__c>();
        DSE__DS_Sources__c PaxSource = new DSE__DS_Sources__c(name = 'Booking_Passenger__c', DSE__DS_Object_Class__c = 'Account');
        ListSource.add(PaxSource);

        DSE__DS_Sources__c ReqSource = new DSE__DS_Sources__c(name = 'Request__c', DSE__DS_Object_Class__c = 'Account');
        ListSource.add(ReqSource);

        DSE__DS_Sources__c PreSource = new DSE__DS_Sources__c(name = 'Pre_Registration__c', DSE__DS_Object_Class__c = 'Account');
        ListSource.add(PreSource);

        DSE__DS_Sources__c LeadSource = new DSE__DS_Sources__c(name = 'Lead', DSE__DS_Object_Class__c = 'Account');
        ListSource.add(LeadSource);

        insert ListSource;

        //Create Synch settngs
        list<DSE__DS_SF_Synchronization_Settings__c> SynchList = new list<DSE__DS_SF_Synchronization_Settings__c>();
        DSE__DS_SF_Synchronization_Settings__c PaxSynch = new DSE__DS_SF_Synchronization_Settings__c(name = 'Booking_Passenger__c', DSE__Billing_City__c = 'Address_4__c', DSE__Company__c = 'Full_Name__c', DSE__Billing_Country__c = 'Country__c', DSE__Custom_Field_1__c = 'Title__c', DSE__Custom_Field_2__c = 'Email__c', DSE__Custom_Field_3__c= 'First_Name__c', DSE__Custom_Field_4__c = 'Last_Name__c', DSE__Custom_Field_5__c = 'Is_Person_Account__c', DSE__Custom_Field_8__c = 'Client_ID__c', DSE__Custom_Field_10__c = 'Segment_for_CloudMDM__c', DSE__Email__c = 'Email__c', DSE__First_Name__c = 'First_Name__c', DSE__Last_Name__c = 'Last_Name__c', DSE__Billing_Postal_Code__c = 'Postal_code__c', DSE__Billing_State__c = 'State__c', DSE__Billing_Street__c = 'Billing_Street__c', DSE__Synchronize__c = true);
        SynchList.add(PaxSynch);

        DSE__DS_SF_Synchronization_Settings__c ReqSynch = new DSE__DS_SF_Synchronization_Settings__c(name = 'Request__c', DSE__Billing_City__c = 'City__c', DSE__Company__c = 'Full_Name__c', DSE__Billing_Country__c = 'Country__c', DSE__Custom_Field_1__c = 'Title__c', DSE__Custom_Field_2__c = 'Email__c', DSE__Custom_Field_3__c= 'First_Name__c', DSE__Custom_Field_4__c = 'Last_Name__c', DSE__Custom_Field_5__c = 'Is_Person_Account__c', DSE__Custom_Field_10__c = 'Segment_for_CloudMDM__c', DSE__Email__c = 'Email__c', DSE__First_Name__c = 'First_Name__c', DSE__Last_Name__c = 'Last_Name__c', DSE__Billing_Postal_Code__c = 'Postal_code__c', DSE__Billing_State__c = 'State__c', DSE__Billing_Street__c = 'Billing_Street__c', DSE__Synchronize__c = true);
        SynchList.add(ReqSynch);

        DSE__DS_SF_Synchronization_Settings__c PreSynch = new DSE__DS_SF_Synchronization_Settings__c(name = 'Pre_Registration__c', DSE__Billing_City__c = 'City__c', DSE__Company__c = 'Full_Name__c', DSE__Billing_Country__c = 'Country__c', DSE__Custom_Field_1__c = 'Title__c', DSE__Custom_Field_2__c = 'Email__c', DSE__Custom_Field_3__c= 'First_Name__c', DSE__Custom_Field_4__c = 'Last_Name__c', DSE__Custom_Field_5__c = 'Is_Person_Account__c', DSE__Custom_Field_10__c = 'Segment_for_CloudMDM__c', DSE__Email__c = 'Email__c', DSE__First_Name__c = 'First_Name__c', DSE__Last_Name__c = 'Last_Name__c', DSE__Billing_Postal_Code__c = 'Postal_code__c', DSE__Billing_State__c = 'State_Region__c', DSE__Billing_Street__c = 'Street__c', DSE__Synchronize__c = true);
        SynchList.add(PreSynch);

        DSE__DS_SF_Synchronization_Settings__c LeadSynch = new DSE__DS_SF_Synchronization_Settings__c(name = 'Lead', DSE__Billing_City__c = 'City', DSE__Company__c = 'Company', DSE__Billing_Country__c = 'Country', DSE__Custom_Field_1__c = 'Title', DSE__Custom_Field_2__c = 'Email', DSE__Custom_Field_3__c= 'FirstName', DSE__Custom_Field_4__c = 'LastName', DSE__Email__c = 'Email', DSE__First_Name__c = 'FirstName', DSE__Last_Name__c = 'LastName', DSE__Billing_Postal_Code__c = 'Postalcode', DSE__Billing_State__c = 'State', DSE__Billing_Street__c = 'Street', DSE__Synchronize__c = true);
        SynchList.add(LeadSynch);

        insert SynchList;


        //Create Account Creation Setting - enable everything including logging
        MDM_Account_Creation_Setting__c Creation = new MDM_Account_Creation_Setting__c(name = 'Active', Active__c = true, Enable_Account_Creation__c = true, Enable_Auto_match_Beans__c = true, Enable_Logging__c = true, Enable_Synch__c = true, Update_Accounts_on_Field_Change_only__c = true);
        insert Creation;


        //enable cloud MDM
        DSE__DS_Settings__c setup = new DSE__DS_Settings__c(name = 'Active', DSE__DS_Setup_Completed__c = true, DSE__DS_Standardize_Billing_Country__c = false, DSE__DS_Validate_Billing_Country__c = false);
        insert setup;

        //Diable Account Trigger
        DSE.API_AccountTriggerHandler API1 = new DSE.API_AccountTriggerHandler();
        API1.disableCloudMDMTrigger();

        //Diable Lead Trigger
        DSE.API_LeadTriggerHandler API2 = new DSE.API_LeadTriggerHandler();
        API2.disableCloudMDMTrigger();

        //License MDM
        DSE.API_LicenseManager.setFeature('Production',true,'BLO4v1xz27');
        DSE.API_LicenseManager.setFeature('Sandbox',true,'BLO4v1xz27');
        DSE.API_LicenseManager.setFeature('FullCopy',true,'BLO4v1xz27');
    }



    @isTest
    static void CreateBookingPax(){
        CreateCustomSettings();
        //get Account record Types
        map<string, id> mapRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
            mapRT.put(RT.DeveloperName, RT.id);
        }

        //get Booking__c record Types
        map<string, id> mapRTBooking = new map<string, id>();
        for(RecordType RT3 : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking__c']){
            mapRTBooking.put(RT3.DeveloperName, RT3.id);
        }

        //Create Business Unit
        Account BU = new Account(name = 'Business Unit', recordTypeID = mapRT.get('Selling_Company'));
        insert BU;

        //create Booking
        Booking__c Book = new Booking__c(Original_Booking_Date__c = date.today(), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111',  Hidden_First_Departure_Month__c = '01', Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
        insert Book;

        //Create Booking Pax
        Booking_Passenger__c BookingPax1 = new Booking_Passenger__c(Booking__c = Book.id, name = 'test', Address_1__c = 'Test Street', Country__c = 'UK', State__c = 'State', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com');
        insert BookingPax1;

        //Check the Booking Pax should have synchronised
        Booking_Passenger__c PaxCheck = [select id, should_synchronise__c, MDM_Synchronize__c from Booking_Passenger__c where id = :BookingPax1.id];
        system.assert(PaxCheck.should_synchronise__c);
        system.assert(PaxCheck.MDM_Synchronize__c);

        //Check the Bean has been created
        list<DSE__DS_Bean__c> Paxbeans = [select id, Booking_Passenger__c, CP_segment__c, DSE__DS_Segment__c from DSE__DS_Bean__c where DSE__DS_Source_No__c = :BookingPax1.id];
        system.assert(Paxbeans.size() == 1);

        //Check the Bean has the Booking pax field populated
        system.assert(Paxbeans[0].Booking_Passenger__c == BookingPax1.id);
        
        //Check the CP Segment has been created
        system.assert(Paxbeans[0].CP_segment__c != null);

        //Check Segment has had the common words stripped out
        system.debug('Segment = '+ Paxbeans[0].DSE__DS_Segment__c);
        system.assert(!Paxbeans[0].DSE__DS_Segment__c.contains('TRAVEL'));

        //Update Booking Pax
        BookingPax1.Address_2__c = 'Address Line 2';
        update BookingPax1;

        //Create Master Bean manually - set to not create Account
        DSE__DS_Master_Bean__c MB = new DSE__DS_Master_Bean__c(DSE__DS_Company__c = 'Test Company', Do_Not_Create_Account__c = true);
        insert MB;

        //Link Bean to new MB
        Paxbeans[0].DSE__DS_Master_Bean__c = MB.ID;
        update Paxbeans;

        //Insert first bean in again 
        Booking_Passenger__c BookingPax2 = BookingPax1.clone(false, true, false, false);
        insert BookingPax2;

        //Check the Bean has been created
        list<DSE__DS_Bean__c> Paxbeans2 = [select id, Booking_Passenger__c, CP_segment__c, DSE__DS_Master_Bean__c from DSE__DS_Bean__c where DSE__DS_Source_No__c = :BookingPax2.id];
        system.assert(Paxbeans.size() == 1);

        //Check that the Bean has been matched to the same MB
        system.assert(Paxbeans[0].DSE__DS_Master_Bean__c == MB.id);

        //Unsynch Booking pax
        BookingPax2.MDM_Synchronize__c = false;
        update BookingPax2;

        //Resynch Booking Pax
        BookingPax2.MDM_Synchronize__c = true;
        update BookingPax2;

        //Delete Booking Pax
        delete BookingPax2;

    }

    @isTest
    static void SetLeadBookingPax(){
        CreateCustomSettings();
        //get Account record Types
        map<string, id> mapRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
            mapRT.put(RT.DeveloperName, RT.id);
        }

        //get Booking__c record Types
        map<string, id> mapRTBooking = new map<string, id>();
        for(RecordType RT3 : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking__c']){
            mapRTBooking.put(RT3.DeveloperName, RT3.id);
        }

        //Create Business Unit
        Account BU = new Account(name = 'Business Unit', recordTypeID = mapRT.get('Selling_Company'));
        insert BU;

        //create Booking
        Booking__c Book = new Booking__c(Original_Booking_Date__c = date.today(), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111',  Hidden_First_Departure_Month__c = '01', Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
        insert Book;

        //create Customer
        Account Cus = new Account(firstName = 'Customer', lastName = 'last', recordTypeID = mapRT.get('Customer'));
        insert Cus;

        //Create lead Booking Pax
        Booking_Passenger__c BookingPax1 = new Booking_Passenger__c(Customer__c = Cus.ID, Lead_Passenger__c = true, Booking__c = Book.id, name = 'test', Address_1__c = 'Test Street', Country__c = 'UK', State__c = 'state', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com');
        insert BookingPax1;

        //check that the booking now has a lead booking pax
        list<booking__c> Books = [select id, Lead_Passenger__c from booking__c where id = :Book.id];
        system.assert(Books.size() == 1);
        system.assert(Books[0].Lead_Passenger__c == Cus.id);


    }

    @isTest
    static void CreateRequest(){
        CreateCustomSettings();
        //Create Request
        Request__c Req = new Request__c( Address_1__c = 'Test Street', Country__c = 'UK', City__c = 'City', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com', Request_Type__c = 'BRQ', selling_company__C = 'CHEUOS');
        insert Req;
        update Req;

        //Check the Bean has been created
        list<DSE__DS_Bean__c> Reqbeans = [select id, Booking_Passenger__c, Request__c, CP_segment__c, DSE__DS_Segment__c from DSE__DS_Bean__c where DSE__DS_Source_No__c = :Req.id];
        system.assert(Reqbeans.size() == 1);

        //Check the Bean has the Request field populated
        system.assert(Reqbeans[0].Request__c == Req.id);

        delete Req;
    }

    @isTest
    static void CreateandPurgeLogs(){
        MDM_Debug_Logs_Class Debug = new MDM_Debug_Logs_Class('Name', 'Cat', True);
        Debug.Quicklog('Short Log');
        Debug.LogError();
        Debug.Comit();

        Debug.PurgeLogs(2, true);
    }

    @isTest
    static void CreateandDeleteLead(){
        CreateCustomSettings();

        Lead lead1 = new Lead(firstname = 'First', lastname = 'Last', city = 'city', company = 'Company', country = 'UK', street = 'street', email = 'email@email.com');
        insert lead1;
        update lead1;

        //Check the Bean has been created
        list<DSE__DS_Bean__c> Leadbeans = [select id, Booking_Passenger__c, Request__c, DSE__DS_Lead__c, CP_segment__c, DSE__DS_Segment__c from DSE__DS_Bean__c where DSE__DS_Source_No__c = :lead1.id];
        system.assert(Leadbeans.size() == 1);

        //Check the Bean has the Request field populated
        system.assert(Leadbeans[0].DSE__DS_Lead__C == Lead1.id);

        delete lead1;
    }

    @isTest
    static void CreatePrereg(){
        CreateCustomSettings();
        
        //get Account record Types
        map<string, id> mapRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
            mapRT.put(RT.DeveloperName, RT.id);
        }

        //get Booking__c record Types
        map<string, id> mapRTBooking = new map<string, id>();
        for(RecordType RT3 : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking__c']){
            mapRTBooking.put(RT3.DeveloperName, RT3.id);
        }
        
        //Create Business Unit
        Account BU = new Account(name = 'Business Unit', recordTypeID = mapRT.get('Selling_Company'));
        insert BU;

        //create Booking
        Booking__c Book = new Booking__c(Original_Booking_Date__c = date.today(), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111',  Hidden_First_Departure_Month__c = '01', Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
        insert Book;

        //Create Booking Pax
        Booking_Passenger__c BookingPax1 = new Booking_Passenger__c(Booking__c = Book.id, name = 'test', Address_1__c = 'Test Street', Country__c = 'UK', State__c = 'State', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com');
        insert BookingPax1;
        
        //Create Request
        Pre_Registration__c Reg = new Pre_Registration__c(name = 'Test', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Booking_Passenger__c = BookingPax1.Id, Booking__c = Book.Id, State_Region__c = 'state', Street__c = 'street', Email__c = 'email@email.com');
        test.startTest();
        insert Reg;
        update Reg;
        test.stopTest();

        //Check the Bean has been created
        list<DSE__DS_Bean__c> Regbeans = [select id, Booking_Passenger__c, Pre_Registration__c, CP_segment__c, DSE__DS_Segment__c from DSE__DS_Bean__c where DSE__DS_Source_No__c = :Reg.id];
        system.assert(Regbeans.size() == 1);

        //Check the Bean has the Request field populated
        system.assert(Regbeans[0].Pre_Registration__c == Reg.id);

        delete Reg;
    }
    

}