// 
// (c) 2016 Appirio, Inc.
//
// Test Class Name: FeedItemTriggerHandler_Test
// For Apex Class: FeedItemTriggerHandler
// For Apex Trigger: FeedItemTrigger
// Description: Apex trigger for sobject API named "FeedItem".
//
// 12th February 2016   Hemendra Singh Bhati  Original (Task # T-473038) - Please see the task description for more details.
//
@isTest(seeAllData=false)
private class FeedItemTriggerHandler_Test {
  /**
  * @description  This method validates controller functionality.
  *
  * @param        void
  * @return       void
  */
  private static testMethod void validateTriggerHandlerFunctionality() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Tour Instance.
    Tour_Instance__c theTestTourInstance = theTestDataFactory.createTourInstance('Test Tour','IEW93210', true);

    // Inserting Multiple Chatter Feed Items.
    List<FeedItem> theTestFeedItemRecords = new List<FeedItem> {
      // Adding Chatter File To Test Tour Instance Record.
      new FeedItem(
        ParentId = theTestTourInstance.Id,
        Type = 'ContentPost',
        ContentFileName = 'ChatterFile.pdf',
        ContentData = Blob.valueOf('Chatter File Content')
      ),
      // Adding Another Chatter File To Test Tour Instance Record.
      new FeedItem(
        ParentId = theTestTourInstance.Id,
        Type = 'ContentPost',
        ContentFileName = 'AnotherChatterFile.pdf',
        ContentData = Blob.valueOf('Another Chatter File Content')
      )
    };
    insert theTestFeedItemRecords;

    // Test Case 1 - Validate Chatter Attachment References For Test Tour Instance Record.
    system.assert(
      [SELECT Chatter_Attachment_References__c FROM Tour_Instance__c WHERE Id = :theTestTourInstance.Id].Chatter_Attachment_References__c != null,
      'Error: The feed item trigger handler failed to generate chatter attachment references on adding chatter files.'
    );

    // Test Case 2 - Adding Yet Another Chatter File To Test Tour Instance Record.
    FeedItem yetAnotherChatterFile = new FeedItem(
      ParentId = theTestTourInstance.Id,
      Type = 'ContentPost',
      ContentFileName = 'AnotherChatterFile.pdf',
      ContentData = Blob.valueOf('Yet Another Chatter File Content')
    );
    insert yetAnotherChatterFile;
    system.assert(
      [SELECT Chatter_Attachment_References__c FROM Tour_Instance__c WHERE Id = :theTestTourInstance.Id].Chatter_Attachment_References__c != null,
      'Error: The feed item trigger handler failed to update chatter attachment references on adding chatter files.'
    );

    // Test Case 3 - Deleting Chatter And Another Chatter Files From Test Tour Instance Record.
    delete theTestFeedItemRecords;
    system.assert(
      [SELECT Chatter_Attachment_References__c FROM Tour_Instance__c WHERE Id = :theTestTourInstance.Id].Chatter_Attachment_References__c != null,
      'Error: The feed item trigger handler failed to update chatter attachment references on deleting chatter files.'
    );

    // Test Case 4 - Deleting Yet Another Chatter File From Test Tour Instance Record.
    delete yetAnotherChatterFile;
    system.assert(
      [SELECT Chatter_Attachment_References__c FROM Tour_Instance__c WHERE Id = :theTestTourInstance.Id].Chatter_Attachment_References__c == null,
      'Error: The feed item trigger handler failed to update chatter attachment references on deleting chatter files.'
    );
	}
}