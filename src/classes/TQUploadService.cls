public without sharing class TQUploadService implements TQIUploadService{
    public static final String LocalIdPreffix = 'Local_';
    public static final String DELETE_OPERATION = 'DELETE';
    public static final String INSERT_OPERATION = 'INSERT';
    public static final String UPDATE_OPERATION = 'UPDATE';
    private static final String DefaultAppId = 'TquilaONE';
    private TQMetadataService metadataService;
    private TQDownloadService downloadService;
    
    public Map<String,List<String>> fieldListMap;
    public final String ClientAppId;
    
    private static final Set<String> fieldsToExclude = new Set<String>{'BillingAddress', 'BillingAddres', 'ShippingAddress'};

    
    public TQUploadService(){
        this(DefaultAppId);
    } 
    
    public TQUploadService(String clientAppId){
        this.ClientAppId = clientAppId;
        metadataService = new TQMetadataService(ClientAppId);
        downloadService = new TQDownloadService(ClientAppId);
        fieldListMap = getObjectFieldListMap();
    } 
    
    //Initialize for each sObject type all the required fields, which should be returned in upload response
    private Map<String, List<String>> getObjectFieldListMap(){
        Map<String, List<String>> fieldListMap = new Map<String, List<String>>();
        
        Map<String, TQ_Tracked_Object_Config__c> objectsSetting = TQTrackingUtils.getObjects(ClientAppId);
        
        //Check on the argument
        for (String objectAPIName : objectsSetting.keySet()) {
            
                List<String> fieldsSet = new List<String>();
                Set<String> includedFields = new Set<String>();
                
                Map<String, List<String>> trackedObjectFieldSetsMap = metadataService.trackedObjectFieldSets(objectApiName);
                for(String trackedObjectFieldSetName : trackedObjectFieldSetsMap.keySet()) {
                    for(String trackedObjectField : trackedObjectFieldSetsMap.get(trackedObjectFieldSetName)) {
                        if (!includedFields.contains(trackedObjectField)) {
                            fieldsSet.add(trackedObjectField);
                            includedFields.add(trackedObjectField);
                        }
                    }
                }
                
                // Add all the fields if no field sets are specified in the custom setting
                // RawRecordFieldSet contains detailFieldSet + Required fields + relathionship fields + system fields
                fieldsSet = (fieldsSet == null || fieldsSet.size() == 0)
                    ? metadataService.getAllFieldSet(objectApiName)
                    : metadataService.getFullRecordFieldSet(objectApiName, fieldsSet);
                
               fieldListMap.put(objectApiName, fieldsSet); 
        }       
        return fieldListMap;        
    }
    
    //Make List of strings unique removing all the repetitive elements
    @TestVisible
    private List<String> getUniqueArray(List<String> stringList){
        List<String> resultList = new List<String>();
        Set<String> stringSet = new Set<String>();
        
        for (String val : stringList){
            //If element was not added to resulting array before
            if (!stringSet.contains(val)) {
                resultList.add(val);
                stringSet.add(val);
            }
        }
        
        return resultList;
    }
    
    //Recognize if sObject Id is local
    public Boolean isLocalId(String id){
        return id.startsWith(LocalIdPreffix);
    }
    
    //Recognize which DML operation should be done with object: insert, update or delete
    public String getOperationType(sObject record){
        String recordId = (String)record.get('Id');
        Schema.Describesobjectresult objDescribe = record.getSObjectType().getDescribe();
        
        if (objDescribe.isDeletable() && record.get('isDeleted') != null && record.get('isDeleted') == true){        
            return DELETE_OPERATION;
        }
        else if (isLocalId(recordId)){
            return INSERT_OPERATION;
        }
        else 
            return UPDATE_OPERATION;
    }
    
    
    //Go through the all reference fields of sObject to replace all local Ids with all ids inserted before
    public Boolean reassignLocalReferences(sObject recordObject, Map<String, String> assignmentMap){
        Boolean assignmentComplete = true;
        String sObjectId = (String)recordObject.get('Id');
        recordObject.put('Id', null);
        Schema.DescribeSObjectResult objectDescribe = recordObject.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldDescribeMap = objectDescribe.fields.getMap();
        Type objectType = Type.forName(objectDescribe.getName());

        for (String fieldName : fieldDescribeMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldDescribeMap.get(fieldName).getDescribe();
            
            //Check if field is Lookup or Parent-Child field to replace it
            if (fieldName != 'Id' && fieldDescribe.getType() == Schema.Displaytype.Reference){
                Object fieldValue = recordObject.get(fieldName);
                if (fieldValue != null &&  fieldValue instanceof String) {
                    String stringValue = String.valueOf(fieldValue);
                    if (isLocalId(stringValue)){
                        if (assignmentMap.containsKey(stringValue)) {
                            // Replace local Id of Lookup with the actual one
                            String assignedId = assignmentMap.get(stringValue);
                            recordObject.put(fieldName, assignedId);
                        } 
                        else
                            // sObject still does not contains assigned fields so should be processed later
                            assignmentComplete = false;
                    }
                }
            }
        }
        
        recordObject.put('Id', sObjectId);
        
        return assignmentComplete;
    }
    
    //Convert JSON string in request item to the sObject
    public sObject deserializeSObject(TQUploadRequestItem requestItem, Map<String, Object> additionalData){
        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(requestItem.record);
        Map<String, Blob> blobDataMap = new Map<String, Blob>();
        
        Map<String, Schema.DescribeFieldResult> fieldDescriptionMap = metadataService.getFieldDescriptionMap(requestItem.objectApiName);
        if (fieldDescriptionMap != null){
            for (String key : dataMap.keySet()){
                Schema.DescribeFieldResult fieldDescribe = fieldDescriptionMap.get(key);
                Object fieldValue = dataMap.get(key);

                if (key == 'TQ_Attachment_Link__c' && fieldValue != null && fieldValue instanceof String) {
                    Blob dataBlob = null;

                    try {
                        dataBlob = EncodingUtil.base64Decode((String) fieldValue);
                        if (dataMap.containsKey('TQ_Attachment_FileName__c')){
                            additionalData.put('TQ_Attachment_FileName__c' , '' + 
                                               dataMap.get('TQ_Attachment_FileName__c'));
                        }
                        else
                            additionalData.put('TQ_Attachment_FileName__c' , 'MomentFile.jpg');
                        
                        additionalData.put('AttachmentData', dataBlob);
                        dataMap.remove(key);
                    } catch(Exception e) {
                        // nothing to do...
                    }
                }
                
                
                if (fieldDescribe != null && fieldDescribe.getType() == Schema.Displaytype.base64 &&
                    fieldValue != null && fieldValue instanceof String){
                    Blob DataBlob = EncodingUtil.base64Decode((String) fieldValue);
                    blobDataMap.put(key, DataBlob);
                    dataMap.remove(key);
                }
                
                if (fieldDescribe == null) {
                    dataMap.remove(key);
                }
            }
        }
        
        String cleanSObjectString = JSON.serialize(dataMap);
        
        Type objectType = Type.forName(requestItem.objectApiName);
        sObject resultObject = (sObject)JSON.deserializeStrict(cleanSObjectString, objectType);
        
        if (blobDataMap.size() > 0){
            Object objectId = resultObject.get('Id');
            resultObject.put('Id', null);
            
            for (String key : blobDataMap.keySet())
                resultObject.put(key, blobDataMap.get(key));
                
            if (objectId != null)
                resultObject.put('Id', objectId);
        }
                
        //sObject resultObject = (sObject)JSON.deserializeStrict(requestItem.record, objectType);
        
        return resultObject;
    }
    
    public Map<String, String> getUnresolvedRelatedFields(sObject recordObject){    
        Map<String, String> unresolvedFields = new Map<String, String>();
            
        Schema.DescribeSObjectResult objectDescribe = recordObject.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldDescribeMap = objectDescribe.fields.getMap();
        Type objectType = Type.forName(objectDescribe.getName());

        for (String fieldName : fieldDescribeMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldDescribeMap.get(fieldName).getDescribe();
            
            //Check if field is Lookup or Parent-Child field to replace it
            if (fieldName != 'Id' && fieldDescribe.getType() == Schema.Displaytype.Reference){
                Object fieldValue = recordObject.get(fieldName);
                if (fieldValue != null &&  fieldValue instanceof String) {
                    String stringValue = String.valueOf(fieldValue);
                    if (isLocalId(stringValue)){
                        unresolvedFields.put(fieldName, fieldDescribe.getLabel());
                    }
                }
            }
        }       
        
        return unresolvedFields;
    }
    
    //Fetch new sObject data after DML operation was finished successfully
    public sObject getResultSObject(String objectApiName, String objectId){
        List<String> fieldList = fieldListMap.get(objectApiName);
        if (fieldList == null || fieldList.size() == 0){
            fieldList = new List<String>{'Id'};
        }
        
        //Prepare list of select fields in query
        String fieldsString = '';
        for (String fieldName : fieldList){
        	if (fieldsToExclude.contains(fieldName) || (objectApiName == 'Account' && fieldName.endsWith('Address'))) continue;
            if (fieldsString != '')
                fieldsString += ', ';
            fieldsString += fieldName;
        }
        
        String whereClause = downloadService.calculateWhereClauseForObject(objectApiName, false);
        String query = 'SELECT ' + fieldsString + ' FROM ' + objectApiName + ' WHERE Id = \'' + objectId + '\'';
        if (whereClause != null)
            query += ' AND (' + whereClause + ')';
            
        List<sObject> resultObjects = Database.query(query);
        sObject resultObject = (resultObjects.size() > 0) ? resultObjects.get(0) : null;
        
        if (resultObject != null) {
            for (String fieldName : fieldList)
                try {
                    if (resultObject.get(fieldName) == null)
                        resultObject.put(fieldName, null);
                }
                catch (Exception e){
                }
        }
        return resultObject;
    }
    
    public Boolean shouldForceSharingInDml(sObject sObjectToCheck, String operation){   	
    	if ((sObjectToCheck instanceof Account || operation == TQUploadService.UPDATE_OPERATION) 
    		|| sObjectToCheck instanceof Marketing_Consent__c
    		|| sObjectToCheck instanceof Preferences__c) {
    		User currentUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
    		if (currentUser.Contact == null) return false;
    		if (sObjectToCheck instanceof Account)
    			return ((Id)sObjectToCheck.get('Id')) == currentUser.Contact.AccountId;
    		if (sObjectToCheck instanceof Marketing_Consent__c)
    			if (sObjectToCheck.get('Id') == null)
    				return ((Marketing_Consent__c)sObjectToCheck).Customer_Or_Prospect__c == currentUser.Contact.AccountId;
    			else {
    				Marketing_Consent__c consentToReturn = [SELECT Id, Customer_Or_Prospect__c 
    														FROM Marketing_Consent__c 
    														WHERE Id = :(Id)sObjectToCheck.get('Id')];
    				return consentToReturn.Customer_Or_Prospect__c == currentUser.Contact.AccountId;
    			}
    		if (sObjectToCheck instanceof Preferences__c)
    			if (sObjectToCheck.get('Id') == null)
    				return ((Preferences__c)sObjectToCheck).Customer_Or_Prospect__c == currentUser.Contact.AccountId;
    			else {
    				Preferences__c consentToReturn = [SELECT Id, Customer_Or_Prospect__c 
    														FROM Preferences__c
    														WHERE Id = :(Id)sObjectToCheck.get('Id')];
    				return consentToReturn.Customer_Or_Prospect__c == currentUser.Contact.AccountId;
    			}
    	}
    	
    	return false;
    }
    
    //Because this methods is executing in TQUploadService class which is without sharing, 
    //all operations done here will be executed successfully
    public Database.SaveResult insertForceSharing(sObject sObjectToInsert){
    	return Database.insert(sObjectToInsert, false);
    }
            
    //Because this methods is executing in TQUploadService class which is without sharing, 
    //all operations done here will be executed successfully
    public Database.SaveResult updateForceSharing(sObject sObjectToUpdate){
    	return Database.update(sObjectToUpdate, false);
    }
}