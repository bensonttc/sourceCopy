trigger IndividualEmailResultTrigger on et4ae5__IndividualEmailResult__c (Before Insert, Before Update, Before Delete, After Insert, After Update, After Delete) {
    if(Trigger.isBefore){
        List<et4ae5__IndividualEmailResult__c> recordsToProcess = new List<et4ae5__IndividualEmailResult__c>();
        if(Trigger.isInsert){
            for(et4ae5__IndividualEmailResult__c emailResult : Trigger.New){
                if(emailResult.et4ae5__DateUnsubscribed__c != Null && emailResult.et4ae5__SendDefinition__c != Null){
                    recordsToProcess.add(emailResult);
                    system.debug('The email result Id is '+emailResult.id);
                    system.debug('the email result is '+emailResult);
                }
            }
            if(recordsToProcess.size() > 0){
                IndividualEmailResultTriggerHandler.MCUnsubscribe(recordsToProcess);
            }
        } else if(Trigger.isUpdate){
            for(et4ae5__IndividualEmailResult__c emailResult : Trigger.New){
                et4ae5__IndividualEmailResult__c oldEmailResult = Trigger.OldMap.get(emailResult.Id);
                if(emailResult.et4ae5__DateUnsubscribed__c != Null && oldEmailResult.et4ae5__DateUnsubscribed__c != Null && emailResult.et4ae5__SendDefinition__c != Null){
                    recordsToProcess.add(emailResult);
                }
            }
            if(recordsToProcess.size() > 0){
                IndividualEmailResultTriggerHandler.MCUnsubscribe(recordsToProcess);
            }
        }
    }
}