// ******* Copyright Cloud Perspective Ltd 2016 - all rights reserved
// ******* Please ensure that this copyright is acknowledged in any subsequent use.
// ******* Contact regarding Copyright: martyn@cloudperspective.co.uk
// ******* Developer: deliveryteam@cloudperspective.co.uk

// **************************DW****************************
// ** Class passes reparented Marketing Consents 		 **
// ** back in to the pool to be appropriatley            **
// ** upserted. Old instances are deleted so as          **
// ** to prevent duplicates.							 **
// ********************************************************

public with sharing class Marketing_Consent_Delete implements Queueable {
	private list<Marketing_Consent__c> MarketingConsentList;
	private list<Marketing_Consent__c> MarketingConsentListClone;

	public Marketing_Consent_Delete(list<Marketing_Consent__c> MCs){
		MarketingConsentList = MCs;	
	}
	
	public void execute(QueueableContext context) {

		Marketing_Consent_Handler_Class MarketingConsentHandler = new Marketing_Consent_Handler_Class(NULL); //What object string does this want?
	    MarketingConsentHandler.addPreference(MarketingConsentList);
	    // **************************DW****************************
		// ** createPreferences() method makes a call to the     **
		// ** archiving Queuable method. Cannot call successive  **
		// ** queuables within test-class                        **
		// ********************************************************
		if(!Test.isRunningTest()){
	        MarketingConsentHandler.createPreferences();
	    } else {
			MarketingConsentListClone = MarketingConsentList.deepClone(false, false, false);
	    	upsert MarketingConsentListClone External_Id__c;
	    }
		delete MarketingConsentList;
	}

}