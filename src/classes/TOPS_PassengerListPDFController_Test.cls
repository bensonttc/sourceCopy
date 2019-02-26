//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_PassengerListPDFController_Test
// For Apex Class: TOPS_PassengerListPDFController
// Description: Used to generate passenger pdf
//
// 28th January 2016    Kirti Agarwal  Original (Task # T-465523)
//
@isTest(seeAllData=false)
class TOPS_PassengerListPDFController_Test{
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
   static testMethod void TOPS_PassengerListPDFController_Test1() { 
   	TestDataFactory theTestDataFactory = new TestDataFactory();

       Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test tour','Abcd', false);
       test_TourInstance.Operating_Product_Code__c = 'VBDE3421L';
       insert test_TourInstance;

       list<Passenger__c> lstPassanger = new list<Passenger__c>();

       Passenger__c test_Passenger = theTestDataFactory.createPassenger('test pessanger',test_TourInstance.Id,true);
       lstPassanger.add(test_Passenger);

       PageReference passPage = Page.TOPS_PassengerListPDF;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('relatedObjectId',test_TourInstance.id );
       ApexPages.currentPage().getParameters().put('fieldSets',test_TourInstance.id );
       TOPS_PassengerListPDFController cont = new TOPS_PassengerListPDFController();
       system.assertEquals(cont.passengerList.size(),1);  

       lstPassanger = new list<Passenger__c>();
       for(integer i =1; i< 43;i++){
       	Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+String.valueOf(i),test_TourInstance.Id,false);
       	lstPassanger.add(p);
       }   
       insert lstPassanger;
       cont = new TOPS_PassengerListPDFController();
       lstPassanger = new list<Passenger__c>();
       for(integer i =42; i< 50;i++){
       	Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+String.valueOf(i),test_TourInstance.Id,false);
       	lstPassanger.add(p);
       }   
       insert lstPassanger;
       cont = new TOPS_PassengerListPDFController();
      
       lstPassanger = new list<Passenger__c>();
       for(integer i =49; i< 56;i++){
       	Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+string.valueOf(i),test_TourInstance.Id,false);
       	lstPassanger.add(p);
       }   
       insert lstPassanger;
       cont = new TOPS_PassengerListPDFController();
       
       lstPassanger = new list<Passenger__c>();
       Passenger__c p = theTestDataFactory.createPassenger('test pessanger56',test_TourInstance.Id,false);
       p.Passenger_Class__c = 'Driver';
       p.First_Name__c = 'Test Tour';
       p.Family_Name__c = 'Driver';
       lstPassanger.add(p);
       Passenger__c p2 = theTestDataFactory.createPassenger('test pessanger57',test_TourInstance.Id,false);
       p2.Passenger_Class__c = 'Tour Director';
       p2.First_Name__c = 'Test Tour';
       p2.Family_Name__c = 'Director';
       lstPassanger.add(p2);  
       insert lstPassanger;
       cont = new TOPS_PassengerListPDFController();

       system.assertEquals(cont.tourDirector.size(),1); 
       system.assertEquals(cont.tourDriver.size(),1); 
    }
}