@isTest private class IndividualEmailResultTriggerHandler_Test{
    private static et4ae5__SendDefinition__c emailSend;
    private static Account customer1;
    private static Account customer2;
    private static Account contikiBrand;
    private static Account contikiBU1;
    private static Account contikiBU2;
    private static Marketing_Consent__c mcTest1;
    private static Marketing_Consent__c mcTest2;
    
    public static void createRecords(){
        emailSend = new et4ae5__SendDefinition__c();
        insert emailSend;
        customer1 = new Account(firstname = 'test', lastname = 'Customer', personemail = 'test.customer@gmail.com', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert Customer1;
        customer1 = [Select Id, firstName, lastName, personEmail, recordTypeId, personContactId FROM Account WHERE Id = :customer1.id limit 1];
        contikiBrand = new Account(name = 'Contiki', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId());
        insert contikiBrand;
        contikiBU1 = new Account(name = 'Contiki (NZ)', ParentId = contikiBrand.id, Selling_Company_Short_Name__c = 'CHAKLS', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Unit').getRecordTypeId());
        insert contikiBU1;
        List<Business_Units__c> BUList = new List<Business_Units__c>();
        Business_Units__c contikiBusinessUnits1 = new Business_Units__c(name = 'testCHAKLS', Selling_Company_Code__c = 'CHAKLS', Business_Unit_Id__c = contikiBU1.Id, type__c = 'Business Unit', Marketing_Cloud_Business_Unit__c = 'Contiki NZ (1058719)');
        BUList.add(contikiBusinessUnits1);
        Business_Units__c contikiBusinessUnits2 = new Business_Units__c(name = 'testCONTIKI', Selling_Company_Code__c = 'CONTIKI', Business_Unit_Id__c = contikiBrand.Id, type__c = 'Brand', Marketing_Cloud_Business_Unit__c = 'Contiki NZ (1058720)');
        BUList.add(contikiBusinessUnits2);
        insert BUList;
        List<Marketing_Consent__c> mcList = new List<Marketing_Consent__c>();
        mcTest1 = new Marketing_Consent__c(Customer_Or_Prospect__c = customer1.Id, Selling_Company__c = contikiBU1.id, Brand__c = contikiBrand.Id, Opt_In__c = true, Assumed_Opt_In__c = false, External_Id__c = contikiBU1.id+'#'+customer1.Id, recordTypeId = Schema.SObjectType.Marketing_Consent__c.getRecordTypeInfosByName().get('Active Marketing Consent').getRecordTypeId());
        mcList.add(mcTest1);
        mcTest2 = new Marketing_Consent__c(Customer_Or_Prospect__c = customer1.Id, Selling_Company__c = contikiBrand.id, Brand__c = contikiBrand.Id, Opt_In__c = true, Assumed_Opt_In__c = false, External_Id__c = contikiBrand.id+'#'+customer1.Id, recordTypeId = Schema.SObjectType.Marketing_Consent__c.getRecordTypeInfosByName().get('Active Marketing Consent').getRecordTypeId());
        mcList.add(mcTest2);
        insert mcList;
    }
    @isTest static void testMCWritebacksuccessful(){
        createRecords();
        emailSend.et4ae5__Business_Unit_saved__c = 'Contiki NZ (1058719)';
        update emailSend;
        et4ae5__IndividualEmailResult__c test = new et4ae5__IndividualEmailResult__c(et4ae5__SendDefinition__c = emailSend.Id, et4ae5__DateUnsubscribed__c = Date.Today(), et4ae5__Contact__c = customer1.personContactId);
        insert test;
        mcTest1 = [SELECT Id, Opt_In__c from Marketing_Consent__c where Id = :mcTest1.Id limit 1];
        //system.assertEquals(false, mcTest1.Opt_In__c);
    }
    @isTest static void testMCWritebackUpdateFail(){
        createRecords();
        et4ae5__IndividualEmailResult__c test = new et4ae5__IndividualEmailResult__c(et4ae5__SendDefinition__c = emailSend.Id, et4ae5__Contact__c = customer1.personContactId, et4ae5__DateUnsubscribed__c = Date.Today());
        insert test;
    }
    @isTest static void testMCWritebackUpdateOptOutAll(){
        createRecords();
        emailSend.et4ae5__Business_Unit_saved__c = 'Contiki NZ (1058720)';
        update emailSend;
        et4ae5__IndividualEmailResult__c test = new et4ae5__IndividualEmailResult__c(et4ae5__SendDefinition__c = emailSend.Id, et4ae5__DateUnsubscribed__c = Date.Today(), et4ae5__Contact__c = customer1.personContactId);
        insert test;
        mcTest1 = [SELECT Id, Opt_In__c from Marketing_Consent__c where Id = :mcTest1.Id limit 1];
        //system.assertEquals(false, mcTest1.Opt_In__c);
    }
}