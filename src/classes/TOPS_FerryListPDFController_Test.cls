//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_FerryListPDFController_Test
// For Apex Class: TOPS_FerryListPDFController
// Description: Used to generate passenger pdf.
//
// 2nd February 2016    Kirti Agarwal   Original (Task # T-467687)
//
@isTest(seeAllData=false)
private class TOPS_FerryListPDFController_Test{
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  static testMethod void TOPS_FerryListPDFController_Test() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Tour Instance.
    Tour_Instance__c theTestTourInstance = theTestDataFactory.createTourInstance('test tour', 'Abcd', true);  

    // Inserting Test Account.
    Account acc = new Account(
      FirstName = 'Test',
      LastName = 'Account'
    );
    insert acc;

    // Inserting Test Tour Instance Itinerary.
    Tour_Instance_Itinerary__c tii = theTestDataFactory.createTourInstanceItinerary(acc.id, theTestTourInstance.id, false);
    tii.Component_Type__c  = 'Hotel';
    insert tii;
       
    // Inserting Test Tour Passenger.
    Passenger__c test_Passenger = theTestDataFactory.createPassenger('Test Passenger', theTestTourInstance.Id, true);

    // Setting Up Current Visualforce Page.
    PageReference passPage = Page.TOPS_FerryListPDF;
    Test.setCurrentPage(passPage);
    ApexPages.currentPage().getParameters().put('relatedObjectId', tii.id);
    ApexPages.currentPage().getParameters().put('Parameters', 'Passport Numbers');
    TOPS_FerryListPDFController obj = new TOPS_FerryListPDFController();
    System.assert(obj.wrapperPassengerList.size() > 1);

    // Inserting Test Tour Passengers.
    Map<Integer, String> thePassengerClassMapping = new Map<Integer, String> {
      1 => 'Tour Director',
      2 => 'Driver',
      3 => 'Cook',
      4 => 'OSTM',
      5 => 'National Guide'
    };
    Passenger__c thePassenger = null;
    List<Passenger__c> theTestTourPassengers = new List<Passenger__c>();
    for(Integer index = 1;index <= 10;index++) {
      thePassenger = theTestDataFactory.createPassenger(
        'Test Passenger #' + index,
        theTestTourInstance.Id,
        false
      );
      thePassenger.Date_Of_Birth__c = (index >= 1 && index <= 5) ? System.Today().addYears(-25) :
                                      (index < 7) ? System.Today().addYears(-15) : System.Today().addYears(-2);
      thePassenger.Email_Share_Opt_In__c = true;
      thePassenger.Other_Special_Requirements__c = 'Quiet Room Please.';
      thePassenger.Passenger_Class__c = thePassengerClassMapping.containsKey(index) ? thePassengerClassMapping.get(index): 'Passenger';
      theTestTourPassengers.add(thePassenger);
    }
    insert theTestTourPassengers;

    // Updating Test Tour Instance.
    theTestTourInstance.Operating_Product_Code__c = 'TE23S12';
    update theTestTourInstance;

    // Instantiating Ferry List PDF Controller
    obj = new TOPS_FerryListPDFController();
    System.assert(obj.wrapperPassengerList.size() > 1);
  }
}