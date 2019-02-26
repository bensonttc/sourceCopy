trigger BookingPassengerTrigger on Booking_Passenger__c (before update, after update) {

    bookingPassengerTriggerHandler bookPassTrigHand = new bookingPassengerTriggerHandler();
    
    if(Trigger.isAfter) {
    
        if(Trigger.isUpdate ) {
        
            bookPassTrigHand.NextBookingDate(Trigger.new);
            
        }
        
    }

}