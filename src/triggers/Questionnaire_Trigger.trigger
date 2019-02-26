trigger Questionnaire_Trigger on Questionnaire__c (before insert, after insert, before update, after update, before delete, after delete) {
    Questionnaire_Trigger_Helper triggerHandler = new Questionnaire_Trigger_Helper();
    triggerHandler.execute();
}