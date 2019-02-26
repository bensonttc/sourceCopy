// 
// (c) 2016 Appirio, Inc.
//
// Apex Trigger Name: EmailPrintRequestTrigger
// Description: Apex trigger for sobject "Email_Print_Request__c".
//
// 12th January 2016    Leo Alves             Original
// 05th February 2016   Hemendra Singh Bhati  Modified (Task # T-473038) - Added Comments.
//
trigger EmailPrintRequestTrigger on Email_Print_Request__c(before insert, before update, after insert, after update) {
  // Instantiating Email Print Request Trigger Handler.
  EmailPrintRequestTriggerHandler triggerHandler = new EmailPrintRequestTriggerHandler();
  triggerHandler.execute();
}