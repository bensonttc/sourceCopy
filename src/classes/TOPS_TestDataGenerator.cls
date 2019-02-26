/******************************************************************************************************
//(c) 2017 Appirio, Inc.
//
//
//Date             Updated By          Task No.    Description
//Feb 9, 2017      Anuj Khanna         T-570160    Create TII Integration Simulator
//Feb 14, 2017     Anuj Khanna         T-570161    Create Additional Methods for PAX processing
//Feb 18, 2017     Anuj Khanna         T-578933    Additional fields for PAX Data
*******************************************************************************************************/
global with sharing class TOPS_TestDataGenerator implements Queueable {
    
    Account tourDirector;
    public List<String> tourInstanceIds = new List<String>{'a1e8E0000000gsu', 'a1e8E0000000auc', 'a1e8E0000000aud'};
    List<String> gender = new List<String>{'Male' , 'Female'};
    public class CSVDataWrapper{ 
        
        public String OpCode {get; set;}
        public Date StartDate {get; set;}
        public String Supplier {get; set;}
        public Tour_Instance_Itinerary__c tourII {get; set;}
        
        
        private Date getDateFormat(string dateCSV){
            List<String> dateStr = dateCSV.split('/');
            String retDate;
            if(dateStr.size() > 1){
                retDate = dateStr[2] +'-'+ dateStr[0]  +'-'+ dateStr[1];
            }else{
                retDate = dateStr[0];
            }
            
            return Date.ValueOf(retDate);
        }
        
        public CSVDataWrapper(List<String> csvData){
             
             tourII = new Tour_Instance_Itinerary__c();
             OpCode = csvData[0];
             tourII.Operating_Product_Code__c = csvData[0];
             StartDate = !String.IsBlank(csvData[1]) ? getDateFormat(csvData[1]) : null;
             tourII.Service_Start_Date__c = !String.IsBlank(csvData[1]) ? getDateFormat(csvData[1]) : null;
             tourII.Component_Type__c = csvData[2];
             tourII.Day_Number__c = !String.IsBlank(csvData[3]) ? Integer.valueOf(csvData[3]) : null;
             tourII.Duration__c = !String.IsBlank(csvData[4]) ? Integer.valueOf(csvData[4]) : null;
             Supplier = csvData[5];
             tourII.Supply_Purpose__c = csvData[6];
             tourII.Module_Code__c = csvData[7];
             tourII.Module_Start_Day__c = !String.IsBlank(csvData[8]) ? Integer.valueOf(csvData[8]) : null;
             tourII.Module_End_Day__c = !String.IsBlank(csvData[9]) ? Integer.valueOf(csvData[9]) : null;
             tourII.Module_Start_Date__c = !String.IsBlank(csvData[10]) ? getDateFormat(csvData[10]) : null;
             tourII.Module_End_Date__c = !String.IsBlank(csvData[11]) ? getDateFormat(csvData[11]) : null;
             tourII.Module_Start_Location__c = csvData[12];
             tourII.Module_End_Location__c = csvData[13];
             tourII.DR_Change_Of_MOD__c = csvData[14];
             tourII.DR_Split__c = csvData[15];
             tourII.DR_Last_Changed_Date__c = !String.IsBlank(csvData[16]) ? getDateFormat(csvData[16]) : null;
             tourII.TII_Data__c = csvData[17];
            //system.debug('@@@ Sim ' + csvData[0] + ' is modular ' + csvData[18]);
             tourII.Is_Modular_Tour__c = (!String.IsBlank(csvData[18]) && csvData[18] == 'Yes') ? true : false ;
        }
    }
    
    class Module{
        String moduleCode{get; set;}
        Date moduleStartDate {get; set;}
        Date moduleEndDate{get; set;}
        String moduleStartLoc{get; set;}
        String moduleEndLoc{get; set;}
        Module(Tour_Instance_Itinerary__c tii){
            moduleCode = tii.Module_Code__c;
            moduleStartDate = tii.Module_Start_Date__c;
            moduleEndDate = tii.Module_End_Date__c;
            moduleStartLoc = tii.Module_Start_Location__c;
            moduleEndLoc = tii.Module_End_Location__c;
        }
    }
    
       
    public TOPS_TestDataGenerator(Account tourDirector) {
        this.tourDirector = [SELECT firstName, LastName from Account where Id = :tourDirector.Id];
    }
    
    public TOPS_TestDataGenerator() {
    }
    
    
    public void execute(QueueableContext context) {
        List<Passenger__c> passengers = new List<Passenger__c>();
        List<Tour_Optional__c> optionals = new List<Tour_Optional__c>();
        List<Tour_Instance_Itinerary__c> itineraryItems = new List<Tour_Instance_Itinerary__c>();
        
        for (Tour_Instance__c ti : Database.query(buildQuery()))
        {
            Tour_Instance__c copy = ti.clone(false, true, false, true);
            copy.Trip_Status__c = null;
            copy.Allocated_TD__c = tourDirector.Id;
            copy.Instance_Code__c = null;
            copy.Chatter_Attachment_References__c = null;
            insert copy;
            for (Passenger__c p : ti.Passengers__r)
            {
                
                    Passenger__c newP = p.clone(false, true, false, true);
                    newP.Name = p.Name;
                    newP.Tour_Instance__c = copy.Id;
                    if (p.Passenger_Class__c == 'Tour Director')
                    {
                        newP.First_Name__c = tourDirector.FirstName;
                        newP.Family_Name__c = tourDirector.LastName;
                        newP.Account__c = tourDirector.Id;
                    }   
                    passengers.add(newP);
                
            }
            for (Tour_Optional__c optional : ti.Tour_Optionals__r)
            {
                Tour_Optional__c newOptional = optional.clone(false, true, false, true);
                newOptional.Name = optional.Name;
                newOptional.Tour_Instance__c = copy.Id;
                optionals.add(newOptional);
            }
            for (Tour_Instance_Itinerary__c tii : ti.Tour_Instance_Itineraries__r)
            {
                Tour_Instance_Itinerary__c newTII = tii.clone(false, true, false, true);
                newTII.Tour_Instance__c = copy.Id;
                itineraryItems.add(newTII);
            }
        }
        insert passengers;
        insert optionals;
        insert itineraryItems;
        
    }

    private String buildQuery()
    {
        Schema.DescribeSobjectResult[] describeResult = Schema.describeSObjects(new String[]{'Tour_Instance__c'});
        String query = 'Select id,';
        for (Schema.SObjectField sObjectField : describeResult[0].fields.getMap().values())
        {
            Schema.DescribeFieldResult fieldResult = sObjectField.getDescribe();
            if (!fieldResult.isDefaultedOnCreate() && fieldResult.isAccessible() && !fieldResult.isAutoNumber())
                query += fieldResult.getName() + ','; // add each field individually to the query  
        }  
        query += '(SELECT id, Name,';
        describeResult = Schema.describeSObjects(new String[]{'Passenger__c'});
        for (Schema.SObjectField sObjectField : describeResult[0].fields.getMap().values())
        {
            Schema.DescribeFieldResult fieldResult = sObjectField.getDescribe();
            if (!fieldResult.isDefaultedOnCreate() && fieldResult.isAccessible() && !fieldResult.isAutoNumber())
                query += fieldResult.getName() + ','; // add each field individually to the query  
        }  
        query=query.removeEnd(',');
        query += ' FROM Passengers__r), (SELECT id, Name,';
        describeResult = Schema.describeSObjects(new String[]{'Tour_Optional__c'});
        for (Schema.SObjectField sObjectField : describeResult[0].fields.getMap().values())
        {
            Schema.DescribeFieldResult fieldResult = sObjectField.getDescribe();
            if (!fieldResult.isDefaultedOnCreate() && fieldResult.isAccessible() && !fieldResult.isAutoNumber())
                query += fieldResult.getName() + ','; // add each field individually to the query  
        }  
        query=query.removeEnd(',');
        query += ' FROM Tour_Optionals__r), (SELECT id, Name,';
        
        describeResult = Schema.describeSObjects(new String[]{'Tour_Instance_Itinerary__c'});
        for (Schema.SObjectField sObjectField : describeResult[0].fields.getMap().values())
        {
            Schema.DescribeFieldResult fieldResult = sObjectField.getDescribe();
            if (!fieldResult.isDefaultedOnCreate() && fieldResult.isAccessible() && !fieldResult.isAutoNumber())
                query += fieldResult.getName() + ','; // add each field individually to the query  
        }  
        query=query.removeEnd(',');
        query += ' FROM Tour_Instance_Itineraries__r) FROM Tour_Instance__c WHERE Id =: tourInstanceIds';
        System.debug('query ' + query);
        return query;
    }

    public List<Tour_Instance__c> createModularTIIRecords(String tIPrefix , List<String> modules , Boolean purgeOnComplete){
        
        Map<String, List<List<String>>> listProcessedCSV = new Map<String, List<List<String>>>();
        List<ContentVersion> listCSVData = [SELECT Title, OwnerId, Id, FileType, VersionData 
                                            FROM ContentVersion 
                                            WHERE Title IN : modules
                                            AND FileType = 'CSV'
                                            AND IsLatest = true];
        for(ContentVersion cv : listCSVData){
            String fileData = cv.VersionData.toString();
            listProcessedCSV.put(cv.Title , CSVReader.readCSVFile(fileData));
        }
        
        
        Map<String, List<CSVDataWrapper>> mapModCSVRecords = new Map<String, List<CSVDataWrapper>>();
        for(String module : listProcessedCSV.keySet()){
            if(mapModCSVRecords.get(module) == null){
                mapModCSVRecords.put(module, new List<CSVDataWrapper>());
            }
            Integer ct = 0;
            for(List<String> lstCSVRow : listProcessedCSV.get(module)){
                if(ct == 0){
                    ct++;
                    continue;
                }
                mapModCSVRecords.get(module).add(new CSVDataWrapper(lstCSVRow));
                ct++;
            }   
        }
        
        map<String, set<String>> mapOpCodeSupp = new map<String, set<String>>();
        map<String, Date> mapOpCodeSD = new map<String, Date>();
        map<String, Date> mapOpCodeED = new map<String, Date>();
        for(String module : mapModCSVRecords.keySet()){
            for(CSVDataWrapper csvRow : mapModCSVRecords.get(module)){
                if(mapOpCodeSupp.get(csvRow.OpCode) == null){
                    mapOpCodeSupp.put(csvRow.OpCode , new set<String>{csvRow.Supplier});
                }else{
                    mapOpCodeSupp.get(csvRow.OpCode).add(csvRow.Supplier);
                }   
                if(mapOpCodeSD.get(csvRow.OpCode) == null){
                    mapOpCodeSD.put(csvRow.OpCode , csvRow.StartDate);
                }else{
                    if(mapOpCodeSD.get(csvRow.OpCode) > csvRow.StartDate){
                        mapOpCodeSD.put(csvRow.OpCode , csvRow.StartDate);
                    }
                }
                if(mapOpCodeED.get(csvRow.OpCode) == null){
                    mapOpCodeED.put(csvRow.OpCode , csvRow.StartDate);
                }else{
                    if(mapOpCodeED.get(csvRow.OpCode) < csvRow.StartDate){
                        mapOpCodeED.put(csvRow.OpCode , csvRow.StartDate);
                    }
                }
            }
        }
        
        
        List<Tour_Instance__c> lstTI = createNewTI(mapOpCodeSD , mapOpCodeED , tIPrefix);
        List<Account> lstSupplier = createNewSupplier(mapOpCodeSupp , tIPrefix);
        
        insert lstTI;
        insert lstSupplier;
        
        List<Tour_Instance_Itinerary__c> lstTII  = createNewTII(mapModCSVRecords , lstTI , lstSupplier);
        insert lstTII;
        //establish 'Mother Tour', the longest running module
        map<id,Tour_Instance__c> mTI = new Map<id,Tour_Instance__c>(lstTI);
        set<id> tiIds = mTI.keySet();
        AggregateResult[] arMother = [SELECT MIN(Module_Start_Date__c) motherSD, MAX(Module_End_Date__c) motherED,
                                      Tour_Instance__C FROM Tour_Instance_Itinerary__c
                                      WHERE Is_Modular_Tour__C = true AND Tour_Instance__C IN : tiIds
                                        GROUP BY Tour_Instance__C];
        
        for(AggregateResult ar : arMother){
            string tiId = string.valueOf(ar.get('Tour_Instance__C'));
            Tour_Instance__c ti = mTI.get(tiId);
            ti.start_date__c = date.valueOf(ar.get('motherSD'));
            ti.end_date__c = date.valueOf(ar.get('motherED'));
            mTI.put(tiID,ti); //update
        }
        
        update mTI.values();
        
        return lstTI;
    }
    
    public List<Tour_Instance_Itinerary__c> createNewTII(Map<String, List<CSVDataWrapper>> mapCSVRecords ,List<Tour_Instance__c> tourIns ,List<Account>  suppliers){
        map<String, Tour_Instance__c> mapTI = new map<String, Tour_Instance__c>();
        list<Tour_Instance__c> moduleTIs = new list<Tour_Instance__c>();
        Tour_Instance__c mti = new Tour_Instance__c();
        
        for(Tour_Instance__c ti : tourIns){
            mapTI.put(ti.Operating_Product_Code__c , ti);
        }
        
        map<String, Account> mapSupplier = new map<String, Account>();
        for(Account supp : Suppliers){
            mapSupplier.put(supp.name.split('_')[1] , supp);
        }
        
        List<Tour_Instance_Itinerary__c> newTII = new List<Tour_Instance_Itinerary__c>();
        for(String mod : mapCSVRecords.keySet()){
            boolean isCheckForModular = false;
            for(CSVDataWrapper csvRow : mapCSVRecords.get(mod)){
                //T-579438 create a module name
                string modName = 'Tour ' + (math.random() * 1000000).round();
                Tour_Instance_Itinerary__c tii = csvRow.tourII;
                tii.Tour_Instance__c = mapTI.get(csvRow.OpCode).Id;
                tii.Supplier__c = mapSupplier.get(csvRow.Supplier).Id;
                tii.Module_Name__c = modName;
                //Module Codes  T-585165 indicate if TI is modular
                if(tii.Is_Modular_Tour__c == true && isCheckForModular == false){
                    isCheckForModular = true; //only run once
                    mti = mapTI.get(csvRow.OpCode);
                    mti.IsModularTour__c = true; //set the overall TI as modular
                    mapTI.put(csvRow.OpCode, mti);
                }
                newTII.add(tii);
            }
        }
        moduleTIs = mapTI.values();
        update moduleTIs;
        
        return newTII;
    }
    
    public List<Tour_Instance__c> createNewTI(map<String, Date> OpCodeSD  , map<String, Date> OpCodeED , String tiPre){
        List<Tour_Instance__c> newTI = new List<Tour_Instance__c>();
        for(String opCode : OpCodeSD.keySet()){
            Tour_Instance__c tIRec = new Tour_Instance__c();
            tIRec.Operating_Product_Code__c = opCode;
            tiRec.Departure_Code__c = tiPre + '_' + opCode; 
            tiRec.Process_Status__c = 'Unprocessed';
            //tiRec.Start_Date__c = OpCodeSD.get(opCode);
            tiRec.Start_Date__c = System.today();
            tiRec.End_Date__c = OpCodeED.get(opCode);
            tIRec.ActualRoomTrigger__c = 'Complete'; //Mark Complete to prevent the TTC Actual Rooming logic from firing
            newTI.add(tiRec); 
        }
        return newTI;
    }  
    
    public List<Account> createNewSupplier(map<String, set<String>> OpCodeSupp , String tiPre){
        List<Account> newSuppliers = new List<Account>();
        String SUPP_HOTEL = 'Supplier_Hotel';
        Id hotelAccId = [SELECT Id, DeveloperName FROM RecordType Where DeveloperName = : SUPP_HOTEL][0].Id;
        set<String> uniqueSupp = new set<String>();
        for(String opCode : OpCodeSupp.keySet()){
            for(String suppName : OpCodeSupp.get(opCode)){
                uniqueSupp.add(suppName);
            }
        }
        for(String suppName : uniqueSupp){
            Account acc = new Account();
            acc.Name = tiPre + '_' + suppName;
            acc.billingStreet = (math.random() * 1000).round() + ' Any place';
            acc.billingCity = 'Gotham';
            acc.BillingPostalCode = (math.random() * 1000).round() + ' BAT';
            acc.BillingState = 'NY';
            acc.BillingCountry = 'USA';
            acc.ShippingStreet = acc.billingStreet;
            acc.ShippingCity = 'Gotham';
            acc.ShippingPostalCode = acc.BillingPostalCode + ' BAT';
            acc.ShippingState = 'NY';
            acc.ShippingCountry = 'USA';
            acc.RecordTypeId = hotelAccId;
            newSuppliers.add(acc);
        }
        return newSuppliers;
    }

    public void createRoomingLists(Boolean waitForBatch){
        Integration_Log__c logRecord = new Integration_Log__c();
        logRecord.Integration_Start_Date__c = Datetime.now();
        logRecord.Job_Status__c = 'In Progress';
        logRecord.Job_Type__c = 'TII';
        logRecord.External_Id__C = 'TII-'+datetime.now().year()+  Datetime.now().month() + DateTime.now().Day();
        insert logRecord;
        
        if(waitForBatch){
            //logRecord.Job_Status__c = 'Integration Completed';
            //logRecord.Integration_End_Date__c = Datetime.now();
            //update logRecord;
        }else{
            logRecord.Job_Status__c = 'Batch Completed';
            logRecord.Integration_End_Date__c = Datetime.now();
            update logRecord;
            
            TOPS_CreateRoomingList batch = new TOPS_CreateRoomingList();
            Id batchID = database.executeBatch(batch);
        }
    }
    
    
     webservice static void runTIRoomingProcess(String tourInstanceId){
        Integration_Log__c logRecord = new Integration_Log__c();
        logRecord.Integration_Start_Date__c = Datetime.now();
        logRecord.Job_Status__c = 'In Progress';
        logRecord.Job_Type__c = 'TII';
        logRecord.External_Id__C = 'TII-'+datetime.now().year()+  Datetime.now().month() + DateTime.now().Day();
        insert logRecord;
        
        
        logRecord.Job_Status__c = 'Batch Completed';
        logRecord.Integration_End_Date__c = Datetime.now();
        update logRecord;
        
        TOPS_CreateRoomingList batch = new TOPS_CreateRoomingList(Id.valueof(tourInstanceId));
        Id batchID = database.executeBatch(batch);
        
    }
 
    
    
    
    public void purgeModularTIIRecords(String tIPrefix){
        List<Tour_Instance__c> tiToBeDeleted = [SELECT Id FROM Tour_Instance__c
                                                WHERE Departure_Code__c LIKE: tIPrefix+'%'];
        
        Map<Id, Tour_Instance__c> recordsMap = new Map<Id, Tour_Instance__c>();
        recordsMap.putAll(tiToBeDeleted);
        Set<Id> tiIDToBeDelete = recordsMap.keySet();

        List<Passenger__c> paxToBeDeleted = [SELECT id FROM Passenger__c
                                            WHERE Tour_Instance_Id__c IN :tiIDToBeDelete ];
        
        List<Tour_Instance_Itinerary__c> tiiToBeDeleted = [SELECT Id FROM Tour_Instance_Itinerary__c
                                                            WHERE Tour_Instance__c IN : tiToBeDeleted];
        
        List<Account> suppToBeDeleted = [SELECT Id FROM Account
                                         WHERE name LIKE: tIPrefix+'%'];
                                         
        delete paxToBeDeleted;
        delete tiiToBeDeleted;
        delete tiToBeDeleted;
        delete suppToBeDeleted;
    }
    
    
    public List<Id> createNewPAX(Integer numToCreate , List<Id> tourInstanceIds , List<String> roomTypeList){
        
        //Creation of Integration Logs
        Integration_Log__c logRecord = new Integration_Log__c();
        logRecord.Integration_Start_Date__c = Datetime.now();
        logRecord.Job_Status__c = 'In Progress';
        logRecord.External_Id__C = 'PAX-' +datetime.now().year()+  Datetime.now().month() + DateTime.now().Day();
        logRecord.Job_Type__c = 'PAX';
        insert logRecord;
        
        
        List<Passenger__c> passengerToCreate = new List<Passenger__c>();
        List<Id> passIdToReturn = new List<Id>();
        List<Tour_Instance__c> tourInsList = [SELECT Id 
                                                FROM Tour_Instance__c 
                                                WHERE Id IN: tourInstanceIds];
        Map<Id, List<Module>> mapModInfo = getModuleInfo(tourInstanceIds);
        
        for(Tour_Instance__c tI : tourInsList){
            Integer paxPerTI = numToCreate;
            while(paxPerTI > 0){
            for(String roomtype : roomTypeList){
                List<Passenger__c> passList = new List<Passenger__c>(); 
                if(roomtype == 'SIG'){
                    if(paxPerTI - 1 >= 0){
                        passList = getPassenger(mapModInfo.get(tI.Id) , tI.Id, roomtype,  1);
                        paxPerTI = paxPerTI - 1;
                    }else{
                        break;
                    }
                }
                if(roomtype == 'TWN' || roomtype == 'TWS'){
                    if(paxPerTI - 2 >= 0){
                        passList = getPassenger(mapModInfo.get(tI.Id) , tI.Id, roomtype,  2);
                        paxPerTI = paxPerTI - 2;
                    }else{
                        break;
                    }
                }
                if(roomtype == 'TRP' || roomtype == 'TRS'){
                    if(paxPerTI - 3 >= 0){
                        passList = getPassenger(mapModInfo.get(tI.Id) , tI.Id, roomtype,  3);
                        paxPerTI = paxPerTI - 3;
                    }else{
                        break;
                    }
                }
                if(roomtype == 'QAD' || roomtype == 'QDS'){
                    if(paxPerTI - 4 >= 0){
                        passList = getPassenger(mapModInfo.get(tI.Id) , tI.Id, roomtype,   4);
                        paxPerTI = paxPerTI - 4;
                    }else{
                        break;
                    }   
                }
                passengerToCreate.addAll(passList);
            }
            }
        }
        insert passengerToCreate;
        
        logRecord.Job_Status__c = 'Batch Completed';
        logRecord.Integration_End_Date__c = Datetime.now();
        update logRecord;
        
        for(Passenger__c pax : passengerToCreate){
            passIdToReturn.add(pax.Id);
        }
        
        return passIdToReturn;
    }
    
    private List<Passenger__c> getPassenger(List<Module> mods , Id tIns, String roomType , Integer ct){
        List<Passenger__c> passToRet = new List<Passenger__c>();
        Integer index = Math.mod(Math.abs(Crypto.getRandomLong().intValue()),mods.size());
        while(ct > 0){
            Module modObj = index != 0 ? (index != mods.size() ? mods[index] : mods[mods.size()-1]) : mods[0];
            Passenger__c pax = new Passenger__c();
            pax.name = 'TEST_' + (math.random() * 1000000).round();
            pax.Family_Name__c = 'KATGA_' + (math.random() * 1000000).round();
            pax.First_Name__c = 'STELLAX_' + (math.random() * 1000000).round();
            pax.Tour_Instance__c = tIns;
            pax.module_code__c = modObj.moduleCode;
            pax.module_name__c = 'Tour_' + (math.random() * 1000000).round();
            pax.Module_Start_Date__c = modObj.moduleStartDate;
            pax.Module_End_Date__c = modObj.moduleEndDate;
            pax.Module_Start_Location__c = modObj.moduleStartLoc;
            pax.Module_End_Location__c = modObj.moduleEndLoc;
            pax.Start_Date__c = modObj.moduleStartDate;
            pax.End_Date__c = modObj.moduleEndDate;
            pax.Start_Location_City__c = modObj.moduleStartLoc;
            pax.End_Location_City__c = modObj.moduleEndLoc;
            pax.Room_Type_Booked__c = roomType;
            pax.Passenger_Class__c = 'Passenger';
            pax.V2_Status__c = 'CF';
            Blob ext = Crypto.generateAesKey(128);
            string extid = EncodingUtil.base64Encode(ext);
            pax.Passenger_External_Id__c = extid; //required on edits
            Integer dob = (Math.mod(Math.abs(Crypto.getRandomLong().intValue()),75));
            dob = dob < 5 ? dob + 5 : dob;
            pax.Date_of_Birth__c = Date.today().addYears(-dob);
            Integer gen = (Math.mod(Math.abs(Crypto.getRandomLong().intValue()),2));
            gen = gen >= 2 ? gen - 1 : gen;
            pax.gender__c = gender.get(gen);
            passToRet.add(pax);
            ct--;
        }
        return passToRet;
    }
    
    private Map<Id, List<Module>> getModuleInfo(List<Id> tourInstanceIds){
        Map<Id, List<Module>> mapModuleList = new Map<Id, List<Module>>();
        List<String> compType = new List<String>{'Hotel', 'Train', 'Ferry/Cruise'};
        List<Tour_Instance_Itinerary__c> tourIIList = 
                    [SELECT Module_Start_Location__c, Module_Start_Day__c, Module_Start_Date__c, 
                        Is_Modular_Tour__c, Module_End_Day__c, Module_End_Date__c, Module_Code__c, 
                        Module_Code_Change_Date__c, Component_Type__c, Module_End_Location__c ,
                        Tour_Instance__c
                        FROM Tour_Instance_Itinerary__c
                        WHERE Tour_Instance__c IN: tourInstanceIds
                        AND Component_Type__c IN : compType];
        for(Tour_Instance_Itinerary__c tIInew : tourIIList){
            Module mod = new Module(tIInew);
            if(mapModuleList.get(tIInew.Tour_Instance__c) == null){
                mapModuleList.put(tIInew.Tour_Instance__c , new List<Module>());
            }
            mapModuleList.get(tIInew.Tour_Instance__c).add(mod);
        }
        return mapModuleList;
    }
    
    
    public List<Id> changePAXStatusToCancelled(List<Id> passengerIds){
        List<Id> passIdToReturn = new List<Id>();
        List<Passenger__c> passengersToUpdate = new List<Passenger__c>();
        for(Id paxId : passengerIds){
            Passenger__c pax = new Passenger__c(Id = paxId);
            pax.Passenger_Status__c = 'Cancelled';
            pax.V2_Status__c = 'CX';
            passengersToUpdate.add(pax);
        }
        
        update passengersToUpdate;
        
        for(Passenger__c pax : passengersToUpdate){
            passIdToReturn.add(pax.Id);
        }
        
        return passIdToReturn;
    }
    
    
    public List<Id> changeDatePAX(List<Id> passengerIds , Date oldSD, Date newSD, Date oldED, Date newED){
        List<Id> passIdToReturn = new List<Id>();
        List<Passenger__c> passengersToUpdate = new List<Passenger__c>();
        for(Id paxId : passengerIds){
            Passenger__c pax = new Passenger__c(Id = paxId);
            pax.Start_Date__c = newSD;
            pax.End_Date__c = newED;
            pax.Last_PAX_Start_Date__c = oldSD;
            pax.Last_PAX_End_Date__c = oldED;
            passengersToUpdate.add(pax);
        }
        
        update passengersToUpdate;
        
        for(Passenger__c pax : passengersToUpdate){
            passIdToReturn.add(pax.Id);
        }
        
        return passIdToReturn;
        
    }
    
    
    public List<Id> addNewModuleCodeToPAX(List<Id> passengerIds , String newModuleCode){
        List<Id> passIdToReturn = new List<Id>();
        List<Passenger__c> passengersToCreate = new List<Passenger__c>();
        List<Passenger__c> passActuals = [Select Id, Module_Code__c,  Start_Date__c, End_Date__c, 
                                            name , First_Name__c, Tour_Instance__c, module_name__c,
                                            Module_Start_Date__c, Module_End_Date__c, Module_Start_Location__c,
                                            Module_End_Location__c, Start_Location_City__c, 
                                            Room_Type_Booked__c, Passenger_Class__c, V2_Status__c, 
                                            Date_of_Birth__c , gender__c, End_Location_City__c
                                            FROM Passenger__c
                                            WHERE Id IN: passengerIds];
        for(Passenger__c paxAct : passActuals){
            Passenger__c pax = paxAct.clone(false, false, false, false);
            pax.Module_Code__c = newModuleCode;
            Blob ext = Crypto.generateAesKey(128);
            string extid = EncodingUtil.base64Encode(ext);
            pax.Passenger_External_Id__c = extid;
            pax.Start_Date__c = pax.End_Date__c.addDays(1);
            pax.End_Date__c = pax.End_Date__c.addDays(10);
            passengersToCreate.add(pax);
        }
        
        insert passengersToCreate;
        
        for(Passenger__c pax : passengersToCreate){
            passIdToReturn.add(pax.Id);
        }
        
        return passIdToReturn;
    }
    
    
    public List<Id> changePAXModuleCode(Id tourId  , String newModuleCode){
        List<Id> passIdToReturn = new List<Id>();
        List<Passenger__c> passengersToUpdate = new List<Passenger__c>();
        
        Map<Id, List<Module>> modInfo = getModuleInfo(new List<Id>{tourId});
        
        Module modObj ;
        for(Module md : modInfo.get(tourId)){
            if(md.moduleCode == newModuleCode){
                modObj = md; 
            }
        }
        
        if(modObj == null){
            system.assert(false,'Module code not found on this Tour Instance.');
        }
        
        for(Passenger__c pax : [SELECT Id, Module_Code__c, Room_Type_Booked__c 
                                FROM Passenger__c WHERE Tour_Instance__c =: tourId]){
            pax.Module_code__c = modObj.moduleCode;                        
            pax.Module_Start_Date__c = modObj.moduleStartDate;
            pax.Module_End_Date__c = modObj.moduleEndDate;
            pax.Module_Start_Location__c = modObj.moduleStartLoc;
            pax.Module_End_Location__c = modObj.moduleEndLoc;
            pax.Start_Date__c = modObj.moduleStartDate;
            pax.End_Date__c = modObj.moduleEndDate;
            pax.Start_Location_City__c = modObj.moduleStartLoc;
            pax.End_Location_City__c = modObj.moduleEndLoc;
            passengersToUpdate.add(pax);
        }
        
        update passengersToUpdate;
        
        for(Passenger__c pax : passengersToUpdate){
            passIdToReturn.add(pax.Id);
        }
        
        return passIdToReturn;
    }
    
    
    public void purgeTestPAX(){
        List<Passenger__c> paxToBeDeleted = [SELECT Id FROM Passenger__c
                                                WHERE name LIKE: 'TEST_%'];
        
        if(paxToBeDeleted.size() > 0){
            delete paxToBeDeleted;
        }
    }
    
}