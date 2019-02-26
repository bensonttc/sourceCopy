//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_LostInCityPDFController_Test
// For Apex Class: TOPS_LostInCityPDFController
// Description: Used to generate passenger pdf.
//
// 28th January 2016    Vinod Kumar             Original (Task # T-467663)
// 16th March 2016      Hemendra Singh Bhati    Modified (Issue # I-207524) - Code Refactored, Indented And Added Comments.
//                                                                            Also Added System.assert Calls.
//
@isTest(seeAllData=false)
private class TOPS_LostInCityPDFController_Test {
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  static testMethod void testLostInCityPDFController() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Tour Product.
    Tour_Product__c theTestTourProduct = new Tour_Product__c(
      Name = 'AA34FE21',
      Product_Name__c = 'Test Product Name'
    );
    insert theTestTourProduct;

    // Inserting Test Tour Instance.
    Tour_Instance__c theTestTourInstance = theTestDataFactory.createTourInstance('Test Tour', 'Abcd', false);
    theTestTourInstance.Start_Date__c = Date.today();
    theTestTourInstance.Tour_Product__c = theTestTourProduct.Id;
    theTestTourInstance.Operating_Product_Code__c = 'TE';
    insert theTestTourInstance;

    // Inserting Test Account.
    Account theTestAccount = new Account(
      FirstName = 'Test',
      LastName = 'Account',
      BillingStreet = 'Test Street',
      BillingCity = 'Test City',
      BillingPostalCode = 'Test Code',
      BillingState = 'Test State',
      BillingCountry = 'Test Country'
    );
    insert theTestAccount;
       
    // Inserting Test Tour Instance Itinerary
    Tour_Instance_Itinerary__c tii = theTestDataFactory.createTourInstanceItinerary(theTestAccount.id, theTestTourInstance.id, false);
    tii.Component_Type__c  = 'Hotel';
    insert tii;

    // Instantiating Test Tour Passengers List.
    List<Passenger__c> theTestTourPassangers = new List<Passenger__c>();

    // Inserting Test Tour Passenger.
    Passenger__c theTestTourPassenger = theTestDataFactory.createPassenger('Test Passanger', theTestTourInstance.Id, false);
    theTestTourPassenger.Email_Share_Opt_In__c = true;
    theTestTourPassangers.add(theTestTourPassenger);
    insert theTestTourPassangers;

    // Setting Up Current Visualforce Page.
    PageReference passPage = Page.TOPS_PassengerListPDF;
    Test.setCurrentPage(passPage);

    // Initializing Current Page Parameters.
    ApexPages.currentPage().getParameters().put('relatedObjectId', theTestTourInstance.Id);
    ApexPages.currentPage().getParameters().put('fieldSets', theTestTourInstance.Id);
    ApexPages.currentPage().getParameters().put('Parameters' , 'V2');
    ApexPages.currentPage().getParameters().put('processingData' , '{"modules":["NONMOD"],"modular":"No","booking":"New"}');

    // Validating Apex Controller Functionality.
    TOPS_LostInCityPDFController theController = new TOPS_LostInCityPDFController();
    system.assert(
      theController.tourRecord != null,
      'Error: The apex controller class named "TOPS_LostInCityPDFController" failed to determine tour record record.'
    );

    // Test Case 1 - Inserting 42 Test Tour Passengers.
    Passenger__c theTestPassenger = null;
    theTestTourPassangers = new List<Passenger__c>();
    for(Integer i = 1;i < 43;i++) {
      theTestPassenger = theTestDataFactory.createPassenger('Test Passenger' + String.valueOf(i), theTestTourInstance.Id, false);
      theTestPassenger.Email_Share_Opt_In__c = true;
      theTestPassenger.Account__c = theTestAccount.id;
      theTestTourPassangers.add(theTestPassenger);
    }
    insert theTestTourPassangers;
    theController = new TOPS_LostInCityPDFController();
    system.assert(
      theController.tourRecord != null,
      'Error: The apex controller class named "TOPS_LostInCityPDFController" failed to determine tour record record.'
    );

    // Test Case 2 - Inserting 8 More Test Tour Passengers.
    theTestPassenger = null;
    theTestTourPassangers = new List<Passenger__c>();
    for(integer i = 42;i < 50;i++) {
      theTestPassenger = theTestDataFactory.createPassenger('Test Passenger' + String.valueOf(i), theTestTourInstance.Id, false);
      theTestPassenger.Email_Share_Opt_In__c = true;
      theTestTourPassangers.add(theTestPassenger);
    }
    insert theTestTourPassangers;
    theController = new TOPS_LostInCityPDFController();
    system.assert(
      theController.tourRecord != null,
      'Error: The apex controller class named "TOPS_LostInCityPDFController" failed to determine tour record record.'
    );
      
    // Test Case 3 - Inserting 7 More Test Tour Passengers.
    theTestPassenger = null;
    theTestTourPassangers = new List<Passenger__c>();
    for(Integer i = 49;i < 56;i++) {
      theTestPassenger = theTestDataFactory.createPassenger('Test Passenger' + String.valueOf(i), theTestTourInstance.Id, false);
      theTestPassenger.Email_Share_Opt_In__c = true;
      theTestTourPassangers.add(theTestPassenger);
    }
    insert theTestTourPassangers;
    theController = new TOPS_LostInCityPDFController();
    system.assert(
      theController.tourRecord != null,
      'Error: The apex controller class named "TOPS_LostInCityPDFController" failed to determine tour record.'
    );
       
    // Resetting Data Members.
    theTestPassenger = null;
    theTestTourPassangers = new List<Passenger__c>();

    // Test Case 4 - Instantiating Test Tour Director.
    theTestPassenger = theTestDataFactory.createPassenger('Test Tour Director', theTestTourInstance.Id,false);
    theTestPassenger.Email_Share_Opt_In__c = true;
    theTestPassenger.Passenger_Class__c = 'Tour Director';
    theTestPassenger.First_Name__c = 'Test Tour';
    theTestPassenger.Family_Name__c = 'Director';
    theTestTourPassangers.add(theTestPassenger);

    // Test Case 5 - Instantiating Test Tour Driver.
    theTestPassenger = theTestDataFactory.createPassenger('Test Tour Driver', theTestTourInstance.Id, false);
    theTestPassenger.Email_Share_Opt_In__c = true;
    theTestPassenger.Passenger_Class__c = 'Driver';
    theTestPassenger.First_Name__c = 'Test Tour';
    theTestPassenger.Family_Name__c = 'Driver';
    theTestTourPassangers.add(theTestPassenger);

    // Inserting Test Tour Director And Test Tour Driver.
    insert theTestTourPassangers;
    theController = new TOPS_LostInCityPDFController();
    system.assert(
      theController.tourDirector != null,
      'Error: The apex controller class named "TOPS_LostInCityPDFController" failed to determine tour director record.'
    );
    system.assert(
      theController.tourDriver != null,
      'Error: The apex controller class named "TOPS_LostInCityPDFController" failed to determine tour driver record.'
    );
  }
}