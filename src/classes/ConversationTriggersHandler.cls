public without sharing class ConversationTriggersHandler {
	private static Boolean ignoreConversationObjectUpdate = false;
	
	public static void processChatterMessageAfterInsert(ChatterMessage privateMessage){
		Id ConversationId = privateMessage.ConversationId;
		Id SenderId = privateMessage.SenderId;
		Id ReceiverId = null;
		ChatterConversationMember[] conversationMembers = [SELECT Id, MemberId 
			FROM ChatterConversationMember
			WHERE ConversationId = :ConversationId AND MemberId != :SenderId];
		if (conversationMembers.size() == 1){
			for (ChatterConversationMember conversationMember : conversationMembers){
				if (conversationMember.MemberId != SenderId){
					ReceiverId = conversationMember.MemberId;
				}
			}
			
			if (ReceiverId == null){
				return;
			}		
					
			Community_Conversation__c directConversation = null, reverseConversation = null;
			Community_Conversation__c[] conversationObjects = [SELECT Id, Conversation_Id__c, Last_Message_Datetime__c,
				Last_Seen_Message_Datetime__c, Unread_Messages_Count__c, Is_Sender_Muted__c, Sender__c, Receiver__c
				FROM Community_Conversation__c
				WHERE (Sender__c = :SenderId AND Receiver__c = :ReceiverId) 
				   OR (Sender__c = :ReceiverId AND Receiver__c = :SenderId)];
				   
			for (Community_Conversation__c conversationObject : conversationObjects){
				if (conversationObject.Sender__c == SenderId){
					directConversation = conversationObject;
				}
				if (conversationObject.Sender__c == ReceiverId){
					reverseConversation = conversationObject;
				}
			}
			
			if (directConversation == null){
				directConversation = new Community_Conversation__c(
					Last_Seen_Message_Datetime__c = null,
					Sender__c = SenderId,
					Receiver__c = ReceiverId,
					Unread_Messages_Count__c = 0
				);
			} 
			directConversation.Conversation_Id__c = ConversationId;
			if (directConversation.Is_Sender_Muted__c != true){
				directConversation.Last_Message_Datetime__c = privateMessage.SentDate;
				if (directConversation.Unread_Messages_Count__c == null)
					directConversation.Unread_Messages_Count__c = 1; 
				else
					directConversation.Unread_Messages_Count__c += 1;			
			}
			
			if (reverseConversation == null){
				reverseConversation = new Community_Conversation__c(
					Last_Seen_Message_Datetime__c = null,
					Sender__c = ReceiverId,
					Receiver__c = SenderId
				);			
			}
			reverseConversation.Conversation_Id__c = ConversationId;
			reverseConversation.Last_Message_Datetime__c = privateMessage.SentDate;
			
			ignoreConversationObjectUpdate = true;
			upsert new List<Community_Conversation__c>{directConversation, reverseConversation};
			ignoreConversationObjectUpdate = false;
		}
	}
	
	public static void recalculateUnreadMessagesCount(List<Community_Conversation__c> conversationObjects,
		Map<Id, Community_Conversation__c>oldValuesMap){
		if (!ignoreConversationObjectUpdate && conversationObjects.size() > 0){
			for (Community_Conversation__c conversationObject : conversationObjects){
				Community_Conversation__c oldValues = oldValuesMap.get(conversationObject.Id);
				if (conversationObject.Conversation_Id__c != null && 
					oldValues.Last_Seen_Message_Datetime__c != conversationObject.Last_Seen_Message_Datetime__c &&
					conversationObject.Last_Seen_Message_Datetime__c != null){
					conversationObject.Unread_Messages_Count__c = [SELECT COUNT()
						FROM ChatterMessage 
						WHERE ConversationId = :conversationObject.Conversation_Id__c
						  AND SentDate > :conversationObject.Last_Seen_Message_Datetime__c
						  AND SenderId != :conversationObject.Sender__c];
				}
			}
		}
	}
}