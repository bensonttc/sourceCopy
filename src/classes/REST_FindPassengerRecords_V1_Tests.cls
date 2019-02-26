@istest private class REST_FindPassengerRecords_V1_Tests {
    
    //Declare variables that will be used in test
    private static Account personAcc;
    private static Account personAcc1;
    private static Account businessAcc;
    private static Account businessAcc2;
    private static Account businessAcc3;
    private static Passenger__c pass;
    private static Passenger__c pass2;
    private static Passenger__c pass3;
    private static Passenger__c pass4;
    private static Booking_Passenger__c bPass;
    private static Booking_Passenger__c bPass2;
    private static Booking_Passenger__c bPass3;
    private static Booking_Component__c bComp;
    private static Booking_Component__c bComp2;
    private static Booking_Component__c bComp3;
    private static Booking__c book;
    private static Booking__c book2;
    private static Booking__c book3;
    private static Tour_Product__c product;
    private static Tour_Product__c product1;
    private static Tour_Product__c product2;
    private static Tour_Product__c product3;
    
    //First test will Successfully find a booking and move it to the current account
    @isTest
    static void callAPIForTestResults1(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'Kenneth';
        details.lastName = 'Wither';
        details.BookingRef = 'A029034';
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Success');
        system.assertEquals(results.message, 'Are you sure you would like this Booking put into your name?');
    }
    
    //Second test will Successfully find a booking and move it to the current account
    @isTest
    static void callAPIForTestResults2(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'Henry';
        details.lastName = 'Wither';
        details.BookingRef = 'A029035';
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Success');
        system.assertEquals(results.message, '2 bookings were found based on that criteria. Please choose which one you would like to have put into your name');
    }
    
    //third test will pass Null value for First Name
    @isTest
    static void callAPIForTestResults3(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = '';
        details.lastName = 'Wither';
        details.BookingRef = 'A029034';
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'you must enter a First Name');
    }
    
    //fourth test will pass Null value for First Name
    @isTest
    static void callAPIForTestResults4(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = '';
        details.lastName = 'Wither';
        details.BookingRef = '';
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'you must enter a Booking Reference and you must enter a First Name');
    }
    
    //fifth test will pass Null value for Last Name
    @isTest
    static void callAPIForTestResults5(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'Kenneth';
        details.lastName = Null;
        details.BookingRef = 'A029034';
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'you must enter a Last Name');
    }
    
    //sixth test will pass Null value for Last Name
    @isTest
    static void callAPIForTestResults6(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'Kenneth';
        details.lastName = Null;
        details.BookingRef = '';
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'you must enter a Booking Reference and you must enter a Last Name');
    }
    
    //seventh test will pass Null value for Booking Reference
    @isTest
    static void callAPIForTestResults7(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'Kenneth';
        details.lastName = 'Wither';
        details.BookingRef = Null;
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'you must enter a Booking Reference');
    }
    
    //eighth test will pass data which will return no Bookings
    @isTest
    static void callAPIForTestResults8(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'John';
        details.lastName = 'Wither';
        details.BookingRef = 'A029034';
        details.accountId = a.id;
        details.BookingRegion = 'TTAKLS';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'No bookings were found based on that criteria');
    }
    
    //ninth test will pass data which will return multiple bookings over multiple Regions
    @isTest
    static void callAPIForTestResults9(){    
        
        //create records
        CreateRecords2();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'Kenneth';
        details.lastName = 'Wither';
        details.BookingRef = 'A029034';
        details.accountId = a.id;
        details.BookingRegion = '';
        details.specialBrand = '';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'The results returned are over multiple Regions');
    }
    
    
   //First test will Successfully find a booking and move it to the current account
    @isTest
    static void callAPIForTestResults10(){    
        
        //create records
        CreateRecords();
        
        test.startTest();
            
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();  
        RestContext.request.httpMethod = 'PATCH';
        
        Account a = new Account(firstName = 'a', lastName = 'b', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert a;
        
        REST_FindPassengerRecords_V1.BookingDetails details = new REST_FindPassengerRecords_V1.BookingDetails();
        details.firstName = 'Kenneth';
        details.lastName = 'Witther';
        details.BookingRef = '1234567';
        details.accountId = a.id;
        details.BookingRegion = 'UN';
        details.specialBrand = 'UBU';
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_FindPassengerRecords_V1.PassengerWrapper results = REST_FindPassengerRecords_V1.doPatch(details);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'No bookings were found based on that criteria');
    }
    
    
    public static void createRecords(){
    
        //grab record type id of Person Account        
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId();
        
        //grab record type id of Business Unit        
        Id businessUnitRecordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Business Unit').getRecordTypeId();
        
        //grab record type id of Passenger        
        Id passengerRecordTypeId = Schema.SObjectType.Passenger__c.getRecordtypeInfosByName().get('Main Passenger').getRecordTypeId();
        
        //grab record type id of Booking Passenger        
        Id bookingPassengerRecordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId();
        
        //grab record type id of Booking Component        
        Id bookingComponentRecordTypeId = Schema.SObjectType.Booking_Component__c.getRecordtypeInfosByName().get('Tour').getRecordTypeId();
        
        //grab record type id of Booking        
        Id bookingRecordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId();
        
        
        product = new Tour_Product__c(name = 'BIXPA11', Product_Name__c = 'Costsaver Britain and Ireland', Special_Brand__c = 'COST');
        
        product1 = new Tour_Product__c(name = 'BIXPA12', Product_Name__c = 'Costsaver Britain and Ireland', Special_Brand__c = 'UBU');
        
        personAcc = new Account(firstName = 'Kenneth', lastName = 'Wither', recordTypeId = personAccountRecordTypeId);
        insert personAcc;
        
        personAcc1 = new Account(firstName = 'Kenneth', lastName = 'Witther', recordTypeId = personAccountRecordTypeId);
        insert personAcc1;
        
        businessAcc = new Account(name = 'Trafalgar (NZ)', Selling_Company_Short_Name__c = 'TTAKLS', External_Id__c = 'TTAKLS', recordTypeId = businessUnitRecordTypeId);
        insert businessAcc;
        
        businessAcc2 = new Account(name = 'Trafalgar (IRE)', Selling_Company_Short_Name__c = 'TTOSTS', External_Id__c = 'TTOSTS', recordTypeId = businessUnitRecordTypeId);
        insert businessAcc2;
        
        businessAcc3 = new Account(name = 'Uniworld (AUS)', Selling_Company_Short_Name__c = 'UNSYDS', External_Id__c = 'UNSYDS', recordTypeId = businessUnitRecordTypeId);
        insert businessAcc3;
        
        book = new Booking__c(name = 'A029034', Selling_Company__c = businessAcc.Id, Lead_Passenger__c = personAcc.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId);
        insert book;
        
        book2 = new Booking__c(name = 'A029035', Selling_Company__c = businessAcc.Id, Lead_Passenger__c = personAcc.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId);
        insert book2;
             
        book3 = new Booking__c(name = '1234567', Selling_Company__c = businessAcc3.Id, Lead_Passenger__c = personAcc1.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId);
        insert book3;
        
        bPass = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book.Id, name = 'TTAKLS#A029034#001', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass;
        
        bPass2 = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book2.Id, name = 'TTAKLS#A029035#001', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass2;
        
        bPass3 = new Booking_Passenger__c(Customer__c = personAcc1.Id, Booking__c = book3.Id, name = 'UNSYDS#1234567#003', Pax_No__c = '003', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass3;
        
        bComp = new Booking_Component__c(name = 'TTAKLS-A029034-001-BIXPA11-14H16a', Booking_Number__c = book.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass.Id, Product__c = product.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp;
        
        bComp2 = new Booking_Component__c(name = 'TTAKLS-A029035-001-BIXPA11-14H16a', Booking_Number__c = book2.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass2.Id, Product__c = product.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp2;
        
        bComp3 = new Booking_Component__c(name = 'UNSYDS-1234567-001-BIXPA11-14H16a', Booking_Number__c = book3.Id, Customer__c = personAcc1.Id, Booking_Passenger__c = bPass3.Id, Product__c = product1.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp3;
        
        pass = new Passenger__c(name = 'Kenneth Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029034#001', First_name__c = 'Kenneth', Family_Name__c = 'Wither', Booking_Passenger__c = bPass.Id, Booking_Component__c = bComp.Id, recordTypeId = passengerRecordTypeId);
        insert pass;
        
        pass2 = new Passenger__c(name = 'Henry Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029035#001', First_name__c = 'Henry', Family_Name__c = 'Wither', Booking_Passenger__c = bPass2.Id, Booking_Component__c = bComp2.Id, recordTypeId = passengerRecordTypeId);
        insert pass2;
        
        pass3 = new Passenger__c(name = 'Henry Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029035#002', First_name__c = 'Henry', Family_Name__c = 'Wither', Booking_Passenger__c = bPass2.Id, Booking_Component__c = bComp2.Id, recordTypeId = passengerRecordTypeId);
        insert pass3;  
        
        pass4 = new Passenger__c(name = 'Kenneth Witther', Account__c = personAcc1.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-UNSYDS#1234567#003', First_name__c = 'Kenneth', Family_Name__c = 'Witther', Booking_Passenger__c = bPass3.Id, Booking_Component__c = bComp3.Id, recordTypeId = passengerRecordTypeId);
        insert pass4;      
    }
    
    public static void createRecords2(){
    
        //grab record type id of Person Account        
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId();
        
        //grab record type id of Business Unit        
        Id businessUnitRecordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Business Unit').getRecordTypeId();
        
        //grab record type id of Passenger        
        Id passengerRecordTypeId = Schema.SObjectType.Passenger__c.getRecordtypeInfosByName().get('Main Passenger').getRecordTypeId();
        
        //grab record type id of Booking Passenger        
        Id bookingPassengerRecordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId();
        
        //grab record type id of Booking Component        
        Id bookingComponentRecordTypeId = Schema.SObjectType.Booking_Component__c.getRecordtypeInfosByName().get('Tour').getRecordTypeId();
        
        //grab record type id of Booking        
        Id bookingRecordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId();
        
       

        personAcc = new Account(firstName = 'Kenneth', lastName = 'Wither', recordTypeId = personAccountRecordTypeId);
        insert personAcc;
        
        businessAcc = new Account(name = 'Trafalgar (NZ)', Selling_Company_Short_Name__c = 'TTAKLS', External_Id__c = 'TTAKLS', recordTypeId = businessUnitRecordTypeId);
        insert businessAcc;
        
        businessAcc2 = new Account(name = 'Contiki (IRE)', Selling_Company_Short_Name__c = 'CTOSTS', External_Id__c = 'CTOSTS', recordTypeId = businessUnitRecordTypeId);
        insert businessAcc2;
        
        book = new Booking__c(name = 'A029034', Selling_Company__c = businessAcc.Id, Lead_Passenger__c = personAcc.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId);
        insert book;
        
        book2 = new Booking__c(name = 'A029034', Selling_Company__c = businessAcc2.Id, Lead_Passenger__c = personAcc.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId);
        insert book2;
        
        bPass = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book.Id, name = 'TTAKLS#A029034#001', Pax_No__c = '001', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass;
        
        bPass2 = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book2.Id, name = 'TTOSTS#A029035#002', Pax_No__c = '002', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass2;
        
        bComp = new Booking_Component__c(name = 'TTAKLS-A029034-001-BIXPA11-14H16a', Booking_Number__c = book.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp;
        
        bComp2 = new Booking_Component__c(name = 'TTOSTS-A029035-001-BIXPA11-14H16a', Booking_Number__c = book2.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass2.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp2;
        
        pass = new Passenger__c(name = 'Kenneth Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029034#001', First_name__c = 'Kenneth', Family_Name__c = 'Wither', Booking_Passenger__c = bPass.Id, Booking_Component__c = bComp.Id, recordTypeId = passengerRecordTypeId);
        insert pass;
        
        pass2 = new Passenger__c(name = 'Kenneth Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTOSTS#A029035#002', First_name__c = 'Kenneth', Family_Name__c = 'Wither', Booking_Passenger__c = bPass2.Id, Booking_Component__c = bComp2.Id, recordTypeId = passengerRecordTypeId);
        insert pass2;
        
        pass3 = new Passenger__c(name = 'Kenneth Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTOSTS#A029035#002', First_name__c = 'Kenneth', Family_Name__c = 'Wither', Booking_Passenger__c = bPass2.Id, Booking_Component__c = bComp2.Id, recordTypeId = passengerRecordTypeId);
        insert pass3;
        
        
    }
}