/**
 *	Test class for the SSO Registration handler
 */
@isTest
private class TQSsoRegistrationHandlerTest {
	
	/**
	 *	Create a brand new user
	 */
	@isTest static void createNewUser() {
		String firstName = 'first time user', lastName = 'sur name', email = 'acn@test.com';
		String fullName = firstName + ' ' + lastName;
		String identifier = '123882497938247239427394723', provider = 'Open ID Connect';
		Id portalId = null;

		Map<String,String> attributeMap = new Map<String,String>();
		attributeMap.put('email', email);
		attributeMap.put('name', fullName);
		attributeMap.put('sfdc_networkid', '12345');
		attributeMap.put('sub', identifier);

		// Simulate a callback from the SSO Provider
		Auth.UserData data = new Auth.UserData(identifier, null, null, fullName, email, null, null, null, provider, null, attributeMap);

		// Create the first time user
		TQSsoRegistrationHandler tqSSO = new TQSsoRegistrationHandler();
		User user = tqSSO.createUser(portalId, data);

		System.assertEquals(user.FirstName + ' ' + user.LastName, fullName);
		System.assertEquals(user.Email, email);
		System.assertEquals(user.SSO_Identifier__c, identifier);
		System.assert(user.contactId != null);
	}
	
	/**
	 *	Create a new user from an existing PersonAccount
	 */
	@isTest static void createNewUserExistingPersonAccount() {
		String firstName = 'first time user', lastName = 'sur name', email = 'acn@test.com';
		String fullName = firstName + ' ' + lastName;
		String identifier = '123882497938247239427394723', provider = 'Open ID Connect';
		Id portalId = null;

		Map<String,String> attributeMap = new Map<String,String>();
		attributeMap.put('email', email);
		attributeMap.put('name', fullName);
		attributeMap.put('sfdc_networkid', '12345');
		attributeMap.put('sub', identifier);

		// Simulate a callback from the SSO Provider
		Auth.UserData data = new Auth.UserData(identifier, null, null, fullName, email, null, null, null, provider, null, attributeMap);

		Map<String, String> accountRecordTypeMap = TQSsoRegistrationHandler.getRecordTypeMap('Account');
        Account customerPA = new Account(
            RecordTypeId = accountRecordTypeMap.get(TQSsoRegistrationHandler.ACCOUNT_RECORD_TYPE_CUSTOMER),
            FirstName = firstName,
            LastName = lastName, 
            PersonEmail = email
        );
        insert customerPA;
        List<Account> personAccounts = [Select PersonContactId From Account Where Id = :customerPA.Id];
		customerPA = personAccounts.get(0);

		// Create the first time user from an existing PersonAccount
		TQSsoRegistrationHandler tqSSO = new TQSsoRegistrationHandler();
		User user = tqSSO.createUser(portalId, data);

		System.assertEquals(user.FirstName + ' ' + user.LastName, fullName);
		System.assertEquals(user.Email, email);
		System.assertEquals(user.SSO_Identifier__c, identifier);
		System.assertEquals(user.contactId, customerPA.PersonContactId);
	}

	/**
	 *	Create a new user from an existing PersonAccount
	 */
	@isTest static void createNewUserExistingPersonAccountAndUser() {
		String firstName = 'first time user', lastName = 'sur name', email = 'acn@test.com';
		String fullName = firstName + ' ' + lastName;
		String identifier = '123882497938247239427394723', provider = 'Open ID Connect';
		Id portalId = null;
		User communityUser;
		TQSsoRegistrationHandler tqSSO = new TQSsoRegistrationHandler();

		Map<String,String> attributeMap = new Map<String,String>();
		attributeMap.put('email', email);
		attributeMap.put('name', fullName);
		attributeMap.put('sfdc_networkid', '12345');
		attributeMap.put('sub', identifier);

		// Simulate a callback from the SSO Provider
		Auth.UserData data = new Auth.UserData(identifier, null, null, fullName, email, null, null, null, provider, null, attributeMap);

		Map<String, String> accountRecordTypeMap = TQSsoRegistrationHandler.getRecordTypeMap('Account');
        Account customerPA = new Account(
            RecordTypeId = accountRecordTypeMap.get(TQSsoRegistrationHandler.ACCOUNT_RECORD_TYPE_CUSTOMER),
            FirstName = firstName,
            LastName = lastName, 
            PersonEmail = email
        );
        insert customerPA;
        List<Account> personAccounts = [Select PersonContactId From Account Where Id = :customerPA.Id];
		customerPA = personAccounts.get(0);

		// Create the user
		communityUser = new User(
            username = TQSsoRegistrationHandler.getUsernamePrefix() + email + TQSsoRegistrationHandler.getUsernameSuffix(),
            email = email,
            lastName = lastName,
            firstName = firstName,
            alias = 'Test34',
            emailencodingkey = 'UTF-8',
            languagelocalekey = 'en_US', 
            localesidkey = 'en_GB', 
            timezonesidkey = 'GMT',
            UserRoleId = null,
            //languagelocalekey = UserInfo.getLocale(),
            //localesidkey = UserInfo.getLocale(),
            profileId = TQSsoRegistrationHandler.getProfile().Id,
            contactId = customerPA.PersonContactId,
            SSO_Identifier__c = identifier
        );
        insert communityUser;

		// Create the first time user from an existing PersonAccount
		User user = tqSSO.createUser(portalId, data);

		System.assertEquals(user.Id, communityUser.Id);
	}

	/**
	 *	Create a new user from an existing PersonAccount
	 */
	@isTest static void returningRegisteredUser() {
		User currentUser = new User(Id = UserInfo.getUserId());
		Account customerPA;
		User communityUser;
		String firstName = 'first time user', lastName = 'sur name', email = 'acn@test.com';
		String fullName = firstName + ' ' + lastName;
		String identifier = '123882497938247239427394723', provider = 'Open ID Connect';
		Id portalId = null;

		Map<String,String> attributeMap = new Map<String,String>();
		attributeMap.put('email', email);
		attributeMap.put('name', fullName);
		attributeMap.put('sfdc_networkid', '12345');
		attributeMap.put('sub', identifier);
		
		Auth.UserData  data = new Auth.UserData(identifier, null, null, fullName, email, null, null, null, provider, null, attributeMap);
	
		Map<String, String> accountRecordTypeMap = TQSsoRegistrationHandler.getRecordTypeMap('Account');
        customerPA = new Account(
            RecordTypeId = accountRecordTypeMap.get(TQSsoRegistrationHandler.ACCOUNT_RECORD_TYPE_CUSTOMER),
            FirstName = firstName,
            LastName = lastName, 
            PersonEmail = email
        );
        insert customerPA;
	
		System.runAs(currentUser){
	        List<Account> personAccounts = [Select PersonContactId From Account Where Id = :customerPA.Id];
			customerPA = personAccounts.get(0);
	
			// Create the user
			communityUser = new User(
	            username = TQSsoRegistrationHandler.getUsernamePrefix() + email + TQSsoRegistrationHandler.getUsernameSuffix(),
	            email = email,
	            lastName = lastName,
	            firstName = firstName,
	            alias = 'Test34',
	            emailencodingkey = 'UTF-8',
	            languagelocalekey = 'en_US', 
	            localesidkey = 'en_GB', 
	            timezonesidkey = 'GMT',
	            UserRoleId = null,
	            //languagelocalekey = UserInfo.getLocale(),
	            //localesidkey = UserInfo.getLocale(),
	            profileId = TQSsoRegistrationHandler.getProfile().Id,
	            contactId = customerPA.PersonContactId,
	            SSO_Identifier__c = identifier
	        );
	        insert communityUser;
		}
        	
        
		Test.startTest();
        // Now change email
        String newEmail = 'newemail@a.com';
        data.email = newEmail;

		// Create the first time user from an existing PersonAccount
		TQSsoRegistrationHandler tqSSO = new TQSsoRegistrationHandler();
		User user = tqSSO.createUser(portalId, data);
		System.runAs(user){
			tqSSO.updateUser(null, portalId, data);
		}
		Test.stopTest();

		List<User> returningUsers = [SELECT Email FROM User WHERE Id = :communityUser.Id];
		if(returningUsers != null && returningUsers.size() > 0) {
			communityUser = returningUsers.get(0);
			System.assertEquals(communityUser.Email, newEmail);
		} else {
			System.assert(false);
		}
	}
	
}