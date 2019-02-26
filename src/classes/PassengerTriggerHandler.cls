/*
    (c) 2016 Appirio, Inc.

    Created By : Manisha Gupta
    Created On : Jan 27, 2016
    Purpose : Handler class for Passenger Trigger with below functionality:
    
    Feb 15, 2017     Anuj Khanna    (T-576854) Saving the last value of key fields required by TOPS
  July 23, 2018    Lucas Isla      (C-00234088) Calculating/updating stats for passenger's related tour instances  

*/
public with sharing class PassengerTriggerHandler  extends TriggerHandler
{

    public static Boolean hasExecuted = false;

    // **************************
    // **** Constructor *********
    // **************************
    public PassengerTriggerHandler()
    {

    }


    //Changes start, Done by Maksud Ali for Story - S-436505,S-436508 and S-438218
    public override void beforeInsert(List<SObject> newObjects)
    {
        updatePassengerNationality(newObjects);
        TOPS_UpdatePAXAuditFields.updatePAXAccomodationClass(newObjects , null);
    }
    
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
         updatePassengerNationality(newObjects);
         //AK : 15th Feb : T-576854 | Point#4
         TOPS_UpdatePAXAuditFields.updatePAXInitalValues(newObjects , (Map<Id, Passenger__c>)oldMap); 
         TOPS_UpdatePAXAuditFields.updatePAXAccomodationClass(newObjects , (Map<Id, Passenger__c>)oldMap); 
    }
    
    private static void updatePassengerNationality(List<SObject> newObjects) {
        //getting nationality data clean from custom settings.
        map<string,string> nationalityCSData = new map<string,string>();
        
        for(Nationality_Data_Cleanup__c key : Nationality_Data_Cleanup__c.getAll().values()) {
            nationalityCSData.put(key.name.toLowerCase(),key.Standard_Nationality__c);
        }
        
        //getting special diet data from custom settings.
        set<string> specialDietData = new set<string>();
        
        for(string key : Special_Diet__c.getAll().Keyset()) {
            specialDietData.add(key.toLowerCase());
        }
        
        for(Passenger__c psngr : (List<Passenger__c>)newObjects)
        {
           // test of normalising capitals of nationalities 
            if(string.isNotBlank(psngr.Nationality__c)) {
                List<String> elems = psngr.Nationality__c.split(' ');
                psngr.Nationality__c = '';
                for (String x : elems)
                {
                   x = x.tolowercase();
                   psngr.Nationality__c += x.capitalize() + ' ';
                }
                 psngr.Nationality__c = psngr.Nationality__c.trim();
            }     
           // end test
           
            if(string.isNotBlank(psngr.Nationality__c) && string.isNotBlank(psngr.Nationality__c.trim()) && nationalityCSData.containsKey(psngr.Nationality__c.toLowerCase())) {
                psngr.Nationality__c = nationalityCSData.get(psngr.Nationality__c.toLowerCase()) ;
           }
           
           if(string.isNotBlank(psngr.Dietary_Requirements__c) && string.isNotBlank(psngr.Dietary_Requirements__c.trim()) && specialDietData.contains(psngr.Dietary_Requirements__c.toLowerCase())) {
              psngr.Dietary_Requirements__c = ''; 
           }
           
           //updating preferred name if it contains comma or space we will take only a word just before space or comma.
           if(string.isNotBlank(psngr.Preferred_Name__c) && string.isNotBlank(psngr.Preferred_Name__c.trim())) {
              string strPreferredName = psngr.Preferred_Name__c.split(' ')[0];
              if(strPreferredName.split(',').size() > 0) {
                  psngr.Preferred_Name__c = strPreferredName.split(',')[0]; 
              }
              else {
                  psngr.Preferred_Name__c = '';
              }
           }
        }
    }
    //Changes End for Story - S-436505,S-436508 and S-438218



    // **********************************
    // ******* After Insert *************
    // **********************************
    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap)
    {
        updateInfoOnTourInstance(newObjects, null, true); 
        TOPS_UpdatePAXAuditFields.insertPAXInitalValues(newObjects); //AK : 15th Feb : T-576854 | Point#3 
    }


    // **********************************
    // ******* After Update *************
    // **********************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap)
    {
        updateInfoOnTourInstance(newObjects, oldObjectsMap, false);
        queueUpdateParentAccount(newObjects, oldObjectsMap);
        //queueTropicsUpdate(newObjects, oldObjectsMap);
    }

    // **********************************
    // ******* After Delete *************
    // **********************************
    public override void afterDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap)
    {
        updateInfoOnTourInstance(newObjects, null, true);
    }

    // **********************************
    // ******* After UnDelete *************
    // **********************************
    public override void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap)
    {
        updateInfoOnTourInstance(objects, null, true);
    }

    /**
      * @description  This method is used to check passenger insert and update and update the relevant information on Tour Instance
      *
      * @param        List<sObject> newObjects, Map<Id, sObject> oldObjectsMap, boolean notIsUpdate
      * @return       void
    **/

    private static void updateInfoOnTourInstance(List<sObject> newObjects, Map<Id, sObject> oldObjectsMap, boolean notIsUpdate){
        List<Passenger__c> listNewP = (List<Passenger__c>)newObjects;
        Map<Id, Passenger__c> mapOldP = (Map<Id, Passenger__c>)oldObjectsMap;
        Set<Id> setTourInstanceIds = new Set<Id>();
        for(Passenger__c p : listNewP){
            // Lucas Isla - C-00234088 - 8/2/18 - Check if more fields changed (V2 Status, DOB, Previous Trips)
            if(notIsUpdate || (p.Age__c != mapOldP.get(p.Id).Age__c || 
                               p.Gender__c != mapOldP.get(p.Id).Gender__c || 
                               p.MTS_User__c != mapOldP.get(p.Id).MTS_User__c || 
                               p.Selling_company_code__c != mapOldP.get(p.Id).Selling_company_code__c || 
                               p.V2_Status__c != mapOldP.get(p.Id).V2_Status__c || 
                               p.Date_of_Birth__c  != mapOldP.get(p.Id).Date_of_Birth__c ||
                               p.Previous_Trips__c   != mapOldP.get(p.Id).Previous_Trips__c )) {
                setTourInstanceIds.add(p.Tour_Instance__c);
            }
        }
         
        if(!setTourInstanceIds.isEmpty()){
              calculateTourInstanceFieldValues(setTourInstanceIds);          
        }
    }

    /**
      * @description  This method is used to update the information on Tour Instance
      * @Params       Set<Id> tourInstanceIds
      * @return       void
    **/
    private static void calculateTourInstanceFieldValues(Set<Id> tourInstanceIds){
        
         /*List<Tour_Instance__c> listTourInstance = [Select Id,
                                                    (Select Age__c, MTS_User__c, Gender__c, Previous_Trips__c, Selling_Company_Code__c
                                                     from Passengers__r where Passenger_Class__c = 'Passenger' AND Status__c != 'CX')
                                                    from Tour_Instance__c where Id in : tourInstanceIds];*/
        
        // Code commented and changes made by Ravi Jain for Case - 00176373
        // Code changes Starts from here
        
        List<Passenger__c> passengerList = new List<Passenger__c>();//Added by Mandeep for case 00194600
        // Lucas Isla - C-00234088 - 7/23/18 - Added more Tour_Instance__c fields to query, changed to check V2 Status
        List<Tour_Instance__c> listTourInstance = [Select Id,Name,
                                                   Last_Passenger_Update__c, Age_Count__c, Average_Age__c, Number_of_Children__c, Average_Age_of_Children__c, Number_of_Men__c, Number_of_Men_with_Past_Trips__c,
                                                   Number_of_Women__c, Number_of_Women_with_Past_Trips__c, Number_MTS_Users__c, Number_Grand_European__c, Brendan__c,
                                                    (Select Age__c,Passenger_Type__c, MTS_User__c, Gender__c, Previous_Trips__c, Selling_Company_Code__c, V2_Status__c
                                                     from Passengers__r where Passenger_Class__c = 'Passenger' AND V2_Status__c = 'CF')
                                                    from Tour_Instance__c where Id in : tourInstanceIds];
        
        // Code changes end from here
              
        if(!listTourInstance.isEmpty()){
            
            System.debug(LoggingLevel.INFO, 'TOURS NOT EMPTY');

            for(Tour_Instance__c tour : listTourInstance){
                tour.Last_Passenger_Update__c = DateTime.now(); //AK : 14th Feb : T-576854 | Point#1 
                tour.Age_Count__c = 0;
                tour.Average_Age__c = 0;
                tour.Number_of_Children__c = 0;
                tour.Average_Age_of_Children__c = 0;
                tour.Number_of_Men__c = 0;
                tour.Number_of_Men_with_Past_Trips__c = 0;
                tour.Number_of_Women__c = 0;
                tour.Number_of_Women_with_Past_Trips__c = 0;
                tour.Number_MTS_Users__c = 0;
                tour.Number_Grand_European__c = 0;
                tour.Brendan__c = 0;
                Decimal totalAgeOfChildren = 0;
                
                for(Passenger__c p : tour.Passengers__r){
                    
                    if(p.Age__c != null){
                        tour.Age_Count__c += p.Age__c;
                        passengerList.add(p);//Added by Mandeep for case 00194600
                    }
                    
                    if(p.Age__c < 18){
                        // Code commented and changes made by Ravi Jain for Case - 00176373
                        //tour.Number_of_Children__c++;
                        totalAgeOfChildren += p.Age__c;
                    }
                    
                    // Code commented and changes made by Ravi Jain for Case - 00176373
                    // Code changes Starts here
                    // 
                    // Lucas Isla - C-00234088 - 7/23/18 -  Added < 18 check in below line
                    if(p.Age__c < 18 || p.Passenger_Type__c == 'CH'){
                        tour.Number_of_Children__c++;
                    }
                    // Code changes end here
                    // Passenger is only man / woman if age >= 18
                    else if(p.Gender__c == 'Male' || p.Gender__c == '' || p.Gender__c == null){
                        tour.Number_of_Men__c++;
                        if(p.Previous_Trips__c != null && p.Previous_Trips__c > 0){
                            tour.Number_of_Men_with_Past_Trips__c++;
                        }
                    }else if(p.Gender__c == 'Female'){
                        tour.Number_of_Women__c++;
                        if(p.Previous_Trips__c != null && p.Previous_Trips__c > 0){
                            tour.Number_of_Women_with_Past_Trips__c++;
                        }
                    }
                    
                    
                    if(p.MTS_User__c){
                        tour.Number_MTS_Users__c++;
                    }
                    if(p.Selling_Company_Code__c != null && p.Selling_Company_Code__c.startsWith('GE')){
                        tour.Number_Grand_European__c++;
                    }
                    
                    if(p.Selling_Company_Code__c != null && p.Selling_Company_Code__c == 'BVUSAS'){
                        tour.Brendan__c++;
                    }
                }
                
                // if(tour.Passengers__r.size() > 0) {//Commented by Mandeep for case 00194600
                if(passengerList.size()>0){//Added by Mandeep for case 00194600
                    //tour.Average_Age__c = tour.Age_Count__c/tour.Passengers__r.size();//Commented by Mandeep for case 00194600
                    tour.Average_Age__c = tour.Age_Count__c/passengerList.size();//Added by Mandeep for case 00194600
                }
                if(tour.Number_of_Children__c > 0) {
                    tour.Average_Age_of_Children__c = totalAgeOfChildren/tour.Number_of_Children__c;
                }
            }
                       
            //try{
            update listTourInstance;
            /*}catch(Exception ex){
              system.debug('Exception while updating tour info ' + ex.getMessage());
            }*/
            
        }
    }

    // method to queue an async job
    // when certain fields are updated on the passenger, these need to be replicated on the account and siblings
    private void queueUpdateParentAccount(List<sObject> newObjects, Map<Id, sObject> oldObjectsMap)
    {

        Set<Id> passengerIdsToReplicate = new Set<Id>();
        System.debug('hasExecuted ' + hasExecuted);
        System.debug('objects ' + newObjects);
        if (!hasExecuted)
        {
            for (sObject newObj : newObjects)
            {
                Passenger__c newPass = (Passenger__c)newObj;
                Passenger__c oldPass = (Passenger__c)oldObjectsMap.get(newObj.Id);
                if (dataReplicationFieldsChanged(newPass, oldPass))
                    passengerIdsToReplicate.add(newPass.Id);
            }
            if (passengerIdsToReplicate.size() > 0)
            {
                hasExecuted = true;
                Id jobId = System.enqueueJob(new PassengerToAccountReplicator(passengerIdsToReplicate));
                System.debug('jobId ' + jobId);
            }
        }
    }

    /*// enqueues a job that writes back updates to passengers to tropics
    private void queueTropicsUpdate(List<sObject> newObjects, Map<Id, sObject> oldObjectsMap)
    {
        Set<Id> passengerIdsToUpdateTropics = new Set<Id>();
        for (sObject newObj : newObjects)
        {
            Passenger__c newPass = (Passenger__c)newObj;
            Passenger__c oldPass = (Passenger__c)oldObjectsMap.get(newObj.Id);
            if (tropicsFieldsChanged(newPass, oldPass))
            {
                System.enqueueJob(new PassengerTropicsDispatcher(newPass));
            }
        }
    }*/

    // helper method to identify if any field changed on the passenger
    private static Boolean dataReplicationFieldsChanged(Passenger__c newPass, Passenger__c oldPass)
    {
        return  newPass.Address_City__c             != oldPass.Address_City__c
          ||    newPass.Address_Country__c          != oldPass.Address_Country__c
          ||    newPass.Address_Line_1__c           != oldPass.Address_Line_1__c
          ||    newPass.Address_Postcode__c         != oldPass.Address_Postcode__c
          ||    newPass.Address_Region__c           != oldPass.Address_Region__c
          ||    newPass.Date_of_Birth__c            != oldPass.Date_of_Birth__c
          ||    newPass.Email__c                    != oldPass.Email__c
          ||    newPass.Family_Name__c              != oldPass.Family_Name__c
          ||    newPass.First_Name__c               != oldPass.First_Name__c
          ||    newPass.Middle_Name__c              != oldPass.Middle_Name__c
          ||    newPass.Mobile__c                   != oldPass.Mobile__c
          ||    newPass.Gender__c                   != oldPass.Gender__c
          ||    newPass.Dietary_Requirements__c     != oldPass.Dietary_Requirements__c
          ||    newPass.City_Of_Birth__c            != oldPass.City_Of_Birth__c
          ||    newPass.Country_Of_Birth__c         != oldPass.Country_Of_Birth__c
          ||    newPass.Country_of_Issue__c         != oldPass.Country_of_Issue__c
          ||    newPass.Nationality__c              != oldPass.Nationality__c
          ||    newPass.Passport_Issue_Date__c      != oldPass.Passport_Issue_Date__c
          ||    newPass.Passport_Expiry_Date__c     != oldPass.Passport_Expiry_Date__c
          ||    newPass.Passport_number__c          != oldPass.Passport_number__c;
    }

    // if any of the following fields changed, a new job will be queued to update Tropics
    /*private static Boolean tropicsFieldsChanged(Passenger__c newPass, Passenger__c oldPass)
    {
        return  newPass.Family_Name__c                      != oldPass.Family_Name__c
          ||    newPass.Preferred_Name__c                   != oldPass.Preferred_Name__c
          ||    newPass.Mobile__c                           != oldPass.Mobile__c
          ||    newPass.Email__c                            != oldPass.Email__c
          ||    newPass.Address_Line_1__c                   != oldPass.Address_Line_1__c
          ||    newPass.Address_City__c                     != oldPass.Address_City__c
          ||    newPass.Address_Region__c                   != oldPass.Address_Region__c
          ||    newPass.Address_Postcode__c                 != oldPass.Address_Postcode__c
          ||    newPass.Address_Country__c                  != oldPass.Address_Country__c
          ||    newPass.Home_Phone_Intl_Code__c             != oldPass.Home_Phone_Intl_Code__c
          ||    newPass.Home_Phone_Area_Code__c             != oldPass.Home_Phone_Area_Code__c
          ||    newPass.Home_Phone_Base_Number__c           != oldPass.Home_Phone_Base_Number__c
          ||    newPass.Emergency_Contact_Name__c           != oldPass.Emergency_Contact_Name__c
          ||    newPass.Emergency_Contact_Relationship__c   != oldPass.Emergency_Contact_Relationship__c
          ||    newPass.Emergency_Contact_Intl__c           != oldPass.Emergency_Contact_Intl__c
          ||    newPass.Emergency_Contact_Area__c           != oldPass.Emergency_Contact_Area__c
          ||    newPass.Emergency_Contact_Base__c           != oldPass.Nationality__c
          ||    newPass.Booking_Passenger__r.Client_ID__c   != oldPass.Booking_Passenger__r.Client_ID__c
          ||    newPass.LastModifiedDate                    != oldPass.Passport_Expiry_Date__c
          ||    newPass.Booking_Number__c                   != oldPass.Booking_Number__c
          ||    newPass.Selling_company_code__c             != newPass.Selling_company_code__c;
    }*/
} // end class