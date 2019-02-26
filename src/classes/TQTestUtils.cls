@IsTest
public with sharing class TQTestUtils {    

    public final static String COMMUNITY_NAME = 'TTC';
    public static final String ACCOUNT_RECORD_TYPE_CUSTOMER = 'Customer';
    public static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business Unit';
    public final static String CLIENT_APP_ID = 'guestApp';
    public static final String CUSTOMER_PROFILE_NAME = 'MTS Guest User';//'TTC Guest User (CC Plus)'; 

    /* 
     *  Create Account
     */
    public static Account createAccount(String name) {
        Account account = new Account(Name = name);

        return account;
    }
    
    
    public static Integer roundInteger(){
    	return Math.round(Math.random() * 1000000);
    }

    /* 
     *  Create Account
     */
    public static Account createAccount(String firstname, String lastname, String email) {
        Map<String, String> accountRecordTypeMap = getRecordTypeMap('Account');
        Account account = new Account(
            FirstName = firstName,
            LastName = lastName, 
            RecordTypeId = accountRecordTypeMap.get(ACCOUNT_RECORD_TYPE_CUSTOMER),
            Email__c = email);
        
        return account;
    }

    /* 
     *  Create Business Account, without parent
     */
    public static Account createBusinessAccount(String name, String email) {
        return createBusinessAccount(name, email, null);
    }

    /* 
     *  Create Business Account
     */
    public static Account createBusinessAccount(String name, String email, Account parent) {
        Map<String, String> accountRecordTypeMap = getRecordTypeMap('Account');
        Account account = new Account(
            Name = name,
            RecordTypeId = accountRecordTypeMap.get(ACCOUNT_RECORD_TYPE_BUSINESS),
            Email__c = email
        );
        if(parent != null) {
            account.ParentId = parent.Id;
        }
        
        return account;
    }

    /* 
     *  Create a Booking
     */
    public static Booking__c createBooking(Account business, String name) {
        return new Booking__c(
            Name = name,
            External_ID__c = name,
            Selling_Company__c = business.Id,
            Status__c = 'CO'
        );
    }

    /* 
     *  Create a Booking Passenger
     */
    public static Booking_Passenger__c createBookingPassenger(Booking__c booking, Account customer, String firstName, String lastName) {
        return new Booking_Passenger__c(
            Booking__c = booking.Id,
            Customer__c = customer.Id,
            First_Name__c = firstName,
            Last_Name__c = lastName
        );
   }

    /* 
     *  Create a Tour Product
     */
    public static Tour_Product__c createProduct(String tourName, String operatingProductCode) {
        return new Tour_Product__c(
                Name = tourName,
                Operating_Product_Code__c = operatingProductCode
            );
    }

    /* 
     *  Create a Booking Component
     */
    public static Booking_Component__c createBookingComponent(Booking__c booking, 
            Booking_Passenger__c passenger, Tour_Product__c product, String departureCode, Date startDate, Date endDate) {
        return new Booking_Component__c(
            Booking_Number__c = booking.Id,
            Booking_Passenger__c = passenger.Id,
            Status__c = 'CF',
            Product__c = product.Id,
            Departure_Code__c = departureCode,
            Start_Date__c = startDate,
            End_Date__c = endDate
        );
    }

    /* 
     *  Create List of Accounts
     */
    public static List<Account> createAccounts(Integer i) {
        List<Account> res = new List<Account>();
        for(Integer j = 0; j < i; j++){
            res.add(createAccount('Account'+j));
        }
        return res;
    }

    /* 
     *  Create ticket
     */
    public static Case createTicket(Contact contact) {
        Case ticket = new Case();
        if(contact != null) {
            ticket.ContactId = contact.Id;
        }
        
        return ticket;
    }
  
    /*
     * Create Opportunity
     */
    public static Opportunity buildOpportunity() {
        
        Account account = new Account(Name = 'Test Company');
        insert account;
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opp';
        opp.accountid = account.id;
        opp.closedate = date.today();
        opp.stagename = 'Prospecting';
        
        return opp;
    }
    
    /*
     *  Create attachment
     */
    public static Attachment createAttachment(Id parentId) {
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = 'test';
        attachment.Body = Blob.valueOf('testBody');
        
        return attachment;
    }

    /*
     *  Create feed item
     */
    public static FeedItem createFeedItem() {
        return createFeedItem(null);
    }
    public static FeedItem createFeedItem(Id parentId) {
        FeedItem feedItem = new FeedItem();
        feedItem.ContentFileName = 'testing';
        feedItem.ContentData = Blob.valueOf('testBody');
        feedItem.Body = 'Testing feed items';
        if(parentId != null) {
            feedItem.ParentId = parentId;
        }
        
        return feedItem;
    }    
    
    /*
     *  Create contact
     */
    public static Contact createContact(String firstName, String lastName, String email) {
        return createContact(firstName, lastName, email, null);
    }

    /*
     *  Create contact
     */
    public static Contact createContact(String firstName, String lastName, String email, Id accountId) {
        Contact contact = new Contact();
        contact.firstName = firstName;
        contact.lastName = lastName;
        contact.Email = email;
        
        if(accountId != null) {
            contact.AccountId = accountId;
        }
        
        return contact;
    }

    /*
     *  Create Moment
     */
    public static Moment__c createMoment(String body) {
        Moment__c moment = new Moment__c();
        moment.Type__c = 'Note';
        moment.Body__c = body;
        
        return moment;
    }

    /*
     *  Create User
     */
    public static User createUser(String personAccountId, String firstName, String lastName, String username, String email) {
        List<Account> personAccounts = [Select PersonContactId From Account Where Id = :personAccountId];
        if(personAccounts == null || personAccounts.size() == 0) {
            return null;
        } else {
            String personContactId = personAccounts.get(0).PersonContactId;
            String profileName = CUSTOMER_PROFILE_NAME;

            List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
            Profile customerProfile = profiles != null && profiles.size() > 0 ? profiles.get(0) : null; 

            return (customerProfile != null) 
                ? new User(
                    firstName = firstName,
                    lastName = lastName,
                    username = username,
                    email = email,
                    alias = userName.substring(0, 7),
                    emailencodingkey = 'UTF-8',
                    languagelocalekey = 'en_US', 
                    localesidkey = 'en_GB', 
                    timezonesidkey = 'GMT',
                    ProfileId = customerProfile.Id,
                    ContactId = personContactId
                )
                : null;
        }
    }

    /*
     *  Create a TD
     */
    public static User createTDUser(String firstName, String lastName, String username, String email) {
        List<Profile> profiles = [SELECT Id FROM Profile LIMIT 1];
        Profile customerProfile = profiles != null && profiles.size() > 0 ? profiles.get(0) : null; 

        return (customerProfile != null) 
            ? new User(
                firstName = firstName,
                lastName = lastName,
                username = username,
                email = email,
                alias = userName.substring(0, 7),
                emailencodingkey = 'UTF-8',
                languagelocalekey = 'en_US', 
                localesidkey = 'en_GB', 
                timezonesidkey = 'GMT',
                ProfileId = customerProfile.Id,
                Is_Travel_Director__c = true
            )
            : null;
    }

    /*
     *  Get the Community ID
     */
    public static Id getCommunityID() {
        Network n = [Select Id from Network Where Name = :COMMUNITY_NAME];
        return n != null ? n.Id : null;
    }
    
    /*
     * Create a list of TQUploadRequestItem for tetsing BatchDml option
     */
    public static List<TQUploadRequestItem> createTQUploadRequestItemList(Integer i){
        List<TQUploadRequestItem> res = new List<TQUploadRequestItem>();
        
        for(Integer j = 0; j < i; j++){
            res.add(new TQUploadRequestItem(
                'Contact', 'Local_Id_'+j,
                '{"Id" : "Local_Id_'+j+'", "Name" : "Name'+j+'", "LastName": "Surname'+j+'", "AccountId" : "Local_Id"}'
            ));
        }
        
        return res;
    }
    
    /*
     * Create a list of TQUploadRequestItem from list of sObjects, should be list of inserted objects for delete or update
     * params = '"IsDeleted" : true'
     */
    public static List<TQUploadRequestItem> createTQUploadRequestItemList(List<SObject> objList, String objectType, String params){
        List<TQUploadRequestItem> res = new List<TQUploadRequestItem>();
        
        for(SObject o : objList){
            res.add(new TQUploadRequestItem(
                objectType, String.valueOf(o.get('Id')),
                '{"Id" : "' + o.get('Id') + '", '+ params +'}'
            ));
        }
        
        return res;
    }

    /*
     * Prepare the custom settings
     *
     */
    public static list<TQ_Tracked_Object_Config__c> createTrackedObjConfigCustomSettings() {
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
        
        return trackedObjConfigList;
    }
    
    /*
     * get the record type of an object
     */
    public static Map<String, String> getRecordTypeMap(String objectApiName) {
        Map<String,String> accountRecordTypesMap = new Map<String,String>{};
        
        for(RecordType rt : [Select Name, Id From RecordType where sObjectType=:objectApiName and isActive=true]) {
            accountRecordTypesMap.put(rt.Name, rt.Id);
        }
        return accountRecordTypesMap;
    }

    /*
     * Create Tour Instance
     */
    public static Tour_Instance__c createTourInstance(String name, Id tdId, String operatingProductCode, String departureCode, Date startDate, Date endDate, Boolean reverse) {
        Tour_Instance__c tourInstance = new Tour_Instance__c();
        tourInstance.Start_Date__c = startDate;
        tourInstance.End_Date__c = endDate;
        tourInstance.Reverse_Itinerary__c = reverse;
        tourInstance.Operating_Product_Code__c = operatingProductCode;
        tourInstance.Departure_Code__c = departureCode;

        if(tdId != null) {
            tourInstance.Travel_Director__c = tdId;
        }

        return tourInstance;
    }

    public static User getUser(String firstName, String lastName) {
        List<User> tdUsers = [Select Id from User WHERE FirstName = :firstName and LastName = :lastName];
        return tdUsers != null && tdUsers.size() > 0 ? tdUsers.get(0) : null;
    }
    
    public static Account createPersonAccount(){
    	RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = :ACCOUNT_RECORD_TYPE_CUSTOMER and SObjectType = 'Account'];
		Account newPersonAccount = new Account();
		newPersonAccount.FirstName = 'Fred Test ' + roundInteger();
 		newPersonAccount.LastName = 'Smith Test ' + roundInteger();
 		newPersonAccount.RecordType = personAccountRecordType;
 		insert newPersonAccount;
 		return newPersonAccount;
    }
    
    public static Passenger__c createPassengerWithAllRelatedObjects(Tour_Instance__c relatedTourInstance){
    	Account personAccount = createPersonAccount();
    	User communityUser = createUser(personAccount.Id, 
    							personAccount.FirstName, 
    							personAccount.LastName, 
    							'testemail.user' + roundInteger() + '@test.com', 
    							'testemail.user' + roundInteger() + '@test.com');
    							
    	insert communityUser;
    	
    	Account sellingCompany = createBusinessAccount('CHTEST-' + roundInteger(), 'test@test.test');
    	insert sellingCompany;
    	    	
    	Booking__c testBooking = createBooking(sellingCompany, 'TestBooking' + roundInteger());
    	insert testBooking;
    	
    	    	
    	Tour_Product__c testProduct = createProduct('TestProduct', '' + roundInteger());
    	insert testProduct;
    	
    	Booking_Passenger__c testBookingPassenger = createBookingPassenger(testBooking, 
    					personAccount, personAccount.FirstName, personAccount.LastName);
    	insert testBookingPassenger;
    	    	
    	Booking_Component__c testBookingComponent = createBookingComponent(testBooking, 
            testBookingPassenger, 
            testProduct, 
            'TST', 
            Date.today().addDays(-10), 
            Date.today().addDays(10));
            
        insert testBookingComponent;
    	
    	Passenger__c resultPassenger = new Passenger__c(
    		Account__c = personAccount.Id,
    		User__c = communityUser.Id,
    		Tour_Product__c = testProduct.Id,
    		Booking_Passenger__c = testBookingPassenger.Id,
    		Booking_Component__c = testBookingComponent.Id,
    		Passenger_External_Id__c = 'PS-' + roundInteger()
    	);
    	
    	if (relatedTourInstance != null){
    		resultPassenger.Tour_Instance__c = relatedTourInstance.Id;
    	}
    	
    	return resultPassenger;
    }

	public static CollaborationGroup createTestCollaborationGroup(){
    	return new CollaborationGroup(
  			Name = 'TestGroup-' + Math.round(Math.random()*70000),
  			IsArchived = true,
  			NetworkId = getCommunityID(),
  			CollaborationType = 'Private'
  		);
    }
}