public interface TQIUploadService {
	//Recognize if sObject Id is local
	Boolean isLocalId(String id);
	
	//Recognize which DML operation should be done with object: insert, update or delete
	String getOperationType(sObject record);
	
	//Go through the all reference fields of sObject to replace all local Ids with all ids inserted before
	Boolean reassignLocalReferences(sObject recordObject, Map<String, String> assignmentMap);
	
	//Convert JSON string in request item to the sObject
	sObject deserializeSObject(TQUploadRequestItem requestItem, Map<String, Object> additionalData);
	
	//Fetch new sObject data after DML operation was finished successfully
	sObject getResultSObject(String objectApiName, String objectId);
	
	//Get map of related fields with local ids for the object
	Map<String, String> getUnresolvedRelatedFields(sObject recordObject);
	
	Boolean shouldForceSharingInDml(sObject sObjectToCheck, String operation);
	
	Database.SaveResult insertForceSharing(sObject sObjectToInsert);
	
	Database.SaveResult updateForceSharing(sObject sObjectToUpdate);
}