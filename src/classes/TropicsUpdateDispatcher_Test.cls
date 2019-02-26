//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TropicsUpdateDispatcher_Test
// For Apex Class: TropicsUpdateDispatcher
// Description: Call out dispatcher to "Tropics" to update accounts.
//
// 10th March 2016   Hemendra Singh Bhati   Original (Issue # I-207071) - Please see the issue description for more details.
//
@isTest(seeAllData=false)
private class TropicsUpdateDispatcher_Test {
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void validateClassFunctionality() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Account.
    Account theTestAccount = theTestDataFactory.createAccount('Test', 'Account', false);
    theTestAccount.TD_Tropics_ID__c = '1234567890';
    theTestAccount.Known_As__pc = 'Test Account';
    theTestAccount.PersonEmail = 'hsingh@appirio.com';
    theTestAccount.Home_Phone_Intl_Code__c = '12345';
    theTestAccount.Home_Phone_Area_Code__c = '12345';
    theTestAccount.Home_Phone_Base_Number__c = '12345';
    insert theTestAccount;

    Test.startTest();

    // Test Case 1 - Validating Mock Response.
    Test.setMock(HttpCalloutMock.class, new TropicsUpdateDispatcherMock());
    System.enqueueJob(new TropicsUpdateDispatcher(theTestAccount));

    Test.stopTest();
	}
}