/**
 *	Trigger Handler for the User Trigger
 */
public with sharing class TQUserTriggerHandler {

	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    @testvisible
    private static Boolean ignorePassengerAssignment = false;


    /**
	 *	Default Constructor
	 */
	public TQUserTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

     /**
     *  Before insert handler
     */
    public void OnBeforeInsert(List<User> newUsers) {
    	// Report email
    	for(User user : newUsers) {
    		user.Email__c = user.Email;
    	}
        
    }

    /**
     *  After insert handler
     */
    public void OnAfterInsert(List<User> newUsers, Map<Id, User> newUsersMap) {
    	// Make sure the new users have editing permissions on their related Person Accounts
        List<Id> newUserIds = new List<Id>();
        Map<Id,Id> userAccountMap = new Map<Id, Id>();
        for(User user : newUsers) {
            newUserIds.add(user.Id);
            if (user.AccountId != null){
            	userAccountMap.put(user.AccountId, user.Id);
            }
        }
    	ensureEditingOnPersonAccount(newUserIds);
    	
    	if (userAccountMap.size() > 0 && !TQUserTriggerHandler.ignorePassengerAssignment &&
    		!System.isFuture() && !System.isBatch()) {
    		populatePassengerUserLookups(userAccountMap);
    	}
    }

    /**
     *  Before update handler
     */
    public void OnBeforeUpdate(List<User> newUsers) {
        
    }

    /**
     *  After update handler
     */
    public void OnAfterUpdate(List<User> Users, Map<Id, User> oldUsersMap) {
        
    }

    /**
     *  Extend the visibility of the new community users to their related person accounts
     */
    @future
    private static void ensureEditingOnPersonAccount(List<Id> newUserIds) {
    	try {
	        // Fetch the existing Portal-related account rules
	        List<AccountShare> accountShares = [SELECT AccountAccessLevel, ContactAccessLevel FROM AccountShare 
	            WHERE UserOrGroupId IN :newUserIds AND RowCause = 'PortalImplicit'];
	
	        for(AccountShare accountShare : accountShares) {
	            accountShare.AccountAccessLevel = 'Edit';
	            //accountShare.ContactAccessLevel = 'Edit';
	        }
	    	update accountShares;
    	} catch (Exception e){
    		System.debug('Cannot update');
    	}
    }

	@future
	private static void populatePassengerUserLookups(Map<Id, Id> accountUserMap){
		List<Passenger__c> unassignedPassengers = [SELECT Id, User__c, Account__c
												   FROM Passenger__c 
												   WHERE Account__c IN :accountUserMap.keySet()];
		for (Passenger__c passenger : unassignedPassengers){
			passenger.User__c = accountUserMap.get(passenger.Account__c);
		}
		
		Database.update(unassignedPassengers, false);
	}
}