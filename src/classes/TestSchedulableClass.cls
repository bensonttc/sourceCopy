@isTest (seeAllData = false)
                                
private class TestSchedulableClass {
  
/*  public static String CRON_EXP = '0 0 0 15 3 ? 2022';

  static void createTestData(){
        DSE__DS_Settings__c testSettings = new DSE__DS_Settings__c(
        CurrencyIsoCode='USD',
        DSE__DS_Account_Duplicate_if_Lead_exists__c=FALSE,
        DSE__DS_Automatic_Mode_Job_Delay__c=2,
        DSE__DS_Concurrent_Jobs_Limit__c=5,
        DSE__DS_Enable_Data_Scout_Tests__c=FALSE,
        DSE__DS_Extract_Domain__c=TRUE,
        DSE__DS_Extract_Legal_Form__c=TRUE,
        DSE__DS_Hierarchy_Batch_Size_Limit__c=5000,
        DSE__DS_Hierarchy_Scout_Node_Page_Size__c=50,
        DSE__DS_Ignore_ISO_Code__c=FALSE,
        DSE__DS_Lead_Duplicate_if_Account_exists__c=FALSE,
        DSE__DS_Maintenance_Window_Active__c=FALSE,
        DSE__DS_Match_Using_Record_Type_Rules__c=TRUE,
        DSE__DS_Max_Hierarchy_Limit__c=45000,
        DSE__DS_Max_Hierarchy_TriggerLimit__c=500,
        DSE__DS_MB_Override__c=FALSE,
        DSE__DS_Save_Job_Statistics__c=TRUE,
        DSE__DS_Search_Results_Limit__c=200,
        DSE__DS_Segment_Key_Index_Length__c=3,
        DSE__DS_Setup_Completed__c=TRUE,
        DSE__DS_Skip_Batch_Job_Size_Check__c=FALSE,
        DSE__DS_Standardize_Billing_Country__c=TRUE,
        DSE__DS_Use_Default_Settings__c=FALSE,
        DSE__DS_Validate_Billing_Country__c=FALSE,
        Name='Active');

        insert testSettings;
   }


  static testmethod void testSchMathing() {
  
    createTestData();
    Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleMatchingClassTest',
                        CRON_EXP, 
                        new scheduledMatching ());
    Test.StopTest();
    
    }
    static testmethod void testSchConsolidation() {
  
    createTestData();
    Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleConsolidationClassTest',
                        CRON_EXP, 
                        new scheduledConsolidation ());
    Test.StopTest();
    
    }*/
}