/**
 *  Chatter endpoint
 */
@RestResource(urlMapping='/tqchatter/*')
global with sharing class TQChatterEndpoint {

	/**
	 *	Return the list of followers, with the email address if selected
	 */
	@HttpPost
    webservice static List<User> getFilteredFollowers(String recordId) {
    	TQChatterService chatterService = new TQChatterService();
    	if (chatterService.isTourInstanceId(recordId))
    		return chatterService.getPassengerUsersForTourInstance(recordId);
    	else 
    		return chatterService.getFilteredFollowers(recordId);
	}
}