//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_OptionalSignUpPDFController_Test
// For Apex Class: TOPS_OptionalSignUpPDFController
// Description: Used to generate optional sign up pdf
//
// 4th feb 2016    Kirti Agarwal  Original (Task # T-467738)
// 15th Apr 18 Calvin Goodenough
@isTest
private class TOPS_OptionalSignUpPDFController_Test{

    
    /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
   static testMethod void TOPS_OptionalSignUpPDFController_Test() {
       TestDataFactory theTestDataFactory = new TestDataFactory();
       Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('13D18a','TEESPLA12', true); 
       Tour_Optional__c test_TourOptional = theTestDataFactory.createTourOptional('test tour',test_TourInstance.id,null,true);  
       test_TourOptional.Day__c = 1; 
       test_TourOptional.Short_Description__c = 'Test short descrption'; 
       update test_TourOptional;
    //   PageReference passPage = Page.TOPS_PersonalMenusPDF;
       PageReference passPage = Page.TOPS_OptionalSignUpPDF;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('relatedObjectId', test_TourInstance.id);
       ApexPages.currentPage().getParameters().put('Parameters', 'V2, Adults,Adult Price,Day,Time,Child Price,Kids');
       ApexPages.currentPage().getParameters().put('processingData','{"dayFrom":1,"dayTo":5,"title":"Test"}');
       TOPS_OptionalSignUpPDFController obj = new TOPS_OptionalSignUpPDFController();
       System.assert(obj.tourOptionalList.size() >0);      
   }
   
   static testMethod void TOPS_OptionalSignUpPDFController_Test2() {
       TestDataFactory theTestDataFactory = new TestDataFactory();
       Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('13D18a','AZZABCZ07', true); 
       Tour_Optional__c test_TourOptional = theTestDataFactory.createTourOptional('test tour',test_TourInstance.id,null,true);  
       test_TourOptional.Day__c = 1; 
       update test_TourOptional;
      // PageReference passPage = Page.TOPS_PersonalMenusPDF;
       PageReference passPage = Page.TOPS_OptionalSignUpPDF;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('relatedObjectId', test_TourInstance.id);
       ApexPages.currentPage().getParameters().put('Parameters', 'V2, Adults,Adult Price,Day,Time,Child Price,Kids');
 //      ApexPages.currentPage().getParameters().put('processingData','{"dayFrom":1,"dayTo":5,"title":"Test"}');
       TOPS_OptionalSignUpPDFController obj = new TOPS_OptionalSignUpPDFController();
       System.assert(obj.tourOptionalList.size() >0);      
   }

}