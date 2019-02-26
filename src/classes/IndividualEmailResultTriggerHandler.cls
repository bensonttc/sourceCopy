public with sharing class IndividualEmailResultTriggerHandler{
    public static void MCUnsubscribe(List<et4ae5__IndividualEmailResult__c> newList){
        
        Map<Id, Id> newMap = new Map<Id, Id>();
        Map<Id, Id> personContactIds = new Map<Id, Id>();
        Map<et4ae5__IndividualEmailResult__c, String> MCBusinessUnitIds = new Map<et4ae5__IndividualEmailResult__c, String>();
        Map<et4ae5__IndividualEmailResult__c, Id> BusinessUnitIds = new Map<et4ae5__IndividualEmailResult__c, Id>();
        Map<Id, String> insertErrorMessages = new Map<Id, String>();
        Map<Id, List<String>> insertErrorFields = new Map<Id, List<String>>();
        Map<Id, et4ae5__IndividualEmailResult__c> sendDefinitionIds = new Map<Id, et4ae5__IndividualEmailResult__c>();
        Set<String> externalIdSet = new Set<String>();
        Map<et4ae5__IndividualEmailResult__c, Id> customerIds = new Map<et4ae5__IndividualEmailResult__c, Id>();
        List<String> externalIds = new List<String>();
        List<Marketing_Consent__c> mcList = new List<Marketing_Consent__c>();
        List<String> noMCBusinessUnit = new List<String>();
        List<String> noBusinessUnit = new List<String>();
        List<Id> optOutAll = new List<Id>();
        
        //populate a map from the new list
        for(et4ae5__IndividualEmailResult__c individualEmailResult : newList){
            newMap.put(individualEmailResult.id, individualEmailResult.et4ae5__Contact__c);
        }
        
        //For all the Contacts associated with the individualEMailResults, find the 001 version of the ids
        for(Account personAccount : [select Id, personContactId from Account Where personContactId in :newMap.values()]){
            personContactIds.put(personAccount.personContactId, personAccount.Id);
        }
        
        
        //Check that all the Emails Sends have Customers. Any that don't, add the Id to a list of Ids with no Customer
        for(et4ae5__IndividualEmailResult__c individualEmail : newList){
            if(individualEmail.et4ae5__SendDefinition__c != Null){
                sendDefinitionIds.put(individualEmail.et4ae5__SendDefinition__c, individualEmail);
            //If there was no Email Send related to the Individual Email Result then add the Id to the noSendDefinition list
            }
            if(individualEmail.et4ae5__Contact__c != Null){
                customerIds.put(individualEmail, personContactIds.get(individualEmail.et4ae5__Contact__c));
                system.Debug('Individual Email is '+individualEmail);
                system.Debug('Individual Email Contact is '+personContactIds.get(individualEmail.et4ae5__Contact__c));
            }
        }
        
        //Perform a SOQL query on the Email Sends object
        for(et4ae5__SendDefinition__c emailSend : [SELECT Id, et4ae5__fBusiness_Unit__c, et4ae5__Business_Unit_saved__c FROM et4ae5__SendDefinition__c WHERE Id IN: sendDefinitionIds.keyset()]){
            //Look at the Email send and see if the Business Unit Saved field is populated. If it is add it to the MCBusinessUnit map
            if(emailSend.et4ae5__Business_Unit_saved__c != Null){
                MCBusinessUnitIds.put(sendDefinitionIds.get(emailSend.Id), emailSend.et4ae5__Business_Unit_saved__c);
            //If not, check if the Business Unit formula is filled in. If it is then add it to the MCBusinessUnit map instead
            } else if(emailSend.et4ae5__fBusiness_Unit__c != Null){
                MCBusinessUnitIds.put(sendDefinitionIds.get(emailSend.Id), emailSend.et4ae5__fBusiness_Unit__c);
            //If neither are filled in then add the Individual Email Id to the noMCBusinessUnit list
            } else{
                //noMCBusinessUnit.add(sendDefinitionIds.get(emailSend.Id));
                noMCBusinessUnit.add('Contact Id: '+sendDefinitionIds.get(emailSend.Id).et4ae5__Contact__c+' Send Definition Id: '+emailSend.Id);
            }
        }
        
        //Create a list of Custom Settings from Business_Units__c. This grabs all data in the Custom Setting
        List<Business_Units__c> businessUnits = Business_Units__c.getAll().Values();
        //Create a Map that will be used to grab certain values from the Custom Setting record based on a field that is not the key (name field)
        Map<String, String> MCBusinessUnitToBusinessUnitId = new Map<String, String>();
        Map<String, String> MCBusinessUnitToType = new Map<String, String>();
        
        //This for loop iterates through the businessUnits List and for each value you add the Type, Marketing Consent Business Unit and the Business Unit Id
        for(Business_Units__c BusinessUnit : BusinessUnits){
            MCBusinessUnitToBusinessUnitId.put(BusinessUnit.Marketing_Cloud_Business_Unit__c, BusinessUnit.Business_Unit_Id__c);
            MCBusinessUnitToType.put(BusinessUnit.Marketing_Cloud_Business_Unit__c, BusinessUnit.Type__c);
        }
        
        //Loop through the MCBusinessUnit Id map to create an External Id from the Business Unit Id
        for(et4ae5__IndividualEmailResult__c individualEmail : MCBusinessUnitIds.KeySet()){
            //If the current associated Type is Brand then add the Individual Email Id to the optOutAll list
            if(MCBusinessUnitToType.get(MCBusinessUnitIds.get(individualEmail)) == 'Brand'){
                optOutAll.add(personContactIds.get(individualEmail.et4ae5__Contact__c));
            //Otherwise you create a External Id from the Bsuiness Unit Id and Customer Id and add it to the externalIdSet
            } else if(MCBusinessUnitToType.get(MCBusinessUnitIds.get(individualEmail)) == 'Business Unit'){
                externalIdSet.add(MCBusinessUnitToBusinessUnitId.get(MCBusinessUnitIds.get(individualEmail))+'#'+customerIds.get(individualEmail));
            } else if(MCBusinessUnitToType.get(MCBusinessUnitIds.get(individualEmail)) == null){
                //noBusinessUnit.add(individualEmail);
                noBusinessUnit.add('Contact Id: '+individualEmail.et4ae5__Contact__c+' Send Definition Id: '+individualEmail.et4ae5__SendDefinition__c);
            }
        }
        
        //Add the externalIdSet to the externalIds list (which we know is unique)
        externalIds.addAll(externalIdSet);
        
        //If there are any records in the optOutAll list, create a SOQL query to grab the Marketing Consent records
        //associated to the Contact where they are opted in and set them to opt out and add them to the mcList
        if(optOutAll.size() > 0){
            for(Marketing_Consent__c mc : [SELECT Id, External_ID__c FROM Marketing_Consent__c WHERE Customer_or_Prospect__c IN: optOutAll and
                                        RecordTypeId = :Schema.SObjectType.Marketing_Consent__c.getRecordTypeInfosByName().get('Active Marketing Consent').getRecordTypeId() and
                                        Opt_In__c = TRUE]){
                mc.Opt_In__c = FALSE;
                mc.Assumed_Opt_In__c = FALSE;
                mcList.add(mc);
            }
        }
        
        //Iterate though the list of External Ids and create new Marketing Consent records with them opted out and add the Marketing consents to the mcList List
        for(String externalId : externalIds){
            System.debug('This External Id is '+externalId);
            Marketing_Consent__c mc = new Marketing_Consent__c(External_Id__c = externalId, Opt_In__c = FALSE, Assumed_Opt_In__c = FALSE);
            mcList.add(mc);
        }
        
        //update the Marketing Consent records
        for(Database.upsertResult sr : database.upsert(mcList, Marketing_Consent__c.External_Id__c, false)){
            //If a success happens then add the result to the debug log
            if(sr.isSuccess()){
                System.debug('Successfully updated the Marketing Consent '+ sr.getId());
            //If a failure happens, put the fail message and fields into the debug log
            //and add the fields and messages to two maps
            } else{
                for(Database.Error err : sr.getErrors()) {
                    system.debug('LOG: The following error has occurred.');                    
                    system.debug('LOG: '+ err.getStatusCode() + ': ' + err.getMessage());
                    system.debug('LOG: MC fields that affected this error: ' + err.getFields());
                    insertErrorMessages.put(sr.getId(), err.getMessage());
                    insertErrorFields.put(sr.getId(), err.getFields());
                }
            }
        }
        
        //Check if any of the error lists are populated. If they are then create an email to send to SalesforceTeam email box
        if(noMCBusinessUnit.size() > 0 || noBusinessUnit.size() > 0 || insertErrorMessages.keySet().Size() > 0 || insertErrorFields.keySet().Size() > 0){
            /*String custIds;
            for(Id cust : noContact){
                system.debug('custIds is currently equals to '+custIds);
                custIds = custIds+cust+' ';
                system.debug('custIds is currently equals to '+custIds);
            }*/
            //create an email to send to salesforceTeam
            //First, reserve email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending email after the current transaction is committed.
            Messaging.reserveSingleEmailCapacity(1);
            //Now create a new single email message object that will send out a single email to the address
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {'mark.mulholland@ttc.com'};
            //Assign the addresses for the To list to the mail object.
            mail.setToAddresses(toAddresses);
            //Specify the address used when the recipients reply to the email. 
            mail.setReplyTo('mark.mulholland@ttc.com');
            // Specify the name used as the display name.
            mail.setSenderDisplayName('MC Writeback Process');
            // Specify the subject line for your email address.
            mail.setSubject('There were errors with the MC Writeback Process');
            //Set the html body of the email
            mail.setHtmlBody('There was an error with the processing of the MC Writeback job.<p>'+
            '<b>Number of Marketing Consent Business Unit issues: '+noMCBusinessUnit.size()+'</b><br>'+
            'The Contact and Email Send Ids where there were Marketing Consent Business Unit errors are: '+noMCBusinessUnit+'<p>'+
            '<b>Number of Business Unit issues: '+noBusinessUnit.size()+'</b><br>'+
            'The Contact and Email Send Ids where there were Business Unit errors are: '+noBusinessUnit+'<p>'+
            '<b>Number of errors updating the Marketing Consent records: '+insertErrorMessages.keySet().Size()+'</b><br>'+
            'The error messages are: '+insertErrorMessages+'<br>'+
            'The error fields are: '+insertErrorFields);
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('The errors returned are: No MC Business Unit: '+noMCBusinessUnit+' no Business Unit: '+noBusinessUnit+' Insert Errors Messages: '+insertErrorMessages+' and insert error fields: '+insertErrorFields);
        }
    }
}