@isTest
private class TQChatterServiceTest {
  
  @IsTest(SeeAllData=true)
  static void test_method_one() {
        String firstName = 'Nick', lastName = 'Tquila', email = 'nicola@tquila.com', username = 'nic1231242@tquila.com.121244';
    // Create tdAccount
        Account tdAccount = TQTestUtils.createAccount(firstname, lastname, email);
        insert tdAccount;
        // Create tour instance
        Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', null, 'opeProCode123', 'departureCode234',
          Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
        insert tourInstance;

    Test.startTest();
    FeedItem feedItem = new FeedItem();
    feedItem.ParentId = tourInstance.Id;
    feedItem.Body = 'Test of my message....';
    feedItem.ContentData = Blob.valueOf('data data dataaa');
    feedItem.ContentFileName = 'filename.txt';
    feedItem.NetworkScope = TqTestUtils.getCommunityID();

    TQChatterService chatterService = new TQChatterService();
    try {
      ConnectApi.FeedElement result = chatterService.post(feedItem);
      System.assert(result != null);
    } catch(Exception e) {
      System.debug('Fail to execute test ' + e);
    }

    Test.stopTest();
  }
  
  @IsTest
  static void testEmptyIdCheck(){
  	TQChatterService service = new TQChatterService();
  	System.assert(!service.isTourInstanceId(null));
  }
  
  @IsTest(SeeAllData=true)
  static void testTourInstanceFollowersInNewModel(){
  	String accountEmail='test@donotexists.com', accountName = 'Pablo', accountSurname = 'Escabar';
  	
    Account personAccount = TQTestUtils.createAccount(accountName, accountSurname, accountEmail);
    insert personAccount;
    
    User communityUser = TQTestUtils.createUser(personAccount.Id, accountName, accountSurname, accountEmail, accountEmail);
  	communityUser.Show_My_Email_Address__c = false;
  	communityUser.Email__c = accountEmail;
  	insert communityUser;
  
  	User currentUser = new User(Id = UserInfo.getUserId(), Is_Travel_Director__c = true);
  	update currentUser;
  	
  	Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', UserInfo.getUserId(), 'opeProCode123', 'departureCode234',
                					Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
    insert tourInstance;    
    
    Passenger__c newPassenger = new Passenger__c();
    newPassenger.Account__c = personAccount.Id;
    newPassenger.Tour_Instance__c = tourInstance.Id;
    newPassenger.User__c = communityUser.Id;
    newPassenger.Passenger_External_Id__c = 'TESTEXTERNALID';
    insert newPassenger;
    
  	Test.startTest();
  	TQChatterService service = new TQChatterService();
  	List<User> followersList = service.getPassengerUsersForTourInstance(tourInstance.Id);
  	Boolean isTourInstanceId = service.isTourInstanceId(tourInstance.Id);
  	Test.stopTest();
  	System.assert(isTourInstanceId);
  	System.assertEquals(followersList.size(), 1);
  	System.assertEquals(followersList.get(0).Email__c, null);
  	System.assertEquals(followersList.get(0).Id, communityUser.Id);
  }
  
  @IsTest
  static void test_ChatterFollowers() {
    String firstName = 'Nick', lastName = 'Tquila', email = 'nicola@tquila.com', username = 'nic1231242@tquila.com.121244';
    // Create tdAccount
    Account tdAccount = TQTestUtils.createAccount(firstname, lastname, email);
    insert tdAccount;
    // Create tour instance
    Tour_Instance__c tourInstance = TQTestUtils.createTourInstance('Test', null, 'opeProCode123', 'departureCode234',
          Date.newInstance(2015, 02, 20), Date.newInstance(2025, 02, 20), false);
        insert tourInstance;

    Network n = [Select Id from Network Where Name = :TQTestUtils.COMMUNITY_NAME];
        Id networkID = n != null ? n.Id : null;

        List<NetworkMember> networkMembers = [Select MemberId from NetworkMember WHERE NetworkId = :networkID LIMIT 100];

    Map<Id, NetworkMember> networkMemberIds = new Map<Id, NetworkMember>();
    for(NetworkMember nm : networkMembers) {
      networkMemberIds.put(nm.MemberId, nm);
    } 

    if(networkMemberIds.size() > 0) {
      Set<Id> networkMemberIdKeys = networkMemberIds.keySet();
      List<User> users = [Select Id FROM User WHERE Id IN :networkMemberIdKeys AND IsActive = true];

      Test.startTest();
          if(users != null && users.size() > 0) {
            Id memberId = users.get(0).Id;

          EntitySubscription follower = new EntitySubscription(
                    subscriberid=memberId,
                    ParentId=tourInstance.Id,
                    NetworkId=networkID
        );
        insert follower;

        List<User> followers = TQChatterEndpoint.getFilteredFollowers(tourInstance.Id);
        System.assert(followers != null);
          }

      Test.stopTest();
    }
  }
  
  
  @IsTest
  static void test_ChatterDeleted() {
    
    FeedItem feedItem = new FeedItem();
    feedItem.ParentId = UserInfo.getUserId();
    feedItem.Body = 'Test of my message....';
    insert feedItem;

      RestRequest req = new RestRequest();
      System.RestContext.request = req;
    DateTime startTime = DateTime.now().addHours(-1);
    DateTime endTime = DateTime.now().addHours(1);
    req.addParameter('start', JSON.serialize(startTime).replace('"', ''));
    req.addParameter('end', JSON.serialize(endTime).replace('"', ''));
    
    Test.startTest();
    delete feedItem;
    TQChatterDeletedEndpoint.GetDeletedResult result = TQChatterDeletedEndpoint.getDeletedFeedItems();
    System.assertEquals(1, result.deletedRecords.size());
    Test.stopTest();
  }
}