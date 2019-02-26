public with sharing class TQTrackedObjectEditController {
	static final Integer DEFAULT_MAX_RECORDS_BEFORE_FULL_SYNC = 1000;

	public Boolean err {
		get {
			if (err==null) {
				err = false;
			}
			return err;
		}
		private set;
	}
	public String errMsg {get;set;}

	public class FieldsetWrapper implements Comparable {
		public String apiName {get;set;}
		public Boolean selected {
			get {
				if (selected==null) {
					selected = false;
				}
				return selected;
			}
			set;
		}

		public Integer compareTo(Object obj2) {
			FieldsetWrapper fsw2 = (FieldsetWrapper) obj2;

			if (this.apiName>fsw2.apiName) {
				return 1;
			}
			else if (this.apiName<fsw2.apiName) {
				return -1;
			}
			else {
				return 0;
			}
		}
	}

	// Returns a sorted list of fieldsets for the object of interest
	public List<FieldsetWrapper> getFSL() {

		List<FieldsetWrapper> fsl = new List<FieldsetWrapper>();

		Schema.DescribeSObjectResult d = Schema.getGlobalDescribe().get(config.Object_Api_Name__c).getDescribe();

		for (Schema.FieldSet fs : d.FieldSets.getMap().values() ) {

			FieldsetWrapper x = new FieldsetWrapper();
			x.apiName = fs.getName();
			if (config.Fieldset_Name_List__c != null && config.Fieldset_Name_List__c.contains(fs.getName())) {
				x.selected = true;
			}
			fsl.add(x);
		}
		fsl.sort();

		return fsl;
	}

	// Returns a sorted list of fields for the object of interest
	// NOTE: This uses the fieldset wrapper because it requires the same functionality
	// checkme is the string to check against to determine if a field is currently selected
	private List<FieldsetWrapper> getFieldList(String checkme) {

		List<FieldsetWrapper> fieldList = new List<FieldsetWrapper>();

		Schema.DescribeSObjectResult d = Schema.getGlobalDescribe().get(config.Object_Api_Name__c).getDescribe();

		for (String f : d.Fields.getMap().keyset() ) {

			FieldsetWrapper x = new FieldsetWrapper();
			x.apiName = f;
			if (checkme != null && checkme.contains(f)) {
				x.selected = true;
			}
			fieldList.add(x);
		}
		fieldList.sort();

		return fieldList;
	}

	public List<FieldsetWrapper> getCustomIndexFields() {
		return getFieldList(config.Custom_Index_List__c);
	}

	public List<FieldsetWrapper> getListHeaderFields() {
		return getFieldList(config.List_Header_Fieldset__c);
	}

	public TQ_Tracked_Object_Config__c config {get;set;}

	public TQTrackedObjectEditController() {
		
		String clientAppId = ApexPages.currentPage().getParameters().get('clientAppId');
		String objApiName = ApexPages.currentPage().getParameters().get('objApiName');

		if (clientAppId==null || objApiName==null) {
			// TODO: Add error here. We need these things
			err = true;
			errMsg = 'This page requires a Client App Id and an Object API name.';
		}
		else {

			String configName = clientAppId+' '+Schema.getGlobalDescribe().get(objApiName).getDescribe().getLabel();

			if (TQ_Tracked_Object_Config__c.getInstance(configName)!=null) {

				config = TQ_Tracked_Object_Config__c.getInstance(configName);
			}
			else {
				config = new TQ_Tracked_Object_Config__c(Name=configName,ClientApp_ID__c=clientAppId,Object_Api_Name__c=objApiName,
					Max_Records_Before_Full_Sync__c=DEFAULT_MAX_RECORDS_BEFORE_FULL_SYNC);
			}
		}

	}

	public PageReference save() {
		// TODO: Better error handling

		SavePoint sp = Database.setSavePoint();
		try {
			upsert config;
			if (TQ_Config__c.getInstance(config.ClientApp_ID__c)==null) {
				insert new TQ_Config__c(ClientApp_ID__c=config.ClientApp_ID__c,Name=config.ClientApp_ID__c);
			}
			return new PageReference('/apex/TQMobileApp');
			//return new PageReference('/apex/TQTrackedObjectEdit?clientAppId='+config.ClientApp_ID__c+'&objApiName='+config.Object_Api_Name__c);
		}
		// TODO: This currently won't rerender and so actually display an error message!
		catch (Exception e) {
			// roll 'em back
			Database.rollback(sp);

			err = true;

			errMsg = e.getMessage();

			return null;
		}
	}
}