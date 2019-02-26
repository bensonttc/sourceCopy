//
// (c) 2016 Appirio, Inc.
//
// Test class for TOPS_Helper
//
@isTest
private class TOPS_HelperTest
{

    @isTest static void testSetAddress()
    {
        Test.startTest();
        TOPS_EmailWrapper emailWrapper = new TOPS_EmailWrapper();
        emailWrapper.tdId = [SELECT Id FROM Account limit 1].Id;
        emailWrapper.regionCode = 'AA';
        TOPS_Helper.setFromAddresses(new List<TOPS_EmailWrapper>{ emailWrapper });
        Test.stopTest();
        System.assertEquals(true, emailWrapper.fromEmail.contains('aatkings.com'));
        System.assertEquals(true, emailWrapper.fromEmail.startsWith('TD'));
    }

    @TestSetup static void createTestData()
    {
        insert TQTestUtils.createAccount('Leo', 'Alves', 'leo@appirio.com');
    }

}