@istest private class caseTriggerHandlerTest{

    private static Account businessUnit;
    private static Account personAccount1;
    private static Account personAccount2;
    private static Booking__c testBooking;
    private static Booking__c booking1;
    private static Booking__c booking2;
    private static Booking__c booking3;
    private static Booking__c booking4;
    private static Booking__c booking5;
    private static Booking_Passenger__c bPass1;
    private static Booking_Passenger__c bPass2;
    private static Booking_Passenger__c bPass3;
    private static Booking_Passenger__c bPass4;
    private static Booking_Passenger__c bPass5;
    private static Booking_Passenger__c bPass6;
    
    @istest public static void oneBookingPassengerWithCorrectLastName(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking1 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking1.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A012345-deBlah] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking1.Id, testCase.Booking__c);
        system.assertEquals(bPass1.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass1.Id, testCase.Booking_Passenger__c);
        system.assertEquals(bPass1.Customer__r.personContactId, testCase.ContactId);
        system.assertEquals(bPass1.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void oneBookingPassengerWithNoLastName(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking1 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking1.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A012345-yerma] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking1.Id, testCase.Booking__c);
        system.assertEquals(bPass1.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass1.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void oneBookingPassengerWithIncorrectLastName(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking1 = [SELECT Id, Selling_Company__c, Full_Status__c FROM Booking__c WHERE Id = :booking1.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A012345] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking1.Id, testCase.Booking__c);
        system.assertEquals(bPass1.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass1.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void noBookingPassengerAgainstBooking(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking2 = [SELECT Id, Selling_Company__c, Full_Status__c FROM Booking__c WHERE Id = :booking2.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A123456-deBlah] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking2.Id, testCase.Booking__c);
        system.assertEquals(booking2.Selling_Company__c, testCase.Business_Unit__c);
    
    }
    
    @istest public static void multipleBookingPassengerWithCorrectLastNameOnLeadPassenger(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking3 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking3.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A234567-hoo] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, Booking_Passenger__r.Last_Name__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking3.Id, testCase.Booking__c);
        system.assertEquals(bPass2.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass2.id, testCase.Booking_Passenger__c);
        system.assertEquals(bPass2.Customer__r.personContactId, testCase.ContactId);
        system.assertEquals(bPass2.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void multipleBookingPassengerWithIncorrectLastNameOnLeadPassenger(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking3 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking3.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A234567-hotman] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, Booking_Passenger__r.Last_Name__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking3.Id, testCase.Booking__c);
        system.assertEquals(bPass3.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass3.id, testCase.Booking_Passenger__c);
        system.assertEquals(bPass3.Customer__r.personContactId, testCase.ContactId);
        system.assertEquals(bPass2.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void multipleBookingPassengerWithIncorrectLastName(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking3 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking3.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A234567-deBlah] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, Booking_Passenger__r.Last_Name__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking3.Id, testCase.Booking__c);
        system.assertEquals(bPass2.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass2.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void multipleBookingsOneWithCorrectLastName(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking3 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking3.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A345678-hoo] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, Booking_Passenger__r.Last_Name__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking4.Id, testCase.Booking__c);
        system.assertEquals(bPass4.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass4.id, testCase.Booking_Passenger__c);
        system.assertEquals(bPass4.Customer__r.personContactId, testCase.ContactId);
        system.assertEquals(bPass4.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void multipleBookingsNoneWithCorrectLastName(){
    
        createRecords();
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking3 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking3.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A345678-deBlah] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, Booking_Passenger__r.Last_Name__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking4.Id, testCase.Booking__c);
        system.assertEquals(bPass4.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass4.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    @istest public static void multipleBookingsWithMultipleCorrectLastNames(){
    
        createRecords();
        
        bPass6 = new Booking_Passenger__c(First_Name__c = 'flameo', Last_Name__c = 'hotman', Email__c = 'flameo@hotman.com', Lead_Passenger__c = false, Pax_No__c = '002', Business_Unit_Lookup__c = businessUnit.Id, Customer__c = personAccount2.Id, Booking__c = booking5.Id, Original_Booking_Date__c = (date.today() -2), recordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId());
        insert bPass6;
        bPass6 = [SELECT Id, Lead_Passenger__c, Pax_No__c, Customer__c, Customer__r.personContactId, Business_Unit_Lookup__c, Original_Booking_Date__c FROM Booking_Passenger__c WHERE Id = :bPass6.Id LIMIT 1];
        
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        booking3 = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :booking3.Id LIMIT 1];
        //system.assertEquals('Cancelled', testBooking.Full_Status__c);
        Case testCase = new Case(Subject = '[A345678-hotman] this is a test', Origin = 'Email2Case', SuppliedEmail = 'blahdeblah@gmail.com', Booking__c = testBooking.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId());
        testBooking = [SELECT Id, Full_Status__c FROM Booking__c WHERE Id = :testBooking.Id LIMIT 1];
        
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        testCase = [SELECT Id, Booking__c, Business_Unit__c, Booking_Passenger__c, Booking_Passenger__r.Last_Name__c, ContactId, Lead_Passenger__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        
        system.assertEquals(booking5.Id, testCase.Booking__c);
        system.assertEquals(bPass5.Business_Unit_Lookup__c, testCase.Business_Unit__c);
        system.assertEquals(bPass5.id, testCase.Booking_Passenger__c);
        system.assertEquals(bPass5.Customer__r.personContactId, testCase.ContactId);
        system.assertEquals(bPass5.Customer__c, testCase.Lead_Passenger__c);
    
    }
    
    public static void CreateRecords(){
    
        businessUnit = new Account(name = 'busUnit', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Business Unit').getRecordTypeId());
        insert businessUnit;
        
        personAccount1 = new Account(firstName = 'blah', lastName = 'deBlah', PersonEmail = 'blah@deblah.com', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert personAccount1;
        
        personAccount2 = new Account(firstName = 'flameo', lastName = 'hotman', PersonEmail = 'flameo@hotman.com', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert personAccount2;
        
        testBooking = new Booking__c(name = 'xxxxxx', Selling_Company__c = businessUnit.Id, Status__c = 'CO', recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId());
        insert testBooking;
        
        booking1 = new Booking__c(name = 'A012345', Selling_Company__c = businessUnit.Id, Status__c = 'CO', recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId());
        insert booking1;
        
        booking2 = new Booking__c(name = 'A123456', Selling_Company__c = businessUnit.Id, Status__c = 'CO', recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId());
        insert booking2;
        
        booking3 = new Booking__c(name = 'A234567', Selling_Company__c = businessUnit.Id, Status__c = 'CO', recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId());
        insert booking3;
        
        booking4 = new Booking__c(name = 'A345678', Selling_Company__c = businessUnit.Id, Status__c = 'CO', recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId());
        insert booking4;
        
        booking5 = new Booking__c(name = 'A345678', Selling_Company__c = businessUnit.Id, Status__c = 'CO', recordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId());
        insert booking5;
        
        bPass1 = new Booking_Passenger__c(First_Name__c = 'blah', Last_Name__c = 'deBlah', Email__c = 'blah@deblah.com', Lead_Passenger__c = true, Pax_No__c = '001', Business_Unit_Lookup__c = businessUnit.Id, Customer__c = personAccount1.Id, Booking__c = booking1.Id, recordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId());
        insert bPass1;
        bPass1 = [SELECT Id, Lead_Passenger__c, Pax_No__c, Customer__c, Customer__r.personContactId, Business_Unit_Lookup__c FROM Booking_Passenger__c WHERE Id = :bPass1.Id LIMIT 1];
        
        bPass2 = new Booking_Passenger__c(First_Name__c = 'yoo', Last_Name__c = 'hoo', Email__c = 'blah@deblah.com', Lead_Passenger__c = true, Pax_No__c = '001', Business_Unit_Lookup__c = businessUnit.Id, Customer__c = personAccount1.Id, Booking__c = booking3.Id, recordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId());
        insert bPass2;
        bPass2 = [SELECT Id, Last_Name__c, Lead_Passenger__c, Pax_No__c, Customer__c, Customer__r.personContactId, Business_Unit_Lookup__c FROM Booking_Passenger__c WHERE Id = :bPass2.Id LIMIT 1];
        
        bPass3 = new Booking_Passenger__c(First_Name__c = 'flameo', Last_Name__c = 'hotman', Email__c = 'flameo@hotman.com', Lead_Passenger__c = false, Pax_No__c = '002', Business_Unit_Lookup__c = businessUnit.Id, Customer__c = personAccount2.Id, Booking__c = booking3.Id, recordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId());
        insert bPass3;
        bPass3 = [SELECT Id, Lead_Passenger__c, Pax_No__c, Customer__c, Customer__r.personContactId, Business_Unit_Lookup__c FROM Booking_Passenger__c WHERE Id = :bPass3.Id LIMIT 1];
        
        bPass4 = new Booking_Passenger__c(First_Name__c = 'yoo', Last_Name__c = 'hoo', Email__c = 'blah@deblah.com', Lead_Passenger__c = true, Pax_No__c = '001', Business_Unit_Lookup__c = businessUnit.Id, Customer__c = personAccount1.Id, Booking__c = booking4.Id, Original_Booking_Date__c = date.today(), recordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId());
        insert bPass4;
        bPass4 = [SELECT Id, Last_Name__c, Lead_Passenger__c, Pax_No__c, Customer__c, Customer__r.personContactId, Business_Unit_Lookup__c, Original_Booking_Date__c FROM Booking_Passenger__c WHERE Id = :bPass4.Id LIMIT 1];
        
        bPass5 = new Booking_Passenger__c(First_Name__c = 'flameo', Last_Name__c = 'hotman', Email__c = 'flameo@hotman.com', Lead_Passenger__c = true, Pax_No__c = '001', Business_Unit_Lookup__c = businessUnit.Id, Customer__c = personAccount2.Id, Booking__c = booking5.Id, Original_Booking_Date__c = (date.today() -2), recordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId());
        insert bPass5;
        bPass5 = [SELECT Id, Lead_Passenger__c, Pax_No__c, Customer__c, Customer__r.personContactId, Business_Unit_Lookup__c, Original_Booking_Date__c FROM Booking_Passenger__c WHERE Id = :bPass5.Id LIMIT 1];
    
    }

}