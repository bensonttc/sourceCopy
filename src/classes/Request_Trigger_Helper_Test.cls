@istest(seealldata=true) private class Request_Trigger_Helper_Test {

    //declare variables that will be used in test
    private static Request__c req1;
    private static Request__c req2;
    private static Account personAcct1;
    private static Account personAcct2;
    private static Account businessUnit1;
    private static Account businessUnit2;
    private static Account Insight;
    private static Account Contiki;
    private static Booking__c book1;
    private static Booking__c book2;
    private static Booking__c book3;
    private static Booking__c book4;
    private static Booking_Passenger__c bookPass1;
    private static Booking_Passenger__c bookPass2;
    private static Booking_Passenger__c bookPass3;
    private static Booking_Passenger__c bookPass4;
    private static Booking_Passenger__c bookPass5;
    private static Booking_Passenger__c bookPass6;
    private static Id bookingRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
    private static Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    private static Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Unit').getRecordTypeId();
    private static Id brandRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
    private static List<Account> accts = new List<Account>();
    private static List<Booking__c> books = new List<Booking__c>();
    private static List<Booking_Passenger__c> bookPasses = new List<Booking_Passenger__c>();
    private static List<Request__c> reqs = new List<Request__c>();
    
    public static testMethod void createLead(){
        
        createRecords();
        
        req1 = [SELECT Id FROM Request__c WHERE Selling_Company__c = 'IVCANS' and Customer__c = NULL and Request_Type__c = 'Request A Brochure' LIMIT 1];
        
        req1.Customer__c = personAcct1.Id;
        
        test.StartTest();
        update req1;
        test.StopTest();
    
    }
    
    public static testMethod void createOpportunity(){
        
        createRecords();
        
        req2 = [SELECT Id FROM Request__c WHERE Selling_Company__c = 'CHCANS' and Customer__c = NULL and Request_Type__c = 'Request A Brochure' LIMIT 1];
        
        req2.Customer__c = personAcct1.Id;
        
        test.StartTest();
        update req2;
        test.StopTest();
    
    }
    
    public static testMethod void futureLead(){
        
        createRecords();
        
        req1 = [SELECT Id FROM Request__c WHERE Selling_Company__c = 'IVCANS' and Customer__c = NULL and Request_Type__c = 'Request A Brochure' LIMIT 1];
        
        req1.Customer__c = personAcct2.Id;
        
        test.StartTest();
        update req1;
        test.StopTest();
    
    }
    
    public static testMethod void futureOpportunity(){
        
        createRecords();
        
        req2 = [SELECT Id FROM Request__c WHERE Selling_Company__c = 'CHCANS' and Customer__c = NULL and Request_Type__c = 'Request A Brochure' LIMIT 1];
        
        req2.Customer__c = personAcct2.Id;
        
        test.StartTest();
        update req2;
        test.StopTest();
    
    }
    
    public static void createRecords(){
        
        personAcct1 = new Account(firstName = 'Mister', lastName = 'A', Insight_Tour_Count__c = 1, recordTypeId = customerRecordTypeId);
        accts.add(personAcct1);
        
        personAcct2 = new Account(firstName = 'Mister', lastName = 'A', Contiki_Tour_Count__c = 1, recordTypeId = customerRecordTypeId);
        accts.add(personAcct2);
        
        Insight = new Account(Name = 'Insight', recordTypeId = brandRecordTypeId);
        accts.add(Insight);
        
        Contiki = new Account(Name = 'Contiki', recordTypeId = brandRecordTypeId);
        accts.add(Contiki);
        
        businessUnit1 = new Account(Name = 'Insight', recordTypeId = businessRecordTypeId, ParentId = Insight.Id);
        accts.add(businessUnit1);
        
        businessUnit2 = new Account(Name = 'Contiki', recordTypeId = businessRecordTypeId, ParentId = Contiki.Id);
        accts.add(businessUnit2);
        
        insert accts;
        
        book1 = new Booking__c(Selling_Company__c = businessUnit1.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() -3, CurrencyISOCode = 'GBP', Name = 'A12345678');
        books.add(book1);
        
        book2 = new Booking__c(Selling_Company__c = businessUnit2.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() -3, CurrencyISOCode = 'GBP', Name = 'A12345678');
        books.add(book2);
        
        book3 = new Booking__c(Selling_Company__c = businessUnit1.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +3, CurrencyISOCode = 'GBP', Name = 'A12345678');
        books.add(book3);
        
        book4 = new Booking__c(Selling_Company__c = businessUnit2.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +3, CurrencyISOCode = 'GBP', Name = 'A12345678');
        books.add(book4);
        
        insert books;
        
        bookPass1 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#001', First_Name__c = 'Mister', Last_Name__c = 'A', Booking__c = book1.Id, Customer__c = personAcct1.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +1, Brand__c = insight.Id, Client_Status__c = 'Cancelled', currencyISOCode = 'USD');
        bookPasses.add(bookPass1);
        
        bookPass2 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#002', First_Name__c = 'Mister', Last_Name__c = 'AA', Booking__c = book2.Id, Customer__c = personAcct1.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +3, Brand__c = insight.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass2);
        
        bookPass3 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#003', First_Name__c = 'Mister', Last_Name__c = 'AA', Booking__c = book3.Id, Customer__c = personAcct2.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +5, Brand__c = insight.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass3);
        
        bookPass4 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#001', First_Name__c = 'Mister', Last_Name__c = 'A', Booking__c = book4.Id, Customer__c = personAcct2.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +1, Brand__c = contiki.Id, Client_Status__c = 'Cancelled', currencyISOCode = 'USD');
        bookPasses.add(bookPass4);
        
        bookPass5 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#002', First_Name__c = 'Mister', Last_Name__c = 'AA', Booking__c = book2.Id, Customer__c = personAcct2.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +3, Brand__c = contiki.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass5);
        
        bookPass6 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#003', First_Name__c = 'Mister', Last_Name__c = 'AA', Booking__c = book2.Id, Customer__c = personAcct2.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +5, Brand__c = contiki.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass6);
        
        insert bookPasses;
        
    }
    
}