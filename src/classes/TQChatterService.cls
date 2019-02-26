/**
 *  Chatter service
 */
public class TQChatterService {

    public TQChatterService() {}
    
    /**
     *    Post on a Chatter feed with an attachment
     */
    public ConnectApi.FeedElement post(FeedItem feedItem) {
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = feedItem.ParentId;
        
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = feedItem.Body;
        messageInput.messageSegments.add(textSegment);

        input.body = messageInput;
        
        ConnectApi.BinaryInput binInput = null;
        if(feedItem.ContentData != null) {
            ConnectApi.ContentCapabilityInput contentInput = new ConnectApi.ContentCapabilityInput();
            contentInput.title = feedItem.ContentFileName;
    
            ConnectApi.FeedElementCapabilitiesInput capabilities = new ConnectApi.FeedElementCapabilitiesInput();
            capabilities.content = contentInput;
    
            input.capabilities = capabilities;
        
            binInput = new ConnectApi.BinaryInput(feedItem.ContentData, 
                feedItem.ContentType == null ? 'text/plain' : feedItem.ContentType, feedItem.ContentFileName);    
        }    

        return ConnectApi.ChatterFeeds.postFeedElement(feedItem.NetworkScope, input, binInput);
    }

    /**
     *  Get all the followers of a specific record
     */
    public List<User> getFilteredFollowers(String recordId) {
        List<User> followersUsers = new List<User>();

        if(recordId != null) {
            // Get the sync records
            List<EntitySubscription> followers = [
                SELECT id, subscriberid, subscriber.AboutMe, subscriber.Name, subscriber.firstName, subscriber.lastName,
                subscriber.Email__c, subscriber.Show_My_Email_Address__c, subscriber.SmallPhotoUrl, subscriber.FullPhotoUrl
                FROM EntitySubscription 
                WHERE parentid = :recordId
                LIMIT 1000];

            // Parse the users
            User user = null;
            for(EntitySubscription entitySubscription : followers) {
                user = entitySubscription.subscriber;
                if(!user.Show_My_Email_Address__c) {
                    user.Email__c = null;
                }
                
                followersUsers.add(user);
            }
        }
        

        return followersUsers;
    }
    
    public Boolean isTourInstanceId(String recordId){
    	if (recordId == null) {
    		return false;
    	} else {
    		Schema.DescribeSObjectResult bookingComponentDescribe = Tour_Instance__c.sObjectType.getDescribe();
    		String prefix = bookingComponentDescribe.getKeyPrefix();
    		return String.valueOf(recordId).startsWithIgnoreCase(prefix);
    	}
    }
    
    public List<User> getPassengerUsersForTourInstance(String tourInstanceId){
    	List<User> followersUsers = new List<User>();
    	List<Passenger__c> passengers = [SELECT Id, User__r.Id, User__r.AboutMe, User__r.Name, User__r.firstName, 
    		User__r.lastName, User__r.Email__c, User__r.Show_My_Email_Address__c, User__r.SmallPhotoUrl, 
    		User__r.FullPhotoUrl FROM Passenger__c WHERE Tour_Instance__c = :tourInstanceId];
    		
    	// Parse the users
        User user = null;
        for(Passenger__c passenger : passengers) {
            user = passenger.User__r;
            if (user == null) continue;
            if(!user.Show_My_Email_Address__c) {
                user.Email__c = null;
            }
            
            followersUsers.add(user);
        }
        return followersUsers;
    }
    
}