@isTest
private class ChatterGroupActivationTest {
	private static App_Settings__c getAppSettings(){
    	return new App_Settings__c(
    		Name = ChatterGroupHandler.customSettingsName,
    		Past_Trip_Deactivation_In_Days__c = 20,
    		Upcoming_Trip_Activation_In_Days__c = 40,
    		ClientAPP_Id__c = ChatterGroupHandler.customSettingsName
    	);		
	}
	
    private static testMethod void testBatchTourInstanceActivation(){
    	App_Settings__c appSettings = getAppSettings();
    	insert appSettings;
    	
    	CollaborationGroup chatterGroup1 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup1.IsArchived = true;
    	
    	CollaborationGroup chatterGroup2 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup2.IsArchived = true;
    	
    	CollaborationGroup chatterGroup3 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup3.IsArchived = true;
    	List<CollaborationGroup> chatterGroups = new List<CollaborationGroup>{chatterGroup1, chatterGroup2, chatterGroup3};
    	insert chatterGroups;
    	
    	List<Tour_Instance__c> testTourInstances = new List<Tour_Instance__c>{
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE1', UserInfo.getUserId(), 'TST', 'STTS3', 
    			Date.today().addDays(50), Date.today().addDays(70), false
    		),
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE2', UserInfo.getUserId(), 'TST', 'STTS4', 
    			Date.today().addDays(35), Date.today().addDays(55), false
    		),
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE3', UserInfo.getUserId(), 'TST', 'STTS5', 
    			Date.today().addDays(-80), Date.today().addDays(-50), false
    		)    		    		
    	};
    	
    	Set<Id> groupIds = new Set<Id>();
    	for (Integer index = 0; index < 3; index++){
    		testTourInstances.get(index).Chatter_Group_Id__c = chatterGroups.get(index).Id;
    		groupIds.add(chatterGroups.get(index).Id);
    	}
    	
    	insert testTourInstances;
    	
    	Test.startTest();
        Database.executeBatch(new ChatterGroupActivationBatch(false),100);
        Database.executeBatch(new ChatterGroupActivationBatch(true),100);
    	Test.stopTest();
    	
    	List<CollaborationGroup> chatterGroupResults = [SELECT Id, IsArchived FROM CollaborationGroup
    		WHERE Id IN :groupIds];
    		
    	for (Integer resIndex = 0; resIndex < chatterGroupResults.size(); resIndex++){
    		CollaborationGroup resultChatterGroup = chatterGroupResults.get(resIndex);
    		if (resultChatterGroup.Id == chatterGroup2.Id){
    			System.assertEquals(false, resultChatterGroup.IsArchived);
    		} else {
    			System.assertEquals(true, resultChatterGroup.IsArchived);
    		}
    	}
    }   
    
    	
    private static testMethod void testBatchTourInstanceActivationDeclined(){
    	App_Settings__c appSettings = getAppSettings();
    	insert appSettings;
    	
    	CollaborationGroup chatterGroup1 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup1.IsArchived = true;
    	
    	CollaborationGroup chatterGroup2 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup2.IsArchived = true;
    	
    	CollaborationGroup chatterGroup3 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup3.IsArchived = true;
    	List<CollaborationGroup> chatterGroups = new List<CollaborationGroup>{chatterGroup1, chatterGroup2, chatterGroup3};
    	insert chatterGroups;
    	
    	List<Tour_Instance__c> testTourInstances = new List<Tour_Instance__c>{
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE1', null, 'TST', 'STTS3', 
    			Date.today().addDays(50), Date.today().addDays(70), false
    		),
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE2', null, 'TST', 'STTS4', 
    			Date.today().addDays(35), Date.today().addDays(55), false
    		),
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE3', null, 'TST', 'STTS5', 
    			Date.today().addDays(-80), Date.today().addDays(-50), false
    		)    		    		
    	};
    	
    	Set<Id> groupIds = new Set<Id>();
    	for (Integer index = 0; index < 3; index++){
    		testTourInstances.get(index).Chatter_Group_Id__c = chatterGroups.get(index).Id;
    		groupIds.add(chatterGroups.get(index).Id);
    	}
    	
    	insert testTourInstances;
    	
    	Test.startTest();
        Database.executeBatch(new ChatterGroupActivationBatch(false),100);
        Database.executeBatch(new ChatterGroupActivationBatch(true),100);
    	Test.stopTest();
    	
    	List<CollaborationGroup> chatterGroupResults = [SELECT Id, IsArchived FROM CollaborationGroup
    		WHERE Id IN :groupIds];
    		
    	for (Integer resIndex = 0; resIndex < chatterGroupResults.size(); resIndex++){
    		CollaborationGroup resultChatterGroup = chatterGroupResults.get(resIndex);
    		System.assertEquals(true, resultChatterGroup.IsArchived);
    	}
    }   
    	
    private static testMethod void testBatchTourInstanceArchiving(){
    	App_Settings__c appSettings = getAppSettings();
    	insert appSettings;
    	
    	CollaborationGroup chatterGroup1 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup1.IsArchived = false;
    	
    	CollaborationGroup chatterGroup2 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup2.IsArchived = false;
    	
    	CollaborationGroup chatterGroup3 = TQTestUtils.createTestCollaborationGroup();
    	chatterGroup3.IsArchived = false;
    	List<CollaborationGroup> chatterGroups = new List<CollaborationGroup>{chatterGroup1, chatterGroup2, chatterGroup3};
    	insert chatterGroups;
    	
    	List<Tour_Instance__c> testTourInstances = new List<Tour_Instance__c>{
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE1', null, 'TST', 'STTS3', 
    			Date.today().addDays(50), Date.today().addDays(70), false
    		),
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE2', null, 'TST', 'STTS4', 
    			Date.today().addDays(35), Date.today().addDays(40), false
    		),
    		TQTestUtils.createTourInstance(
    			'TEST_TOUR_INSTANCE3', null, 'TST', 'STTS5', 
    			Date.today().addDays(-40), Date.today().addDays(-25), false
    		)    		    		
    	};
    	
    	Set<Id> groupIds = new Set<Id>();
    	for (Integer index = 0; index < 3; index++){
    		testTourInstances.get(index).Chatter_Group_Id__c = chatterGroups.get(index).Id;
    		groupIds.add(chatterGroups.get(index).Id);
    	}
    	
    	insert testTourInstances;
    	
    	Test.startTest();
        Database.executeBatch(new ChatterGroupActivationBatch(true),100);
        Database.executeBatch(new ChatterGroupActivationBatch(false),100);
    	Test.stopTest();
    	
    	List<CollaborationGroup> chatterGroupResults = [SELECT Id, IsArchived FROM CollaborationGroup
    		WHERE Id IN :groupIds];
    		
    	for (Integer resIndex = 0; resIndex < chatterGroupResults.size(); resIndex++){
    		CollaborationGroup resultChatterGroup = chatterGroupResults.get(resIndex);
    		if (resultChatterGroup.Id == chatterGroup3.Id){
    			System.assertEquals(true, resultChatterGroup.IsArchived);
    		} else {
    			System.assertEquals(false, resultChatterGroup.IsArchived);
    		}
    	}
    }
    
    private static testMethod void testSchedulingJobStart(){
    	App_Settings__c appSettings = getAppSettings();
    	insert appSettings;
    	
    	Test.startTest();
    	List<String> scheduleJobSize = ChatterGroupActivationSchedule.setupScheduleJobs();
    	Test.stopTest();
    	System.assertEquals(2, scheduleJobSize.size());
    }
}