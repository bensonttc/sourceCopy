/**
 *  Controller for the Attachment 
 */
 public without sharing class TQAttachmentController{
    
    /**
     *  Default controller
     */
    public TQAttachmentController() {}

    /**
     *  Attachment ID
     */
    public String attachmentID { get; set; }
    public String result { get; set; }
    public class AttachmentData {
    	public String name {get; set;}
    	public String contentType {get; set;}
    	public Blob body {get; set;}
    	public Id CreatedById {get; set;}
    	public Datetime CreatedDate {get; set;}
    	public String text{get; set;}
    	public String objectType{get; set;}
    	public String userName{get; set;}
    	public String userAvatarUrl{get; set;}
    }

	public AttachmentData attachmentInfo {get; private set;}
	public String attachmentBase64 {get; private set;}

    private final static String FOLDER_NAME = 'MTS_Shared_Attachments';

    public PageReference dispatch() {

        // Try to get the operation type
        String operation = null;
        try {
            operation = (String) ApexPages.currentPage().getParameters().get('operation');
        } catch(Exception e) {
            System.debug('Exception in reading the operation' + e.getMessage());
            return null;
        }

        // Get the record Id
        Id recordID = null;
        try {
            recordID = (Id) ApexPages.currentPage().getParameters().get('recordID');
        } catch(Exception e) {
            System.debug('Exception in reading the recordID' + e.getMessage());
            return null;
        }

        // Invoke the right method
        if(operation.equalsIgnoreCase('share')) {
            return returnAttachment(recordID);
        } else if(operation.equalsIgnoreCase('delete')) {
            return deleteAttachment(recordID);
        } else {
            System.debug('Operation not found: ' + operation);
            return null;
        }
    }
    
    private AttachmentData getAttachmentData(Id recordId, Boolean fetchAllData){
    	AttachmentData resultData = new AttachmentData();
        List<Attachment> attachmentsList = [SELECT Id, Name, ContentType, Body, CreatedById, CreatedDate, ParentId
            FROM Attachment 
            WHERE ParentId = :recordID
            ORDER BY LastModifiedDate DESC];
        if(attachmentsList != null && attachmentsList.size() > 0 && attachmentsList.get(0) != null) {
            // Get the attachment
            Attachment attachment = attachmentsList.get(0);
            resultData.Name = attachment.Name;
            resultData.ContentType = (attachment.ContentType == null) ? 'img/jpg' : attachment.ContentType;
            resultData.Body = attachment.Body;
            resultData.ObjectType = 'Attachment';
            
            try {
            	resultData.CreatedById = attachment.CreatedById;
            	resultData.CreatedDate = attachment.CreatedDate;
            } finally {
           	  System.debug(resultData);          	
            }
            
            if (fetchAllData) {
            	List<Moment__c> attachmentMoment = [SELECT Id, Body__c 
            		FROM Moment__c 
            		WHERE Id = :attachment.ParentId];
            	if (attachmentMoment != null && attachmentMoment.size() > 0){
            		resultData.Text = attachmentMoment.get(0).Body__c;
            	}
            }
        } 
        // Try to load it as a Feed Item
        else {
            List<FeedItem> feedItemsList = [SELECT Id, ContentFileName, ContentType, ContentData, Body,
            								CreatedById, CreatedDate
            FROM FeedItem 
            WHERE Id = :recordID
            ORDER BY LastModifiedDate DESC];
            if(feedItemsList != null && feedItemsList.size() > 0 && feedItemsList.get(0) != null) {
                // Get the attachment
                FeedItem feedItem = feedItemsList.get(0);
                resultData.Name = feedItem.ContentFileName;
                resultData.ContentType = feedItem.ContentType;
                resultData.Body = feedItem.ContentData;
                resultData.Text = feedItem.Body;
                resultData.ObjectType = 'FeedItem';
                try {
                	resultData.CreatedById = feedItem.CreatedById;
                	resultData.CreatedDate = feedItem.CreatedDate;
                } finally {
                	System.debug(resultData);
                }
            } else if (fetchAllData) {
            	List<Moment__c> momentList = [SELECT Id, Body__c, CreatedById, CreatedDate 
            		FROM Moment__c 
            		WHERE Id = :recordId
            		ORDER By LastModifiedDate DESC];
            		
            	if (momentList != null && momentList.size() > 0) {
            		Moment__c moment = momentList.get(0);
	                resultData.Text = moment.Body__c;
	                resultData.ObjectType = 'Moment';
                	resultData.CreatedById = moment.CreatedById;
                	resultData.CreatedDate = moment.CreatedDate; 		
            	}
            }
        }    
        
        if (fetchAllData && resultData.CreatedById != null){
        	User userData = [SELECT Id, Name, fullPhotoUrl FROM User WHERE Id = :resultData.CreatedById];
    		resultData.userName = userData.Name;
    		resultData.userAvatarUrl = userData.fullPhotoUrl;
        }
        
        return resultData;	
    }

    /**
     *  Return the attachment
     *  Expect a "recordID" get parameter
     */
    public PageReference returnAttachment(Id recordID) {
        if(recordID != null) {
            System.debug('ParentID is ' + recordID);
            // Generic variables, to be filled by either an attachment or a feed item
            //String documentName = null, documentContentType = null;
            //Blob documentBody = null;

			AttachmentData recordData = getAttachmentData(recordId, false);

            // Create the document, if the original has been found
            if(recordData.Name != null && recordData.ContentType != null && recordData.Body != null) {
                // Get the folder
                List<Folder> folders = [SELECT ID FROM Folder WHERE DeveloperName = :FOLDER_NAME];
                if(folders == null || folders.size() == 0) {
                    System.debug('TQAttachmentController: Folder ' + FOLDER_NAME + ' not found');
                    return null;
                }
                Folder folder = folders.get(0);

                // Create the document
                Document document = new Document();
                document.folderId = folder.Id;
                document.name = recordData.Name;
                document.contentType = 'image/png'; //recordData.ContentType;
                document.Body = recordData.Body;
                document.IsPublic = true;
                document.Description = recordID;

                try {
                    insert document;
                } catch(Exception e) {
                    System.debug('TQAttachmentController: error saving the new document ' + e.getMessage());    
                    return null;
                }

                String resultStr, currentHost = URL.getSalesforceBaseUrl().getHost();
                String genericHost = 'https://' + currentHost.substringAfter('.');
                resultStr = genericHost + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + UserInfo.getOrganizationId();

                TQAttachmentResponse attachResponse = new TQAttachmentResponse(resultStr);
                result = JSON.serialize(attachResponse);
            } else {
                System.debug('TQAttachmentController: required contents not found');    
            }
        } else {
            System.debug('TQAttachmentController: parameter recordID not found');   
        }
        return null;
    }

    /**
     *  Delete a document previously created for a specific attachment
     */
    public PageReference deleteAttachment(Id recordID) {
        Integer resultInt = null;

        if(recordID != null) {
            // Try to load the ID as a Moment
            List<Document> documentsList = [SELECT Id
                FROM Document
                WHERE Description = :recordID];

            if(documentsList != null && documentsList.size() > 0) {
                try {
                    delete documentsList;
                    resultInt = 0;
                } catch(Exception e) {
                    System.debug('TQAttachmentController: error deleting documents ' + e.getMessage()); 
                    resultInt = -2;
                    return null;
                }
            } else {
                resultInt = -3;
            }
        } else {
            System.debug('TQAttachmentController.deleteAttachment: parameter recordID not found');  
            resultInt = -1;
        }

        TQAttachmentResponse attachResponse = new TQAttachmentResponse(resultInt);
        result = JSON.serialize(attachResponse);

        return null;
    }
    
    public PageReference initSharePage(){
    	Id recordID = null;
        try {
            recordID = (Id) ApexPages.currentPage().getParameters().get('recordID');
        } catch(Exception e) {
            System.debug('Exception in reading the recordID' + e.getMessage());
            return null;
        }
        
        attachmentInfo = getAttachmentData(recordId, true);
        if (attachmentInfo.body != null){
        	attachmentBase64 = EncodingUtil.base64encode(attachmentInfo.body);
        }
        
    	return null;
    }

}