/**
 *  Test Class for the Download service and endpoint
 */
@isTest
private class TQDownloadTest {
  
  
    /**
    * testMethod to unit test the function "cleanRequest" on the "TQAssignmentEndpoint"
    */
    @isTest(SeeAllData=False)
    static void TQAssignmentEndpoint_Test(){
      Test.startTest();
      String deviceID = 'TestDeviceID';
      String localID = 'LocalID';
            
      TQ_Local_Assignment__c localAssignment = new TQ_Local_Assignment__c();
      localAssignment.Device_Id__c = deviceID;
      localAssignment.Local_Id__c = localID;
      
      String[] recordIdList = new String[1];
      recordIdList[0] = localID;
      TQCommandResponse response = TQAssignmentEndpoint.cleanRequest(recordIdList, deviceID);
      Test.stopTest();
      system.assert(response != null);
    }
    
     /**
    * testMethod to unit test the "TQDownloadEndpoint"
    */
    @isTest(SeeAllData=false)
    static void TQDownloadEndpoint_Test(){
      Test.startTest();

      TQ_Tracked_Object_Config__c setting = new TQ_Tracked_Object_Config__c();
      setting.Name = 'Moment Setting';
      setting.Active__c = true;
      setting.ClientApp_ID__c = TqTestUtils.CLIENT_APP_ID;
      setting.Object_Api_Name__c = 'Moment__c';
      setting.Where__c = 'Name <> null AND OwnerId = $User.Id';
      insert setting;

      TQCommandResponse command = new TQCommandResponse();
      Moment__c moment = TqTestUtils.createMoment('body of the moment...');
      insert moment;
      
      List<TQDownloadRequest> requestItemList = new List<TQDownloadRequest>();
      
      TQDownloadResponse response = TQDownloadEndpoint.downloadRequest(TqTestUtils.CLIENT_APP_ID, requestItemList);
      
      TQDownloadRequest dwReq = new TQDownloadRequest();
      dwReq.setFromDateTime('2013-12-28T13:23:12.459Z');
      //Datetime now = Datetime.now();
      //dwReq.setToDateTime(now.format('yyyy-MM-dd\'T\'HH:mm:ssz'));
      dwReq.setToDateTime('2113-12-28T13:23:12.459Z');
      dwReq.setObjectApiName('Moment__c');
      requestItemList.add(dwReq);

      dwReq = new TQDownloadRequest();
      dwReq.setFromDateTime('2015-01-01T13:23:15.108Z');  
      dwReq.setObjectApiName('Moment__c');
      requestItemList.add(dwReq);

      dwReq = new TQDownloadRequest();
      dwReq.setObjectApiName('Moment__c');
      requestItemList.add(dwReq);
      
      response = TQDownloadEndpoint.downloadRequest(TqTestUtils.CLIENT_APP_ID, requestItemList);
      Test.stopTest();
      system.assert(response != null);
      
      List<TQDownloadResponse.TQDownloadResponseItem> respItems = response.getBody();
      
      system.assertEquals(3, respItems.size());
      system.assertEquals('Moment__c', respItems[0].getObjectApiName());
      system.assertEquals('2013-12-28T13:23:12.459Z', respItems[0].getFromDateTime());
      system.assertEquals('2113-12-28T13:23:12.459Z', respItems[0].getToDateTime());
      system.assert(respItems[0].getQuery() != null);
      system.assertEquals('INC', respItems[0].getSyncType());
      system.assertEquals(1, respItems[0].getRecordCount());
    }
    
    /**
    * testMethod to unit test the "TQDownloadEndpoint"
    */
    @isTest(SeeAllData=false)
    static void TQDownloadEndpointException_Test(){
      Test.startTest();

      TQ_Tracked_Object_Config__c setting = new TQ_Tracked_Object_Config__c();
      setting.Name = 'Moment Setting';
      setting.Active__c = true;
      setting.ClientApp_ID__c = TqTestUtils.CLIENT_APP_ID;
      setting.Object_Api_Name__c = 'Moment__c';
      setting.Where__c = 'Name <> null AND OwnerId = User.Id';
      insert setting;

      TQCommandResponse command = new TQCommandResponse();
      Moment__c moment = TqTestUtils.createMoment('body of the moment...');
      insert moment;
      
      List<TQDownloadRequest> requestItemList = new List<TQDownloadRequest>();
      
      TQDownloadResponse response = TQDownloadEndpoint.downloadRequest(TqTestUtils.CLIENT_APP_ID, requestItemList);
      
      TQDownloadRequest dwReq = new TQDownloadRequest();
      dwReq.setFromDateTime('2013-12-28T13:23:12.459Z');
      //Datetime now = Datetime.now();
      //dwReq.setToDateTime(now.format('yyyy-MM-dd\'T\'HH:mm:ssz'));
      dwReq.setToDateTime('2113-12-28T13:23:12.459Z');
      dwReq.setObjectApiName('Moment__c');
      requestItemList.add(dwReq);

      dwReq = new TQDownloadRequest();
      dwReq.setFromDateTime('2015-01-01T13:23:15.108Z');  
      dwReq.setObjectApiName('Moment__c');
      requestItemList.add(dwReq);

      dwReq = new TQDownloadRequest();
      dwReq.setObjectApiName('Moment__c');
      requestItemList.add(dwReq);
      
      response = TQDownloadEndpoint.downloadRequest(TqTestUtils.CLIENT_APP_ID, requestItemList);
      Test.stopTest();
      system.assert(response != null);
      
      
    }
    
    /**
    * testMethod to unit test the "TQDownloadEndpoint"
    */
    @isTest(SeeAllData=false)
    static void TQDownloadEndpointWrongDateTimeException_Test(){
      Test.startTest();

      TQ_Tracked_Object_Config__c setting = new TQ_Tracked_Object_Config__c();
      setting.Name = 'Moment Setting';
      setting.Active__c = true;
      setting.ClientApp_ID__c = TqTestUtils.CLIENT_APP_ID;
      setting.Object_Api_Name__c = 'Moment__c';
      setting.Where__c = 'Name <> null AND OwnerId = $User.Id';
      insert setting;

      TQCommandResponse command = new TQCommandResponse();
      Moment__c moment = TqTestUtils.createMoment('body of the moment...');
      insert moment;
      
      List<TQDownloadRequest> requestItemList = new List<TQDownloadRequest>();
      
      TQDownloadResponse response = TQDownloadEndpoint.downloadRequest(TqTestUtils.CLIENT_APP_ID, requestItemList);
      
      TQDownloadRequest dwReq = new TQDownloadRequest();
      dwReq.setFromDateTime('2013-12-28T13:23:12.459Z');
      //Datetime now = Datetime.now();
      //dwReq.setToDateTime(now.format('yyyy-MM-dd\'T\'HH:mm:ssz'));
      dwReq.setToDateTime('2113-20-28T13:');
      dwReq.setObjectApiName('Moment__c');
      requestItemList.add(dwReq);
            
      response = TQDownloadEndpoint.downloadRequest(TqTestUtils.CLIENT_APP_ID, requestItemList);
      Test.stopTest();
      system.assert(response != null);
    }
    
    /**
    * testMethod to unit test the "TQDownloadEndpoint"
    */
    @isTest(SeeAllData=false)
    static void TQDownloadSyncType_Test(){
    	
    	String res = TQDownloadSyncType.FULL;
    	res = TQDownloadSyncType.INC;
    	res = TQDownloadSyncType.NONE;
    }
    
    static testMethod void testCustomLogicExtensionBookingComponent(){
    	TQDownloadService downloadService = new TQDownloadService();
    	String newWhereCondition = downloadService.extendSyncWithCustomLogic('Booking_Component__c', 'IsDeleted = false');
    	System.assert(!newWhereCondition.contains('Booking_Component__r.Customer__c'));
    }  
        
    static testMethod void testCustomLogicExtensionItineraryItem(){
    	update new User(Id = UserInfo.getUserId(), Is_Travel_Director__c = true);
    	
    	TQDownloadService downloadService = new TQDownloadService();
    	String whereCondition = 'IsDeleted = false';
    	String newWhereCondition = downloadService.extendSyncWithCustomLogic('Itinerary_Item__c', whereCondition);
    	System.assertEquals(whereCondition, newWhereCondition);
    }
}