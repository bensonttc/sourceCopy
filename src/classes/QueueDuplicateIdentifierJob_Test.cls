//
// (c) 2016 Appirio, Inc.
//
// Class Name: OptionalTrigger
// Description: Test class to test OptionalTriggerHandler.queueDuplicateIdentifierJob
//
@isTest
private class QueueDuplicateIdentifierJob_Test
{
    @testSetup static void setupData()
    {
        List<Optional__c> optionalsToInsert = new List<Optional__c>();
        for (Integer i = 0; i < 2; i++)
            optionalsToInsert.add(new TestDataFactory().createOptional('Optional ' + i, false));
        insert optionalsToInsert;
    }

    @isTest static void testJobIsEnqueued()
    {
        AsyncApexJob job = [SELECT ApexClassID, JobItemsProcessed, JobType, MethodName FROM AsyncApexJob];
        System.assertEquals([SELECT Id FROM ApexClass WHERE Name = 'DuplicateIdentifierQueueable'].Id, job.ApexClassID);
        System.assertEquals('Queueable', job.JobType);
    }

}