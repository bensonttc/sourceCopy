/******************************************************************************************************
//(c) 2017 Appirio, Inc.
//
//
//Date             Updated By          Task No.    Description
//Feb 15, 2017     Anuj Khanna         T-576854    Saving the last value of key fields required by TOPS
*******************************************************************************************************/
public class TOPS_UpdatePAXAuditFields {
    
    // MAIN JSON Class for TII DATA - Itinerary Record
    class TIIData{
        TIITourSummary tourSummary{get; set;}
        TIIDailySummary dailySummary{get; set;}
    }
    
    // Daily Summary Class for TII DATA - Itinerary Record
    class TIIDailySummary{ 
        List<Module> modules {get; set;} 
    }  
    
    // Tour Summary Class for TII DATA - Itinerary Record
    class TIITourSummary{ 
        List<Module> modules {get; set;} 
        TourType tourType {get; set;}
    }
    
    // Module Class for TII DATA - Itinerary Record
    class Module{
        String name {get; set;}
        String mcode {get; set;}
        String startDate {get; set;}
        String endDate {get; set;}
        Boolean welcomeEmailSent {get; set;}
        Boolean farewellEmailSent {get; set;}
        String supplierPurpose {get; set;}
        String startLocation {get; set;}
        String endLocation {get; set;}
        List<Integer> days {get; set;}
        String startDay {get; set;}
        String endDay {get; set;}
    }
    
    // Tour Type Details Class for TII Data - Itinerary Record
    class TourType{
        String hasAccommodationClass {get; set;}
        String hasSplit {get; set;}
        String isModular {get; set;}
    }
    
    //AK : 15th Feb : T-576854 | Point#3 
    //Method to Update Passenger Module Code and Start & End Date with Status
    //@param1  : List for PAX records (List of new records)
    //@return null  
    public static void insertPAXInitalValues(list<Passenger__c> newPAXs){
        List<Passenger__c> paxToUpdate = new List<Passenger__c>();
        
        for(Passenger__c pax : newPAXs){
            if(pax.Passenger_Class__c == 'Passenger'){
            Passenger__c newPAX = new Passenger__c(Id = pax.Id);
            newPAX.Last_Module_Code__c = pax.Module_Code__c;
            newPAX.Last_PAX_Start_Date__c = pax.Start_Date__c; 
            newPAX.Last_PAX_End_Date__c = pax.End_Date__c;
            newPAX.Last_PAX_Status__c = pax.V2_Status__c;
            
            paxToUpdate.add(newPAX);
            }
        }
        
        // Updating on the Just Inserted Records
        update paxToUpdate;
    } 
    
    //RB : 8th March : T-583859 | I-263450. Update the Last Passenger Field on TI
    //AK : 15th Feb : T-576854 | Point#4
    //Method to Update Passenger Module Code and Start & End Date with Status
    //@param1  : List for PAX records (List of new records)
    //@param2 : Map of OLD PAX records
    //@return null 
    public static void updatePAXInitalValues(list<Passenger__c> newPAXs , Map<Id, Passenger__c> oldmapPAXs){
        List<Passenger__c> paxToUpdate = new List<Passenger__c>();
        boolean isUpdateLastPAXDate = false;
        id tiId;
        for(Passenger__c pax : newPAXs){
            if(pax.Passenger_Class__c == 'Passenger'){
            pax.Last_Module_Code__c = (oldmapPAXs.get(pax.Id).Module_Code__c != pax.Module_Code__c) 
                                            ? oldmapPAXs.get(pax.Id).Module_Code__c : pax.Last_Module_Code__c;
            pax.Last_PAX_Start_Date__c = (oldmapPAXs.get(pax.Id).Start_Date__c != pax.Start_Date__c) 
                                            ? oldmapPAXs.get(pax.Id).Start_Date__c  : pax.Last_PAX_Start_Date__c; 
            pax.Last_PAX_End_Date__c = (oldmapPAXs.get(pax.Id).End_Date__c != pax.End_Date__c) 
                                            ? oldmapPAXs.get(pax.Id).End_Date__c : pax.Last_PAX_End_Date__c;
            pax.Last_PAX_Status__c = (oldmapPAXs.get(pax.Id).V2_Status__c != pax.V2_Status__c) 
                                            ? oldmapPAXs.get(pax.Id).V2_Status__c : pax.Last_PAX_Status__c;
            
            //Does the Last Passenger Update field on the TI need to be updated?
            //Only key field changes require an updated date
            if(isUpdateLastPAXDate == false){
                //system.debug('@@@ isUpdateLastPAXDate is ' + isUpdateLastPAXDate);
                //system.debug('@@@ Old Start Date ' + oldmapPAXs.get(pax.Id).Start_Date__c + ' existing '+pax.Start_Date__c);
                if(oldmapPAXs.get(pax.Id).Module_Code__c != pax.Module_Code__c || 
                  oldmapPAXs.get(pax.Id).Start_Date__c != pax.Start_Date__c ||
                  oldmapPAXs.get(pax.Id).End_Date__c != pax.End_Date__c ||
                   oldmapPAXs.get(pax.Id).V2_Status__c != pax.V2_Status__c){
                       isUpdateLastPAXDate = true;
                       tiId = pax.tour_instance__c;
                       //system.debug('@@@ Key Pax Fields have changes isUpdateLastPAXDate is ' + isUpdateLastPAXDate + ' TI is ' + tiId);
                   }
            }
            
          }  
        }
        //Update the Last_Passenger_Update__c on the TI
        if(isUpdateLastPAXDate == true && tiId != null){
            list<tour_instance__c> ti = [SELECT id, Last_Passenger_Update__c 
                                        FROM Tour_Instance__c
                                        WHERE id = :tiId];
            if(ti.size() > 0){
                //system.debug('@@@ Old Last_Passenger_Update__c is ' + ti[0].Last_Passenger_Update__c);
                ti[0].Last_Passenger_Update__c = DateTime.now();
                update ti[0];
                //system.debug('@@@ New Last_Passenger_Update__c is ' + ti[0].Last_Passenger_Update__c);
            }
        }
    }
    
    //AK : 15th Feb : T-576854 | Point#5
    //Method to Update Passenger Accomodation Classes
    //@param1  : List for PAX records (List of new records)
    //@param2 : Map of OLD PAX records
    //@return null 
    public static void updatePAXAccomodationClass(list<Passenger__c> newPAXs , Map<Id, Passenger__c> oldmapPAXs){
        List<Passenger__c> paxToUpdate = new List<Passenger__c>();
        set<Id> setTI = new set<Id>();
        for(Passenger__c pax : newPAXs){
            setTI.add(pax.Tour_Instance__c);
        }
        
        map<Id, Tour_Instance_Itinerary__c> mapIdToTII = new map<Id, Tour_Instance_Itinerary__c>();
        for(Tour_Instance_Itinerary__c tii : [SELECT id, component_type__c, TII_Data__c, Tour_Instance__c
                                                FROM Tour_Instance_Itinerary__c
                                                WHERE Tour_Instance__c IN : setTI 
                                                AND component_type__c = 'Itinerary' AND Day_Number__c = 1]){
            
            mapIdToTII.put(tii.Tour_Instance__c , tii);                                         
        }
        
        
        for(Passenger__c pax : newPAXs){
            if(pax.Passenger_Class__c == 'Passenger'){
            Tour_Instance_Itinerary__c tiiRec = mapIdToTII.get(pax.Tour_Instance__c);
            if(tiiRec != null && tiiRec.TII_Data__c != null){
            //TIIData tts = (TIIData)JSON.deserializeStrict(tiiRec.TII_Data__c, TIIData.class);
            TourItinerary ti =  processItineraryJSON(tiiRec.TII_Data__c);
            //system.debug('@@@ TII Data: ' + tiiRec.TII_Data__c); 
            //system.debug('@@@ accom value: ' + ti.hasAccommodationClass);
            if(ti.hasAccommodationClass == 'Yes'){
                
                for(TourModules mod : ti.modules){
                    //system.debug('@@@@ Pax mod code: ' + pax.module_code__c + ' code from ti ' + mod.mcode );
                    //system.debug('@@@@ Supplier Code: ' + mod.supplierPurpose );
                    if(pax.module_code__c == mod.mcode){ 
                        if(!String.IsBlank(mod.supplierPurpose)){
                            pax.Last_Accommodation_Class__c = (oldmapPAXs != null && 
                                        oldmapPAXs.get(pax.Id).AccommodationClass__c != mod.supplierPurpose) ? 
                                        oldmapPAXs.get(pax.Id).AccommodationClass__c : mod.supplierPurpose;
                            pax.AccommodationClass__c = mod.supplierPurpose;
                        }else{
                            pax.Last_Accommodation_Class__c = (oldmapPAXs != null && 
                                        oldmapPAXs.get(pax.Id).AccommodationClass__c != 'No Class') ? 
                                        oldmapPAXs.get(pax.Id).AccommodationClass__c : 'No Class';
                            pax.AccommodationClass__c = 'No Class';
                            
                        }
                    }
                }
            }else{
                
                pax.Last_Accommodation_Class__c = (oldmapPAXs != null && 
                                        oldmapPAXs.get(pax.Id).AccommodationClass__c != 'No Class') ? 
                                        oldmapPAXs.get(pax.Id).AccommodationClass__c : 'No Class'; 
                pax.AccommodationClass__c = 'No Class';
            }
        }
        }
        }
    } 
    
    //T-597408 (I-271024) - use more generic form of JSON parsing to accommmodate modifications to JSON made on Mobile App
    //RB 9th May 2017
    public static TourItinerary processItineraryJSON(string jsonData){
        TourItinerary ti = new TourItinerary();
        TourModules tm = new TourModules();
        JSONParser parser = JSON.createParser(jsonData);
        
        while (parser.nextToken() != null) {
            //system.debug('@@@@ JSON Field: '+ parser.getCurrentToken() + ' Value: ' + parser.getText());
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'hasAccommodationClass')) {
                    // Get the value.
                    //system.debug('@@@@ Accom field in JSON ' + parser.getText() );
                    parser.nextToken();
                    //Does this tour have class of accommodation
                    ti.hasAccommodationClass = parser.getText();
                    //system.debug('@@@@ Accom value in JSON ' + parser.getText() );
                }
            
            if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
               (parser.getText() == 'mcode')){
                   // Get the value.
                   parser.nextToken();
                   tm.mcode = parser.getText();
               }
            if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
               (parser.getText() == 'supplierPurpose')){
                   // Get the value.
                   parser.nextToken();
                   tm.supplierPurpose = parser.getText();
               }
            ti.modules.add(tm);   
        }
          
        //system.debug(ti);
        return ti;
    }
    //T-597408 (I-271024) - use more generic form of JSON parsing to accommmodate modifications to JSON made on Mobile App
    //RB 9th May 2017 
    public class TourItinerary{
        public string hasAccommodationClass {get;set;}
        public string supplierPurpose {get;set;}
        public list<TourModules> modules =  new list<TourModules>();
    }
    public class TourModules{
        public string mcode {get;set;}
        public string supplierPurpose {get;set;}
    }
    
}