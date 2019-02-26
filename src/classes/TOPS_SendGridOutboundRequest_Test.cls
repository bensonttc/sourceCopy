//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_SendGridOutboundRequest_Test
// For Apex Classes: TOPS_SendGridOutboundRequestDispatcher, TOPS_SendGridHelper
// Description: This apex class integrates with SendGrid API to send mass emails.
//
// 29th January 2016   Hemendra Singh Bhati   Original (Task # T-470006)
// 9th February 2016   Hemendra Singh Bhati   Modified (Task # T-471567) - Please see the task description for more details.
// 11th February 2016  Hemendra Singh Bhati   Modified (Task # T-474150) - Please see the task description for more details.
//
@isTest(seeAllData=false)
private class TOPS_SendGridOutboundRequest_Test {
  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void validateClassFunctionality() {
    // Instantiating Email Wrapper.
    TOPS_EmailWrapper emailWrapper = null;
    List<TOPS_EmailWrapper> theEmailsToProcess = new List<TOPS_EmailWrapper>();

    // Data Set 1 - Single TO Email Address, No CC Email Address And No BCC Email Address.
    emailWrapper = new TOPS_EmailWrapper(
      'hsingh@appirio.com',
      'hsingh@appirio.com',
      'Welcome Email',
      'This is a test welcome email.',
      new Map<String, Blob> {
        'Attachment.pdf' => Blob.valueOf('Test PDF')
      }
    );
    emailWrapper.brand = 'Contiki';
    theEmailsToProcess.add(emailWrapper);
    
    // Data Set 2 - Multiple TO Email Addresses, Single CC Email Address And Single BCC Email Address.
    emailWrapper = new TOPS_EmailWrapper(
      'hsingh@appirio.com, leo@appirio.com',
      'hsingh@appirio.com',
      'Welcome Email',
      'This is a test welcome email.',
      new Map<String, Blob> {
        'Attachment.pdf' => Blob.valueOf('Test PDF')
      }
    );
    emailWrapper.brand = 'Contiki';
    emailWrapper.cc = 'hsingh@appirio.com';
    emailWrapper.bcc = 'hsingh@appirio.com';
    theEmailsToProcess.add(emailWrapper);

    // Data Set 3 - Single TO Email Addresses, Multiple CC Email Addresses And Multiple BCC Email Addresses.
    emailWrapper = new TOPS_EmailWrapper(
      'hsingh@appirio.com, leo@appirio.com',
      'hsingh@appirio.com',
      'Welcome Email',
      'This is a test welcome email.',
      new Map<String, Blob> {
        'Attachment.pdf' => Blob.valueOf('Test PDF')
      }
    );
    emailWrapper.brand = 'Contiki';
    emailWrapper.cc = 'hsingh@appirio.com, leo@appirio.com';
    emailWrapper.bcc = 'hsingh@appirio.com, leo@appirio.com';
    theEmailsToProcess.add(emailWrapper);

    // Data Set 4 - Brand Name Not Set.
    emailWrapper = new TOPS_EmailWrapper(
      'hsingh@appirio.com',
      'hsingh@appirio.com',
      'Welcome Email',
      'This is a test welcome email.',
      new Map<String, Blob> {
        'Attachment.pdf' => Blob.valueOf('Test PDF')
      }
    );
    emailWrapper.brand = null;
    theEmailsToProcess.add(emailWrapper);

    // Data Set 5 - Invalid Brand Name.
    emailWrapper = new TOPS_EmailWrapper(
      'hsingh@appirio.com',
      'hsingh@appirio.com',
      'Welcome Email',
      'This is a test welcome email.',
      new Map<String, Blob> {
        'Attachment.pdf' => Blob.valueOf('Test PDF')
      }
    );
    emailWrapper.brand = 'Contiki';
    theEmailsToProcess.add(emailWrapper);

    // Data Set 6 - Valid Brand Name.
    emailWrapper = new TOPS_EmailWrapper(
      'hsingh@appirio.com',
      'hsingh@appirio.com',
      'Welcome Email',
      'This is a test welcome email.',
      new Map<String, Blob> {
        'Attachment.pdf' => Blob.valueOf('Test PDF')
      }
    );
    emailWrapper.brand = 'Contiki';
    theEmailsToProcess.add(emailWrapper);

    // Test Case 1 - Without Mock Class.
    TOPS_SendGridOutboundRequestDispatcher theEmailDispatcher = new TOPS_SendGridOutboundRequestDispatcher(null);
    theEmailDispatcher = new TOPS_SendGridOutboundRequestDispatcher(theEmailsToProcess);
    system.assert(
      theEmailDispatcher.status == false,
      'Error: The SendGrid outbound request dispatcher apex class failed to generate IO exception.'
    );

    // Test Case 2 - With Mock Class.
    Test.setMock(HttpCalloutMock.class, new TOPS_SendGridResponseMock());
    theEmailDispatcher = new TOPS_SendGridOutboundRequestDispatcher(theEmailsToProcess);
    system.assert(
      theEmailDispatcher.status == true,
      'Error: The SendGrid outbound request dispatcher apex class failed to send emails.'
    );

    // Test Case 3 - Extracting SendGrid API Credentials Without Using Brand Name.
    TOPS_EmailWrapper theEmailWrapper = new TOPS_EmailWrapper();
    TOPS_SendGridHelper.SendGridCredentials theAccessDetails = TOPS_SendGridHelper.getCredentials();
    system.assert(
      String.isNotBlank(theAccessDetails.username) && String.isNotBlank(theAccessDetails.key),
      'Error: The send grid helper class failed to extract SendGrid API credentials without using the brand name.'
    );
	}
}