/**
 * Class to host the endpoint of the Metadata WebService 
 */
@RestResource(urlMapping='/tqdownload/*')
global with sharing class TQDownloadEndpoint {
	
	/**
	 * Return download information on the tracked objects
	 * Keep the @ReadOnly annotation in order to be able to run the count on all the available records
	 */
	@HttpPost
	@ReadOnly
    webservice static TQDownloadResponse downloadRequest(String clientAppID, List<TQDownloadRequest> requestItemList) {
		//Init the sevice
		TQIDownloadService downloadService = new TQDownloadService(clientAppId);
		
    	// Prepare the response
    	TQDownloadResponse response = new TQDownloadResponse();
    	TQDownloadResponse.TQDownloadResponseItem responseItem = null;
    	
    	// Iterate on the full list of requests
    	if(requestItemList != null) {
    		List<TQDownloadResponse.TQDownloadResponseItem> responseItemList = new List<TQDownloadResponse.TQDownloadResponseItem>();
    		
    		for(TQDownloadRequest requestItem : requestItemList) {    			
				// Init responseItem holder     			
				responseItem = new TQDownloadResponse.TQDownloadResponseItem();
				responseItem.setStatus(TQWebServiceResponse.SUCCESS);
				
    			// Report basic info
				responseItem.setObjectApiName(requestItem.getObjectApiName());
				responseItem.setFromDateTime(requestItem.getFromDateTime());
				responseItem.setToDateTime(requestItem.getToDateTime());
				
				// Parse dates				
				DateTime fromDateTime = convertDateTime(requestItem.getFromDateTime());
				DateTime toDateTime = convertDateTime(requestItem.getToDateTime());
				
				TQDownloadObjectSyncType syncTypeWrap = null;
				try {
					syncTypeWrap = downloadService.computeObjectSyncType(requestItem.getObjectApiName(), fromDateTime, toDateTime);
					responseItem.setSyncType(syncTypeWrap.getSyncType());
					responseItem.setRecordCount(syncTypeWrap.getRecordCount());
				} catch(TQDownloadException de) {
					System.debug('Error fetching synctype ' + de.getMessage() + ' ' + de.getErrorCode());
					responseItem.setStatus(de.getErrorCode());
					responseItem.setError(de.getMessage());
				}
				
				// Compute the query if needed
				if(syncTypeWrap != null && (syncTypeWrap.getSyncType().equalsIgnoreCase(TQDownloadSyncType.FULL) 
						|| syncTypeWrap.getSyncType().equalsIgnoreCase(TQDownloadSyncType.INC))) {
					try {
						responseItem.setQuery(downloadService.computeObjectSyncQuery(requestItem.getObjectApiName(), fromDateTime, toDateTime));
					} catch(TQDownloadException de) {
						System.debug('Error fetching query ' + de.getMessage() + ' ' + de.getErrorCode());
						responseItem.setStatus(de.getErrorCode());
						responseItem.setError(de.getMessage());
					}
				}
				
				// Include the result in the main container
				responseItemList.add(responseItem);
    		}
    		
    		// Add responseItems to the main response 
    		response.setBody(responseItemList);
    		response.setStatus(TQWebServiceResponse.SUCCESS);
    	} else {
    		
    		// No items specified
    		response.setStatus(TQDownloadResponse.SERVER_ERROR_NOITEMS);
    		response.setError('No objects specified');
    	}
    	
    	return response;
    }
	
	/**
	 * Convert a String in a date / time
 	 * @param dateTimeStr String that represents a date. GMT, format is yyyy-MM-ddTHH:mm:ss.SSSZ
 	 * @returns converted DateTime
	 */
	private static DateTime convertDateTime(String dateTimeStr) {
		if(dateTimeStr != null && dateTimeStr.length() > 0) {
			try {
				// Clear the 'T'
				dateTimeStr = dateTimeStr.replaceAll('T', ' ');
				
				// Remove milliseconds
				dateTimeStr = dateTimeStr.substring(0, dateTimeStr.IndexOf('.'));
				
				//Parse and return
				return DateTime.valueOfGmt(dateTimeStr);
			} catch(Exception e) {
				System.debug('TQDownloadEndpoint.convertDateTime: Exception converting a datetime \'' + dateTimeStr + '\' Exception ' + e.getMessage());
				return null;
			}
		} else {
			System.debug('TQDownloadEndpoint.convertDateTime: Error converting a datetime - param not specified');
			return null;
		}
	}
}