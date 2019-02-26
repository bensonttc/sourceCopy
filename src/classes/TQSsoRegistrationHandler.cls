/**
 *  TTC SSO Registration Hanler 
 *
 */
global class TQSsoRegistrationHandler implements Auth.RegistrationHandler {

    public static final String ACCOUNT_RECORD_TYPE_CUSTOMER = 'Prospect';
    //Customer community plus user is deprecated, new user will be used instead of it
    //private static final String CUSTOMER_PROFILE_NAME = 'TTC Guest User (CC Plus)';
    private static final String CUSTOMER_PROFILE_NAME = 'MTS Guest User';
    private static final String MTS_CUSTOM_SETTING_NAME = 'mtsApp';

    /**
     *  Verify if the running user can create user
     */
    global boolean canCreateUser(Auth.UserData data) {
        return true;
    }

    /**
     *  Create the User - as the first time that he has accessed it
     */
    global User createUser(Id portalId, Auth.UserData data) {
        System.debug('TTC SSO Integration - Creation on profileId ' + portalId + ' and Data ' + data);

        // Get the value of the SSO Global User Identifier
        String ssoGUID = data.identifier;

        // Check if the User already exists
        List<User> existingUsers = [SELECT Id, profileId, contactId, isActive FROM User WHERE SSO_Identifier__c = :ssoGUID];
        if(existingUsers != null && existingUsers.size() > 0) {
            return validateCommunityUser(existingUsers.get(0));
        }

        // Create a new user 
        else {
            // Block the user if he can't create new users
            if(!canCreateUser(data)) {
                //Returning null or throwing an exception fails the SSO flow
                System.debug('Registration.createUser: Error can\'t create users ' + data);
                return null;
            }

            // Parse user's info, checking if the full name is defined or not
            String firstName, lastName, dataFirstName, dataLastName, dataFullName;
            dataFirstName = '' + data.firstName;
            dataLastName = '' + data.lastName;
            dataFullName = '' + data.fullName;

            if(dataFirstName == null || dataFirstName.length() == 0 || dataFirstName.equalsIgnoreCase('null')
                || dataLastName == null || dataLastName.length() == 0 || dataLastName.equalsIgnoreCase('null')) {
                // Use the full name
                if(dataFullName != null && dataFullName.length() > 0 && !dataFullName.equalsIgnoreCase('null')) {
                    firstName = dataFullName.substringBefore(' ');
                    lastName = dataFullName.substringAfter(' ');
                } else {
                    System.debug('Registration.createUser: Error creating user, no name defined ' + data);
                    return null;
                }
            } else {
                firstName = dataFirstName;
                lastName = dataLastName;
            }

            // Get user's email
            String email = data.email;
            if(email == null || email.length() == 0) {
                System.debug('Registration.createUser: Error creating user, no email ' + data);
                return null;
            }

            // Query the person account to see if an existing record is available
            List<Account> existingPersonAccounts = [Select Id, PersonContactId From Account 
                Where PersonEmail LIKE :email AND Name = :dataFullName LIMIT 1];
            
            // Check if the person account actually exists or if it needs to be created
            Account customerPA = null;
            if(existingPersonAccounts == null || existingPersonAccounts.size() == 0) {
                // Create the Account
                Map<String, String> accountRecordTypeMap = getRecordTypeMap('Account');
                customerPA = new Account(
                    RecordTypeId = accountRecordTypeMap.get(ACCOUNT_RECORD_TYPE_CUSTOMER),
                    FirstName = firstName,
                    LastName = lastName, 
                    PersonEmail = email
                );
                insert customerPA;

                List<Account> personAccounts = [Select PersonContactId From Account Where Id = :customerPA.Id];
                customerPA = personAccounts.get(0);
            } else {
                // Get the existing one
                customerPA = existingPersonAccounts.get(0);
            }
            
            // Check the contact side of the PA has been created
            if(customerPA == null || customerPA.PersonContactId == null) {
                System.debug('Registration.createUser: Error creating user, no PersonContactId found on PersonAccount on ' + customerPA);
                return null;
            }

            // Check if an existing user is already been associated to the found / created PersonAccount
            List<User> existingCommunityUser = [SELECT Id, ProfileId, isActive FROM User WHERE contactId = :customerPA.PersonContactId];
            User communityUser = null;
            if(existingCommunityUser != null && existingCommunityUser.size() > 0) {
                communityUser = validateCommunityUser(existingCommunityUser.get(0));
            } else {
                //Alias must be 8 characters or less
                String alias = email;
                if(alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }

                // Create the user
                communityUser = new User(
                    username = getUsernamePrefix() + email + getUsernameSuffix(),
                    email = email,
                    lastName = lastName,
                    firstName = firstName,
                    alias = alias,
                    emailencodingkey = 'UTF-8',
                    languagelocalekey = 'en_US', 
                    localesidkey = 'en_GB', 
                    timezonesidkey = 'GMT',
                    UserRoleId = null,
                    //languagelocalekey = UserInfo.getLocale(),
                    //localesidkey = UserInfo.getLocale(),
                    profileId = getProfile().Id,
                    contactId = customerPA.PersonContactId,
                    SSO_Identifier__c = ssoGUID,
                    ReceivesInfoEmails = false,
                    UserPreferencesDisableAllFeedsEmail = true,
                    UserPreferencesDisableBookmarkEmail = true,
                    UserPreferencesDisableChangeCommentEmail = true,
                    UserPreferencesDisableEndorsementEmail = true,
                    UserPreferencesDisableFollowersEmail = true,
                    UserPreferencesDisableLaterCommentEmail = true,
                    UserPreferencesDisableLikeEmail = true,
                    UserPreferencesDisableMentionsPostEmail = true,
                    UserPreferencesDisableMessageEmail = true,
                    UserPreferencesDisableProfilePostEmail = true,
                    UserPreferencesDisProfPostCommentEmail = true,
                    UserPreferencesDisCommentAfterLikeEmail = true,
                    UserPreferencesShowProfilePicToGuestUsers = true
                );
            }

            return communityUser;
        }
    }

    /**
     *  Update the user all the times he's coming back
     */
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        System.debug('TTC SSO Integration - Update on profileId ' + portalId + ' and Data ' + data + ' userId ' + userId); 

        String ssoGUID = data.identifier;
        
        // Check if the User already exists
        List<User> users = [SELECT Email FROM User WHERE SSO_Identifier__c = :ssoGUID];

        if(users == null || users.size() != 1) {
            System.debug('Registration.updateUser: Error finding user ' + userId);
        } else {
            User user = users.get(0);
            if(user != null) {
                if(data.email != null && data.email.length() > 0) {
                    user.Email = data.email;

                    try {
                        update user;
                    } catch(Exception e) {
                        System.debug('Registration.updateUser: Exception in updating the user ' + e.getMessage());
                    }
                } else {
                    System.debug('Registration.updateUser: New email error ' + data);
                }
            } else {
                System.debug('Registration.updateUser: Error finding user ' + userId + ' user is blank');
            }
        }
    }

    /**
     *  Recort Type Map management
     */
    public static Map<String, String> getRecordTypeMap(String objectApiName) {
        Map<String,String> accountRecordTypesMap = new Map<String,String>{};
        
        for(RecordType rt : [Select Name, Id From RecordType where sObjectType=:objectApiName and isActive=true]) {
            accountRecordTypesMap.put(rt.Name, rt.Id);
        }
        return accountRecordTypesMap;
    }

    /**
    * Get the app settings
    */
    private static App_Settings__c getAppSettings() {
        return App_Settings__c.getValues(MTS_CUSTOM_SETTING_NAME);
    }

    /**
    * Return the prefix to use for the username prefix
    */
    public static String getUsernamePrefix() {
        App_Settings__c appSettings = getAppSettings();
        return appSettings != null && appSettings.Username_Prefix__c != null 
            ? appSettings.Username_Prefix__c : '';
    }

    /**
    * Return the prefix to use for the username prefix
    */
    public static String getUsernameSuffix() {
        App_Settings__c appSettings = getAppSettings();
        return appSettings != null && appSettings.Username_Suffix__c != null 
            ? appSettings.Username_Suffix__c : '';
    }

    /**
    * Return the name of the profile that must be used
    */
    private static String getProfileName() {
        App_Settings__c appSettings = getAppSettings();
        return appSettings != null && appSettings.Guest_Profile_Name__c != null 
            ? appSettings.Guest_Profile_Name__c : CUSTOMER_PROFILE_NAME;
    }

    /**
    * Return the profile that must be used
    */
    public static Profile getProfile() {
        return [SELECT Id FROM profile WHERE name=:getProfileName()];
    }

    /**
    * Validate the community user record
    */
    private User validateCommunityUser(User communityUser) {
        if(communityUser == null) {
            System.debug('Registration.validateCommunityUser: Argument is null');
            return null;
        } else {
            // Verify if the user has the right profile
            if(checkCommunityUserProfile(communityUser)) {
                return validateCommunityUserActive(communityUser);
            } else {
                System.debug('Registration.createUser: Existing User with unexpected profile ' + communityUser);
                return null;
            }
        }
    }

    /**
    * Check if the community user profile is the expected one
    */
    private Boolean checkCommunityUserProfile(User communityUser) {
        // Check if the profile is the expected one
        return communityUser != null && (communityUser.ProfileId == getProfile().Id || communityUser.ContactId != null);
    }

    /**
    * Validate if the community user is active. If not, activate the record
    */
    private User validateCommunityUserActive(User communityUser) {
        if(communityUser != null) {
            // Switch the active flag
            if(!communityUser.isActive) {
                communityUser.isActive = true;
                try {
                    update communityUser;
                } catch(Exception e) {
                    System.debug('Registration.validateCommunityUserActive: Exception activating the community user ' + communityUser + ' ' + e.getMessage());
                    return null;
                }
            }

            return communityUser;
        } else {
            System.debug('Registration.validateCommunityUserActive: Existing User is null');
            return null;
        }
    }
            
}