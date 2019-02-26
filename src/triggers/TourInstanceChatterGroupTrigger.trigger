trigger TourInstanceChatterGroupTrigger on Tour_Instance__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        TQTourInstanceTriggerHandler.populateTravelDirectorLookup(Trigger.new, Trigger.oldMap);
    }
    
    // Code changes done by Ravi Jain for story S-569799
    // Start - Ravi Jain - S-569799 - 25th July, 2018 - Call the trigger on before update
    if(trigger.isBefore && trigger.isUpdate){
        TQTourInstanceTriggerHandler.runBatchForTourInstance(trigger.new, trigger.oldMap);    
    }
    // End - Ravi Jain - S-569799 - 25th July, 2018
    
    if (Trigger.isInsert && Trigger.isAfter){
        ChatterGroupHandler.createChatterGroupsForTourInstances(Trigger.new);
    }
    
    if (Trigger.isUpdate && Trigger.isAfter){
        ChatterGroupHandler.assignTravelDirectorsForChatterGroup(Trigger.new, Trigger.oldMap);
    }
}