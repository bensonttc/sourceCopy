@istest private class AccountToPassengerReplicator_Tests {

    //Declare variables for records that will be used
    private static Account Customer1;
    
    private static Passenger__c Passenger1;    
    
    public static void createRecords(){
        
        //get Account record Types
        map<string, id> custRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName, Name, SobjectType FROM RecordType WHERE SobjectType = 'Account']){
            custRT.put(RT.DeveloperName, RT.id);
        }

        //get Passenger record Types
        map<string, id> passRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName, Name, SobjectType FROM RecordType WHERE SobjectType = 'Passenger__c']){
            passRT.put(RT.DeveloperName, RT.id);
        }
        
        //insert Accounts to be used in test
        Customer1 = new Account(firstName = 'Mike', lastName = 'Ross', RecordTypeId = custRT.get('Customer'));
        insert Customer1;        
        
        //insert Passengers to be used in test
        Passenger1 = new Passenger__c(first_Name__c = 'Daigo', Family_Name__c = 'Umehara', Account__c = Customer1.Id, RecordTypeId = passRT.get('Main_Passenger'));
        insert Passenger1;
        
        list<Account> accts = new list<Account>();
        set<Id> Ids = new set<Id>();
        
        FOR(Integer i=0; i<200; i++){
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        
        FOR(Integer i=0; i<200; i++){
            String accId = accts[i].Id;
            Ids.add(accId);
        }
        
        System.AssertEquals(accts.size(), Ids.size());
    }
    
    
    @isTest
    
    static void AccountToPassengerReplicator_Test(){
        
        //create records
        createRecords();
        
        Set<Id> AccIds = new Set<Id>();
        AccIds.Add(Customer1.Id);
        
        test.startTest();
        System.enqueueJob(new AccountToPassengerReplicator(AccIds));
        test.stopTest();
        
        Customer1 = [SELECT firstName, lastName FROM Account WHERE Id = :Customer1.Id];
        Passenger1 = [SELECT first_Name__c, Family_Name__c FROM Passenger__c WHERE Id = :Passenger1.Id];
        
        System.AssertEquals(Customer1.firstName, Passenger1.First_Name__c);
        
    }
}