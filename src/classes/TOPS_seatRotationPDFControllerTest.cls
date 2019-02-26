// (c) 2018 Appirio, Inc.
//
// Test Class Name: TOPS_seatRotationPDFControllerTest
// For Apex Class: TOPS_seatRotationPDFController
// For Apex Page: TOPS_RoomListPDF
// Functionality Description: This apex controller is used to generate PDF of seating layout on a variety of coach layouts.
//
// 02nd February 2016   Ravi Jain

@isTest(seeAllData=false)
public class TOPS_seatRotationPDFControllerTest
{
     public static testmethod void validateClassFunctionality()  
     {
         TOPS_seatRotationPDFController seatRotationPDFController = new TOPS_seatRotationPDFController();
         seatRotationPDFController.getPDFLanguage();
         seatRotationPDFController.theTotalRows = 14;
         integer counter = 0;
         seatRotationPDFController.getCoachSeatingPlan();
     }
    
    private static testmethod void testCase1()  
    {
        TestDataFactory factory = new TestDataFactory();
        
        Account acc = factory.createAccount('Test', 'Test', true);
        Tour_Instance__c tI = factory.createTourInstance('Test', 'CDT', false);
        tI.rotate_rows_behind_driver__c = '15';
        tI.rotate_rows_behind_TDTM__c = '11';
        tI.rotate_rows_after_stairs__c = '10';
        tI.rotate_driver_side__c = 'Left';
        tI.rotate_orientation__c = 'UpDown';
        tI.rotate_method__c = 'Clockwise';
        tI.rotate_num_seats__c = '5';
        insert tI;
        
        Tour_Instance__c tI1 = factory.createTourInstance('Test', 'CDT', false);
        tI1.rotate_rows_behind_driver__c = '15';
        tI1.rotate_rows_behind_TDTM__c = '11';
        tI1.rotate_rows_after_stairs__c = '10';
        tI1.rotate_driver_side__c = 'Left';
        tI1.rotate_orientation__c = 'UpDown';
        tI1.rotate_method__c = 'Clockwise';
        tI1.rotate_num_seats__c = '5';
        insert tI1;
        
        Tour_Instance_Itinerary__c tII = factory.createTourInstanceItinerary(acc.Id, ti.Id, false);
        tII.Component_Type__c = 'Itinerary';
        insert tII;
        
        Tour_Instance_Itinerary__c tII1 = factory.createTourInstanceItinerary(acc.Id, ti1.Id, false);
        tII1.rotate_seat_plan__c = '{ "seatingPlan" : [{ "theSeatNumber":51, "theNonRotator":false,"theGuestName":"Jewell, Test","theAnnotation":"null" },{ "theSeatNumber":31, "theNonRotator":true,"theGuestName":"HalfPennyTD, IPA","theAnnotation":"null" }]}';
        tII1.Day_Wise_Seating_Plan__c = '{ "seatingPlan" : [{ "theSeatNumber":51, "theNonRotator":false,"theGuestName":"Jewell, Test","theAnnotation":"null", "theGuestId":"Test", "theSeatIndex":0,"theSeatColumnType":"firstRowAfterStairs"}, { "theSeatNumber":51, "theNonRotator":false,"theGuestName":"Jewell, Test","theAnnotation":"null", "theGuestId":"Test", "theSeatIndex":0,"theSeatColumnType":"firstRowBeforeStairs"}, { "theSeatNumber":51, "theNonRotator":false,"theGuestName":"Jewell, Test","theAnnotation":"null", "theGuestId":"Test", "theSeatIndex":0,"theSeatColumnType":"secondRowAfterStairs"}, { "theSeatNumber":51, "theNonRotator":false,"theGuestName":"Jewell, Test","theAnnotation":"null", "theGuestId":"Test", "theSeatIndex":0,"theSeatColumnType":"secondRowBeforeStairs"}, { "theSeatNumber":51, "theNonRotator":false,"theGuestName":"Jewell, Test","theAnnotation":"null", "theGuestId":"Test", "theSeatIndex":0,"theSeatColumnType":"thirdRow"}, { "theSeatNumber":51, "theNonRotator":false,"theGuestName":"Jewell, Test","theAnnotation":"null", "theGuestId":"Test", "theSeatIndex":0,"theSeatColumnType":"fifthRow"}]}';
        insert tII1;
        
        Passenger__c theTestPassenger = factory.createPassenger('Test', tI.Id, false);
        theTestPassenger.Passenger_Status__c = 'Started';
        theTestPassenger.Passenger_Class__c = 'Passenger';
        theTestPassenger.Family_Name__c = 'Mike';
        theTestPassenger.Preferred_Name__c = 'Steve';
        theTestPassenger.First_Name__c = 'Clarke';
        insert theTestPassenger;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('relatedObjectId', tI.Id);
        ApexPages.currentPage().getParameters().put('Parameters', 'Layout');
            
        TOPS_seatRotationPDFController seatRotationPDFController = new TOPS_seatRotationPDFController();
        seatRotationPDFController.setLayoutVars();
        
        ApexPages.currentPage().getParameters().put('relatedObjectId', tII1.Id);
        ApexPages.currentPage().getParameters().put('Parameters', 'Data');
            
        seatRotationPDFController = new TOPS_seatRotationPDFController();
        Test.stopTest();
    }
}