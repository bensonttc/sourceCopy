//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_RoomListPDFController_Test
// For Apex Class: TOPS_RoomListPDFController
// For Apex Page: TOPS_RoomListPDF
// Functionality Description: This apex controller is used to generate PDF of booked rooms.
//
// 02nd February 2016   Hemendra Singh Bhati   Original (Task # T-465524) - Please see the task description for more details.
// 15th February 2016   Hemendra Singh Bhati   Modified (Task # T-476273) - Please see the task description for more details.
// 01st April 2016      Hemendra Singh Bhati   Modified (Issue # I-209979) - Please see the issue description for more details.
// 12th May 2016      Modified (Issue # I-217956) - Added test for findFirstTII
// 08th November 2016   Ravi Jain              Modified (Case 00182146) - Please see the case description for more details.
//
@isTest(seeAllData=false)
private class TOPS_RoomListPDFController_Test {
  // Private Data Members.
  private static final Id ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Supplier - Hotel').RecordTypeId;
  private static final Map<Integer, Map<String, String>> theBagNumberAndRoomMapping = new Map<Integer, Map<String, String>> {
    1 => new Map<String, String> {
      'Room_Number' => '1',
      'Room_Code' => 'SIG',
      'Room_Type' => 'Single'
    },
    2 => new Map<String, String> {
      'Room_Number' => '2',
      'Room_Code' => 'TWN',
      'Room_Type' => 'Double'
    },
    3 => new Map<String, String> {
      'Room_Number' => '2',
      'Room_Code' => 'TWN',
      'Room_Type' => 'Double'
    },
    4 => new Map<String, String> {
      'Room_Number' => '3',
      'Room_Code' => 'TRP',
      'Room_Type' => 'Triple'
    },
    5 => new Map<String, String> {
      'Room_Number' => '3',
      'Room_Code' => 'TRP',
      'Room_Type' => 'Triple'
    },
    6 => new Map<String, String> {
      'Room_Number' => '3',
      'Room_Code' => 'TRP',
      'Room_Type' => 'Triple'
    },
    7 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Code' => 'QAD',
      'Room_Type' => 'Quad'
    },
    8 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Code' => 'QAD',
      'Room_Type' => 'Quad'
    },
    9 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Code' => 'QAD',
      'Room_Type' => 'Quad'
    },
    10 => new Map<String, String> {
      'Room_Number' => '4',
      'Room_Code' => 'QAD',
      'Room_Type' => 'Quad'
    }
  };

  /**
  * @description  This method validates controller functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void validateControllerFunctionality() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Setting The Current Page.
    PageReference thePage = Page.TOPS_RoomListPDF;
    Test.setCurrentPage(thePage);

    // Inserting Test Supplier Hotel Account.
    Account theSupplier = new Account(
      Name = 'Executive Style Hotel Rome',
      RecordTypeId = ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID
    );
    insert theSupplier;

    // Inserting Test Tour Instance.
    Tour_Instance__c theTestTourInstance = theTestDataFactory.createTourInstance('Test Tour','IEW93210', false);
    theTestTourInstance.Start_Date__c = Date.today();
    insert theTestTourInstance;

    // Instantiating Test Passengers.
    Passenger__c thePassenger = null;
    List<Passenger__c> theTestPassengers = new List<Passenger__c>();
    for(Integer index = 1;index <= 10;index++) {
      thePassenger = theTestDataFactory.createPassenger(
        'Test Passenger #' + index,
        theTestTourInstance.Id,
        false
      );
      thePassenger.Bag_Number__c = String.valueOf(index);
      thePassenger.Actual_Room_ID__c = Integer.valueOf(theBagNumberAndRoomMapping.get(index).get('Room_Number'));
      thePassenger.Room_Type_Booked__c = theBagNumberAndRoomMapping.get(index).get('Room_Code');
      thePassenger.Actual_Room_Type__c = theBagNumberAndRoomMapping.get(index).get('Room_Type');
      thePassenger.Room_Near_Group__c = String.valueOf(Math.round(Math.random() * (10 - 1)) + 1);
      thePassenger.Room_Special_Instructions__c = 'Quiet Room Please.';
      thePassenger.Dietary_Requirements__c = 'Low Carb Food Preferred.';
      thePassenger.First_Name__c = 'Test #' + index;
      thePassenger.Family_Name__c = 'Passenger #' + index;
      thePassenger.Date_of_Birth__c = Date.today();
      thePassenger.Passenger_Class__c = 'Passenger';

      if(thePassenger.Room_Type_Booked__c == 'TWN') {
        thePassenger.Room_Preference__c = 'DBL';
      }

      theTestPassengers.add(thePassenger);
    }

    // Instantiating Tour Director.
    thePassenger = theTestDataFactory.createPassenger(
      'The Tour Director',
      theTestTourInstance.Id,
      false
    );
    thePassenger.Actual_Room_ID__c = null;
    thePassenger.Room_Type_Booked__c = 'SIG';
    thePassenger.Actual_Room_Type__c = 'Single';
    thePassenger.Room_Special_Instructions__c = 'Quiet Room Please.';
    thePassenger.First_Name__c = 'The Tour';
    thePassenger.Family_Name__c = 'Director';
    thePassenger.Date_of_Birth__c = Date.today();
    thePassenger.Passenger_Class__c = 'Tour Director';
    theTestPassengers.add(thePassenger);

    // Instantiating Tour Driver.
    thePassenger = theTestDataFactory.createPassenger(
      'The Tour Driver',
      theTestTourInstance.Id,
      false
    );
    thePassenger.Actual_Room_ID__c = null;
    thePassenger.Room_Type_Booked__c = 'TWN';
    thePassenger.Actual_Room_Type__c = 'Double';
    thePassenger.Room_Special_Instructions__c = 'Quiet Room Please.';
    thePassenger.First_Name__c = 'The Tour';
    thePassenger.Family_Name__c = 'Driver';
    thePassenger.Date_of_Birth__c = Date.today();
    thePassenger.Passenger_Class__c = 'Driver';
    theTestPassengers.add(thePassenger);

    // Instantiating Tour National Guide.
    thePassenger = theTestDataFactory.createPassenger(
      'The Tour National Guide',
      theTestTourInstance.Id,
      false
    );
    thePassenger.Actual_Room_ID__c = null;
    thePassenger.Room_Type_Booked__c = 'TRP';
    thePassenger.Actual_Room_Type__c = 'Triple';
    thePassenger.Room_Special_Instructions__c = 'Quiet Room Please.';
    thePassenger.First_Name__c = 'The Tour National';
    thePassenger.Family_Name__c = 'Guide';
    thePassenger.Date_of_Birth__c = Date.today();
    thePassenger.Passenger_Class__c = 'National Guide';
    theTestPassengers.add(thePassenger);

    // Inserting Test Passengers.
    insert theTestPassengers;

    // Inserting Test Tour Instance Itineraries.
    Tour_Instance_Itinerary__c theTourInstanceItinerary = null;
    List<Tour_Instance_Itinerary__c> theTestTourInstanceItineraries = new List<Tour_Instance_Itinerary__c>();
    for(Integer index = 0;index <= 2;index++) {
      theTourInstanceItinerary = new Tour_Instance_Itinerary__c(
        Tour_Instance__c = theTestTourInstance.Id,
        Supplier__c = theSupplier.Id,
        City__c = 'Rome',
        Arrival_Time__c = '07:00',
        Dinner_Time__c = '20:00',
        Morning_Call_Time__c = '08:00',
        Bags_Time__c = '07:30',
        Depart_Time__c = '10:00',
        Breakfast_time__c = '08:00',
        Day_Number__c = index + 1,
        Component_Type__c = 'Itinerary'
      );

      theTestTourInstanceItineraries.add(theTourInstanceItinerary);
    }
    insert theTestTourInstanceItineraries;

    // Initializing The Page Parameters.
    ApexPages.currentPage().getParameters().put('relatedObjectId', theTestTourInstanceItineraries.get(0).Id);

    // Instantiating Room List PDF Controller.
    TOPS_RoomListPDFController theController = new TOPS_RoomListPDFController();
    /*system.assert(
      theController.totalTwins == 2,
      'Error: The room list PDF controller failed to compute total double rooms.'
    );*/
      
    // Code changes done by Ravi Jain for Case 00182146
    // Code changes start here
      
      system.assert(
      theController.totalTwins == 1,
      'Error: The room list PDF controller failed to compute total double rooms.'
    );  
    // Code changes end here
    
    }
  
  /**
   * @descriptoin This tests to see that the correct TII is returned. This should be the first for that supplier for the given TI
   **/
  private static testMethod void testFindFirstTII() {

    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Create a couple of tour instances
    Map<String, Tour_Instance__c> tourInstanceByName = new Map<String, Tour_Instance__c>();
    tourInstanceByName.put('t1',theTestDataFactory.createTourInstance('Test Tour 1','IEW93210', false));
    tourInstanceByName.put('t2',theTestDataFactory.createTourInstance('Test Tour 2','IEW93210', false));
    insert tourInstanceByName.values();

    // Create a couple of suppliers
    Map<String, Account> suppliersByName = new Map<String, Account>();
    suppliersByName.put('s1',createAccount('supp1'));
    suppliersByName.put('s2',createAccount('supp2'));
    insert suppliersByName.values();

    // Create some tour instance itins for the tour instances
    Map<String, Tour_Instance_Itinerary__c> tourInstItinByName = new Map<String, Tour_Instance_Itinerary__c>();
    tourInstItinByName.put('t1~1',createTourInstanceItin(tourInstanceByName.get('t1').Id,suppliersByName.get('s1').Id,1,'Itinerary'));
    tourInstItinByName.put('t1~2',createTourInstanceItin(tourInstanceByName.get('t1').Id,suppliersByName.get('s1').Id,2,'Itinerary'));
    tourInstItinByName.put('t1~3',createTourInstanceItin(tourInstanceByName.get('t1').Id,suppliersByName.get('s1').Id,3,'Itinerary')); 

    tourInstItinByName.put('t2~3',createTourInstanceItin(tourInstanceByName.get('t2').Id,suppliersByName.get('s1').Id,3,'Something')); // Wrong type
    tourInstItinByName.put('t2~4',createTourInstanceItin(tourInstanceByName.get('t2').Id,suppliersByName.get('s2').Id,4,'Itinerary')); // Wrong supplier
    tourInstItinByName.put('t2~5',createTourInstanceItin(tourInstanceByName.get('t2').Id,suppliersByName.get('s1').Id,5,'Itinerary')); // Should get this since the earlier one are for a different supplier and the wrong type
    tourInstItinByName.put('t2~6',createTourInstanceItin(tourInstanceByName.get('t2').Id,suppliersByName.get('s1').Id,6,'Itinerary')); // Pass in this one
    insert tourInstItinByName.values();

    // Instantiate the controller
    TOPS_RoomListPDFController controller = new TOPS_RoomListPDFController();

    // Start the test
    Test.startTest();

    // Try and get the ID of the first related TII
    Id firstTIIId = controller.findFirstTII(tourInstItinByName.get('t2~6').Id);

    // Stop the test
    Test.stopTest();

    // Confirm that the correct TII has been found
    System.assertEquals(tourInstItinByName.get('t2~5').Id, firstTIIId, tourInstItinByName);

  }

  /*************************** PRIVATE METHODS ******************************/
  private static Tour_Instance_Itinerary__c createTourInstanceItin(Id tourId, Id supplierId, Integer dayNumber, String compType) {
    Tour_Instance_Itinerary__c tii = new Tour_Instance_Itinerary__c ();
    tii.Tour_Instance__c = tourId;
    tii.Supplier__c = supplierId;
    tii.Day_Number__c = dayNumber;
    tii.Component_Type__c = compType;
    return tii;
  }

  private static Account createAccount(String name) {
    Account acc = new Account();
    acc.Name = name;
    return acc;
  }

}