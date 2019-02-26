/*****************************************************************************************************
* Appirio, Inc
* Test Class Name: TOPS_ResetTourInstance_Test
* Class Name: TOPS_ResetTourInstance
* Description:  Test Class for TOPS_ResetTourInstance class
* Created Date: [25-Sept-2017]
* Created By: [Neeraj Kumawat] (Appirio)
* 
* Date Modified          Modified By              Description of the update
******************************************************************************************************/
@isTest
private class TOPS_ResetTourInstance_Test {
    //****************************************************************************
    // Method to Test Reset Tour Instance
    // @return void
    //25-Sept-2017 Neeraj Kumawat
    //****************************************************************************
    static testMethod void testResetTourInstance() {
        TestDataFactory theTestDataFactory = new TestDataFactory();
        Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test tour','Abcd', False); 
        test_TourInstance.Process_Status__c='Process Completed';
        insert test_TourInstance;
        Passenger__c test_Passenger=theTestDataFactory.createPassenger('Test Passenger',test_TourInstance.Id, False);
        test_Passenger.Passenger_Class__c='Passenger';
        insert test_Passenger;
        Passenger__c test_PassengerWithDriver=theTestDataFactory.createPassenger('Test Driver',test_TourInstance.Id, False);
        test_PassengerWithDriver.Passenger_Class__c='Driver';
        insert test_PassengerWithDriver;
        Account acc=theTestDataFactory.createAccount('Test First Name','Test Last Name',True);
        Tour_Instance_Itinerary__c test_TII=theTestDataFactory.createTourInstanceItinerary(acc.Id,test_TourInstance.Id,True);
        String result=TOPS_ResetTourInstance.resetTourInstance(test_TourInstance.Id);
        System.assertEquals(result, 'Tour Instance Reset Successfully.'); 
    }
}