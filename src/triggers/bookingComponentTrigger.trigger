trigger bookingComponentTrigger on Booking_Component__c (before update) {
    
    bookingComponentTriggerHandler bookTrigHand = new bookingComponentTriggerHandler();
    if(Trigger.isBefore) {
        if(Trigger.isUpdate ) {
            bookTrigHand.UpdateFields(Trigger.new);
        }
    } 
}