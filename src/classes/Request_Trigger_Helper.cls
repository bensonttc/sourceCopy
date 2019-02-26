public without sharing class Request_Trigger_Helper extends TriggerHandlerV2 {
    private MDM_Account_Creation_Setting__c Creation;
    private map<id, Account> AccMap;

    // **************************
    // **** Constructor *********
    // **************************
    public Request_Trigger_Helper() {
        Creation = MDM_Account_Creation_Setting__c.getValues('Active');
        if(Creation == null){
            Creation = new MDM_Account_Creation_Setting__c(Active__c = false, Name = 'Active');
        }

        AccMap = new map<id, Account>();
        MDM_Custom_Synch_Class.Synchronise_This_Object('Request__c', 'MDM_Synchronize__c', 'Should_Synchronise__c', trigger.old, trigger.New, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isBefore, trigger.isAfter, trigger.isUnDelete);
    }


    // **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
        SetBusinessUnitLookup(newObjects);
    }

    // **********************************
    // ******* Before Update *************
    // **********************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) 
    {
        SetBusinessUnitLookup(newObjects);
        if(Creation.Active__c && Creation.Enable_Preference_Management__C){
            system.debug('Marketing Consent Enabled - Process Requests');
            UpdatePreferences(newObjects, oldMap);
        }
        createPastBookerLead(newObjects, oldMap);
    }

    // **********************************
    // ******* Before Delete *************
    // **********************************
    public override void beforeDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
    }

    // **********************************
    // ******* After Insert *************
    // **********************************
    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
       
    }


    // **********************************
    // ******* After Update *************
    // **********************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) 
    {
        
    }

    // **********************************
    // ******* After Delete *************
    // **********************************
    public override void afterDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
    }

    // **********************************
    // ******* After UnDelete *************
    // **********************************
    public override void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap)
    {       
    }

    // *****************************************************************************************************************************************************************************************************************************************************************************************************************************************************

    //********************************
    //*** Set Business Unit Lookup ***
    //********************************
    public void SetBusinessUnitLookup(list<Sobject> NewRequests){

        AccMap = MDM_Helper_Class.setBusinessUnit('Selling_Company__c', 'Business_Unit_Lookup__c', 'Brand_Lookup__c', NewRequests);

        /*set<string> BUExtIDs = new set<string>();
        set<id> BUIDs = new set<id>();
        for(Request__c req : NewRequests){
            if(req.Business_Unit_Lookup__c != null){
                BUIDs.add(req.Business_Unit_Lookup__c);
            }
            else if(req.Selling_Company__c != null){
                BUExtIDs.add(req.Selling_Company__c);
            }
        }

        AccMap = new Map<id, Account>([select id, External_ID__c, parentID, Parent.name, name from Account where External_ID__c in :BUExtIDs OR id in :BUIDs]);
        map<string, ID> ExtMap = new map<string, ID>();
        for(Account Acc : AccMap.values()){
            ExtMap.put(Acc.External_ID__c, Acc.ID);
        }

        //Get brand from SellingCompanyID
        for(Request__c req : NewRequests){
            if(req.Selling_Company__c != null){
                ID BUID = ExtMap.get(req.Selling_Company__c);
                if(BUID != null) req.Business_Unit_Lookup__c = BUID;
            }
            if(req.Business_Unit_Lookup__c != null && AccMap != null){
                req.Brand_Lookup__c = AccMap.get(req.Business_Unit_Lookup__c).parentID;
            }
        }*/

    }

    //********************************
    //*** Create Marketing Consent ***
    //********************************
    public void UpdatePreferences(list<Sobject> Requests, map<id, sobject> oldMap){
        Marketing_Consent_Handler_Class PrefClass = new Marketing_Consent_Handler_Class('Request__c');
        //Get the RCH Brand record


        //get the Booking Passenger information
        for(Sobject sobj: Requests){
            Request__c req = (Request__c) sobj;
            Request__c oldReq = (Request__c) oldMap.get(req.id);
            //Build the Preferences
            if(req.Customer__c != null && (req.Business_Unit_Lookup__c != null || req.Data_Source__c == 'Red Carnation Hotel') && !req.Am_Travel_Agent__c && (oldReq.Customer__c == null || req.Create_MC__c || req.Marketing_Consent__c == null)){
                Marketing_Consent__c thisPref = new Marketing_Consent__c();
                thisPref.Request__c = req.id;
                thisPref.Customer_or_Prospect__c = req.Customer__c;
                thisPref.Date_Entered__c = req.Date_Ordered__c;
                thisPref.Selling_Company__c = req.Business_Unit_lookup__c;
                thisPref.Brand__c = req.Brand_Lookup__c;

                //Set Brand/BU names
                Account BU = AccMap.get(req.Business_Unit_lookup__c);
                thisPref.Brand_Text__c = '';
                if(BU != null){
                    thisPref.Brand_Text__c = BU.parent.name;
                    thisPref.Business_Unit_Text__c = BU.name;
                }

                thisPref.Opt_In__c = !req.Would_Not_Like_Info__c;
                thisPref.Assumed_Opt_in__c = false;                 //!req.Would_Not_Like_Info__c;
                thisPref.Source__c = 'Request';
                //thisPref.Source__c = req.Request_Type__c;
                thisPref.Type__c = req.Request_Type__c;

                if(thisPref.Brand_Text__c == 'RCH' && req.hotel__c != null){
                    thisPref.Hotel__c = req.hotel__c;
                    req.Marketing_Consent_External_ID__c = thisPref.Hotel__c + '#' + thisPref.Customer_or_Prospect__c;

                }
                else{
                    req.Marketing_Consent_External_ID__c = thisPref.Selling_Company__c + '#' + thisPref.Customer_or_Prospect__c;
                }

                
                thisPref.External_ID__c = req.Marketing_Consent_External_ID__c;

                PrefClass.addPreference(thisPref, req.id);
            }
            req.Create_MC__c = false;
        }

        //Create the MC
        map<string, id> SourceToID = PrefClass.createPreferences();

        //Link back to MC
        if(SourceToID.size() > 0){
            for(Sobject sobj: Requests){
                Request__c req = (Request__c) sobj;
                if(req.Marketing_Consent_External_ID__c != null){
                    ID MCID = SourceToID.get(req.Marketing_Consent_External_ID__c);
                    if(MCID != null){
                        req.Marketing_Consent__c = MCID;
                    }
                }
            }
        } 
    }
    
    //*********************************
    //*** Create Past Booker - Lead ***
    //*********************************
    
    public void createPastBookerLead(list<Sobject> Requests, map<id, sobject> oldMap){
    
        //Declare variables
        List<Request__c> reqsToCheck = new List<Request__c>();
        List<Id> custsToCheck = new List<Id>();
        Map<Id, Boolean> pastCustomer = new Map<Id, Boolean>();
        Map<Id, Boolean> futureCustomer = new Map<Id, Boolean>();
        Map<Id, Boolean> onlyPastCustomer = new Map<Id, Boolean>();
        Map<Id, Request__c> customerToRequest = new Map<Id, Request__c>();
        Map<Id, Booking_Passenger__c> customerToBooking = new Map<Id, Booking_Passenger__c>();
        Map<Id, Id> customerBrand = new Map<Id, Id>();
        List<Booking_Passenger__c> bookPass = new List<Booking_Passenger__c>();
        List<Booking_Passenger__c> pastBookers = new List<Booking_Passenger__c>();
        List<Booking_Passenger__c> pastBookPass = new List<Booking_Passenger__c>();
        List<Booking_Passenger__c> futureBookPass = new List<Booking_Passenger__c>();
        List<Booking_Passenger__c> onlyPastBookPass = new List<Booking_Passenger__c>();
        List<Lead> leadsToCreate = new List<Lead>();
        
        //Start looping through the Requests
        for(Sobject sobj: Requests){
            
            Request__c req = (Request__c) sobj;
            Request__c oldReq = (Request__c) oldMap.get(req.id);
            
            /*Set the requirements for creating a lead from one of these Requests
            * Customer was just added to the Request
            * Request is RAB or Request a Brochure
            * Source is Web or Website
            * The customer was on at least 1 previous Tour
            * This is not a Travel Agent Request
            */
            if(req.Customer__c != Null && oldReq.Customer__c == Null && (req.Request_Type__c == 'RAB' || req.Request_Type__c == 'Request a Brochure') && (req.Source_Name__c == 'Web' || req.Source_Name__c == 'Website') && req.Previous_Tours_Count__c > 0 && req.Previous_Tours_Count__c != Null && req.Am_Travel_Agent__c == FALSE && req.Working_with_Travel_Agent__c == FALSE){
            
                reqsToCheck.add(req);
                custsToCheck.add(req.Customer__c);
                pastCustomer.put(req.Customer__c, FALSE);
                futureCustomer.put(req.Customer__c, FALSE);
                onlyPastCustomer.put(req.Customer__c, FALSE);
                customerToRequest.put(req.Customer__c, req);
                customerBrand.put(req.Customer__c, req.Brand_Lookup__c);
            
            }
            
        }
        
        //Make sure at least 1 Request has gotten through
        if(custsToCheck.size() > 0 && custsToCheck != Null){
        
            //Find all Booking Passengers belonging to the associated Accounts
            bookPass = [SELECT Id, Lead_Passenger__c, Customer__c, Customer__r.salutation, Customer__r.firstName, Customer__r.lastName, Customer__r.personEmail, Customer__r.billingStreet, Customer__r.billingCity, Customer__r.billingState, Customer__r.billingPostalCode, Customer__r.billingCountry, Customer__r.phone, Customer__r.Selling_Company__r.name, Booking__c, Booking__r.First_Departure_Date__c, Booking__r.name, Booking__r.Booking_Type__c, Booking__r.First_Reservation_Agent__c, Brand__c, Brand__r.Name FROM Booking_Passenger__c WHERE Customer__c IN :custsToCheck];
        
        }
        
        //Make sure at least 1 Booking Passenger was selected
        if(bookPass.size() > 0 && bookPass != Null){
        
            //Iterate through the Booking Passengers
            for(integer x = 0; x < bookPass.size(); x++){
            
                //Mark each Customer who has a Booking Passenger whose Booking's First Departure Date is in the past and the brand is the same as the brand of the Request
                if(pastCustomer.get(bookPass[x].Customer__c) == FALSE && bookPass[x].Booking__r.First_Departure_Date__c < date.Today() && customerBrand.get(bookPass[x].Customer__c) == bookPass[x].Brand__c){
                
                    pastCustomer.put(bookPass[x].Customer__c, TRUE);
                    pastBookPass.add(bookPass[x]);
                
                }
                
                //Mark each customer who has a Booking Passenger whose Booking's First Departure Date is in the future and the Brand is the same as the Brand of the request
                else if(futureCustomer.get(bookPass[x].Customer__c) == FALSE && bookPass[x].Booking__r.First_Departure_Date__c > date.Today() && customerBrand.get(bookPass[x].Customer__c) == bookPass[x].Brand__c){
                
                    futureCustomer.put(bookPass[x].Customer__c, TRUE);
                    futureBookPass.add(bookPass[x]);
                
                }
            
            }
            
            If(pastBookPass.size() > 0 && pastBookPass != Null){    
                
                //Iterate through the Past Accounts
                for(integer x = 0; x < pastBookPass.size(); x++){
                
                    //For each Past Account identify which ones do not have Future bookings and add them to a list of Accounts that only have past bookings
                    if(pastCustomer.get(pastBookPass[x].Customer__c) == TRUE && futureCustomer.get(pastBookPass[x].Customer__c) == FALSE){
                    
                        onlyPastCustomer.put(pastBookPass[x].Customer__c, TRUE);
                        pastBookers.add(pastBookPass[x]);
                        customerToBooking.put(pastBookPass[x].Customer__c, pastBookPass[x]);
                    
                    }
                
                }
                
            }
        
        }
        
        if(pastBookers.size() > 0 && pastBookers != Null){
        
            for(integer x = 0; x < pastBookers.Size(); x++){
            
                if(customerToBooking.get(pastBookers[x].Customer__c).Booking__r.First_Departure_Date__c == NULL || customerToBooking.get(pastBookers[x].Customer__c).Booking__r.First_Departure_Date__c < pastBookers[x].Booking__r.First_Departure_Date__c){
                
                    customerToBooking.put(pastBookers[x].Customer__c, pastBookers[x]);
                
                }
            
            }
            
            for(integer x = 0; x < pastBookers.size(); x++){
            
                if(customerToBooking.get(pastBookers[x].Customer__c) != Null){
                
                    Booking_Passenger__c thisBookPass = customerToBooking.get(pastBookers[x].Customer__c);
                    Request__c thisRequest = customerToRequest.get(pastBookers[x].Customer__c);
                    Lead thisLead = new Lead();
                    
                    thisLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2C Lead').getRecordTypeId();
                    thisLead.Web_Request_Type__c = 'Request a Brochure';
                    thisLead.LeadSource = 'Web';
                    thisLead.Booking__c = thisBookPass.Booking__c;
                    thisLead.Booking_Type__c = thisBookPass.Booking__r.Booking_Type__c;
                    thisLead.First_Reservation_Agent__c = thisBookPass.Booking__r.First_Reservation_Agent__c;
                    thisLead.salutation = thisBookPass.Customer__r.salutation;
                    thisLead.FirstName = thisBookPass.Customer__r.firstname;
                    thisLead.LastName = thisBookPass.Customer__r.lastName;
                    thisLead.Email = thisBookPass.Customer__r.personEmail;
                    thisLead.Street = thisRequest.Billing_Street__c;
                    thisLead.City = thisRequest.City__c;
                    thisLead.State = thisRequest.State__c;
                    thisLead.PostalCode = thisRequest.Postal_Code__c;
                    thisLead.Country = thisRequest.Country__c;
                    thisLead.Selling_Company_Code__c = thisRequest.Selling_Company__c;
                    thisLead.Brochure_Name__c = thisRequest.Brochure_Name__c;
                    thisLead.Brochure2__c = thisRequest.Brochure2__c;
                    thisLead.Brochure3__c = thisRequest.Brochure3__c;
                    thisLead.Brochure4__c = thisRequest.Brochure4__c;
                    thisLead.Brochure5__c = thisRequest.Brochure5__c;
                    thisLead.Brochure6__c = thisRequest.Brochure6__c;
                    
                    AssignmentRule AR = new AssignmentRule();
                    AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
                    
                    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                    
                    //Setting the DMLOption on Case instance
                    thisLead.setOptions(dmlOpts);
                    
                    leadsToCreate.add(thisLead);
                
                }
            
            }
        
        }
        
        insert leadsToCreate;
        
    }
    
}