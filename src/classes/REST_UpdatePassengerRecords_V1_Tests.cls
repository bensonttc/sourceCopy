@istest private class REST_UpdatePassengerRecords_V1_Tests {
    
    //Declare variables that will be used in test
    private static Account personAcc;
    private static Account businessAcc;
    private static Passenger__c pass;
    private static Passenger__c pass2;
    private static Passenger__c pass3;
    private static Booking_Passenger__c bPass;
    private static Booking_Passenger__c bPass2;
    private static Booking_Component__c bComp;
    private static Booking_Component__c bComp2;
    private static Booking__c book;
    private static Booking__c book2;
    
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
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger1 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger1.accountId = a.Id;
        passenger1.passengerId = pass.id;
        
        REST_UpdatePassengerRecords_V1.passengers passengers = new REST_UpdatePassengerRecords_V1.passengers();
        passengers.updatePassengers.add(passenger1);
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_UpdatePassengerRecords_V1.PassengerResponse results = REST_UpdatePassengerRecords_V1.doPatch(passengers);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Success');
        system.assertEquals(results.message, 'That passenger record is now visible to you');
    }
    
    //second test will pass Null value for First Name
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
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger1 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger1.accountId = a.Id;
        passenger1.passengerId = pass.id;
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger2 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger2.accountId = a.Id;
        passenger2.passengerId = pass2.id;
        
        REST_UpdatePassengerRecords_V1.passengers passengers = new REST_UpdatePassengerRecords_V1.passengers();
        passengers.updatePassengers.add(passenger1);
        passengers.updatePassengers.add(passenger2);
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_UpdatePassengerRecords_V1.PassengerResponse results = REST_UpdatePassengerRecords_V1.doPatch(passengers);      
        
        test.stopTest();
        system.assertEquals(results.message, '2 Passenger records are now visible to you');
        system.assertEquals(results.status, 'Success');
        
    }
    
    //third test will pass Null value for Last Name
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
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger1 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger1.passengerId = pass.id;
        
        REST_UpdatePassengerRecords_V1.passengers passengers = new REST_UpdatePassengerRecords_V1.passengers();
        passengers.updatePassengers.add(passenger1);
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_UpdatePassengerRecords_V1.PassengerResponse results = REST_UpdatePassengerRecords_V1.doPatch(passengers);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'The accountId is blank on Passenger 1');
    }
    
    //fourth test will pass data which will return no Bookings
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
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger1 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger1.accountId = a.Id;
        
        REST_UpdatePassengerRecords_V1.passengers passengers = new REST_UpdatePassengerRecords_V1.passengers();
        passengers.updatePassengers.add(passenger1);
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_UpdatePassengerRecords_V1.PassengerResponse results = REST_UpdatePassengerRecords_V1.doPatch(passengers);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'The passengerId is blank on Passenger 1');
    }
    
    //fifth test will pass null values on both Passengers
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
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger1 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger2 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        
        REST_UpdatePassengerRecords_V1.passengers passengers = new REST_UpdatePassengerRecords_V1.passengers();
        passengers.updatePassengers.add(passenger1);
        passengers.updatePassengers.add(passenger2);
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_UpdatePassengerRecords_V1.PassengerResponse results = REST_UpdatePassengerRecords_V1.doPatch(passengers);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'The accountId and the PassengerId are blank on Passenger 1 and the accountId and the PassengerId are blank on Passenger 2');
    }
    
    //sixth test will pass no passengers
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
        
        REST_UpdatePassengerRecords_V1.passengers passengers = new REST_UpdatePassengerRecords_V1.passengers();
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_UpdatePassengerRecords_V1.PassengerResponse results = REST_UpdatePassengerRecords_V1.doPatch(passengers);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'There were no Passenger Records to be updated');
    }
    
    //seventh test will pass missing details on some of the passengers
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
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger1 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger1.passengerId = pass.id;
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger2 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger2.passengerId = pass2.id;
        
        REST_UpdatePassengerRecords_V1.updatePassengers passenger3 = new REST_UpdatePassengerRecords_V1.updatePassengers();
        passenger3.accountId = a.Id;
        
        REST_UpdatePassengerRecords_V1.passengers passengers = new REST_UpdatePassengerRecords_V1.passengers();
        passengers.updatePassengers.add(passenger1);
        passengers.updatePassengers.add(passenger2);
        passengers.updatePassengers.add(passenger3);
        
        //call the PATCH method on the Rest API class and envolk the ContactWrapper list
        REST_UpdatePassengerRecords_V1.PassengerResponse results = REST_UpdatePassengerRecords_V1.doPatch(passengers);      
        
        test.stopTest();
        system.assertEquals(results.status, 'Failure');
        system.assertEquals(results.message, 'The accountId is blank on Passenger 1 and the accountId is blank on Passenger 2 and the passengerId is blank on Passenger 3');
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
        
        
        personAcc = new Account(firstName = 'Kenneth', lastName = 'Wither', recordTypeId = personAccountRecordTypeId);
        insert personAcc;
        
        businessAcc = new Account(name = 'Trafalgar (NZ)', Selling_Company_Short_Name__c = 'TTAKLS', External_Id__c = 'TTAKLS', recordTypeId = businessUnitRecordTypeId);
        insert businessAcc;
        
        book = new Booking__c(name = 'A029034', Selling_Company__c = businessAcc.Id, Lead_Passenger__c = personAcc.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId);
        insert book;
        
        book2 = new Booking__c(name = 'A029035', Selling_Company__c = businessAcc.Id, Lead_Passenger__c = personAcc.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId);
        insert book2;
        
        bPass = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book.Id, name = 'TTAKLS#A029034#001', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass;
        
        bPass2 = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book2.Id, name = 'TTAKLS#A029035#001', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass2;
        
        bComp = new Booking_Component__c(name = 'TTAKLS-A029034-001-BIXPA11-14H16a', Booking_Number__c = book.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp;
        
        bComp2 = new Booking_Component__c(name = 'TTAKLS-A029035-001-BIXPA11-14H16a', Booking_Number__c = book2.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass2.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp2;
        
        pass = new Passenger__c(name = 'Kenneth Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029034#001', First_name__c = 'Kenneth', Family_Name__c = 'Wither', Booking_Passenger__c = bPass.Id, Booking_Component__c = bComp.Id, recordTypeId = passengerRecordTypeId);
        insert pass;
        
        pass2 = new Passenger__c(name = 'Henry Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029035#001', First_name__c = 'Henry', Family_Name__c = 'Wither', Booking_Passenger__c = bPass2.Id, Booking_Component__c = bComp2.Id, recordTypeId = passengerRecordTypeId);
        insert pass2;
        
        pass3 = new Passenger__c(name = 'Henry Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029035#002', First_name__c = 'Henry', Family_Name__c = 'Wither', Booking_Passenger__c = bPass2.Id, Booking_Component__c = bComp2.Id, recordTypeId = passengerRecordTypeId);
        insert pass3;    
    }
}