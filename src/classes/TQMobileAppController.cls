public with sharing class TQMobileAppController {

	public class ObjectWrapper {
		public String label {
			get {
				if (label==null) {
					label = Schema.getGlobalDescribe().get(apiName).getDescribe().getLabel();
				}
				return label;
			}
			set;
		}
		public String apiName {
			get {
				if (apiName==null) {
					apiName = config.Object_Api_Name__c;
				}
				return apiName;
			}
			set;
		}
		public TQ_Tracked_Object_Config__c config {get;set;}

		public ObjectWrapper(TQ_Tracked_Object_Config__c config) {
			this.config = config;
		}
	}

	public List<String> getObjectsList() {

		List<String> objApiNames = new List<String>();

		List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();     

		for(Schema.SObjectType f : gd) {
			objApiNames.add(f.getDescribe().getName());
		}
		objApiNames.sort();

		return objApiNames;
	}

	public class AppWrapper implements Comparable {
		public String appName {get;set;}
		public List<ObjectWrapper> objs {get;set;}
		public TQ_Config__c conf {
			get {
				if (conf==null) {
					conf = TQ_Config__c.getInstance(appName);
				}
				return conf;
			}
			set;}

		public AppWrapper(String appName, List<ObjectWrapper> objs) {
			this.appName = appName;
			this.objs = objs;
		}

		public Integer compareTo(Object obj2) {
			AppWrapper appw2 = (AppWrapper) obj2;

			if (this.appName>appw2.appName) {
				return 1;
			}
			else if (this.appName<appw2.appName) {
				return -1;
			}
			else {
				return 0;
			}
		}
	}

	public List<AppWrapper> apps {get;set;}

	/*public String appInFocus {get;set;}*/

	public PageReference updateAll() {
		List<TQ_Tracked_Object_Config__c> objs = new List<TQ_Tracked_Object_Config__c>();
		for (AppWrapper app : apps) {
			//objs.addAll(app.objs);

			//if (app.appName==appInFocus) {
				for (ObjectWrapper obj : app.objs) {
					objs.add(obj.config);
				}	
			//}
		}

		update objs;

		return null;
	}

	@RemoteAction
	public static void deleteObjSetting(String objname) {
		TQ_Tracked_Object_Config__c config = TQ_Tracked_Object_Config__c.getInstance(objname);
		if(config != null) {
			String appname = config.ClientApp_ID__c;
			delete config;	

			// If there are no remaining settings for this app then delete the tq_config__c entry too
			List<TQ_Tracked_Object_Config__c> remainingConfigsForThisApp = [SELECT Id FROM TQ_Tracked_Object_Config__c WHERE ClientApp_ID__c=:appname];
			if (remainingConfigsForThisApp.size()==0) {
				TQ_Config__c syncConfig = TQ_Config__c.getInstance(appname);
				delete syncConfig;
			}
		}
	}

	public TQMobileAppController() {

		apps = new List<AppWrapper>();
		Map<String,List<ObjectWrapper>> appsMap = new Map<String,List<ObjectWrapper>>();

		for (TQ_Tracked_Object_Config__c conf : TQ_Tracked_Object_Config__c.getall().values()) {

			String appName = conf.ClientApp_ID__c;
			if (!appsMap.containsKey(appName)) {
				appsMap.put(appName, new List<ObjectWrapper>());
			}

			appsMap.get(appName).add(new ObjectWrapper(conf));

		}

		for (String k : appsMap.keySet()) {
			apps.add(new AppWrapper(k,appsMap.get(k)));
		}

		apps.sort();
	}
}