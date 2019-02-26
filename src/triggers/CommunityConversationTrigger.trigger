trigger CommunityConversationTrigger on Community_Conversation__c (before update) {
	if (Trigger.isBefore && Trigger.isUpdate){
		ConversationTriggersHandler.recalculateUnreadMessagesCount(Trigger.new, Trigger.oldMap);
	}
}