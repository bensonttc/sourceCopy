/*----------------------------------------------------------------
*----------TESt class for REST_GetEDocumentsSignedUrl API call-------
------------ for my documents view and download-----------------
*----------Used by MTS----------------------------------------
*-------------------------------------------------------------
*/
@istest() 
global class REST_GetEDocumentsSignedUrl_Tests implements HttpCalloutMock {

    //Declare variables that will be used in test
    private static Account customerPA;
    private static Account customerPA2;
    private static User communityUser;
    private static Passenger__c pass;
    private static Passenger__c pass2;
    private static Passenger_Document__c paxDocuments;
    private static App_Settings__c settings;
   
    //Mocked HTTP Response
    global HTTPResponse respond(HTTPRequest req) {
        settings = App_Settings__c.getValues('mtsApp');
     // Optionally, only send a mock response for a specific endpoint
        System.assertEquals(settings.MMD_URL__c, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setBody('https://mmd.dev.travcorpservices.com/signed/url/FlightItinerary.pdf');
        res.setStatusCode(200);
        return res;
}
     
    /**
    * when user is not autheticated to view my documents
    */
    @isTest(SeeAllData=false)
    static void pageLoadAndUserIsNotAuthenticated (){
       createRecords();
          System.runAs(communityUser){
       Test.startTest();
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = pass2.Id;
       paxDetail.sellingCompanyShortName = 'CHUSAS';
       paxDetail.BookingRef = 'A242440';
       paxDetail.actionType = 'pageLoad';
       paxDetail.documentId= null;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
       Test.stopTest();
       
       system.assert(response.rawRecord.size() == 0);
       system.assertEquals(null, response.leadPassenger);
       system.assertEquals('Failure', response.status);
       system.assertEquals('080', response.errorCode.get(0));
       system.assertEquals('You are not allowed to view or download the documents', response.message.get(0));
      } 
    }
    
    
    /**
    * when passenger Id is null in post request payload
    */
    @isTest(SeeAllData=false)
    static void passengerIdNullInRequest (){
       createRecords();
          System.runAs(communityUser){
       Test.startTest();
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = null;
       paxDetail.sellingCompanyShortName = 'CHUSAS';
       paxDetail.BookingRef = 'A242440';
       paxDetail.actionType = 'pageLoad';
       paxDetail.documentId= null;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
       Test.stopTest();
       
       system.assert(response.rawRecord.size() == 0);
       system.assertEquals(null, response.leadPassenger);
       system.assertEquals('Failure', response.status);
       system.assertEquals('010', response.errorCode.get(0));
       system.assertEquals('you must enter a selected passenger id', response.message.get(0));
      } 
    }
    
    /**
    * when booking reference is null in post request payload
    */
    @isTest(SeeAllData=false)
    static void bookingRefNullInRequest (){
       createRecords();
          System.runAs(communityUser){
       Test.startTest();
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = pass.Id;
       paxDetail.sellingCompanyShortName = 'CHUSAS';
       paxDetail.BookingRef = null;
       paxDetail.actionType = 'pageLoad';
       paxDetail.documentId= null;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
       Test.stopTest();
       
       system.assert(response.rawRecord.size() == 0);
       system.assertEquals(null, response.leadPassenger);
       system.assertEquals('Failure', response.status);
       system.assertEquals('020', response.errorCode.get(0));
       system.assertEquals('you must enter a booking reference', response.message.get(0));
      } 
    }
    
    /**
    * when selling company name  is null in post request payload
    */
    @isTest(SeeAllData=false)
    static void sellingCompanyNullInRequest (){
       createRecords();
          System.runAs(communityUser){
       Test.startTest();
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = pass.Id;
       paxDetail.sellingCompanyShortName = null;
       paxDetail.BookingRef = 'A242440';
       paxDetail.actionType = 'pageLoad';
       paxDetail.documentId= null;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
       Test.stopTest();
       
       system.assert(response.rawRecord.size() == 0);
       system.assertEquals(null, response.leadPassenger);
       system.assertEquals('Failure', response.status);
       system.assertEquals('050', response.errorCode.get(0));
       system.assertEquals('you must enter a selling company short name', response.message.get(0));
      } 
    }
    
    /**
    * when action type is null in post request payload
    */
    @isTest(SeeAllData=false)
    static void actionTypeNullInRequest (){
       createRecords();
          System.runAs(communityUser){
       Test.startTest();
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = pass.Id;
       paxDetail.sellingCompanyShortName = 'CHUSAS';
       paxDetail.BookingRef = 'A242440';
       paxDetail.actionType = null;
       paxDetail.documentId= null;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
       Test.stopTest();
       
       system.assert(response.rawRecord.size() == 0);
       system.assertEquals(null, response.leadPassenger);
       system.assertEquals('Failure', response.status);
       system.assertEquals('030', response.errorCode.get(0));
       system.assertEquals('you must choose a action type', response.message.get(0));
      } 
    }
    
     /**
    * when action type is null in post request payload
    */
    @isTest(SeeAllData=false)
    static void actionTypeSingleButDocumentIdNullInRequest (){
       createRecords();
          System.runAs(communityUser){
       Test.startTest();
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = pass.Id;
       paxDetail.sellingCompanyShortName = 'CHUSAS';
       paxDetail.BookingRef = 'A242440';
       paxDetail.actionType = 'single';
       paxDetail.documentId= null;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
       Test.stopTest();
       
       system.assert(response.rawRecord.size() == 0);
       system.assertEquals(null, response.leadPassenger);
       system.assertEquals('Failure', response.status);
       system.assertEquals('060', response.errorCode.get(0));
       system.assertEquals('you must enter a document id', response.message.get(0));
      } 
    }

    /**
    * testMethod to unit test the function
    */
    @isTest(SeeAllData=false)
    static void pageLoadAndUserIsAuthenticatedAndLeadPasseneger (){
        createRecords();
        System.runAs(communityUser){
       Test.startTest();
      
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = pass.Id;
       paxDetail.sellingCompanyShortName = 'CHUSAS';
       paxDetail.BookingRef = 'A242440';
       paxDetail.actionType = 'pageLoad';
       paxDetail.documentId= null;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
      
       Test.stopTest();
       system.assertEquals(paxDocuments.Id, response.rawRecord[0].documentId);
       system.assertEquals(paxDocuments.Document_Name__c, response.rawRecord[0].documentName);
       system.assertEquals(paxDocuments.Document_Type__c, response.rawRecord[0].documentType);
       system.assertEquals(paxDocuments.Lead_Passenger_Name__c, response.rawRecord[0].leadPassenger);
       system.assertEquals(paxDocuments.Passenger_Name__c, response.rawRecord[0].passengerName);
       system.assertEquals(paxDocuments.Passenger_Number__c, response.rawRecord[0].passengerNumber);
       system.assertEquals(null, response.rawRecord[0].signedURL);
       system.assertEquals(response.status, 'Success');
       system.assertEquals(response.errorCode.get(0), '000');
       system.assertEquals(response.message.get(0), 'Operation successful');
       
        }
       
    }
    
    /**
    * testMethod to unit test the function
    */
    @isTest(SeeAllData=false)
    static void returnSingnedURL (){
        createRecords();
        Test.setMock(HttpCalloutMock.class, new REST_GetEDocumentsSignedUrl_Tests());
        System.runAs(communityUser){
       Test.startTest();
      
       REST_GetEDocumentsSignedUrl.passengerDetails paxDetail = new REST_GetEDocumentsSignedUrl.passengerDetails();
       paxDetail.Id = pass.Id;
       paxDetail.sellingCompanyShortName = 'CHUSAS';
       paxDetail.BookingRef = 'A242440';
       paxDetail.actionType = 'single';
       paxDetail.documentId= paxDocuments.Id;
      
       REST_GetEDocumentsSignedUrl.postMMDJson response = REST_GetEDocumentsSignedUrl.doPost(paxDetail);
      
       Test.stopTest();
       system.assertEquals(paxDocuments.Id, response.rawRecord[0].documentId);
       system.assertEquals(paxDocuments.Document_Name__c, response.rawRecord[0].documentName);
       system.assertEquals(paxDocuments.Document_Type__c, response.rawRecord[0].documentType);
       system.assertEquals(paxDocuments.Lead_Passenger_Name__c, response.rawRecord[0].leadPassenger);
       system.assertEquals(paxDocuments.Passenger_Name__c, response.rawRecord[0].passengerName);
       system.assertEquals(paxDocuments.Passenger_Number__c, response.rawRecord[0].passengerNumber);
       system.assertEquals('https://mmd.dev.travcorpservices.com/signed/url/FlightItinerary.pdf', response.rawRecord[0].signedURL);
       system.assertEquals(response.status, 'Success');
       system.assertEquals(response.errorCode.get(0), '000');
       system.assertEquals(response.message.get(0), 'Operation successful');
       
        }
       
    }
    

      public static void createRecords(){ 
         String firstName = 'Brian', lastName = 'Wlezien', email = 'acn@test.com';
        String identifier = '123882497938247239427394723';
    
         Map<String, String> accountRecordTypeMap = TQSsoRegistrationHandler.getRecordTypeMap('Account');
        customerPA = new Account(
            RecordTypeId = accountRecordTypeMap.get(TQSsoRegistrationHandler.ACCOUNT_RECORD_TYPE_CUSTOMER),
            FirstName = firstName,
            LastName = lastName, 
            PersonEmail = email
        );
        insert customerPA;
        
        customerPA2 = new Account(
            RecordTypeId = accountRecordTypeMap.get(TQSsoRegistrationHandler.ACCOUNT_RECORD_TYPE_CUSTOMER),
            FirstName = firstName,
            LastName = lastName, 
            PersonEmail = email
        );
        insert customerPA2;
     
          List<Account> personAccounts = [Select PersonContactId From Account Where Id = :customerPA.Id];
        customerPA = personAccounts.get(0);

        // Create the user
        communityUser = new User(
            username = TQSsoRegistrationHandler.getUsernamePrefix() + email + TQSsoRegistrationHandler.getUsernameSuffix(),
            email = email,
            lastName = lastName,
            firstName = firstName,
            alias = 'Test34',
            emailencodingkey = 'UTF-8',
            languagelocalekey = 'en_US', 
            localesidkey = 'en_GB', 
            timezonesidkey = 'GMT',
            UserRoleId = null,
            profileId = TQSsoRegistrationHandler.getProfile().Id,
            contactId = customerPA.PersonContactId,
            SSO_Identifier__c = identifier
        );
        insert communityUser;
         
        pass = new Passenger__c();
        pass.Account__c = customerPA.Id;
        pass.User__c = communityUser.Id;
        pass.Passenger_External_Id__c = 'TESTEXTERNALID';
        pass.Name = 'Brian Wlezien';
        pass.Lead_Passenger__c = pass.Id;
        insert pass;
        
        pass2 = new Passenger__c();
        pass2.Account__c = customerPA2.Id ;
        pass2.User__c = communityUser.Id;
        pass2.Passenger_External_Id__c = 'TESTEXTERNALID';
        pass2.Lead_Passenger__c = pass.Id;
        insert pass2;
        
        paxDocuments = new Passenger_Document__c();
        paxDocuments.Booking_Number__c = 'A242440';
        paxDocuments.Document_Name__c  = '003_Ms_C_Wlezien_5_FlightItinerary.pdf';
        paxDocuments.Document_Type__c = 'Flight Itinerary';
        paxDocuments.Document_URL__c = 'https://mmd.dev.travcorpservices.com/FlightItinerary.pdf';
        paxDocuments.Lead_Passenger_Name__c ='Brian Wlezien';
        paxDocuments.Passenger__c = pass.Id;
        paxDocuments.Passenger_Name__c = 'Brian Wlezien';
        paxDocuments.Passenger_Number__c = '001';
        paxDocuments.Selling_Company_Code_Text__c = 'CHUSAS';
        insert paxDocuments;
        
        settings = new App_Settings__c();
        settings.MMD_X_API_header_key__c = '1234567890';
        settings.MMD_URL__c = 'https://mmd/dev.com';
        settings.Name = 'mtsApp';
        settings.ClientApp_ID__c = pass.Id;
        insert settings; 
        
      }
      
}