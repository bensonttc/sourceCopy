@isTest private class countBookingComponentsTest{/*

    //Declate variables used in this test class
    private static Account personAcct1;
    private static Account personAcct2;
    private static Account personAcct3;
    private static Account personAcct4;
    private static Account personAcct5;
    private static Account businessUnit1;
    private static Account businessUnit2;
    private static Account businessUnit3;
    private static Account businessUnit4;
    private static Account businessUnit5;
    private static Account Trafalgar;
    private static Account Insight;
    private static Account Contiki;
    private static Account Uniworld;
    private static Account AATKings;
    private static Booking__c book1;
    private static Booking__c book2;
    private static Booking__c book3;
    private static Booking__c book4;
    private static Booking__c book5;
    private static Booking_Component__c bookComp1;
    private static Booking_Component__c bookComp2;
    private static Booking_Component__c bookComp3;
    private static Booking_Component__c bookComp4;
    private static Booking_Component__c bookComp5;
    private static Booking_Component__c bookComp6;
    private static Booking_Component__c bookComp7;
    private static Booking_Component__c bookComp8;
    private static Booking_Component__c bookComp9;
    private static Booking_Component__c bookComp10;
    private static Booking_Component__c bookComp11;
    private static Booking_Component__c bookComp12;
    private static Booking_Component__c bookComp13;
    private static Booking_Component__c bookComp14;
    private static Booking_Component__c bookComp15;
    private static Booking_Passenger__c bookPass1;
    private static Booking_Passenger__c bookPass2;
    private static Booking_Passenger__c bookPass3;
    private static Booking_Passenger__c bookPass4;
    private static Booking_Passenger__c bookPass5;
    private static Id tourRecordTypeId = Schema.SObjectType.Booking_Component__c.getRecordTypeInfosByName().get('Tour').getRecordTypeId();
    private static Id flightRecordTypeId = Schema.SObjectType.Booking_Component__c.getRecordTypeInfosByName().get('Flight').getRecordTypeId();
    private static Id bookingRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
    private static Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    private static Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Unit').getRecordTypeId();
    private static Id brandRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
    
    //In the first test, the records are all created, going through the trigger once. then 10 of the 15 Booking components are edited. this will mean for each account, two records will be edited and one more will count up even thpough it wasn't edited
    public static testMethod void testCountBookingComponents1(){

        CreateRecords();
        
        List<Booking_Component__c> bookingComps = new List<Booking_Component__c>();
        
        bookComp1.Status__c = 'CF';
        bookComp2.Status__c = 'CF';
        bookComp3.Status__c = 'CF';
        bookComp4.Status__c = 'CF';
        bookComp5.Status__c = 'CF';
        bookComp6.Status__c = 'CF';
        bookComp7.Status__c = 'CF';
        bookComp8.Status__c = 'CF';
        bookComp9.Status__c = 'CF';
        bookComp10.Status__c = 'CF';
        
        bookingComps.add(bookComp1);
        bookingComps.add(bookComp2);
        bookingComps.add(bookComp3);
        bookingComps.add(bookComp4);
        bookingComps.add(bookComp5);
        bookingComps.add(bookComp6);
        bookingComps.add(bookComp7);
        bookingComps.add(bookComp8);
        bookingComps.add(bookComp9);
        bookingComps.add(bookComp10);
        
        test.startTest();
        update bookingComps;
        test.stopTest();
        
        personAcct1 = [SELECT Id, Trafalgar_Tour_Count__c FROM Account WHERE Id = :personAcct1.Id];
        system.assertEquals(personAcct1.Trafalgar_Tour_Count__c, 3);
        
    }
    
    //In test 2, after the records are created, edit one of them to be cancelled. this will loop through the cancelled part of the trigger
    public static testMethod void testCountBookingComponents2(){

        CreateRecords();
        
        List<Booking_Component__c> bookingComps = new List<Booking_Component__c>();
        
        bookComp1.Status__c = 'CF';
        bookComp2.Status__c = 'CF';
        bookComp3.Status__c = 'CF';
        bookComp4.Status__c = 'CF';
        bookComp6.Status__c = 'CF';
        bookComp7.Status__c = 'CF';
        bookComp8.Status__c = 'CF';
        bookComp9.Status__c = 'CF';
        
        bookingComps.add(bookComp1);
        bookingComps.add(bookComp2);
        bookingComps.add(bookComp3);
        bookingComps.add(bookComp4);
        bookingComps.add(bookComp6);
        bookingComps.add(bookComp7);
        bookingComps.add(bookComp8);
        bookingComps.add(bookComp9);
        
        update bookingComps;
        
        bookComp1.Status__c = 'CX';
        bookComp2.Status__c = 'CX';
        bookComp3.Status__c = 'CX';
        bookComp4.Status__c = 'CX';
        
        update bookComp1;
        update bookComp2;
        update bookComp3;
        update bookComp4;
        
        personAcct1 = [SELECT Id, Trafalgar_Tour_Count__c FROM Account WHERE Id = :personAcct1.Id LIMIT 1];
        system.assertEquals(personAcct1.Trafalgar_Tour_Count__c, 2);
        
    }
    
    //use a method to create the records based on those variables
    public static void CreateRecords(){
    
        personAcct1 = new Account(firstName = 'Mister', lastName = 'A', recordTypeId = customerRecordTypeId);
        insert personAcct1;
        
        personAcct2 = new Account(firstName = 'Mister', lastName = 'B', recordTypeId = customerRecordTypeId);
        insert personAcct2;
        
        personAcct3 = new Account(firstName = 'Mister', lastName = 'C', recordTypeId = customerRecordTypeId);
        insert personAcct3;
        
        personAcct4 = new Account(firstName = 'Mister', lastName = 'D', recordTypeId = customerRecordTypeId);
        insert personAcct4;
        
        personAcct5 = new Account(firstName = 'Mister', lastName = 'E', recordTypeId = customerRecordTypeId);
        insert personAcct5;
        
        Trafalgar = new Account(Name = 'Trafalgar', recordTypeId = brandRecordTypeId);
        insert Trafalgar;
        
        Insight = new Account(Name = 'Insight', recordTypeId = brandRecordTypeId);
        insert Insight;
        
        Contiki = new Account(Name = 'Contiki', recordTypeId = brandRecordTypeId);
        insert Contiki;
        
        Uniworld = new Account(Name = 'Uniworld', recordTypeId = brandRecordTypeId);
        insert Uniworld;
        
        AATKings = new Account(Name = 'AAT Kings', recordTypeId = brandRecordTypeId);
        insert AATKings;
        
        businessUnit1 = new Account(Name = 'Trafalgar', recordTypeId = businessRecordTypeId, ParentId = Trafalgar.Id);
        insert businessUnit1;
        
        businessUnit2 = new Account(Name = 'Insight', recordTypeId = businessRecordTypeId, ParentId = Insight.Id);
        insert businessUnit2;
        
        businessUnit3 = new Account(Name = 'Contiki', recordTypeId = businessRecordTypeId, ParentId = Contiki.Id);
        insert businessUnit3;
        
        businessUnit4 = new Account(Name = 'Uniworld', recordTypeId = businessRecordTypeId, ParentId = Uniworld.Id);
        insert businessUnit4;
        
        businessUnit5 = new Account(Name = 'AAT Kings', recordTypeId = businessRecordTypeId, ParentId = AATKings.Id);
        insert businessUnit5;
        
        book1 = new Booking__c(Selling_Company__c = businessUnit1.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', CurrencyISOCode = 'GBP', Name = 'A12345678');
        insert book1;
        
        book2 = new Booking__c(Selling_Company__c = businessUnit2.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', CurrencyISOCode = 'GBP', Name = 'A12345679');
        insert book2;
        
        book3 = new Booking__c(Selling_Company__c = businessUnit3.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', CurrencyISOCode = 'GBP', Name = 'A12345670');
        insert book3;
        
        book4 = new Booking__c(Selling_Company__c = businessUnit4.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', CurrencyISOCode = 'GBP', Name = 'A12345681');
        insert book4;
        
        book5 = new Booking__c(Selling_Company__c = businessUnit5.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', CurrencyISOCode = 'GBP', Name = 'A12345682');
        insert book5;
        
        bookPass1 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#001', First_Name__c = 'Mister', Last_Name__c = 'A', Booking__c = book1.Id, Customer__c = personAcct1.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass1;
        
        bookPass2 = new Booking_Passenger__c(Name = 'TTUSAS#A12345679#001', First_Name__c = 'Mister', Last_Name__c = 'B', Booking__c = book2.Id, Customer__c = personAcct2.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass2;
        
        bookPass3 = new Booking_Passenger__c(Name = 'TTUSAS#A12345670#001', First_Name__c = 'Mister', Last_Name__c = 'C', Booking__c = book3.Id, Customer__c = personAcct3.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass3;
        
        bookPass4 = new Booking_Passenger__c(Name = 'TTUSAS#A12345681#001', First_Name__c = 'Mister', Last_Name__c = 'D', Booking__c = book4.Id, Customer__c = personAcct4.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass4;
        
        bookPass5 = new Booking_Passenger__c(Name = 'TTUSAS#A12345682#001', First_Name__c = 'Mister', Last_Name__c = 'E', Booking__c = book5.Id, Customer__c = personAcct5.Id, Pax_no__c = '001', Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        insert bookPass5;
        
        bookComp1 = new Booking_Component__c(Name = 'TTUSAS-A12345678-001-JPNLN11-04I16a', Booking_Number__c = book1.Id, Customer__c = personAcct1.Id, Booking_Passenger__c = bookPass1.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp1;
        
        bookComp2 = new Booking_Component__c(Name = 'TTUSAS-A12345679-001-JPNLN11-04I16a', Booking_Number__c = book2.Id, Customer__c = personAcct2.Id, Booking_Passenger__c = bookPass2.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp2;
        
        bookComp3 = new Booking_Component__c(Name = 'TTUSAS-A12345670-001-JPNLN11-04I16a', Booking_Number__c = book3.Id, Customer__c = personAcct3.Id, Booking_Passenger__c = bookPass3.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp3;
        
        bookComp4 = new Booking_Component__c(Name = 'TTUSAS-A12345681-001-JPNLN11-04I16a', Booking_Number__c = book4.Id, Customer__c = personAcct4.Id, Booking_Passenger__c = bookPass4.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp4;
        
        bookComp5 = new Booking_Component__c(Name = 'TTUSAS-A12345682-001-JPNLN11-04I16a', Booking_Number__c = book5.Id, Customer__c = personAcct5.Id, Booking_Passenger__c = bookPass5.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp5;
        
        bookComp6 = new Booking_Component__c(Name = 'TTUSAS-A12345678-001-JPNLN11-04I16a', Booking_Number__c = book1.Id, Customer__c = personAcct1.Id, Booking_Passenger__c = bookPass1.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp6;
        
        bookComp7 = new Booking_Component__c(Name = 'TTUSAS-A12345679-001-JPNLN11-04I16a', Booking_Number__c = book2.Id, Customer__c = personAcct2.Id, Booking_Passenger__c = bookPass2.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp7;
        
        bookComp8 = new Booking_Component__c(Name = 'TTUSAS-A12345670-001-JPNLN11-04I16a', Booking_Number__c = book3.Id, Customer__c = personAcct3.Id, Booking_Passenger__c = bookPass3.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp8;
        
        bookComp9 = new Booking_Component__c(Name = 'TTUSAS-A12345681-001-JPNLN11-04I16a', Booking_Number__c = book4.Id, Customer__c = personAcct4.Id, Booking_Passenger__c = bookPass4.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp9;
        
        bookComp10 = new Booking_Component__c(Name = 'TTUSAS-A12345682-001-JPNLN11-04I16a', Booking_Number__c = book5.Id, Customer__c = personAcct5.Id, Booking_Passenger__c = bookPass5.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CX', CurrencyISOCode = 'USD');
        insert bookComp10;
        
        bookComp11 = new Booking_Component__c(Name = 'TTUSAS-A12345678-001-JPNLN11-04I16a', Booking_Number__c = book1.Id, Customer__c = personAcct1.Id, Booking_Passenger__c = bookPass1.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CF', CurrencyISOCode = 'USD');
        insert bookComp11;
        
        bookComp12 = new Booking_Component__c(Name = 'TTUSAS-A12345679-001-JPNLN11-04I16a', Booking_Number__c = book2.Id, Customer__c = personAcct2.Id, Booking_Passenger__c = bookPass2.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CF', CurrencyISOCode = 'USD');
        insert bookComp12;
        
        bookComp13 = new Booking_Component__c(Name = 'TTUSAS-A12345670-001-JPNLN11-04I16a', Booking_Number__c = book3.Id, Customer__c = personAcct3.Id, Booking_Passenger__c = bookPass3.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CF', CurrencyISOCode = 'USD');
        insert bookComp13;
        
        bookComp14 = new Booking_Component__c(Name = 'TTUSAS-A12345681-001-JPNLN11-04I16a', Booking_Number__c = book4.Id, Customer__c = personAcct4.Id, Booking_Passenger__c = bookPass4.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CF', CurrencyISOCode = 'USD');
        insert bookComp14;
        
        bookComp15 = new Booking_Component__c(Name = 'TTUSAS-A12345682-001-JPNLN11-04I16a', Booking_Number__c = book5.Id, Customer__c = personAcct5.Id, Booking_Passenger__c = bookPass5.Id, RecordTypeId = tourRecordTypeId, Status__c = 'CF', CurrencyISOCode = 'USD');
        insert bookComp15;
    }

*/}