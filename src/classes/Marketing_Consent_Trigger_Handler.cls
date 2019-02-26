public without sharing class Marketing_Consent_Trigger_Handler extends TriggerHandlerV2 {
    private MDM_Account_Creation_Setting__c Creation;
    
    // **************************
    // **** Constructor *********
    // **************************
    public Marketing_Consent_Trigger_Handler() {
        Creation = MDM_Account_Creation_Setting__c.getValues('Active');
        if(Creation == null){
            Creation = new MDM_Account_Creation_Setting__c(Active__c = false, Name = 'Active');
        }
    }


    // **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
        ClearDoNotArchiveFlag(newObjects);
    }

    // **********************************
    // ******* Before Update *************
    // **********************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) 
    {
    	if(Creation.Active__c && Creation.Enable_Preference_Management__C){
        	Marketing_Consent_Before_Update(oldMap, newMap);
        }
    }

    // **********************************
    // ******* Before Delete *************
    // **********************************
    public override void beforeDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {

    }

    // **********************************
    // ******* After Insert *************
    // **********************************
    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
       
    }


    // **********************************
    // ******* After Update *************
    // **********************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) 
    {
        
    }

    // **********************************
    // ******* After Delete *************
    // **********************************
    public override void afterDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
    }

    // **********************************
    // ******* After UnDelete *************
    // **********************************
    public override void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap)
    {       
    }

    // *****************************************************************************************************************************************************************************************************************************************************************************************************************************************************

    //*********************************
    //*** Clear do not archive flag ***
    //*********************************
    public static void ClearDoNotArchiveFlag(list<Marketing_Consent__c> NewMC){
	    for(Marketing_Consent__c MC : NewMC){
			MC.Do_Not_Archive_On_Save__c = false;
		}
	}


    //***********************************
    //*** Marketing Consent Archiving ***
    //***********************************
	public static void Marketing_Consent_Before_Update(map<id,Sobject> oldPrefMap,  map<id,Sobject> newPrefMap){
		Marketing_Consent_Handler_Class PrefClass = new Marketing_Consent_Handler_Class(null);
		ID ActiveMCID = Marketing_Consent_Handler_Class.MCRecordTypeMap.get('ActivePreference');

		for(Sobject Sobj : newPrefMap.values()){
			Marketing_Consent__c Pref = (Marketing_Consent__c) Sobj;
			Marketing_Consent__c oldPref = (Marketing_Consent__c) oldPrefMap.get(Pref.id).clone(false, true, true, true);

			//If the change was made directly to the 
			if(!Pref.Do_Not_Archive_On_Save__c && Pref.RecordTypeID == ActiveMCID){
				boolean manualChange = false;
                Pref.Assumed_Opt_in__c = false;
				if(Pref.Source__c == oldPref.Source__c && Pref.Opt_In__c != oldPref.Opt_In__c){
					system.debug('MC: Record was edited but source not changed - change to manaul override');
					Pref.Source__c = 'Manual Override';
                    manualChange = true;
				}

				if(Pref.Date_Entered__c == oldPref.Date_Entered__c && Pref.Opt_In__c != oldPref.Opt_In__c){
					system.debug('MC: Record was edited but date did not changed - change date to today');
					Pref.Date_Entered__c = date.today();
                    manualChange = true;
				}
                
				//Pick the winner
                if(!manualChange){
                    Marketing_Consent__c oldPrefClone = oldPref.Clone(false, true, false, false);
                    Marketing_Consent__c newPrefClone = Pref.Clone(false, true, false, false);

                    Pref = PrefClass.comparePreferences(newPrefClone, oldPrefClone);
                }
                else{
                    PrefClass.ArchiveThisPreference(oldPref);   //Archive the old preference
                }
				

				if(Pref.Source__c != 'Booking' && Pref.Source__c != 'Reservation' ) Pref.Booking_Passenger__c = null;
				if(Pref.Source__c != 'Request') Pref.Request__c = null;
				if(Pref.Source__c != 'Questionnaire') Pref.Questionnaire__c = null;

			}
			Pref.Do_Not_Archive_On_Save__c = false;
		}
		PrefClass.UpsertArchived();	
	}  
}