public without sharing class Account_Trigger_Handler extends TriggerHandler {
    private MDM_Account_Creation_Setting__c Creation;
    private DSE.API_AccountTriggerHandler apiHandler;
    private MDM_Debug_Logs_Class Dlog;
    
    // **************************
    // **** Constructor *********
    // **************************
    public Account_Trigger_Handler() {
        string TriggerEvent = '';

        if(trigger.isBefore) TriggerEvent += 'Before';
        else TriggerEvent += 'After';

        if(trigger.isInsert) TriggerEvent += 'Insert';
        else if(trigger.isUpdate) TriggerEvent += 'Update';

        Dlog = new MDM_Debug_Logs_Class('Account Trigger', TriggerEvent, false);

        Creation = MDM_Account_Creation_Setting__c.getValues('Active');
        if(Creation == null){
            Creation = new MDM_Account_Creation_Setting__c(Active__c = false, Name = 'Active');
        }
        Dlog.LogsEnabled = Creation.Enable_Logging__c;

        if(Creation.Active__c && Creation.Enable_Account_Trigger__c){
            apiHandler = new DSE.API_AccountTriggerHandler();
            try {
                apiHandler.initTrigger(); 
            }
            catch (DSE.API_AccountTriggerHandler.DS_CloudMDMSkipTriggerException es) 
            {
                Dlog.BlankLog('MDM INITIALISATION FAILED');
                Dlog.Comit();
                return;
            }
            catch (Exception e)
            {
                Dlog.BlankLog('MDM INITIALISATION FAILED');
                Dlog.Comit();
                throw new DSE.API_AccountTriggerHandler.DS_CloudMDMTriggerAPIException ( 'Cloud MDM Trigger API Initialization Failed');
            }
        }

    }


    // **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
        if(Creation.Active__c && Creation.Enable_Account_Trigger__c && !MDM_Recursion_Handler.TurnOffCMDMAccountTrigger){
            system.debug('MDM Account Before Insert Firing');
            //MDM_Recursion_Handler.TurnOffMasterBeanTrigger = true;
            apiHandler.Trigger_InsertBefore_Handler(); 
            Dlog.Comit();
        }
        else{
            system.debug('MDM Account Before Insert NOT Firing');
        }
    }

    // **********************************
    // ******* Before Update *************
    // **********************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) 
    {
        if(Creation.Active__c && Creation.Enable_Account_Trigger__c && !MDM_Recursion_Handler.TurnOffCMDMAccountTrigger){
            system.debug('MDM Account Before Update Firing');
            //MDM_Recursion_Handler.TurnOffMasterBeanTrigger = true;
            apiHandler.Trigger_UpdateBefore_Handler(); 
            Dlog.Comit();
        }
        else{
            system.debug('MDM Account Before Update NOT Firing');
        }
    }

    // **********************************
    // ******* Before Delete *************
    // **********************************
    public override void beforeDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
        if(Creation.Active__c && Creation.Enable_Account_Trigger__c){
            system.debug('MDM Account Before Delete Firing');
            //MDM_Recursion_Handler.TurnOffMasterBeanTrigger = true;
            apiHandler.Trigger_DeleteBefore_Handler(); 
            Dlog.Comit();
        }
        else{
            system.debug('MDM Account Before Delete NOT Firing');
        }
    }

    // **********************************
    // ******* After Insert *************
    // **********************************
    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
        if(Creation.Active__c && Creation.Enable_Account_Trigger__c && !MDM_Recursion_Handler.TurnOffCMDMAccountTrigger){
            system.debug('MDM Account After Insert Firing');
            //MDM_Recursion_Handler.TurnOffMasterBeanTrigger = true;
            apiHandler.Trigger_InsertAfter_Handler();
            Dlog.Comit();
        }
        else{
            system.debug('MDM Account After Insert NOT Firing');
        }
    }


    // **********************************
    // ******* After Update *************
    // **********************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) 
    {
        if(Creation.Active__c && Creation.Enable_Account_Trigger__c && !MDM_Recursion_Handler.TurnOffCMDMAccountTrigger){
            system.debug('MDM Account After Update Firing');
            //MDM_Recursion_Handler.TurnOffMasterBeanTrigger = true;
            apiHandler.Trigger_UpdateAfter_Handler();
            Dlog.Comit();
        }
        else{
            system.debug('MDM Account After Update NOT Firing');
        }
    }

    // **********************************
    // ******* After Delete *************
    // **********************************
    public override void afterDelete(List<SObject> oldObjects, Map<Id, SObject> oldObjectsMap) 
    {
        if(Creation.Active__c && Creation.Enable_Account_Trigger__c ){
            system.debug('MDM Account After Delete Firing');
            //MDM_Recursion_Handler.TurnOffMasterBeanTrigger = true;
            apiHandler.Trigger_DeleteAfter_Handler(); 
            Dlog.Comit();
        }
        else{
            system.debug('MDM Account After Delete NOT Firing');
        }
        // For non-batch duplicate mergeing - run reparenting.
        if (!System.isBatch()){
            Merge_Marketing_Consent(oldObjectsMap);
            Merge_Manual_Share(oldObjectsMap);
        } else {
            System.debug('System.isBatch()='+System.isBatch());
            System.debug('Invoked Batch process - do not run reparenting.');
        }
    }

    // **********************************
    // ******* After UnDelete *************
    // **********************************
    public override void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap)
    {    
        if(Creation.Active__c && Creation.Enable_Account_Trigger__c){   

        }
    }

    // ------------Update marketing consent records on Winning Account---------------
    public void Merge_Marketing_Consent(Map<Id, SObject> oldObjectsMap){

        String ExternalID = '';
        list<String> HalfExternalID = new list<String>();

        //Get set of DeletedAccount IDs
        set<Id> DeletedAccountIDs = oldObjectsMap.keySet();

        //Initiate set of winning Accounts to reduce Marketing Consent querying
        set<Id> MasterAccountIDs = new set<Id>();
        for (SObject x:oldObjectsMap.values()){
            Account acc = (Account) x;
            MasterAccountIDs.add(acc.MasterRecordId);
        }

        set<String> DeletedAccountIDsString = new set<String>();
        for (Id x:DeletedAccountIDs) DeletedAccountIDsString.add('%'+x);

        //Get Marketing Consent Records of Deleted Accounts using External ID
        //list<Marketing_Consent__c> MarketingConsentList = [SELECT Active_Preference__c,Archived_Date__c,Archived_Questionnaire__c,Archived__c,Assumed_Opt_in__c,Booking_Passenger_Archived__c,Booking_Passenger__c,Brand_Text__c,Brand__c,Business_Unit_Text__c,CreatedById,CreatedDate,CurrencyIsoCode,Customer_Active__c,Customer_Archived__c,Customer_or_Prospect__c,Date_Entered__c,Do_Not_Archive_On_Save__c,External_ID__c,Hotel__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lead_Archived__c,Lead__c,Name,Opt_In__c,Questionnaire_Count__c,Questionnaire__c,RCH_Incorrect_MC__c,Reason__c,RecordTypeId,Request_Archived__c,Request_Count__c,Request__c,Selling_Company__c,Source__c,SystemModstamp,Temp_Brand_Text_Formula__c,Temp_Business_Unit_Text__c,Tour_Count__c,Tour_Gross_Total__c,Type__c,Validation_Correct_External_ID__c,Validation_Duplicate_Account_ID__c,Validation_Is_External_ID_Correct__c FROM Marketing_Consent__c WHERE Customer_or_Prospect__c IN :MasterAccountIDs AND External_ID__c LIKE :DeletedAccountIDsString];
        //--LastReferencedDate, LastViewedDate - not found on Request tests in CP2--
        list<Marketing_Consent__c> MarketingConsentList = [SELECT Active_Preference__c,Archived_Date__c,Archived_Questionnaire__c,Archived__c,Assumed_Opt_in__c,Booking_Passenger_Archived__c,Booking_Passenger__c,Brand_Text__c,Brand__c,Business_Unit_Text__c,CreatedById,CreatedDate,CurrencyIsoCode,Customer_Active__c,Customer_Archived__c,Customer_or_Prospect__c,Date_Entered__c,Do_Not_Archive_On_Save__c,External_ID__c,Hotel__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Lead_Archived__c,Lead__c,Name,Opt_In__c,Questionnaire_Count__c,Questionnaire__c,RCH_Incorrect_MC__c,Reason__c,RecordTypeId,Request_Archived__c,Request_Count__c,Request__c,Selling_Company__c,Source__c,SystemModstamp,Temp_Brand_Text_Formula__c,Temp_Business_Unit_Text__c,Tour_Count__c,Tour_Gross_Total__c,Type__c,Validation_Correct_External_ID__c,Validation_Duplicate_Account_ID__c,Validation_Is_External_ID_Correct__c FROM Marketing_Consent__c WHERE Customer_or_Prospect__c IN :MasterAccountIDs AND External_ID__c LIKE :DeletedAccountIDsString];

        //Update ExternalIDs
        for (Marketing_Consent__c x:MarketingConsentList){

            //Replace end of ExternalID with new Winning ID
            ExternalID = x.External_ID__C;
            HalfExternalID = ExternalID.split('#');
            ExternalID = HalfExternalID[0]+'#'+x.Customer_or_Prospect__c;
            x.External_ID__C=ExternalID;
        }

        //---Process as queueable job to avoid Account updates during merge operation---
        //Marketing_Consent_Handler_Class MarketingConsentHandler = new Marketing_Consent_Handler_Class(NULL); //What object string does this want?
        //MarketingConsentHandler.addPreference(MarketingConsentList);
        //MarketingConsentHandler.createPreferences();

        //delete MarketingConsentList;
        //------------------------------------------------------------------------------

        if(MarketingConsentList.size() > 0){
            System.enqueueJob(new Marketing_Consent_Delete(MarketingConsentList));
        }
    }
    // ------------------------------------------------------------------------------

    // ---------------------Reparent Account Manual sharing Rules--------------------
    public void Merge_Manual_Share(Map<Id, SObject> oldObjectsMap){
        //Get set of DeletedAccount IDs
        set<Id> DeletedAccountIDs = oldObjectsMap.keySet();
        list<AccountShare> AccountShareManuals = new list<AccountShare>();

        //Get each deleted AccountShare record that was asociated with the Losing Merged Account
        for (AccountShare x: [SELECT AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,OpportunityAccessLevel,RowCause,UserOrGroupId FROM AccountShare WHERE AccountId in :DeletedAccountIDs AND RowCause='Manual' ALL ROWS]){
            SObject sobj = oldObjectsMap.Get(x.AccountId);
            Account accobj = (Account)sobj;

            //Winning Merged Account in MasterRecordId field
            if (accobj.MasterRecordId != NULL){
                AccountShare tempAccshare = new AccountShare(
                    AccountAccessLevel = x.AccountAccessLevel,
                    AccountId = accobj.MasterRecordId,
                    CaseAccessLevel = x.CaseAccessLevel,
                    OpportunityAccessLevel= x.OpportunityAccessLevel,
                    UserOrGroupId = x.UserOrGroupId);

                AccountShareManuals.add(tempAccshare);
            }
        }

        if (AccountShareManuals.size()>0) insert AccountShareManuals;

    }
    // ------------------------------------------------------------------------------
    // *****************************************************************************************************************************************************************************************************************************************************************************************************************************************************

}