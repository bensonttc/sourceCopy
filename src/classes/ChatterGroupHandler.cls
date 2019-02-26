public with sharing class ChatterGroupHandler {

    public static final String customSettingsName = 'mtsApp';

    public static final Boolean shouldThrowPermissionErrors = false;

    public static Boolean ignoreTDAssignments = false;

    public static App_Settings__c settings = App_Settings__c.getValues(customSettingsName);

    public static void createChatterGroupsForTourInstances(List<Tour_Instance__c> tourInstanceList){
        createChatterGroupsForTourInstances(tourInstanceList, false);
    }

    public static Boolean shouldGroupBeInactive(Date startDate, Date endDate){
        if (settings == null){
            return null;
        } else {
                Integer upcomingDays = 30, pastDays = 30;
                if (settings.Upcoming_Trip_Activation_In_Days__c != null ){
                    upcomingDays = settings.Upcoming_Trip_Activation_In_Days__c.intValue();
                }
                if (settings.Past_Trip_Deactivation_In_Days__c != null){
                    pastDays = settings.Past_Trip_Deactivation_In_Days__c.intValue();
                }
                return (startDate  > Date.today().addDays(upcomingDays)) ||
                        (endDate < Date.today().addDays(-pastDays));
        }
    }

    public static void createChatterGroupsForTourInstances(List<Tour_Instance__c> tourInstanceList, Boolean doSync){
        Map<Id, Boolean> createdGroupActivityMap = new Map<Id, Boolean>();
        Map<Id, String> tourInstanceNamesMap = new Map<Id, String>();
        Map<Id, Id> travelDirectorsMap = new Map<Id, Id>();

        settings = App_Settings__c.getValues(customSettingsName);
        if (settings != null) {
            for (Tour_Instance__c tourInstance : tourInstanceList){
                System.debug('tourInstance ' + tourInstance);
                if (tourInstance.Chatter_Group_Id__c == null){
                    Boolean groupShouldBeInactive = shouldGroupBeInactive(tourInstance.Start_Date__c, tourInstance.End_Date__C);
                    tourInstanceNamesMap.put(tourInstance.Id, tourInstance.Instance_Code__c);
                    createdGroupActivityMap.put(tourInstance.Id, groupShouldBeInactive);
                    if (tourInstance.Travel_Director__c != null){
                        travelDirectorsMap.put(tourInstance.Id, tourInstance.Travel_Director__c);
                    }
                }
            }

            if (doSync) {
                createRelatedChatterGroupsSync(createdGroupActivityMap, tourInstanceNamesMap, travelDirectorsMap);
            } else {
                createRelatedChatterGroups(createdGroupActivityMap, tourInstanceNamesMap, travelDirectorsMap);
            }
        }
    }

    public static void createChatterGroupMembersForPassengers(List<Passenger__c> passengerList, Map<Id, Passenger__c> oldValuesMap){
        settings = App_Settings__c.getValues(customSettingsName);

        List<CollaborationGroupMember> membersList = new List<CollaborationGroupMember>();
        Set<String> chatterGroupsToActivate = new Set<String>();
        Map<String, CollaborationGroupMember> membersMap = new Map<String, CollaborationGroupMember>();
        Map<String, Id> groupTravelDirectorMap = new Map<String, Id>();
        for (Passenger__c currentPassenger : passengerList){
            Passenger__c oldPassenger;
            if (oldValuesMap != null) {
              oldPassenger = oldValuesMap.get(currentPassenger.Id);
            }
            if ((
                  oldPassenger == null ||
                  oldPassenger.User__c != currentPassenger.User__c ||
                  oldPassenger.Tour_Instance__c != currentPassenger.Tour_Instance__c ||
                  oldPassenger.Booking_Status_Hidden__c != currentPassenger.Booking_Status_Hidden__c
                ) &&
                (currentPassenger.Booking_Status_Hidden__c == 'CO' || currentPassenger.Booking_Status_Hidden__c == 'UC' || currentPassenger.Booking_Status__c == 'CO' || currentPassenger.Booking_Status__c == 'UC') &&
                 currentPassenger.Chatter_Group_Id__c != null &&
                 currentPassenger.Tour_Instance__c != null &&
                 currentPassenger.User__c != null){
                    CollaborationGroupMember member = new CollaborationGroupMember();
                    member.MemberId = currentPassenger.User__c;
                    member.CollaborationGroupId = currentPassenger.Chatter_Group_Id__c;
                    member.NotificationFrequency = 'N';
                    membersList.add(member);

                    groupTravelDirectorMap.put(currentPassenger.Chatter_Group_Id__c, currentPassenger.Travel_Director__c);
                    if (shouldGroupBeInactive(currentPassenger.Tour_Start_Date__c, currentPassenger.Tour_End_Date__c) == false){
                        System.debug('Groups to activate:');
                        System.debug(chatterGroupsToActivate);

                        chatterGroupsToActivate.add(currentPassenger.Chatter_Group_Id__c);
                    }
            }
        }

        System.debug('Chatter user passengers to add: ' + membersList);

        if (membersList.size() > 0) {

            for (CollaborationGroupMember member : membersList)
                membersMap.put(member.CollaborationGroupId, member);

            List<CollaborationGroup> groupsToUpdate = new List<CollaborationGroup>();
            List<CollaborationGroup> groupsToActivate = new List<CollaborationGroup>();
            List<CollaborationGroupMember> membersCouldBeDeleted = [SELECT Id, CollaborationGroupId, MemberId
                    FROM CollaborationGroupMember
                    WHERE Member.AccountId = null
                    AND CollaborationGroupId IN :membersMap.keySet()
                    AND CollaborationRole = 'Admin'];
            List<CollaborationGroupMember> membersToDelete = new List<CollaborationGroupMember>();

            System.debug('Members fetched: ' + membersToDelete);

            for (CollaborationGroupMember oldOwner : membersCouldBeDeleted){
                if (oldOwner.memberId != groupTravelDirectorMap.get(oldOwner.CollaborationGroupId)){
                    membersToDelete.add(oldOwner);

                    groupsToUpdate.add(new CollaborationGroup(
                        Id = oldOwner.CollaborationGroupId,
                        OwnerId = membersMap.get(oldOwner.CollaborationGroupId).MemberId
                    ));

                    if (chatterGroupsToActivate.contains(oldOwner.CollaborationGroupId)){
                        groupsToActivate.add(new CollaborationGroup(
                            Id = oldOwner.CollaborationGroupId,
                            IsArchived = false
                        ));
                    }
                }
            }

            Database.insert(membersList, shouldThrowPermissionErrors);
            System.debug('new users inserted ' + membersList);

            System.debug('Groups to update owners:');
            System.debug(groupsToUpdate);

            System.debug('Members to delete and replace with passengers:');
            System.debug(membersToDelete);


            System.debug('Changing owners to groups');
            Database.update(groupsToUpdate, shouldThrowPermissionErrors);
            System.debug('Removing Sys Adming owners to Groups');
            Database.delete(membersToDelete, shouldThrowPermissionErrors);
            System.debug('Activating groups');
            Database.update(groupsToActivate, shouldThrowPermissionErrors);
        }
    }

    public static void assignTravelDirectorsForChatterGroup(List<Tour_Instance__c> tourInstanceList, Map<Id, Tour_Instance__c> oldValuesMap){
        if (ignoreTDAssignments == true) return;
        settings = App_Settings__c.getValues(customSettingsName);
        Set<String> chatterGroupIdsList = new Set<String>();
        //try {
            List<CollaborationGroupMember> directorsList = new List<CollaborationGroupMember>();
            List<CollaborationGroup> groupListToUpdate = new List<CollaborationGroup>();
            List<CollaborationGroup> groupListToActivate = new List<CollaborationGroup>();
            Map<String, Id> newGroupTD = new Map<String, Id>();
            for (Tour_Instance__c tourInstance : tourInstanceList){
                System.debug(tourInstance);
                Tour_Instance__c oldValue = oldValuesMap.get(tourInstance.Id);
                if (tourInstance.Chatter_Group_Id__c != null && tourInstance.Travel_Director__c != null
                    && (tourInstance.Travel_Director__c != oldValue.Travel_Director__c
                        || tourInstance.Chatter_Group_Id__c != oldValue.Chatter_Group_Id__c)){
                        directorsList.add(new CollaborationGroupMember(
                            MemberId = tourInstance.Travel_Director__c,
                            CollaborationGroupId = tourInstance.Chatter_Group_Id__c,
                            CollaborationRole = 'Admin',
                            NotificationFrequency = 'N'
                        ));

                        groupListToUpdate.add(new CollaborationGroup(
                            Id  = tourInstance.Chatter_Group_Id__c,
                            OwnerId = tourInstance.Travel_Director__c
                        ));
                        groupListToActivate.add(new CollaborationGroup(
                            Id  = tourInstance.Chatter_Group_Id__c,
                            IsArchived = shouldGroupBeInactive(tourInstance.Start_Date__c, tourInstance.End_Date__c)
                        ));

                        newGroupTD.put(tourInstance.Chatter_Group_Id__c, tourInstance.Travel_Director__c);

                        if (tourInstance.Travel_Director__c != oldValue.Travel_Director__c){
                            chatterGroupIdsList.add(tourInstance.Chatter_Group_Id__c);
                        }
                    }
            }

            List<CollaborationGroupMember> membersToDelete = new List<CollaborationGroupMember>(),
                                           membersToUpdate = new List<CollaborationGroupMember>();
            List<CollaborationGroupMember> oldMemberOwners = [SELECT Id, MemberId,
                    Member.AccountId, CollaborationRole, CollaborationGroupId
                    FROM CollaborationGroupMember
                    WHERE CollaborationGroupId IN :chatterGroupIdsList
                    AND CollaborationRole = 'Admin'];

            for (CollaborationGroupMember oldMember : oldMemberOwners){
                if ((Id)oldMember.Id != (Id)(newGroupTD.get(oldMember.CollaborationGroupId))){
                    if (oldMember.Member.AccountId == null){
                        membersToDelete.add(new CollaborationGroupMember(Id = oldMember.Id));
                    } else {
                        membersToUpdate.add(new CollaborationGroupMember(
                            Id = oldMember.Id, CollaborationRole = 'Member'
                        ));
                    }
                }
            }

            System.debug('GroupsList: ' + groupListToUpdate);
            System.debug('Members to delete: ' + membersToDelete);
            System.debug('Members to update: ' + membersToUpdate);

            Database.insert(directorsList, shouldThrowPermissionErrors);
            Database.update(groupListToUpdate, shouldThrowPermissionErrors);
            if (membersToDelete.size() > 0){
                Database.delete(membersToDelete, shouldThrowPermissionErrors);
            }
            if (membersToUpdate.size() > 0){
                Database.update(membersToUpdate, shouldThrowPermissionErrors);
            }
            Database.update(groupListToActivate, shouldThrowPermissionErrors);
    }

    public static void removeGroupMemberForCancelledBookings(List<Passenger__c> passengerList){
        
        Set<Id> passengersToBeRemovedIds = new Set<Id>();
        
        for (Passenger__c pass : passengerList){
            
            Passenger__c oldPass = (Passenger__c) trigger.oldMap.get(pass.Id);
            
            if (pass.Booking_Status_Hidden__c != oldPass.Booking_Status_Hidden__c && pass.Booking_Status_Hidden__c != 'CO' && pass.Booking_Status_Hidden__c != 'UC' && pass.Chatter_Group_Id__c != Null && pass.User__c != Null && pass.Tour_Instance__c != Null){
                
                passengersToBeRemovedIds.add(pass.Id);
            
            }
        
        }
        
        removeGroupMembersForBookings(passengersToBeRemovedIds);
    
    }

    public static void populatePassangersWithUserData(List<Passenger__c> passengersList){
        Set<Id> accountIdSet = new Set<Id>();
        for (Passenger__c passenger : passengersList){
            if (passenger.Account__c != null && passenger.User__c == null){
                accountIdSet.add(passenger.Account__c);
            }
        }

        if (accountIdSet.size() > 0) {
            List<User> userList = [SELECT Id, AccountId FROM User WHERE AccountId IN :accountIdSet];
            Map<Id, Id> accountUserMap = new Map<Id, Id>();
            for (User u : userList) {
                accountUserMap.put(u.AccountId, u.Id);
            }
            for (Passenger__c passenger : passengersList){
                if (passenger.Account__c != null && passenger.User__c == null &&
                    accountUserMap.get(passenger.Account__c) != null){
                    passenger.User__c = accountUserMap.get(passenger.Account__c);
                }
            }
        }
    }

    @future
    private static void removeGroupMembersForBookings(set<Id> passengersToBeRemovedIds){

        List<Passenger__c> passengersToBeRemoved = [SELECT Id, Chatter_Group_Id__c, User__c FROM Passenger__c WHERE Id IN :passengersToBeRemovedIds];
        
        List<CollaborationGroupMember> groupMembers = new List<CollaborationGroupMember>();

        Set<Id> usersIdsSet = new Set<Id>();
        Set<Id> chatterGroupIdsSet = new Set<Id>();
        Map<Id, Set<Id>> chatterGroupUserMap = new Map<Id, Set<Id>>();

        for (Passenger__c passenger : passengersToBeRemoved){
            if (passenger.Chatter_Group_Id__c != null && passenger.User__c != null){
                usersIdsSet.add(passenger.User__c);
                chatterGroupIdsSet.add(passenger.Chatter_Group_Id__c);
                if (!chatterGroupUserMap.containsKey(passenger.Chatter_Group_Id__c)){
                    chatterGroupUserMap.put(passenger.Chatter_Group_Id__c, new Set<Id>());
                }
                chatterGroupUserMap.get(passenger.Chatter_Group_Id__c).add(passenger.User__c);
            }
        }

        if (usersIdsSet.size() > 0 && chatterGroupIdsSet.size() > 0){
                List<CollaborationGroupMember> groupMembersForPassenger = [SELECT Id, MemberId,
                    CollaborationGroupId, CollaborationGroup.OwnerId
                    FROM CollaborationGroupMember
                    WHERE CollaborationGroupId IN :chatterGroupIdsSet
                    AND MemberId IN :usersIdsSet
                ];
                for (CollaborationGroupMember groupMember : groupMembersForPassenger){
                    Set<Id> groupUsersToRemove = chatterGroupUserMap.get(groupMember.CollaborationGroupId);
                    if (groupUsersToRemove != null && groupUsersToRemove.contains(groupMember.MemberId) &&
                        groupMember.CollaborationGroup.OwnerId != groupMember.MemberId){
                        groupMembers.add(new CollaborationGroupMember(Id = groupMember.Id));
                    }
                }
        }

        /*for (Passenger__c passenger : passengersForBookings){
            if (passenger.Chatter_Group_Id__c != null && passenger.User__c != null){
                List<CollaborationGroupMember> groupMembersForPassenger = [SELECT Id, MemberId, CollaborationGroup.OwnerId
                    FROM CollaborationGroupMember
                    WHERE CollaborationGroupId = :passenger.Chatter_Group_Id__c
                    AND MemberId = :passenger.User__c
                ];
                for (CollaborationGroupMember groupMember : groupMembersForPassenger){
                    if (groupMember.CollaborationGroup.OwnerId != groupMember.MemberId){
                        groupMembers.add(new CollaborationGroupMember(Id = groupMember.Id));
                    }
                }
                //groupMembers.addAll(groupMembersForPassenger);
            }
        }*/

        if (groupMembers.size() > 0){
            Database.delete(groupMembers, shouldThrowPermissionErrors);
        }
    }

    private static void createRelatedChatterGroupsSync(Map<Id, Boolean> createdGroupActivityMap,
                                                   Map<Id, String> tourInstanceNamesMap,
                                                   Map<Id, Id> travelDirectorsMap){
        String communityName = 'TOPS';
        Network network = [Select Id from Network Where Name = :communityName];
        Map<Id, CollaborationGroup> chatterGroupsMap = new Map<Id, CollaborationGroup>();
        for (Id tourIstanceId : createdGroupActivityMap.keySet()){
            CollaborationGroup chatterGroup = new CollaborationGroup(
                CanHaveGuests = false,
                CollaborationType = 'Private',
                Name = 'MTS-' +  tourInstanceNamesMap.get(tourIstanceId),
                IsAutoArchiveDisabled = true,
                IsArchived = createdGroupActivityMap.get(tourIstanceId)
            );

            Id directorId = travelDirectorsMap.get(tourIstanceId);
            if (directorId != null){
                chatterGroup.OwnerId = directorId;
            } else {
                chatterGroup.IsArchived = true;
            }

            try {
                chatterGroup.NetworkId = network.Id;
            } finally {
                chatterGroupsMap.put(tourIstanceId, chatterGroup);
            }
        }

        System.debug(chatterGroupsMap);

        Database.insert(chatterGroupsMap.values(), shouldThrowPermissionErrors);

        List<Tour_Instance__c> tourInstanceDataToUpdate = new List<Tour_Instance__c>();
        List<CollaborationGroup> groupsToActivateList = new List<CollaborationGroup>();
        for (Id tourInstanceId : chatterGroupsMap.keySet()){
            CollaborationGroup chatterGroup = chatterGroupsMap.get(tourInstanceId);
            tourInstanceDataToUpdate.add(new Tour_Instance__c(
                Id = tourInstanceId,
                Chatter_Group_Id__c = chatterGroup.Id
            ));

            /*if (createdGroupActivityMap.get(tourInstanceId) == false &&
                chatterGroup != null &&
                chatterGroup.Id != null){
                groupsToActivateList.add(
                    new CollaborationGroup(
                        Id = chatterGroup.Id,
                        IsArchived = false
                    )
                );
            }*/
        }

        System.debug('Result tour Instances to update: ');
        System.debug(tourInstanceDataToUpdate);

        ignoreTDAssignments = true;
        Database.update(tourInstanceDataToUpdate, shouldThrowPermissionErrors);
        //Database.update(groupsToActivateList, shouldThrowPermissionErrors);
        ignoreTDAssignments = false;
    }


    @future
    private static void createRelatedChatterGroups(Map<Id, Boolean> createdGroupActivityMap,
                                                   Map<Id, String> tourInstanceNamesMap,
                                                   Map<Id, Id> travelDirectorsMap){
        createRelatedChatterGroupsSync(createdGroupActivityMap, tourInstanceNamesMap, travelDirectorsMap);
    }
}