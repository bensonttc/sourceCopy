//
// (c) 2016 Appirio, Inc.
//
// Class Name: DuplicateIdentifierQueueable_Test
// Description: Test class for QueueDuplicateIdentifierJob_Test
//
@isTest
private class DuplicateIdentifierQueueable_Test
{
	@isTest static void testDuplicatesAreIdentified()
	{
		System.assertEquals(3, [SELECT count() FROM Optional__c WHERE Duplicate__c = false], 'Incorrect number of non duplicate optionals');
		System.assertEquals(false,
							[SELECT Duplicate__c FROM Optional__c WHERE Optional_Unique_Code__c = '1-1' AND Day__c = 1].Duplicate__c,
							'Non duplicate optional marked as duplicate');
		for (Optional__c opt : [SELECT Duplicate__c FROM Optional__c WHERE Optional_Unique_Code__c = '1-1' AND Day__c != 1])
			System.assertEquals(true, opt.Duplicate__c, 'Duplicate record not marked as duplicate');
	}

	@testSetup static void setupData()
    {
        List<Optional__c> optionalsToInsert = new List<Optional__c>();
		TestDataFactory dataFactory = new TestDataFactory();

        for (Integer i = 0; i < 15; i++)
		{
            Optional__c opt = dataFactory.createOptional('Optional ' + i, false);
			opt.Tour_Code__c = '12345678';
			opt.Optional_Code__c = '12345678';
			opt.Day__c = 1;
			optionalsToInsert.add(opt);
		}
		for (Integer i = 0; i < 15; i++)
		{
            Optional__c opt = dataFactory.createOptional('Optional ' + i, false);
			opt.Tour_Code__c = '87654321';
			opt.Optional_Code__c = '87654321';
			opt.Day__c = 1;
			optionalsToInsert.add(opt);
		}

		Optional__c optDay2 = dataFactory.createOptional('Optional Day 2', false);
		optDay2.Tour_Code__c = '1';
		optDay2.Optional_Code__c = '1';
		optDay2.Day__c = 2;
		Optional__c optDay3 = dataFactory.createOptional('Optional Day 3', false);
		optDay3.Tour_Code__c = '1';
		optDay3.Optional_Code__c = '1';
		optDay3.Day__c = 3;
		optionalsToInsert.addAll(new List<Optional__c>{optDay2, optDay3});

        insert optionalsToInsert;

		Optional__c optDay1 = dataFactory.createOptional('Optional Day 1', false);
		optDay1.Tour_Code__c = '1';
		optDay1.Optional_Code__c = '1';
		optDay1.Day__c = 1;
		insert optDay1;
    }
}