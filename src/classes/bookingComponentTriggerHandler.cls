public with sharing class bookingComponentTriggerHandler {
    
    public void UpdateFields(List<Booking_Component__c> newList) {
    
        //Declare variables for this trigger
        List<Account> accts = new List<Account>();
        Set<Id> updatedBooks = new Set<Id>();
        List<Booking_Component__c> matchEditedBooks = new List<Booking_Component__c>();
        List<Booking_Component__c> matchMergedBooks = new List<Booking_Component__c>();
        List<Id> matchEditedBooksIds = new List<Id>();
        List<Id> matchMergedBooksIds = new List<Id>();
        List<Booking_Component__c> Books = new List<Booking_Component__c>();
        List<Id> CustomerIds = new List<Id>();
        Id tourRecordTypeId = Schema.SObjectType.Booking_Component__c.getRecordTypeInfosByName().get('Tour').getRecordTypeId();
        Map<Id, Integer> insightCount = new Map<Id, Integer>();
        Map<Id, Integer> trafalgarCount = new Map<Id, Integer>();
        Map<Id, Integer> contikiCount = new Map<Id, Integer>();
        Map<Id, Integer> uniworldCount = new Map<Id, Integer>();
        Map<Id, Integer> aatKingsCount = new Map<Id, Integer>();
        
        //If the trigger is an Update or an Insert then check all the new details and add them to the Account and Id lists
        for(Booking_Component__c compts : newList){
                
            Booking_Component__c oldBook = (Booking_Component__c) trigger.oldMap.get(compts.Id);
            
            if(((compts.Customer__c != Null && compts.Status__c != oldBook.Status__c) || (compts.Customer__c != oldBook.Customer__c && compts.Status__c == 'CF')) && (compts.Hidden_Brand__c == 'Contiki' || compts.Hidden_Brand__c == 'Insight' || compts.Hidden_Brand__c == 'Trafalgar' || compts.Hidden_Brand__c == 'Uniworld' || compts.Hidden_Brand__c == 'AAT Kings') && compts.RecordTypeId == tourRecordTypeId){
            
                Account thisAccount = new Account(Id = compts.Customer__c, Contiki_Tour_Count__c = 0, Trafalgar_Tour_Count__c = 0, Insight_Tour_Count__c = 0, Uniworld_Tour_Count__c = 0, AAT_Kings_Tour_Count__c = 0);
                
                accts.add(thisAccount);
                CustomerIds.add(compts.Customer__c);
                
                //If a Booking Component is Confirmed and is a Tour then add it to the list of Booking Components that have been edited for this trigger, which should affect the numbers on the parent account
                if(compts.Status__c == 'CF' && compts.RecordTypeId == tourRecordTypeId && (compts.Hidden_Brand__c == 'Insight' || compts.Hidden_Brand__c == 'Trafalgar' || compts.Hidden_Brand__c == 'Contiki' || compts.Hidden_Brand__c == 'Uniworld' || compts.Hidden_Brand__c == 'AAT Kings')){
                    
                    matchEditedBooks.add(compts);
                    matchEditedBooksIds.add(compts.Id);
                    
                }
                
                //If the trigger is an update and if the Status was changed from Confirmed to anything except confirmed then make sure this Booking Component does not get counted on the Parent Account
                if(compts.Status__c != 'CF' & oldBook.Status__c == 'CF'){
                    
                    updatedBooks.add(compts.Id);
                    
                }
                
                //If the Account got moved from one Booking Component to another, reduce the Tour Count on the removed Account by 1
                if(compts.Customer__c != Null && oldBook.Customer__c != Null && compts.Customer__c != oldBook.Customer__c){
                    
                    matchMergedBooks.add(oldBook);
                    matchMergedBooksIds.add(oldBook.Customer__c);
                    
                }
                
            }    
         
        }
        
        //Process the updated Booking Components first. These are the Booking Components that were edited/created to fire the trigger
        if(matchEditedBooks.Size() > 0){
            
            for(integer i = 0; i < matchEditedBooks.Size(); i++){
            
                //In each case find the ones in the brands we are looking for and add the numbers up on those accounts where needed
                if(matchEditedBooks[i].Hidden_Brand__c == 'Insight'){
                        
                    //When an account has passed one of the brand checks then make sure it will not get counted later when all Booking Components are looked for
                    updatedBooks.add(matchEditedBooks[i].Id);
                    
                    //If the brand is found then check to see if there is a Set created for that Account Id
                    if(insightCount.containsKey(matchEditedBooks[i].Customer__c)){
                    
                        //If there is then add 1 to the number against that Id
                        integer num = insightCount.get(matchEditedBooks[i].Customer__c);
                        insightCount.put(matchEditedBooks[i].Customer__c, num+1);
                    
                    }
                    
                    else{
                    
                        //If not then create a new set with that Id and the number 1
                        insightCount.put(matchEditedBooks[i].Customer__c, 1);
                    
                    }
                
                }
                
                if(matchEditedBooks[i].Hidden_Brand__c == 'trafalgar'){
                
                    updatedBooks.add(matchEditedBooks[i].Id);
                    
                    if(trafalgarCount.containsKey(matchEditedBooks[i].Customer__c)){
                    
                        integer num = trafalgarCount.get(matchEditedBooks[i].Customer__c);
                        trafalgarCount.put(matchEditedBooks[i].Customer__c, num+1);
                    
                    }
                    
                    else{
                    
                        trafalgarCount.put(matchEditedBooks[i].Customer__c, 1);
                    
                    }
                
                }
                
                if(matchEditedBooks[i].Hidden_Brand__c == 'Contiki'){
                
                    updatedBooks.add(matchEditedBooks[i].Id);
                    
                    if(contikiCount.containsKey(matchEditedBooks[i].Customer__c)){
                    
                        integer num = contikiCount.get(matchEditedBooks[i].Customer__c);
                        contikiCount.put(matchEditedBooks[i].Customer__c, num+1);
                    
                    }
                    
                    else{
                    
                        contikiCount.put(matchEditedBooks[i].Customer__c, 1);
                    
                    }
                
                }
                
                if(matchEditedBooks[i].Hidden_Brand__c == 'Uniworld'){
                
                    updatedBooks.add(matchEditedBooks[i].Id);
                    
                    if(uniworldCount.containsKey(matchEditedBooks[i].Customer__c)){
                    
                        integer num = uniworldCount.get(matchEditedBooks[i].Customer__c);
                        uniworldCount.put(matchEditedBooks[i].Customer__c, num+1);
                    
                    }
                    
                    else{
                    
                        uniworldCount.put(matchEditedBooks[i].Customer__c, 1);
                    
                    }
                
                }
                
                if(matchEditedBooks[i].Hidden_Brand__c == 'AAT Kings'){
                
                    updatedBooks.add(matchEditedBooks[i].Id);
                    
                    if(aatKingsCount.containsKey(matchEditedBooks[i].Customer__c)){
                    
                        integer num = aatKingsCount.get(matchEditedBooks[i].Customer__c);
                        aatKingsCount.put(matchEditedBooks[i].Customer__c, num+1);
                    
                    }
                    
                    else{
                    
                        aatKingsCount.put(matchEditedBooks[i].Customer__c, 1);
                    
                    }
                
                }
            
            }
        
        }
        
        //If there is at least 1 Customer Id in all of the Booking Components that were edited then proceed to find the child Booking Components
        if(accts.size() > 0){
        
            //Select all Booking_Components from Salesforce with selected details based on the Account Ids
            Books = [SELECT Id, Hidden_Brand__c, Status__c, Customer__c, recordTypeId FROM Booking_Component__c WHERE Customer__c IN :CustomerIds AND recordTypeId = :tourRecordTypeId AND Status__c = 'CF' AND (Booking_Number__r.Selling_Company__r.Parent.Name = 'Insight' OR Booking_Number__r.Selling_Company__r.Parent.Name = 'Trafalgar' OR Booking_Number__r.Selling_Company__r.Parent.Name = 'Contiki' OR Booking_Number__r.Selling_Company__r.Parent.Name = 'Uniworld' OR Booking_Number__r.Selling_Company__r.Parent.Name = 'AAT Kings') LIMIT 50000];
        
            //If there is at least 1 Booking Component found then proceed
            if(Books.size() > 0){
            
                //Start iterating through all of the Booking Components
                for(integer i = 0; i < Books.Size(); i++){
                
                    if((updatedBooks.contains(Books[i].Id)) == false){
                    
                        //Make 5 checks to see if the brand is one of the 5 we are looking for
                        if(Books[i].Hidden_Brand__c == 'Insight'){
                        
                            //If the brand is found then check to see if there is a Set created for that Account Id
                            if(insightCount.containsKey(Books[i].Customer__c)){
                            
                                //If there is then add 1 to the number against that Id
                                integer num = insightCount.get(Books[i].Customer__c);
                                insightCount.put(Books[i].Customer__c, num+1);
                            
                            }
                            
                            else{
                            
                                //If not then create a new set with that Id and the number 1
                                insightCount.put(Books[i].Customer__c, 1);
                            
                            }
                        
                        }
                        
                        if(Books[i].Hidden_Brand__c == 'trafalgar'){
                        
                            if(trafalgarCount.containsKey(Books[i].Customer__c)){
                            
                                integer num = trafalgarCount.get(Books[i].Customer__c);
                                trafalgarCount.put(Books[i].Customer__c, num+1);
                            
                            }
                            
                            else{
                            
                                trafalgarCount.put(Books[i].Customer__c, 1);
                            
                            }
                        
                        }
                        
                        if(Books[i].Hidden_Brand__c == 'Contiki'){
                        
                            if(contikiCount.containsKey(Books[i].Customer__c)){
                            
                                integer num = contikiCount.get(Books[i].Customer__c);
                                contikiCount.put(Books[i].Customer__c, num+1);
                            
                            }
                            
                            else{
                            
                                contikiCount.put(Books[i].Customer__c, 1);
                            
                            }
                        
                        }
                        
                        if(Books[i].Hidden_Brand__c == 'Uniworld'){
                        
                            if(uniworldCount.containsKey(Books[i].Customer__c)){
                            
                                integer num = uniworldCount.get(Books[i].Customer__c);
                                uniworldCount.put(Books[i].Customer__c, num+1);
                            
                            }
                            
                            else{
                            
                                uniworldCount.put(Books[i].Customer__c, 1);
                            
                            }
                        
                        }
                        
                        if(Books[i].Hidden_Brand__c == 'AAT Kings'){
                        
                            if(aatKingsCount.containsKey(Books[i].Customer__c)){
                            
                                integer num = aatKingsCount.get(Books[i].Customer__c);
                                aatKingsCount.put(Books[i].Customer__c, num+1);
                            
                            }
                            
                            else{
                            
                                aatKingsCount.put(Books[i].Customer__c, 1);
                            
                            }
                        
                        }
                        
                    }
                
                }
            
            }
            
            if(matchMergedBooks.size() > 0){
                
                for(Account mergedAccounts : [SELECT Id, Insight_Tour_Count__c, Trafalgar_Tour_Count__c, Contiki_Tour_Count__c, Uniworld_Tour_Count__c, AAT_Kings_Tour_Count__c FROM Account WHERE Id in :matchMergedBooksIds]){
                    
                    insightCount.put(mergedAccounts.id, integer.valueof(mergedAccounts.Insight_Tour_Count__c));
                    contikiCount.put(mergedAccounts.id, integer.valueof(mergedAccounts.Contiki_Tour_Count__c));
                    trafalgarCount.put(mergedAccounts.id, integer.valueof(mergedAccounts.Trafalgar_Tour_Count__c));
                    uniworldCount.put(mergedAccounts.id, integer.valueof(mergedAccounts.Uniworld_Tour_Count__c));
                    aatKingsCount.put(mergedAccounts.id, integer.valueof(mergedAccounts.AAT_Kings_Tour_Count__c));
                    
                }
                
                for(integer i = 0; i < matchMergedBooks.size(); i++){
                    
                    //Make 5 checks to see if the brand is one of the 5 we are looking for
                    if(matchMergedBooks[i].Hidden_Brand__c == 'Insight'){
                        
                        //If the brand is found then check to see if there is a Set created for that Account Id
                        if(insightCount.containsKey(matchMergedBooks[i].Customer__c)){
                            
                            //If there is then add 1 to the number against that Id
                            integer num = insightCount.get(matchMergedBooks[i].Customer__c);
                            insightCount.put(matchMergedBooks[i].Customer__c, num-1);
                            
                        }
                        
                    }
                    
                    if(matchMergedBooks[i].Hidden_Brand__c == 'trafalgar'){
                        
                        if(trafalgarCount.containsKey(matchMergedBooks[i].Customer__c)){
                            
                            integer num = trafalgarCount.get(matchMergedBooks[i].Customer__c);
                            trafalgarCount.put(matchMergedBooks[i].Customer__c, num-1);
                            
                        }
                        
                    }
                    
                    if(matchMergedBooks[i].Hidden_Brand__c == 'Contiki'){
                        
                        if(contikiCount.containsKey(matchMergedBooks[i].Customer__c)){
                            
                            integer num = contikiCount.get(matchMergedBooks[i].Customer__c);
                            contikiCount.put(matchMergedBooks[i].Customer__c, num-1);
                            
                        }
                        
                    }
                    
                    if(matchMergedBooks[i].Hidden_Brand__c == 'Uniworld'){
                        
                        if(uniworldCount.containsKey(matchMergedBooks[i].Customer__c)){
                            
                            integer num = uniworldCount.get(matchMergedBooks[i].Customer__c);
                            uniworldCount.put(matchMergedBooks[i].Customer__c, num-1);
                            
                        }
                        
                    }
                    
                    if(matchMergedBooks[i].Hidden_Brand__c == 'AAT Kings'){
                        
                        if(aatKingsCount.containsKey(matchMergedBooks[i].Customer__c)){
                            
                            integer num = aatKingsCount.get(matchMergedBooks[i].Customer__c);
                            aatKingsCount.put(matchMergedBooks[i].Customer__c, num-1);
                            
                        }
                        
                    }
                    
                    Account testAcct = new Account(Id = matchMergedBooks[i].Customer__c);
                    accts.add(testAcct);
                    
                }
                
            }
            
            //Deduplicate all of the Accounts
            set<Account> deDupe = new set<Account>(accts);
            accts.Clear();
            accts.addAll(deDupe);
            
            //iterate through the accounts, and for each account set the Passenger Count from the Sets
            for(integer i = 0; i < accts.size(); i++){
                
                if(contikiCount.get(accts[i].Id) != Null){
                
                    accts[i].Contiki_Tour_Count__c = contikiCount.get(accts[i].Id);
                    
                }
                
                if(insightCount.get(accts[i].Id) != Null){
                
                    accts[i].Insight_Tour_Count__c = insightCount.get(accts[i].Id);
                    
                }
                
                if(trafalgarCount.get(accts[i].Id) != Null){
                
                    accts[i].Trafalgar_Tour_Count__c = trafalgarCount.get(accts[i].Id);
                    
                }
                
                if(uniworldCount.get(accts[i].Id) != Null){
                
                    accts[i].Uniworld_Tour_Count__c = uniworldCount.get(accts[i].Id);
                    
                }
                
                if(aatKingsCount.get(accts[i].Id) != Null){
                
                    accts[i].AAT_Kings_Tour_Count__c = aatKingsCount.get(accts[i].Id);
                    
                }
            
            }
        
        }
        
        //Update accounts
        update accts;
    
    }
    
}