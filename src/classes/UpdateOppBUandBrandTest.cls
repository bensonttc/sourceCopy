@isTest
private class UpdateOppBUandBrandTest{
    
    private static Account businessUnit;
    private static Account businessUnit2;
    private static Account customer;
    private static Business_Units__c busUnit;
    private static Opportunity oppty;
    
    public static testMethod void testUpdateOppBUandBrand1(){
    
        createRecords();
        
        oppty.Business_Unit__c = businessUnit.Id;
        oppty.Selling_Company_Code__c = Null;
        
        test.startTest();
        update oppty;
        test.stopTest();
        
        oppty = [SELECT Id, Selling_Company_Code__c, Business_Unit__c, Brand__c, CurrencyISOCode FROM Opportunity WHERE Id = :oppty.Id LIMIT 1];
        
        system.assertEquals(oppty.Selling_Company_Code__c, 'ABCDEF');
        system.assertEquals(oppty.Business_Unit__c, businessUnit.Id);
        system.assertEquals(oppty.Brand__c, 'Insight');
        system.assertEquals(oppty.CurrencyISOCode, 'GBP');
    
    }
    
    public static testMethod void testUpdateOppBUandBrand2(){
    
        createRecords();
        
        oppty.Selling_Company_Code__c = 'ABCDEF';
        
        test.startTest();
        update oppty;
        test.stopTest();
        
        oppty = [SELECT Id, Selling_Company_Code__c, Business_Unit__c, Brand__c, CurrencyISOCode FROM Opportunity WHERE Id = :oppty.Id LIMIT 1];
        
        system.assertEquals(oppty.Selling_Company_Code__c, 'ABCDEF');
        system.assertEquals(oppty.Business_Unit__c, businessUnit.Id);
        system.assertEquals(oppty.Brand__c, 'Insight');
        system.assertEquals(oppty.CurrencyISOCode, 'GBP');
    
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
        
        oppty = new Opportunity(name = 'alberto dei giudici - Request A Quote', AccountId = customer.Id, stageName = 'Prospecting', closeDate = date.today(), Business_Unit__c = businessUnit2.Id, Selling_Company_Code__c = 'ABCDEG');
        insert oppty;
    
    }

}