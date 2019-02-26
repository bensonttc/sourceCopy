/**
 *  Test Class for the TQMobileAppController
 */
@isTest
private class TQMobileAppControllerTest {

    static testMethod void testUpdateSettings() {
        
        list<TQ_Tracked_Object_Config__c> trackedObjConfigList = TQTestUtils.createTrackedObjConfigCustomSettings();
        insert trackedObjConfigList;
        
		TQMobileAppController cont = new TQMobileAppController();
		
		system.assert(cont.apps.size() > 0);
		system.assert(cont.apps[0].objs[0].label != null);
		system.assert(cont.apps[0].objs[0].apiName != null);
		
		cont.apps[0].objs[0].config.Name = 'Updated';
		cont.updateAll();
		
		List<TQ_Tracked_Object_Config__c> settings = [SELECT Name FROM TQ_Tracked_Object_Config__c WHERE Id = : cont.apps[0].objs[0].config.Id];
		
		system.assertEquals('Updated', settings[0].Name);
		
		system.assert(cont.getObjectsList().size() > 0);
		
    }
    
    static testMethod void testDeleteSetting() {
    	
        list<TQ_Tracked_Object_Config__c> trackedObjConfigList = TQTestUtils.createTrackedObjConfigCustomSettings();
        insert trackedObjConfigList;
        
		TQMobileAppController.deleteObjSetting('Moment');
		
		List<TQ_Tracked_Object_Config__c> settings = [SELECT Id FROM TQ_Tracked_Object_Config__c];
        //System.assertEquals(trackedObjConfigList.size() - 1, settings.size());
		
    }
}