//
// (c) 2016 Appirio, Inc.
//
// Apex Mock Class: TropicsUpdateDispatcherMock
// For Test Class: TropicsUpdateDispatcher_Test
// For Apex Class: TropicsUpdateDispatcher
// Description: Call out dispatcher to "Tropics" to update accounts.
//
// 10th March 2016   Hemendra Singh Bhati   Original (Issue # I-207071) - Please see the issue description for more details.
//
global class TropicsUpdateDispatcherMock implements HttpCalloutMock {
  /**
  * @description  This method is used to generate a fake HTTP response.
  *
  * @param        HTTPRequest theRequest
  * @return       HTTPResponse
  */
  global HTTPResponse respond(HTTPRequest theRequest) {
    String theResponseXMLBody = '<response>';
    theResponseXMLBody += '<message>Bridge update successfully completed.</message>';
    theResponseXMLBody += '</response>';

    HttpResponse theResponse = new HttpResponse();
    theResponse.setHeader('Content-Type', 'application/xml');
    theResponse.setBody(theResponseXMLBody);
    theResponse.setStatus('Accepted');
    theResponse.setStatusCode(200);
    return theResponse;
  }
}