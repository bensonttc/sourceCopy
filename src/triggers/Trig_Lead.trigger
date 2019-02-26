// TriggeredSend for Auto-response email to be sent to the Lead after creation
trigger Trig_Lead on Lead (after insert) {//, after update) {
        et4ae5.triggerUtility.automate('Lead'); 
}