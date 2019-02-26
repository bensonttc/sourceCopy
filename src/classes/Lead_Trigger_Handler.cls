public without sharing class Lead_Trigger_Handler extends TriggerHandlerV2 {
	private MDM_Account_Creation_Setting__c Creation;
	//private DSE.API_LeadTriggerHandler apiHandler;
	private MDM_Debug_Logs_Class Dlog;
    private boolean MDMon;
	
	// **************************
	// **** Constructor *********
	// **************************
	public Lead_Trigger_Handler(Boolean Intrigger) {
        if(Intrigger){
            MDMon = true;
            string TriggerEvent = '';

            if(trigger.isBefore) TriggerEvent += 'Before';
            else TriggerEvent += 'After';

            if(trigger.isInsert) TriggerEvent += 'Insert';
            else if(trigger.isUpdate) TriggerEvent += 'Update';

            Dlog = new MDM_Debug_Logs_Class('Lead Trigger', TriggerEvent, false);

            Creation = MDM_Account_Creation_Setting__c.getValues('Active');
            if(Creation == null){
                Creation = new MDM_Account_Creation_Setting__c(Active__c = false, Name = 'Active');
            }
            Dlog.LogsEnabled = Creation.Enable_Logging__c;

            MDM_Custom_Synch_Class.Synchronise_This_Object('Lead', 'MDM_Synchronize__c', 'Should_Synchronise__c', trigger.old, trigger.New, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isBefore, trigger.isAfter, trigger.isUnDelete);        
        }
	}


	// **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
        SetBusinessUnitLookup(newObjects);
    	if(Creation.Active__c && MDMon){
    		
    	}
    }

    // **********************************
    // ******* Before Update *************
    // **********************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) 
    {
        SetBusinessUnitLookup(newObjects);
    	if(Creation.Active__c && MDMon && Creation.Enable_Preference_Management__C){
    		UpdatePreferences(newObjects, oldMap);
    	}
    }

    // **********************************
    // ******* Before Delete *************
    // **********************************
    public override void beforeDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
    	if(Creation.Active__c && MDMon){
    		
    	}
    }

    // **********************************
    // ******* After Insert *************
    // **********************************
    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
        if(Creation.Active__c && MDMon){
        	
        }
    }


    // **********************************
    // ******* After Update *************
    // **********************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) 
    {
    	if(Creation.Active__c && MDMon){
    	 	
    	}
    }

    // **********************************
    // ******* After Delete *************
    // **********************************
    public override void afterDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
    	if(Creation.Active__c && MDMon){
    		
    	}
    }

    // **********************************
    // ******* After UnDelete *************
    // **********************************
    public override void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap)
    {    
    	if(Creation.Active__c && MDMon){   

    	}
    }

    // *****************************************************************************************************************************************************************************************************************************************************************************************************************************************************

    //********************************
    //*** Set Business Unit Lookup ***
    //********************************
    public void SetBusinessUnitLookup(list<Sobject> Leads){
        //Create Business Unit lookup - 
        MDM_Helper_Class.setBusinessUnit('Selling_Company_Code__c', 'Business_Unit__c', 'Brand_Lookup__c', Leads);

    }

    //********************************
    //*** Create Marketing Consent ***
    //********************************
    public void UpdatePreferences(list<Sobject> Leads, map<id, sobject> oldMap){
        Marketing_Consent_Handler_Class PrefClass = new Marketing_Consent_Handler_Class(null);

        //get the Booking Passenger information
        for(Sobject sobj: Leads){
            Lead LeadInst = (Lead) sobj;
            Lead oldLead = (Lead) oldMap.get(LeadInst.id);
            //Build the Preferences
            if(LeadInst.ISConverted && LeadInst.ConvertedAccountId != null && LeadInst.Business_Unit__c != null && LeadInst.Marketing_Consent__c == null){
                Marketing_Consent__c thisPref = new Marketing_Consent__c();
                thisPref.Customer_or_Prospect__c = LeadInst.ConvertedAccountId;
                thisPref.Date_Entered__c = date.today();
                thisPref.Selling_Company__c = LeadInst.Business_Unit__c;
                thisPref.Brand__c = LeadInst.Brand_Lookup__c;

                //----MIGHT REMOVE AND REPLACE WITH WORKFLOW RULE - Set Brand/BU names
                /*Account BU = AccMap.get(Business_Unit__c);
                if(BU != null){
                    thisPref.Brand_Text__c = BU.parent.name;
                    thisPref.Business_Unit_Text__c = BU.name;
                }
                */

                thisPref.Type__c = LeadInst.Web_Request_Type__c;

                if(LeadInst.Web_Request_Type__c == 'Newsletter'){
                    thisPref.Assumed_Opt_in__c = false;
                    thisPref.Opt_In__c = true;
                }
                else if(LeadInst.Request_Newsletter__c){
                    thisPref.Assumed_Opt_in__c = false;
                    thisPref.Opt_In__c = true;
                }
                else{
                    thisPref.Assumed_Opt_in__c = true;
                    thisPref.Opt_In__c = true;
                }

                thisPref.Source__c = 'Lead';
                //thisPref.Source__c = LeadInst.Request_Type__c;
                

                LeadInst.Marketing_Consent_External_ID__c = thisPref.Selling_Company__c + '#' + thisPref.Customer_or_Prospect__c;
                thisPref.External_ID__c = LeadInst.Marketing_Consent_External_ID__c;

                PrefClass.addPreference(thisPref, LeadInst.id);
            }
            if(LeadInst.ConvertedAccountId != null){
                LeadInst.MDM_Synchronize__c = false;
            }
        }

        //Create the MC
        map<string, id> SourceToID = PrefClass.createPreferences();

        //Link back to MC
        if(SourceToID.size() > 0){
            for(Sobject sobj: Leads){
                Lead LeadInst = (Lead) sobj;
                if(LeadInst.Marketing_Consent_External_ID__c != null){
                    ID MCID = SourceToID.get(LeadInst.Marketing_Consent_External_ID__c);
                    if(MCID != null){
                        LeadInst.Marketing_Consent__c = MCID;
                    }
                }
            }
        } 

    }

}