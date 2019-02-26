//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_FlightListPDFController_Test
// For Apex Class: TOPS_FlightListPDFController
// For Apex Page: TOPS_FlightListPDF
// Functionality Description: This apex controller is used to generate PDF of flight passengers.
//
// 01st February 2016   Hemendra Singh Bhati   Original (Task # T-467673)
//
@isTest(seeAllData=false)
private class TOPS_FlightListPDFController_Test {
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
    PageReference thePage = Page.TOPS_FlightListPDF;
    Test.setCurrentPage(thePage);

    // Inserting Test Tour Instance.
    Tour_Instance__c theTestTourInstance = theTestDataFactory.createTourInstance('Test Tour','IEW93210', true);       

    // Inserting Test Passengers.
    Integer theCounter = 1;
    //Code changes  by Nishant Singh for 00189158 boolean changed to false
    //Changes Start
    List<Passenger__c> theTestPassengers = new List<Passenger__c> {
      theTestDataFactory.createPassenger('Test Passenger #' + theCounter, theTestTourInstance.Id, false)
    };
    //Code added by Nishant Singh for 00189158
    for(Passenger__c p : theTestPassengers){
        p.Passenger_Class__c='Passenger';
    }
    //Changes End
    insert theTestPassengers;
    

    // Initializing The Page Parameters.
    ApexPages.currentPage().getParameters().put('relatedObjectId', theTestTourInstance.Id);
    ApexPages.currentPage().getParameters().put('fieldSets', theTestTourInstance.Id);

    // Instantiating Flight List PDF Controller.
    TOPS_FlightListPDFController theController = new TOPS_FlightListPDFController();

    // Test Case 1 - Validating Font Size And Total Test Flight Passengers.
    system.assert(
      theController.theFlightPassengersList.size() == 1,
      'Error: The flight list PDF controller failed to fetch flight passengers list.'
    );
    system.assert(
      theController.theFontSize == '14px',
      'Error: The flight list PDF controller failed to set text font size to 14px.'
    );
    
    // Test Case 2 - Inserting 41 More Test Flight Passengers.
    theTestPassengers = new List<Passenger__c>();
    for(Integer index = 1;index <= 41;index++) {
      theCounter++;
      theTestPassengers.add(theTestDataFactory.createPassenger(
        'Test Passenger #' + theCounter,
        theTestTourInstance.Id,
        false
      ));
    }
    //Code added by Nishant Singh for 00189158
    //Code Start
    for(Passenger__c p : theTestPassengers){
        p.Passenger_Class__c='Passenger';
    }
    //Code End
    insert theTestPassengers;
    theController = new TOPS_FlightListPDFController();
    system.assert(
      theController.theFontSize == '13px',
      'Error: The flight list PDF controller failed to set text font size to 13px.'
    );

    // Test Case 3 - Inserting 5 More Test Flight Passengers.
    theTestPassengers = new List<Passenger__c>();
    for(Integer index = 1;index <= 5;index++) {
      theCounter++;
      theTestPassengers.add(theTestDataFactory.createPassenger(
        'Test Passenger #' + theCounter,
        theTestTourInstance.Id,
        false
      ));
    }
    //Code added by Nishant Singh for 00189158
    //Code Start
    for(Passenger__c p : theTestPassengers){
        p.Passenger_Class__c='Passenger';
    }
    //Code End
    insert theTestPassengers;
    theController = new TOPS_FlightListPDFController();
    system.assert(
      theController.theFontSize == '12px',
      'Error: The flight list PDF controller failed to set text font size to 12px.'
    );

    // Test Case 4 - Inserting 5 More Test Flight Passengers.
    theTestPassengers = new List<Passenger__c>();
    for(Integer index = 1;index <= 5;index++) {
      theCounter++;
      theTestPassengers.add(theTestDataFactory.createPassenger(
        'Test Passenger #' + theCounter,
        theTestTourInstance.Id,
        false
      ));
    }
    //Code added by Nishant Singh for 00189158
    //Code Start
    for(Passenger__c p : theTestPassengers){
        p.Passenger_Class__c='Passenger';
    }
    //Code End
    insert theTestPassengers;
    theController = new TOPS_FlightListPDFController();
    system.assert(
      theController.theFontSize == '11px',
      'Error: The flight list PDF controller failed to set text font size to 11px.'
    );

    // Test Case 5 - Inserting 5 More Test Flight Passengers.
    theTestPassengers = new List<Passenger__c>();
    for(Integer index = 1;index <= 5;index++) {
      theCounter++;
      theTestPassengers.add(theTestDataFactory.createPassenger(
        'Test Passenger #' + theCounter,
        theTestTourInstance.Id,
        false
      ));
    }
    //Code added by Nishant Singh for 00189158
    //Code Start
    for(Passenger__c p : theTestPassengers){
        p.Passenger_Class__c='Passenger';
    }
    //Code End
    insert theTestPassengers;
    theController = new TOPS_FlightListPDFController();
    system.assert(
      theController.theFontSize == '10px',
      'Error: The flight list PDF controller failed to set text font size to 10px.'
    );

    // Test Case 6 - Inserting 5 More Test Flight Passengers.
    theTestPassengers = new List<Passenger__c>();
    for(Integer index = 1;index <= 5;index++) {
      theCounter++;
      theTestPassengers.add(theTestDataFactory.createPassenger(
        'Test Passenger #' + theCounter,
        theTestTourInstance.Id,
        false
      ));
    }
    //Code added by Nishant Singh for 00189158
    //Code Start
    for(Passenger__c p : theTestPassengers){
        p.Passenger_Class__c='Passenger';
    }
    //Code End
    insert theTestPassengers;
    theController = new TOPS_FlightListPDFController();
    system.assert(
      theController.theFontSize == '9px',
      'Error: The flight list PDF controller failed to set text font size to 9px.'
    );
    }
}