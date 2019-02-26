// ******* Copyright Cloud Perspective Ltd 2014 - all rights reserved
// ******* Please ensure that this copyright is acknowledged in any subsequent use.
// ******* Contact regarding Copyright: martyn@cloudperspective.co.uk
// ******* Developer: ricky@cloudperspective.co.uk


// Class adds synchronisation functionality to any Object.
// Create a Trigger on the required object and call the following method (description of variables below):
// MDM_Custom_Synch_Class.Synchronise_This_Bookingsobj(string Obj, string SynchFlagField, list<sobject> oldList, list<sobject> newList, boolean isInsert, boolean isUpdate, boolean isDelete, boolean isBefore, boolean isAfter, boolean isUnDelete)

// Where:
// * Obj = API name of object
// * SynchFlagField = API name of the synchronisation field on the object (must be boolean)
// * oldList = trigger.old variable
// * newList = trigger.new variable
// * isInsert = trigger.isInsert variable
// * isUpdate = trigger.isUpdate variable
// * isDelete = trigger.isDelete variable
// * isBefore = trigger.isBefore variable
// * isAfter = trigger.isAfter variable
// * isUnDelete = trigger.isUnDelete variable

/*E.g.:

trigger MDM_Opportunity_Synch_Trigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {

	MDM_Custom_Synch_Class.Synchronise_This_Object('opportunity', 'MDM_Synchronize__c', trigger.old, trigger.New, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isBefore, trigger.isAfter, trigger.isUnDelete);

}
 
*/

public with sharing class MDM_Custom_Synch_Class {
	public MDM_Custom_Synch_Class() {
		
	}

	public static void Synchronise_This_Object(string Obj, string SynchFlagField, string ShouldSynchFlagField, list<sobject> oldList, list<sobject> newList, boolean isInsert, boolean isUpdate, boolean isDelete, boolean isBefore, boolean isAfter, boolean isUnDelete){
		MDM_Debug_Logs_Class Dlog = new MDM_Debug_Logs_Class('Custom Synch', Obj, false);

		MDM_Account_Creation_Setting__c Creation;
	    try{
	         Creation = MDM_Account_Creation_Setting__c.getValues('Active');
	         Dlog.LogsEnabled = Creation.Enable_Logging__c;
	    }
	    catch(exception e){
	    	Creation = new MDM_Account_Creation_Setting__c(Active__c = false);
	        Dlog.LogsEnabled = false;
	        Dlog.BlankLog('Creation setting not found');
	    }

	    //If not enabled then end class here
	    if(!Creation.Active__c || !Creation.Enable_Synch__c){
	    	Dlog.BlankLog('Synchronisation is disabled');
	    	Dlog.Comit();
	    	return;
	    }

		//old and new list for sobjects with true synchronise flag
		list<sobject> SynchOldsobj = new list<sobject>();
		list<sobject> SynchNewsobj = new list<sobject>();

		//old and new list for sobjects with false synchronise flag
		list<sobject> NotSynchOldsobj = new list<sobject>();
		list<sobject> NotSynchNewsobj = new list<sobject>();

		//Old map to get the Old Sobject
		map<ID, sobject> oldMap;

		//Update event: Split into two lists - one with Synchronize = true, one with Synchronize = false
		if(isUpdate){
			oldMap = new map<ID, sobject>(oldList);
			
			//loop round and split the records
			for(Sobject sobj: newList){
				boolean newSynchFlag = (boolean) sobj.get(SynchFlagField);
				boolean oldSynchFlag = (boolean) oldMap.get((id) sobj.get('id')).get(SynchFlagField);
				boolean ShoudlSynch = (boolean) sobj.get(ShouldSynchFlagField);
				
				//newsynch = true therefore always synch
				if(newSynchFlag && ShoudlSynch){
					Dlog.BlankLog('Update - Synch - '+ (string) sobj.get('id') );
					SynchNewsobj.add(sobj);
					SynchOldsobj.add(oldMap.get( (id) sobj.get('id') ));
				}

				//if newsynch = false and old synch = true then we need to delete
				else if(oldSynchFlag || !ShoudlSynch){
					Dlog.BlankLog('Update - Delete');
					NotSynchNewsobj.add(sobj);
					NotSynchOldsobj.add(oldMap.get( (id) sobj.get('id') ));
				}
				//If newsynch = false and oldsynch = false then we do not need to do anything 
				else{
					Dlog.BlankLog('Update - Do nothing');
				}
			}

			//For ones with Synchronise = true use API to update
			if(SynchNewsobj.size() > 0){
				DSE.API_CustomScoutClass CustomSyncUpdate = new DSE.API_CustomScoutClass(Obj);
				CustomSyncUpdate.triggerSynchronize (SynchNewsobj, SynchOldsobj, isInsert, isUpdate, isDelete, isUnDelete, isBefore, isAfter);
			}
			
			//For ones with Synchronise = false use API to delete (set isDelete to be true)		
			if(NotSynchNewsobj.size() > 0){
				DSE.API_CustomScoutClass CustomUnsynch = new DSE.API_CustomScoutClass(Obj);
				CustomUnsynch.triggerSynchronize (NotSynchNewsobj, NotSynchOldsobj, false, false, true, false, isBefore, isAfter);
			}
			
			
		}
		//Insert event: Auto Synch if the Custom setting says so. If not then follow the synch flag on the record
		else if(isInsert){

			//If auto synchronise flag set in custom setting then set all to be synchronised
			if(isBefore){
				DSE__DS_SF_Synchronization_Settings__c SynchSettings = DSE__DS_SF_Synchronization_Settings__c.getValues(Obj);
				if(SynchSettings != null){
					if(SynchSettings.DSE__Synchronize__c){
						for(Sobject sobj: NewList){
							sobj.put(SynchFlagField, true);
						}
					}
				}
				//Pass into Before Insert API (may not actually do anything!)
				DSE.API_CustomScoutClass CustomSyncInsert = new DSE.API_CustomScoutClass(Obj);
				CustomSyncInsert.triggerSynchronize (newList, null, isInsert, isUpdate, isDelete, isUnDelete, isBefore, isAfter);
			}

			//After Insert - check if the flag is set and then send to API
			else{
				for(Sobject sobj: NewList){
					boolean ShoudlSynch = (boolean) sobj.get(ShouldSynchFlagField);
					boolean SynchFlag = (boolean) sobj.get(SynchFlagField);

					if(ShoudlSynch && SynchFlag){
						Dlog.BlankLog('Insert - Synch');
						SynchNewsobj.add(sobj);
					}
				}
				//after insert API
				if(SynchNewsobj.size() > 0){
					DSE.API_CustomScoutClass CustomSyncInsert = new DSE.API_CustomScoutClass(Obj);
					CustomSyncInsert.triggerSynchronize (SynchNewsobj, null, isInsert, isUpdate, isDelete, isUnDelete, isBefore, isAfter);
				}
			}
			

			
		}
		//Delete event: Delete Bean
		else if (isDelete){
			DSE.API_CustomScoutClass CustomSyncDelete = new DSE.API_CustomScoutClass(Obj);
			CustomSyncDelete.triggerSynchronize (null, oldList, isInsert, isUpdate, isDelete, isUnDelete, isBefore, isAfter);
		}

		Dlog.Comit();

		
	}




}