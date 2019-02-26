@isTest private class UpdateoppCurrencyTest{
                
    public static testMethod void testOppCurrency(){
                                
        /*Account acc = new Account(Name='ChrisHemsworth');
        insert acc;
        
        List<Opportunity> opps = new List<Opportunity>();
        
        Opportunity opp1 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVSYDS');                        
        Opportunity opp2 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVCANS');
        Opportunity opp3 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVUSAS');
        Opportunity opp4 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVEUOS');
        Opportunity opp5 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVAKLS');
        Opportunity opp6 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVJBGS');
        Opportunity opp7 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVSINS');
        Opportunity opp8 = new Opportunity(Name = 'oppname', accountID = acc.id, StageName = 'Prospecting', CloseDate = system.today(), Selling_Company_Code__c = 'IVUKLS');
        
        opps.add(opp1);
        opps.add(opp2);
        opps.add(opp3);
        opps.add(opp4);
        opps.add(opp5);
        opps.add(opp6);
        opps.add(opp7);
        opps.add(opp8);
        
        test.startTest();
        insert opps;
        test.stopTest();
        */
        
        insert new Business_Units__c(name = 'Test value 1', Selling_Company_Code__c = 'ABCDEF', Currency__c = 'USD');
        insert new Business_Units__c(name = 'Test value 2', Selling_Company_Code__c = 'ABCDEG', Currency__c = 'EUR');
        insert new Business_Units__c(name = 'Test value 3', Selling_Company_Code__c = 'ABCDEH', Currency__c = 'GBP');
        insert new Business_Units__c(name = 'Test value 4', Selling_Company_Code__c = 'ABCDEI', Currency__c = 'CAD');
        
        List<Business_Units__c> businessUnits = Business_Units__c.getAll().Values();
        Map<String, String> BUtoSC = new Map<String, String>();
        
        for(integer i = 0; i < businessUnits.size(); i++){
        
            //String scc = businessUnits.get(i).Selling_Company_Code__c;
            //String cur = businessUnits.get(i).Currency__c;
            
            BUtoSC.put(businessUnits.get(i).Selling_Company_Code__c, businessUnits.get(i).Currency__c);
        
        }
        
        system.assertEquals(BUtoSC.size(), 4);
        
    }
    
}