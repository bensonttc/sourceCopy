trigger PassengerChatterGroupTrigger on Passenger__c (before insert, before update, after insert, after update) {
	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		ChatterGroupHandler.populatePassangersWithUserData(Trigger.new);
	}

	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
		ChatterGroupHandler.createChatterGroupMembersForPassengers(Trigger.new, Trigger.oldMap);
	}
}