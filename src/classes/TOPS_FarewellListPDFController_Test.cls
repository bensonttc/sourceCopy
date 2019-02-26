//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_FarewellListPDFController_Test
// For Apex Class: TOPS_FarewellListPDFController
// Description: Used to generate passenger pdf
//
// 28th January 2016    Vinod Kumar  Original (Task # T-467683)
//
@isTest(seeAllData=false)
private class TOPS_FarewellListPDFController_Test {
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
   static testMethod void testTOPS_FarewellListPDFController() {
    TestDataFactory theTestDataFactory = new TestDataFactory();

    Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test tour','Abcd', false); 
    test_TourInstance.Operating_Product_Code__c = 'AAE23910';
    insert test_TourInstance;
       
       
      Account acc = new Account(
      FirstName = 'Test',
      LastName = 'Account',
      Email__c = 'test@appirio.com'
    );   
    insert acc;   
    Tour_Instance_Itinerary__c tiiData = theTestDataFactory.createTourInstanceItinerary(acc.Id,test_TourInstance.Id, false); 
    tiiData.Component_Type__c = 'Itinerary';
    tiiData.TII_Data__c = '{ \"tourSummary\" : { \"tourType\" : { \"isModular\" : \"No\", \"hasSplit\" : \"No\", \"hasAccommodationClass\" : \"No\" }, \"modules\" : [ { \"welcomeEmailSent\" : false, \"supplierPurpose\" : \"No Class\", \"startLocation\" : \"Melbourne (VIC)\", \"startDay\" : \"1\", \"startDate\" : \"2017-11-19\", \"name\" : null, \"mcode\" : \"AAIMSEEE06\", \"farewellEmailSent\" : false, \"endLocation\" : \"Sydney (NSW)\", \"endDay\" : \"13\", \"endDate\" : \"2017-12-02\", \"days\" : [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ] } ] }, \"dailySummary\" : { \"modules\" : [ { \"startDate\" : \"2017-11-19\", \"name\" : \"AAIMSEEE06\", \"endDate\" : \"2017-12-02\" } ] } }';   
    insert tiiData;

    list<Passenger__c> lstPassanger = new list<Passenger__c>();
    
    Passenger__c test_Passenger = theTestDataFactory.createPassenger('test pessanger',test_TourInstance.Id,false);
    test_Passenger.Email_Share_Opt_In__c = true;
    
    lstPassanger.add(test_Passenger);
    insert lstPassanger;
    
    PageReference passPage = Page.TOPS_PassengerListPDF;
    Test.setCurrentPage(passPage);
    
    ApexPages.currentPage().getParameters().put('relatedObjectId', test_TourInstance.id );
    ApexPages.currentPage().getParameters().put('fieldSets', test_TourInstance.id );
    ApexPages.currentPage().getParameters().put('Parameters' , 'V2');
    ApexPages.currentPage().getParameters().put('processingData' , '{"modules":["NONMOD"],"modular":"No","booking":"New"}');

    TOPS_FarewellListPDFController cont = new TOPS_FarewellListPDFController();
    system.assertEquals(cont.passengerList.size(), 1);  

    lstPassanger = new list<Passenger__c>();
    for(integer i = 1;i < 43;i++) {
      Passenger__c p = theTestDataFactory.createPassenger('test pessanger' + String.valueOf(i), test_TourInstance.Id, false);
      p.Email_Share_Opt_In__c = true;
      lstPassanger.add(p);
    }
    insert lstPassanger;

    cont = new TOPS_FarewellListPDFController();

    lstPassanger = new list<Passenger__c>();
    for(integer i = 42;i < 50;i++) {
      Passenger__c p = theTestDataFactory.createPassenger('test pessanger' + String.valueOf(i), test_TourInstance.Id, false);
      p.Email_Share_Opt_In__c = true;
      lstPassanger.add(p);
    }
    insert lstPassanger;

    cont = new TOPS_FarewellListPDFController();

    lstPassanger = new list<Passenger__c>();
    for(integer i = 49;i < 56;i++) {
      Passenger__c p = theTestDataFactory.createPassenger('test pessanger' + string.valueOf(i), test_TourInstance.Id, false);
      p.Email_Share_Opt_In__c = true;
      lstPassanger.add(p);
    }   
    insert lstPassanger;
    cont = new TOPS_FarewellListPDFController();
    
    lstPassanger = new list<Passenger__c>();

    Passenger__c p = theTestDataFactory.createPassenger('test pessanger56', test_TourInstance.Id, false);
    p.Email_Share_Opt_In__c = true;
    p.Passenger_Class__c = 'Driver';
    lstPassanger.add(p);

    Passenger__c p2 = theTestDataFactory.createPassenger('test pessanger57', test_TourInstance.Id, false);
    p.Email_Share_Opt_In__c = true;
    p2.Passenger_Class__c = 'Tour Director';
    p2.First_Name__c = 'Test First Name';
    p2.Family_Name__c = 'Test Family Name';
    lstPassanger.add(p2);  
    insert lstPassanger;

    cont = new TOPS_FarewellListPDFController();

    system.assert(cont.travelDirectorName != null); 
    system.assert(cont.tourDriver != null); 
  }
}