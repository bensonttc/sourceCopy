trigger Account_Trigger on Account (after delete, after undelete, after update, after insert,  before delete, before insert, before update) {
    Account_Trigger_Handler triggerHandler = new Account_Trigger_Handler();
    triggerHandler.execute();
}