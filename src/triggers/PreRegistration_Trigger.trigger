trigger PreRegistration_Trigger on Pre_Registration__c (before insert, after insert, before update, after update, before delete, after delete) {
	Pre_Registration_Trigger_Helper triggerHandler = new Pre_Registration_Trigger_Helper();
    triggerHandler.execute();
}