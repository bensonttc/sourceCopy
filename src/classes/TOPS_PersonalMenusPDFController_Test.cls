//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_PersonalMenusPDFController_Test
// For Apex Class: TOPS_PersonalMenusPDFController
// Description: Used to generate personal menu pdf
//
// 4th February 2016    Kirti Agarwal   Original (Task # T-467738)
//
@isTest(seeAllData=false)
private class TOPS_PersonalMenusPDFController_Test {
  // Private Data Members.
  private static final Id ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Supplier - Hotel').RecordTypeId;

  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  static testMethod void TOPS_PersonalMenusPDFController_Test() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Supplier Hotel Account.
    Account theSupplier = new Account(
      Name = 'Executive Style Hotel Rome',
      Crew_Email_for_Supplier_Office_use__c = 'hsingh@appirio.com',
      RecordTypeId = ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID
    );
    insert theSupplier;

    // Inserting Test Tour Instance.
    Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test tour', 'Abcd', false);
    test_TourInstance.Operating_Product_Code__c = 'TE234ER';
    insert test_TourInstance;
    
    // Inserting Test Tour Optional.
    Tour_Optional__c test_TourOptional = theTestDataFactory.createTourOptional('test tour', test_TourInstance.id, null, false);
    test_TourOptional.Supplier__c = theSupplier.Id;
    insert test_TourOptional;
    
    // Inserting Test Tour Passenger.
    Passenger__c test_Passenger = theTestDataFactory.createPassenger('test pessanger', test_TourInstance.Id, true);
    
    PageReference passPage = Page.TOPS_PersonalMenusPDF;
    Test.setCurrentPage(passPage);
    ApexPages.currentPage().getParameters().put('relatedObjectId', test_TourOptional.id);
    TOPS_PersonalMenusPDFController obj = new TOPS_PersonalMenusPDFController();
    System.assert(obj.passengerOptionalmap.size() != 1);
    
    List<Passenger__c> lstPassanger = new List<Passenger__c>();

    Passenger__c p = theTestDataFactory.createPassenger('test pessanger56',test_TourInstance.Id,false);
    p.Email_Share_Opt_In__c = true;
    p.Passenger_Class__c = 'Driver';
    lstPassanger.add(p);

    Passenger__c p2 = theTestDataFactory.createPassenger('test pessanger57',test_TourInstance.Id,false);
    p.Email_Share_Opt_In__c = true;
    p2.Passenger_Class__c = 'Tour Director';
    lstPassanger.add(p2);  

    insert lstPassanger;
    
    Passenger_Optional__c pass = new Passenger_Optional__c(Passenger__c = p.id, Tour_Optional__c = test_TourOptional.id);
    insert pass;

    obj = new TOPS_PersonalMenusPDFController();
    System.assert(obj.passengerOptionalmap.size() > 0);

    theSupplier.Name = 'Executive Style Hotel Rome - Test Supplier';
    update theSupplier;

    obj = new TOPS_PersonalMenusPDFController();
    System.assert(obj.passengerOptionalmap.size() > 0);
  }
}