/**
 * Class to host the endpoint of the Assignments WebService 
 */
@RestResource(urlMapping='/tqassignment/*')
global with sharing class TQAssignmentEndpoint {
	@HttpPost
    webservice static TQCommandResponse cleanRequest(String[] recordIdList, String deviceId) {
    	TQCommandResponse response = new TQCommandResponse();
    	try{
    		String userId = UserInfo.getUserId();
    		String query = 'SELECT Id FROM TQ_Local_Assignment__c WHERE CreatedById = :userId ';
    		if (recordIdList != null && recordIdList.size() > 0)
    			query += ' AND Local_Id__c IN :recordIdList ';
    		if (deviceId != null)
    			query += ' AND Device_Id__c = :deviceId ';
    			
    		List<sObject> assignmentsToDelete = Database.query(query);
    		delete assignmentsToDelete;
    		
    		response.setStatus(TQWebServiceResponse.SUCCESS);
    	}
    	catch (Exception e){
    		response.setStatus(TQWebServiceResponse.SERVER_GENERIC_ERROR);
    		response.setError(e.getMessage());
    	}
    	return response;
    }
}