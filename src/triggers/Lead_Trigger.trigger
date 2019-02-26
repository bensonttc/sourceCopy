trigger Lead_Trigger on Lead (after delete, after undelete, after update, after insert,  before delete, before insert, before update) {
    Lead_Trigger_Handler triggerHandler = new Lead_Trigger_Handler(TRUE);
    triggerHandler.execute();
}