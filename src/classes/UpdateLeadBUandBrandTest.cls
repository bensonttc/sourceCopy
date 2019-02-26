@isTest
private class UpdateLeadBUandBrandTest{
    
    private static Account businessUnit;
    private static Account businessUnit2;
    private static Account customer;
    private static Business_Units__c busUnit;
    private static Lead lead1;
    
    public static testMethod void testUpdateOppBUandBrand1(){
    
        createRecords();
        
        lead1.Business_Unit__c = businessUnit.Id;
        lead1.Selling_Company_Code__c = Null;
        
        test.startTest();
        update lead1;
        test.stopTest();
        
        lead1 = [SELECT Id, Selling_Company_Code__c, Business_Unit__c, Brand__c, CurrencyISOCode FROM Lead WHERE Id = :lead1.Id LIMIT 1];
        
        system.assertEquals(lead1.Selling_Company_Code__c, 'ABCDEF');
        system.assertEquals(lead1.Business_Unit__c, businessUnit.Id);
        system.assertEquals(lead1.Brand__c, 'Insight');
        system.assertEquals(lead1.CurrencyISOCode, 'GBP');
    
    }
    
    public static testMethod void testUpdateOppBUandBrand2(){
    
        createRecords();
        
        lead1.Selling_Company_Code__c = 'ABCDEF';
        
        test.startTest();
        update lead1;
        test.stopTest();
        
        lead1 = [SELECT Id, Selling_Company_Code__c, Business_Unit__c, Brand__c, CurrencyISOCode FROM Lead WHERE Id = :lead1.Id LIMIT 1];
        
        system.assertEquals(lead1.Selling_Company_Code__c, 'ABCDEF');
        system.assertEquals(lead1.Business_Unit__c, businessUnit.Id);
        system.assertEquals(lead1.Brand__c, 'Insight');
        system.assertEquals(lead1.CurrencyISOCode, 'GBP');
    
    }
    
    public static void createRecords(){
    
        businessUnit = new Account(name = 'Insight (CAN)', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Unit').getRecordTypeId(), Selling_Company_Short_Name__c = 'ABCDEF');
        insert businessUnit;
        
        businessUnit2 = new Account(name = 'Insight (CAD)', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Unit').getRecordTypeId(), Selling_Company_Short_Name__c = 'ABCDEG');
        insert businessUnit2;
        
        customer = new Account(firstName = 'alberto', lastName = 'dei giudici', recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId());
        insert customer;
        
        busUnit = new Business_Units__c(name = 'ABCDEF', Brand__c = 'Insight', Business_Unit_Id__c = businessUnit.Id, Currency__C = 'GBP', Selling_Company_Code__c = 'ABCDEF');
        insert busUnit;
        
        lead1 = new Lead(firstName = 'alberto', lastName = 'dei giudici', Business_Unit__c = businessUnit2.Id, Selling_Company_Code__c = 'ABCDEG');
        insert lead1;
    
    }

}