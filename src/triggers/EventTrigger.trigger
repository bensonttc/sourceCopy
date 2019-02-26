// written 04/09/2014 by John Jordan for Cloud Perspective
trigger EventTrigger on Event (before insert, before update, after insert, after update, before delete, after delete)
{
    system.debug('Checking recursion');
    if (s_CheckRecursionOnTriggers.runonce())
    {
        system.debug('Recursion OK');
        EventTriggerHandler triggerHandler = new EventTriggerHandler();
        triggerHandler.execute();
        system.debug('Done execute');
    }
}