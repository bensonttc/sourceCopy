public without sharing class Pre_Registration_Trigger_Helper extends TriggerHandlerV2 {
	private MDM_Account_Creation_Setting__c Creation;
	private map<id, Account> AccMap;

	// **************************
	// **** Constructor *********
	// **************************
	public Pre_Registration_Trigger_Helper() {
		Creation = MDM_Account_Creation_Setting__c.getValues('Active');
	    if(Creation == null){
	        Creation = new MDM_Account_Creation_Setting__c(Active__c = false, Name = 'Active');
	    }

        AccMap = new map<id, Account>();
        MDM_Custom_Synch_Class.Synchronise_This_Object('Pre_Registration__c', 'MDM_Synchronize__c', 'Should_Synchronise__c', trigger.old, trigger.New, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isBefore, trigger.isAfter, trigger.isUnDelete);
	}

}