@isTest
private class TQUploadEndpointTest {

    static testMethod void simpleInsertTest(){
        Account testAccount = new Account(Name = 'SimpleTestAccoun');
        insert testAccount;
        
        List<TQUploadRequestItem> requestItems = new List<TQUploadRequestItem>{
            new TQUploadRequestItem(
                'Account', 'Local_Id',
                '{"Id" : "Local_Id", "Name" : "Test Account Name 2", "LastModifiedById" : "Fake_Id"}'
            ),
            
            new TQUploadRequestItem(
                'Account', testAccount.Id,
                '{"Id" : "' + testAccount.Id + '", "IsDeleted" : true}'
            )
        };      

        
        TQUploadResponse response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        System.assertEquals(0, response.getStatus());
        System.assert(response.body.get(0).success);
        System.assert(response.body.get(0).responseId != null);
        System.assertNotEquals(response.body.get(0).requestId, response.body.get(0).responseId);
        System.assert(response.body.get(1).success);
        
        List<Account> resultAccounts = [SELECT Id FROM Account WHERE Id = : testAccount.Id];
        System.assertEquals(0, resultAccounts.size());

    }
    
    static testMethod void testMultipleRequestWithReassignment() {
        List<TQUploadRequestItem> requestItems = new List<TQUploadRequestItem>{
            new TQUploadRequestItem(
                'Contact', 'Local_Id_2',
                '{"Id" : "Local_Id_2", "Name" : "Nik", "LastName": "Tassini", "AccountId" : "Local_Id"}'
            ),
            new TQUploadRequestItem(
                'Account', 'Local_Id',
                '{"Id" : "Local_Id", "Name" : "Test Account Name 35", "LastModifiedById" : "Fake_Id"}'
            ),
            new TQUploadRequestItem(
                'Account', '0012000001CzRAbAAN',
                '{"Id" : "0012000001CzRAbAAN", "Name" : "Test Account Name 2", "LastModifiedById" : "Fake_Id", "IsDeleted" : true}'
            ),
            new TQUploadRequestItem(
                'Contact', 'Local_Id_3',
                '{"Id" : "Local_Id_3", "Name" : "Ale", "LastName": "Valentini",  "AccountId" : "Local_Id_XXX"}'
            )
        };
        

        TQUploadResponse response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        System.assertEquals(0, response.getStatus());
        System.assert(response.body.get(0).success);        
        System.assert(response.body.get(1).success);
        System.assert(!response.body.get(2).success);
        System.assert(!response.body.get(3).success);
        
    }
    
    //test update with a local Id
    static testMethod void testSecondRequest() {
        List<TQUploadRequestItem> requestItems = new List<TQUploadRequestItem>{
            new TQUploadRequestItem(
                'Account', 'Local_Id',
                '{"Id" : "Local_Id", "Name" : "Test Account Name 35", "LastModifiedById" : "Fake_Id"}'
            )
        };
        

        TQUploadResponse response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        System.assertEquals(0, response.getStatus());
        System.assert(response.body.get(0).success);
        
        response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        
    }
    
    static testMethod void testDmlBatchesInsert() {
        TQUploadEndpoint.EXECUTE_DML_BY_RECORD_LIMIT = 2;
        
        List<TQUploadRequestItem> requestItems = new List<TQUploadRequestItem>{
            new TQUploadRequestItem(
                'Account', 'Local_Id',
                '{"Id" : "Local_Id", "Name" : "Test Account Name 35", "LastModifiedById" : "Fake_Id"}'
            )
        };
        
        requestItems.addAll(TQTestUtils.createTQUploadRequestItemList(2));

        TQUploadResponse response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        System.assertEquals(0, response.getStatus());
        System.assert(response.body.get(0).success);        
        System.assert(response.body.get(1).success);
        System.assert(response.body.get(2).success);
        
    }
    
    static testMethod void testDmlBatchesDelete() {
        TQUploadEndpoint.EXECUTE_DML_BY_RECORD_LIMIT = 2;
        //create Accounts 
        List<Account> aL = TQTestUtils.createAccounts(4);
        insert aL;
        
        List<TQUploadRequestItem> requestItems = TQTestUtils.createTQUploadRequestItemList(aL, 'Account', '"IsDeleted" : true');

        TQUploadResponse response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        System.assertEquals(0, response.getStatus());
        System.assert(response.body.get(0).success);        
        System.assert(response.body.get(1).success);
        System.assert(response.body.get(3).success);
        
    }
    
    static testMethod void testDmlBatchesUpdate() {
        TQUploadEndpoint.EXECUTE_DML_BY_RECORD_LIMIT = 2;
        //create Accounts 
        List<Account> aL = TQTestUtils.createAccounts(4);
        insert aL;
        
        List<TQUploadRequestItem> requestItems = TQTestUtils.createTQUploadRequestItemList(aL, 'Account', '"LastModifiedById" : "Fake_Id"');

        TQUploadResponse response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        System.assertEquals(0, response.getStatus());
        System.assert(response.body.get(0).success);        
        System.assert(response.body.get(1).success);
        System.assert(response.body.get(3).success);
        
    }
    
    @IsTest(SeeAllData=true)
    static void testFeedItem() {
        String firstName = 'Nick', lastName = 'Tquila', email = 'nicola@tquila.com', username = 'nic1231242@tquila.com.121244';
        // Create tdAccount
        Account tdAccount = TQTestUtils.createAccount(firstname, lastname, email);
        insert tdAccount;
        // Create tour instance
        Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', null, 'opeProCode123', 'departureCode234',
            Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
        insert tourInstance;
        
        List<TQUploadRequestItem> requestItems = new List<TQUploadRequestItem>{
            new TQUploadRequestItem(
                'FeedItem', 'Local_Id',
                '{"Id" : "Local_Id", "Type" : "TextPost", "Body" : "Test", "ParentId" : "' + tourInstance.Id + '"}'
            ),
            new TQUploadRequestItem(
                'FeedItem', 'Local_Id_1',
                '{"Id" : "Local_Id_1", "Type" : "ContentPost", "Body" : "Test", "ParentId" : "' + tourInstance.Id + '", "ContentFileName" : "file.txt", "ContentData" : "' + 
                    EncodingUtil.base64Encode(Blob.valueOf('data data dataaa')) +'"}'
            )
        };
        

        TQUploadResponse response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        System.assertEquals(0, response.getStatus());
        System.assert(response.body.get(0).success);
        
        response = TQUploadEndpoint.uploadRequest('TquilaONE', requestItems, 'testdevice');
        
    }
   
    @isTest(SeeAllData=False)
    static void TQUploadService_Test(){
        createTrackedObjConfigCustomSetting();
        TQUploadService tqUploadSer = new TQUploadService();
        tqUploadSer.getUniqueArray(new list<String>{'1','2','3'});
    }
    
    @isTest(SeeAllData=False)
    static void TQUploadRequest_Test(){
        createTrackedObjConfigCustomSetting();
        TQUploadRequest req = new TQUploadRequest();
    }
    
    static void createTrackedObjConfigCustomSetting(){
        list<TQ_Tracked_Object_Config__c> trackedObjConfigList = new list<TQ_Tracked_Object_Config__c>();
        
        TQ_Tracked_Object_Config__c t1TrackedObjConfig1 = new TQ_Tracked_Object_Config__c();
        t1TrackedObjConfig1.Active__c = true;
        t1TrackedObjConfig1.ClientApp_ID__c = 'TquilaONE';
        t1TrackedObjConfig1.Custom_Index_List__c = '';
        t1TrackedObjConfig1.Displayable__c = true;
        t1TrackedObjConfig1.Fieldset_Name_List__c = '';
        t1TrackedObjConfig1.Layout_Needed__c = false;
        t1TrackedObjConfig1.List_Header_Fieldset__c = '';
        t1TrackedObjConfig1.Max_Records_Before_Full_Sync__c = 1000;
        t1TrackedObjConfig1.Name = 'Account';
        t1TrackedObjConfig1.Object_Api_Name__c = 'Account';
        t1TrackedObjConfig1.Order_By__c = '';
        t1TrackedObjConfig1.Where__c = 'Name like \'%TquilaONE%\'';
        trackedObjConfigList.add(t1TrackedObjConfig1);
        
        TQ_Tracked_Object_Config__c t1TrackedObjConfig2 = new TQ_Tracked_Object_Config__c();
        t1TrackedObjConfig2.Active__c = true;
        t1TrackedObjConfig2.ClientApp_ID__c = 'TquilaONE';
        t1TrackedObjConfig2.Custom_Index_List__c = '';
        t1TrackedObjConfig2.Displayable__c = true;
        t1TrackedObjConfig2.Fieldset_Name_List__c = '';
        t1TrackedObjConfig2.Layout_Needed__c = false;
        t1TrackedObjConfig2.List_Header_Fieldset__c = '';
        t1TrackedObjConfig2.Max_Records_Before_Full_Sync__c = 1000;
        t1TrackedObjConfig2.Name = 'Case';
        t1TrackedObjConfig2.Object_Api_Name__c = 'Case';
        t1TrackedObjConfig2.Order_By__c = '';
        t1TrackedObjConfig2.Where__c = '';
        trackedObjConfigList.add(t1TrackedObjConfig2);
        
        TQ_Tracked_Object_Config__c t1TrackedObjConfig3 = new TQ_Tracked_Object_Config__c();
        t1TrackedObjConfig3.Active__c = true;
        t1TrackedObjConfig3.ClientApp_ID__c = 'TquilaONE';
        t1TrackedObjConfig3.Custom_Index_List__c = '';
        t1TrackedObjConfig3.Displayable__c = true;
        t1TrackedObjConfig3.Fieldset_Name_List__c = '';
        t1TrackedObjConfig3.Layout_Needed__c = false;
        t1TrackedObjConfig3.List_Header_Fieldset__c = '';
        t1TrackedObjConfig3.Max_Records_Before_Full_Sync__c = 1000;
        t1TrackedObjConfig3.Name = 'Order';
        t1TrackedObjConfig3.Object_Api_Name__c = 'Order__c';
        t1TrackedObjConfig3.Order_By__c = '';
        t1TrackedObjConfig3.Where__c = '';
        trackedObjConfigList.add(t1TrackedObjConfig3);
        
        TQ_Tracked_Object_Config__c t1TrackedObjConfig4 = new TQ_Tracked_Object_Config__c();
        t1TrackedObjConfig4.Active__c = true;
        t1TrackedObjConfig4.ClientApp_ID__c = 'TquilaONE';
        t1TrackedObjConfig4.Custom_Index_List__c = '';
        t1TrackedObjConfig4.Displayable__c = false;
        t1TrackedObjConfig4.Fieldset_Name_List__c = '';
        t1TrackedObjConfig4.Layout_Needed__c = false;
        t1TrackedObjConfig4.List_Header_Fieldset__c = '';
        t1TrackedObjConfig4.Max_Records_Before_Full_Sync__c = 1000;
        t1TrackedObjConfig4.Name = 'FeedItem';
        t1TrackedObjConfig4.Object_Api_Name__c = 'FeedItem';
        t1TrackedObjConfig4.Order_By__c = '';
        t1TrackedObjConfig4.Where__c = '';
        trackedObjConfigList.add(t1TrackedObjConfig4);
        
        TQ_Tracked_Object_Config__c t1TrackedObjConfig5 = new TQ_Tracked_Object_Config__c();
        t1TrackedObjConfig5.Active__c = true;
        t1TrackedObjConfig5.ClientApp_ID__c = 'TquilaONE';
        t1TrackedObjConfig5.Custom_Index_List__c = '';
        t1TrackedObjConfig5.Displayable__c = false;
        t1TrackedObjConfig5.Fieldset_Name_List__c = 'dummyFieldSet';
        t1TrackedObjConfig5.Layout_Needed__c = false;
        t1TrackedObjConfig5.List_Header_Fieldset__c = '';
        t1TrackedObjConfig5.Max_Records_Before_Full_Sync__c = 1000;
        t1TrackedObjConfig5.Name = 'FeedComment';
        t1TrackedObjConfig5.Object_Api_Name__c = 'FeedComment';
        t1TrackedObjConfig5.Order_By__c = '';
        t1TrackedObjConfig5.Where__c = '';
        trackedObjConfigList.add(t1TrackedObjConfig5);
        
        insert trackedObjConfigList;
    }
    
}