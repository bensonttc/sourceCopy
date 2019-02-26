trigger caseTrigger on Case (before insert) {
    
    caseTriggerHandler caseTrigHand = new caseTriggerHandler();
    if(Trigger.isBefore) {
        if(Trigger.isInsert ) {
            caseTrigHand.InsertCases(Trigger.new);
        }
    } 
}