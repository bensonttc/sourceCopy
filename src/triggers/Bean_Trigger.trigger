trigger Bean_Trigger on DSE__DS_Bean__c (before insert, before update) {
    
    if(trigger.IsBefore && (trigger.IsUpdate || trigger.IsInsert)){
        Bean_trigger_helper.Before_Update_or_insert(trigger.new, trigger.oldMap, trigger.isInsert, trigger.isUpdate);
    }
}