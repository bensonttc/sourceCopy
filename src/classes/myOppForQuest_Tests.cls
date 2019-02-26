@istest private class myOppForQuest_Tests {
    
    private static Account CustomerAcc;
    private static Account SellingCompanyAcc;
    private static Account BrandAcc;
    private static Booking__c TestBooking;
    private static questionnaire__c testPassQuestionnaire;
    private static questionnaire__c testFailQuestionnaire;
    
    public static void createRecords() {
            
        //get Account record Types
        map<string, id> mapRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName, Name, SobjectType FROM RecordType WHERE SobjectType = 'Account']){
            mapRT.put(RT.DeveloperName, RT.id);
        }

        //get Booking record Types
        map<string, id> BookRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName, Name, SobjectType FROM RecordType WHERE SobjectType = 'Booking__c']){
            BookRT.put(RT.DeveloperName, RT.id);
        }
        
        //insert Accounts, Booking and user to be used in test
        CustomerAcc = new Account(FirstName = 'Person', LastName = 'Account', RecordTypeId = mapRT.get('Customer'));
        insert CustomerAcc;
        
        SellingCompanyAcc = new Account(Name = 'Selling Company', RecordTypeId = mapRT.get('Selling_Company'));
        insert SellingCompanyAcc;
        
        BrandAcc = new Account(Name = 'Brand Account', RecordTypeId = mapRT.get('Brand'));
        insert BrandAcc;
        
        list<user> ActiveUser = [select id from user where profile.name = 'System Administrator' AND  isActive = true limit 1];
        
        TestBooking = new Booking__c(Selling_Company__c = SellingCompanyAcc.Id, Original_booking_Date__c = date.today(), name = '1', RecordTypeID = BookRT.get('Booking'), status__c = 'CX', ownerID = ActiveUser[0].ID);
        insert TestBooking;
        
        testPassQuestionnaire = new Questionnaire__c(Booking__c = TestBooking.Id,
                                                    Customer__c = CustomerAcc.Id,
                                                    Selling_Company__c = SellingCompanyAcc.Id,
                                                    Departure_Date__c = System.today(),
                                                    Comms__c = 'Y',
                                                    Recommend_NPS__c = '8',
                                                    Travel_Again_NPS__c = '8');
        insert testPassQuestionnaire;
        
        testFailQuestionnaire = new Questionnaire__c(Booking__c = TestBooking.Id,
                                                    Customer__c = CustomerAcc.Id,
                                                    Selling_Company__c = SellingCompanyAcc.Id,
                                                    Departure_Date__c = System.today(),
                                                    Comms__c = 'N',
                                                    Comms_Email__c = 'N',
                                                    Recommend_NPS__c = '8',
                                                    Travel_Again_NPS__c = '8');
        insert testFailQuestionnaire;
        
    }
    
    @isTest
    //Tests will update the Questionnaire records to fire the trigger. Separate tests to check the Questionnaire that should result in a Opportunity getting created and one where an Opportunity wouldn't get created
    static void updateQuestionnaireForTrigger()
   {
       //Create records
       CreateRecords();
       
       test.starttest();
       //***UPDATE PASS QUESTIONNAIRE***
       update testPassQuestionnaire;
       
       //check Opportunity was created
       list<opportunity> Opp1 = [SELECT Id FROM Opportunity WHERE CTQ_Name__C = :testPassQuestionnaire.Id];
       system.assert(Opp1.size() == 1); //List will be exactly 1 because only 1 Opportunity would have been generated
       
       
       //***UPDATE FAIL QUESTIONNAIRE***
       update testFailQuestionnaire;
       
       //check no opportunity was created
       list<opportunity> Opp2 = [SELECT Id FROM Opportunity WHERE CTQ_Name__C = :testFailQuestionnaire.Id];
       system.assert(Opp2.size() != 1);
       
       test.stoptest();
   }
}