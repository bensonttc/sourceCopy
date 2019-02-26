// 
// (c) 2016 Appirio, Inc.
//
// Apex Trigger Name: FeedItemTrigger
// Description: Apex trigger for sobject API named "FeedItem".
//
// 12th February 2016   Hemendra Singh Bhati  Original (Task # T-473038) - Please see the task description for more details.
//
trigger FeedItemTrigger on FeedItem(after insert, after delete) {
  // Instantiating Feed Item Trigger Handler.
  FeedItemTriggerHandler theTriggerHandler = new FeedItemTriggerHandler();

  system.debug('TRACE: FeedItemTrigger - Executing Feed Item Trigger Handler.');
  theTriggerHandler.execute();
}