@istest private class bookingTriggerHandler_Test {
    
    private static Account acct1;
    private static Account businessUnit;
    private static Contact consultant1;
    private static Contact consultant2;
    private static Opportunity opp1;
    private static Opportunity opp2;
    private static Booking__c currentBooking1;
    private static Booking__c currentBooking2;
    private static Booking__c oldBooking;
    private static Booking__c closedWonBooking;
    private static Booking__c closedLostBooking;
    private static Account brand;
    private static Account personAccount1;
    private static Booking__c booking1;
    private static Booking__c booking2;
    private static Booking__c booking3;
    private static Booking__c booking4;
    private static Booking_Passenger__c bookPass1;
    private static Booking_Passenger__c bookPass2;
    private static Booking_Passenger__c bookPass3;
    private static Booking_Passenger__c bookPass4;
    private static Account personAcct1;
    private static Account personAcct2;
    private static Account personAcct3;
    private static Account personAcct4;
    private static Id reservationRecordType = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Reservation').getRecordTypeId();
    private static Id brandRecordType = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Brand').getRecordTypeId();
    private static Id businessUnitRecordType = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Business Unit').getRecordTypeId();
    private static Id travelConsultantRecordType = Schema.SObjectType.Contact.getRecordtypeInfosByName().get('Travel Consultant').getRecordTypeId();
    
    @istest public static void updateOneBookingFindNoMore(){
    
        CreateRecords();
        
        booking1.Status__c = 'Checked Out';
        
        test.StartTest();
        update booking1;
        test.StopTest();
        
        personAccount1 = [SELECT Id, RCH_Hotel_Stays__c FROM Account WHERE Id = :booking1.Lead_Passenger__c LIMIT 1];
        
        system.assertEquals(booking1.Brand__c, 'RCH');
        system.assertEquals(personAccount1.RCH_Hotel_Stays__c, 1);
    
    }
    
    @istest public static void updateOneBookingFindOneMore(){
    
        CreateRecords();
        
        booking3 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'Checked Out', Lead_Passenger__c = personAccount1.Id, recordTypeId = reservationRecordType);
        insert booking3;
        
        booking1.Status__c = 'Checked Out';
        
        test.StartTest();
        update booking1;
        test.StopTest();
        
        personAccount1 = [SELECT Id, RCH_Hotel_Stays__c FROM Account WHERE Id = :booking1.Lead_Passenger__c LIMIT 1];
        
        system.assertEquals(personAccount1.RCH_Hotel_Stays__c, 2);
    
    }
    
    @istest public static void updateTwoBookingsFindOneMore(){
    
        CreateRecords();
        
        booking3 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'Checked Out', Lead_Passenger__c = personAccount1.Id, recordTypeId = reservationRecordType);
        insert booking3;
        
        booking1.Status__c = 'Checked Out';
        booking2.Status__c = 'Checked Out';
        
        list<Booking__c> updateBooks = new List<Booking__c>();
        
        updateBooks.add(booking1);
        updateBooks.add(booking2);
        
        test.StartTest();
        update updateBooks;
        test.StopTest();
        
        personAccount1 = [SELECT Id, RCH_Hotel_Stays__c FROM Account WHERE Id = :booking1.Lead_Passenger__c LIMIT 1];
        
        system.assertEquals(personAccount1.RCH_Hotel_Stays__c, 3);
    
    }
    
    @istest public static void updateTwoBookingsFindTwoMore(){
    
        CreateRecords();
        
        booking3 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'Checked Out', Lead_Passenger__c = personAccount1.Id, recordTypeId = reservationRecordType);
        insert booking3;
        
        booking4 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'Checked Out', Lead_Passenger__c = personAccount1.Id, recordTypeId = reservationRecordType);
        insert booking4;
        
        booking1.Status__c = 'Checked Out';
        booking2.Status__c = 'Checked Out';
        
        list<Booking__c> updateBooks = new List<Booking__c>();
        
        updateBooks.add(booking1);
        updateBooks.add(booking2);
        
        test.StartTest();
        update updateBooks;
        test.StopTest();
        
        personAccount1 = [SELECT Id, RCH_Hotel_Stays__c FROM Account WHERE Id = :booking1.Lead_Passenger__c LIMIT 1];
        
        system.assertEquals(personAccount1.RCH_Hotel_Stays__c, 4);
    
    }
    
    @istest public static void updateOneBookingToCancelledFindOneMore(){
    
        CreateRecords();
        
        booking3 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'Checked Out', Lead_Passenger__c = personAccount1.Id, recordTypeId = reservationRecordType);
        insert booking3;
        
        booking4 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'Checked Out', Lead_Passenger__c = personAccount1.Id, recordTypeId = reservationRecordType);
        insert booking4;
        
        booking3.Status__c = 'Cancelled';
        
        test.StartTest();
        update booking3;
        test.StopTest();
        
        personAccount1 = [SELECT Id, RCH_Hotel_Stays__c FROM Account WHERE Id = :booking1.Lead_Passenger__c LIMIT 1];
        
        system.assertEquals(personAccount1.RCH_Hotel_Stays__c, 1);
    
    }
    
    @isTest static void insertNewBooking(){
    
        createRecords();
        
        List<Booking__c> bookList = new List<Booking__c>();
        bookList.Add(currentBooking1);
        bookList.Add(currentBooking2);
        
        test.startTest();
        insert bookList;
        test.stopTest();
        
        List<Booking__c> currentBookings = [SELECT Id, Consultant__r.Inactive__c, Consultant__r.Has_Bookings__c FROM Booking__c WHERE Consultant__c = :consultant1.Id];
        
        system.assertEquals(currentBookings.Size(), 2);
        system.assertEquals(currentBookings.get(0).Consultant__r.Inactive__c, False);
        system.assertEquals(currentBookings.get(0).Consultant__r.Has_Bookings__c, True);
    
    }
    
    @isTest static void insertOldBooking(){
    
        createRecords();
        
        test.startTest();
        insert oldBooking;
        test.stopTest();
        
        oldBooking = [SELECT Id, Consultant__r.Inactive__c, Consultant__r.Has_Bookings__c FROM Booking__c WHERE Id = :oldBooking.Id];
        
        system.assertEquals(OldBooking.Consultant__r.Inactive__c, False);
        system.assertEquals(OldBooking.Consultant__r.Has_Bookings__c, False);
        
    }
    
    @isTest static void cancelUnconfirmedBooking(){
    
        createRecords();
        
        closedLostBooking.Status__c = 'CX';
        
        test.startTest();
        update closedLostBooking;
        test.stopTest();
        
        opp1 = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp1.Id];
        
        system.assertEquals(opp1.StageName, 'Closed Lost');
        
    }
    
    @isTest static void confirmUnconfirmedBooking(){
    
        createRecords();
        
        closedWonBooking.Status__c = 'CO';
        closedWonBooking.Payment_Status__c = 'FP';
        
        test.startTest();
        update closedWonBooking;
        test.stopTest();
        
        opp2 = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp2.Id];
        
        system.assertEquals(opp2.StageName, 'Closed Won');
        
    }
    
    @isTest static void collectAllGroupBookings(){
    
        createRecords();
        
        booking3.group_Booking_Id__c = '8008135';
        booking3.group_Opportunity__c = opp1.Id;
        
        test.startTest();
        update booking3;
        test.stopTest();
        
        opp1 = [SELECT Id, StageName, group_Id__c, Booked_Passengers__c FROM Opportunity WHERE Id = :opp1.Id];
        
        system.assertEquals(opp1.Booked_Passengers__c, 4);
        
    }
    
    public static void createRecords(){
    
        acct1 = new Account(name = 'test');
        insert acct1;
        
        brand = new Account(name = 'RCH', recordTypeId = brandRecordType);
        insert brand;
        
        businessUnit = new Account(name = 'busUnit', parentId = brand.Id, recordTypeId = businessUnitRecordType);
        insert businessUnit;
        
        consultant1 = new Contact(firstName = 'guy', lastName = 'dude', email = 'test@test.com', Account = acct1, inactive__c = True, Has_Bookings__c = False, recordTypeId = travelConsultantRecordType);
        insert consultant1;
        
        consultant2 = new Contact(firstName = 'guy', lastName = 'dude', email = 'test@test.com', Account = acct1, inactive__c = False, Has_Bookings__c = False, recordTypeId = travelConsultantRecordType);
        insert consultant2;
        
        currentBooking1 = new Booking__c(Consultant__c = consultant1.Id, Selling_Company__c = businessUnit.Id, Original_Booking_Date__c = date.today(), name = 'ABCDEFGH');
        currentBooking2 = new Booking__c(Consultant__c = consultant1.Id, Selling_Company__c = businessUnit.Id, Original_Booking_Date__c = date.today(), name = 'ABCDEFGH');
        oldBooking = new Booking__c(Consultant__c = consultant2.Id, Selling_Company__c = businessUnit.Id, Original_Booking_Date__c = date.today().addDays(-1100), name = 'ABCDEFGH');
        
        closedLostBooking = new Booking__c(Status__c = 'UC', Selling_Company__c = businessUnit.Id);
        insert closedLostBooking;
        
        closedWonBooking = new Booking__c(Status__c = 'UC', Selling_Company__c = businessUnit.Id);
        insert closedWonBooking;
        
        opp1 = new Opportunity(name = 'Test', Account = acct1, StageName = 'Prospecting', Booking_Number__c = closedLostBooking.Id, CloseDate = date.today(), group_Id__c = '8008135', RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B2C Opportunity').getRecordTypeId());
        insert opp1;
        
        opp2 = new Opportunity(name = 'Test', Account = acct1, StageName = 'Prospecting', Booking_Number__c = closedWonBooking.Id, CloseDate = date.today(), RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B2C Opportunity').getRecordTypeId());
        insert opp2;
        
        personAccount1 = new Account(firstName = 'blah', lastName = 'deBlah', PersonEmail = 'blah@deblah.com', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert personAccount1;
        
        booking1 = new Booking__c(name = 'A012345', Selling_Company__c = businessUnit.Id, Status__c = 'CX', Total_Price__c = 0, Lead_Passenger__c = personAccount1.Id, recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Reservation').getRecordTypeId());
        insert booking1;
        booking1 = [SELECT Id, Name, Pax_Count__c, Selling_Company__c, Status__c, Lead_Passenger__c, recordTypeId, Brand__c FROM Booking__c WHERE Id = :booking1.id LIMIT 1];
        
        booking2 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'CX', Total_Price__c = 0, Lead_Passenger__c = personAccount1.Id, recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Reservation').getRecordTypeId());
        insert booking2;
        booking2 = [SELECT Id, Name, Pax_Count__c, Selling_Company__c, Status__c, Lead_Passenger__c, recordTypeId, Brand__c FROM Booking__c WHERE Id = :booking2.id LIMIT 1];
        
        booking3 = new Booking__c(name = 'A012345', Selling_Company__c = businessUnit.Id, Status__c = 'CO', Total_Price__c = 0, Lead_Passenger__c = personAccount1.Id, recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Reservation').getRecordTypeId());
        insert booking3;
        booking3 = [SELECT Id, Name, Pax_Count__c, Selling_Company__c, Status__c, Lead_Passenger__c, recordTypeId, Brand__c FROM Booking__c WHERE Id = :booking3.id LIMIT 1];
        
        booking4 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'CO', Total_Price__c = 0, Lead_Passenger__c = personAccount1.Id, group_Booking_Id__c = '8008135', recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Reservation').getRecordTypeId(), Group_Opportunity__c = opp1.Id);
        insert booking4;
        booking4 = [SELECT Id, Name, Pax_Count__c, Selling_Company__c, Status__c, Lead_Passenger__c, recordTypeId, Brand__c FROM Booking__c WHERE Id = :booking4.id LIMIT 1];
        
        personAcct1 = new Account(firstName = 'Mister', lastName = 'A', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert personAcct1;
        
        personAcct2 = new Account(firstName = 'Mister', lastName = 'B', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert personAcct2;
        
        personAcct3 = new Account(firstName = 'Mister', lastName = 'C', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert personAcct3;
        
        personAcct4 = new Account(firstName = 'Mister', lastName = 'D', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert personAcct4;
        
        bookPass1 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#001', First_Name__c = 'Mister', Last_Name__c = 'A', Booking__c = booking3.Id, Customer__c = personAcct1.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass1;
        
        bookPass2 = new Booking_Passenger__c(Name = 'TTUSAS#A12345679#001', First_Name__c = 'Mister', Last_Name__c = 'B', Booking__c = booking4.Id, Customer__c = personAcct2.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass2;
        
        bookPass3 = new Booking_Passenger__c(Name = 'TTUSAS#A12345670#001', First_Name__c = 'Mister', Last_Name__c = 'C', Booking__c = booking3.Id, Customer__c = personAcct3.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass3;
        
        bookPass4 = new Booking_Passenger__c(Name = 'TTUSAS#A12345681#001', First_Name__c = 'Mister', Last_Name__c = 'D', Booking__c = booking4.Id, Customer__c = personAcct4.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass4;
        
        booking3 = [SELECT Id, Name, Pax_Count__c, Selling_Company__c, Status__c, Lead_Passenger__c, recordTypeId, Brand__c FROM Booking__c WHERE Id = :booking3.id LIMIT 1];
        
        booking4 = [SELECT Id, Name, Pax_Count__c, Selling_Company__c, Status__c, Lead_Passenger__c, recordTypeId, Brand__c FROM Booking__c WHERE Id = :booking4.id LIMIT 1];
    
    }
    
}