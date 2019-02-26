public without sharing class Booking_Passenger_Trigger_Helper extends TriggerHandlerV2 {
    private MDM_Account_Creation_Setting__c Creation;
    
    // **************************
    // **** Constructor *********
    // **************************
    public Booking_Passenger_Trigger_Helper() {
        MDM_Custom_Synch_Class.Synchronise_This_Object('Booking_Passenger__c', 'MDM_Synchronize__c', 'Should_Synchronise__c', trigger.old, trigger.New, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isBefore, trigger.isAfter, trigger.isUnDelete);
        
        Creation = MDM_Account_Creation_Setting__c.getValues('Active');
        if(Creation == null){
            Creation = new MDM_Account_Creation_Setting__c(Active__c = false, Name = 'Active');
        }
    }

    public static map<string, ID> PaxRTs{
        get{
            if(PaxRTs == null){
                PaxRTs = new  map<string, ID>();
                for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking_Passenger__c']){
                    PaxRTs.put(RT.DeveloperName, RT.id);
                }
            }
            return PaxRTs;
        }
        set;
    }


    // **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
        
    }

    // **********************************
    // ******* Before Update *************
    // **********************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) 
    {
        if(Creation.Active__c && Creation.Enable_Preference_Management__C){
            UpdatePreferences(newObjects, oldMap);
        }
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
       UpdateBookingLeadPax(newObjectsMap);
    }


    // **********************************
    // ******* After Update *************
    // **********************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) 
    {
        UpdateBookingLeadPax(newObjectsMap);
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

    //*****************************************
    //*** Set Lead Passenger on the Booking ***
    //*****************************************
    public void UpdateBookingLeadPax(map<id, sobject> Bookingpax){
        //Update the Booking Lead Passenger
        map<ID, Booking__c> BookingMap = new map<ID, Booking__c>();

        for(sobject sobj: Bookingpax.values()){
            booking_passenger__c pax = (booking_passenger__c) sobj;

            if(pax.Lead_Passenger__c == true && pax.Customer__c != null){
                Booking__c Book = new Booking__c();
                Book.Lead_Passenger__c = pax.Customer__c;
                Book.ID = pax.Booking__c;
                BookingMap.put(Book.ID, Book);
            }
        }
        if(BookingMap.size() > 0){
            update BookingMap.values();
        }
    }

    //********************************
    //*** Create Marketing Consent ***
    //********************************
    public static void UpdatePreferences(list<sobject> Bookingpax, map<id, sobject> oldMap){
        Marketing_Consent_Handler_Class PrefClass = new Marketing_Consent_Handler_Class('Booking_Passenger__c');

        //loop round to get Bookings
        set<id> BookId = new set<id>();
        for(sobject sobj: Bookingpax){
            Booking_Passenger__c pax = (Booking_Passenger__c) sobj;
            BookId.add(pax.booking__c);
        }

        //Get extra fields from the Booking
        map<id, booking__c> BookMap = new map<id, booking__c>([select id, selling_company__c, selling_company__r.parentID, selling_company__r.name, selling_company__r.parent.name, Original_Booking_Date__c, Hotel__c from Booking__c where id in :BookId]);

        //get the Booking Passenger information
        for(sobject sobj: Bookingpax){
            Booking_Passenger__c pax = (Booking_Passenger__c) sobj;
            Booking_Passenger__c oldPax = (Booking_Passenger__c) oldMap.get(pax.id);

            pax.Business_Unit_Lookup__c = BookMap.get(pax.booking__c).selling_company__c;
            pax.Brand__c = BookMap.get(pax.booking__c).selling_company__r.parentID;
            pax.Original_Booking_Date__c = BookMap.get(pax.booking__c).Original_Booking_Date__c;
            pax.Hotel__c = BookMap.get(pax.booking__c).Hotel__c;

            //Build the Preferences
            if(pax.Customer__c != null && pax.Business_Unit_Lookup__c != null && (oldPax.Customer__c == null || pax.Create_MC__c || pax.Marketing_Consent__c == null)){
                Marketing_Consent__c thisPref = new Marketing_Consent__c();
                thisPref.Booking_Passenger__c = pax.id;
                thisPref.Customer_or_Prospect__c = pax.Customer__c;
                thisPref.Date_Entered__c = date.newinstance(pax.Original_Booking_Date__c.year(), pax.Original_Booking_Date__c.month(), pax.Original_Booking_Date__c.day());
                thisPref.Selling_Company__c = pax.Business_Unit_Lookup__c;
                thisPref.Brand__c = pax.Brand__c;
                thisPref.Brand_Text__c = BookMap.get(pax.booking__c).selling_company__r.parent.name;
                thisPref.Business_Unit_Text__c = BookMap.get(pax.booking__c).selling_company__r.name;

                thisPref.Hotel__c = pax.Hotel__c;
                thisPref.Opt_In__c = true;
                thisPref.Assumed_Opt_in__c = true;

                if(pax.recordTypeID == PaxRTs.get('Guest')){
                    if(pax.Hotel__c != null){
                        thisPref.Type__c = 'Hotel Guest';
                        thisPref.Source__c = 'Reservation';
                        pax.Marketing_Consent_External_ID__c = thisPref.Hotel__c + '#' + thisPref.Customer_or_Prospect__c;
                        thisPref.External_ID__c = pax.Marketing_Consent_External_ID__c;    
                    }
                    else{
                        continue;
                    }
                }
                else{
                    thisPref.Type__c = 'Global';
                    thisPref.Source__c = 'Booking';
                    pax.Marketing_Consent_External_ID__c = thisPref.Selling_Company__c + '#' + thisPref.Customer_or_Prospect__c;
                    thisPref.External_ID__c = pax.Marketing_Consent_External_ID__c;
                }
                PrefClass.addPreference(thisPref, pax.id);
                
            }
            pax.Create_MC__c = false;
        }

        //Create the MC
        map<string, id> SourceToID = PrefClass.createPreferences();

        //Link back to MC
        if(SourceToID.size() > 0){
            for(Sobject sobj: Bookingpax){
                Booking_Passenger__c pax = (Booking_Passenger__c) sobj;
                if(pax.Marketing_Consent_External_ID__c != null){
                    ID MCID = SourceToID.get(pax.Marketing_Consent_External_ID__c);
                    if(MCID != null){
                        pax.Marketing_Consent__c = MCID;
                    }
                }
            }
        } 

    }   
}