trigger MDM_BookingPax_Synch_Trigger on Booking_Passenger__c (before insert, after insert, before update, after update, before delete, after delete) {
    Booking_Passenger_Trigger_Helper triggerHandler = new Booking_Passenger_Trigger_Helper();
    triggerHandler.execute();
}