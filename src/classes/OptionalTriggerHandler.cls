//
// (c) 2016 Appirio, Inc.
//
// Class Name: OptionalTrigger
// Description: General purpose trigger handler for optionals
//
public class OptionalTriggerHandler extends TriggerHandler
{
    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap)
    {
        queueDuplicateIdentifierJob(newObjects);
    }

    // queue job that will mark records as duplicate
    private static void queueDuplicateIdentifierJob(List<SObject> newObjects)
    {
        System.enqueueJob(new DuplicateIdentifierQueueable((List<Optional__c>)newObjects));
    }
}