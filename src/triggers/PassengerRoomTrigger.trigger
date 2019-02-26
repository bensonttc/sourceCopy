Trigger PassengerRoomTrigger on Tour_Instance__c (before update) {

      
for(Tour_Instance__c tourInstance: Trigger.new){
if (tourInstance.ActualRoomTrigger__c == 'Fire'){  
// Get all of the passengers and build up a set of unique room keys
List<Passenger__c> allPassengers = [SELECT Id, Room_Type_Booked__c, Selling_company_code__c, Booking_Number__c, Tropics_Room_Id__c FROM Passenger__c WHERE Tour_Instance__c =: tourInstance.Id AND Status__c = 'CF'];
Set<String> roomKeys = new Set<String>();
    
for (Passenger__c passenger : allPassengers) {
    // Get the room type sort order
    //Integer roomTypeSortOrder = roomTypeSortOrder.get(passenger.Room_Type_Booked__c);
    String uniqueRoomKey = (String)passenger.Room_Type_Booked__c + '-' + passenger.Selling_company_code__c + '-' + passenger.Booking_Number__c + '-' + passenger.Tropics_Room_Id__c;
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

    
    
// Loop through the passengers and allocate the room id to the passenger
for (Passenger__c passenger : allPassengers) {
    String uniqueRoomKey = passenger.Room_Type_Booked__c + '-' + passenger.Selling_company_code__c + '-' + passenger.Booking_Number__c + '-' + passenger.Tropics_Room_Id__c;
    Integer roomIden = roomIdsByKey.get(uniqueRoomKey);
    
    passenger.put('Actual_Room_ID__c', roomIden);
}

update allPassengers;
tourInstance.ActualRoomTrigger__c = 'Complete';
    
}    
}    
}