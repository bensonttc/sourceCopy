// Leo Alves - commenting out legacy code on behalf of Fergal
@isTest
private class TQTourInstanceTriggerHandlerTest {
    
    
    private static testmethod void test_populateTravelDirectorLookup()
    {
        // Create tdUser
        User tdUser = TQTestUtils.getUser('Salesforce', 'Interface');
        Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', tdUser.Id, 'opeProCode123', 'departureCode234',
        Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
        insert tourInstance;
        
        String firstName = 'Nick', lastName = 'Tquila', email = 'nicola@tquila.com', username = 'nic1231242@tquila.com.121244';

        // Create tdAccount
        Account tdAccount = TQTestUtils.createAccount(firstname, lastname, email);
        tdaccount.User__c = tdUser.id;
        insert tdAccount;
        
        tourInstance.Allocated_Td__c = tdAccount.Id;
        update tourInstance;
        
        System.assertEquals(tdAccount.User__c, tourInstance.Travel_Director__c);
        
    }
    /**
    *   New TourInstance, new TD
    */
    //@IsTest(SeeAllData=true)
    /*static void testFirstTD() {
        String firstName = 'Nick', lastName = 'Tquila', email = 'nicola@tquila.com', username = 'nic1231242@tquila.com.121244';

        // Create tdAccount
        Account tdAccount = TQTestUtils.createAccount(firstname, lastname, email);
        insert tdAccount;

        // Create tdUser
        User tdUser = TQTestUtils.getUser('Salesforce', 'Interface');
        
        if(tdUser != null) {
            // Create tour instance
            Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', tdUser.Id, 'opeProCode123', 'departureCode234',
                Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
            insert tourInstance;

            // Check TD can see the record
            List<Tour_Instance__Share> tourInstanceShares = [ SELECT UserOrGroupId FROM Tour_Instance__Share WHERE ParentId = :tourInstance.Id];
            Set<Id> userOnTour = new Set<Id>();
            for(Tour_Instance__Share tourInstanceShare : tourInstanceShares) {
                userOnTour.add(tourInstanceShare.UserOrGroupId);
            }
            System.assert(userOnTour.contains(tdUser.Id));

            // Check TD is following the record
            List<EntitySubscription> existingSubscriptions = [SELECT SubscriberId FROM EntitySubscription WHERE ParentId = :tourInstance.Id];
            Set<Id> followers = new Set<Id>();
            for(EntitySubscription existingSubscription : existingSubscriptions) {
                followers.add(existingSubscription.SubscriberId);
            }
            System.assert(followers.contains(tdUser.Id));
        }
    }*/

    /**
    *   Updating a TourInstance with a new TD
    */
    //@IsTest(SeeAllData=true)
    /*static void testReplaceTD() {
        String firstName = 'Nick', lastName = 'Tquila', email = 'nicola@tquila.com', username = 'nic1231242@tquila.com.121244';

        // Create tdAccount
        Account tdAccount = TQTestUtils.createAccount(firstname, lastname, email);
        insert tdAccount;

        // Create tdUser
        User tdUser = TQTestUtils.getUser('Salesforce', 'Interface');
        
        if(tdUser != null) {

            // Create tour instance
            Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', tdUser.Id, 'opeProCode123', 'departureCode234',
                Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
            insert tourInstance;

            String usernameTwo = 'nic1231242@tquila.com.1123131324';

            // Create tdAccount
            Account tdAccountTwo = TQTestUtils.createAccount(firstname, lastname, email);
            insert tdAccountTwo;

            // Create tdUser
            User tdUserTwo = TQTestUtils.getUser('Data', 'Integration');

            tourInstance.Travel_Director__c = tdUserTwo.Id;
            update tourInstance;

            // Check TD can see the record
            List<Tour_Instance__Share> tourInstanceShares = [ SELECT UserOrGroupId FROM Tour_Instance__Share WHERE ParentId = :tourInstance.Id];
            Set<Id> userOnTour = new Set<Id>();
            for(Tour_Instance__Share tourInstanceShare : tourInstanceShares) {
                userOnTour.add(tourInstanceShare.UserOrGroupId);
            }
            System.assert(!userOnTour.contains(tdUser.Id));
            System.assert(userOnTour.contains(tdUserTwo.Id));

            // Check TD is following the record
            List<EntitySubscription> existingSubscriptions = [SELECT SubscriberId FROM EntitySubscription WHERE ParentId = :tourInstance.Id];
            Set<Id> followers = new Set<Id>();
            for(EntitySubscription existingSubscription : existingSubscriptions) {
                followers.add(existingSubscription.SubscriberId);
            }
            System.assert(followers.contains(tdUserTwo.Id));
        }
    }*/
    // Private Data Members.
  private static final Id ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Business Unit').RecordTypeId;
  private static final Map<Integer, Map<String, String>> theBagNumberAndRoomMapping = new Map<Integer, Map<String, String>> {
    1 => new Map<String, String> {
      'Room_Number' => '1',
      'Room_Type' => 'Single'
    },
    2 => new Map<String, String> {
      'Room_Number' => '2',
      'Room_Type' => 'Double'
    },
    3 => new Map<String, String> {
      'Room_Number' => '2',
      'Room_Type' => 'Double'
    },
    4 => new Map<String, String> {
      'Room_Number' => '3',
      'Room_Type' => 'Triple'
    },
    5 => new Map<String, String> {
      'Room_Number' => '3',
      'Room_Type' => 'Triple'
    },
    6 => new Map<String, String> {
      'Room_Number' => '3',
      'Room_Type' => 'Triple'
    },
    7 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Type' => 'Quad'
    },
    8 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Type' => 'Quad'
    },
    9 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Type' => 'Quad'
    },
    10 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Type' => 'Quad'
    }
  };

  /**
  * @description  This method validates tour instance trigger handler functionality.
  *
  * @param        void
  * @return       void
  */
    private static testMethod void validateTriggerHandlerFunctionality() {
        // Instantiating Test Data Factory Class.
        TestDataFactory theTestDataFactory = new TestDataFactory();

        // Inserting Test Selling Company Account.
        Account theTestSellingCompany = new Account(
          Name = 'Test Selling Company',
          RecordTypeId = ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID
        );
        insert theTestSellingCompany;

        // Inserting Test Tour Instance.
        Tour_Instance__c theTestTourInstance = theTestDataFactory.createTourInstance('Test Tour','IEW93210', false);
        theTestTourInstance.Start_Date__c = Date.today();
        insert theTestTourInstance;

        // Inserting Test Booking.
        Booking__c theTestBooking = new Booking__c(
          Name = 'Test Booking',
          Selling_Company__c = theTestSellingCompany.Id
        );
        insert theTestBooking;

        // Inserting Test Booking Passenger.
        Booking_Passenger__c theTestBookingPassenger = new Booking_Passenger__c(
          Name = 'Test Booking Passenger',
          Booking__c = theTestBooking.Id
        );
        insert theTestBookingPassenger;

        // Inserting Test Booking Component.
        Booking_Component__c theTestBookingComponent = new Booking_Component__c(
          Name = 'Test Booking Component',
          Booking_Passenger__c = theTestBookingPassenger.Id,
          Status__c = 'CF'
        );
        insert theTestBookingComponent;

    // Instantiating Test Passengers.
        Passenger__c thePassenger = null;
        List<Passenger__c> theTestPassengers = new List<Passenger__c>();
        for(Integer index = 1;index <= 10;index++) {
          thePassenger = theTestDataFactory.createPassenger(
            'Test Passenger #' + index,
            theTestTourInstance.Id,
            false
          );
          thePassenger.Booking_Component__c = theTestBookingComponent.Id;
          thePassenger.Bag_Number__c = String.valueOf(index);
          thePassenger.Actual_Room_ID__c = Integer.valueOf(theBagNumberAndRoomMapping.get(index).get('Room_Number'));
          thePassenger.Actual_Room_Type__c = theBagNumberAndRoomMapping.get(index).get('Room_Type');
          thePassenger.Room_Near_Group__c = String.valueOf(Math.round(Math.random() * (10 - 1)) + 1);
          thePassenger.Room_Special_Instructions__c = 'Quiet Room Please.';
          thePassenger.Dietary_Requirements__c = 'Low Carb Food Preferred.';
          thePassenger.First_Name__c = 'Test #' + index;
          thePassenger.Family_Name__c = 'Passenger #' + index;
          thePassenger.Date_of_Birth__c = Date.today();
          thePassenger.Passenger_Class__c = 'Passenger';

          theTestPassengers.add(thePassenger);
        }

        // Inserting Test Passengers.
        insert theTestPassengers;

        // Updating Test Tour Instance.
        theTestTourInstance.ActualRoomTrigger__c = Label.Fire;
        update theTestTourInstance;
        system.assert(
          [SELECT ActualRoomTrigger__c FROM Tour_Instance__c WHERE Id = :theTestTourInstance.Id].ActualRoomTrigger__c == Label.Complete,
          'Error: The tour instance trigger handler failed to process the related passenger records.'
        );
    }
    
}