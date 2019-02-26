@istest() private class REST_savePassengerDocuments_V1_Tests {

    //Declare variables that will be used in test
    private static Account personAcc;
    private static Account businessAcc;
    private static Passenger__c pass;
    private static Passenger__c pass2;
    private static Passenger__c pass3;
    private static Booking_Passenger__c bPass;
    private static Booking_Passenger__c bPass2;
    private static Booking_Component__c bComp;
    private static Booking_Component__c bComp2;
    private static Booking__c book;
    private static Tour_Instance__c tourInstance;
    private static Tour_Product__c tourProduct;
    
    @isTest
    static void callAPIForTestResults1(){
        
        createRecords();
        
        passenger_Document__c testDoc = new Passenger_Document__c(passenger__c = pass.id);
        insert testDoc;
        
        REST_savePassengerDocuments_V1.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_V1.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_V1.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.Passengers leadPassenger = new REST_savePassengerDocuments_V1.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Passengers standardPassenger = new REST_savePassengerDocuments_V1.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Tours tours = new REST_savePassengerDocuments_V1.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_V1.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_V1.eDocsJson eDocsJson = new REST_savePassengerDocuments_V1.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.Tours = new List<REST_savePassengerDocuments_V1.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_V1.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.mmdJson mmdJson = new REST_savePassengerDocuments_V1.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.postMMDJson response = REST_savePassengerDocuments_V1.doPost(mmdJson);
        
        system.assertEquals('4 Documents have been added to Salesforce', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults2(){
        
        createRecords();
        
        REST_savePassengerDocuments_V1.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_V1.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_V1.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.Passengers leadPassenger = new REST_savePassengerDocuments_V1.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        
        REST_savePassengerDocuments_V1.Passengers standardPassenger = new REST_savePassengerDocuments_V1.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        
        REST_savePassengerDocuments_V1.Tours tours = new REST_savePassengerDocuments_V1.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_V1.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_V1.eDocsJson eDocsJson = new REST_savePassengerDocuments_V1.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.Tours = new List<REST_savePassengerDocuments_V1.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_V1.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.mmdJson mmdJson = new REST_savePassengerDocuments_V1.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.postMMDJson response = REST_savePassengerDocuments_V1.doPost(mmdJson);
        
        system.assertEquals('There are no Documents associated with the Passenger 001 on the Tour Costsaver Britain and Ireland and there are no Documents associated with the Passenger 002 on the Tour Costsaver Britain and Ireland', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults3(){
        
        createRecords();
        
        REST_savePassengerDocuments_V1.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_V1.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_V1.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.Passengers leadPassenger = new REST_savePassengerDocuments_V1.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Passengers standardPassenger = new REST_savePassengerDocuments_V1.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Tours tours = new REST_savePassengerDocuments_V1.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_V1.Passengers>();
        
        REST_savePassengerDocuments_V1.Tours tours2 = new REST_savePassengerDocuments_V1.Tours();
        tours2.TourCode = 'BIXPA12';
        tours2.TourName = 'Costsaver France';
        tours2.Passengers = new List<REST_savePassengerDocuments_V1.Passengers>();
        
        REST_savePassengerDocuments_V1.eDocsJson eDocsJson = new REST_savePassengerDocuments_V1.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.Tours = new List<REST_savePassengerDocuments_V1.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_V1.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.Tours.add(tours2);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.mmdJson mmdJson = new REST_savePassengerDocuments_V1.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Tours.add(tours2);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.postMMDJson response = REST_savePassengerDocuments_V1.doPost(mmdJson);
        
        system.assertEquals('There are no Passengers in Tour Costsaver Britain and Ireland and There are no Passengers in Tour Costsaver France', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults4(){
        
        createRecords();
        
        REST_savePassengerDocuments_V1.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_V1.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_V1.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.Passengers leadPassenger = new REST_savePassengerDocuments_V1.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Passengers standardPassenger = new REST_savePassengerDocuments_V1.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Tours tours = new REST_savePassengerDocuments_V1.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_V1.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_V1.eDocsJson eDocsJson = new REST_savePassengerDocuments_V1.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.Tours = new List<REST_savePassengerDocuments_V1.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_V1.AdditionalDocuments>();
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.mmdJson mmdJson = new REST_savePassengerDocuments_V1.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.postMMDJson response = REST_savePassengerDocuments_V1.doPost(mmdJson);
        
        system.assertEquals('There are no tours in this json', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults5(){
        
        createRecords();
        
        delete pass;
        delete pass2;
        
        REST_savePassengerDocuments_V1.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_V1.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_V1.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_V1.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_V1.Passengers leadPassenger = new REST_savePassengerDocuments_V1.Passengers();
        leadPassenger.passengerNumber = '008';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Passengers standardPassenger = new REST_savePassengerDocuments_V1.Passengers();
        standardPassenger.passengerNumber = '009';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V1.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_V1.Tours tours = new REST_savePassengerDocuments_V1.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_V1.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_V1.Tours tours2 = new REST_savePassengerDocuments_V1.Tours();
        tours2.TourCode = 'BIXPA12';
        tours2.TourName = 'Costsaver France';
        tours2.Passengers = new List<REST_savePassengerDocuments_V1.Passengers>();
        tours2.Passengers.add(leadPassenger);
        tours2.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_V1.eDocsJson eDocsJson = new REST_savePassengerDocuments_V1.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.Tours = new List<REST_savePassengerDocuments_V1.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_V1.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.Tours.add(tours2);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.mmdJson mmdJson = new REST_savePassengerDocuments_V1.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Tours.add(tours2);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V1.postMMDJson response = REST_savePassengerDocuments_V1.doPost(mmdJson);
        
        system.assertEquals('There are no Passengers in Salesforce for tour Costsaver Britain and Ireland and there are no Passengers in Salesforce for tour Costsaver France', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults6(){
        
        createRecords();
        
        passenger_Document__c testDoc = new Passenger_Document__c(passenger__c = pass.id);
        insert testDoc;
        
        REST_savePassengerDocuments_V2.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_V2.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_V2.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_V2.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_V2.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_V2.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_V2.Passengers leadPassenger = new REST_savePassengerDocuments_V2.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V2.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_V2.Passengers standardPassenger = new REST_savePassengerDocuments_V2.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_V2.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_V2.Tours tours = new REST_savePassengerDocuments_V2.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_V2.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_V2.eDocsJson eDocsJson = new REST_savePassengerDocuments_V2.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.MTSMessaging = 0;
        eDocsJson.Tours = new List<REST_savePassengerDocuments_V2.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_V2.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V2.mmdJson mmdJson = new REST_savePassengerDocuments_V2.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_V2.postMMDJson response = REST_savePassengerDocuments_V2.doPost(mmdJson);
        
        system.assertEquals('4 Documents have been added to Salesforce', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults7(){
        
        createRecords();
        
        REST_savePassengerDocuments_V2.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_V2.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_v2.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.Passengers leadPassenger = new REST_savePassengerDocuments_v2.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        
        REST_savePassengerDocuments_v2.Passengers standardPassenger = new REST_savePassengerDocuments_v2.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        
        REST_savePassengerDocuments_v2.Tours tours = new REST_savePassengerDocuments_v2.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_v2.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_v2.eDocsJson eDocsJson = new REST_savePassengerDocuments_v2.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.MTSMessaging = 0;
        eDocsJson.Tours = new List<REST_savePassengerDocuments_v2.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_v2.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.mmdJson mmdJson = new REST_savePassengerDocuments_v2.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.postMMDJson response = REST_savePassengerDocuments_v2.doPost(mmdJson);
        
        system.assertEquals('There are no Documents associated with the Passenger 001 on the Tour Costsaver Britain and Ireland and there are no Documents associated with the Passenger 002 on the Tour Costsaver Britain and Ireland', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults8(){
        
        createRecords();
        
        REST_savePassengerDocuments_v2.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_v2.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_v2.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.Passengers leadPassenger = new REST_savePassengerDocuments_v2.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_v2.Passengers standardPassenger = new REST_savePassengerDocuments_v2.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_v2.Tours tours = new REST_savePassengerDocuments_v2.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_v2.Passengers>();
        
        REST_savePassengerDocuments_v2.Tours tours2 = new REST_savePassengerDocuments_v2.Tours();
        tours2.TourCode = 'BIXPA12';
        tours2.TourName = 'Costsaver France';
        tours2.Passengers = new List<REST_savePassengerDocuments_v2.Passengers>();
        
        REST_savePassengerDocuments_v2.eDocsJson eDocsJson = new REST_savePassengerDocuments_v2.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.MTSMessaging = 0;
        eDocsJson.Tours = new List<REST_savePassengerDocuments_v2.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_v2.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.Tours.add(tours2);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.mmdJson mmdJson = new REST_savePassengerDocuments_v2.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Tours.add(tours2);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.postMMDJson response = REST_savePassengerDocuments_v2.doPost(mmdJson);
        
        system.assertEquals('There are no Passengers in Tour Costsaver Britain and Ireland and There are no Passengers in Tour Costsaver France', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults9(){
        
        createRecords();
        
        REST_savePassengerDocuments_v2.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_v2.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_v2.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.Passengers leadPassenger = new REST_savePassengerDocuments_v2.Passengers();
        leadPassenger.passengerNumber = '001';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_v2.Passengers standardPassenger = new REST_savePassengerDocuments_v2.Passengers();
        standardPassenger.passengerNumber = '002';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_v2.Tours tours = new REST_savePassengerDocuments_v2.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_v2.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_v2.eDocsJson eDocsJson = new REST_savePassengerDocuments_v2.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.MTSMessaging = 0;
        eDocsJson.Tours = new List<REST_savePassengerDocuments_v2.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_v2.AdditionalDocuments>();
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.mmdJson mmdJson = new REST_savePassengerDocuments_v2.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.postMMDJson response = REST_savePassengerDocuments_v2.doPost(mmdJson);
        
        system.assertEquals('There are no tours in this json', response.message);
    
    }
    
    @isTest
    static void callAPIForTestResults10(){
        
        createRecords();
        
        delete pass;
        delete pass2;
        
        REST_savePassengerDocuments_v2.AdditionalDocuments additionalDocuments = new REST_savePassengerDocuments_v2.AdditionalDocuments();
        additionalDocuments.DocumentName = 'this is the name of the additional document';
        additionalDocuments.DocumentURL = 'www.additionalDocumentURL.com';
        
        REST_savePassengerDocuments_v2.PassengerDocuments leadPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        leadPassengerDocuments.DocumentType = 'TourItinerary';
        leadPassengerDocuments.DocumentName = 'this is the name of the lead passenger document';
        leadPassengerDocuments.DocumentURL = 'www.leadPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.PassengerDocuments standardPassengerDocuments = new REST_savePassengerDocuments_v2.PassengerDocuments();
        standardPassengerDocuments.DocumentType = 'HotelList';
        standardPassengerDocuments.DocumentName = 'this is the name of the standard passenger document';
        standardPassengerDocuments.DocumentURL = 'www.standardPassengerDocumentURL';
        
        REST_savePassengerDocuments_v2.Passengers leadPassenger = new REST_savePassengerDocuments_v2.Passengers();
        leadPassenger.passengerNumber = '008';
        leadPassenger.passengerName = 'Mr. K Wither';
        leadPassenger.clientId = '21628388';
        leadPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        leadPassenger.PassengerDocuments.add(leadPassengerDocuments);
        
        REST_savePassengerDocuments_v2.Passengers standardPassenger = new REST_savePassengerDocuments_v2.Passengers();
        standardPassenger.passengerNumber = '009';
        standardPassenger.passengerName = 'Mrs. A Wither';
        standardPassenger.clientId = '21628389';
        standardPassenger.PassengerDocuments = new List<REST_savePassengerDocuments_v2.PassengerDocuments>();
        standardPassenger.PassengerDocuments.add(standardPassengerDocuments);
        
        REST_savePassengerDocuments_v2.Tours tours = new REST_savePassengerDocuments_v2.Tours();
        tours.TourCode = 'BIXPA11';
        tours.TourName = 'Costsaver Britain and Ireland';
        tours.Passengers = new List<REST_savePassengerDocuments_v2.Passengers>();
        tours.Passengers.add(leadPassenger);
        tours.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_v2.Tours tours2 = new REST_savePassengerDocuments_v2.Tours();
        tours2.TourCode = 'BIXPA12';
        tours2.TourName = 'Costsaver France';
        tours2.Passengers = new List<REST_savePassengerDocuments_v2.Passengers>();
        tours2.Passengers.add(leadPassenger);
        tours2.Passengers.add(standardPassenger);
        
        REST_savePassengerDocuments_v2.eDocsJson eDocsJson = new REST_savePassengerDocuments_v2.eDocsJson();
        eDocsJson.BookingRef = 'A029034';
        eDocsJson.SellingCompanyCode = 'TTAKLS';
        eDocsJson.BookingType = 'CT';
        eDocsJson.DepartureDate = DateTime.newInstance(2017,01,01,00,00,00);
        eDocsJson.TravelAgency = 'My agency';
        eDocsJson.LeadPassengerName = 'Mr K Wither';
        eDocsJson.MTSMessaging = 0;
        eDocsJson.Tours = new List<REST_savePassengerDocuments_v2.Tours>();
        eDocsJson.AdditionalDocuments = new List<REST_savePassengerDocuments_v2.AdditionalDocuments>();
        eDocsJson.Tours.add(tours);
        eDocsJson.Tours.add(tours2);
        eDocsJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.mmdJson mmdJson = new REST_savePassengerDocuments_v2.mmdJson();
        mmdJson.eDocsJson = eDocsJson;
        mmdJson.Tours.add(tours);
        mmdJson.Tours.add(tours2);
        mmdJson.Passengers.add(leadPassenger);
        mmdJson.Passengers.add(standardPassenger);
        mmdJson.PassengerDocuments.add(leadPassengerDocuments);
        mmdJson.PassengerDocuments.add(standardPassengerDocuments);
        mmdJson.AdditionalDocuments.add(additionalDocuments);
        
        REST_savePassengerDocuments_v2.postMMDJson response = REST_savePassengerDocuments_v2.doPost(mmdJson);
        
        system.assertEquals('There are no Passengers in Salesforce for tour Costsaver Britain and Ireland and there are no Passengers in Salesforce for tour Costsaver France', response.message);
    
    }
    
    public static void createRecords(){
    
        //grab record type id of Person Account        
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Customer').getRecordTypeId();
        
        //grab record type id of Business Unit        
        Id businessUnitRecordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Business Unit').getRecordTypeId();
        
        //grab record type id of Passenger        
        Id passengerRecordTypeId = Schema.SObjectType.Passenger__c.getRecordtypeInfosByName().get('Main Passenger').getRecordTypeId();
        
        //grab record type id of Booking Passenger        
        Id bookingPassengerRecordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordtypeInfosByName().get('Booking Passengers').getRecordTypeId();
        
        //grab record type id of Booking Component        
        Id bookingComponentRecordTypeId = Schema.SObjectType.Booking_Component__c.getRecordtypeInfosByName().get('Tour').getRecordTypeId();
        
        //grab record type id of Booking        
        Id bookingRecordTypeId = Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId();
        
        
        personAcc = new Account(firstName = 'Kenneth', lastName = 'Wither', recordTypeId = personAccountRecordTypeId);
        insert personAcc;
        
        businessAcc = new Account(name = 'Trafalgar (NZ)', Selling_Company_Short_Name__c = 'TTAKLS', External_Id__c = 'TTAKLS', recordTypeId = businessUnitRecordTypeId);
        insert businessAcc;
        
        book = new Booking__c(name = 'A029034', Selling_Company__c = businessAcc.Id, Lead_Passenger__c = personAcc.Id, Original_Booking_Date__c = date.today(), recordTypeId = bookingRecordTypeId, First_Departure_Date__c = date.today() + 30);
        insert book;
        
        bPass = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book.Id, name = 'TTAKLS#A029034#001', Pax_No__c = '001', Lead_Passenger__c = TRUE, recordTypeId = bookingPassengerRecordTypeId);
        insert bPass;
        
        bPass2 = new Booking_Passenger__c(Customer__c = personAcc.Id, Booking__c = book.Id, name = 'TTAKLS#A029035#002', Pax_No__c = '002', recordTypeId = bookingPassengerRecordTypeId);
        insert bPass2;
        
        bComp = new Booking_Component__c(name = 'TTAKLS-A029034-001-BIXPA11-14H16a', Booking_Number__c = book.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp;
        
        bComp2 = new Booking_Component__c(name = 'TTAKLS-A029035-001-BIXPA11-14H16a', Booking_Number__c = book.Id, Customer__c = personAcc.Id, Booking_Passenger__c = bPass2.Id, recordTypeId = bookingComponentRecordTypeId);
        insert bComp2;
        
        tourProduct = new Tour_Product__c(name = 'BIXPA11', Product_Name__c = 'Costsaver Britain and Ireland');
        insert tourProduct;
        
        tourInstance = new Tour_instance__c(Operating_Product_Code__c = 'TUDEUS11', Departure_Code__c = '19H16a');
        insert tourInstance;
        
        pass = new Passenger__c(name = 'Kenneth Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029034#001', First_name__c = 'Kenneth', Family_Name__c = 'Wither', Booking_Passenger__c = bPass.Id, Booking_Component__c = bComp.Id, Tour_Instance__c = tourInstance.id, Tour_Product__c = tourProduct.id, recordTypeId = passengerRecordTypeId);
        insert pass;
        
        pass2 = new Passenger__c(name = 'Anne Wither', Account__c = personAcc.Id, Passenger_External_Id__c = 'a1e20000007Y9NBAA0-TTAKLS#A029035#001', First_name__c = 'Anne', Family_Name__c = 'Wither', Booking_Passenger__c = bPass2.Id, Booking_Component__c = bComp2.Id, Tour_Instance__c = tourInstance.id, Tour_Product__c = tourProduct.id, recordTypeId = passengerRecordTypeId);
        insert pass2;
    }

}