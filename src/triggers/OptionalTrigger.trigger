//
// (c) 2016 Appirio, Inc.
//
// Class Name: OptionalTrigger
// Description: General purpose trigger for optionals
//
trigger OptionalTrigger on Optional__c (before insert, after insert)
{
	OptionalTriggerHandler handler = new OptionalTriggerHandler();
	handler.execute();
}