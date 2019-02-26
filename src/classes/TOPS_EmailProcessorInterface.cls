//
// (c) 2016 Appirio, Inc.
//
// Apex Interface Name: TOPS_EmailProcessorInterface
// Description: Used in email print service.
//
// 25th January 2016    Hemendra Singh Bhati    Modified (Task # T-468823)
//
public interface TOPS_EmailProcessorInterface {
  // Method Signatures.
  TOPS_EmailWrapper createEmailWrapper(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord);
  String mergeFields(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord);
}