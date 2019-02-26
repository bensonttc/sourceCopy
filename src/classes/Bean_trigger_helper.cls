public with sharing class Bean_trigger_helper {
	public Bean_trigger_helper() {
		
	}

	public static void Before_Update_or_insert(list<DSE__DS_Bean__c> newList, map<id, DSE__DS_Bean__c> oldMap, boolean isInsert, boolean isUpdate){
		//*** START Setup of Logging
		string TriggerEvent = '';

	    if(isInsert) TriggerEvent += 'Insert';
	    else TriggerEvent += 'Update';

		MDM_Debug_Logs_Class Dlog = new MDM_Debug_Logs_Class('Bean Trigger', TriggerEvent, false);

		MDM_Account_Creation_Setting__c Creation;
	    try{
	         Creation = MDM_Account_Creation_Setting__c.getValues('Active');
	         Dlog.LogsEnabled = Creation.Enable_Logging__c;
	    }
	    catch(exception e){
	    	Creation = new MDM_Account_Creation_Setting__c(Active__c = false);
	        Dlog.LogsEnabled = false;
	        Dlog.quicklog('Creation setting not found');
	    }

	    //If not enabled then end class here
	    if(!Creation.Active__c){
	    	Dlog.quicklog('Synchronisation is disabled');
	    	Dlog.Comit();
	    	return;
	    }

	    //*** END Setup of Logging


		map<string, list<DSE__DS_Bean__c>> NewMapWithSegments = new map<string, list<DSE__DS_Bean__c>>();

		//Get the record Types
		map<string, string> SourceToRecordType = new map<string, string>();
		for(MDM_Bean_Source_Record_Types__c  BeanRTs : MDM_Bean_Source_Record_Types__c.getall().values()){
			//if(BeanRTs.name == 'Booking_Passenger__c'){
				SourceToRecordType.put(BeanRTs.name, BeanRTs.Target_Record_Type__c);
			//}
		}

		//Get the Data Sources
		set<string> ContactExtSources = new set<string>();
		for(DSE__DS_Sources__c sources : DSE__DS_Sources__c.getall().values()){
			if(sources.DSE__DS_Object_Class__c == 'Contact' && sources.name != 'Contact'){
				ContactExtSources.add(sources.name);
			}
		}

		Dlog.quicklog('External Sources = '+ ContactExtSources);



		for (DSE__DS_Bean__c Bean: newList)
    	{
    		DSE__DS_Bean__c oldBean;
    		if(isUpdate){
    			oldBean = oldMap.get(Bean.ID);
    		}
    		
    		//***START Stripping words 
    		Bean.DSE__DS_Custom_Field_10__c = MDM_Helper_Class.sanitiseAndRemoveCommonWordsName(Bean.DSE__DS_Custom_Field_10__c);
    		Bean.DSE__DS_Segment__c = MDM_Helper_Class.RemoveCommonWords(Bean.DSE__DS_Segment__c);
    		//***END Stripping words


    		//***START Setting Record Type Field
    		string RecordType = SourceToRecordType.get(Bean.DSE__DS_Source__c);
    		if(RecordType != null){
    			Bean.DSE__DS_Record_Type_Name__c = RecordType;
    		}

    		//***END Setting Record Type Field


    		//*** START Setting Lookups ***
    		boolean processPax = false;
    		boolean processCont = false;

    		if(isInsert || Bean.Reset_Lookups__c){
    			processPax = true;
    			processCont = true;
    			Bean.Reset_Lookups__c = false;
    		}
    		else if (isUpdate){
    			if(oldBean.DSE__DS_Conversion_Status__c != Bean.DSE__DS_Conversion_Status__c){
    				processCont = true;
    			}
    		}

    		if(processPax){
    			if(Bean.DSE__DS_Source__c == 'Booking_Passenger__c')
		        {
		        	try{
		        		Bean.Booking_Passenger__c = Bean.DSE__DS_Source_No__c;
		        	}
		        	catch(exception e){
		        		system.debug('Error setting Booking Passenger');
		        	}
		        }
		        else if (Bean.DSE__DS_Source__c == 'Request__c'){
		        	try{
		        		Bean.Request__c = Bean.DSE__DS_Source_No__c;
		        	}
		        	catch(exception e){
		        		system.debug('Error setting Request');
		        	}
		        }
		        else if (Bean.DSE__DS_Source__c == 'Pre_Registration__c'){
		        	try{
		        		Bean.Pre_Registration__c = Bean.DSE__DS_Source_No__c;
		        	}
		        	catch(exception e){
		        		system.debug('Error setting Pre Reg');
		        	}
		        }
		        else if (Bean.DSE__DS_Source__c == 'Lead'){
		        	try{
		        		Bean.DSE__DS_Lead__c = Bean.DSE__DS_Source_No__c;
		        	}
		        	catch(exception e){
		        		system.debug('Error setting Lead');
		        	}
		        }
		    }

		    if(processCont){
		        //Set the Conversion Contact field
		        if(Bean.DSE__DS_Conversion_Status__c != null){
		        	if(Bean.DSE__DS_Conversion_Status__c.startsWith('Converted:') || Bean.DSE__DS_Conversion_Status__c.startsWith('Duplicates:')){
			        	try{
			        		string ConvID = Bean.DSE__DS_Conversion_Status__c.replace('Converted:', '').replace('Duplicates:','').substring(0,18);
			        		if(ConvID.startsWith('003')){
			        			Bean.Conversion_Contact__c = ConvID;
			        		}
			        	}
			        	catch(exception e){
			        		system.debug('Error setting Conversion Contact');
			        	}
			        }
		        }
    		}
    		//*** END Setting Lookups ***


    		//*** START Setting Custom Field 5 for Contacts ***
    		Dlog.quicklog('Start setting CF5');
    		//if contact then set as 'Contact'
    		if(Bean.DSE__DS_Source__c == 'Contact'){
    			Dlog.quicklog('Set CF5 to Contact');
    			Bean.DSE__DS_Custom_Field_5__c = 'Contact';
    			Bean.DSE__DS_Segment__c = BuildSegment(Bean.DSE__DS_Segment__c, 'C');
    		}
    		//if external Contact Source then set as 'Account'
    		else if(ContactExtSources.contains(Bean.DSE__DS_Source__c)){
    			Bean.DSE__DS_Duplicate_Checked__c = true;
    			//has been through conversion so switch segment so not compared
    			if(Bean.Conversion_Contact__c != null && Bean.DSE__DS_Master_Bean__c != null){
    				Bean.DSE__DS_Custom_Field_5__c = 'N/A';
    				Dlog.quicklog('Set CF5 to N/A');
    				Bean.DSE__DS_Segment__c = BuildSegment(Bean.DSE__DS_Segment__c, 'N');
    				
    			}
    			else if(Bean.DSE__DS_Master_Bean__c == null){
    				Bean.DSE__DS_Custom_Field_5__c = 'Account';
    				Dlog.quicklog('No MB - Set CF5 to Account');
    				Bean.DSE__DS_Segment__c = BuildSegment(Bean.DSE__DS_Segment__c, 'A');
    			}
    			//Needs to go through Data Conversion so has same segment as Contacts
    			else{
    				Bean.DSE__DS_Custom_Field_5__c = 'Contact';
    				Dlog.quicklog('Set CF5 to Contact');
    				Bean.DSE__DS_Segment__c = BuildSegment(Bean.DSE__DS_Segment__c, 'C');
    			}
    		}
    		//*** END Setting Custom Field 5 for Contacts ***

	        
	        //*** START Build CP Segment ***
	        //Build the CP Segment for Business Accounts
	        string Sanitised = '';
	        if(Bean.DSE__DS_Custom_Field_5__c == 'false' || Bean.DSE__DS_Custom_Field_5__c == 'Account' || Bean.DSE__DS_Custom_Field_5__c == 'Agency' || Bean.DSE__DS_Custom_Field_5__c == 'Contact'){
	        	if(Bean.DSE__DS_Billing_Country__c != null && Bean.DSE__DS_Company__c != null && Bean.DSE__DS_Billing_Street__c != null && Bean.DSE__DS_Billing_City__c != null){
	        		Sanitised = MDM_Helper_Class.sanitiseName(MDM_Helper_Class.removeNull(Bean.DSE__DS_Custom_Field_5__c) + MDM_Helper_Class.removeNull(Bean.DSE__DS_Billing_Country__c) + MDM_Helper_Class.removeNull(Bean.DSE__DS_Company__c) + MDM_Helper_Class.removeNull(Bean.DSE__DS_Billing_Street__c) + MDM_Helper_Class.removeNull(Bean.DSE__DS_Billing_City__c) + MDM_Helper_Class.removeNull(Bean.DSE__DS_Custom_Field_6__c));
	        	}
	        }
	        //Build the CP Segment for Person Accounts
	        else if(Bean.DSE__DS_Custom_Field_5__c == 'true'){
	        	if(Bean.DSE__DS_First_Name__c != null && Bean.DSE__DS_Last_Name__c != null && Bean.DSE__DS_Email__c != null){
	        		string firstName = MDM_Helper_Class.removeNull(Bean.DSE__DS_First_Name__c);
	        		if(firstName.length() > 3) firstName = firstName.substring(0,3);
	        		Sanitised = MDM_Helper_Class.sanitiseName(MDM_Helper_Class.removeNull(Bean.DSE__DS_Custom_Field_5__c) + firstName + MDM_Helper_Class.removeNull(Bean.DSE__DS_Last_Name__c) + MDM_Helper_Class.removeNull(Bean.DSE__DS_Email__c));
	        	}
	        }

	        //Truncate to 255 and set field on Bean
	        if(Sanitised.length() > 255){
        		Sanitised = Sanitised.substring(0,255);
        	}

        	Bean.CP_Segment__c = Sanitised;
        	//has to have a CP segment and both old and new bean's MB are null (not been unmatched)
        	//SHOULD ONLY COMPARE OLD VS NEW IN UPDATE - NEED TO FIX ASAP
        	boolean Unmatched = false;
        	if(isUpdate){
        		if(oldBean.DSE__DS_Master_Bean__c != null){
        			Unmatched = true;
        		}
        	}
        	if(Sanitised.length() > 0 && Bean.DSE__DS_Master_Bean__c == null && !Unmatched){

        		if(NewMapWithSegments.containsKey(Bean.CP_Segment__c)){
					NewMapWithSegments.get(Bean.CP_Segment__c).add(Bean);
				}
				else{
					list<DSE__DS_Bean__c> BeanList = new list<DSE__DS_Bean__c>();
					BeanList.add(Bean);
					NewMapWithSegments.put(Bean.CP_Segment__c, BeanList);
				}
        	}
	        //*** END Build CP Segment ***
    	}//End loop round Beans

    	//AutoMatch beans
    	if(NewMapWithSegments.size() > 0 && Creation.Enable_Auto_match_Beans__c){
    		FindMatchedBeans(NewMapWithSegments);
    	}
    	
    	//Dlog.Comit();
	}

	public static string BuildSegment(string SegVal, string CF5){
		if(SegVal != null){
			if(SegVal.length() <=1){
				SegVal = CF5;
			}
			else{
				SegVal = CF5 + SegVal.substring(1, SegVal.length());
			}
		}
		return SegVal;
	}


	//Find matching master beans
	public static void FindMatchedBeans(map<string, list<DSE__DS_Bean__c>> BeanMap){
		map<string, id> SegmentToMasterBean = new map<string, id>();
		for(DSE__DS_Master_Bean__c MB : [select id, CP_Segment__c from DSE__DS_Master_Bean__c where CP_Segment__c in :BeanMap.KeySet()]){
			SegmentToMasterBean.put(MB.CP_Segment__c, MB.ID);
		}

		for(list<DSE__DS_Bean__c> Beans : BeanMap.values()){
			for(DSE__DS_Bean__c Bean: Beans){
				if(SegmentToMasterBean.ContainsKey(Bean.CP_Segment__c)){
					Bean.DSE__DS_Master_Bean__c = SegmentToMasterBean.get(Bean.CP_Segment__c);
				}
			}
		}
	}

}