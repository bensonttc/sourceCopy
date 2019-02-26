/**
 *  Test Class for the Metadata service and endpoint
 */
@isTest
private class TQMetadataTest {
    
    /**
     *  High level test to ensure service is not broken
     */
    static testMethod void noTest() {
        TQMetadataResponse response = TQMetadataEndpoint.trackedObjectsInfo('TquilaONE');
        System.assert(response != null);
        System.assert(response.getBody() != null);
    }
    
    /**
    * testMethod to unit test the function "trackedObjectsInfo(String clientAppID)"
    */
    @isTest(SeeAllData=False)
    static void TQMetadataEndpoint_Test(){
        Test.startTest();
        list<TQ_Tracked_Object_Config__c> trackedObjConfigList = TQTestUtils.createTrackedObjConfigCustomSettings();
        insert trackedObjConfigList;
        TQMetadataResponse response = TQMetadataEndpoint.trackedObjectsInfo('TquilaONE');
        Test.stopTest();
        system.assert(response != null);
    }
    
    @isTest(SeeAllData=False)
    static void TQTrackingUtils_Test(){
        Test.startTest();
        list<TQ_Tracked_Object_Config__c> trackedObjConfigList = TQTestUtils.createTrackedObjConfigCustomSettings();
        insert trackedObjConfigList;
        TQTrackingUtils.getObjects('TquilaONE');
        
        TQTrackingUtils.FieldSetSelectionCriteria param = new TQTrackingUtils.FieldSetSelectionCriteria();
        param.objectAPIName = 'Account';
        param.fieldSetName = 'testFieldSetName';
        param.enforceIsAccessible = false;
        param.enforceIsCreateable = false;
        param.enforceIsRequired = false;
        param.enforceIsUpdateable = false;
        TQTrackingUtils.splitList('Id,Name,OwnerId,CreatedDate,LastModifiedDate');
        Test.stopTest();
    }
    
    @isTest(SeeAllData=False)
    static void TQMetadataResponse_Test(){
        
        TQMetadataResponse.TQMetadataResponseFieldSet restFS = new TQMetadataResponse.TQMetadataResponseFieldSet('Name',new List<String>{'Id','OwnerId','LastModifiedDate','CreatedDate'});
        restFS.getFieldList();
        restFS.getName();
        
        TQMetadataResponse.TQMetadataResponseItem resItem = new TQMetadataResponse.TQMetadataResponseItem();
        resItem.getObjectApiName();
        resItem.getLayoutNeeded();
        resItem.getDisplayable();
        resItem.getFieldSetList();
        resItem.setFieldSetList(new List<TQMetadataResponse.TQMetadataResponseFieldSet>{restFS});
        resItem.getObjectCustomIndexList();
        resItem.setDetailFieldSet(restFS.getFieldList());
        resItem.getDetailFieldSet();
        resItem.setListHeaderFieldSet(restFS.getFieldList());
        resItem.getListHeaderFieldSet();
    }
    
    @isTest(SeeAllData=False)
    static void TQException_Test(){
        TQException exp = new TQException(2);
        system.assert(exp.getErrorCode() == 2);
        exp.setErrorCode(3);
        system.assert(exp.getErrorCode() == 3);
    }
    
}