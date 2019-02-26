/**
* Test Class Name   : Tops_ItineraryEmailProcessor_Test
* For Apex Class    : Tops_ItineraryEmailProcessor
* Created By        : Ravi Jain
* Date              : 06/02/2017 
* Purpose           : S-455963 and S-458016
*/
@isTest(seeAllData=false)
public class Tops_ItineraryEmailProcessor_Test {
 // Private Data Members.
  private static final Id ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Business Unit').RecordTypeId;

  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
    @isTest static void validteClassFunctionality() {
        // Create test data
        TestDataFactory theTestDataFactory = new TestDataFactory();
        Email_Print_Request_Config__c testEmailPrintConfig =  theTestDataFactory.createEmailPrintRequestConfig('testWelComeEmail','Tops_ItineraryEmailProcessor','testFieldset',
                                                                'testSubject','testBody','Itinerary Email','Email',true);
        
    // Inserting Test Selling Company Account.
    Account theTestSellingCompany = new Account(
      Name = 'Test Selling Company',
      Selling_Company_Short_Name__c = 'GE',
      RecordTypeId = ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID
    );

        Account acc = new Account( LastName='myTest', FirstName='account');
        acc.Email__c = 'nitish.bansal@appirio.com';

    insert new List<Account> {
      theTestSellingCompany,
      acc
    };

    // Inserting Test Tour Series.
    Tour_Series__c theTestTourSeries = new Tour_Series__c(
      Name = 'AAERYF2341',
      Brand_Welcome_Message__c = 'Test Brand Welcome Message'
    );
    insert theTestTourSeries;

    Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test nick','Abcd', false); 
    /*test_TourInstance.Allocated_TD__c = acc.id;
    test_TourInstance.Operating_Product_Code__c = 'AAER2341';
    test_TourInstance.Start_Date__c = Date.today();
    test_TourInstance.Tour_Series__c = theTestTourSeries.Id;*/
    
    // Code changes done by Ravi Jain for story S-455844 
    // Code changes start here
    for(Integer i=0;i<12;i++)
    {
    test_TourInstance.Allocated_TD__c = acc.id;
    test_TourInstance.Operating_Product_Code__c = 'AAER2341';
    test_TourInstance.Start_Date__c = Date.today().addMonths(i);
    test_TourInstance.Tour_Series__c = theTestTourSeries.Id;
    }   
    // Code changes end here
    
    insert test_TourInstance;

    // Inserting Test Booking.
    Booking__c theTestBooking = new Booking__c(
      Name = 'Test Booking',
      Selling_Company__c = theTestSellingCompany.Id
    );
    insert theTestBooking;

    // Inserting Test Booking Passenger.
    Booking_Passenger__c theTestBookingPassenger = new Booking_Passenger__c(
      Name = 'Test Booking Passenger',
      Booking__c = theTestBooking.Id
    );
    insert theTestBookingPassenger;

    // Inserting Test Booking Component.
    Booking_Component__c theTestBookingComponent = new Booking_Component__c(
      Name = 'Test Booking Component',
      Booking_Passenger__c = theTestBookingPassenger.Id,
      Status__c = 'CF'
    );
    insert theTestBookingComponent;

    list<Passenger__c> lstPassanger = new list<Passenger__c>();
    for(integer i = 1; i< 10;i++) {
      Passenger__c p = theTestDataFactory.createPassenger('test pessanger'+String.valueOf(i),test_TourInstance.Id,false);
      p.Email_Share_Opt_In__c = true;
      p.Dietary_Requirements__c = 'I would prefer green meal';
      p.Booking_Passenger__c = theTestBookingPassenger.Id;
      p.Account__c = acc.id;

      if(i== 1 || i == 4 || i == 7) {
        p.Actual_Room_Type__c = 'Double';
      }
      else if( i == 2 || i == 5 || i == 8) {
        p.Actual_Room_Type__c = 'Triple';
      }
      else if( i == 3 || i == 6 || i == 9) {
        p.Actual_Room_Type__c = 'Quad';
      }

      if(i == 1) {
        p.Passenger_Class__c = 'Tour Director';
      }
      else if(i == 2) {
        p.Passenger_Class__c = 'Driver';
      }
      lstPassanger.add(p);
    } 
    insert lstPassanger;

    // Inserting Test Email Print Request.
    Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'nitish.bansal@appirio.com',
      'New',
      'Itinerary Email',
      false
    );
    theTestEmailPrintRequest.Related_Object_Id__c = test_TourInstance.Id;
    theTestEmailPrintRequest.Parameters__c = 'Lost in City Subject: Test email';
    theTestEmailPrintRequest.Additional_Emails__c = '{"cc":"jai@test.com,jai@success.com"}'; // Added by Jai Gupta S-568616
    insert theTestEmailPrintRequest;
        
     // Inserting Test Email Print Request.
    Email_Print_Request__c theTestEmailPrintRequest1 = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'nitish.bansal@appirio.com',
      'New',
      'Itinerary Email',
      false
    );
    theTestEmailPrintRequest1.Related_Object_Id__c = test_TourInstance.Allocated_TD__c;
    theTestEmailPrintRequest1.Parameters__c = 'Lost in City Subject: Test email';
    insert theTestEmailPrintRequest1;    
  // Code changes end here    

        Tops_ItineraryEmailProcessor objWelcomeProcessor = new Tops_ItineraryEmailProcessor();
        TOPS_EmailWrapper testEmailWrapper = objWelcomeProcessor.createEmailWrapper(theTestEmailPrintRequest,testEmailPrintConfig);
        //system.assertEquals('Test email', testEmailWrapper.emailSubject);
    }
}