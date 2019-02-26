//
// (c) 2016 Appirio, Inc.
//
// Apex Mock Class: TOPS_SendGridResponseMock
// For Test Class: TOPS_SendGridOutboundRequest_Test
// For Apex Class: TOPS_SendGridOutboundRequestDispatcher
// Description: This apex class integrates with SendGrid API to send mass emails.
//
// 29th January 2016   Hemendra Singh Bhati   Original (Task # T-470006)
//
global without sharing class TOPS_SendGridResponseMock implements HttpCalloutMock {
  /**
  * @description  This method is used to generate a fake HTTP response.
  *
  * @param        HTTPRequest theRequest
  * @return       HTTPResponse
  */
  global HTTPResponse respond(HTTPRequest theRequest) {
    String theResponseXMLBody = '<response>';
    theResponseXMLBody += '<invalid><email>hsingh@appirio.com</email></invalid>';
    theResponseXMLBody += '<blocked><email>hsingh@appirio.com</email></blocked>';
    theResponseXMLBody += '<bounced><email>hsingh@appirio.com</email></bounced>';
    theResponseXMLBody += '</response>';

    HttpResponse theResponse = new HttpResponse();
    theResponse.setHeader('Content-Type', 'application/xml');
    theResponse.setBody(theResponseXMLBody);
    theResponse.setStatus('OK');
    theResponse.setStatusCode(200);
    return theResponse;
  }
}