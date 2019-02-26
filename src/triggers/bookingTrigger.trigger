trigger bookingTrigger on Booking__c (after insert, after update) {
    
    bookingTriggerHandler bookTrigHand = new bookingTriggerHandler();
    if(Trigger.isAfter) {
        if(Trigger.isInsert ) {
            bookTrigHand.ConsultantHasBooking(Trigger.new);
        }
        if(Trigger.isUpdate ) {
            bookTrigHand.ConsultantHasBooking(Trigger.new);
            bookTrigHand.CountRCHStays(Trigger.new);
            bookTrigHand.AutoCloseOpportunities(Trigger.new);
            bookTrigHand.collectGroupBookings(Trigger.new);
            bookTrigHand.RCHNextBooking(Trigger.new);
        }
    } 
}