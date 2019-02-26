//To Do:

// 1) check all required fields are filled in
// 2) need to add single row error handeling
// 3) Need to add a field to the Master bean that controls the Record Type of the Account
// 4) If the MB has an Account then that Record type should be used
// 5) change to database upsert so that successful rows will still be saved



//Fixed:
// 1) if the Account is deleted then the trigger will create a new one - fix this
// 2) if the Master Bean is created from an Account then need to stop trigger from firing
// 3) stop the MB from getting created after a conversion. Then update the Account so that the Bean is created and attached to the same MB
// 4) connect Master bean to new Account
// 5) stop the Update of the Master Bean Account if it is a Business User
// 6) currently hard coding the Record Types - needs to change
// 7) Need extra Person Account fields on the MB to get into Person Account
// 8) in a batch - one Account getting created and all MB are getting assigned to that Account

public with sharing class MDM_Person_Account_Conversion_Class {
	private list<MDM_Custom_Synchronisation_settings__c> PersonSynchList;
	private list<MDM_Custom_Synchronisation_settings__c> BusinessSynchList;
	private set<string> AccountQueryFields;
	private map<id, RecordType> RecordTypes;
	private map<string, ID> RecordTypeNames;
	private MDM_Debug_Logs_Class Dlog;
	private id DefaultPersonRT;
	private id DefaultBusinessRT;
	private list<Account> AccToUpsert;
	private list<DSE__DS_Bean__c> BeansToUpsert;
	private list<ObjectLink> ObjectToUpsert;
    public static set<id> MBListThatCausedEnrichment = new set<id>();

	public MDM_Person_Account_Conversion_Class(MDM_Debug_Logs_Class Dl) {
		Dlog = Dl;
		Dlog.BlankLog('Enter MDM_Person_Account_Conversion_Class');
		//Get the synchronisation settings for the Person Accounts
		PersonSynchList = new list<MDM_Custom_Synchronisation_settings__c>();
		BusinessSynchList = new list<MDM_Custom_Synchronisation_settings__c>();
		MDM_Helper_Class MasterBeanFields = new MDM_Helper_Class('DSE__DS_Master_Bean__c');
		MDM_Helper_Class AccountFields = new MDM_Helper_Class('Account');

		AccountQueryFields = new set<string>();


		//Loop round Synch settings and check fields exist
		for(MDM_Custom_Synchronisation_settings__c sync : MDM_Custom_Synchronisation_settings__c.getall().values()){
			if(sync.Object__c != null){
				if(AccountFields.WritableFieldsInObject.contains(sync.Object_Field__c.toUpperCase())){	//is the target field writable
					if(MasterBeanFields.AllFieldsInObject.contains(sync.Bean_Field__c.toUpperCase())){
						if(sync.Object__c == 'PersonAccount'){
							PersonSynchList.add(sync);
							AccountQueryFields.add(sync.Object_Field__c.toUpperCase());
						}
						else if(sync.Object__c == 'BusinessAccount'){
							BusinessSynchList.add(sync);
							AccountQueryFields.add(sync.Object_Field__c.toUpperCase());
						}
					}
					else{
		            	Dlog.BlankLog('Following source field does not exist: '+ sync.Bean_Field__c);
		            	Dlog.LogError();
	            		Dlog.Comit();
					}
				}
				else{
		            Dlog.BlankLog('Following target field does not exist or is not writable: '+ sync.Object_Field__c);
		            Dlog.LogError();
	            	Dlog.Comit();
				}
			}
		}

		//Get Person Account record types
		RecordTypes = new map<id, RecordType>([SELECT DeveloperName, name, Id, IsPersonType FROM RecordType WHERE SobjectType = 'Account']);
		RecordTypeNames = new map<string, ID>();

		//Set default Business and Person Accounts record types
		for(ID RTid: RecordTypes.keySet()){
			RecordType RT = RecordTypes.get(RTid);

			if(RT.DeveloperName == 'Customer'){
				DefaultPersonRT = RTid;
			}
			else if(RT.DeveloperName == 'Business_Account'){
				DefaultBusinessRT = RTid;
			}

			RecordTypeNames.put(RT.Name, RTid);
		}

		//Validate the Bean Fields

		//Validate the Account Fields - including checking that they are writable + check the field types

	}

	public class ObjectLink{
        public Account Acc {get; set;}
		public DSE__DS_Master_Bean__c MB {get; set;}
		public DSE__DS_Bean__c Bean {get; set;}

		public ObjectLink(Account Ac, DSE__DS_Master_Bean__c MBean){
			Acc = Ac;
			MB = MBean;
			Bean = new DSE__DS_Bean__c();
		}
	}

	//1) Build Account query from Fields in Synch settings
	//2) Query all exsisting Accounts
	//3) Compare Master Bean fields against Account fields
		//a) If there is a change in any fields then add to upsert list
		//b) if there is no Account then add to upsert list with fields
		//c) no change - do not add to the list
	//4) Turn off the Cloud MDM Account Trigger
	//5) Upsert the Account list
	//6) Create Beans from Account using the synch settings
	//7) Set Consolidation flag of Bean to True as it has already been consolidated 
	//8) Upsert the Beans 
	// If this works then the triggers will end here. There will be no recursion of triggers.
	// Before Master Bean Trigger + Before Account Trigger + After Account Trigger + After MB Trigger + Bean Trigger - END


	//Method takes field list and creates a query
	public static string CreateAccountQuery(string Obj, string IDinListName, set<string> fieldList){
		if(!fieldList.contains('ID')) fieldList.add('ID');
		if(!fieldList.contains('RECORDTYPEID')) fieldList.add('RECORDTYPEID');

		string query = 'SELECT ';
		for(string field:fieldList){
			query += field + ', ';
		}
		query = query.removeEnd(', ');
		query += ' FROM ' + Obj + ' WHERE ID in :' + IDinListName;
		return query;
	}
	

	public void CreateUpsertAccountList(list<DSE__DS_Master_Bean__c> MasterBeans, map<id, DSE__DS_Master_Bean__c> oldMap, map<id, Account> Accounts){
		ObjectToUpsert = new list<ObjectLink>();
		AccToUpsert = new list<Account>();

		for(DSE__DS_Master_Bean__c MB : MasterBeans){

			//Check if the Account field has just been cleared
			if(oldMap != null){
				DSE__DS_Master_Bean__c oldMB = oldMap.get(MB.ID);
				if(MB.DSE__DS_Account__c == null && oldMB.DSE__DS_Account__c != null){
					Dlog.BlankLog('Account field deleted - do not include');
					continue;
				}
			}

			//Get the Associated Account (if it existis)
			Account ExistingAccount = Accounts.get(MB.DSE__DS_Account__c);
			Account AccountToUpsert = new Account();
                
			//Check if a Account Exists
			if(ExistingAccount == null){
				Dlog.BlankLog('No Existing Account found for MB '+ MB.ID);
				ExistingAccount = new Account();
			}
            else{
            	Dlog.BlankLog('Existing Account found for MB '+ MB.ID + ' = '+ ExistingAccount.ID);
                AccountToUpsert.ID = ExistingAccount.ID;	//Set ID if it exists
            }

			//If RecordType doesn't exist then need to get record Type off the Master Bean
			if(ExistingAccount.RecordTypeID == null && RecordTypeNames.containsKey(MB.DSE__DS_Record_Type_Name__c)){
				ExistingAccount.RecordTypeID = RecordTypeNames.get(MB.DSE__DS_Record_Type_Name__c);
				Dlog.BlankLog('Found Record Type from MB = '+ MB.DSE__DS_Record_Type_Name__c + ', ID = '+ ExistingAccount.RecordTypeID );
			}
			if(ExistingAccount.RecordTypeID == null){
				Dlog.BlankLog('No Record Type found on MB - do not include');
				continue;
			}
			//Set RecordTypeID
			AccountToUpsert.RecordTypeID = ExistingAccount.RecordTypeID;	//Set recordTYpeID
            
			//Need to decide if Business Account or Person Account
			list<MDM_Custom_Synchronisation_settings__c> TheSynchList;
			if(RecordTypes.get(ExistingAccount.RecordTypeID).IsPersonType){
				Dlog.BlankLog('Setting Person Account Synchronisation settings');
				TheSynchList = PersonSynchList;
			}
			else{
				Dlog.BlankLog('Setting Business Account Synchronisation settings');
				TheSynchList = BusinessSynchList;
			}


			//Loop round the fields in the sync settings and check for changes
			boolean ChangeDetected = false;
			for(MDM_Custom_Synchronisation_settings__c synch : TheSynchList){
                object MBValue = MB.get(synch.Bean_Field__c);
				object AccValue = ExistingAccount.get(synch.Object_Field__c);
                
                
                Dlog.Quicklog('Account Field: '+ synch.Object_Field__c);
                Dlog.Quicklog('Account Field Value: '+ AccValue);
                
                Dlog.Quicklog('Bean Field: '+ synch.Bean_Field__c);
                Dlog.Quicklog('Bean Field Value: '+ MBValue);
				
				//Convert MBValue into the type of the Account
				MBValue = MDM_Helper_Class.setValue(synch.Bean_Field__c, MBValue, synch.Object_Field__c, AccValue);
				
				//if there is a difference
				if(MBValue != AccValue){
					
					//Set the Account to the MB Value
					AccountToUpsert.put(synch.Object_Field__c, MBValue);

					//AccountToUpsert.put(synch.Object_Field__c, MBValue);	//Set the new Account field instead of existing one - avoids setting incorrect fields e.g. person Account fields
					ChangeDetected = true;
					Dlog.Quicklog('Change Detected');
				}
			}

			//Add to upsert list if change detected
			if(ChangeDetected){
				Dlog.BlankLog('Adding MB to the enrich list = '+ MB.ID);

                MBListThatCausedEnrichment.add(MB.ID);		//Add the MB to the list
				AccountToUpsert.DSE__DS_Synchronize__c = true;
				AccToUpsert.add(AccountToUpsert);
				ObjectToUpsert.add(new ObjectLink(AccountToUpsert, MB));
			} 
		}
	}



	public void UpsertAccounts(){

		Dlog.BlankLog('Size of before update Account map = '+AccToUpsert.size());

		if(AccToUpsert.size() >0){
			// Iterate through each returned result
			MDM_Recursion_Handler.TurnOffCMDMAccountTrigger = true;
			integer count = 0;
			for(Database.UpsertResult sr : database.upsert (AccToUpsert, false)) {
			    if(sr.isSuccess()) {
			        //Operation was successful, so get the ID of the record that was processed
			        AccToUpsert[count].id = sr.getId();							//Set Account ID on Acc list
			        ObjectToUpsert[count].MB.DSE__DS_Account__c = sr.getId();	//set the Account field on the MB
			        ObjectToUpsert[count].MB.Time_of_Last_Account_Enrichment__c = datetime.now();
			        Dlog.BlankLog('Successfully inserted account. Account ID: ' + sr.getId());
			    }
			    else{
			        //Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            Dlog.Quicklog('The following error has occurred.');                    
			            Dlog.Quicklog(err.getStatusCode() + ': ' + err.getMessage());
			            Dlog.BlankLog('Account fields that affected this error: ' + err.getFields());
			        }
			    }
			    count ++;
			}
			MDM_Recursion_Handler.TurnOffCMDMAccountTrigger = false;
		}
	}



	public void UpsertBeans(list<DSE__DS_Master_Bean__c> newMBs){
		BeansToUpsert = new list<DSE__DS_Bean__c>();
		//MDM_Recursion_Handler.TurnOffCMDMAccountTrigger = true;

		Dlog.BlankLog('Number of MasterBeans = '+ newMBs.size());
		Dlog.BlankLog('MasterBeans = '+ newMBs);

		//Get the Account Synch list
		DSE__DS_SF_Synchronization_Settings__c MDMSynch = DSE__DS_SF_Synchronization_Settings__c.getValues('Account');
		for(DSE__DS_Master_Bean__c MB: newMBs){

			//get the different objects
			DSE__DS_Bean__c Bean = new DSE__DS_Bean__c();
			Dlog.BlankLog('MB = '+MB);
			if(MB.DSE__DS_Account__c != null && MB.ID != null){
				//Set the appropriate fields
				Bean.DSE__DS_Company__c = MB.DSE__DS_Company__c;
				Bean.DSE__DS_Billing_City__c = MB.DSE__DS_Billing_City__c;
				Bean.DSE__DS_Billing_Country__c = MB.DSE__DS_Billing_Country__c;
				Bean.DSE__DS_Custom_Field_1__c = MB.DSE__DS_Custom_Field_1__c;
				Bean.DSE__DS_Custom_Field_10__c = MB.DSE__DS_Custom_Field_10__c;
				Bean.DSE__DS_Custom_Field_2__c = MB.DSE__DS_Custom_Field_2__c;
				Bean.DSE__DS_Custom_Field_3__c = MB.DSE__DS_Custom_Field_3__c;
				Bean.DSE__DS_Custom_Field_4__c = MB.DSE__DS_Custom_Field_4__c;
				Bean.DSE__DS_Custom_Field_5__c = MB.DSE__DS_Custom_Field_5__c;
				Bean.DSE__DS_Custom_Field_6__c = MB.DSE__DS_Custom_Field_6__c;
				Bean.DSE__DS_Custom_Field_7__c = MB.DSE__DS_Custom_Field_7__c;
				Bean.DSE__DS_Custom_Field_8__c = MB.DSE__DS_Custom_Field_8__c;
				Bean.DSE__DS_Custom_Field_9__c = MB.DSE__DS_Custom_Field_9__c;
				Bean.DSE__DS_Phone__c = MB.DSE__DS_Phone__c;
				Bean.DSE__DS_Billing_Postal_Code__c = MB.DSE__DS_Billing_Postal_Code__c;
				Bean.DSE__DS_Billing_State__c = MB.DSE__DS_Billing_State__c;
				Bean.DSE__DS_Billing_Street__c = MB.DSE__DS_Billing_Street__c;
				Bean.DSE__DS_Website__c = MB.DSE__DS_Website__c;

				id RTID = RecordTypeNames.get(MB.DSE__DS_Record_Type_Name__c);
				boolean IsPersType;
				RecordType RT;
				String SourceName;

				if(RTID != null){
					RT = RecordTypes.get(RTID);
					if(RT != null){
						IsPersType = RT.IsPersonType;
					}
				}
				else{
					//No record type so no Account or Bean
					continue;
				}
				
				if(IsPersType != null){
					if(IsPersType){
						SourceName = 'PersonAccount';
						Bean.DSE__DS_Last_Name__c = MB.DSE__DS_Custom_Field_4__c;
						Bean.DSE__DS_First_Name__c = MB.DSE__DS_Custom_Field_3__c;
						Bean.DSE__DS_Email__c = MB.DSE__DS_Custom_Field_2__c;
					}
					else{
						SourceName = 'Account';
					}
				}
				else{
					SourceName = 'Account';
				}

				Bean.DSE__DS_Consolidated__c = true;
				Bean.DSE__DS_Account__c = MB.DSE__DS_Account__c;
				Bean.DSE__DS_Source__c = SourceName;
				Bean.DSE__DS_Source_No__c = MB.DSE__DS_Account__c;
				Bean.DSE__DS_External_ID__c = SourceName + '#' + MB.DSE__DS_Account__c;
				Bean.DSE__DS_Master_Bean__c = MB.ID; 

				//Add to upsert List
				BeansToUpsert.add(Bean);
			}
		}

		//Upsert
		Dlog.BlankLog('BeansToUpsert Size = '+BeansToUpsert.size());
		Dlog.BlankLog('BeansToUpsert = '+BeansToUpsert);

		if(BeansToUpsert.size() > 0){
			Schema.SObjectField field = DSE__DS_Bean__c.Fields.DSE__DS_External_ID__c;
			for(Database.UpsertResult sr : database.upsert(BeansToUpsert,field, false)) {
			    if(sr.isSuccess()) {
			        //Operation was successful, so get the ID of the record that was processed
			        Dlog.BlankLog('Successfully inserted Bean. Bean ID: ' + sr.getId());
			    }
			    else{
			        //Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            Dlog.Quicklog('The following error has occurred.');                    
			            Dlog.Quicklog(err.getStatusCode() + ': ' + err.getMessage());
			            Dlog.BlankLog('Bean fields that affected this error: ' + err.getFields());
			        }
			    }
			}
		}
		
	}


	public void AccountEnrichment (map<id, DSE__DS_Master_Bean__c> oldMap, list<DSE__DS_Master_Bean__c> newMBs, boolean isInsert){
		
		try{
			//Check if Settings are available
			MDM_Account_Creation_Setting__c Creation = MDM_Account_Creation_Setting__c.getValues('Active');
			if(Creation == null){
		        Creation = new MDM_Account_Creation_Setting__c(Active__c = false);
		    }
		    if(!Creation.Active__c) return;
            
		    //Get a list of Account ID + MB that should be processed
		    list<DSE__DS_Master_Bean__c> newMBsToProcess = new list<DSE__DS_Master_Bean__c>();
		    set<id> AccIDs = new set<id>();
		    for(DSE__DS_Master_Bean__c MB : newMBs){
		    	if(MB.Create_Update_Account__c){
		    		MB.Create_Update_Account__c = false;
		    		MB.Time_of_Last_Update_Create_Checkbox_set__c = datetime.now();
		    		newMBsToProcess.add(MB);
		    		if(MB.DSE__DS_Account__c != null){
			    		AccIDs.add(MB.DSE__DS_Account__c);
			    	}
		    	}
		    }

		    //If there are no MB that have been marked to create Accounts then end processing here
		    if(newMBsToProcess.size() == 0) return;

		    //If there are MB to create Accounts then turn off the MB trigger to avoid recursion
		    MDM_Recursion_Handler.TurnOffBeforeMB = true;


		    //Query Accounts
		    map<id, Account> AccountMap = new map<id, Account>();
		    try{
		    	string query = CreateAccountQuery('Account', 'AccIDs', AccountQueryFields);
		    	for(sObject sobj: database.query(query)){
		    		Account Acc = (Account) sobj;
		    		AccountMap.put(Acc.ID, Acc);
		    	}
		    }
		    catch (exception e){

		    }
		    
		    //Compare Account values with the Master Bean values to check for differences + build upsert list
		    CreateUpsertAccountList(newMBsToProcess, oldMap, AccountMap);

		    //Upsert the Accounts + get results
		    UpsertAccounts();
		}
		catch(exception e){
			Dlog.Quicklog('Error when building the table of results = '+ e.getMessage());
            Dlog.Quicklog('Line Number = '+ string.valueof(e.getLineNumber()) );
            Dlog.Quicklog('Error Type = '+ string.valueof(e.getTypeName()) );
            Dlog.Quicklog('Stack Track = '+ e.getStackTracestring() ); 
            Dlog.LogError();
            Dlog.Comit();
		}
	}


	//After update method on MB withh Create the Account/Person Account Bean
	public void AfterMBUpdate(list<DSE__DS_Master_Bean__c> newMBs){
		Dlog.Quicklog('Master Bean - After Update');
        try{
        	Dlog.Quicklog('Master Bean enrich size = '+ MBListThatCausedEnrichment.size());
            list<DSE__DS_Master_Bean__c> MBsThatWereEnriched = new list<DSE__DS_Master_Bean__c>();
            for(DSE__DS_Master_Bean__c MB : newMBs){
                if(MBListThatCausedEnrichment.contains(MB.ID) && MB.DSE__DS_Account__c != null){
                    system.debug('MB ID caused enrichment - '+ MB.ID);
                    MBsThatWereEnriched.add(MB);
                }
            }
            if(MBsThatWereEnriched.size() > 0){
            	//The MB has been marked to create/Update Account. Turn off trigger to avoid recursion
                MDM_Recursion_Handler.TurnOffAfterMB = true;
            	UpsertBeans(MBsThatWereEnriched);
            }
            
        }
        catch(exception e){
			Dlog.Quicklog('Error when building the table of results = '+ e.getMessage());
            Dlog.Quicklog('Line Number = '+ string.valueof(e.getLineNumber()) );
            Dlog.Quicklog('Error Type = '+ string.valueof(e.getTypeName()) );
            Dlog.Quicklog('Stack Track = '+ e.getStackTracestring() ); 
            Dlog.LogError();
            Dlog.Comit();
		}
		
	}


	public static void Before_Update_or_insert(list<DSE__DS_Master_Bean__c> newList, boolean isInsert){
		for (DSE__DS_Master_Bean__c MBean: newList){
			if(isInsert){
				MBean.Create_Update_Account__c = false;
			}
			MBean.DSE__DS_Custom_Field_10__c = MDM_Helper_Class.sanitiseAndRemoveCommonWordsName(MBean.DSE__DS_Custom_Field_10__c);
			MBean.DSE__DS_Segment__c = MDM_Helper_Class.RemoveCommonWords(MBean.DSE__DS_Segment__c);

			//*** START Build CP Segment ***
	        //Build the CP Segment for Business Accounts
	        string Sanitised = '';
	        if(MBean.DSE__DS_Custom_Field_5__c == 'false' || MBean.DSE__DS_Custom_Field_5__c == 'Account' || MBean.DSE__DS_Custom_Field_5__c == 'Agency' || MBean.DSE__DS_Custom_Field_5__c == 'Contact'){
	        	if(MBean.DSE__DS_Billing_Country__c != null && MBean.DSE__DS_Company__c != null && MBean.DSE__DS_Billing_Street__c != null && MBean.DSE__DS_Billing_City__c != null){
	        		Sanitised = MDM_Helper_Class.sanitiseName(MDM_Helper_Class.removeNull(MBean.DSE__DS_Custom_Field_5__c) + MDM_Helper_Class.removeNull(MBean.DSE__DS_Billing_Country__c) + MDM_Helper_Class.removeNull(MBean.DSE__DS_Company__c) + MDM_Helper_Class.removeNull(MBean.DSE__DS_Billing_Street__c) + MDM_Helper_Class.removeNull(MBean.DSE__DS_Billing_City__c) + MDM_Helper_Class.removeNull(MBean.DSE__DS_Custom_Field_6__c));
	        	}
	        }
	        //Build the CP Segment for Person Accounts
	        else if(MBean.DSE__DS_Custom_Field_5__c == 'true'){
	        	if(MBean.DSE__DS_Custom_Field_3__c != null && MBean.DSE__DS_Custom_Field_4__c != null && MBean.DSE__DS_Custom_Field_2__c != null){
	        		string firstName = MDM_Helper_Class.removeNull(MBean.DSE__DS_Custom_Field_3__c);
	        		if(firstName.length() > 3) firstName = firstName.substring(0,3);
	        		Sanitised = MDM_Helper_Class.sanitiseName(MDM_Helper_Class.removeNull(MBean.DSE__DS_Custom_Field_5__c) + firstName + MDM_Helper_Class.removeNull(MBean.DSE__DS_Custom_Field_4__c) + MDM_Helper_Class.removeNull(MBean.DSE__DS_Custom_Field_2__c));
	        	}
	        }

	        //Truncate to 255 and set field on MBean
	        if(Sanitised.length() > 255){
        		Sanitised = Sanitised.substring(0,255);
        	}

        	MBean.CP_Segment__c = Sanitised;
        	//*** END Build CP Segment ***
		}
	}
	

}