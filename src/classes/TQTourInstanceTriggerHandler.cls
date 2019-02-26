/**
 *  Class Name : TourInstanceTriggerHandler
 *  Called From : Tour Instance Trigger
 *  Purpose : 
 *  1) Update visibility of the Tour Instance to the associated TD
 *  2) Leo Alves - retiring code on behalf of Fergal
 **/
public with sharing class TQTourInstanceTriggerHandler extends TriggerHandler {

    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) 
    {
        updatePassengerRooms(newObjects, oldObjectsMap, false);
    }


    /**
      * @description  This method is used to update rooming lists
      * @param        List<sObject> newObjects
      * @param        Map<Id, sObject>oldObjectsMap
      * @param        boolean notIsUpdate
      * @return       void
    **/
    private static void updatePassengerRooms(List<sObject> newObjects, Map<Id, sObject> oldObjectsMap, boolean notIsUpdate)
    {
        // Set of tour instances where passenger__c record rooms need to be set
        List<Tour_Instance__c> tourInstancesToCalculate = new List<Tour_Instance__c>();
        for (sObject obj : newObjects){
            if (obj.get('ActualRoomTrigger__c') == Label.Fire)
                tourInstancesToCalculate.add((Tour_Instance__c)obj);
        }
        // check first if any tour instance must be updated
        if (!tourInstancesToCalculate.isEmpty())
        {
            Map<String, Integer> roomTypeSortOrderMap = new Map<String, Integer>();
            roomTypeSortOrderMap.put('SIG', 1);
            roomTypeSortOrderMap.put('TWN-DBL', 2);
            roomTypeSortOrderMap.put('TWN-TWN', 3);
            roomTypeSortOrderMap.put('TWN', 3);
            roomTypeSortOrderMap.put('TWS', 4);
            roomTypeSortOrderMap.put('TRP', 5);
            roomTypeSortOrderMap.put('TRS', 6);
            roomTypeSortOrderMap.put('QAD', 7);
            roomTypeSortOrderMap.put('QDS', 8);
            // map each tour instance to its children passengers
            Map<Id, List<Passenger__c>> tourInstanceIdToPassengerMap = new Map<Id, List<Passenger__c>>();
            for (Passenger__c passenger : [SELECT Id, Room_Type_Booked__c, 
                                        Selling_company_code__c, Booking_Number__c, 
                                        Tropics_Room_Id__c, Tour_Instance__c, Room_Preference__c
                                        FROM Passenger__c 
                                        WHERE Tour_Instance__c IN :tourInstancesToCalculate 
                                        AND Status__c = 'CF' 
                                        AND Passenger_Class__c = 'Passenger'])
            {
                if (tourInstanceIdToPassengerMap.containsKey(passenger.Tour_Instance__c))
                    tourInstanceIdToPassengerMap.get(passenger.Tour_Instance__c).add(passenger);
                else
                    tourInstanceIdToPassengerMap.put(passenger.Tour_Instance__c, new List<Passenger__c>{passenger});
            }
            // list of passenger records that will be updated
            List<Passenger__c> passengersToUpdate = new List<Passenger__c>();

            // iterate all passenger records on each Passenger__c passenger
            for (List<Passenger__c> passengerList : tourInstanceIdToPassengerMap.values())
            {
                Set<String> roomKeys = new Set<String>();
                for (Passenger__c passenger : passengerList)
                {
                    String roomType;
                    if (passenger.Room_Type_Booked__c != null && passenger.Room_Preference__c != null)
                        roomType = passenger.Room_Type_Booked__c + '-' + passenger.Room_Preference__c;
                    else
                        roomType = passenger.Room_Type_Booked__c;
                    Integer roomTypeSortOrder = roomTypeSortOrderMap.get(roomType);
                    String uniqueRoomKey = roomTypeSortOrder + '-' + passenger.Selling_company_code__c + '-' + passenger.Booking_Number__c + '-' + passenger.Tropics_Room_Id__c;
                    roomKeys.add(uniqueRoomKey);
                }
                // Sort the keys (so we just want to sort on the key)
                List<String> roomKeysList = new List<String>(roomKeys);
                roomKeysList.sort();
                // Allocate a unique number to the room ids
                Map<String, Integer> roomIdsByKey = new Map<String, Integer>();
                Integer roomId = 1;
                for (String roomKey : roomKeysList) {
                    roomIdsByKey.put(roomKey, roomId);
                    roomId++;
                }
                for (Passenger__c passenger : passengerList) {
                    String roomType;
                    if (passenger.Room_Type_Booked__c != null && passenger.Room_Preference__c != null)
                        roomType = passenger.Room_Type_Booked__c + '-' + passenger.Room_Preference__c;
                    else
                        roomType = passenger.Room_Type_Booked__c;
                    Integer roomTypeSortOrder = roomTypeSortOrderMap.get(roomType);
                    String uniqueRoomKey = roomTypeSortOrder + '-' + passenger.Selling_company_code__c + '-' + passenger.Booking_Number__c + '-' + passenger.Tropics_Room_Id__c;
                    Integer roomIden = roomIdsByKey.get(uniqueRoomKey);
                    
                    passenger.Actual_Room_ID__c = roomIden;
                }
                passengersToUpdate.addAll(passengerList);
            }
            update passengersToUpdate;

            // set the tour instances to complete
            for (Tour_Instance__c tour : tourInstancesToCalculate)
                tour.ActualRoomTrigger__c = Label.Complete;
        }
    }
    
    public static void populateTravelDirectorLookup(List<Tour_Instance__c> tourInstances, Map<Id, Tour_Instance__c> oldTourInstancesMap){
      Set<Id> travelDirectorAccountIds = new Set<Id>();
              
      for (Tour_Instance__c tourInstance : tourInstances){                
      Tour_Instance__c oldTourInstance = null;
      if (oldTourInstancesMap != null){
        oldTourInstance = oldTourInstancesMap.get(tourInstance.Id);
      }
    
        if ((tourInstance.Travel_Director__c == null ||
          (oldTourInstance != null && oldTourInstance.Allocated_TD__c != tourInstance.Allocated_TD__c))
          && tourInstance.Allocated_TD__c != null){
          travelDirectorAccountIds.add(tourInstance.Allocated_TD__c);
        }
      }
      
      if (travelDirectorAccountIds.size() > 0){
        List<User> tdUsers = [SELECT Id, AccountId FROM User WHERE AccountId IN :travelDirectorAccountIds];
        Map<Id, Id> tdAccountsMap = new Map<Id, Id>(); 
        
        for (User tdUser : tdUsers){
          tdAccountsMap.put(tdUser.AccountId, tdUser.Id);
        }

              
        for (Tour_Instance__c tourInstance : tourInstances){
          if (tourInstance.Allocated_TD__c != null
              && tdAccountsMap.get(tourInstance.Allocated_TD__c) != null){
            tourInstance.Travel_Director__c = tdAccountsMap.get(tourInstance.Allocated_TD__c);
          }
        }
      }
    }

    /*
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public static final String TRAFALGAR_COMMUNITY_NAME = 'myTrafalgar';
    
    /**
     *  Constructor
     */
    /*public TQTourInstanceTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /**
     *  Before insert handler
     */
    /*public void OnBeforeInsert(List<Tour_Instance__c> newTourInstances) {
        setTDTourProduct(newTourInstances);
    }

    /**
     *  After insert handler
     */
    /*public void OnAfterInsert(List<Tour_Instance__c> newTourInstances, Map<Id, Tour_Instance__c> newTourInstancesMap) {
        updateVisibilityForTDs(newTourInstances);
    }

    /**
     *  Before update handler
     */
    /*public void OnBeforeUpdate(List<Tour_Instance__c> newTourInstances) {
        setTDTourProduct(newTourInstances);
        updatePassengerRooms((List<sObject>)newTourInstances);
    }

    /**
     *  After update handler
     */
    /*public void OnAfterUpdate(List<Tour_Instance__c> newTourInstances, Map<Id, Tour_Instance__c> oldTourInstancesMap) {
        updateVisibilityForTDs(newTourInstances);
    }
    
    public static void populateTravelDirectorLookup(List<Tour_Instance__c> tourInstances, Map<Id, Tour_Instance__c> oldTourInstancesMap){
      Set<Id> travelDirectorAccountIds = new Set<Id>();
              
      for (Tour_Instance__c tourInstance : tourInstances){                
      Tour_Instance__c oldTourInstance = null;
      if (oldTourInstancesMap != null){
        oldTourInstance = oldTourInstancesMap.get(tourInstance.Id);
      }
    
        if ((tourInstance.Travel_Director__c == null ||
          (oldTourInstance != null && oldTourInstance.Allocated_TD__c != tourInstance.Allocated_TD__c))
          && tourInstance.Allocated_TD__c != null){
          travelDirectorAccountIds.add(tourInstance.Allocated_TD__c);
        }
      }
      
      if (travelDirectorAccountIds.size() > 0){
        List<User> tdUsers = [SELECT Id, AccountId FROM User WHERE AccountId IN :travelDirectorAccountIds];
        Map<Id, Id> tdAccountsMap = new Map<Id, Id>(); 
        
        for (User tdUser : tdUsers){
          tdAccountsMap.put(tdUser.AccountId, tdUser.Id);
        }

              
        for (Tour_Instance__c tourInstance : tourInstances){
          if (tourInstance.Allocated_TD__c != null
              && tdAccountsMap.get(tourInstance.Allocated_TD__c) != null){
            tourInstance.Travel_Director__c = tdAccountsMap.get(tourInstance.Allocated_TD__c);
          }
        }
      }
    }

    /**
     *  Remove visibility to previous TD, and grant it to the new one
     */
    /*private void updateVisibilityForTDs(List<Tour_Instance__c> newTourInstances) {

        // Get the Network Id
        Network n = [Select Id from Network Where Name = :TRAFALGAR_COMMUNITY_NAME];
        Id networkID = n != null ? n.Id : null;

        // Remove visibility to previous TDs
        Set<Id> tourIds = new Set<Id>();
        for(Tour_Instance__c tour : newTourInstances) {
            tourIds.add(tour.Id);
        }

        // Map of existing subscriptions, as TourInstanceID > Set of followers IDs
        Map<Id, Set<Id>> existingSubscriptionsMap = new Map<Id, Set<Id>>();

        if(tourIds.size() > 0) {
            // get the list of users
            List<Tour_Instance__Share> tourInstanceShares = [ SELECT UserOrGroupId 
                FROM Tour_Instance__Share 
                WHERE ParentId IN :tourIds AND RowCause = 'Manual'
            ];
            if(tourInstanceShares.size() > 0) {
                Set<Id> userIds = new Set<Id>();
                for(Tour_Instance__Share tourShare : tourInstanceShares) {
                    userIds.add(tourShare.UserOrGroupId);
                }

                List<User> oldTDs = [SELECT Id FROM User WHERE Id IN :userIds AND Is_Travel_Director__c = true];
                if(oldTDs.size() > 0) {
                    List<Tour_Instance__Share> tourInstanceSharesToDelete = [ SELECT Id 
                        FROM Tour_Instance__Share 
                        WHERE ParentId IN :tourIds AND UserOrGroupId IN :oldTDs
                    ];

                    Database.delete(tourInstanceSharesToDelete, false);
                }
            }

            // Get existing subscriptions
            List<EntitySubscription> existingSubscriptions = [SELECT SubscriberId, ParentId 
                FROM EntitySubscription WHERE ParentId IN :tourIds LIMIT 1000];
                
            for(EntitySubscription existingSubscription : existingSubscriptions) {
                if(!existingSubscriptionsMap.containsKey(existingSubscription.ParentId)) {
                    existingSubscriptionsMap.put(existingSubscription.ParentId, new Set<Id>());
                }
                existingSubscriptionsMap.get(existingSubscription.ParentId).add(existingSubscription.SubscriberId);
            }

        }

        // Grant visibility to new TDs
        List<Tour_Instance__Share> tourInstanceShares = new List<Tour_Instance__Share>();
        Tour_Instance__Share tourInstanceShare = null;

        List<EntitySubscription> tourSubscriptions = new List<EntitySubscription>();

        for(Tour_Instance__c tour : newTourInstances) {
            if(tour != null && tour.Travel_Director__c != null) {
                
                // Add a tour instance share
                tourInstanceShare = new Tour_Instance__Share();
                tourInstanceShare.ParentId = tour.Id;
                tourInstanceShare.UserOrGroupId = tour.Travel_Director__c;
                tourInstanceShare.AccessLevel = 'Read';
                tourInstanceShare.RowCause = Schema.Tour_Instance__Share.RowCause.Manual;
                
                tourInstanceShares.add(tourInstanceShare);

                // Follow the record on Chatter
                if(networkID != null && (existingSubscriptionsMap.get(tour.Id) == null ||
                        !existingSubscriptionsMap.get(tour.Id).contains(tour.Travel_Director__c)) ) {
                    tourSubscriptions.add(new EntitySubscription(
                        ParentId = tour.Id,
                        SubscriberId = tour.Travel_Director__c,
                        NetworkId = networkID
                    ));
                }

            }
        }

        // Persist changes
        try {
          if(tourInstanceShares.size() > 0) {
              Database.insert(tourInstanceShares, false);         
          }
        } finally {
          try {
            if(tourSubscriptions.size() > 0) {
                Database.insert(tourSubscriptions, false);
            }
          } catch (Exception e) {
            System.debug('Cannot Insert Subscriptions');
            System.debug(e);
          }
        }
    }

    /**
     *  For each Tour Instance, find the Tour Product with the highest duration and same 
     *  operating product code and set it as default product for the TDs
     */
    /*private void setTDTourProduct(List<Tour_Instance__c> newTourInstances) {
        if(newTourInstances != null && newTourInstances.size() > 0) {
            // Collect all  the operating product codes from the new tour instances
            List<String> operatingProductCodes = new List<String>();
            for(Tour_Instance__c tour : newTourInstances) {
                if(tour.Tour_Product__c == null) {
                    operatingProductCodes.add(tour.Operating_Product_Code__c );
                }
            }

            // Fetch all the existing tour products, given a set of operating product codes - sorted by duration desc
            List<Tour_Product__c> tourProducts = [SELECT Id, Operating_Product_Code__c, Duration__c
                FROM Tour_Product__c WHERE Operating_Product_Code__c IN :operatingProductCodes 
                ORDER BY Duration__c DESC, Name ASC LIMIT 50000];
            Map<String, Tour_Product__c> operatingProductToTourProductMap = new Map<String, Tour_Product__c>();
            for(Tour_Product__c tourProduct : tourProducts) {
                if(!operatingProductToTourProductMap.containsKey(tourProduct.Operating_Product_Code__c)
                        || operatingProductToTourProductMap.get(tourProduct.Operating_Product_Code__c).Duration__c < tourProduct.Duration__c) {
                    operatingProductToTourProductMap.put(tourProduct.Operating_Product_Code__c, tourProduct);
                }
            }
            
            // Assign the tour product to the tour instance
            for(Tour_Instance__c tour : newTourInstances) {
                if(tour.Tour_Product__c == null && operatingProductToTourProductMap.containsKey(tour.Operating_Product_Code__c)
                        && operatingProductToTourProductMap.get(tour.Operating_Product_Code__c) != null) {
                    System.debug('setTDTourProduct.ASSIGN: ' + operatingProductToTourProductMap.get(tour.Operating_Product_Code__c).Id);
                    tour.Tour_Product__c = operatingProductToTourProductMap.get(tour.Operating_Product_Code__c).Id;
                }
            }
        }
    }

    private static void updatePassengerRooms(List<sObject> newObjects)
    {
        // Set of tour instances where passenger__c record rooms need to be set
        List<Tour_Instance__c> tourInstancesToCalculate = new List<Tour_Instance__c>();
        for (sObject obj : newObjects){
            if (obj.get('ActualRoomTrigger__c') == Label.Fire)
                tourInstancesToCalculate.add((Tour_Instance__c)obj);
        }
        // check first if any tour instance must be updated
        if (!tourInstancesToCalculate.isEmpty())
        {
            Map<String, Integer> roomTypeSortOrderMap = new Map<String, Integer>();
            roomTypeSortOrderMap.put('SIG', 1);
            roomTypeSortOrderMap.put('TWN-DBL', 2);
            roomTypeSortOrderMap.put('TWN-TWN', 3);
            roomTypeSortOrderMap.put('TWN', 3);
            roomTypeSortOrderMap.put('TWS', 4);
            roomTypeSortOrderMap.put('TRP', 5);
            roomTypeSortOrderMap.put('TRS', 6);
            roomTypeSortOrderMap.put('QAD', 7);
            roomTypeSortOrderMap.put('QDS', 8);
            // map each tour instance to its children passengers
            Map<Id, List<Passenger__c>> tourInstanceIdToPassengerMap = new Map<Id, List<Passenger__c>>();
            for (Passenger__c passenger : [SELECT Id, Room_Type_Booked__c, 
                                        Selling_company_code__c, Booking_Number__c, 
                                        Tropics_Room_Id__c, Tour_Instance__c, Room_Preference__c
                                        FROM Passenger__c 
                                        WHERE Tour_Instance__c IN :tourInstancesToCalculate 
                                        AND Status__c = 'CF' 
                                        AND Passenger_Class__c = 'Passenger'])
            {
                if (tourInstanceIdToPassengerMap.containsKey(passenger.Tour_Instance__c))
                    tourInstanceIdToPassengerMap.get(passenger.Tour_Instance__c).add(passenger);
                else
                    tourInstanceIdToPassengerMap.put(passenger.Tour_Instance__c, new List<Passenger__c>{passenger});
            }
            // list of passenger records that will be updated
            List<Passenger__c> passengersToUpdate = new List<Passenger__c>();

            // iterate all passenger records on each Passenger__c passenger
            for (List<Passenger__c> passengerList : tourInstanceIdToPassengerMap.values())
            {
                Set<String> roomKeys = new Set<String>();
                for (Passenger__c passenger : passengerList)
                {
                    String roomType;
                    if (passenger.Room_Type_Booked__c != null && passenger.Room_Preference__c != null)
                        roomType = passenger.Room_Type_Booked__c + '-' + passenger.Room_Preference__c;
                    else
                        roomType = passenger.Room_Type_Booked__c;
                    Integer roomTypeSortOrder = roomTypeSortOrderMap.get(roomType);
                    String uniqueRoomKey = roomTypeSortOrder + '-' + passenger.Selling_company_code__c + '-' + passenger.Booking_Number__c + '-' + passenger.Tropics_Room_Id__c;
                    roomKeys.add(uniqueRoomKey);
                }
                // Sort the keys (so we just want to sort on the key)
                List<String> roomKeysList = new List<String>(roomKeys);
                roomKeysList.sort();
                // Allocate a unique number to the room ids
                Map<String, Integer> roomIdsByKey = new Map<String, Integer>();
                Integer roomId = 1;
                for (String roomKey : roomKeysList) {
                    roomIdsByKey.put(roomKey, roomId);
                    roomId++;
                }
                for (Passenger__c passenger : passengerList) {
                    String roomType;
                    if (passenger.Room_Type_Booked__c != null && passenger.Room_Preference__c != null)
                        roomType = passenger.Room_Type_Booked__c + '-' + passenger.Room_Preference__c;
                    else
                        roomType = passenger.Room_Type_Booked__c;
                    Integer roomTypeSortOrder = roomTypeSortOrderMap.get(roomType);
                    String uniqueRoomKey = roomTypeSortOrder + '-' + passenger.Selling_company_code__c + '-' + passenger.Booking_Number__c + '-' + passenger.Tropics_Room_Id__c;
                    Integer roomIden = roomIdsByKey.get(uniqueRoomKey);
                    
                    passenger.Actual_Room_ID__c = roomIden;
                }
                passengersToUpdate.addAll(passengerList);
            }
            update passengersToUpdate;

            // set the tour instances to complete
            for (Tour_Instance__c tour : tourInstancesToCalculate)
                tour.ActualRoomTrigger__c = Label.Complete;
        }
    }*/
    
    // Code changes done by Ravi Jain for story S-569799
    // Start - Ravi Jain - S-569799 - 25th July, 2018 - Check if the Allocated TD value is not null
    public static void runBatchForTourInstance(List<Tour_Instance__c> newList, Map<Id, Tour_Instance__c> oldMap){
        set<Id> tourIds = new set<Id>();
        
        for(Tour_Instance__c tour: newList){
            if(tour.Allocated_TD__c != null && oldMap.get(tour.Id).Allocated_TD__c == null && tour.Allocated_TD__c != oldMap.get(tour.Id).Allocated_TD__c){
                tourIds.add(tour.Id);
            }
        }
        
        if(tourIds.size()>0){
            TOPS_CreateRoomingList roomingListBatch = new TOPS_CreateRoomingList(); 
            database.executebatch(roomingListBatch);
        }
    }
    // End - Ravi Jain - S-569799 - 25th July, 2018

}