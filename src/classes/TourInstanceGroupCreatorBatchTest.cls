@isTest
private class TourInstanceGroupCreatorBatchTest {
    
                                                     
   private static testMethod void testChatterGroupCreatorBatch(){
        insert new App_Settings__c(
            Name = ChatterGroupHandler.customSettingsName,
            Past_Trip_Deactivation_In_Days__c = 20,
            Upcoming_Trip_Activation_In_Days__c = 40,
            ClientAPP_Id__c = ChatterGroupHandler.customSettingsName
        );
        
        Tour_Instance__c testTourInstance = new Tour_Instance__c (Operating_Product_Code__c = 'TEST', Departure_Code__c = 'STTS3', End_Date__c = Date.today().addDays(5), Start_Date__c = Date.today().addDays(-5), Reverse_Itinerary__c = FALSE, Instance_Code__c = '123');
        
        testTourInstance.Chatter_Group_Id__c = 'TEST_CHATTER_GROUP';
        insert testTourInstance;
        
        //testTourInstance.Chatter_Group_Id__c = null;
        //update testTourInstance;
        
        Test.startTest();
        TourInstanceChatterGroupCreatorBatch.run();
        Test.stopTest();
        
        Tour_Instance__c resultTourInstance = [SELECT Id, Chatter_Group_Id__c 
            FROM Tour_Instance__c 
            WHERE Id = :testTourInstance.Id];
        System.assertNotEquals(null, resultTourInstance.Chatter_Group_Id__c);
   }    

}