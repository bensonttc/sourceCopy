public with sharing class bookingPassengerTriggerHandler {

    /******************************************
    ************Next Booking Date**************
    ******************************************/
    
    public Void NextBookingDate(List<Booking_Passenger__c> newList) {
    
        //Declare variables
        List<Booking_Passenger__c> pax = new List<Booking_Passenger__c>();
        List<Account> cust = new List<Account>();
        Set<Account> updateAccts = new Set<Account>();
        List<Id> paxId = new List<Id>();
        List<Id> custId = new List<Id>();
        Map<Id, String> paxStatus = new Map<Id, String>();
        Map<Id, Id> paxCustomer = new Map<Id, Id>();
        Map<Id, Date> paxDate = new Map<Id, Date>();
        Map<Id, Date> contikiDate = new Map<Id, Date>();
        Map<Id, Date> insightDate = new Map<Id, Date>();
        Map<Id, Date> trafalgarDate = new Map<Id, Date>();
        Map<Id, Date> uniworldDate = new Map<Id, Date>();
        Map<Id, Id> contikiBooking = new Map<Id, Id>();
        Map<Id, Id> insightBooking = new Map<Id, Id>();
        Map<Id, Id> trafalgarBooking = new Map<Id, Id>();
        Map<Id, Id> uniworldBooking = new Map<Id, Id>();
        
        //iterate through all passed Bookings
        for(Booking_Passenger__c bookPass : newList) {
        
            //For each booking find the corresponding prior values
            Booking_Passenger__c oldBookPass = (Booking_Passenger__c) trigger.oldMap.get(bookPass.Id);
            
            //At each booking, check if it has a closed status, and also check that the Status was not the same before the edit
            if(((bookPass.Client_Status__c != oldBookPass.Client_Status__c && bookPass.Customer__c != Null && bookPass.First_Departure_Date_Text__c > date.today()) || (bookPass.Customer__c != oldBookPass.Customer__c && BookPass.Customer__c != Null && bookPass.First_Departure_Date_Text__c > date.today() && bookPass.client_Status__c == 'Confirmed')) && (bookPass.Brand_Text__c == 'Contiki' || bookPass.Brand_Text__c == 'Insight' || bookPass.brand_Text__c == 'Trafalgar' || bookPass.Brand_Text__c == 'Uniworld')){
            
                //Create two maps. One of the map has the Status and the other has the Payment Status
                pax.add(bookPass);
                paxId.add(bookPass.Id);
                custId.add(bookPass.Customer__c);
                paxStatus.put(bookPass.Id, bookPass.Client_Status__c);
                paxCustomer.put(bookPass.Id, BookPass.Customer__c);
                paxDate.put(bookPass.Id, bookPass.First_Departure_Date_Text__c);
                contikiDate.put(bookPass.Customer__c, Null);
                insightDate.put(bookPass.Customer__c, Null);
                trafalgarDate.put(bookPass.Customer__c, Null);
                uniworldDate.put(bookPass.Customer__c, Null);
                contikiBooking.put(bookPass.Customer__c, Null);
                insightBooking.put(bookPass.Customer__c, Null);
                trafalgarBooking.put(bookPass.Customer__c, Null);
                uniworldBooking.put(bookPass.Customer__c, Null);
            
            }
        
        }
        
        //pull a SOQL list of Accounts where you can see the current Next dates on the Accounts the Booking Passengers are linked to
        cust = [SELECT Id, Next_Contiki_Booking__c, Next_Insight_Booking__c, Next_Trafalgar_Booking__c, Next_Uniworld_Booking__c, CH_Booking__c, IV_Booking__c, TT_Booking__c, UW_Booking__c FROM Account WHERE Id IN :custId];
        
        //Do a nested loop through the two pulled lists. Make them into one single list, like what was given the first time only with all the up to date information
        if(pax.size() > 0 && cust.size() > 0 && pax != Null && cust != Null){
        
            for(integer x = 0; x < pax.size(); x++){
                
                for (integer y = 0; y < cust.size(); y++){
                
                    if(pax[x].Customer__c == cust[y].Id){
                    
                        if(cust[y].Next_Contiki_Booking__c != Null){
                        
                            contikiDate.put(pax[x].Customer__c, cust[y].Next_Contiki_Booking__c);
                            contikiBooking.put(pax[x].Customer__c, cust[y].CH_Booking__c);
                            
                        }
                        
                        if(cust[y].Next_Insight_Booking__c != Null){
                        
                            insightDate.put(pax[x].Customer__c, cust[y].Next_Insight_Booking__c);
                            insightBooking.put(pax[x].Customer__c, cust[y].IV_Booking__c);
                        
                        }
                        
                        if(cust[y].Next_Trafalgar_Booking__c != Null){
                        
                            trafalgarDate.put(pax[x].Customer__c, cust[y].Next_Trafalgar_Booking__c);
                            trafalgarBooking.put(pax[x].Customer__c, cust[y].TT_Booking__c);
                        
                        }
                        
                        if(cust[y].Next_Uniworld_Booking__c != Null){
                        
                            uniworldDate.put(pax[x].Customer__c, cust[y].Next_Uniworld_Booking__c);
                            uniworldBooking.put(pax[x].Customer__c, cust[y].UW_Booking__c);
                            
                        }
                    
                    }
                
                }
            
            }
        
        }
        
        //Nullify the Account list, it will be used again later
        cust.clear();
        
        //Make sure there is atleast one Booking Passenger
        if(pax.size() > 0 && pax != Null){
        
            //Start looping through the list
            for(integer x = 0; x < pax.size(); x++){
                
                //Check that the current Booking Passenger is on Contiki
                if(pax[x].Brand_Text__c == 'Contiki'){
                
                    //Check if the status is Confirmed
                    if(paxStatus.get(pax[x].id) == 'Confirmed'){
                    
                        //If the Next Contiki Booking is blank then populate with the current Booking Passenger's First Departure Date and Booking Id
                        if(contikiDate.get(pax[x].Customer__c) == Null){
                        
                            contikiDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            contikiBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                        
                        //Otherwise, if there is a date in Next Contiki Booking, then check the date is before the current Booking Passenger's First Departure Date
                        //If that is so then populate with the current Booking Passenger's First Departure Date and Booking Id
                        else if(contikiDate.get(pax[x].Customer__c) < paxDate.get(pax[x].Id)){
                        
                            contikiDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            contikiBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                    
                    }
                    
                    //If the status is Cancelled, chech that the Next Contiki Booking field is not blank
                    else if(paxStatus.get(pax[x].id) == 'Cancelled' && contikiDate.get(pax[x].Customer__c) != Null){
                    
                        //Check if the Next Contiki Booking date is the same as the First Departure Date of the Booking Passenger
                        if(contikiDate.get(pax[x].Customer__c) == paxDate.get(pax[x].Id)){
                        
                            //Set Next Contiki Booking and CH Booking to Null 
                            contikiDate.put(pax[x].Customer__c, Null);
                            contikiBooking.put(pax[x].Customer__c, Null);
                            
                            //Pull a SOQL list of all Booking Passengers linked to the Account and see if there is one that has a date in the future
                            List<Booking_Passenger__c> otherBooks = new List<Booking_Passenger__c>();
                            
                            otherBooks = [SELECT Id, First_Departure_Date_Text__c, Client_Status__c, Customer__c, Booking__c, Booking__r.Brand__c, Booking__r.Payment_Status__c FROM Booking_Passenger__c WHERE Customer__c = :pax[x].Customer__c and Client_Status__c = 'Confirmed' and Booking__r.Id != :pax[x].Booking__c and Booking__r.Brand__c = 'Contiki' and Booking__r.Payment_Status__c = 'FP' and Id != :pax[x].Id ORDER BY First_Departure_Date_Text__c DESC LIMIT 1];
                            
                            //If you find one then add the details to Next Contiki Booking and CH Booking fields on the Account
                            if(otherBooks.size() == 1 && otherBooks != Null){
                            
                                contikiDate.put(pax[x].Customer__c, otherBooks[0].First_Departure_Date_Text__c);
                                contikiBooking.put(pax[x].Customer__c, otherBooks[0].Booking__c);
                            
                            }
                        
                        }
                    
                    }
                
                }
                
                //Check that the current Booking Passenger is on Insight
                else if(pax[x].Brand_Text__c == 'Insight'){
                
                    //Check if the status is Confirmed
                    if(paxStatus.get(pax[x].id) == 'Confirmed'){
                    
                        //If the Next Insight Booking is blank then populate with the current Booking Passenger's First Departure Date and Booking Id
                        if(insightDate.get(pax[x].Customer__c) == Null){
                        
                            insightDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            insightBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                        
                        //Otherwise, if there is a date in Next Insight Booking, then check the date is before the current Booking Passenger's First Departure Date
                        //If that is so then populate with the current Booking Passenger's First Departure Date and Booking Id
                        else if(insightDate.get(pax[x].Customer__c) < paxDate.get(pax[x].Id)){
                        
                            insightDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            insightBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                    
                    }
                    
                    //If the status is Cancelled, chech that the Next Insight Booking field is not blank
                    else if(paxStatus.get(pax[x].id) == 'Cancelled' && insightDate.get(pax[x].Customer__c) != Null){
                    
                        //Check if the Next Insight Booking date is the same as the First Departure Date of the Booking Passenger
                        if(insightDate.get(pax[x].Customer__c) == paxDate.get(pax[x].Id)){
                        
                            //Set Next Insight Booking and IV Booking to Null
                            insightDate.put(pax[x].Customer__c, Null);
                            insightBooking.put(pax[x].Customer__c, Null);
                            
                            //Pull a SOQL list of all Booking Passengers linked to the Account and see if there is one that has a date in the future
                            List<Booking_Passenger__c> otherBooks = new List<Booking_Passenger__c>();
                            
                            otherBooks = [SELECT Id, First_Departure_Date_Text__c, Client_Status__c, Customer__c, Booking__c, Booking__r.Brand__c, Booking__r.Payment_Status__c FROM Booking_Passenger__c WHERE Customer__c = :pax[x].Customer__c and Client_Status__c = 'Confirmed' and Booking__r.Id != :pax[x].Booking__c and Booking__r.Brand__c = 'Insight' and Booking__r.Payment_Status__c = 'FP' and Id != :pax[x].Id ORDER BY First_Departure_Date_Text__c DESC LIMIT 1];
                            
                            //If you find one then add the details to Next Insight Booking and IV Booking fields on the Account
                            if(otherBooks.size() == 1 && otherBooks != Null){
                            
                                insightDate.put(pax[x].Customer__c, otherBooks[0].First_Departure_Date_Text__c);
                                insightBooking.put(pax[x].Customer__c, otherBooks[0].Booking__c);
                            
                            }
                            
                        }
                    
                    }
                
                }
                
                //Check that the current Booking Passenger is on Trafalgar
                else if(pax[x].Brand_Text__c == 'Trafalgar'){
                
                    //Check if the status is Confirmed
                    if(paxStatus.get(pax[x].id) == 'Confirmed'){
                    
                        //If the Next Trafalgar Booking is blank then populate with the current Booking Passenger's First Departure Date and Booking Id
                        if(trafalgarDate.get(pax[x].Customer__c) == Null){
                        
                            trafalgarDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            trafalgarBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                        
                        //Otherwise, if there is a date in Next Trafalgar Booking, then check the date is before the current Booking Passenger's First Departure Date
                        //If that is so then populate with the current Booking Passenger's First Departure Date and Booking Id
                        else if(trafalgarDate.get(pax[x].Customer__c) < paxDate.get(pax[x].Id)){
                        
                            trafalgarDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            trafalgarBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                    
                    }
                    
                    //If the status is Cancelled, chech that the Next Trafalgar Booking field is not blank
                    else if(paxStatus.get(pax[x].id) == 'Cancelled' && trafalgarDate.get(pax[x].Customer__c) != Null){
                    
                        //Check if the Next Trafalgar Booking date is the same as the First Departure Date of the Booking Passenger
                        if(trafalgarDate.get(pax[x].Customer__c) == paxDate.get(pax[x].Id)){
                        
                            //Set Next Trafalfar Booking and TT Booking to Null
                            trafalgarDate.put(pax[x].Customer__c, Null);
                            trafalgarBooking.put(pax[x].Customer__c, Null);
                            
                            //Pull a SOQL list of all Booking Passengers linked to the Account and see if there is one that has a date in the future
                            List<Booking_Passenger__c> otherBooks = new List<Booking_Passenger__c>();
                            
                            otherBooks = [SELECT Id, First_Departure_Date_Text__c, Client_Status__c, Customer__c, Booking__c, Booking__r.Brand__c, Booking__r.Payment_Status__c FROM Booking_Passenger__c WHERE Customer__c = :pax[x].Customer__c and Client_Status__c = 'Confirmed' and Booking__r.Id != :pax[x].Booking__c and Booking__r.Brand__c = 'Trafalgar' and Booking__r.Payment_Status__c = 'FP' and Id != :pax[x].Id ORDER BY First_Departure_Date_Text__c DESC LIMIT 1];
                            
                            //If you find one then add the details to Next Trafalgar Booking and TT Booking fields on the Account
                            if(otherBooks.size() == 1 && otherBooks != Null){
                            
                                trafalgarDate.put(pax[x].Customer__c, otherBooks[0].First_Departure_Date_Text__c);
                                trafalgarBooking.put(pax[x].Customer__c, otherBooks[0].Booking__c);
                            
                            }
                            
                        }
                    
                    }
                
                }
                
                //Check that the current Booking Passenger is on Uniworld
                else if(pax[x].Brand_Text__c == 'Uniworld'){
                
                    //Check if the status is Confirmed
                    if(paxStatus.get(pax[x].id) == 'Confirmed'){
                    
                        //If the Next Uniworld Booking is blank then populate with the current Booking Passenger's First Departure Date and Booking Id
                        if(uniworldDate.get(pax[x].Customer__c) == Null){
                        
                            uniworldDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            uniworldBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                        
                        //Otherwise, if there is a date in Next Uniworld Booking, then check the date is before the current Booking Passenger's First Departure Date
                        //If that is so then populate with the current Booking Passenger's First Departure Date and Booking Id
                        else if(uniworldDate.get(pax[x].Customer__c) < paxDate.get(pax[x].Id)){
                        
                            uniworldDate.put(pax[x].Customer__c, paxDate.get(pax[x].Id));
                            uniworldBooking.put(pax[x].Customer__c, pax[x].Booking__c);
                        
                        }
                    
                    }
                    
                    //If the status is Cancelled, chech that the Next Uniworld Booking field is not blank
                    else if(paxStatus.get(pax[x].id) == 'Cancelled' && uniworldDate.get(pax[x].Customer__c) != Null){
                    
                        //Check if the Next Uniworld Booking date is the same as the First Departure Date of the Booking Passenger
                        if(uniworldDate.get(pax[x].Customer__c) == paxDate.get(pax[x].Id)){
                        
                            //Set Next Uniworld Booking and UW Booking to Null
                            uniworldDate.put(pax[x].Customer__c, Null);
                            uniworldBooking.put(pax[x].Customer__c, Null);
                            
                            //Pull a SOQL list of all Booking Passengers linked to the Account and see if there is one that has a date in the future
                            List<Booking_Passenger__c> otherBooks = new List<Booking_Passenger__c>();
                            
                            otherBooks = [SELECT Id, First_Departure_Date_Text__c, Client_Status__c, Customer__c, Booking__c, Booking__r.Brand__c, Booking__r.Payment_Status__c FROM Booking_Passenger__c WHERE Customer__c = :pax[x].Customer__c and Client_Status__c = 'Confirmed' and Booking__r.Id != :pax[x].Booking__c and Booking__r.Brand__c = 'Uniworld' and Booking__r.Payment_Status__c = 'FP' and Id != :pax[x].Id ORDER BY First_Departure_Date_Text__c DESC LIMIT 1];
                            
                            //If you find one then add the details to Next Uniworld Booking and UW Booking fields on the Account
                            if(otherBooks.size() == 1 && otherBooks != Null){
                            
                                uniworldDate.put(pax[x].Customer__c, otherBooks[0].First_Departure_Date_Text__c);
                                uniworldBooking.put(pax[x].Customer__c, otherBooks[0].Booking__c);
                            
                            }
                            
                        }
                    
                    }
                
                }
            
            }
            
            //After going through all the Booking Passengers, extract the Accounts and put them into a list
            for(integer x = 0; x < pax.size(); x++){
            
                Account acct = new Account(id = pax[x].Customer__c, Next_Contiki_Booking__c = contikiDate.get(pax[x].Customer__c), Next_Insight_Booking__c = insightDate.get(pax[x].Customer__c), Next_Trafalgar_Booking__c = trafalgarDate.get(pax[x].Customer__c), Next_Uniworld_Booking__c = uniworldDate.get(pax[x].Customer__c), CH_Booking__c = contikiBooking.get(pax[x].Customer__c), IV_Booking__c = insightBooking.get(pax[x].Customer__c), TT_Booking__c = trafalgarBooking.get(pax[x].Customer__c), UW_Booking__c = uniworldBooking.get(pax[x].Customer__c));
                
                cust.add(acct);
            
            }
            
            //Deduplicate Accounts List
            set<Account> deDupe = new set<Account>(cust);
            cust.clear();
            cust.addAll(deDupe);
            
            //Update Accounts
            update cust;
        
        }
    
    }

}