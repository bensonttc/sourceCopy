trigger Request_Trigger on Request__c (before insert, after insert, before update, after update, before delete, after delete) {
    Request_Trigger_Helper triggerHandler = new Request_Trigger_Helper();
    triggerHandler.execute();
}