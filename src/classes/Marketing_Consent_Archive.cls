public class Marketing_Consent_Archive implements Queueable {
	private list<Marketing_Consent__c> MarketingConsentList;

	public Marketing_Consent_Archive(list<Marketing_Consent__c> MCs){
		MarketingConsentList = MCs;
	}

	
	public void execute(QueueableContext context) {
		upsert MarketingConsentList External_ID__c;
	}
}