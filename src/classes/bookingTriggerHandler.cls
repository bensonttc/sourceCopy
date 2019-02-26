public with sharing class bookingTriggerHandler {
    
    /*************************************
    ************Open or close*************
    ********related Opportunities*********
    *************************************/
    public Void AutoCloseOpportunities(List<Booking__c> newList) {
    
        //Declare Variables
        List<Id> bookingIds = new List<Id>();
        Map<Id, String> bookingStatus = new Map<Id, String>();
        Map<Id, String> paymentStatus = new Map<Id, String>();
        Map<Id, Decimal> bookingAmount = new Map<Id, Decimal>();
        Map<Id, String> bookingNumber = new Map<Id, String>();
        Map<Id, Decimal> numberOfPassengers = new Map<Id, Decimal>();
        
        //iterate through all passed Bookings
        for(Booking__c book : newList) {
        
            //For each booking find the corresponding prior values
            Booking__c oldBook = (Booking__c) trigger.oldMap.get(book.Id);
            
            //At each booking, check if it has a closed status, and also check that the Status was not the same before the edit
            if((book.Status__c == 'CO' || book.Status__c == 'CX' || book.Status__c == 'AC') && book.Status__c != oldBook.Status__c && book.RecordTypeId == Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId()){
            
                //Create two maps. One of the map has the Status and the other has the Payment Status
                bookingIds.add(book.Id);
                bookingStatus.put(book.Id, book.Status__c);
                paymentStatus.put(book.Id, book.Payment_Status__c);
                bookingAmount.put(book.Id, book.Total_Price__c);
                bookingNumber.put(book.Id, book.Name);
                numberOfPassengers.put(book.Id, book.Pax_Count__c);
            
            }
        
        }
        
        //Create a list of all associated Opportunities which are not closed and have the B2B, B2C or B2B2C record types
        List<Opportunity> oppsToEdit = [SELECT Id, StageName, RecordTypeId, Booking_Number__c, IsClosed, Amount, Text_Booking_Ref__c, Number_Of_Passengers__c FROM Opportunity WHERE Booking_Number__c IN :bookingIds AND (RecordTypeId = :Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B Opportunity').getRecordTypeId() OR
                                        RecordTypeId = :Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B2C Opportunity').getRecordTypeId() OR RecordTypeId = :Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Opportunity').getRecordTypeId()) AND
                                        IsClosed = FALSE];
                                        
        //Make sure there was at least 1 Opportunity returned
        if(oppsToEdit.Size() > 0){
        
            //Start looping throug hthe opportunities
            for(integer i = 0; i < oppsToEdit.Size(); i++){
            
                //For each Opportunity, see if the parent Booking was confirmed and payment status is paritally paid, fully paid or overpaid
                if(bookingStatus.get(oppsToEdit[i].Booking_Number__c) == 'CO' && (paymentStatus.get(oppsToEdit[i].Booking_Number__c) == 'FP' || paymentStatus.get(oppsToEdit[i].Booking_Number__c) == 'OP' || paymentStatus.get(oppsToEdit[i].Booking_Number__c) == 'PP')){
                
                    oppsToEdit[i].StageName = 'Closed Won';
                
                //For each Opportunity, see if the parent Booking was cancelled or auto cancelled
                } else if(bookingStatus.get(oppsToEdit[i].Booking_Number__c) == 'CX' || bookingStatus.get(oppsToEdit[i].Booking_Number__c) == 'AC'){
                
                    oppsToEdit[i].StageName = 'Closed Lost';
                
                }
                
                if(oppsToEdit[i].Amount == Null){
                
                    oppsToEdit[i].Amount = bookingAmount.get(oppsToEdit[i].Booking_Number__c);
                
                }
                
                if(oppsToEdit[i].Text_Booking_Ref__c == Null){
                
                    oppsToEdit[i].Text_Booking_Ref__c = bookingNumber.get(oppsToEdit[i].Booking_Number__c);
                
                }
                
                if(oppsToEdit[i].Number_Of_Passengers__c == Null){
                
                    oppsToEdit[i].Number_Of_Passengers__c = numberOfPassengers.get(oppsToEdit[i].Booking_Number__c);
                
                }
            
            }
            
            //update the opportunities
            update oppsToEdit;
        
        }
    
    }
    
    /*************************************
    ******Count Red Carnation Visits******
    *************************************/
    public void countRCHStays(List<Booking__c> newList) {
    
        //declare variables
        List<Account> leadPax = new List<Account>();
        List<Id> leadPaxIds = new List<Id>();
        List<Booking__c> matchEditedBooks = new List<Booking__c>();
        Set<Id> matchEditedBooksIds = new Set<Id>();
        Set<Id> updatedBooks = new Set<Id>();
        Map<Id, Integer> hotelStays = new Map<Id, Integer>();
        
        //iterate through all passed Bookings
        for(Booking__c book : newList) {
            
            //Find all Bookings with a Lead Passenger where the Status was made Confirmed
            Booking__c oldBook = (Booking__c) trigger.oldMap.get(book.Id);
            
            if(book.Lead_Passenger__c != Null && book.Brand__c == 'RCH' && book.recordTypeId == Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Reservation').getRecordTypeId()){
            
                Account acct = new Account(Id = Book.Lead_Passenger__c, RCH_Hotel_Stays__c = 0);
                leadPax.add(acct);
                leadPaxIds.add(book.Lead_Passenger__c);
                
                if(book.Status__c == 'Checked Out' && oldBook.Status__c != 'Checked Out'){
                
                    matchEditedBooks.add(book);
                    matchEditedBooksIds.add(book.Id);
                
                }
                
                if(book.Status__c != 'Checked Out' && oldBook.Status__c == 'Checked Out'){
                
                    updatedBooks.add(book.Id);
                
                }
            
            }
            
        }
        
        //Process the updated Bookings first. These are the Bookings that were edited/created to fire the trigger
        if(matchEditedBooks.Size() > 0){
            
            for(integer i = 0; i < matchEditedBooks.Size(); i++){
                        
                //When an account has passed one of the brand checks then make sure it will not get counted later when all Booking Components are looked for
                updatedBooks.add(matchEditedBooks[i].Id);
                
                //If the brand is found then check to see if there is a Set created for that Account Id
                if(hotelStays.containsKey(matchEditedBooks[i].Lead_Passenger__c)){
                
                    //If there is then add 1 to the number against that Id
                    integer num = hotelStays.get(matchEditedBooks[i].Lead_Passenger__c);
                    hotelStays.put(matchEditedBooks[i].Lead_Passenger__c, num+1);
                
                }
                
                else{
                
                    //If not then create a new set with that Id and the number 1
                    hotelStays.put(matchEditedBooks[i].Lead_Passenger__c, 1);
                
                }
                
            }
            
        }
        
        //If there is at least 1 Customer Id in all of the Booking Components that were edited then proceed to find the child Booking Components
        if(leadPax.size() > 0){
        
            //Select all Booking_Components from Salesforce with selected details based on the Account Ids
            List<Booking__c> Books = [SELECT Id, Status__c, Lead_Passenger__c, Brand__c, recordTypeId FROM Booking__c WHERE Lead_Passenger__c IN :leadPaxIds AND Brand__c = 'RCH' AND Status__c = 'Checked Out' LIMIT 50000];
        
            //If there is at least 1 Booking Component found then proceed
            if(Books.size() > 0){
            
                //Start iterating through all of the Booking Components
                for(integer i = 0; i < Books.Size(); i++){
                
                    if((updatedBooks.contains(Books[i].Id)) == false){
                        
                        //If the brand is found then check to see if there is a Set created for that Account Id
                        if(hotelStays.containsKey(Books[i].Lead_Passenger__c)){
                        
                            //If there is then add 1 to the number against that Id
                            integer num = hotelStays.get(Books[i].Lead_Passenger__c);
                            hotelStays.put(Books[i].Lead_Passenger__c, num+1);
                        
                        }
                        
                        else{
                        
                            //If not then create a new set with that Id and the number 1
                            HotelStays.put(Books[i].Lead_Passenger__c, 1);
                        
                        }
                    
                    }
                    
                }
                
            }
            
        }
        
        //Deduplicate all of the Accounts
        set<Account> deDupe = new set<Account>(leadPax);
        leadPax.Clear();
        leadPax.addAll(deDupe);
        
        //iterate through the accounts, and for each account set the Passenger Count from the Sets
        for(integer i = 0; i < leadPax.size(); i++){
            
            if(hotelStays.get(leadPax[i].Id) != Null){
            
                leadPax[i].RCH_Hotel_Stays__c = hotelStays.get(leadPax[i].Id);
                
            }
            
        }
        
        List<Account> UpdateLeadPax = new List<Account>();
        
        //Go through all of the accounts and find the ones which have a number against RCH_Hotel_Stays__c
        for(integer i = 0; i < leadPax.size(); i++){
        
            if(leadPax[i].RCH_Hotel_Stays__c != 0){
        
                //add the leadPax to the new updateLeadPax list
                updateLeadPax.add(leadPax[i]);
                
            }
            
        }
        
        if(updateLeadPax != Null && updateLeadPax.size() > 0){
        
            //Update the Accounts
            update updateLeadPax;
        
        }
    
    }
    
    /*************************************
    ******Count Up Group Bookings******
    *************************************/
    public void collectGroupBookings(List<Booking__c> newList) {
    
        //declare variables
        List<Booking__c> matchEditedBooks = new List<Booking__c>();
        List<Booking__c> otherBooks = new List<Booking__c>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Id> oppIds = new List<Id>();
        List<String> groupBookingIds = new List<String>();
        Set<Id> updatedBooks = new Set<Id>();
        Map<Id, Integer> passengerCount = new Map<Id, Integer>();
        Id bookingRecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
                
        //iterate through all passed Bookings
        for(Booking__c book : newList) {
            
            //make a list of the booking details before the edit
            Booking__c oldBook = (Booking__c) trigger.oldMap.get(book.Id);
            
            //Check if each edited Booking was modified to match the criteria
            if((book.Group_Opportunity__c != Null && oldBook.Group_Opportunity__c == Null && book.Status__c == 'CO' && book.Group_Booking_Id__c != Null) || (book.Status__c == 'CO' && oldBook.Status__c != 'CO' && book.Group_Booking_Id__c != Null && book.Group_Opportunity__c != Null) || (book.Status__c != 'CO' && oldBook.Status__c == 'CO' && book.Group_Booking_Id__c != Null && book.Group_Opportunity__c != Null) && book.Brand__c != Null && book.RecordTypeId == bookingRecordTypeId){
                
                Opportunity thisOpp = new Opportunity(Id = book.Group_Opportunity__c, Booked_Passengers__c = 0);
                
                matchEditedBooks.add(book);
                updatedBooks.add(book.Id);
                groupBookingIds.add(book.Group_Booking_Id__c);
                
                passengerCount.put(book.Group_Opportunity__c, 0);
                opps.add(thisOpp);
                oppIds.add(thisOpp.Id);
                
            }
            
        }
        
        //Process the updated Booking Components first. These are the Booking Components that were edited/created to fire the trigger
        if(matchEditedBooks.Size() > 0){
            
            for(integer i = 0; i < matchEditedBooks.Size(); i++){
                
                integer num = passengerCount.get(matchEditedBooks[i].Group_Opportunity__c);
                passengerCount.put(matchEditedBooks[i].Group_Opportunity__c, num + matchEditedBooks[i].Pax_Count__c.intValue());
                
            }
            
        }
        
        //Find all of the Bookings that are linked to the Group Opportunities, excluding the ones that were edited to meet the criterea, and count them up
        if(opps.size() > 0 && opps != Null){
            
            //Select all Bookings from Salesforce with selected details based on the Opportunity Ids
            otherBooks = [SELECT Id, Group_Opportunity__c, Status__c, recordTypeId, Pax_Count__c FROM Booking__c WHERE Group_Opportunity__c IN :oppIds AND Status__c = 'CO' LIMIT 50000];
            
            //If there is at least 1 Booking found then proceed
            if(otherBooks.size() > 0){
                
                //Start iterating through all of the Bookings
                for(integer i = 0; i < otherBooks.size(); i++){
                    
                    //Make sure the Booking is not one of the Bookings that was edited for this Method
                    if(updatedBooks.contains(otherBooks[i].id) == false){
                        
                        integer num = passengerCount.get(otherBooks[i].Group_Opportunity__c);
                        passengerCount.put(otherBooks[i].Group_Opportunity__c, num + otherBooks[i].Pax_Count__c.intValue());
                        
                    }
                    
                }
                
            }
            
        }
        
        //Deduplicate all opportunities
        Set<Opportunity> deDuplicator = new Set<Opportunity>(opps);
        opps.clear();
        opps.addAll(deDuplicator);
        
        //iterate through the Opportunities and for each one set the Passenger count
        for(integer x = 0; x < opps.size(); x++){
            
            opps[x].Booked_Passengers__c = passengerCount.get(opps[x].Id);
            
        }
        
        //update Opportunities
        update opps;
    
    }
    
    /*********************************
    *****Check if the Consultant******
    *******has active bookings********
    *********************************/
    public void ConsultantHasBooking(List<Booking__c> newList) {

        List<Contact> updateNewList = new List<Contact>();
        List<Contact> updateOldList = new List<Contact>();
        Set<Contact> deduplicator = new set<Contact>();
        List<Booking__c> consultantBookings = new List<Booking__c>();
        Set<Id> bookingsWithConsultant = new Set<Id>();

        //iterate through all passed Bookings
        for(Booking__c book : newList) {
        
            //For each Booking with a Consultant, add the Booking and Booking Id to Lists
            if(book.Consultant__c != Null){
            
                consultantBookings.add(book);
                bookingsWithConsultant.add(book.Id);
            
            }
            
        }
        
        //Check if any of the Bookings passed have Consultants
        if(consultantBookings.size() > 0){
        
            //For each Booking, grab required fields from the Booking and Consultant records and put them into a List of Booking__c
            List<Booking__c> bookings = [SELECT Id, Original_Booking_Date__c, Consultant__r.Has_Bookings__c, Consultant__r.Inactive__c, Consultant__r.Id, Consultant__r.LastModifiedDate 
            FROM Booking__c 
            WHERE Id IN :bookingsWithConsultant AND Consultant__r.owner.profileId != '00e20000001okXEAAY' AND Consultant__r.owner.profileId != '00e20000001okXJAAY' AND Consultant__r.owner.profileId != '00e20000001om9cAAA' AND 
            ((Original_Booking_Date__c > :date.today().addDays(-1096) AND Consultant__r.Has_Bookings__c = False) OR (Original_Booking_Date__c <= :date.today().addDays(-1096) AND Consultant__r.Has_Bookings__c = True AND Consultant__r.LastModifiedDate < :date.today().addDays(-365))) LIMIT 50000];
            
            //Make sure the list is not empty
            if(bookings.size() > 0){
            
                //Iterate through the list
                for(integer i = 0; i < bookings.size(); i++){
                
                    //For each of those Bookings, look for any with the Original Booking Date in the last 3 years
                    if(bookings.get(i).Original_Booking_Date__c > date.today().addDays(-1096) && bookings.get(i).Consultant__r.Has_Bookings__c == False){
                    
                        //For each one, tick the Has Bookings checkbox, untick the Inactive Checkbox and add that Consultant to the list of Consultants to get updated
                        Contact cont1 = new Contact(id = bookings.get(i).Consultant__r.Id);
                        cont1.Has_Bookings__c = True;
                        cont1.Inactive__c = False;
                        updateNewList.add(cont1);
                    
                    }
                    //If the above check fails then see if there are any Bookings with Original Booking Date from over 3 years ago, the Has Bookings box is ticked and the Consultant was last updated over a year ago
                    else if(bookings.get(i).Original_Booking_Date__c <= date.today().addDays(-1096) && bookings.get(i).Consultant__r.Has_Bookings__c == True && bookings.get(i).Consultant__r.LastModifiedDate < date.today().addDays(-365)){
                    
                        //For those Consultants, go through them and untick Has Bookings, Make them Inactive and add the Consultant to the list of Consultants to be Updated
                        Contact cont1 = new Contact(id = bookings.get(i).Consultant__r.Id);
                        cont1.Has_Bookings__c = False;
                        cont1.Inactive__c = True;
                        updateOldList.add(cont1);
                    
                    }
                
                }
            
            }
        
            //Deduplicate New Consultants List
            deduplicator.addAll(updateNewList);
            updateNewList.clear();
            updateNewList.addAll(deduplicator);
            deduplicator.clear();
            
            //Deduplicate Old Consultants List
            deduplicator.addAll(updateOldList);
            updateOldList.clear();
            updateOldList.addAll(deduplicator);
            deduplicator.clear();
            
            //Do this only if both update Lists of Consultants have at least 1 record in them
            if(updateNewList.size() > 0 && updateOldList.size() > 0){
            
                //Iterate though the list of Consultants against new Bookings (OBD in the last 3 years)
                for(integer i = 0; i < updateNewList.size(); i++){
                
                    //For each of those, iterate through the list of old Bookings (Last updated over a year ago and OBD over 3 years old)
                    for (integer j = 0; j < updateOldList.Size(); j++){
                    
                        //If you find the same contact in both Lists, remove that contact from the old Bookings list
                        if(updateOldList.get(j) == updateNewList.get(i)){
                        
                            updateOldList.remove(j);
                            j--;
                        
                        }
                    
                    }
                
                }
            
            }
            
            //Make sure the list of New Consultants has at least 1 record in it 
            if(updateNewList.Size() > 0){
                
                update updateNewList;
                
            }
            //Make sure the list of Old Consultants has at least 1 record in it 
            if(updateOldList.Size() > 0){
                
                update updateOldList;
                
            }
        
        }
    
    }
    /*********************************
    ******RCH Next Booking Link*******
    *********************************/
    public void RCHNextBooking(List<Booking__c> newList) {
    
        //Declare variables
        Set<Account> accts = new Set<Account>();
        List<Account> acctsToBeUpdated = new List<Account>();
        Set<Id> acctIds = new Set<Id>();
        
        //iterate through all passed Bookings
        for(Booking__c book : newList) {
            
            //Find the prior values for each of the bookings
            Booking__c oldBook = (Booking__c) trigger.oldMap.get(book.Id);
            
            if(book.Status__c == 'Checked Out' && oldBook.Status__c != 'Checked Out' && book.Lead_Passenger__c != Null && book.Brand__c == 'RCH' && book.recordTypeId == Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Reservation').getRecordTypeId()){
                
                if(acctIds.contains(Book.Lead_Passenger__c)){
                    
                    //Do nothing
                    
                }else{
                
                    acctIds.add(book.Lead_Passenger__c);
                    Account acct = new Account(Id = book.Lead_Passenger__c, RCH_Booking__c = Book.Id);
                    acctsToBeUpdated.add(acct);
                
                }
                
            }
            
        }
        
        if(acctsToBeUpdated.size() > 0 && acctsToBeUpdated != Null){
            
            update acctsToBeUpdated;
            
        }
    
    }
    
    /*********************************
    *****Populate Passengers with*****
    **********Booking Status**********
    *********************************/
    public void PassengerStatusUpdate(List<Booking__c> newList) {
    
        //Declare variables
        List<Booking__c> updatedStatus = new List<Booking__c>();
        List<Id> bookingIds = new List<Id>();
        
        //iterate through all passed Bookings
        for(Booking__c book : newList) {
        
            //create a variable of the old values of the booking
            Booking__c oldBook = (Booking__c) trigger.oldMap.get(book.Id);
            
            //Select the Bookings where the Status has changed to Confirmed from not Confirmed and the Record Type is Booking
            if(book.Status__c != oldBook.Status__c && (book.Status__c == 'CO' || oldBook.Status__c == 'CO') && book.recordTypeId == Schema.SObjectType.Booking__c.getRecordtypeInfosByName().get('Booking').getRecordTypeId()){
            
                updatedStatus.add(book);
                bookingIds.add(book.Id);
            
            }
        
        }
        
        //Check if at least one Booking was selected
        if(bookingIds.size() > 0){
        
            //run a SOQL query to select all of the Passengers of the Bookings
            List<Passenger__c> passes = new List<Passenger__c>();
            passes = [SELECT Id, Booking_Status_Hidden__c, Booking_Component__r.Booking_Number__c, Booking_Component__r.Booking_Number__r.Status__c FROM Passenger__c WHERE Booking_Component__r.Booking_Number__c IN :bookingIds LIMIT 10000];
            
            //Make sure at least one booking was selected
            if(passes.size() > 0){
            
                for(integer y = 0; y < passes.size(); y++){
                
                    //For each Passenger, set the new Status field on the Passengers to CO
                    passes[y].Booking_Status_Hidden__c = passes[y].Booking_Component__r.Booking_Number__r.Status__c;
                
                }
                
                //Update the passengers
                update Passes;
            
            }
        
        }
    
    }

}