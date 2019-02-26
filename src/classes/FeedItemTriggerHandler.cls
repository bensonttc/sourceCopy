// 
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: FeedItemTriggerHandler
// For Apex Trigger: FeedItemTrigger
// Description: Apex trigger for sobject API named "FeedItem".
//
// 12th February 2016   Hemendra Singh Bhati  Original (Task # T-473038) - Please see the task description for more details.
// 15th February 2016   Hemendra Singh Bhati  Modified (Task # T-473038) - Code optimized.
//
public without sharing class FeedItemTriggerHandler extends TriggerHandler {
  // Private Constants.
  private final String DELIMITER = '¬';

  /**
  * @description  This method is called on after insert trigger event.
  *
  * @param        List<SObject> newValues, Map<Id, SObject> newValuesMap
  * @return       void
  */
  public override void afterInsert(List<SObject> newValues, Map<Id, SObject> newValuesMap) {
    system.debug('TRACE: FeedItemTriggerHandler - afterInsert - Process Newly Inserted Feed Items.');
    setChatterAttachmentReferences(newValues);
  }

  /**
  * @description  This method is called on after delete trigger event.
  *
  * @param        List<SObject> deletedRecords, Map<Id, SObject> deletedRecordsMap
  * @return       void
  */
  public override void afterDelete(List<SObject> deletedRecords, Map<Id, SObject> deletedRecordsMap) {
    system.debug('TRACE: FeedItemTriggerHandler - afterDelete - Process Newly Deleted Feed Items.');
    setChatterAttachmentReferences(deletedRecords);
  }

  /**
  * @description  This method processes newly inserted and deleted feed items related to tour instance records.
  *
  * @param        List<SObject> feedItemRecordsToProcess
  * @return       void
  */
  private void setChatterAttachmentReferences(List<SObject> feedItemRecordsToProcess) {
    // Processing Newly Inserted/Deleted Feed Items.
    String theParentIdType = '';
    Set<Id> theTourInstanceIds = new Set<Id>();
    Map<Id, Tour_Instance__c> toBeUpdated = new Map<Id, Tour_Instance__c>();
    for(FeedItem theRecord : (List<FeedItem>)feedItemRecordsToProcess) {
      theParentIdType = theRecord.ParentId.getSObjectType().getDescribe().getName();
      if(theParentIdType.equalsIgnoreCase('Tour_Instance__c')) {
        // Collecting Tour Instance Ids.
        theTourInstanceIds.add(theRecord.ParentId);

        // Aggregating Tour Instance Records To Be Updated.
        toBeUpdated.put(
          theRecord.ParentId,
          new Tour_Instance__c(
            Id = theRecord.ParentId,
            Chatter_Attachment_References__c = ''
          )
        );
      }
    }
    system.debug('TRACE: FeedItemTriggerHandler - setChatterAttachmentReferences - theTourInstanceIds - ' + theTourInstanceIds);
    system.debug('TRACE: FeedItemTriggerHandler - setChatterAttachmentReferences - toBeUpdated - ' + toBeUpdated);

    // Processing Filtered Tour Instance Ids Extracted Above.
    if(theTourInstanceIds.size() > 0) {
      Map<Id, Set<String>> theTourInstanceIdAndChatterAttachmentReferencesMapping = new Map<Id, Set<String>>();
      for(FeedItem theRecord : [SELECT Id, ParentId, ContentSize, ContentFileName, CreatedDate FROM FeedItem WHERE ParentId IN :theTourInstanceIds]) {
        if(!theTourInstanceIdAndChatterAttachmentReferencesMapping.containsKey(theRecord.ParentId)) {
          theTourInstanceIdAndChatterAttachmentReferencesMapping.put(
            theRecord.ParentId,
            new Set<String>()
          );
        }
        theTourInstanceIdAndChatterAttachmentReferencesMapping.get(theRecord.ParentId).add(
          theRecord.ContentFileName + DELIMITER +
          String.valueOf(theRecord.CreatedDate.getTime()) + DELIMITER +
          String.valueOf(theRecord.Id) + DELIMITER +
          theRecord.ContentSize
        );
      }
      system.debug(
        'TRACE: FeedItemTriggerHandler - setChatterAttachmentReferences - theTourInstanceIdAndChatterAttachmentReferencesMapping - ' +
        theTourInstanceIdAndChatterAttachmentReferencesMapping
      );

      // Processing Chatter Attachment References Collected Above.
      if(theTourInstanceIdAndChatterAttachmentReferencesMapping.size() > 0) {
        for(Id theTourInstanceId : theTourInstanceIdAndChatterAttachmentReferencesMapping.keySet()) {
          toBeUpdated.put(
            theTourInstanceId,
            new Tour_Instance__c(
              Id = theTourInstanceId,
              Chatter_Attachment_References__c = generateChatterAttachmentReferenceString(
                theTourInstanceIdAndChatterAttachmentReferencesMapping.get(theTourInstanceId)
              )
            )
          );
        }
      }
      system.debug('TRACE: FeedItemTriggerHandler - setChatterAttachmentReferences - toBeUpdated - ' + toBeUpdated);

      // Updating Tour Instance Records.
      if(toBeUpdated.size() > 0) {
        update toBeUpdated.values();
      }
    }
  }

  /**
  * @description  This method is used to generate the chatter attachment reference string.
  *
  * @param        Set<String> theChatterAttachments
  * @return       String generatedChatterAttachmentReference
  */
  private String generateChatterAttachmentReferenceString(Set<String> theChatterAttachments) {
    String generatedChatterAttachmentReference = '';
    if(theChatterAttachments != null && theChatterAttachments.size() > 0) {
      for(String newAttachment : theChatterAttachments) {
        generatedChatterAttachmentReference += newAttachment + ';\n';
      }
      generatedChatterAttachmentReference = generatedChatterAttachmentReference.subString(0, generatedChatterAttachmentReference.length() - 2);
    }
    return generatedChatterAttachmentReference;
  }
}