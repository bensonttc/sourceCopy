//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_OptionalSignUpContikiPDFCont_Test
// For Apex Class: TOPS_OptionalSignUpContikiPDFController
// Description: Used to generate Optional Sign-Up pdf
//
// 8nd Feburary 2016   Anuj Khanna  Original (Task # T-469466)
//
@isTest(seeAllData=false)
private class TOPS_OptionalSignUpContikiPDFCont_Test{
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void TOPS_OptionalSignUpContikiPDFCont_Test1() {
    TestDataFactory theTestDataFactory = new TestDataFactory();

    Tour_Instance__c test_TI1 = theTestDataFactory.createTourInstance('TI1','Abcd', false);
    test_TI1.Operating_Product_Code__c = 'VBEFR3278';
    insert test_TI1;

    insert new List<Tour_Optional__c> {
      theTestDataFactory.createTourOptional('TO1', test_TI1.Id, null, false),
      theTestDataFactory.createTourOptional('TO2',test_TI1.Id , null ,false)
    };

    PageReference passPage = Page.TOPS_PassengerListPDF;
    Test.setCurrentPage(passPage);
    ApexPages.currentPage().getParameters().put('relatedObjectId', test_TI1.Id);
    ApexPages.currentPage().getParameters().put('Parameters', 'v2');

    TOPS_OptionalSignUpContikiPDFController opSignContiki = new TOPS_OptionalSignUpContikiPDFController();
    System.assertEquals(opSignContiki.tourOptionalList.size(), 2);

    Tour_Optional__c theTestTourOptional = null;
    List<Tour_Optional__c> theTestTourOptionals = new List<Tour_Optional__c>();
    for(Integer index = 0;index < 18;index++) {
      theTestTourOptional = theTestDataFactory.createTourOptional('Tour Optional #' + index, test_TI1.Id, null, false);
      theTestTourOptionals.add(theTestTourOptional);
    }
    insert theTestTourOptionals;
    opSignContiki = new TOPS_OptionalSignUpContikiPDFController();
    System.assertEquals(opSignContiki.tourOptionalList.size(), 20);

    theTestTourOptionals = new List<Tour_Optional__c>();
    for(Integer index = 0;index < 5;index++) {
      theTestTourOptional = theTestDataFactory.createTourOptional('Tour Optional #' + index, test_TI1.Id, null, false);
      theTestTourOptionals.add(theTestTourOptional);
    }
    insert theTestTourOptionals;
    opSignContiki = new TOPS_OptionalSignUpContikiPDFController();
    System.assertEquals(opSignContiki.tourOptionalList.size(), 25);

    theTestTourOptionals = new List<Tour_Optional__c>();
    for(Integer index = 0;index < 5;index++) {
      theTestTourOptional = theTestDataFactory.createTourOptional('Tour Optional #' + index, test_TI1.Id, null, false);
      theTestTourOptionals.add(theTestTourOptional);
    }
    insert theTestTourOptionals;
    opSignContiki = new TOPS_OptionalSignUpContikiPDFController();
    System.assertEquals(opSignContiki.tourOptionalList.size(), 30);

    theTestTourOptionals = new List<Tour_Optional__c>();
    for(Integer index = 0;index < 5;index++) {
      theTestTourOptional = theTestDataFactory.createTourOptional('Tour Optional #' + index, test_TI1.Id, null, false);
      theTestTourOptionals.add(theTestTourOptional);
    }
    insert theTestTourOptionals;
    opSignContiki = new TOPS_OptionalSignUpContikiPDFController();
    System.assertEquals(opSignContiki.tourOptionalList.size(), 35);
    }
}