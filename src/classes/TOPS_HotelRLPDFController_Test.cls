//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_HotelRLPDFController_Test 
// For Apex Class: TOPS_HotelRLPDFController
// For Apex Page: TOPS_HotelRLPDF
// Functionality Description: This apex controller is used to generate PDF of booked rooms.
//
//
@isTest(seeAllData=false)
private class TOPS_HotelRLPDFController_Test {

    
    private static testMethod void testFindFirstTII() {
        
        // Instantiating Test Data Factory Class.
        TestDataFactory theTestDataFactory = new TestDataFactory();
        String tIPrefix = 'TESTSIMPLE'; 
        StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name LIKE 'TIIDATA%'];
        blob tempB = defaultResource.Body;
        String contentFile = tempB.toString();
        List<List<String>> csvList = CSVReader.readCSVFile(contentFile);
        Map<String, List<TOPS_TestDataGenerator.CSVDataWrapper>> mapModCSVRecords = new Map<String, List<TOPS_TestDataGenerator.CSVDataWrapper>>();
        Map<String, List<List<String>>> listProcessedCSV = new Map<String, List<List<String>>>();
        listProcessedCSV.put('TestFile' , csvList);
        for(String module : listProcessedCSV.keySet()){
            if(mapModCSVRecords.get(module) == null){
                mapModCSVRecords.put(module, new List<TOPS_TestDataGenerator.CSVDataWrapper>());
            }
            Integer ct = 0;
            for(List<String> lstCSVRow : listProcessedCSV.get(module)){
                if(ct == 0){
                    ct++;
                    continue;
                }
                mapModCSVRecords.get(module).add(new TOPS_TestDataGenerator.CSVDataWrapper(lstCSVRow));
                ct++;
            }   
        }
        
        map<String, set<String>> mapOpCodeSupp = new map<String, set<String>>();
        map<String, Date> mapOpCodeSD = new map<String, Date>();
        map<String, Date> mapOpCodeED = new map<String, Date>();
        for(String module : mapModCSVRecords.keySet()){
            for(TOPS_TestDataGenerator.CSVDataWrapper csvRow : mapModCSVRecords.get(module)){
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
        
        TOPS_TestDataGenerator tiGen = new TOPS_TestDataGenerator();
        
        List<Tour_Instance__c> lstTI = tiGen.createNewTI(mapOpCodeSD, mapOpCodeED, tIPrefix); 
        List<Account> lstSupplier = tiGen.createNewSupplier(mapOpCodeSupp , tIPrefix);
        
        // Added by Ravi
        System.debug('List Supplier'+' '+lstSupplier);
        insert lstTI;
        Account acc = new Account();
        acc.FirstName = 'Testname';
        acc.LastName = 'lastname';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Tour Director').getRecordTypeId();
        acc.Room_Sort_Preference__c='By Room Type';
        insert acc;
        System.assertEquals(true,(lstTI!=null));
        
        insert lstSupplier;
        
        List<Tour_Instance__c> newListTI= new List<Tour_Instance__c>();
        for(Tour_Instance__c ti : lstTI){
            
            ti.Allocated_TD__c=acc.id;
            newListTI.add(ti);
        }
        //System.assert(false,'Test BY vM >>> ' + newListTI);
        update newListTI;
        //Added By Ravi
        System.debug('mapOfCSVRecords'+mapModCSVRecords);
        System.debug('lstTI'+lstTI);
        List<Tour_Instance_Itinerary__c> lstTII  = tiGen.createNewTII(mapModCSVRecords , lstTI , lstSupplier);
        //Added by Ravi
        lstTII[0].Supplier__c = lstSupplier[0].id;
        lstTII[0].Tour_Instance__c = lstTI[0].id;
        lstTII[0].Component_Type__c = 'Itinerary';
        insert lstTII;
        List<Tour_Instance_Itinerary__c> newlstTII  = new List<Tour_Instance_Itinerary__c>();
        
        for(Tour_Instance_Itinerary__c tii : lstTII){
            tii.Service_Start_Date__c =getDateFormat('2017-03-24');
            newlstTII.add(tii);
            break;
        }
        update newlstTII;
        List<Tour_Instance_Itinerary__c> updateList = new List<Tour_Instance_Itinerary__c>();
        
        StaticResource PAXdefaultResource = [Select  s.Body From StaticResource s where s.Name LIKE 'PassangerData%'];
        blob PAXtempB = PAXdefaultResource.Body;
        String PAXDataFile = PAXtempB.toString();
        List<List<String>> PAXcsvList = CSVReader.readCSVFile(PAXDataFile);
        List<Passenger__c> paxList = new List<Passenger__c>();
        Integer ct = 0;

        for(List<String> lstPaxRow : PAXcsvList){
            if(ct == 0){
                ct++;
                continue;
            }
            Passenger__c pax = new Passenger__c();
            pax.Name = lstPaxRow[0];
            pax.Module_Code__c = lstPaxRow[7];
            pax.Start_Date__c = getDateFormat(lstPaxRow[8]);
            pax.End_Date__c= getDateFormat(lstPaxRow[9]);
            pax.PAX_Timeline__c= lstPaxRow[10];
            pax.Bag_Number__c= lstPaxRow[11];
            pax.Tour_Instance__c = lstTI != null && lstTI.size() > 0 ? lstTI[0].Id : null;
            ct++;
            paxList.add(pax);
        }
        insert paxList;
        List<Passenger__c> newPaxList =  new List<Passenger__c>();
        for(Passenger__c pass : paxList)
        {
            pass.Room_Special_Instructions__c = 'Quiet Room Please.';
            pass.Dietary_Requirements__c = 'Low Carb Food Preferred.';
            pass.First_Name__c = 'Test #';
            pass.Family_Name__c = 'Passenger #' ;
            pass.Date_of_Birth__c = Date.today();
            pass.Passenger_Class__c = 'Passenger';
            newPaxList.add(pass);
        }
        update newPaxList;
        
        
        list<string> roomTypes = new list<string>{'SIG','TWN','TRP','QAD'};
            //tiGen.createRoomingLists(false);
            List<Tour_Instance_Itinerary__c> recievedTII = [SELECT ID, Tour_Instance__c, Supplier__c,
                                                            component_type__c , TII_Data__c
                                                            FROM Tour_Instance_Itinerary__c 
                                                           ];
        Test.startTest();  
        TOPS_CreateRoomingList batch = new TOPS_CreateRoomingList();
        Id batchID = database.executeBatch(batch); 
        Test.stopTest();
        
        //System.assert(false,'to check id test by VM'  + lstTII);
        TOPS_HotelEmailProcessor.emailToOA(lstTII[0].id);
        ApexPages.currentPage().getParameters().put('relatedObjectId', lstTII[0].Id);
        
        /*Map<String, List<TOPS_WrapperUtility.paxWrapper>> mapStringWRTWrapper = new Map<String, List<TOPS_WrapperUtility.paxWrapper>>(); 
        Double roomId = 10.00;
        List<TOPS_WrapperUtility.paxWrapper> lstWrapper = new List<TOPS_WrapperUtility.paxWrapper>();
        lstWrapper.add(new TOPS_WrapperUtility.paxWrapper(paxList[0],10,'Twin'));
        mapStringWRTWrapper.put('Twin',lstWrapper);
        
        TOPS_HotelEmailProcessor.roomTypeToPaxWrapper = mapStringWRTWrapper;*/
        
        TOPS_HotelRLPDFController controller = new TOPS_HotelRLPDFController();
        controller.getBlankBookedRoomWrapper();
        controller.getRegionCodeAndFooterLogoList();
        
        
        
        // Start the test
        //Test.startTest();
        Id firstTIIId = controller.findFirstTII(lstTII[0].id);
        
        // Stop the test
        //Test.stopTest();
    }
    public static Date getDateFormat(string dateCSV){
        List<String> dateStr = dateCSV.split('/');
        String retDate;
        if(dateStr.size() > 1){
            retDate = dateStr[2] +'-'+ dateStr[0]  +'-'+ dateStr[1];
        }else{
            retDate = dateStr[0];
        }
        
        return Date.ValueOf(retDate);
    }
}




/*************************** PRIVATE METHODS ******************************/
/*  private static Tour_Instance_Itinerary__c createTourInstanceItin(Id tourId, Id supplierId, Integer dayNumber, String compType) {
Tour_Instance_Itinerary__c tii = new Tour_Instance_Itinerary__c ();
tii.Tour_Instance__c = tourId;
tii.Supplier__c = supplierId;
tii.Day_Number__c = dayNumber;
tii.Component_Type__c = compType;
return tii;
}

private static Account createAccount(String name) {
Account acc = new Account();
acc.Name = name;
return acc;
}

}*/