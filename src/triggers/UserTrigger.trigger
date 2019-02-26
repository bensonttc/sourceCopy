/**
 *	Trigger on the User Object
 */
trigger UserTrigger on User (before insert, before update, after insert, after update) {

	TQUserTriggerHandler handler = new TQUserTriggerHandler(Trigger.isExecuting, Trigger.size);

	// Before
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
	}

}