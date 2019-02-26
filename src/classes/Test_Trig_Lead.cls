@isTest (SeeAllData = false)
private class Test_Trig_Lead {
    
    static testmethod void test_TriggeredSend() {
    
        Lead leadObj = new Lead(LastName = 'TestLastName', LeadSource = 'Web');
        Test.startTest();
            insert leadObj;
        Test.stopTest();
    }
    
}