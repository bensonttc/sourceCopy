/**
 * Class to host the endpoint of the Upload WebService 
 */
@RestResource(urlMapping='/tqupload/*')
global with sharing class TQUploadEndpoint {
    //To do implement one by one execution if total number of items less then described
    @TestVisible static Integer EXECUTE_DML_BY_RECORD_LIMIT = 70;
    
    static List<TQUploadRequestItem> requestItemsList;
    static List<TQUploadResponse.TQUploadResponseItem> responseItemsList;
    
    static List<Integer> recordOperationIndexList;
    static List<Map<String, Object>> recordAdditonalDataList;
    static Map<String, Integer> numberOfOperationsPerRecord;
    static Map<String, Integer> numberOfProcessedOperationsPerRecord;
    //Map which contains which SalesforceId were set for the object with Local Id
    static Map<String, String> assignedIdsMap;  
    static TQIUploadService service;
    //Set of Ids which hasn't failed during the DML operation
    static Set<String> failedRecordIdSet;
    static Boolean useDmlBatches;
    
    /**
     * Do the upload data functionality to prepare data for execution
     */
    @HttpPost
    webservice static TQUploadResponse uploadRequest(String clientAppID, List<TQUploadRequestItem> recordList, String deviceId) {
        service = new TQUploadService(clientAppID);
        TQChatterService chatterService = new TQChatterService();
        
        TQUploadResponse response = new TQUploadResponse();
        try {
            initVariables(recordList);
            
            Boolean cycleShouldContinue = true;
            while (cycleShouldContinue){
                cycleShouldContinue = processRequestCycle(true, deviceId, chatterService);
            }
            
            setRelationErrors();
            
            response.body = responseItemsList;
            
            response.setStatus(0);
            response.setError(null);
        } catch (Exception e){
            response.setError(e.getMessage());
            response.setStatus(e.getLineNumber());
        }
                
        return response;
    }
    
    // Process one cycle iteration
    private static Boolean processRequestCycle(Boolean reassignmentNeeded, String deviceId, TQChatterService chatterService) {
    
        Boolean itemsToProcessFouneded = false;
        Set<String> itemIdsGoingToProcess = new Set<String>();

        List<Integer> objectRequestIndexesToRemove = new List<Integer>();
        List<sObject> objectReadyToRemove = new List<sObject>();
        
        List<Integer> objectRequestIndexesToUpdate = new List<Integer>();
        List<sObject> objectReadyToUpdate = new List<sObject>();
        
        List<Integer> objectRequestIndexesToInsert = new List<Integer>();
        List<sObject> objectReadyToInsert = new List<sObject>();    
        
        List<TQ_Local_Assignment__c> newAssignments = new List<TQ_Local_Assignment__c>();   
        
        //Go through the all request Items, which were not assigned yet
        for (Integer index = 0; index < requestItemsList.size(); index++) {
            TQUploadRequestItem requestItem = requestItemsList.get(index);
            TQUploadResponse.TQUploadResponseItem responseItem = responseItemsList.get(index);
            Integer recordOperationIndex = recordOperationIndexList.get(index);         
            SObject recordSObject = responseItem.record;
            String requestId  = responseItem.requestId;
            String originalRequestId = requestId;
            Map<String, Object> additionalDataMap = recordAdditonalDataList.get(index);
            
            if (responseItem.executed == true || failedRecordIdSet.contains(requestId)
                || recordOperationIndex != numberOfProcessedOperationsPerRecord.get(requestId)){
                continue;
            }
            
            if (assignedIdsMap.containsKey(requestId)){
                requestId = assignedIdsMap.get(requestId);
                recordSObject.put('Id', requestId);
            }
            
            String operation = service.getOperationType(recordSObject);
            
            //Process DELETE operation
            if (operation == 'DELETE'){
                try {
                    if (service.isLocalId(requestId))
                    {
                        responseItem.success = true;
                        responseItem.executed = true; 
                        continue;
                    }
                    
                    if (useDmlBatches){
                        objectRequestIndexesToRemove.add(index);
                        objectReadyToRemove.add(recordSObject);
                    }
                    else {
                        Database.DeleteResult deleteResult = Database.delete(recordSObject, false);
                        responseItem.requestId = originalRequestId;
                        processItemDeleteResult(responseItem, deleteResult);
                    }

                }
                catch (Exception e){
                    responseItem.success = false;
                    responseItem.executed = true;
                    responseItem.errorList.add(e.getMessage());
                    failedRecordIdSet.add(originalRequestId);
                }
                finally{
                    itemsToProcessFouneded = true;
                    
                    responseItem.requestId = originalRequestId;
                    responseItem.responseId = null;
                    responseItem.operation = TQUploadResponse.OperationDelete;
                }
            }
            else {
                //Process Upsert operation
                if (reassignmentNeeded == true){
                    //Try to replace all references to object with Local Ids to Salesforce Ids
                    Boolean assignmentComplete = service.reassignLocalReferences(recordSObject, assignedIdsMap);
                        
                    if (!assignmentComplete) {
                        continue;
                    }
                }
                
                responseItem.operation = TQUploadResponse.OperationUpsert;
                try {
                    Boolean isInsert = (operation == TQUploadService.INSERT_OPERATION);
                    
                    //sObject should be cloned to remove all the readOnly instances
                    sObject recordSObjectToUpsert = recordSObject.clone(true, false, false, false);
                    //If we are inserting object, then remove localId from sObject
                    if (isInsert)
                        recordSObjectToUpsert.put('Id', null);
                        
                    Database.SaveResult saveResult = null;
                        
                    if (isInsert) {
                        if (useDmlBatches){
                            objectRequestIndexesToInsert.add(index);
                            objectReadyToInsert.add(recordSObjectToUpsert);     
                        }   
                        else {
                            if (recordSObjectToUpsert instanceof FeedItem){
                                ConnectApi.FeedElement feedElement = chatterService.post((FeedItem) recordSObjectToUpsert);
                                responseItem.success = true;
                                responseItem.executed = true; 
                                responseItem.responseId = feedElement.id;
                                
                                assignedIdsMap.put(responseItem.requestId, responseItem.responseId);
                                                    
                                Integer newProcessedCount = numberOfProcessedOperationsPerRecord.get(requestId) + 1;
                                numberOfProcessedOperationsPerRecord.put(requestId, newProcessedCount);
                                
                                if (newProcessedCount == numberOfOperationsPerRecord.get(requestId)){
                                    Schema.Describesobjectresult objectDescribe = TQTrackingUtils.getObjectDescribe(responseItem.objectApiName);
                                    if (objectDescribe != null && objectDescribe.isQueryable()){
                                        sObject resultSObject = service.getResultSObject(responseItem.objectApiName, responseItem.responseId);
                                        if (resultSObject != null) {
                                            responseItem.record = resultSObject;
                                        }
                                        else {
                                            //In case when new record doesn't apply for the download criteria, it should be removed locally
                                            responseItem.operation = TQUploadResponse.OperationDelete;
                                        }
                                    }
                                }
                                
                                saveAssignment(responseItem.requestId, responseItem.responseId, deviceId, newAssignments);
                            }
                            else{
                                Database.SaveResult insertResult;
                                if (service.shouldForceSharingInDml(recordSObjectToUpsert,TQUploadService.INSERT_OPERATION)) {
                                	insertResult = service.insertForceSharing(recordSObjectToUpsert);
                                } else {
                                 	insertResult = Database.insert(recordSObjectToUpsert, false);
                                }
                                responseItem.requestId = originalRequestId;
                                processItemInsertResult(responseItem, insertResult, deviceId, newAssignments);
                                saveResult = insertResult;
                            }
                        }                               
                    }
                    else {
                        if (useDmlBatches){
                            objectRequestIndexesToUpdate.add(index);
                            objectReadyToUpdate.add(recordSObjectToUpsert); 
                        }
                        else {
                            Database.SaveResult updateResult;
                            if (service.shouldForceSharingInDml(recordSObjectToUpsert,TQUploadService.UPDATE_OPERATION)) {
                            	updateResult = service.updateForceSharing(recordSObjectToUpsert);
                            } else {
                             	updateResult = Database.update(recordSObjectToUpsert, false);
                            }
                            responseItem.requestId = originalRequestId;
                            processItemUpdateResult(responseItem, updateResult);  
                            saveResult = updateResult;                          
                        }                   
                    }
                    
                    
                    // If the record contains a file attached to it, create & link an Attachment
                    if(saveResult != null && saveResult.isSuccess() && additionalDataMap.containsKey('TQ_Attachment_FileName__c')
                            && additionalDataMap.containsKey('AttachmentData')) {
                        Attachment attachment = new Attachment();
                        attachment.Body = (Blob)additionalDataMap.get('AttachmentData');
                        attachment.Name = String.valueOf(additionalDataMap.get('TQ_Attachment_FileName__c'));
                        attachment.ParentId = responseItem.responseId;
                        insert attachment;

                        responseItem.record.put('TQ_Attachment_Link__c', '/services/data/v30.0/sobjects/Attachment/' + attachment.Id + '/Body');
                        update responseItem.record;
                    }
                }
                catch (Exception e){
                    responseItem.success = false;
                    responseItem.executed = true;
                    responseItem.errorList.add(e.getMessage());
                    failedRecordIdSet.add(originalRequestId);
                }
                finally {
                    itemsToProcessFouneded = true;
                    responseItem.requestId = originalRequestId;
                }
            }
        }    
        
        processItemsDeletion(objectReadyToRemove, objectRequestIndexesToRemove);
        
        processItemsInserting(objectReadyToInsert, objectRequestIndexesToInsert, deviceId, newAssignments);
                
        processItemsUpdating(objectReadyToUpdate, objectRequestIndexesToUpdate);
        
        if (newAssignments.size() > 0)
            Database.insert(newAssignments, false);
        
        return itemsToProcessFouneded;          
    }

    private static void processItemDeleteResult(TQUploadResponse.TQUploadResponseItem responseItem, Database.DeleteResult deleteResult){
        String requestId = responseItem.requestId;
        responseItem.success = deleteResult.isSuccess();
        if (deleteResult.isSuccess()){
            responseItem.executed = true;
            responseItem.responseId = null;
            responseItem.record = null;
            
            Integer newProcessedCount = numberOfProcessedOperationsPerRecord.get(requestId) + 1;
            numberOfProcessedOperationsPerRecord.put(requestId, newProcessedCount);
        }
        else {
            failedRecordIdSet.add(requestId);
        }
        
        if (deleteResult.getErrors() != null)
            for (Database.Error error : deleteResult.getErrors())
                responseItem.errorList.add(error.getMessage());         
    }
    
    private static void processItemInsertResult(TQUploadResponse.TQUploadResponseItem responseItem, Database.SaveResult insertResult,
                                                String deviceId, List<TQ_Local_Assignment__c> newAssignments){
        String requestId = responseItem.requestId;
        saveResultToResponse(insertResult, responseItem);
        if (responseItem.success){
            assignedIdsMap.put(responseItem.requestId, responseItem.responseId);
                                
            Integer newProcessedCount = numberOfProcessedOperationsPerRecord.get(requestId) + 1;
            numberOfProcessedOperationsPerRecord.put(requestId, newProcessedCount);
            
            if (newProcessedCount == numberOfOperationsPerRecord.get(requestId)){
                Schema.Describesobjectresult objectDescribe = TQTrackingUtils.getObjectDescribe(responseItem.objectApiName);
                if (objectDescribe != null && objectDescribe.isQueryable()){
                    sObject resultSObject = service.getResultSObject(responseItem.objectApiName, responseItem.responseId);
                    if (resultSObject != null) {
                        responseItem.record = resultSObject;
                    }
                    else {
                        //In case when new record doesn't apply for the download criteria, it should be removed locally
                        responseItem.operation = TQUploadResponse.OperationDelete;
                    }
                }
            }
            
            saveAssignment(responseItem.requestId, responseItem.responseId, deviceId, newAssignments);
        }
        else {
            responseItem.record.put('Id', responseItem.requestId);
            failedRecordIdSet.add(requestId);
        }       
    }
    
    private static void processItemUpdateResult(TQUploadResponse.TQUploadResponseItem responseItem, Database.SaveResult updateResult){
        String requestId = responseItem.requestId;
        saveResultToResponse(updateResult, responseItem);
        if (responseItem.success){
            assignedIdsMap.put(responseItem.requestId, responseItem.responseId);
            
            Integer newProcessedCount = numberOfProcessedOperationsPerRecord.get(requestId) + 1;
            numberOfProcessedOperationsPerRecord.put(requestId, newProcessedCount);
            
            if (newProcessedCount == numberOfOperationsPerRecord.get(requestId)){
                sObject resultSObject = service.getResultSObject(responseItem.objectApiName, responseItem.responseId);
                if (resultSObject != null) {
                    responseItem.record = resultSObject;
                }
                else {
                    //In case when new record doesn't apply for the download criteria, it should be removed locally
                    responseItem.operation = TQUploadResponse.OperationDelete;
                }
            }
        }
        else {
            failedRecordIdSet.add(requestId);
        }
    }
        
    private static void processItemsDeletion(List<sObject> objectReadyToRemove, List<Integer> objectRequestIndexesToRemove){
        if (objectReadyToRemove.size() > 0){
            Database.DeleteResult[] deleteOperationResults = Database.delete(objectReadyToRemove, false);
            
            for (Integer index = 0; index < objectReadyToRemove.size(); index++){
                Integer requestIndex = objectRequestIndexesToRemove.get(index);
                TQUploadResponse.TQUploadResponseItem responseItem = responseItemsList.get(requestIndex);
                Database.DeleteResult deleteResult = deleteOperationResults.get(index);
                processItemDeleteResult(responseItem, deleteResult);
            }
        }       
    }
    
    private static void processItemsInserting(List<sObject> objectReadyToInsert, List<Integer> objectRequestIndexesToInsert, 
                                              String deviceId, List<TQ_Local_Assignment__c> newAssignments){
        if (objectReadyToInsert.size() > 0){
            Database.SaveResult[] insertOperationResults = Database.insert(objectReadyToInsert, false);
            
            for (Integer index = 0; index < objectReadyToInsert.size(); index++){
                Integer requestIndex = objectRequestIndexesToInsert.get(index);
                TQUploadResponse.TQUploadResponseItem responseItem = responseItemsList.get(requestIndex);
                Database.SaveResult insertResult = insertOperationResults.get(index);
                processItemInsertResult(responseItem, insertResult, deviceId, newAssignments);
            }
        }       
    }
    
    private static void processItemsUpdating(List<sObject> objectReadyToUpdate, List<Integer> objectRequestIndexesToUpdate){
        if (objectReadyToUpdate.size() > 0){
            Database.SaveResult[] updateOperationResults = Database.update(objectReadyToUpdate, false);
            
            for (Integer index = 0; index < objectReadyToUpdate.size(); index++){
                Integer requestIndex = objectRequestIndexesToUpdate.get(index);
                TQUploadResponse.TQUploadResponseItem responseItem = responseItemsList.get(requestIndex);
                Database.SaveResult updateResult = updateOperationResults.get(index);
                processItemUpdateResult(responseItem, updateResult);
            }
        }  
    }
    
    private static void setRelationErrors(){
        //Go through the all request Items, which were not assigned yet
        for (Integer index = 0; index < requestItemsList.size(); index++) {
            TQUploadRequestItem requestItem = requestItemsList.get(index);
            TQUploadResponse.TQUploadResponseItem responseItem = responseItemsList.get(index);
            String requestId = responseItem.requestId;
            Integer recordIndex = recordOperationIndexList.get(index);
            
            if (!responseItem.executed && !failedRecordIdSet.contains(requestId) && 
                recordIndex == numberOfProcessedOperationsPerRecord.get(requestId))
            {
                failedRecordIdSet.add(requestId);
                SObject recordSObject = responseItem.record;
                
                responseItem.success = false;
                responseItem.executed = false;
                responseItem.responseId = requestId;
                responseItem.operation = TQUploadResponse.OperationUpsert;
                Map<String, String> unresolvedFieldsMap = service.getUnresolvedRelatedFields(recordSObject);
                for (String fieldName : unresolvedFieldsMap.keySet()){
                    String fieldLabel = unresolvedFieldsMap.get(fieldName);
                    String relatedId = (String)recordSObject.get(fieldName);
                    String errorMessage;
                    if (failedRecordIdSet.contains(relatedId)) {
                        errorMessage = 'Related record for field ' + fieldLabel + ' has been failed';
                    }
                    else {
                        errorMessage = 'Related record for field ' + fieldLabel + ' hasn\'t been founded';
                    }
                    responseItem.errorList.add(errorMessage);
                }
            }
            else if (responseItem.operation == null){
                responseItem.operation = TQUploadResponse.OperationUpsert;
            }
        }       
    }
    
    private static void saveAssignment(String localId, String salesforceId, String deviceId, List<TQ_Local_Assignment__c> assignments){
        if (salesforceId != null && localId != salesforceId){
            TQ_Local_Assignment__c assignment = new TQ_Local_Assignment__c(
                Local_Id__c = localId, Salesforce_Id__c = salesforceId, Device_Id__c = deviceId
            );
            
            assignments.add(assignment);
        }
    }
    
    //Save upsert result to the upload response
    private static void saveResultToResponse(Database.SaveResult saveResult, TQUploadResponse.TQUploadResponseItem responseItem){
        responseItem.success = saveResult.isSuccess();
        responseItem.executed = true;       
        //We should retrieve a new object only if UpsertResult is successful
        if (responseItem.success)
            responseItem.responseId = saveResult.getId();
        else
            responseItem.responseId = responseItem.requestId;
            
        if (saveResult.getErrors() != null)
            for (Database.Error error : saveResult.getErrors())
                responseItem.errorList.add(error.getMessage());
    } 
    
    //Initialize all processing variables plus predefine response data
    private static void initVariables(List<TQUploadRequestItem> recordList){
        useDmlBatches = (recordList.size() > EXECUTE_DML_BY_RECORD_LIMIT);
        requestItemsList = recordList;
        responseItemsList = new List<TQUploadResponse.TQUploadResponseItem>();
        recordOperationIndexList = new List<Integer>();     
        numberOfOperationsPerRecord = new Map<String, Integer>();
        numberOfProcessedOperationsPerRecord = new Map<String, Integer>();  
        recordAdditonalDataList = new List<Map<String, Object>>();
            
        assignedIdsMap = getAssignmentsMap();
        failedRecordIdSet = new Set<String>();
        
        for (Integer index = 0; index < recordList.size(); index++){
            TQUploadRequestItem requestItem = recordList.get(index);
            String requestId = requestItem.Id;
            TQUploadResponse.TQUploadResponseItem responseItem;
            responseItem = new TQUploadResponse.TQUploadResponseItem(requestItem.objectApiName, requestId);
            Boolean sObjectConversionSuccess = true;
            sObject recordObject = null;
            Map<String,Object> additionalData = new Map<String, Object>();
            
            try {
                // Try convert JSON string of record to SObject
                recordObject = service.deserializeSObject(requestItem, additionalData);
            } catch(Exception e) {
                sObjectConversionSuccess = false;
                responseItem.errorList.add('Wrong data of ' + requestItem.objectApiName +' : ' + e.getMessage());
                failedRecordIdSet.add(requestId);
            }
            finally {
                responseItem.record = recordObject;
                responseItem.success = false;
                responseItem.executed = false;
                responseItem.changeDate = requestItem.changeDate;
            }
            responseItemsList.add(responseItem);
            recordAdditonalDataList.add(additionalData);
            
            Integer operationsNumber = numberOfOperationsPerRecord.get(requestId);
            if (operationsNumber == null){
                recordOperationIndexList.add(0);
                numberOfProcessedOperationsPerRecord.put(requestId, 0);
                numberOfOperationsPerRecord.put(requestId, 1);
            }
            else {
                recordOperationIndexList.add(operationsNumber);
                numberOfOperationsPerRecord.put(requestId, operationsNumber + 1);
            }
        }   
    }   
    
    private static Map<String, String> getAssignmentsMap(){
        List<TQ_Local_Assignment__c> assignments = [SELECT Local_Id__c, Salesforce_Id__c FROM TQ_Local_Assignment__c
                                                    WHERE CreatedById = :UserInfo.getUserId()];
                                                    
        Map<String, String> assignmentsMap = new Map<String, String>();
        for (TQ_Local_Assignment__c assignement : assignments){
            assignmentsMap.put(assignement.Local_Id__c, assignement.Salesforce_Id__c);
        }
        return assignmentsMap;
    }  
}