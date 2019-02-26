trigger AttachmentTrigger on Attachment (before insert, before update, after insert, after update, before delete, after delete) 
// written 16/09/2014 by John Jordan for Cloud Perspective
{

	 system.debug('Checking recursion');
    if (s_CheckRecursionOnTriggers.runonce())
    {
        system.debug('Recursion OK');
        AttachmentTriggerHandler triggerHandler = new AttachmentTriggerHandler();
        triggerHandler.execute();
        system.debug('Done execute');
    }
}