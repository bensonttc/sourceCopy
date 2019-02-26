@isTest private class bookingPassengerTriggerHandler_Test{

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
    private static Account Trafalgar;
    private static Account Insight;
    private static Account Contiki;
    private static Account Uniworld;
    private static Booking__c book1;
    private static Booking__c book2;
    private static Booking__c book3;
    private static Booking__c book4;
    private static Booking__c book5;
    private static Booking__c book11;
    private static Booking__c book22;
    private static Booking__c book33;
    private static Booking__c book44;
    private static Booking_Passenger__c bookPass1;
    private static Booking_Passenger__c bookPass2;
    private static Booking_Passenger__c bookPass3;
    private static Booking_Passenger__c bookPass4;
    private static Booking_Passenger__c bookPass11;
    private static Booking_Passenger__c bookPass21;
    private static Booking_Passenger__c bookPass31;
    private static Booking_Passenger__c bookPass41;
    private static Booking_Passenger__c bookPass12;
    private static Booking_Passenger__c bookPass22;
    private static Booking_Passenger__c bookPass32;
    private static Booking_Passenger__c bookPass42;
    private static Id b2b2cRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B2C Opportunity').getRecordTypeId();
    private static Id bookingRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
    private static Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    private static Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Unit').getRecordTypeId();
    private static Id brandRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
    private static List<Account> accts = new List<Account>();
    private static List<Booking__c> books = new List<Booking__c>();
    private static List<Booking_Passenger__c> bookPasses = new List<Booking_Passenger__c>();
    
    public static testMethod void confirmTrafalgarBooking(){
    
        createRecords();
        
        bookPass1.Client_Status__c = 'Confirmed';
        
        test.StartTest();
        update bookPass1;
        test.StopTest();
        
        personAcct1 = [SELECT Id, Next_Trafalgar_Booking__c, TT_Booking__c FROM Account WHERE ID = :personAcct1.Id];
        bookPass1 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass1.Id];
        
        system.assertEquals(personAcct1.Next_Trafalgar_Booking__c, bookPass1.First_Departure_Date_Text__c);
        system.assertEquals(personAcct1.TT_Booking__c, bookPass1.Booking__c);
        
    }
    
    public static testMethod void confirmInsightBooking(){
    
        createRecords();
        
        bookPass2.Client_Status__c = 'Confirmed';
        
        test.StartTest();
        update bookPass2;
        test.StopTest();
        
        personAcct2 = [SELECT Id, Next_Insight_Booking__c, IV_Booking__c FROM Account WHERE ID = :personAcct2.Id];
        bookPass2 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass2.Id];
        
        system.assertEquals(personAcct2.Next_Insight_Booking__c, bookPass2.First_Departure_Date_Text__c);
        system.assertEquals(personAcct2.IV_Booking__c, bookPass2.Booking__c);
        
    }
    
    public static testMethod void confirmContikiBooking(){
    
        createRecords();
        
        bookPass3.Client_Status__c = 'Confirmed';
        
        test.StartTest();
        update bookPass3;
        test.StopTest();
        
        personAcct3 = [SELECT Id, Next_Contiki_Booking__c, CH_Booking__c FROM Account WHERE ID = :personAcct3.Id];
        bookPass3 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass3.Id];
        
        system.assertEquals(personAcct3.Next_Contiki_Booking__c, bookPass3.First_Departure_Date_Text__c);
        system.assertEquals(personAcct3.CH_Booking__c, bookPass3.Booking__c);
        
    }
    
    public static testMethod void confirmUniworldBooking(){
    
        createRecords();
        
        bookPass4.Customer__c = personAcct4.Id;
        
        test.StartTest();
        update bookPass4;
        test.StopTest();
        
        personAcct4 = [SELECT Id, Next_Uniworld_Booking__c, UW_Booking__c FROM Account WHERE ID = :personAcct4.Id];
        bookPass4 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass4.Id];
        
        system.assertEquals(personAcct4.Next_Uniworld_Booking__c, bookPass4.First_Departure_Date_Text__c);
        system.assertEquals(personAcct4.UW_Booking__c, bookPass4.Booking__c);
        
    }
    
    public static testMethod void confirmTrafalgarBookingDateAlreadyOnAccount(){
    
        createRecords();
        
        personAcct1.Next_Trafalgar_Booking__c = date.Today() - 5;
        update personAcct1;
        
        bookPass1.Client_Status__c = 'Confirmed';
        
        test.StartTest();
        update bookPass1;
        test.StopTest();
        
        personAcct1 = [SELECT Id, Next_Trafalgar_Booking__c, TT_Booking__c FROM Account WHERE ID = :personAcct1.Id];
        bookPass1 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass1.Id];
        
        system.assertEquals(personAcct1.Next_Trafalgar_Booking__c, bookPass1.First_Departure_Date_Text__c);
        system.assertEquals(personAcct1.TT_Booking__c, bookPass1.Booking__c);
        
    }
    
    public static testMethod void confirmInsightBookingDateAlreadyOnAccount(){
    
        createRecords();
        
        personAcct2.Next_Insight_Booking__c = date.Today() - 5;
        update personAcct2;
        
        bookPass2.Client_Status__c = 'Confirmed';
        
        test.StartTest();
        update bookPass2;
        test.StopTest();
        
        personAcct2 = [SELECT Id, Next_Insight_Booking__c, IV_Booking__c FROM Account WHERE ID = :personAcct2.Id];
        bookPass2 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass2.Id];
        
        system.assertEquals(personAcct2.Next_Insight_Booking__c, bookPass2.First_Departure_Date_Text__c);
        system.assertEquals(personAcct2.IV_Booking__c, bookPass2.Booking__c);
        
    }
    
    public static testMethod void confirmContikiBookingDateAlreadyOnAccount(){
    
        createRecords();
        
        personAcct3.Next_Contiki_Booking__c = date.Today() - 5;
        update personAcct3;
        
        bookPass3.Client_Status__c = 'Confirmed';
        
        test.StartTest();
        update bookPass3;
        test.StopTest();
        
        personAcct3 = [SELECT Id, Next_Contiki_Booking__c, CH_Booking__c FROM Account WHERE ID = :personAcct3.Id];
        bookPass3 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass3.Id];
        
        system.assertEquals(personAcct3.Next_Contiki_Booking__c, bookPass3.First_Departure_Date_Text__c);
        system.assertEquals(personAcct3.CH_Booking__c, bookPass3.Booking__c);
        
    }
    
    public static testMethod void confirmUniworldBookingDateAlreadyOnAccount(){
    
        createRecords();
        
        personAcct4.Next_Uniworld_Booking__c = date.Today() - 5;
        update personAcct4;
        
        bookPass4.Customer__c = personAcct4.Id;
        
        test.StartTest();
        update bookPass4;
        test.StopTest();
        
        personAcct4 = [SELECT Id, Next_Uniworld_Booking__c, UW_Booking__c FROM Account WHERE ID = :personAcct4.Id];
        bookPass4 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass4.Id];
        
        system.assertEquals(personAcct4.Next_Uniworld_Booking__c, bookPass4.First_Departure_Date_Text__c);
        system.assertEquals(personAcct4.UW_Booking__c, bookPass4.Booking__c);
        
    }
    
    public static testMethod void cancelTrafalgarBookingFindAnother(){
    
        createRecords();
        
        bookPass11 = [SELECT Id, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass11.Id];
        personAcct1.Next_Trafalgar_Booking__c = bookPass11.First_Departure_Date_Text__c;
        bookPass11.Client_Status__c = 'Cancelled';
        
        test.StartTest();
        update personAcct1;
        update bookPass11;
        test.StopTest();
        
        personAcct1 = [SELECT Id, Next_Trafalgar_Booking__c, TT_Booking__c FROM Account WHERE ID = :personAcct1.Id];
        bookPass12 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass12.Id];
        
        system.assertEquals(personAcct1.Next_Trafalgar_Booking__c, bookPass12.First_Departure_Date_Text__c);
        system.assertEquals(personAcct1.TT_Booking__c, bookPass12.Booking__c);
        
    }
    
    public static testMethod void cancelInsightBookingFindAnother(){
    
        createRecords();
        
        bookPass21 = [SELECT Id, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass21.Id];
        personAcct2.Next_Insight_Booking__c = bookPass21.First_Departure_Date_Text__c;
        bookPass21.Client_Status__c = 'Cancelled';
        
        test.StartTest();
        update personAcct2;
        update bookPass21;
        test.StopTest();
        
        personAcct2 = [SELECT Id, Next_Insight_Booking__c, IV_Booking__c FROM Account WHERE ID = :personAcct2.Id];
        bookPass22 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass22.Id];
        
        system.assertEquals(personAcct2.Next_Insight_Booking__c, bookPass22.First_Departure_Date_Text__c);
        system.assertEquals(personAcct2.IV_Booking__c, bookPass22.Booking__c);
        
    }
    
    public static testMethod void cancelContikiBookingFindAnother(){
    
        createRecords();
        
        bookPass31 = [SELECT Id, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass31.Id];
        personAcct3.Next_Contiki_Booking__c = bookPass31.First_Departure_Date_Text__c;
        bookPass31.Client_Status__c = 'Cancelled';
        
        test.StartTest();
        update personAcct3;
        update bookPass31;
        test.StopTest();
        
        personAcct3 = [SELECT Id, Next_Contiki_Booking__c, CH_Booking__c FROM Account WHERE ID = :personAcct3.Id];
        bookPass32 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass32.Id];
        
        system.assertEquals(personAcct3.Next_Contiki_Booking__c, bookPass32.First_Departure_Date_Text__c);
        system.assertEquals(personAcct3.CH_Booking__c, bookPass32.Booking__c);
        
    }
    
    public static testMethod void cancelUniworldBookingFindAnother(){
    
        createRecords();
        
        bookPass41 = [SELECT Id, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass41.Id];
        personAcct4.Next_Uniworld_Booking__c = bookPass41.First_Departure_Date_Text__c;
        bookPass41.Client_Status__c = 'Cancelled';
        
        test.StartTest();
        update personAcct4;
        update bookPass41;
        test.StopTest();
        
        personAcct4 = [SELECT Id, Next_Uniworld_Booking__c, UW_Booking__c FROM Account WHERE ID = :personAcct4.Id];
        bookPass42 = [SELECT Id, Booking__c, First_Departure_Date_Text__c FROM Booking_Passenger__c WHERE Id = :bookPass42.Id];
        
        system.assertEquals(personAcct4.Next_Uniworld_Booking__c, bookPass42.First_Departure_Date_Text__c);
        system.assertEquals(personAcct4.UW_Booking__c, bookPass42.Booking__c);
        
    }
    
    public static void createRecords(){
    
        personAcct1 = new Account(firstName = 'Mister', lastName = 'A', recordTypeId = customerRecordTypeId);
        accts.add(personAcct1);
        
        personAcct2 = new Account(firstName = 'Mister', lastName = 'B', recordTypeId = customerRecordTypeId);
        accts.add(personAcct2);
        
        personAcct3 = new Account(firstName = 'Mister', lastName = 'C', recordTypeId = customerRecordTypeId);
        accts.add(personAcct3);
        
        personAcct4 = new Account(firstName = 'Mister', lastName = 'D', recordTypeId = customerRecordTypeId);
        accts.add(personAcct4);
        
        personAcct5 = new Account(firstName = 'Mister', lastName = 'E', recordTypeId = customerRecordTypeId);
        accts.add(personAcct5);
        
        Trafalgar = new Account(Name = 'Trafalgar', recordTypeId = brandRecordTypeId);
        accts.add(Trafalgar);
        
        Insight = new Account(Name = 'Insight', recordTypeId = brandRecordTypeId);
        accts.add(Insight);
        
        Contiki = new Account(Name = 'Contiki', recordTypeId = brandRecordTypeId);
        accts.add(Contiki);
        
        Uniworld = new Account(Name = 'Uniworld', recordTypeId = brandRecordTypeId);
        accts.add(Uniworld);
        
        insert accts;
        accts.clear();
        
        businessUnit1 = new Account(Name = 'Trafalgar', recordTypeId = businessRecordTypeId, ParentId = Trafalgar.Id);
        accts.add(businessUnit1);
        
        businessUnit2 = new Account(Name = 'Insight', recordTypeId = businessRecordTypeId, ParentId = Insight.Id);
        accts.add(businessUnit2);
        
        businessUnit3 = new Account(Name = 'Contiki', recordTypeId = businessRecordTypeId, ParentId = Contiki.Id);
        accts.add(businessUnit3);
        
        businessUnit4 = new Account(Name = 'Uniworld', recordTypeId = businessRecordTypeId, ParentId = Uniworld.Id);
        accts.add(businessUnit4);
        
        insert accts;
        
        book1 = new Booking__c(Selling_Company__c = businessUnit1.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +3, CurrencyISOCode = 'GBP', Name = 'A12345678');
        books.add(book1);
        
        book2 = new Booking__c(Selling_Company__c = businessUnit2.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +3, CurrencyISOCode = 'GBP', Name = 'A12345679');
        books.add(book2);
        
        book3 = new Booking__c(Selling_Company__c = businessUnit3.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +3, CurrencyISOCode = 'GBP', Name = 'A12345670');
        books.add(book3);
        
        book4 = new Booking__c(Selling_Company__c = businessUnit4.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +3, CurrencyISOCode = 'GBP', Name = 'A12345681');
        books.add(book4);
        
        book11 = new Booking__c(Selling_Company__c = businessUnit1.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +1, CurrencyISOCode = 'GBP', Name = 'A12345678');
        books.add(book11);
        
        book22 = new Booking__c(Selling_Company__c = businessUnit2.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +1, CurrencyISOCode = 'GBP', Name = 'A12345679');
        books.add(book22);
        
        book33 = new Booking__c(Selling_Company__c = businessUnit3.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +1, CurrencyISOCode = 'GBP', Name = 'A12345670');
        books.add(book33);
        
        book44 = new Booking__c(Selling_Company__c = businessUnit4.Id, recordTypeId = bookingRecordTypeId, Booking_Type__c = 'Travel Agent', Payment_Status__c = 'FP', First_Departure_Date__c = date.Today() +1, CurrencyISOCode = 'GBP', Name = 'A12345681');
        books.add(book44);
        
        insert books;
        
        bookPass1 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#001', First_Name__c = 'Mister', Last_Name__c = 'A', Booking__c = book1.Id, Customer__c = personAcct1.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +1, Brand__c = trafalgar.Id, Client_Status__c = 'Cancelled', currencyISOCode = 'USD');
        bookPasses.add(bookPass1);
        
        bookPass11 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#002', First_Name__c = 'Mister', Last_Name__c = 'AA', Booking__c = book1.Id, Customer__c = personAcct1.Id, Pax_no__c = '002', First_Departure_Date__c = date.today() +3, Brand__c = trafalgar.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass11);
        
        bookPass12 = new Booking_Passenger__c(Name = 'TTUSAS#A12345678#002', First_Name__c = 'Mister', Last_Name__c = 'AA', Booking__c = book11.Id, Customer__c = personAcct1.Id, Pax_no__c = '003', First_Departure_Date__c = date.today() +5, Brand__c = trafalgar.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass12);
        
        bookPass2 = new Booking_Passenger__c(Name = 'TTUSAS#A12345679#001', First_Name__c = 'Mister', Last_Name__c = 'B', Booking__c = book2.Id, Customer__c = personAcct2.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() +1, Brand__c = insight.Id, Client_Status__c = 'Cancelled', currencyISOCode = 'USD');
        bookPasses.add(bookPass2);
        
        bookPass21 = new Booking_Passenger__c(Name = 'TTUSAS#A12345679#001', First_Name__c = 'Mister', Last_Name__c = 'BB', Booking__c = book2.Id, Customer__c = personAcct2.Id, Pax_no__c = '002', First_Departure_Date__c = date.today() +3, Brand__c = insight.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass21);
        
        bookPass22 = new Booking_Passenger__c(Name = 'TTUSAS#A12345679#001', First_Name__c = 'Mister', Last_Name__c = 'BB', Booking__c = book22.Id, Customer__c = personAcct2.Id, Pax_no__c = '003', First_Departure_Date__c = date.today() +5, Brand__c = insight.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass22);
        
        bookPass3 = new Booking_Passenger__c(Name = 'TTUSAS#A12345670#001', First_Name__c = 'Mister', Last_Name__c = 'C', Booking__c = book3.Id, Customer__c = personAcct3.Id, Pax_no__c = '001', First_Departure_Date__c = date.today() -1, Brand__c = contiki.Id, Client_Status__c = 'Cancelled', currencyISOCode = 'USD');
        bookPasses.add(bookPass3);
        
        bookPass31 = new Booking_Passenger__c(Name = 'TTUSAS#A12345670#001', First_Name__c = 'Mister', Last_Name__c = 'CC', Booking__c = book3.Id, Customer__c = personAcct3.Id, Pax_no__c = '002', First_Departure_Date__c = date.today() +3, Brand__c = contiki.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass31);
        
        bookPass32 = new Booking_Passenger__c(Name = 'TTUSAS#A12345670#001', First_Name__c = 'Mister', Last_Name__c = 'CC', Booking__c = book33.Id, Customer__c = personAcct3.Id, Pax_no__c = '003', First_Departure_Date__c = date.today() +5, Brand__c = contiki.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass32);
        
        bookPass4 = new Booking_Passenger__c(Name = 'TTUSAS#A12345681#001', First_Name__c = 'Mister', Last_Name__c = 'D', Booking__c = book4.Id, Customer__c = Null, Pax_no__c = '001', First_Departure_Date__c = date.today() +1, Brand__c = uniworld.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass4);
        
        bookPass41 = new Booking_Passenger__c(Name = 'TTUSAS#A12345681#001', First_Name__c = 'Mister', Last_Name__c = 'DD', Booking__c = book4.Id, Customer__c = personAcct4.Id, Pax_no__c = '002', First_Departure_Date__c = date.today() +3, Brand__c = uniworld.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass41);
        
        bookPass42 = new Booking_Passenger__c(Name = 'TTUSAS#A12345681#001', First_Name__c = 'Mister', Last_Name__c = 'DD', Booking__c = book44.Id, Customer__c = personAcct4.Id, Pax_no__c = '003', First_Departure_Date__c = date.today() +5, Brand__c = uniworld.Id, Client_Status__c = 'Confirmed', currencyISOCode = 'USD');
        bookPasses.add(bookPass42);
        
        insert bookPasses;
    
    }

}