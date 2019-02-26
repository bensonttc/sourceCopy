@isTest (seeAllData = false)
private class BookingPassengerCaseTest
{
    private static Booking_Passenger__c CancelledPaxCustomer;
    private static Booking_Passenger__c ConfirmedPaxCustomer;
    private static Booking_Passenger__c ConfirmedPaxNoCustomer;
    private static Booking_Passenger__c PaxInactiveBooking;
    private static BookingPassengerCaseController CaseController;
    private static Account LeadCust;
    private static Account PaxCust;

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

        //Insert Accounts for the Bookings + Pax
        LeadCust = new Account (FirstName = 'Lead', LastName = 'Customer', RecordTypeID = mapRT.get('Customer'));
        insert LeadCust;

        PaxCust = new Account (FirstName = 'Pax', LastName = 'Customer', RecordTypeID = mapRT.get('Customer'));
        insert PaxCust;

        Account Brand = new Account (Name = 'Brand', RecordTypeID = mapRT.get('Brand'));
        insert Brand;

        Account BU = new Account (Name = 'Business Unit', recordTYpeiD = mapRT.get('Selling_Company'), parentID = Brand.ID, External_ID__C = 'BU');
        insert BU;


        //Get Users for booking owners
        //list<user> InactiveUser = [select id from user where profile.name = 'System Administrator' AND isActive = true limit 1];

        list<user> ActiveUser = [select id from user where profile.name = 'System Administrator' AND  isActive = true limit 1];


        //Create Bookings
        Booking__c CancelledBook = new Booking__c(Selling_Company__c = BU.ID, Original_booking_Date__c = date.today(), name = '1', RecordTypeID = BookRT.get('Booking'), status__c = 'CX', lead_passenger__C = LeadCust.id, ownerID = ActiveUser[0].ID);
        Insert CancelledBook;

        Booking__c ConfirmedBook = new Booking__c(Selling_Company__c = BU.ID, Original_booking_Date__c = date.today().addDays(1), name = '2', RecordTypeID = BookRT.get('Booking'), status__c = 'CO', lead_passenger__C = LeadCust.id, ownerID = ActiveUser[0].ID);
        Insert ConfirmedBook;

        //Booking__c InactiveUserBook = new Booking__c(Selling_Company__c = BU.ID, Original_booking_Date__c = date.today().addDays(1), name = '2', RecordTypeID = BookRT.get('Booking'), status__c = 'CO', lead_passenger__C = LeadCust.id, ownerID = InactiveUser[0].ID);
        //Insert InactiveUserBook;

        //change user to inactive after inserting Booking
        //InactiveUser[0].isActive = false;
        //update InactiveUser[0];

        //Create Booking Pax
        CancelledPaxCustomer = new Booking_Passenger__c(Booking__c = CancelledBook.id, name = 'test', Address_1__c = 'Test Street', Country__c = 'UK', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com', customer__c = PaxCust.id);
        insert CancelledPaxCustomer;

        ConfirmedPaxCustomer = new Booking_Passenger__c(Booking__c = ConfirmedBook.id, name = 'test', Address_1__c = 'Test Street', Country__c = 'UK', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com', customer__c = PaxCust.id);
        insert ConfirmedPaxCustomer;

        ConfirmedPaxNoCustomer = new Booking_Passenger__c(Booking__c = ConfirmedBook.id, name = 'test', Address_1__c = 'Test Street', Country__c = 'UK', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com');
        insert ConfirmedPaxNoCustomer;

        //PaxInactiveBooking = new Booking_Passenger__c(Booking__c = ConfirmedBook.id, name = 'test', Address_1__c = 'Test Street', Country__c = 'UK', First_Name__c = 'Travel test', Last_Name__c = 'Last name', Title__c = 'Mr', Email__c = 'email@email.com', customer__c = PaxCust.id);
        //insert PaxInactiveBooking;

    }


    @isTest
    //Tests will Setup the Visualforce page as if the new Case button on the Pax had been selected.
    //Will be repeated for 4 different Pax
    static void InsertCasesFromPax()
    {
        //Create records
        CreateRecords();

        test.starttest();
        //***Cancelled Pax With Customer***
        InitialisePage(CancelledPaxCustomer);   
        system.assert(CaseController.renderPage == false);  //check that the page will not be rendered because the booking is not confirmed

        //***Confirmed Pax With Customer***
        InitialisePage(ConfirmedPaxCustomer);
        system.assert(CaseController.renderPage == true);   //check that the page has rendered successfully
        CaseController.TheCase.Origin = 'Email';
        CaseController.TheCase.Type = 'Query';
        CaseController.SaveCase();                          //Create the case

        //check the case is created
        list<case> case1 = [select id, Lead_Passenger__c, ContactID from case where booking_passenger__c = :ConfirmedPaxCustomer.ID];
        system.assert(case1.size()  == 1);

        //Check the Lead pax and pax customer fields are correct
        list<Account> Cust = [select PersonContactId, ID from Account where PersonContactId = :case1[0].ContactID];
        system.assert(Cust[0].ID == PaxCust.ID);
        system.assert(case1[0].Lead_Passenger__c == LeadCust.ID);


        //***Confirmed Pax No Customer***
        InitialisePage(ConfirmedPaxNoCustomer);
        system.assert(CaseController.renderPage == true);   //check that the page has rendered successfully
        CaseController.TheCase.Origin = 'Email';
        CaseController.TheCase.Type = 'Query';
        CaseController.SaveCase();                          //Create the case

        //check the case is created
        list<case> case2 = [select id, Lead_Passenger__c, ContactID from case where booking_passenger__c = :ConfirmedPaxNoCustomer.ID];
        system.assert(case2.size()  == 1);
        system.assert(case2[0].ContactID  == null);
        system.assert(case2[0].Lead_Passenger__c == LeadCust.ID);

        test.stoptest();


    }

    static void InitialisePage(booking_passenger__c pax){
        //Set Page
        Test.setCurrentPageReference(new PageReference('Page.BookingPassengerCaseInsertPage')); 
        System.currentPageReference().getParameters().put('id', pax.ID);

        //Initialise Controller
        List<Case> cases = new List<Case>();
        CaseController = new BookingPassengerCaseController(new ApexPages.StandardSetController(cases));
    }
}