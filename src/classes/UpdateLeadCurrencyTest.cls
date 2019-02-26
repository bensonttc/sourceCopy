@isTest private class UpdateLeadCurrencyTest{
                
    public static testMethod void testLeadCurrency(){
        
        List<Lead> leads = new List<Lead>();
                  
        Lead lead1 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVSYDS');
        Lead lead2 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVCANS');
        Lead lead3 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVUSAS');
        Lead lead4 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVEUOS');
        Lead lead5 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVAKLS');
        Lead lead6 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVJBGS');
        Lead lead7 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVSINS');
        Lead lead8 = new Lead(FirstName = 'Chris', LastName='Hemsworth', email='test@test.com', selling_company_code__c='IVUKLS');
        
        leads.add(lead1);
        leads.add(lead2);
        leads.add(lead3);
        leads.add(lead4);
        leads.add(lead5);
        leads.add(lead6);
        leads.add(lead7);
        leads.add(lead8);
        
        test.startTest();
        insert leads;
        test.stopTest();
 
    }
}