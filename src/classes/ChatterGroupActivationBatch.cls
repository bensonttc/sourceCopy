global class ChatterGroupActivationBatch implements Database.Batchable<sObject>{
   private Boolean setArchived;
   private final Integer daysToCheck = 10;

   global ChatterGroupActivationBatch(Boolean shouldSetArchived){
   		setArchived = shouldSetArchived;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
   	  App_Settings__c settings = App_Settings__c.getValues(ChatterGroupHandler.customSettingsName);
   	  
   	  if (setArchived) {
   	  	  Integer pastDays = settings.Past_Trip_Deactivation_In_Days__c.intValue();
	      return Database.getQueryLocator([
	      	SELECT Id, Name, Chatter_Group_Id__c, Travel_Director__c
	        FROM Tour_Instance__c
	      	WHERE End_Date__c <= :Date.today().addDays(-pastDays)
	      	  AND End_Date__c > :Date.today().addDays(-pastDays - daysToCheck)
	      ]);
   	  } else {
   	  	  Integer upcomingDays = settings.Upcoming_Trip_Activation_In_Days__c.intValue();
	      return Database.getQueryLocator([
	      	SELECT Id, Name, Chatter_Group_Id__c, Travel_Director__c 
	      	FROM Tour_Instance__c
	      	WHERE Start_Date__c >= :Date.today()
	      	  AND Start_Date__c <= :Date.today().addDays(upcomingDays)
	      ]);
   	  }
   }
   
   global void execute(Database.BatchableContext BC,
                       List<sObject> scope){                      	
       Set<Id> chatterGroupIds = new Set<Id>();
       Map<String, Id> groupTDs = new Map<String, Id>();
       for (sObject tourInstance : scope){
       	  String chatterGroupId = (String)tourInstance.get('Chatter_Group_Id__c');
       	  if (chatterGroupId != null){
       	  	chatterGroupIds.add(chatterGroupId);
       	  	groupTDs.put(chatterGroupId, ((Tour_Instance__c)tourInstance).Travel_Director__c);
       	  }
       }
       
       List<CollaborationGroup> chatterGroups = [
       	SELECT Id, isArchived, OwnerId, Owner.AccountId
       	FROM CollaborationGroup
       	WHERE Id IN :chatterGroupIds
       	AND isArchived = :!setArchived
       ];
       
       List <CollaborationGroup> groupToUpdate = new List<CollaborationGroup>();
       for (CollaborationGroup chatterGroup : chatterGroups){
       	    if (setArchived || chatterGroup.Owner.AccountId != null || 
       	    	chatterGroup.OwnerId == groupTDs.get(chatterGroup.Id)) {
       	  		groupToUpdate.add(new CollaborationGroup(
       	  			Id = chatterGroup.Id,
       	  			IsArchived = setArchived
       	  		));
       		}
       }
       
       Database.update(groupToUpdate, false);
   }
   
   global void finish(Database.BatchableContext BC){
   }	    
}