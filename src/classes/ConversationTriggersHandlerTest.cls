@isTest
private class ConversationTriggersHandlerTest {

	@isTest(seeAllData=true)
	static void testChatterMessageTestExecution(){
    	User tdUser = TqTestUtils.createTDUser('Test', 'Person', 'test2342342342341231231@test.com', 'test345343234221@test.com');
    	tdUser.ProfileId = UserInfo.getProfileId();
    	insert tdUser;
	
		ConnectApi.ChatterMessage resultMessage = ConnectApi.ChatterMessages.sendMessage(
				'Send specific chatter mesasge',
				 tdUser.Id
		);
		
		Test.startTest();
		System.assertNotEquals(null, resultMessage);
		Test.stopTest();
	}

    static testMethod void testUnreadMessagesUpdate() {
        Community_Conversation__c newConversation = new Community_Conversation__c(
        	//Id = 'a0Vg00000055ymN',
        	Conversation_Id__c = 'TESTCONVERSATIONID',
        	Last_Seen_Message_Datetime__c = null,
        	Unread_Messages_Count__c = 20
        );
        insert newConversation;
        
        /*Community_Conversation__c oldConversation = new Community_Conversation__c(
        	Id = 'a0Vg00000055ymN',
        	Conversation_Id__c = 'TESTCONVERSATIONID',
        	Last_Seen_Message_Datetime__c = DateTime.now().addDays(-30),
        	Unread_Messages_Count__c = 20
        );*/
        
        Test.startTest();
        Community_Conversation__c conversationToUpdate = new Community_Conversation__c(
        	Id = newConversation.Id,
        	Last_Seen_Message_Datetime__c = DateTime.now()
    	);
        update conversationToUpdate;
        Test.stopTest();
        
        Community_Conversation__c resultConversation = [SELECT Id, Unread_Messages_Count__c 
        	FROM Community_Conversation__c
        	WHERE Id = :newConversation.Id];
        System.assertEquals(0, resultConversation.Unread_Messages_Count__c);
    }
}