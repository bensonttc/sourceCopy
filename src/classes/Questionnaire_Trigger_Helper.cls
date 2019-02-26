public without sharing class Questionnaire_Trigger_Helper extends TriggerHandlerV2 {
    private MDM_Account_Creation_Setting__c Creation;
    private map<id, Account> AccMap;
    
    // **************************
    // **** Constructor *********
    // **************************
    public Questionnaire_Trigger_Helper() {
        Creation = MDM_Account_Creation_Setting__c.getValues('Active');
        if(Creation == null){
            Creation = new MDM_Account_Creation_Setting__c(Active__c = false, Name = 'Active');
        }

        AccMap = new map<id, Account>();
    }


    // **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
        SetBusinessUnitLookup(newObjects);
    }

    // **********************************
    // ******* Before Update *************
    // **********************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) 
    {
        SetBusinessUnitLookup(newObjects);
        if(Creation.Active__c && Creation.Enable_Preference_Management__C){
            UpdatePreferences(newObjects, oldMap);
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

    //********************************
    //*** Set Business Unit Lookup ***
    //********************************
    public void SetBusinessUnitLookup(list<Sobject> NewQuestionnaires){
        AccMap = MDM_Helper_Class.setBusinessUnit('Selling_Company_Code__c', 'Selling_Company__c', 'Brand__c', NewQuestionnaires);
       

       /* set<string> BUExtIDs = new set<string>();
        set<id> BUIDs = new set<id>();
        for(Questionnaire__c quest : NewQuestionnaires){
            if(quest.Selling_Company__c != null){
                BUIDs.add(quest.Selling_Company__c);
            }
            else if(quest.Selling_Company_Code__c != null){
                BUExtIDs.add(quest.Selling_Company_Code__c);
            }
        }

        AccMap = new Map<id, Account>([select id, External_ID__c, parentID, Parent.name, name from Account where External_ID__c in :BUExtIDs OR id in :BUIDs]);
        map<string, ID> ExtMap = new map<string, ID>();
        for(Account Acc : AccMap.values()){
            ExtMap.put(Acc.External_ID__c, Acc.ID);
        }

        //Get brand from SellingCompanyID
        for(Questionnaire__c quest : NewQuestionnaires){
            if(quest.Selling_Company_Code__c != null){
                ID BUID = ExtMap.get(quest.Selling_Company_Code__c);
                if(BUID != null) quest.Selling_Company__c = BUID;
            }
            if(quest.Selling_Company__c != null && AccMap != null){
                quest.Brand__c = AccMap.get(quest.Selling_Company__c).parentID;
            }
        }
        */

    }

    //********************************
    //*** Create Marketing Consent ***
    //********************************
    public void UpdatePreferences(list<Sobject> Questionnaires, map<id, sobject> oldMap){
        Marketing_Consent_Handler_Class PrefClass = new Marketing_Consent_Handler_Class('Questionnaire__c');

        //get the Booking Passenger information
        for(Sobject sobj: Questionnaires){
            Questionnaire__c quest = (Questionnaire__c) sobj;
            Questionnaire__c oldQuest = (Questionnaire__c) oldMap.get(quest.id);
            
            //Build the Preferences
            if(quest.Customer__c != null && quest.Selling_Company__c != null && (oldQuest.Customer__c == null || quest.Create_MC__c || quest.Marketing_Consent__c == null)){
                Marketing_Consent__c thisPref = new Marketing_Consent__c();
                thisPref.Questionnaire__c = quest.id;
                thisPref.Customer_or_Prospect__c = quest.Customer__c;
                thisPref.Date_Entered__c = quest.Departure_Date__c;
                thisPref.Selling_Company__c = quest.Selling_Company__c;
                thisPref.Brand__c = quest.Brand__c;

                //Set Brand/BU names
                Account BU = AccMap.get(quest.Selling_Company__c);
                if(BU != null){
                    thisPref.Brand_Text__c = BU.parent.name;
                    thisPref.Business_Unit_Text__c = BU.name;
                }
                
                if(quest.Comms__c == 'Y'){
                    thisPref.Opt_In__c = true;
                }
                else if(quest.Comms__c == 'N'){
                    thisPref.Opt_In__c = false;
                }
                thisPref.Assumed_Opt_in__c = false;                 
                thisPref.Source__c = 'Questionnaire';
                thisPref.Type__c = 'Global';  
                quest.Marketing_Consent_External_ID__c = thisPref.Selling_Company__c + '#' + thisPref.Customer_or_Prospect__c;
                thisPref.External_ID__c = quest.Marketing_Consent_External_ID__c;

                PrefClass.addPreference(thisPref, quest.id);
            }

            quest.Create_MC__c = false;
        }

        //Create the MC
        map<string, id> SourceToID = PrefClass.createPreferences();

        //need to change so that it links the External IDs back
        if(SourceToID.size() > 0){
            for(Sobject sobj: Questionnaires){
                Questionnaire__c quest = (Questionnaire__c) sobj;
                if(quest.Marketing_Consent_External_ID__c != null){
                    ID MCID = SourceToID.get(quest.Marketing_Consent_External_ID__c);
                    if(MCID != null){
                        quest.Marketing_Consent__c = MCID;
                    }
                }
            }
        } 
    }   
}