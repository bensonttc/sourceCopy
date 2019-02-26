trigger Marketing_Consent_Trigger on Marketing_Consent__c (before insert, after insert, before update, after update, before delete, after delete) {
    Marketing_Consent_Trigger_Handler triggerHandler = new Marketing_Consent_Trigger_Handler();
    triggerHandler.execute();
}