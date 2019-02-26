/******************************************************************************************************
//(c) 2017 Appirio, Inc.
//
//
//Date              Updated By          Task No.    Description
//Feb 24, 2017      Vivek Makkar                    Test Data for TOPS_TestDataGenerator
//Feb 25, 2017      Anuj Khanna                     Improve Coverage and removed Error
*******************************************************************************************************/
@isTest
private class TOPS_TestDataGeneratorTest {
        
    static String tIPrefix = 'TESTSIMPLE'; 
    static TOPS_TestDataGenerator tiGen = new TOPS_TestDataGenerator(); 
    static List<Tour_Instance__c> lstTI = new List<Tour_Instance__c>();
    static List<Id> PassengerIds = new List<Id>();
    static Date forthColumnDate = Date.parse('01/02/2018');
        
    private static void createTestTII(){
        StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name LIKE 'TIIDATA%'];
        blob tempB = defaultResource.Body;
        String contentFile = tempB.toString();
         
        ContentVersion cv = new ContentVersion();
        cv.versionData = tempB;
        cv.Title = 'TEST';
        cv.PathOnClient = 'www.google.com/file.csv';
        insert cv;
        
        List<String> moduleName = new List<String>{'TEST'};
        lstTI = tiGen.createModularTIIRecords(tIPrefix , moduleName ,false);
        tiGen.createRoomingLists(false);
    }
    
    private static void createTestPAX(){
        List<Id> tourInstanceIds = new List<Id>();
        for(Tour_Instance__c ti : lstTI){
            tourInstanceIds.add(ti.id);
        }
        List<string> roomTypes = new list<string>{'SIG','TWN','TRP','QAD'};
        PassengerIds = tiGen.createNewPAX(20,tourInstanceIds,roomTypes);
    }
    
    private static testmethod void executeTestDataGenerator(){
        
        createTestTII();
        
        Test.startTest();
        TOPS_CreateRoomingList batch = new TOPS_CreateRoomingList();
        Id batchID = database.executeBatch(batch); 
        Test.stopTest();
        
        createTestPAX();
        
        //System.assert(false,PassengerIds);
        tiGen.addNewModuleCodeToPAX(PassengerIds, 'M3');
        tiGen.changePAXModuleCode(lstTI[0].id, 'M2');
        tiGen.changePAXStatusToCancelled(PassengerIds);
        tiGen.changeDatePAX(PassengerIds, getDateFormat('2017-03-23'),getDateFormat('2017-03-24'),getDateFormat('2017-04-24'),getDateFormat('2017-04-27'));
        
        
        tiGen.purgeModularTIIRecords(tIPrefix);
        tiGen.purgeTestPAX();
        
        tiGen.tourInstanceIds.add(lstTI[0].Id); 
        
        ID jobID = System.enqueueJob(tiGen);
        
    }
    
    static testMethod void testPAXAccomodationClass(){
         createTestTII();
         List<Tour_Instance_Itinerary__c> hotelTII0 = [SELECT id, Supply_Purpose__c, Module_Code__c
                                                        FROM Tour_Instance_Itinerary__c
        
                                                        WHERE Tour_Instance__c =: lstTI[0].Id];
                                                        
        for(Tour_Instance_Itinerary__c tii : hotelTII0){                                    
         tii.Module_Code__c='TEST';
         break;
         }
         update hotelTII0;
         
         List<Tour_Instance_Itinerary__c> hotelTII = [SELECT id, Supply_Purpose__c, Module_Code__c
                                                        FROM Tour_Instance_Itinerary__c
                                                        WHERE Tour_Instance__c =: lstTI[0].Id];
         Integer tiiSize = hotelTII.size();
         Integer ct = 0;
         List<Tour_Instance_Itinerary__c> newTIIList = new List<Tour_Instance_Itinerary__c>();
         for(Tour_Instance_Itinerary__c tii : hotelTII){
            if(tii.Module_Code__c == 'M2'){
                tii.Supply_Purpose__c = 'Budget';
            }
            if(tii.Module_Code__c == 'M3'){
                tii.Supply_Purpose__c = 'Standard';
            }
            if(tii.Module_Code__c == 'M4'){
                tii.Supply_Purpose__c = 'Premium';
            }
            if(tii.Module_Code__c == 'TEST'){
                tii.Supply_Purpose__c = 'Budget';}
                
            newTIIList.add(tii);
         }
         
        update newTIIList;
        
        
        Test.startTest();
        TOPS_CreateRoomingList batch = new TOPS_CreateRoomingList();
        Id batchID = database.executeBatch(batch); 
        Test.stopTest();
        
        createTestPAX();
        
    }
    
    private static Date getDateFormat(String dateCSV){
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