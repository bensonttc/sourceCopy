//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_EmailPrintRequestTriggerHandlerTest
// For Apex Class: EmailPrintRequestTriggerHandler
// Description: Used in email print service.
//
// 28th January 2016    Vinod Kumar             Original (Task # T-469233)
// 05th February 2016   Hemendra Singh Bhati    Modified (Task # T-473038) - Added system.assert calls.
//
@isTest(seeAllData=false)
private class EmailPrintRequestTriggerHandlerTest {
  /**
  * @description  This method validates the trigger handler functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void validateTriggerHandlerFunctionality() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Email Print Request Config.
    Email_Print_Request_Config__c theTestEmailPrintRequestConfig = theTestDataFactory.createEmailPrintRequestConfig(
      'Welcome Email',
      'TOPS_WelcomeEmailProcessor',
      '',
      'Welcome Email Subject',
      'Welcome Email Body',
      'Welcome Email',
      'Email',
      true
    );

    // Inserting Test Email Print Request.
    Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'hsingh@appirio.com',
      'New',
      'Welcome Email',
      true
    );

    Test.startTest();

    // Initiating Email Print Service Engine.
    System.enqueueJob(new TOPS_EmailPrintEngine(new List<Email_Print_Request__c> {
      theTestEmailPrintRequest
    }));

    Test.stopTest();

    // Validating Test Email Print Request Status.
    String theStatus = [SELECT Status__c FROM Email_Print_Request__c WHERE Id = :theTestEmailPrintRequest.Id].Status__c;
    /*system.assert(
      String.isNotBlank(theStatus) && theStatus.equalsIgnoreCase('Complete'),
      'Error: The email print request trigger handler apex class failed to update the record status to complete.'
    );*/
  }
  
  
  private static testmethod void BisectModules_test(){
    insert new Email_Print_Request__c(Template__c = 'Farewell Email' , Parameters__c = 'V2 - Test Record' , Processing_Data__c = '{"modules":["M14","M15","M16"],"modular":"Yes","booking":"All"}');
  }
  

  private static testmethod void generateFarewellRequest_test(){
    insert new Email_Print_Request__c(Template__c = 'Farewell Email');
    System.assertEquals(1, [SELECT count() from Email_Print_Request__c 
                            WHERE Template__c = 'Farewell Email - Opt Out']);
  }
}