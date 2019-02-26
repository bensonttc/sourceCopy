/**
 * @description This provides test coverage for the TOPS_SupplierRestriction class which is used to get a list of ids of accounts that should be sent to the device
 **/
@isTest
private class TOPS_SupplierRestriction_Test {
    private static Profile sysAdminProfile;
    private static Map<String, Id> accountRecordTypeIdsByName;

    static {
        // Get a map of the record type ids for the Account object
        accountRecordTypeIdsByName = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType='Account']) {
            accountRecordTypeIdsByName.put(rt.DeveloperName, rt.Id);
        }
    }

    /**
     * @description This is used to create standard data for tests
     **/
    private static void init() {
    }

    /**
    * @description Test that when a user accesss the app and trigges the restriction code it returns the correct Ids
    **/
    static testMethod void testSupplierAccountFilter() {
        
        // Create new users with the admin profile for now to be used as owners
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        Map<String, User> usersByName = new Map<String, User>();
        System.runAs ( thisUser ) {
            usersByName.put('td',createUser('Fred','Smith','fred.smith@ttc.test.com'));
            usersByName.put('other',createUser('Other','User','other.user@ttc.test.com'));
            insert usersByName.values();
        }       

        // Create some optional accounts, varing the location, contract status and supplier type
        Id contractedRecordTypeId = accountRecordTypeIdsByName.get('Supplier_Contracted');
        Map<String, Account> testAccountsByName = new Map<String,Account>();
        testAccountsByName.put('exc1',createAccount('exc1',contractedRecordTypeId,'Shop','London','No longer contracted')); // Should be excluded since the status is invalid
        testAccountsByName.put('exc2',createAccount('exc2',contractedRecordTypeId,'Shop','London','Awaiting Contract – Do not use')); // Should be excluded since the status is invalid
        testAccountsByName.put('inc1',createAccount('inc1',contractedRecordTypeId,'Shop','London','Info Only')); 
        testAccountsByName.put('inc2',createAccount('inc2',contractedRecordTypeId,'Local Specialist','London','Awaiting Contract - Approved')); 
        testAccountsByName.put('inc3',createAccount('inc3',contractedRecordTypeId,'Shop','London','Done')); 

        // Exclude because of city and type being blank
        testAccountsByName.put('exc3',createAccount('exc3',contractedRecordTypeId, null,'London','Info Only')); // Excluded because the type is not populated
        testAccountsByName.put('exc4',createAccount('exc4',contractedRecordTypeId,'Shop','New York','Awaiting Contract - Approved')); // Excluded because the city is not valid
        testAccountsByName.put('exc5',createAccount('exc4',contractedRecordTypeId,'Shop','Washington','Awaiting Contract - Approved')); // Excluded because the city is not valid

        // Ensure that the code works with different case values for the city
        testAccountsByName.put('inc4',createAccount('inc4',contractedRecordTypeId,'Shop','LoNdON','Done')); 

        // Add another couple of cities
        testAccountsByName.put('inc5',createAccount('inc5',contractedRecordTypeId,'Services','Paris','Info Only')); 
        testAccountsByName.put('inc6',createAccount('inc6',contractedRecordTypeId,'Shop','Berlin','Awaiting Contract - Approved')); 
        testAccountsByName.put('inc7',createAccount('inc7',contractedRecordTypeId,'Optional','Paris','Done')); 

        // Create some hotels 
        Id hotelRecordTypeId = accountRecordTypeIdsByName.get('Supplier_Hotel');
        testAccountsByName.put('parishotel',createAccount('parishotel',hotelRecordTypeId,'Services','Paris','Info Only')); 
        testAccountsByName.put('berlinhotel',createAccount('berlinhotel',hotelRecordTypeId,'Shop','Berlin','Awaiting Contract - Approved')); 
        testAccountsByName.put('exc_parishotel2',createAccount('exc_parishotel2',hotelRecordTypeId,'Optional','Paris','Done')); // This will be exluded since we wont link anything to it

        // Create some Restaurants 
        Id restaurantRecordTypeId = accountRecordTypeIdsByName.get('Supplier_Restaurant');
        testAccountsByName.put('parisRestaurant',createAccount('parisRestaurant',restaurantRecordTypeId,null,'Paris','Info Only')); 
        testAccountsByName.put('berlinRestaurant',createAccount('berlinRestaurant',restaurantRecordTypeId,null,'Berlin','Awaiting Contract - Approved')); 
        testAccountsByName.put('exc_parisRestaurant2',createAccount('exc_parisRestaurant2',restaurantRecordTypeId,null,'Paris','Info Only')); // This will be exluded since we wont link anything to it

        // Insert the accounts
        insert testAccountsByName.values();

        // Create a future start and end date
        Date startDate = Date.today().addMonths(3);
        Date endDate = Date.today().addMonths(4);

        // Create some tour instances and allocate 2 to the test TD and 1 to the other user
        Map<String, Tour_Instance__c> tourInstanceByName = new Map<String, Tour_Instance__c>();
        tourInstanceByName.put('td_tour_1', createTourInstance('123','456',usersByName.get('td').Id, startDate, endDate));
        tourInstanceByName.put('td_tour_2', createTourInstance('123','456',usersByName.get('td').Id, startDate, endDate));
        tourInstanceByName.put('other_tour', createTourInstance('123','456',usersByName.get('other').Id, startDate, endDate));
        insert tourInstanceByName.values();
        
        List<Tour_Instance__c> tiList = [SELECT Id, Process_Status__c FROM Tour_Instance__c];
        for(Tour_Instance__c ti : tiList){
            ti.Process_Status__c = 'Process Completed';
        }
        update tiList;

        // Create some Tour_Instance_Itinerary__c records for the restaraunts and hotels
        List<Tour_Instance_Itinerary__c> testTIIs = new List<Tour_Instance_Itinerary__c>();
        testTIIs.add(createTourInstanceItinerary(tourInstanceByName.get('td_tour_1').Id, testAccountsByName.get('parishotel').Id, null));
        testTIIs.add(createTourInstanceItinerary(tourInstanceByName.get('td_tour_1').Id, testAccountsByName.get('berlinRestaurant').Id, null));
        testTIIs.add(createTourInstanceItinerary(tourInstanceByName.get('td_tour_2').Id, testAccountsByName.get('berlinhotel').Id, null));
        testTIIs.add(createTourInstanceItinerary(tourInstanceByName.get('td_tour_2').Id, testAccountsByName.get('parisRestaurant').Id, null));
        testTIIs.add(createTourInstanceItinerary(tourInstanceByName.get('other_tour').Id, testAccountsByName.get('exc_parishotel2').Id, null)); // Not included since this is for another TD
        testTIIs.add(createTourInstanceItinerary(tourInstanceByName.get('other_tour').Id, testAccountsByName.get('exc_parisRestaurant2').Id, null)); // Not included since this is for another TD
        insert testTIIs;

        // Create an optional that the Tour Optionals can be linked to
        Map<String, Optional__c> optionalByCity = new Map<String, Optional__c>();
        optionalByCity.put('London',new Optional__c(name='Test Optional 1',Location__c='London'));
        optionalByCity.put('Paris',new Optional__c(name='Test Optional 2',Location__c='Paris'));
        optionalByCity.put('Berlin',new Optional__c(name='Test Optional 3',Location__c='Berlin'));
        optionalByCity.put('New York',new Optional__c(name='Test Optional 2',Location__c='New York'));
        optionalByCity.put('Washington',new Optional__c(name='Test Optional 3',Location__c='Washington'));      
        insert optionalByCity.values();

        // Create some tour optionals which will be used to extract the cities which in turn will find optional suppliers
        List<Tour_Optional__c> tourOptionals = new List<Tour_Optional__c>();
        tourOptionals.add(createTourOptional('Trip 1',tourInstanceByName.get('td_tour_1').Id,optionalByCity.get('London').Id,null));
        tourOptionals.add(createTourOptional('Trip 2',tourInstanceByName.get('td_tour_1').Id,optionalByCity.get('Paris').Id,null));
        tourOptionals.add(createTourOptional('Trip 3',tourInstanceByName.get('td_tour_2').Id,optionalByCity.get('Berlin').Id,null));
        tourOptionals.add(createTourOptional('Trip 4',tourInstanceByName.get('other_tour').Id,optionalByCity.get('New York').Id,null)); 
        tourOptionals.add(createTourOptional('Trip 5',tourInstanceByName.get('other_tour').Id,optionalByCity.get('Washington').Id,null));   
        insert tourOptionals;

        // Start the test
        Test.startTest();

        // Run as the TD user
        Set<Id> supplierIds;
        System.runAs(usersByName.get('td')) {
            // Create a new restriction
            TOPS_SupplierRestriction supplierRestriction = new TOPS_SupplierRestriction();
            supplierIds = supplierRestriction.returnRestrictedIds(null);

        }

        // Stop the test
        Test.stopTest();

        // Test the number of supplier ids that have been returned. This should be the optionals in the correct cities with status (7) etc plus the hotels and resteraunts in use (4)
        System.assertEquals(11, supplierIds.size());

        // Get the found accounts and check that none are tyhe excluded ones
        List<Account> selectedSuppliers = [SELECT Id, Name FROM Account WHERE Id IN:supplierIds];
        for (Account ac : selectedSuppliers) {
            System.assertNotEquals(null, ac.Name);
            System.assert(ac.Name.startsWith('exc') == false, 'Invalid supplier : ' + ac);
        }

    }
    
    /********************** PRIVATE METHODS ****************************/
    private static Tour_Instance_Itinerary__c createTourInstanceItinerary(Id tourId, Id supplierId, String city) {
        Tour_Instance_Itinerary__c tii = new Tour_Instance_Itinerary__c ();
        tii.Tour_Instance__c = tourId;
        tii.Supplier__c = supplierId;
        tii.City__c = city;
        return tii;
    }

    private static Tour_Optional__c createTourOptional(String name, Id tourId, Id optionalId, Id supplierId) {
        Tour_Optional__c tourOpt = new Tour_Optional__c();
        tourOpt.Name = name;
        tourOpt.Tour_Instance__c = tourId;
        //tourOpt.Location__c = city;
        tourOpt.Optional__c = optionalId;
        tourOpt.Supplier__c = supplierId;
        return tourOpt;
    }

    private static Account createAccount(String name, Id recordTypeId, String supplierType, String city, String contractStatus) {
        Account acc = new Account();
        acc.Name = name;
        acc.RecordTypeId = recordTypeId;
        acc.Supplier_Type__c = supplierType;
        acc.Supplier_City__c = city;
        acc.Contract_Status__c = contractStatus;
        return acc;
    }

    private static Tour_Instance__c createTourInstance(String departCode, String operatingCode, Id ownerId, Date startDate, Date endDate) {
        Tour_Instance__c ti = new Tour_Instance__c();
        ti.Departure_Code__c = departCode;
        ti.Operating_Product_Code__c = operatingCode;
        ti.OwnerId = ownerId;
        ti.Start_Date__c = startDate;
        ti.End_Date__c = endDate;
        ti.Trip_Status__c = 'Allocated';
        return ti;
    }

    /**
     * @description This creates a test user
     **/
    private static User createUser(String firstName, String lastName, String email) {
        String uniqueness = DateTime.now()+':'+Math.random();

        // Get the admin profile
        if (sysAdminProfile == null) {
            sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        }

        // Create the user
        User u = new User();
        u.Alias = (lastName + firstName).substring(0,7);
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = sysAdminProfile.Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.username = UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg';

        return u;
    }


}