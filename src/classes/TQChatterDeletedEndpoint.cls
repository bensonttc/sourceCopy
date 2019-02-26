@RestResource(urlMapping='/tqchatter/deleted/*')
global without sharing class TQChatterDeletedEndpoint {
	
	global class DeletedRecord{
		public DateTime deletedDate;
		public String id;
	}
	
	global class GetDeletedResult{
		public DateTime latestDateCovered;
		public DateTime earliestDateAvailable;
		public DeletedRecord[] deletedRecords;
		
		public GetDeletedResult(){
			deletedRecords = new List<DeletedRecord>();
		}
	}

	/**
	 *	Return the list of followers, with the email address if selected
	 */
	@HttpGet
    webservice static GetDeletedResult getDeletedFeedItems() {
    	RestRequest req = RestContext.request;
    	Datetime startDate = (Datetime)JSON.deserialize('"' + req.params.get('start') + '"', Datetime.class); 
    	Datetime endDate = (Datetime)JSON.deserialize('"' + req.params.get('end') + '"', Datetime.class);
    	
    	Database.GetDeletedResult deletionsResult = Database.getDeleted('FeedItem', startDate, endDate);
    	GetDeletedResult response = new GetDeletedResult();
    	response.earliestDateAvailable = deletionsResult.getEarliestDateAvailable();
    	response.latestDateCovered = deletionsResult.getLatestDateCovered();
    	
    	for (Database.DeletedRecord record : deletionsResult.getDeletedRecords()){
    		DeletedRecord deletedRecordResponse = new DeletedRecord();
    		deletedRecordResponse.id = record.getId();
    		deletedRecordResponse.deletedDate = record.getDeletedDate();
    		
    		response.deletedRecords.add(deletedRecordResponse);
    	}
    	
    	return response;
	}	
}