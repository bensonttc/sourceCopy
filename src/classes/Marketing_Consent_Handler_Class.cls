//Marketing Consent Process:
	//1) Request, Booking Pax or Questionnair comes into SF
	//2) They are connected to a Customer
	//3) Check for MC with same Selling Company and Customer
	//4) If none exists then create a new MC - do not need to do anything else
	//5) If a MC already exists then need to look at logic:
		//Opting out always wins
		//currently only Requests have opt out
		//currently booking passengers dont have an opt out so they are assumed opt in. Meaning requests will trump Pax
		//if there are two records with an actual opt-in field then the latest date wins - compare dates
		//any overwritten preferences will be archived in a 'Preference history object' - which will probably be a record type
		//no need to archive preferences created by assuming opt in - e.g. from pax with no opt in field


//Additional Step needed:
//When the Questionnaire/Request/Pax comes in we need to link them back to the Active MC
//To Do:
//1) Change the object triggers so they run on Before Update and Insert (so we can set the lookup field)
//2) Marketing Consent handler needs to return the ID of the ACTIVE MC record.
//		Probably will return an ID to ID map that can be used by the object trigger



public with sharing class Marketing_Consent_Handler_Class {
	private string ObjectType;
	private map<string, list<MarketingConsent>> prefMap;
	private map<string, Marketing_Consent__c> prefToUpsert;
	private map<string, Marketing_Consent__c> prefToUpsert_Archived;
	private map<string, ID> MCExtToActiveID;
	private map<string, Marketing_Consent__c> ExistingPrefs;	//External ID to Existing MC
	public static boolean ChangeMadeByTrigger = false;
	public static ID ActivePrefRT;

	public static map<string, ID> MCRecordTypeMap{
		get{
			if(MCRecordTypeMap == null){
				MCRecordTypeMap = new map<string, ID>();
				for(RecordType RT: [SELECT DeveloperName, ID FROM RecordType WHERE SobjectType = 'Marketing_Consent__c']){
					MCRecordTypeMap.put(RT.DeveloperName, RT.ID);
				}
			}
			return MCRecordTypeMap;
		}
		set;
	}

	//************
	//*** Init ***
	//************
	public Marketing_Consent_Handler_Class(string ObjTy) {
		ObjectType = ObjTy;
		prefMap = new map<string, list<MarketingConsent>>();
		prefToUpsert = new map<string, Marketing_Consent__c>();
		prefToUpsert_Archived = new map<string, Marketing_Consent__c>();
		MCExtToActiveID = new map<string, ID>();
		ExistingPrefs = new map<string, Marketing_Consent__c>();	//External ID to Existing MC
	}

	//****************************************
	//*** Add in Marketing Consent to list ***
	//****************************************

	public void addPreference(list<Marketing_Consent__c> MCList){
		for(Marketing_Consent__c MC: MCList){
			addPreference(MC, null);
		}
	}

	public void addPreference(Marketing_Consent__c newPref, ID sourceID){
		if(newPref.Selling_Company__c != null && newPref.Customer_or_Prospect__c != null){
			if(newPref.External_ID__c == null){
				newPref.External_ID__c = newPref.Selling_Company__c + '#' + newPref.Customer_or_Prospect__c;
			}
			newPref.Customer_Active__c = newPref.Customer_or_Prospect__c;
			newPref.RecordTypeID = MCRecordTypeMap.get('ActivePreference');
			newPref.Do_Not_Archive_On_Save__c = true;

			system.debug('Adding Preference: '+newPref);
			MarketingConsent MC = new MarketingConsent(sourceID, newPref);

			if(prefMap.containsKey(newPref.External_ID__c)){
				//addToMap(newPref, false);	//need to check why this is here!!!!!
				if(newPref.External_ID__c != null){
					prefMap.get(newPref.External_ID__c).add(MC);
				}
			}
			else{
				list<MarketingConsent> newPrefList = new list<MarketingConsent>();
				newPrefList.add(MC);
				if(newPref.External_ID__c != null){
					prefMap.put(newPref.External_ID__c, newPrefList);
				}
			}
		}
	}

	//*******************************************************
	//*** Create any new Preferences and Archive old ones ***
	//*******************************************************
	//*Method will check all new Preferences created from source objects and decide which records update and archive
	public map<string, id> createPreferences(){
		system.debug('START Creating Preference Log.');

		//Find all Existing MC
		for(Marketing_Consent__c Pref:[SELECT Archived__c,Booking_Passenger_Archived__c,Booking_Passenger__c,Brand__c,Customer_or_Prospect__c,Date_Entered__c,External_ID__c,Opt_In__c,Request_Archived__c,Selling_Company__c,Source__c,Type__c, Request__c,Archived_Questionnaire__c, Questionnaire__c,Assumed_Opt_in__c, lastModifiedDate FROM Marketing_Consent__c where External_ID__c in :prefMap.keySet()]){
			ExistingPrefs.put(Pref.External_ID__c, Pref);
		}

		system.debug('LOG: Number of existing Preferences found = '+ExistingPrefs.size());
		system.debug('LOG: Existing External IDs = '+ExistingPrefs.KeySet());

		//Compare ne MC to Existing and decide which to archive
		ComparingToExistingMC();


		//Upsert the Preferences
		if(prefToUpsert.size() > 0){
			system.debug('LOG: Upsert Map: '+ prefToUpsert);
			for(string ExtID: prefToUpsert.keySet()){
				Marketing_Consent__c MC = prefToUpsert.get(ExtID);
				MC.Do_Not_Archive_On_Save__c = true;
				system.debug('LOG ExtID = ' + ExtID);
				system.debug('LOG MC = ' + MC);
			}

			//Upsert the MC
			//upsert prefToUpsert.values() External_ID__c;
			Schema.SObjectField field = Marketing_Consent__c.Fields.External_ID__c;
			integer count = 0;
			list<Marketing_Consent__c> MCUpsert = prefToUpsert.values();
			for(Database.UpsertResult sr : database.upsert(MCUpsert,field, false)) {
			    if(sr.isSuccess()) {
			        //Operation was successful, so get the ID of the record that was processed
			        system.debug('LOG: successfully upserted MC ID: ' + sr.getId());
			        MCExtToActiveID.put(MCUpsert[count].External_ID__c, sr.getId() );
			    }
			    else{
			        //Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            system.debug('LOG: The following error has occurred.');                    
			            system.debug('LOG: '+ err.getStatusCode() + ': ' + err.getMessage());
			            system.debug('LOG: MC fields that affected this error: ' + err.getFields());
			        }
			    }
			    count ++;
			}

			//Upsert Archived ones in a queue batch
			UpsertArchived();
			return MCExtToActiveID;
		}

		//Upsert Archived ones in queue batch
		UpsertArchived();
		return MCExtToActiveID;
	}


	//*****************************************
	//*** Comparing Existing MC to new ones ***
	//*****************************************
	public void ComparingToExistingMC(){
		//Compare Existing MC with new MC
		for(string ExtID : prefMap.keySet()){
			system.debug('LOG: First Preference External ID = '+ ExtID);
			Marketing_Consent__c MasterPref;

			//*MC already exists
			if(ExistingPrefs.containsKey(ExtID)){
				system.debug('LOG: A preference already exists with the External ID = '+ ExtID);
				list<MarketingConsent> listOfNew = prefMap.get(ExtID);	//List of the new MC
				MasterPref = ExistingPrefs.get(ExtID);					//Get existing MC
				
				//Loop round and decide on winner
				for(MarketingConsent Pref: listOfNew){
					system.debug('LOG: Compare the new Preference with the existing one:');
					MasterPref = comparePreferences(MasterPref, Pref.MC);
				}

			}
			//*MC does not exist
			else{
				system.debug('LOG: NO preference found with External ID = '+ ExtID);
				list<MarketingConsent> listOfNew = prefMap.get(ExtID);
				MasterPref = listOfNew[0].MC;						//Pick first as master
				
				//if more than one in the list then need to compare
				if(listOfNew.size() >1){
					system.debug('LOG: More than one new Pref with = '+ ExtID);
					for(MarketingConsent Pref: listOfNew){
						if(MasterPref != null){
							system.debug('LOG: Comparing new Preferences:');
							MasterPref = comparePreferences(MasterPref, Pref.MC);
						}
					}
				}
				//Only one so set as master
				else{
					system.debug('LOG: Only one new Preference - add to the list');
					addToMap(MasterPref, false);		//add in first master to the list
				}
			}
			//Add to the External to ID map for existing - double check logic here
			MCExtToActiveID.put(MasterPref.External_ID__c, MasterPref.ID);
		}
	}

	//************************************************
	//*** Generate JSON and pass to furture method ***
	//************************************************
	public void UpsertArchived(){
		if(prefToUpsert_Archived.size() > 0){
			System.enqueueJob(new Marketing_Consent_Archive(prefToUpsert_Archived.values()));
			/*string jsonPref = JSON.serializePretty(prefToUpsert_Archived.values());
			UpsertArchivedFuture(jsonPref);*/
		}
		
	}
/*
	//***********************************************
	//*** Create MC from JSON and upsert Archived ***
	//***********************************************
	@future
	public static void UpsertArchivedFuture(string jsonPref){
		ChangeMadeByTrigger = true;
		list<Marketing_Consent__c> PrefList =  (list<Marketing_Consent__c>)JSON.deserializeStrict(jsonPref, list<Marketing_Consent__c>.class);
		upsert PrefList External_ID__c;
	}*/

	//*************************
	//*** Add to Map Method ***
	//*************************
	public void addToMap(Marketing_Consent__c AddPref, boolean Archived){
		if(AddPref != null){
			if(AddPref.External_ID__c != null){
				Marketing_Consent__c newPref = AddPref.Clone(false, true, false, false);
				if(newPref.Source__c != 'Booking' && newPref.Source__c != 'Reservation' ) newPref.Booking_Passenger__c = null;
				if(newPref.Source__c != 'Request') newPref.Request__c = null;
				if(newPref.Source__c != 'Questionnaire') newPref.Questionnaire__c = null;

				if(Archived){
					prefToUpsert_Archived.put(newPref.External_ID__c, newPref);
				}
				else{
					prefToUpsert.put(newPref.External_ID__c, newPref);
				}
				
			}
		}
	}

	//*****************************************************
	//*** Method to decide winning MC from two provided ***
	//*****************************************************
	public Marketing_Consent__c comparePreferences(Marketing_Consent__c masterPref, Marketing_Consent__c secondPref){
		system.debug('START PREF COMPARISON LOG. Comparing..');
		system.debug('Master = '+ masterPref);
		system.debug('Second = '+ secondPref);
		system.debug('Result = ');

		//check that the preferences aren't null
		if(secondPref == null && masterPref != null){
			system.debug('LOG: SecondPref does not exist - Master Wins - do nothing');
			return masterPref;
		}
		else if(secondPref != null && masterPref == null){
			system.debug('LOG: MasterPref does not exist - Secondpref Wins');
			addToMap(secondPref, false);
			return secondPref;
		}

		//Check to see if preferences are same record e.g. same Pax 
		if(ObjectType != null){
			if(masterPref.get(ObjectType) == secondPref.get(ObjectType)){
				system.debug('LOG: SAME RECORD');
				if(masterPref.Opt_in__c != secondPref.Opt_in__c){
					system.debug('LOG: Change in Opt-in detected');
					addToMap(secondPref, false);
					return secondPref;
				}
				else{
					return masterPref;
				}
			}
		}
		
		//Check the opt in flags
		if(masterPref.Assumed_Opt_in__c && !secondPref.Assumed_Opt_in__c){
			system.debug('LOG: secondPref Wins because not assumed - no need to archive master pref as it is assumed');
			addToMap(secondPref, false);
			return secondPref;
		}
		else if(!masterPref.Assumed_Opt_in__c && secondPref.Assumed_Opt_in__c){
			system.debug('LOG: MasterPref Wins because not assumed - no need to archive second pref as it is assumed');
			return masterPref;
		}
		else if(masterPref.Assumed_Opt_in__c && secondPref.Assumed_Opt_in__c){
			system.debug('LOG: Both assumed - no need to archive just select the latest Booking Date');
			if(secondPref.Date_Entered__c == null && masterPref.Date_Entered__c != null){
				system.debug('LOG: secondpref doesnt have a date - master wins');
				return masterPref;
			}
			else if(secondPref.Date_Entered__c != null && masterPref.Date_Entered__c == null){
				system.debug('LOG: master doesnt have a date - secondWins');
				addToMap(secondPref, false);
				return secondPref;
			}

			if(secondPref.Date_Entered__c > masterPref.Date_Entered__c){
				system.debug('LOG: SecondPref has later date - Second Wins');
				addToMap(secondPref, false);
				return secondPref;
			}
			else{
				system.debug('LOG: Master pref is the later date - master wins - no need to update');
				return masterPref;
			}
		}
		else if(!masterPref.Assumed_Opt_in__c && !secondPref.Assumed_Opt_in__c){
			system.debug('LOG: Both are not assumed - need to take the latest date and archive old one');
			if(secondPref.Date_Entered__c == null && masterPref.Date_Entered__c != null){
				system.debug('LOG: secondpref doesnt have a date - master wins');
				//ArchiveThisPreference(secondPref); //DW Dev CP2 - Maybe required for CP.MC.011
				return masterPref;
			}
			else if(secondPref.Date_Entered__c != null && masterPref.Date_Entered__c == null){
				system.debug('LOG: master doesnt have a date - secondWins');
				addToMap(secondPref, false);
				//ArchiveThisPreference(secondPref); //DW Dev CP2 - Maybe required for CP.MC.011
				return secondPref;
			}

			if(secondPref.Date_Entered__c > masterPref.Date_Entered__c){
				system.debug('LOG: Second pref is the later date - Second wins - Updating');
				addToMap(secondPref, false);
				
				//Archive the Master
				system.debug('LOG: Archiving the Master');
				ArchiveThisPreference(masterPref);
				return secondPref;
			}
			else{
				//Master pref is the later date so this becomes preference
				system.debug('LOG: Master pref is the later date - Master wins - no need to update');
				addToMap(masterPref, false);
				
				//Archive the Second
				system.debug('LOG: Archiving the Second');
				ArchiveThisPreference(secondPref);
				return masterPref;
			}
		}
		system.debug('LOG: ERROR - Not met any of the criteria - no winner');
		return null;
	}	

	//*********************************
	//*** Archive a given MC record ***
	//*********************************
	public void ArchiveThisPreference(Marketing_Consent__c thisPref){
		Marketing_Consent__c parentPref = new Marketing_Consent__c (External_ID__c = thisPref.External_ID__c);
		thisPref.Active_Preference__r = parentPref;
		
		if(thisPref.Source__c == 'Booking' || thisPref.Source__c == 'Reservation' ){
			system.debug('LOG: Archiving Booking MC');
			thisPref.External_ID__c += '#' + thisPref.Booking_Passenger__c;
		} 
		else if(thisPref.Source__c == 'Request'){
			system.debug('LOG: Archiving Request MC');
			thisPref.External_ID__c += '#' + thisPref.Request__c;
		} 
		else if(thisPref.Source__c == 'Questionnaire'){
			system.debug('LOG: Archiving Questionnaire MC');
			thisPref.External_ID__c += '#' + thisPref.questionnaire__c;
		} 
		else if(thisPref.Source__c == 'Manual Override'){
			system.debug('LOG: Manual Override MC - do not archive');
			return;
		} 
		else{
			system.debug('LOG: Archiving other source MC');
			thisPref.External_ID__c += '#' + dateTime.now();
		}


		/*if(thisPref.Request__c != null){
			thisPref.External_ID__c += '#' + thisPref.Request__c;
		}
		else if(thisPref.Booking_Passenger__c != null){
			thisPref.External_ID__c += '#' + thisPref.Booking_Passenger__c;
		}
		else if(thisPref.questionnaire__c != null){
			thisPref.External_ID__c += '#' + thisPref.questionnaire__c;
		}
		else{
			thisPref.External_ID__c += '#' + dateTime.now();
		}
		*/

		system.debug(loggingLevel.Error, 'LOG: This MC External ID = '+ thisPref.External_ID__c);
		system.debug(loggingLevel.Error, 'LOG: This MC parentPref External ID = '+ thisPref.Active_Preference__r);
		
		thisPref.Archived__c = true;
		thisPref.RecordTypeID = MCRecordTypeMap.get('Archived_Preference');
		
		//Set the Archived Lookups
		thisPref.Booking_Passenger_Archived__c = thisPref.Booking_Passenger__c;
		thisPref.Request_Archived__c = thisPref.Request__c;
		thisPref.Archived_Questionnaire__c = thisPref.Questionnaire__c;
		thisPref.Customer_Archived__c = thisPref.Customer_or_Prospect__c;

		//null the active lookups
		thisPref.Customer_Active__c = null;
		thisPref.Booking_Passenger__c = null;
		thisPref.Request__c = null;
		thisPref.Questionnaire__c = null;

		thisPref.Archived_Date__c = datetime.now();
		addToMap(thisPref, true);
	}


	//*************************************
	//*** Marketing Consent inner class ***
	//*************************************
	public class MarketingConsent {
	    public ID SourceID;
	    public Marketing_Consent__c MC;

	    public MarketingConsent(ID source, Marketing_Consent__c Mark){
	    	SourceID = source;
	    	MC = Mark;
	    }
	}


}