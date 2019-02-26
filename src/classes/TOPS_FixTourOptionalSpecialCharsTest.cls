@isTest(seeAllData=false)
private class TOPS_FixTourOptionalSpecialCharsTest{
/**
 *  Purpose         :   This class is used to test TOPS_CreateRoomingListSchedule
 *
 *  Created By      :   Ravi Jain (Appirio Offshore) modified by Calvin Goodenough for Tops Fix Tour Optional scheduled Job
 *
 *  Created Date    :   10/04/2018
 **/
 
    //Test method added
    static testmethod void myUnitTest(){
    
       TestDataFactory theTestDataFactory = new TestDataFactory();
       Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('13D18a','TEESPLA12', true); 
       test_TourInstance.Start_date__C = system.today();     
       update test_TourInstance;
       Tour_Optional__c test_TourOptional = theTestDataFactory.createTourOptional('Gossip Girl Sites Tour',test_TourInstance.id,null,true);  
       test_TourOptional.Day__c = 1; // contains('\u2028') || to.Description__c.contains('\u2026') || to.Description__c.contains('\u003F')){
       test_TourOptional.Description__c = '\u2028Test \u2026short \u003Fdescrption…'; 
       update test_TourOptional;
            
        //create a cron expression test obj
        string CRON_EXP = '0 0 0 * * ? *';
        
        //start the test
        Test.startTest();
        
        //create a string of the jobId for a new schedule instance of the Sched_Batch_MaintainReportBalanceOnDS class
        string jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new TOPS_FixTourOptionalSpecialChars());
        
        //query the CronTrigger table selecting in CronTrigger fields where the Id = jobId
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =: jobId];
        system.assertEquals(CRON_EXP, ct.CronExpression);
        
        //assert that the job has not been triggered
        system.assertEquals(0, ct.TimesTriggered);
        
        //assert when the next fire time will be
        system.assert(ct.NextFireTime != null);
        
        //Test stops here
        Test.stopTest();
    }
}