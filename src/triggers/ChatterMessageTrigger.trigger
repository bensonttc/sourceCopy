trigger ChatterMessageTrigger on ChatterMessage (after insert) {
	if (Trigger.isAfter && Trigger.isInsert){
		//It's physically impossible to have more then one object in ChatterMessage trigger, because
		//of very strong limitations, which mean that you can create message only with api and only with one message 
		//per call
		for (ChatterMessage message : Trigger.new){
			ConversationTriggersHandler.processChatterMessageAfterInsert(message);
		}
	}
}