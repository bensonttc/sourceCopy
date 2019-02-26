/**
 * @description This is used in the supplier mobilised table to restrict the number of suppliers that are sent to the app
 **/
global without sharing class TOPS_SupplierRestriction implements mobilecaddy1.RestrictionInterface001_mc {
	private static final set<String> INCLUDED_CONTRACT_STATUS = new Set<String>{'Awaiting Contract - Approved','Info Only','Done'};

	/**
	 * @description This returns a set of Account IDs for all of the Account objects that meet the following criteria:
	 * - All Accounts where Record Type = Supplier_Contracted AND (Contract_Status__c != 'Awaiting Contract – Do not use' OR Contract_Status__c != 'No longer contracted') 
	 * 			AND Supplier_City__c IN Tour_Optional__c.Location__c AND Supplier_Type__c != null // All optional suppliers for the directory
	 * - All Accounts Linked to Tour Instance Itinerary Records (Supplier__c) // All Hotels and Restaraunts that are being used
	 * @param String A JSON String. This isn't currently being used
	 * @return Set<Id> A set of Account IDs
	 **/
	global Set<Id> returnRestrictedIds(String jsonParams) {
		Set<Id> supplierIds = new Set<Id>();

		// Get a map of Account record types
		Map<String, Id> accountRecordTypeIdsByName = new Map<String, Id>();
		for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType='Account']) {
  			accountRecordTypeIdsByName.put(rt.DeveloperName, rt.Id);
		}

		// Find all of the Tour Instances for the current user that should be included on the app
		Map<Id,Tour_Instance__c> tdTourInstancesById = new Map<Id, Tour_Instance__c>([SELECT Id FROM Tour_Instance__c WHERE MC_TOPS_Include_Tour__c=true AND OwnerId=:UserInfo.getUserId()]);
		Set<Id> tourIds = tdTourInstancesById.keySet();

		// Find all of the TIIs and get city information from there
		Set<String> tourCities = new Set<String>();
		for (Tour_Optional__c tourOptional : [SELECT Id, Location__c FROM Tour_Optional__c WHERE Tour_Instance__c IN:tourIds]) {
			tourCities.add(tourOptional.Location__c);
		}

		// Using the City find all of the contacted suppliers with the correct contract status and with a supplier type
		String contractedRecordType = accountRecordTypeIdsByName.get('Supplier_Contracted');
		if (tourCities.size() > 0) {
			for(Account supplier : [SELECT Id FROM Account 
										WHERE Supplier_City__c IN :tourCities 
											AND Supplier_Type__c!=null 
											AND Contract_Status__c IN :INCLUDED_CONTRACT_STATUS
											AND RecordTypeId =:contractedRecordType]) {
				supplierIds.add(Supplier.Id);
			}

		}

		// Get all of the Supplier IDs from the tour instance itineraries linked to these TIs
		for (Tour_Instance_Itinerary__c tii : [SELECT Id, Supplier__c FROM Tour_Instance_Itinerary__c WHERE Tour_Instance__c IN:tourIds]) {
			if (tii.Supplier__c != null) {
				supplierIds.add(tii.Supplier__c);
			}
		}

		return supplierIds; //return (new Map<Id,SObject>(queryResults)).keySet();

	}
}