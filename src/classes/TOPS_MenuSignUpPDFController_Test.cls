//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_MenuSignUpPDFController_Test
// For Apex Class: TOPS_MenuSignUpPDFController
// Description: Used to generate passenger pdf
//
// 2th February 2016    Vinod Kumar  Original (Task # T-466992)
//
@isTest
private class TOPS_MenuSignUpPDFController_Test {

    /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
   static testMethod void testTOPS_MenuSignUpPDFController() { 
   	TestDataFactory theTestDataFactory = new TestDataFactory();
   	   Optional__c testOptional = theTestDataFactory.createOptional('test Optional',true);
   	   testOptional.Starter_Text_1__c = 'test';
   	   testOptional.Starter_Text_2__c = 'test';
   	   testOptional.Starter_Text_3__c = 'test';
   	   testOptional.Starter_Text_4__c = 'test';
   	   testOptional.Starter_Text_5__c = 'test';
   	   
   	   testOptional.Main_Text_1__c = 'test';
   	   testOptional.Main_Text_2__c = 'test';
   	   testOptional.Main_Text_3__c = 'test';
   	   testOptional.Main_Text_4__c = 'test';
   	   testOptional.Main_Text_5__c = 'test';
   	   
   	   testOptional.Dessert_Text_1__c = 'test';
   	   testOptional.Dessert_Text_2__c = 'test';
   	   testOptional.Dessert_Text_3__c = 'test';
   	   testOptional.Dessert_Text_4__c = 'test';
   	   testOptional.Dessert_Text_5__c = 'test';
   	   
   	   update testOptional;
       Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test tour','Abcd', false);
       test_TourInstance.Operating_Product_Code__c = 'VBSE2351';
       insert test_TourInstance;

       Tour_Optional__c testTourOptional = theTestDataFactory.createTourOptional('test', test_TourInstance.id, testOptional.ID, false); 
       testTourOptional.Supplier_Menu__c =  testOptional.ID;
       insert testTourOptional;

       list<Passenger__c> lstPassanger = new list<Passenger__c>();
       Passenger__c test_Passenger = theTestDataFactory.createPassenger('test pessanger',test_TourInstance.Id,false);
       test_Passenger.Email_Share_Opt_In__c = true;
       lstPassanger.add(test_Passenger);
       insert lstPassanger;

       PageReference passPage = Page.TOPS_PassengerListPDF;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('relatedObjectId',testTourOptional.id );
       ApexPages.currentPage().getParameters().put('fieldSets',test_TourInstance.id );

       TOPS_MenuSignUpPDFController cont = new TOPS_MenuSignUpPDFController();
       system.assertEquals(cont.passengerList.size(),1);

       lstPassanger = new list<Passenger__c>();
       for(integer i =1; i< 43;i++){
       	Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+String.valueOf(i),test_TourInstance.Id,false);
       	p.Email_Share_Opt_In__c = true;
       	lstPassanger.add(p);
       }   
       insert lstPassanger;
       cont = new TOPS_MenuSignUpPDFController();

       lstPassanger = new list<Passenger__c>();
       for(integer i =42; i< 50;i++){
       	Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+String.valueOf(i),test_TourInstance.Id,false);
       	p.Email_Share_Opt_In__c = true;
       	lstPassanger.add(p);
       }   
       insert lstPassanger;
       cont = new TOPS_MenuSignUpPDFController();
      
       lstPassanger = new list<Passenger__c>();
       for(integer i =49; i< 56;i++){
       	Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+string.valueOf(i),test_TourInstance.Id,false);
       	p.Email_Share_Opt_In__c = true;
       	lstPassanger.add(p);
       }   
       insert lstPassanger;
       cont = new TOPS_MenuSignUpPDFController();
       
       lstPassanger = new list<Passenger__c>();       
       insert lstPassanger;
       cont = new TOPS_MenuSignUpPDFController();
       
    }
}