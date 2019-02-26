/**
 *	Trigger on the Tour_Instance__c Object
 */
trigger TourInstanceTrigger on Tour_Instance__c (before insert, before update, after insert, after update) {

	TQTourInstanceTriggerHandler handler = new TQTourInstanceTriggerHandler();
	handler.execute();
	/*// Before
	if(Trigger.isBefore) {
		// Insertion of a new record
		if(Trigger.isInsert) {
			handler.OnBeforeInsert(Trigger.new);
		} 

		// Update of an existing record
		else if(Trigger.isUpdate) {
			handler.OnBeforeUpdate(Trigger.new);
		}
	}

	// After
	if(Trigger.isAfter) {
		// Insertion of a new record
		if(Trigger.isInsert) {
			handler.OnAfterInsert(Trigger.new, Trigger.newMap);
		} 

		// Update of an existing record
		else if(Trigger.isUpdate) {
			handler.OnAfterUpdate(Trigger.new, Trigger.newMap);
		}
	}*/

}