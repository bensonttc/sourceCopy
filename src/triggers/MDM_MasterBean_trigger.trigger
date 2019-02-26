trigger MDM_MasterBean_trigger on DSE__DS_Master_bean__c (before insert, after insert, before update, after update) {
    string TriggerEvent = '';

    if(trigger.isBefore) TriggerEvent += 'Before';
    else TriggerEvent += 'After';

    if(trigger.isInsert) TriggerEvent += 'Insert';
    else if(trigger.isUpdate) TriggerEvent += 'Update';

    MDM_Debug_Logs_Class Dlog = new MDM_Debug_Logs_Class('MB Trigger', TriggerEvent, false);

    Dlog.BlankLog('********************* MDM_MasterBean_trigger***************************');

    //Before update on Master Bean changes field values e.g. CP segment
    if((trigger.isUpdate || trigger.isInsert) && trigger.isBefore){
        MDM_Person_Account_Conversion_Class.Before_Update_or_insert(trigger.new, trigger.isInsert);
    }

    MDM_Account_Creation_Setting__c Creation = MDM_Account_Creation_Setting__c.getValues('Active');
    if(Creation == null){
        Creation = new MDM_Account_Creation_Setting__c(Active__c = false);
    }
    //Account Creation process
    if(Creation.Active__c && creation.Enable_Account_Creation__c){
        Dlog.LogsEnabled = Creation.Enable_Logging__c;
        MDM_Person_Account_Conversion_Class Synch = new MDM_Person_Account_Conversion_Class(Dlog);

        if(trigger.ISUpdate){//  && !MDM_Recursion_Handler.TurnOffMasterBeanTrigger){//&& !MDM_Recursion_Handler.TurnOffCMDMAccountTrigger 
            if(trigger.isBefore  && !MDM_Recursion_Handler.TurnOffBeforeMB){
                Dlog.BlankLog('* MB Before Trigger *');
                //MDM_Recursion_Handler.TurnOffBeforeMB = true;   //Just in case Bulk API used - only process the first 200
                Synch.AccountEnrichment(trigger.oldMap, trigger.new, trigger.isInsert);
            }
            else if(!MDM_Recursion_Handler.TurnOffAfterMB){
                //MDM_Recursion_Handler.TurnOffAfterMB = true;    //Just in case Bulk API used - only process the first 200
                Dlog.BlankLog('* MB After Trigger *');
                Synch.AfterMBUpdate(trigger.new);
            }
        }
    }


    Dlog.BlankLog('***********************TRIGGER END *************************************');
    Dlog.Comit();
}