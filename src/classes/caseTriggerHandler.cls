/*
---------------------------------------------------------------------------------------------------------------------------------------
-------------------Created by Mark Mulholland------------------------------------------------------------------------------------------
-------------------------08/12/2016----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------Checklist---------------------------------------------------------------------------------------------------
--[x] Only 1 Booking found with only 1 Passenger with specified Surname----------------------------------------------------------------
--[x] Only 1 Booking found with multiple Passengers with the specified Surname---------------------------------------------------------
--[x] Only 1 Booking found but no related Passengers with specified Surname------------------------------------------------------------
--[x] Only 1 Booking found but no related Passengers records---------------------------------------------------------------------------
--[x] Multiple Bookings found with the specified Booking Number and all of them with 1 of the Passengers having the specified Surname--
--[x] Multiple Bookings found with the specified Booking Number and all of them with multiple Passengers having the specified Surname--
--[x] Multiple Bookings found with the specified Booking Number but none of them with a Passengers having the specified Surname--------
--[x] Multiple Bookings found with the specified Booking Number but all of them with no related Passenger records----------------------
---------------------------------------------------------------------------------------------------------------------------------------
--------------------Edited by Mark Mulholland------------------
-------------------------30/06/2017----------------------------
----------Updated the Subject check to make sure the-----------
----------subject field is not Null as well as if it-----------
-----------------contains square brackets----------------------
---------------------------------------------------------------
*/

public with sharing class caseTriggerHandler {
    
    public void InsertCases(List<Case> newList) {
        
        //Declare Variables
        List<Case> email2CaseCases = new List<Case>();
        String bookNoAndName;
        String bookingNumber;
        String lastName;
        
        //Check the created cases and process only the ones that meet the Email to Case requirements
        for(Case cases : newList){
        
            if(cases.Origin == 'Email2Case' && cases.SuppliedEmail != Null && cases.SuppliedEmail != '' && cases.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Guest Relations').getRecordTypeId()){
            
                //If a case does meet those criteria then add that case to the list called email2CaseCases
                email2CaseCases.add(cases);
            
            }
        
        }
        
        //CHeck if there are at least 1 cases in the list that are Email to Case cases
        if(email2CaseCases.size() > 0){
        
            //If there are then start iterating through them
            for(integer i = 0; i < email2CaseCases.size(); i++){
            
                //Make sure the subject of the case has a open square bracket and a closed square bracket
                if(email2CaseCases[i].Subject.contains('[') && email2CaseCases[i].Subject.contains(']') && email2CaseCases[i].Subject != Null){
                
                    //Extract the beginning of the subject between the square brackets
                    bookNoAndName = email2CaseCases[i].Subject.substringBetween('[',']');
                    
                    //Check that the extracted part contains a hyphen
                    if(bookNoAndName.contains('-')){
                    
                        //Take the part before the hyphen and add it to the bookingNumber string, then remove any leading and trailing spaces
                        bookingNumber = bookNoAndName.substringBefore('-');
                        bookingNumber = bookingNumber.trim();
                        
                        //Take the part after the hyphen and add it to the lastName string, then remove any leading and trailing spaces
                        lastName = bookNoAndName.substringAfter('-');
                        lastName = lastName.Trim();
                        
                    }
                    
                    //If not then the Booking Number is everything between the square brackets and last anem is Null
                    else{
                    
                        bookingNumber = bookNoAndName;
                        bookingNumber = bookingNumber.trim();
                        
                        lastName = Null;
                    
                    }
                        
                    //Grab a list of all Booking Passengers on the Booking you extracted from the Subject of the case
                    List<Booking_Passenger__c> bookPass = [SELECT Id, First_Name__c, Last_Name__c, Lead_Passenger__c, Customer__c, Customer__r.personContactId, Original_Booking_Date__c, Business_Unit_Lookup__c, Booking__c, Booking__r.name FROM Booking_Passenger__c WHERE Booking__r.name = :bookingNumber];
                    
                    //Check that at least 1 Booking Passenger was found
                    if(bookPass.size() > 0){
                    
                        //Check if only 1 Booking Passenger was found
                        if(bookPass.size() == 1){
                        
                            //Check if that 1 Passenger's Last Name is the same as the last name submitted in the Case Subject
                            if(bookPass[0].Last_Name__c == lastName){
                            
                                //Fill in the details on the case for that found Booking Passenger
                                email2CaseCases[i].Booking__c = bookPass[0].Booking__c;
                                email2CaseCases[i].Business_Unit__c = bookPass[0].Business_Unit_Lookup__c;
                                email2CaseCases[i].Booking_Passenger__c = bookPass[0].Id;
                                email2CaseCases[i].ContactId = bookPass[0].Customer__r.personContactId;
                                email2CaseCases[i].Lead_Passenger__c = bookPass[0].Customer__c;
                            
                            } else{
                                
                                //Fill in the details on the case for the Lead Passenger on that booking
                                email2CaseCases[i].Booking__c = bookPass[0].Booking__c;
                                email2CaseCases[i].Business_Unit__c = bookPass[0].Business_Unit_Lookup__c;
                                email2CaseCases[i].Lead_Passenger__c = bookPass[0].Customer__c;
                                
                            }
                        
                        }
                        
                        //Go here if there is more than one passenger found
                        else{
                        
                            //Declare variables specific to multiple returned results
                            Set<Id> bookingId = new Set<Id>();
                            Id leadPax;
                            Id leadPaxCont;
                            Booking_Passenger__c matchedPax = new Booking_Passenger__c();
                            Datetime mostRecentBooking = Null;
                            Integer noOfMatches = 0;
                            
                            //Iterate through all passengers
                            for(integer j = 0; j < bookPass.size(); j++){
                            
                                //Add the Booking Id to a set of Ids so the set will only be as long as the unique Booking Ids
                                bookingId.add(bookPass[j].Booking__c);
                                
                            }
                            
                            //Add those booking Ids from the set to a list to make it easier to sort
                            List<Id> bookingIds = new List<Id>(bookingId);
                            
                            //If there is only 1 Booking found then go here
                            if(bookingIds.size() == 1){
                            
                                //Iterate through all passengers
                                for(integer k = 0; k < bookPass.size(); k++){
                                    
                                    //At each Passenger, check if they are the Lead Passenger. If true then add that Passenger as the Lead Passenger
                                    if(bookPass[k].Lead_Passenger__c == TRUE){
                                    
                                        leadPax = bookPass[k].Customer__c;
                                    
                                    }
                                    
                                    //At each Passenger, check the surname against the surname provided in the Subject. If there is a match then increment the Number of Matches
                                    if(bookPass[k].Last_Name__c == lastName){
                                    
                                        noOfMatches ++;
                                    
                                    }
                                    
                                }
                                
                                //If only one of the Passengers has the supplied surname then go here
                                if(noOfMatches == 1){
                                
                                    //We must dig out the one matched passenger
                                    for(integer l = 0; l < bookPass.size(); l++){
                                    
                                        //While looping through all Booking Passengers, find the one that matched the Last Name and set it as the matchedPax variable
                                        if(bookPass[l].Last_Name__c == lastName){
                                        
                                            matchedPax = bookPass[l];
                                        
                                        }
                                        
                                        if(bookPass[l].Lead_Passenger__c){
                                        
                                            leadPax = bookPass[l].Customer__c;
                                        
                                        }
                                    
                                    }
                                    
                                    email2CaseCases[i].Booking__c = matchedPax.Booking__c;
                                    email2CaseCases[i].Business_Unit__c = matchedPax.Business_Unit_Lookup__c;
                                    email2CaseCases[i].Booking_Passenger__c = matchedPax.Id;
                                    email2CaseCases[i].ContactId = matchedPax.Customer__r.personContactId;
                                    email2CaseCases[i].Lead_Passenger__c = leadPax;
                                
                                }
                                //If more than 1 Passenger has the supplied surname then go here
                                else{
                                
                                    //Loop through the Booking Passengers to find the Lead Passenger
                                    for(integer l = 0; l < bookPass.size(); l++){
                                    
                                        if(bookPass[l].Lead_Passenger__c){
                                        
                                            //Set the Lead Passenger as the LeadPax
                                            leadPax = bookPass[l].Customer__c;
                                        
                                        }
                                    
                                    }
                                    
                                    //Populate the case with the Booking info and the Lead Passenger
                                    email2CaseCases[i].Booking__c = bookPass[0].Booking__c;
                                    email2CaseCases[i].Business_Unit__c = bookPass[0].Business_Unit_Lookup__c;
                                    email2CaseCases[i].Lead_Passenger__c = leadPax;
                                
                                }
                            
                            }
                            
                            //If more than 1 booking was returned then go here
                            else{
                            
                                //Declare variables to hold information about what needs to be put into the case
                                String businessUnit;
                                Id latestBookingId;
                                DateTime bookingDate;
                            
                                //Loop through the booking passengers
                                for(integer k = 0; k < bookPass.size(); k++){
                                
                                    //Check if the current Booking Passenger has the last name we are looking for
                                    if(lastName == bookPass[k].Last_Name__c){
                                    
                                        //If they do then increment the noOfMatches integer and set the variables for the Case
                                        noOfMatches ++;
                                        bookingDate = bookPass[k].Original_Booking_Date__c;
                                        latestBookingId = bookPass[k].Booking__c;
                                        businessUnit = bookPass[k].Business_Unit_Lookup__c;
                                        matchedPax = bookPass[k];
                                        leadPax = bookPass[k].Customer__c;
                                    
                                    }
                                
                                }
                                
                                //If no last name matches were found then go here
                                if(noOfMatches == 0){
                                
                                    //Loop through the Booking Passengers again
                                    for(integer k = 0; k < bookPass.size(); k++){
                                    
                                        //Check the booking date and see if it's sooner than the booking date in the variable
                                        if(bookingDate == Null || bookPass[k].Original_Booking_Date__c >= bookingDate){
                                        
                                            //If it ius then set the current booking date to be the variable
                                            bookingDate = bookPass[k].Original_Booking_Date__c;
                                            
                                            //Then set the other variables to match the current Booking Passenger
                                            latestBookingId = bookPass[k].Booking__c;
                                            businessUnit = bookPass[k].Business_Unit_Lookup__c;
                                            leadPaxCont = bookPass[k].Customer__c;
                                            
                                            if(bookPass[k].Lead_Passenger__c){
                                            
                                                leadPax = bookPass[k].Customer__c;
                                            
                                            }
                                        
                                        }
                                    
                                    }
                                    
                                    //After looping though you will be left with the details of the most recent Booking Passenger. Add them to the case
                                    email2CaseCases[i].Booking__c = latestBookingId;
                                    email2CaseCases[i].Business_Unit__c = businessUnit;
                                    email2CaseCases[i].Lead_Passenger__c = leadPax;
                                
                                //If only one match on last name was found then we know we have our Booking Passenger
                                } else if(noOfMatches == 1){
                                
                                    //All of the variables were set earlier so just add them to the case
                                    email2CaseCases[i].Booking__c = latestBookingId;
                                    email2CaseCases[i].Business_Unit__c = businessUnit;
                                    email2CaseCases[i].Booking_Passenger__c = matchedPax.Id;
                                    email2CaseCases[i].ContactId = matchedPax.Customer__r.personContactId;
                                    email2CaseCases[i].Lead_Passenger__c = leadPax;
                                    
                                //If more than one match on last name was found then go here
                                } else{
                                    
                                    bookingDate = Null;
                                    
                                    for(integer k = 0; k < bookPass.size(); k++){
                                    
                                        if(lastName == bookPass[k].Last_Name__c && (bookingDate == Null || bookPass[k].Original_Booking_Date__c > bookingDate)){
                                        
                                            bookingDate = bookPass[k].Original_Booking_Date__c;
                                            latestBookingId = bookPass[k].Booking__c;
                                            businessUnit = bookPass[k].Business_Unit_Lookup__c;
                                            matchedPax = bookPass[k];
                                        
                                        }
                                    
                                    }
                                    
                                    for(integer k = 0; k < bookPass.size(); k++){
                                    
                                        if(latestBookingId == bookPass[k].Booking__c && bookPass[k].Lead_Passenger__c == TRUE){
                                        
                                            leadPax = bookPass[k].Customer__c;
                                        
                                        }
                                    
                                    }
                                    
                                    email2CaseCases[i].Booking__c = latestBookingId;
                                    email2CaseCases[i].Business_Unit__c = businessUnit;
                                    email2CaseCases[i].Booking_Passenger__c = matchedPax.Id;
                                    email2CaseCases[i].ContactId = matchedPax.Customer__r.personContactId;
                                    email2CaseCases[i].Lead_Passenger__c = leadPax;
                                
                                }
                            
                            }
                        
                        }
                    
                    } else{
                    
                        //if no Booking Passengers were found with the Booking Number then look just for Bookings and grab the most recent one
                        List<Booking__c> books = [SELECT Id, Original_Booking_Date__c, Selling_Company__c, name FROM Booking__c WHERE name = :bookingNumber order by Original_Booking_Date__c desc LIMIT 1];
                        
                        //Make sure 1 Booking was found
                        if(books.size() == 1){
                        
                            //Populate the case with the details of the Booking
                            email2CaseCases[i].Booking__c = books[0].Id;
                            email2CaseCases[i].Business_Unit__c = books[0].Selling_Company__c;
                            
                        }
                        
                    }
                    
                }
            
            }
        
        }
        
    }
    
}