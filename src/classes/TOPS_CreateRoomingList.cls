/******************************************************************************************************
//(c) 2017 Appirio, Inc.
//
//
//Date          Updated By          Task No.    Description
//Jan 29, 2017  Anuj Khanna         T-568724    Batch Class for TII record, Rooming List / Itinerary List
//Feb 8, 2017   Anuj Khanna         T-576821    Additional Set of requirements
//Feb 9, 2017   Anuj Khanna         I-259070    Tour Instance Process Status Update
//Feb 28, 2017  Anuj Khanna         I-262129    Per Itinerary Record a Day, Additional Module Fields in JSON
//Mar 2, 2017   Anuj Khanna         T-568300    Adding Module Empty Error scenario
//Mar 10, 2017  Anuj Khanna         T-583853    Correcting Change Over Day (Last Day Itinerary)
//May 12, 2017  Richard Boyd        T-602053    Fix for Class tour with multiple modules per class
//May 16, 2017  Richard Boyd        T-602778    Prevent split value being true on non-modular tours
//May 18, 2017  Richard Boyd        T-603012    Null reference error fixed when multiple tours being processed
//May 29, 2017  Richard Boyd        T-606644    Fix for where tour has class and change over
//May 31, 2017  Richard Boyd        I-276498    Prevent extra Itinerary records from being created and mark potential issues
//June 1, 2017  Richard Boyd        I-273927    Add City__c to query
//Oct 09, 2017  Anuj Khanna         Issues      HasSplit Error
*******************************************************************************************************/
global class TOPS_CreateRoomingList implements Database.Batchable<sObject>, Database.Stateful {
    
    List<Tour_Instance_Itinerary__c> newRoomListItinerary = new List<Tour_Instance_Itinerary__c>();
    map<Id, Tour_Instance__c> tiToBeUpdated = new map<Id, Tour_Instance__c>();
    set<string> tiIssues = new set<string>(); //TI's with potiential issues
    map<String, Boolean> mapOpCodeToSplit = new map<String, Boolean>(); 
    map<String, List<ItineraryTourSummary>> mapOpCodeTourSum = new map<String, List<ItineraryTourSummary>>();
    map<String, set<String>> mapOpCodeModSet = new map<String, set<String>>();
    List<String> compType = new List<String>{'Hotel', 'Train', 'Ferry/Cruise'};
    List<String> compTypeAll = new List<String>{'Hotel', 'Train', 'Ferry/Cruise', 'Itinerary'};
    String tiProcessStatus = 'Unprocessed';
    String compTypeRoomList = 'RoomingList';
    String compTypeItinerary = 'Itinerary';
    String nodeTourSum = 'tourSummary';
    String nodeDailySum = 'dailySummary';
    String nodeModules = 'modules';
    String nodeTourType = 'tourType';
    String DAY_BEFORE = 'Day Before';
    String CHANGE_DAY = 'Change Over Day';
    String DR_BEFORE_SPLIT = 'Day before Split';
    String DR_OF_SPLIT = 'Day of Split';
    String DR_BEFORE_MERGE = 'Day before Merge';
    String DR_OF_MERGE = 'Day of Merge';
    Id individualTourId;
    
    set<Id> setTourInstance = new set<Id>();
    
    // Class Wrapper for Rooming List
    global class RoomingList{ 
        global String name {get; set;}
        global RoomingList(String moduleName){
            name = moduleName;
        }
    } 
    
    
    global class JSONWrapper{
        global String tiiJSONData {get; set;}
        global String tiiChangeModule {get; set;}
        global String tiiDRSplit {get; set;}
        global String tiiRemainingHotel {get; set;}
        global JSONWrapper(String tdata , String chMod, String drSplit, String tiiHotel){
            tiiJSONData = tdata;
            tiiChangeModule = chMod; 
            tiiDRSplit = drSplit;
            tiiRemainingHotel = tiiHotel;
        }
    }
    
    // Class Wrapper for Itinerary List for Tour Type - Ref. T-576821
    global class ItineraryTourType{
        global String hasAccommodationClass {get; set;}
        global String hasSplit {get; set;}
        global String isModular {get; set;}
        global ItineraryTourType(String accClass , String isSplit , String isModule){
            hasAccommodationClass = accClass;
            hasSplit = isSplit;
            isModular = isModule;
        }
    }
    
    // Class Wrapper for Itinerary List for Tour Summary Data
    global class ItineraryTourSummary{ 
        global String name {get; set;}
        global String mcode {get; set;}
        global String startDate {get; set;}
        global String endDate {get; set;}
        global Boolean welcomeEmailSent {get; set;}
        global Boolean farewellEmailSent {get; set;}
        global String supplierPurpose {get; set;}
        global String startLocation {get; set;}
        global String endLocation {get; set;}
        global List<Integer> days {get; set;}
        global String startDay {get; set;}
        global String endDay {get; set;}
        
        global ItineraryTourSummary(String modCode, String modName, String modSD, String modED, Boolean wEmail,
                         Boolean fEmail, String suppPurp, String stLoc, String edLoc, List<Integer> dys, 
                         String stDay, String edDay){
            name = modName;
            mcode = modCode;
            startDate = modSD;
            endDate = modED;
            welcomeEmailSent = wEmail ;
            farewellEmailSent = fEmail;
            supplierPurpose = suppPurp;
            startLocation = stLoc;
            endLocation = edLoc;
            days  = dys;
            startDay = stDay;
            endDay = edDay;
        }
    }
    
    // Class Wrapper for Itinerary List for Daily Summary Data
    global class ItineraryDailySummary{ 
        global String name {get; set;}
        global String startDate {get; set;}
        global String endDate {get; set;}
        global ItineraryDailySummary(String modName , String modSD , String modED){
            name = modName;
            startDate = modSD;
            endDate = modED;
        }
    }  
    
    // Code changes done by Ravi Jain for story S-548465
    // Start - Ravi Jain - S-548465 - 10th April, 2018 - To get the date after 45 days from today
    Date processingDate = Date.today();
    // End- Ravi Jain - S-548465 - 10th April, 2018
    
    global String query = 'SELECT Tour_Instance__c, Tour_Code_txt__c, TII_Data__c, Start_Date_of_Service__c, Service_Start_Date__c, ' 
                    + 'Module_Start_Location__c, Module_Start_Day__c, Module_Start_Date__c, Is_Modular_Tour__c, Journey_Leg_Name__c, '
                    + 'Module_End_Day__c, Module_End_Date__c, Module_Name__c, Module_Code__c, Module_Code_Change_Date__c, '
                    + 'Duration__c, Day_Number__c, DR_Split__c, DR_Last_Changed_Date__c, DR_Change_Of_MOD__c, Tour_Instance__r.Duration__c, '
                    + 'Component_Type__c, Module_End_Location__c, IsDeleted , Supplier__c , Supplier__r.Name, '
                    + 'Operating_Product_Code__c, Tour_Instance__r.Name, Tour_Instance__r.Start_Date__c , Tour_Instance__r.End_Date__c, '
                    + 'Welcome_Email_Send_Date__c, Farewell_Email_Send_Date__c, Supply_Purpose__c, Location__c, City__c '
                    //+ 'Arrival_Time__c, Depart_Time__c, Breakfast_time__c, Morning_Call_Time__c, Dinner_Time__c, Bags_Time__c '
                    + 'FROM Tour_Instance_Itinerary__c '
                    + 'WHERE Component_Type__c IN : compTypeAll '
                    
                    // Code changes done by Ravi Jain for story S-548465
                    // Start - Ravi Jain - S-548465 - 10th April, 2018 - Check for 45 days
                    //+ 'AND Tour_Instance__r.Start_Date__c =:processingDate '
                    + 'AND (Tour_Instance__r.Start_Date__c = NEXT_N_DAYS:44 OR Tour_Instance__r.Start_Date__c = :processingDate) '
                    // End- Ravi Jain - S-548465 - 10th April, 2018
                    + 'AND Archive__c = false '
                    + 'AND Tour_Instance__r.Allocated_TD__c != null '
                    + 'AND Duration__c > 0 '
                    + 'AND Tour_Instance__r.Process_Status__c = \'' + tiProcessStatus + '\' ' 
                    + 'ORDER BY Operating_Product_Code__c, Module_Code__c, Day_Number__c';
    
    
    //Method to Run Query
    //@param1  : Standard Param for Batch Class
    //@return  : DataQuery Result  
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(individualTourId != null){
            query = 'SELECT Tour_Instance__c, Tour_Code_txt__c, TII_Data__c, Start_Date_of_Service__c, Service_Start_Date__c, ' 
                    + 'Module_Start_Location__c, Module_Start_Day__c, Module_Start_Date__c, Is_Modular_Tour__c, Journey_Leg_Name__c, '
                    + 'Module_End_Day__c, Module_End_Date__c, Module_Name__c, Module_Code__c, Module_Code_Change_Date__c, '
                    + 'Duration__c, Day_Number__c, DR_Split__c, DR_Last_Changed_Date__c, DR_Change_Of_MOD__c, Tour_Instance__r.Duration__c, '
                    + 'Component_Type__c, Module_End_Location__c, IsDeleted , Supplier__c , Supplier__r.Name, '
                    + 'Operating_Product_Code__c, Tour_Instance__r.Name, Tour_Instance__r.Start_Date__c , Tour_Instance__r.End_Date__c, '
                    + 'Welcome_Email_Send_Date__c, Farewell_Email_Send_Date__c, Supply_Purpose__c, Location__c, City__c '
                    //+ 'Arrival_Time__c, Depart_Time__c, Breakfast_time__c, Morning_Call_Time__c, Dinner_Time__c, Bags_Time__c '
                    + 'FROM Tour_Instance_Itinerary__c '
                    + 'WHERE Component_Type__c IN : compTypeAll '
                    + 'AND Duration__c > 0 '
                    + 'AND Archive__c = false '
                    + 'AND Tour_Instance__c = \'' + individualTourId + '\' '
                    + 'AND Tour_Instance__r.Process_Status__c = \'' + tiProcessStatus + '\' ' 
                    + 'ORDER BY Operating_Product_Code__c, Module_Code__c, Day_Number__c';
        }
        system.debug('Query Check : ' + query);
        return Database.getQueryLocator(query);
    }
    
    
    //Method to Run Batch for Specific Tour Instance
    //@Param1  : Tour Instance Id
    public TOPS_CreateRoomingList(Id indTourId){
        individualTourId = indTourId;    
    }
    
    //Default Constructor
    public TOPS_CreateRoomingList(){    
    }
    
    //Method to Execute Logic for Batch Class
    //@param1  : Standard Param for Batch Class
    //@param2  : List for Results for Tour Instance Itinerary Records List
    //@return  : Null
    global void execute(Database.BatchableContext BC, List<Tour_Instance_Itinerary__c> tIIList){   
        
        
        //  LOGIC to Create a MAP for OpCode Versus TII records associated
        map<String,List<Tour_Instance_Itinerary__c>> mapOpCodeTempList = 
                               new map<String,List<Tour_Instance_Itinerary__c>>();
        
        map<String,List<Tour_Instance_Itinerary__c>> mapOpCodeTIIList = 
                               new map<String,List<Tour_Instance_Itinerary__c>>();
                               
        map<String, Id> mapOpCodeTIError = new Map<String, Id>(); 
        for(Tour_Instance_Itinerary__c tII : tIIList){
            if(mapOpCodeTempList.get(tII.Operating_Product_Code__c) == null){
                mapOpCodeTempList.put(tII.Operating_Product_Code__c , new List<Tour_Instance_Itinerary__c>());
            }
            mapOpCodeTempList.get(tII.Operating_Product_Code__c).add(tII);
            
            if(!isValidTII(tII)){
                mapOpCodeTIError.put(tII.Operating_Product_Code__c , tII.Tour_Instance__c);
            }
        
        }
        
        
        // Error Conditional for Empty Module Details (T-568300) 
        for(String opCode : mapOpCodeTempList.keySet()){
            if(!mapOpCodeTIError.keySet().Contains(opCode)){
                for(Tour_Instance_Itinerary__c tII : mapOpCodeTempList.get(opCode)){
                    if(mapOpCodeTIIList.get(tII.Operating_Product_Code__c) == null){
                        mapOpCodeTIIList.put(tII.Operating_Product_Code__c , new List<Tour_Instance_Itinerary__c>());
                    }
                    /*system.debug('@@@ Add to mapOpCodeTIIList. OpCode: ' + tII.Operating_Product_Code__c 
                                 + ' Day ' + tii.Day_Number__c
                                + 'Duration ' + tii.Duration__c);*/
                    mapOpCodeTIIList.get(tII.Operating_Product_Code__c).add(tII);
                }
            }
        } 
        
        //  LOGIC to Create a MAP for Combination fo OpCode-DayNumber-Duration Versus TII records associated
        
        map<String,List<Tour_Instance_Itinerary__c>> mapDaysToTiiList = 
                                new Map<String,List<Tour_Instance_Itinerary__c>>();
        map<String,List<Tour_Instance_Itinerary__c>> mapDaysToOA = 
                                new Map<String,List<Tour_Instance_Itinerary__c>>();
        map<String,List<String>> mapDaysToSuppPurp = 
                                new Map<String,List<String>>(); 
        map<String, map<String,Set<String>>> mapOpCodeToSuppliers = 
                                new  map<String, map<String,Set<String>>>();
        
        
                        
        for(String opCode : mapOpCodeTIIList.keySet()){
            map<String , set<String>> mapDayToSupplier = new map<String , set<String>>();
            Boolean isSplit = false;
            //system.debug('@@@@ mapOpCodeTIIList current opcode is ' + opCode );
            for(Tour_Instance_Itinerary__c tIIrec : mapOpCodeTIIList.get(opCode)){
                /*system.debug('@@@ Day selected for OpCode ' + opCode 
                             + ' is ' + tIIrec.Day_Number__c 
                             + ' mod is ' + tIIrec.Module_Code__c 
                             + ' mod start date is ' + tIIrec.Module_Start_Date__c 
                             + ' start day ' + tIIrec.Day_Number__c );*/
                Integer dayNumber = Integer.valueOf(tIIrec.Day_Number__c);
                Integer durationNumber = Integer.valueOf(tIIrec.Duration__c);
                string opCodeDaysDuration = opCode + '_' + dayNumber + '_' + durationNumber 
                                            + '_' + tIIrec.Supplier__r.Name;
                
                
                
                // AK - Starts - I-263448
                
                List<Integer> daysLst = new List<Integer>();
                Integer startDay = Integer.valueOf(tIIrec.Module_Start_Day__c);
                Integer orgEndDay = Integer.valueOf(tIIrec.Module_End_Day__c); 
                //Integer diff = Integer.valueOf(tIIrec.Module_Start_Date__c.daysBetween(tIIrec.Module_End_Date__c));
                //Integer endDay; 
                //if(orgEndDay != (startDay + diff)){
                //  endDay = startDay + diff - 1;
                //}
                //System.debug('@@@ Module Duration: ' + tIIrec.Module_Code__c 
                //             + ' starts day : ' + startDay
                //            + ' Ends ' + orgEndDay);
                for(Integer iday = startDay ; iday <= orgEndDay ; iday++){
                  daysLst.add(iday);
                }
                //system.debug('@@@ Built day list ' + daysLst + ' for module ' + tIIrec.Module_Code__c);
                Boolean b_welMail = tIIrec.Welcome_Email_Send_Date__c != null? true : false;
                Boolean b_farMail = tIIrec.Farewell_Email_Send_Date__c != null? true : false;
                ItineraryTourSummary iTS = new ItineraryTourSummary(tIIrec.Module_Code__c ,tIIrec.Module_name__c, String.valueOf(tIIrec.Module_Start_Date__c) ,
                                        String.valueOf(tIIrec.Module_End_Date__c) , b_welMail , b_farMail , 
                                        (tIIrec.Supply_Purpose__c != null ? tIIrec.Supply_Purpose__c : 'No Class'),
                                        tIIrec.Module_Start_Location__c , tIIrec.Module_End_Location__c, daysLst,
                                        String.valueOf(Integer.valueOf(startDay)),
                                        String.valueOf(Integer.valueOf(orgEndDay)));
                
                if(mapOpCodeModSet.get(opCode) == null){
                    mapOpCodeModSet.put(opCode , new set<String>());
                    mapOpCodeTourSum.put(opCode, new List<ItineraryTourSummary>());
                }
                if(!mapOpCodeModSet.get(opCode).contains(tIIrec.Module_Code__c)){
                    mapOpCodeModSet.get(opCode).add(tIIrec.Module_Code__c);
                    mapOpCodeTourSum.get(opCode).add(iTS);
                }
                
                
                // AK -- Ends - I-263448
                
                
                // AK - Starts - I-262129
                String opCodeDayOA; 
                String opCodeDayOASupp;
                for(Integer ct = 0 ; ct < durationNumber ; ct++){
                    opCodeDayOA =  opCode + '_' + (dayNumber + ct);
                    if(mapDaysToOA.get(opCodeDayOA) == null){
                        mapDaysToOA.put(opCodeDayOA , new List<Tour_Instance_Itinerary__c>());
                    }
                    mapDaysToOA.get(opCodeDayOA).add(tIIrec);
                    
                    opCodeDayOASupp = opCode + '_' + (dayNumber + ct) + '_' + tIIrec.Supplier__r.Name;
                    if(mapDaysToTiiList.get(opCodeDayOASupp) == null){
                        mapDaysToTiiList.put(opCodeDayOASupp , new List<Tour_Instance_Itinerary__c>());
                    }
                    mapDaysToTiiList.get(opCodeDayOASupp).add(tIIrec);
                    
                    if(mapDaysToSuppPurp.get(opCodeDayOASupp) == null){
                        mapDaysToSuppPurp.put(opCodeDayOASupp , new List<String>{tIIrec.Supply_Purpose__c});
                    }else{
                        if(!String.IsBlank(tIIrec.Supply_Purpose__c)){
                            mapDaysToSuppPurp.get(opCodeDayOASupp).add(tIIrec.Supply_Purpose__c);
                        }
                    }
                    
                // AK - Ends - I-262129
                
                    String dayStr = String.valueOf(Integer.valueOf(tIIrec.Day_Number__c));
                    if(mapDayToSupplier.get(opCodeDayOA) == null){
                        mapDayToSupplier.put(opCodeDayOA , new set<String>());
                    }
                    mapDayToSupplier.get(opCodeDayOA).add(tIIrec.Supplier__r.Name);
                    if(mapDayToSupplier.get(opCodeDayOA).size() > 1 && tIIrec.Is_Modular_Tour__c == true){
                        isSplit = true;
                    }
                }
                
            }
           
            mapOpCodeToSplit.put(opCode , isSplit);
        }

        
        
        for(String opCode : mapOpCodeTIIList.keySet()){
            map<String , set<String>> mapDayToSupplier = new map<String , set<String>>();
            for(Tour_Instance_Itinerary__c tIIrec : mapOpCodeTIIList.get(opCode)){
                Integer day = Integer.valueOf(tIIrec.Day_Number__c);
                Integer dur = Integer.valueOf(tIIrec.Duration__c);
                for(Integer durCounter = 0 ; durCounter < dur ; durCounter++){
                    String dayStr = String.valueOf(day + durCounter);
                    if(mapDayToSupplier.get(dayStr) == null){
                        mapDayToSupplier.put(dayStr , new set<String>());
                    }
                    mapDayToSupplier.get(dayStr).add(tIIrec.Supplier__r.Name);
                }
            }
            mapOpCodeToSuppliers.put(opCode , mapDayToSupplier);
        }   
        
        
        // Create the Rooming List
        createRoomingList(mapDaysToTiiList ,mapDaysToSuppPurp , mapOpCodeToSuppliers ,  compTypeRoomList);
        
        List<Tour_Instance_Itinerary__c> processedRoomingList = processFieldValues(newRoomListItinerary);
        newRoomListItinerary.clear();
        newRoomListItinerary.addAll(processedRoomingList);
        
        // Create the Itinerary List 
          //createRooming_ItineraryList(mapDaysToOA ,mapDaysToSuppPurp , mapOpCodeToSuppliers ,  compTypeItinerary);
        createItineraryList(mapDaysToOA, compTypeItinerary); // AK - Starts - I-262129
         
        
        // Insert the records for Rooming & Itinerary List
        integer tiiResIndex = 0; 
        List<Database.SaveResult> tiiSaveRes = Database.insert(newRoomListItinerary , false); 
        for (Database.SaveResult sr : tiiSaveRes) {
                Tour_Instance__c tourIns = new Tour_Instance__c(Id = newRoomListItinerary[tiiResIndex].Tour_Instance__c);
                if (sr.isSuccess()) {
                   // Operation was successful, so get the ID of the record that was processed
                    if(!tiIssues.contains(tourIns.id)){
                        tourIns.Process_Status__c = 'Process Completed';
                    }else{
                        tourIns.Process_Status__c = 'Process Completed with Issues';
                    }
                   //System.debug('Successfully inserted record. Record ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error while inserting record - ' + newRoomListItinerary[tiiResIndex].Id + ' - ' +err.getMessage());
                        tourIns.Process_Status__c = 'Process Failed';
                        break; 
                    }
                }
                tiToBeUpdated.put(tourIns.id, tourIns);
                tiiResIndex++;
        } 
        
        //Update Error Based Tour Instance as Process Failed for Empty Module Details.
        for(String opCode : mapOpCodeTIError.keySet()){
            Tour_Instance__c tourIns = new Tour_Instance__c(Id = mapOpCodeTIError.get(opCode));
            tourIns.Process_Status__c = 'Process Failed';
            tiToBeUpdated.put(tourIns.id, tourIns);
        }
        
        // Update the Parent Tour Instance Records, Based on the Process Status.
        if(tiToBeUpdated.size() > 0){
            update tiToBeUpdated.values(); 
        }
    
    }     
    
    //Method to Check TII has Valid data or Not
    //@param1 : TII Record
    //@return : Boolean result of success = True & Failure = False
    private Boolean isValidTII(Tour_Instance_Itinerary__c tIIRec){
        Boolean retValid = true;
        if(tIIRec.Module_Start_Date__c == null || tIIRec.Module_End_Date__c == null ||
           tIIRec.Module_Start_Location__c == null || tIIRec.Module_Code__c == null ||
           tIIRec.Module_End_Location__c == null){
            retValid = false;
        }
        return retValid;
    }
    
    
    //Method to Create Rooming List for TII Records
    //@param1  : Map for TII records with Key Combination Of OpCode-Days-Duration (List of new records)
    //@param2  : String having Component Type to create RoomingList
    //@return null   
    private void createRoomingList(Map<String,List<Tour_Instance_Itinerary__c>> mapDayToTII , 
                    map<String, List<String>> mapSuppPurp , map<String, map<String,Set<String>>> mapOpCodeToSuppy, 
                         String compType){
        String opCodeValue;
        set<String> opCodeSet = new set<String>();
        Boolean isSplitDone;
        for(String opCodeDD : mapDayToTII.keySet()){
            opCodeValue = String.valueOf(opCodeDD.split('_')[0]);
            if(opCodeSet.contains(opCodeValue)){
                
            }else{
                opCodeSet.add(opCodeValue);
                isSplitDone = false;
            }
            
            for(Tour_Instance_Itinerary__c tIIrec : mapDayToTII.get(opCodeDD)){
                
                List<String> lstAccClass = mapSuppPurp.get(opCodeDD);
                Integer accClasses = lstAccClass.size();
                Integer day = Integer.valueOf(opCodeDD.split('_')[1]);
                
                // Logic to Run the Creation of TII Records for Number Of Duration Times
                // This performed per class of accommodation
                //while(durCounter < dur){
                Integer accClassCtr = 0;
                    do{
                        String tiiData ;
                        Tour_Instance_Itinerary__c newTII = tIIrec.clone(false,false,false,false);
                        newTII.Tour_Instance__c = tIIrec.Tour_Instance__c;
                        setTourInstance.add(tIIrec.Tour_Instance__c); 
                        newTII.Duration__c = 1;
                        newTII.DR_Change_Of_MOD__c = null;
                        newTII.Day_Number__c = day ;
                        newTII.Service_Start_Date__c = tIIrec.Tour_Instance__r.Start_Date__c.addDays(day - 1);
                        //if there are no accom class return null or get the class value e.g. "first class"
                        newTII.Supply_Purpose__c = accClasses == 0 ? null : lstAccClass[accClassCtr];
                        
                        //durCounter++;
                        Integer currDayNo = day; 
                        
                        // Rooming List JSON Data Creations
                        // compTypeRoomList  e.g. Hotel, Ferry/Cruise
                        if(compType.equals(compTypeRoomList)){
                            newTII.Component_Type__c = compTypeRoomList;
                            //Pass in Supplier on a given day, start date of service, the class, Supplier on given day,
                            //CurrentDay, isSplitDone boolean
                            JSONWrapper jsonWrap = createRoomJSON(mapDayToTII.get(opCodeDD) , newTII.Service_Start_Date__c ,
                                                     lstAccClass[accClassCtr] , mapOpCodeToSuppy ,currDayNo , isSplitDone);
                            newTII.TII_Data__c = jsonWrap.tiiJSONData;
                            newTII.DR_Change_Of_MOD__c = jsonWrap.tiiChangeModule;                  
                            newTII.DR_Split__c = jsonWrap.tiiDRSplit;
                            
                            if(jsonWrap.tiiDRSplit == DR_OF_SPLIT){
                                //system.debug('@@@ is Split done value: ' + isSplitDone);
                                isSplitDone = true;
                            }
                        }
                        
                        // Records being Added into a Single List for TII records Creation.
                        //system.debug('@@@@ Does propose new RL have Supply Purpose? Value is: '+ newTII.Supply_Purpose__c 
                        //             + ' opcode ' + newTII.Operating_Product_Code__c );
                        //T-602053 - fix for Class tour with multiple modules per class
                        boolean isPurposePresent = false;
                        //I-274650 fix check existing list and only check supply purpose of same op code
                        if(String.IsNotBlank(newTII.Supply_Purpose__c ) && newTII.Duration__c >0 ){
                            for(Tour_Instance_Itinerary__c ctii: newRoomListItinerary){
                                //is the same op code?
                                if(ctii.Operating_Product_Code__c == newTII.Operating_Product_Code__c){
                                    //see if the TII has already been created
                                    //system.debug('@@@@ Supply Purpose has a value ' + ctii.Supply_Purpose__c + ' for opcode ' + ctii.Operating_Product_Code__c);
                                    if(ctii.Supply_Purpose__c == newTII.Supply_Purpose__c 
                                       && ctii.Day_Number__c == newTII.Day_Number__c
                                       && ctii.Duration__c > 0){
                                           isPurposePresent = true;
                                           //system.debug('@@@@ There is already an RL for day ' + ctii.Day_Number__c +' for class ' + newTII.Supply_Purpose__c); 
                                    }else{
                                        //system.debug('@@@@ There is no RL for day ' + ctii.Day_Number__c  + ' class ' +newTII.Supply_Purpose__c  ); 
                                        isPurposePresent = false;
                                    }
                                }
                                
                            }
                        }
                        //if RL for class not present add it
                        if(isPurposePresent == false){
                            newRoomListItinerary.add(newTII);
                             system.debug('@@@@ New Record add. OpCode '
                                          + newTII.Operating_Product_Code__c + ' supplier '
                                          + newTII.Supplier__c + ' supply purpose '
                                          + newTII.Supply_Purpose__c + ' Day ' + newTII.Day_Number__c );
                        }
                        
                        accClassCtr++;
                    }while(accClassCtr < accClasses);
                    
                
                // Not overruning the logic in FOR-LOOP 
                // Fetch data from Single record in List(Rest all are same expect Module Code & Info)
                break;
            }
        } 
    }
    
    
     // AK - Starts - I-262129
    //Method to Create Itinerary List for TII Records
    //@param1  : Map for TII records with Key Combination Of OpCode-Days (List of new records)
    //@param2  : String having Component Type to create ItineraryList
    //@return null 
     private void createItineraryList(Map<String,List<Tour_Instance_Itinerary__c>> mapDayToTII, String compType){
        String opCodeValue;
        //system.debug('@@@@ CreateIntinerary');
        set<String> opCodeSet = new set<String>();
        set<string> ItRec = new set<string>();
        //I-276498 create a set of Itinerary Records that already exist. Prevents duplication of Itinerary Records
        for(String opCodeDD : mapDayToTII.keySet()){
          //  system.debug('@@@@ Examine opCode ' + opCodeDD);
            for(Tour_Instance_Itinerary__c tII : mapDayToTII.get(opCodeDD)){
            //    system.debug('@@@@ Component Type ' + tII.Component_Type__c);
                if(tII.Component_Type__c == compTypeItinerary){
                    //an Itinerary record has been found
                    system.debug('@@@@ Component Type ' + compTypeItinerary  + ' already present on ' + tII.Tour_Instance__r.Name);
                    ItRec.add(opCodeDD);
                    tiIssues.add(tII.Tour_Instance__c);
                }
            }
        }
            
         for(String opCodeDD : mapDayToTII.keySet()){
            opCodeValue = String.valueOf(opCodeDD.split('_')[0]);

            for(Tour_Instance_Itinerary__c tIIrec : mapDayToTII.get(opCodeDD)){
                //I-276498 check to see if an itinerary record exits and skip if it does
                 if(ItRec.contains(opCodeDD)){
                     system.debug('@@@@ opCode ' + opCodeDD + ' has an Itinerary Record, skipping');
                     continue;
                 }
                
                Integer day = Integer.valueOf(opCodeDD.split('_')[1]);
                
                String tiiData ;
                Tour_Instance_Itinerary__c newTII = tIIrec.clone(false,false,false,false);
                newTII.Tour_Instance__c = tIIrec.Tour_Instance__c;
                setTourInstance.add(tIIrec.Tour_Instance__c); 
                newTII.Duration__c = 1;
                newTII.Day_Number__c = day;
                newTII.Service_Start_Date__c = tIIrec.Tour_Instance__r.Start_Date__c.addDays(day - 1);
                
                // Itinerary List JSON Data Creations
                if(compType.equals(compTypeItinerary)){
                    newTII.Component_Type__c = compTypeItinerary;
                    tiiData = createItineraryJSON(mapDayToTII.get(opCodeDD), day);
                    newTII.TII_Data__c = tiiData;
                }
                
                
                
                // Records being Added into a Single List for TII records Creation.
                newRoomListItinerary.add(newTII);
                ItRec.add(opCodeDD); // I-276498 add to set of TII days with an Itinerary Record
                
                
                //if((newTII.Day_Number__c + 1) == newTII.Module_End_Day__c){     AK : Commented to Check only Tour End Itinerary
                if((newTII.Day_Number__c + 1) == newTII.Tour_Instance__r.Duration__c){ 
                    Tour_Instance_Itinerary__c tiiEndItinerary = newTII.clone(false,false,false,false);
                    tiiEndItinerary.DR_Change_Of_MOD__c = CHANGE_DAY;
                    tiiEndItinerary.Service_Start_Date__c = newTII.Module_End_Date__c;
                    tiiEndItinerary.Day_Number__c = day + 1;
                    newRoomListItinerary.add(tiiEndItinerary);
                }
                
                
                // Not overruning the logic in FOR-LOOP 
                // Fetch data from Single record in List(Rest all are same expect Module Code & Info)
                break;
            }
        } 
    }
    // AK - Starts - I-262129
    
    
    //Method to Create JSON String for Rooming List
    //@param1  : List of TII records 
    //@return  : String of JSON Data
    //FORMAT ::  {"modules":[{"name":"AZLABCF04"},{"name":"AZLABCM04"},{"name":"AZLABW04"},{"name":"AZLABWF04"}]}
    
    private JSONWrapper createRoomJSON(List<Tour_Instance_Itinerary__c> tIIRecords , Date servStartDate,
                                     String accClass , map<String, map<String,Set<String>>> mapSupplierDAY,
                                      Integer dayNumber, Boolean splitDONE){
        JSONWrapper jWrap;
        JSONGenerator gen = JSON.createGenerator(true);
        String changeMod =  null;
        String dSplit = null;
        List<RoomingList> rlList = new List<RoomingList>();
        String opCode = (tIIRecords != null && tIIRecords.size() > 0) ? tIIRecords[0].Operating_Product_Code__c : null;
        
        List<ItineraryTourSummary> modInfo = mapOpCodeTourSum.get(opCode);
        for(ItineraryTourSummary iTS : modInfo){
            if(servStartDate == Date.valueOf(iTS.startDate).addDays(-1)
               || servStartDate == Date.valueOf(iTS.endDate).addDays(-1)){
                changeMod = DAY_BEFORE; 
            }
            
            if(servStartDate == Date.valueOf(iTS.startDate)
               || servStartDate == Date.valueOf(iTS.endDate)){
                changeMod = CHANGE_DAY;
            }
               
        }
        
        for(Tour_Instance_Itinerary__c tII : tIIRecords){
            /*if(tII.Module_Start_Date__c == servStartDate || tII.Module_End_Date__c == servStartDate){
                changeMod = CHANGE_DAY;
            }*/
            
            if((String.IsBlank(tII.Supply_Purpose__c) || tII.Supply_Purpose__c == accClass)){
                RoomingList rL = new RoomingList(tII.Module_Code__c);
                rlList.add(rL);
            }
        } 
        
        
        //if(mapSupplierDAY.get(opCode).get(String.valueOf(dayNumber) != null)){
        if(splitDONE == false && mapSupplierDAY.get(opCode).get(String.valueOf(dayNumber)).size() > 1){
            dSplit = DR_OF_SPLIT;
        }
        
        if(splitDONE == true && mapSupplierDAY.get(opCode).get(String.valueOf(dayNumber)).size() == 1){
            dSplit = DR_OF_MERGE;
        }
        //}
        
        gen.writeStartObject();
        gen.writeObjectField(nodeModules, rlList);
        gen.writeEndObject();
         
        jWrap = new JSONWrapper(gen.getAsString() , changeMod , dSplit, null);
                    
        return jWrap;
    }
 
    
    //Method to Create JSON String for Itinerary List
    //@param1  : List of TII records 
    //@param2  : No. of Duration for Each Record
    //@param3  : Day Number in Running
    //@return  : String of JSON Data
    // FORMAT ::  {"tourSummary": { "tourType" : { "isModular" : "Yes", "hasSplit" : "No", "hasAccommodationClass" : "No" },
    //            "modules":[{"name":"AZLABCF04","startDate":"2017-03-01","endDate":"2017-03-20",
    //           "welcomeEmailSent":false,"farewellEmailSent":false},{"code":"AZLABCM04","name":"Mod Name",startDate":"2017-03-10",
    //           "endDate":"2017-03-20","welcomeEmailSent":false,"farewellEmailSent":false}]},
    //           "dailySummary":{"modules":[{"code":"AZLABCF04","name":"Mod Name","startDate":"2017-03-01","endDate":"2017-03-20"}]} 
                   
    global String createItineraryJSON(List<Tour_Instance_Itinerary__c> tIIRecords, Integer days){
        JSONGenerator gen = JSON.createGenerator(true);
        List<ItineraryTourSummary> ITSList = new List<ItineraryTourSummary>();
        List<ItineraryDailySummary> IDSList = new List<ItineraryDailySummary>();
        
        // For Tour Type Data - Ref. T-576821
        String hasAccClass;
        String hasSplit;
        String isModule;
        String opCode;
        set<String> moduleSupplier = new set<String>();
        set<String> locationCode = new set<String>();
        for(Tour_Instance_Itinerary__c tII : tIIRecords){
            opCode = tII.Operating_Product_Code__c;
            hasAccClass = tII.Supply_Purpose__c != null ? 'Yes' : 'No'; 
            isModule = tII.Is_Modular_Tour__c == true ? 'Yes' : 'No';
            moduleSupplier.add(tII.Supplier__r.Name);
            locationCode.add(tII.Location__c);
        }
        hasSplit = (mapOpCodeToSplit.get(opCode) == true && hasAccClass == 'No') ? 'Yes' : 'No';
        ItineraryTourType iTourType = new ItineraryTourType(hasAccClass , hasSplit , isModule);
        
        // For Tour Summary Data
        ITSList.addAll(mapOpCodeTourSum.get(opCode));
        
        
        // For Daily Summary Data
        Date presentDay ;
        for(Tour_Instance_Itinerary__c tII : tIIRecords){
            presentDay = tII.Tour_Instance__r.Start_Date__c.addDays(days-1);
            if(tII.Module_Start_Date__c <= presentDay && presentDay <= tII.Module_End_Date__c){
                 ItineraryDailySummary iDS = new ItineraryDailySummary(tII.Module_Code__c , 
                             String.valueOf(tII.Module_Start_Date__c) , String.valueOf(tII.Module_End_Date__c));
                 IDSList.add(iDS);
            }
        }
        
        gen.writeStartObject();
        gen.writeFieldName(nodeTourSum);
        gen.writeStartObject();
        gen.writeFieldName(nodeTourType);
        gen.writeObject(iTourType);
        gen.writeObjectField(nodeModules, ITSList);
        gen.writeEndObject();
        gen.writeFieldName(nodeDailySum);
        gen.writeStartObject();
        gen.writeObjectField(nodeModules, IDSList);
        gen.writeEndObject();
        
            
        system.debug('1st gen'+gen);
         system.debug('2nd gen'+gen.getAsString());
        return gen.getAsString();
        
        
    }
    
    
    //Method to Update the DR_SPLIT & Change of Module in RoomingLists
    //@param1 : List of All TII roomingList
    //@return : Updated List of TII roomingList
    private List<Tour_Instance_Itinerary__c> processFieldValues(List<Tour_Instance_Itinerary__c> roomList){
        map<Id, List<Tour_Instance_Itinerary__c>> mapTIRoomList = new map<Id, List<Tour_Instance_Itinerary__c>>();
        List<Tour_Instance_Itinerary__c> updateRoomingList = new List<Tour_Instance_Itinerary__c>();
        for(Tour_Instance_Itinerary__c tii : roomList){
            if(tii.Component_Type__c == compTypeRoomList){
                if(mapTIRoomList.get(tii.Tour_Instance__c) == null){
                    mapTIRoomList.put(tii.Tour_Instance__c , new List<Tour_Instance_Itinerary__c>());
                }
                mapTIRoomList.get(tii.Tour_Instance__c).add(tii);
            }
        }
        
        map<Id, map<String, List<Tour_Instance_Itinerary__c>>> mapTIDayRoomList = 
                            new map<Id, map<String, List<Tour_Instance_Itinerary__c>>>();
        for(Id tourId : mapTIRoomList.keySet()){
            map<String, List<Tour_Instance_Itinerary__c>> mapDayToTII = 
                                    new map<String, List<Tour_Instance_Itinerary__c>>();
            for(Tour_Instance_Itinerary__c tii : mapTIRoomList.get(tourId)){
                String dayStr = String.valueOf(Integer.valueOf(tii.Day_Number__c));
                if(mapDayToTII.get(dayStr) == null){
                    mapDayToTII.put(dayStr , new List<Tour_Instance_Itinerary__c>());
                }
                mapDayToTII.get(dayStr).add(tii);
                
            }
            mapTIDayRoomList.put(tourId, mapDayToTII);
        }
        
        for(Id tourId : mapTIDayRoomList.keySet()){
            for(String day : mapTIDayRoomList.get(tourId).keySet()){
                //T-603012 need to ensure we have an array of days for the full tour. day 
                for(Tour_Instance_Itinerary__c tii : mapTIDayRoomList.get(tourId).get(day)){
                    Boolean isChange = false;
                    List<Tour_Instance_Itinerary__c> newTIIUpdate = new List<Tour_Instance_Itinerary__c>();
                    String dayStrPre;
                    Integer remTII;
                    if(tii.Day_Number__c != 1){
                        dayStrPre = String.valueOf(Integer.valueOf(day) - 1);
                       // system.debug('@@@@ dayStrPre: ' + dayStrPre 
                         //           + ' tourid: ' + tourid + ' day ' + day);
                        //T-603012 need to check the dayStrPre is a valid day on the tour
                        //in batch of tours all the modules are not getting selected - something is not
                        //getting rest on the loop esp if a module starts after day 1
                        //code below results in no rooming list being produced 
                        /*try{
                            remTII = mapTIDayRoomList.get(tourId).get(dayStrPre).size();
                        }catch (system.NullPointerException e){
                            remTII = mapTIDayRoomList.get(tourId).get(day).size();
                            dayStrPre = day;
                        }*/
                        remTII = mapTIDayRoomList.get(tourId).get(dayStrPre).size();
                        /*if(tii.DR_Change_Of_MOD__c == CHANGE_DAY){
                            for(Tour_Instance_Itinerary__c tiiPre : mapTIDayRoomList.get(tourId).get(dayStrPre)){
                                Tour_Instance_Itinerary__c tiiNew = tiiPre.Clone(false,false,false,false);
                                if(tiiNew.DR_Change_Of_MOD__c != CHANGE_DAY){
                                    tiiNew.DR_Change_Of_MOD__c = DAY_BEFORE;
                                }
                                newTIIUpdate.add(tiiNew);
                            }
                            isChange = true;
                        }*/
                        
                        if(tii.DR_Split__c == DR_OF_SPLIT){
                            if(newTIIUpdate.size() == 0){
                                for(Tour_Instance_Itinerary__c tiiPre : mapTIDayRoomList.get(tourId).get(dayStrPre)){
                                    Tour_Instance_Itinerary__c tiiNew = tiiPre.Clone(false,false,false,false);
                                    tiiNew.DR_Split__c = DR_BEFORE_SPLIT;
                                    newTIIUpdate.add(tiiNew);
                                }
                            }else{
                                for(Tour_Instance_Itinerary__c tiiPre : newTIIUpdate){
                                    tiiPre.DR_Split__c = DR_BEFORE_SPLIT;
                                }
                            }
                            isChange = true;
                        }
                        if(tii.DR_Split__c == DR_OF_MERGE){
                            if(newTIIUpdate.size() == 0){
                                for(Tour_Instance_Itinerary__c tiiPre : mapTIDayRoomList.get(tourId).get(dayStrPre)){
                                    Tour_Instance_Itinerary__c tiiNew = tiiPre.Clone(false,false,false,false);
                                    tiiNew.DR_Split__c = DR_BEFORE_MERGE;
                                    newTIIUpdate.add(tiiNew);
                                }
                            }else{
                                for(Tour_Instance_Itinerary__c tiiPre : newTIIUpdate){
                                    tiiPre.DR_Split__c = DR_BEFORE_MERGE;
                                }
                            }
                            isChange = true;
                        }
                        
                    }
                    if(isChange && newTIIUpdate.size() > 0){
                        for(Integer ctrRem = 0 ; ctrRem < remTII ; ctrRem++){
                            
                            //I-272409 fix list boundary where tour has class and split
                            if(string.isBlank(tii.Supply_Purpose__c)){
                                updateRoomingList.remove(updateRoomingList.size() - 1);
                            }
                        }
                        updateRoomingList.addAll(newTIIUpdate);
                    }
                    
                    //I-272409 Check if RL has already been created for this class on this day
                    //ignore if RL for class exists and ensure that the record with 'Day before Split' is preserved
                    boolean skipRL = false;
                    if(string.isNotBlank(tii.Supply_Purpose__c)){
                        string dayStr = String.valueOf(Integer.valueOf(day));
                        //system.debug('@@@ check if rl for class exists');
                        for(Tour_Instance_Itinerary__c tiiRLC : updateRoomingList){
                            //the extra RL has a null split value otherwise its the same
                            if(tii.Supply_Purpose__c == tiiRLC.Supply_Purpose__c
                               && String.valueOf(Integer.valueOf(tiiRLC.Day_Number__c)) == dayStr 
                               && tiiRLC.Supplier__c == tii.Supplier__c
                               && tii.DR_Change_Of_MOD__c == DAY_BEFORE
                               && string.isBlank(tii.DR_Split__c) ){ 
                                  /* system.debug('@@@ RL has been created tiiRLC Values ' + tiiRLC.Supply_Purpose__c 
                                                + ' fo Day ' + tiiRLC.Day_Number__c
                                                +' Split Type ' + tiiRLC.DR_Split__c
                                                + ' Change Type ' + tiiRLC.DR_Change_Of_MOD__c);
                                   
                                   system.debug('@@@@ remove extra RL as split is on TII '+ tii.DR_Split__c + 
                                              ' updateRoomingList split type is ' +tiiRLC.DR_Split__c );*/
                                   //ignore unneeded RL if the split is also null
                                   skipRL = true;
                                  
                               }   
                        }
                    }
                      
                    if(!skipRL){                    
                        updateRoomingList.add(tii);
                    }
                }
            }
        }
        
        return updateRoomingList;
    }
    
    /*
    //@param1 : Tour Instances
    //@return : Map of longest module code per Tour Instance
    private map<string, date> getLongestRunningModDate(Map<String,List<Tour_Instance_Itinerary__c>> mapDayToTII){
        map<string, date> maxModDate = new map<string, date>();
        
        for(string opCode : mapDayToTII.keySet()){
            list<Tour_Instance_Itinerary__c> tIIrec = mapDayToTII.get(opCode);
            //string ti = mapDayToTII.get(opCode).Tour_Instance__c;
            for(Tour_Instance_Itinerary__c tii : tIIrec){
                //only oa's
                if(compType.equals(tii.component_type__c)){
                    if(maxModDate.get(tii.Tour_Instance__c) == null){
                        date dt1 = maxModDate.get(tii.Tour_Instance__c);
                        date dt2 = tii.Module_End_Date__c;
                        if(dt2 > dt1){
                            maxModDate.put(tii.Tour_Instance__c, dt2);
                        }
                    }
                }
            }
            
        }
                
        return maxModDate;
    }*/
    
    //Method to Execute Logic After Batch Class RUN
    //@param1  : Standard Param for Batch Class
    //@return  : Null
    global void finish(Database.BatchableContext BC){
        
    }
    

}