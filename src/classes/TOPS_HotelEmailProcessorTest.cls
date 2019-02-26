/**
* Test Class Name   : TOPS_HotelEmailProcessorTest
* For Apex Class    : TOPS_HotelEmailProcessor
* Created By        : Nitish Bansal / Vinod Kumar
* Modified By       : Hemendra Singh
* Date              : 02/11/2016 
* Purpose           : T-465528
*/
@isTest(seeAllData=false)
private class TOPS_HotelEmailProcessorTest {
  // Private Data Members.
  private static final Id ACCOUNT_BRAND_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;

  /**
  * @description  This method validates class functionality.
  *
  * @param        void
  * @return       void
  */
  @isTest static void validteClassFunctionality() {
    // Instantiating Test Data Factory Class.
    TestDataFactory theTestDataFactory = new TestDataFactory();

    // Inserting Test Email Print Request Config Record.
        Email_Print_Request_Config__c testEmailPrintConfig = theTestDataFactory.createEmailPrintRequestConfig(
          'testHotelEmail',
          'TOPS_HotelEmailProcessor',
          'testFieldset',
      'testSubject',
      'testBody',
      'Hotel Email',
      'Email',
      true
    );

    // Instantiating Test Account.
        Account acc = new Account(
      FirstName = 'Test',
      LastName = 'Account',
      Email__c = 'vkumar@appirio.com'
    );

    // Instantiating Test Brand Account.
    Account theTestBrand = new Account(
      Name = 'Test Brand',
      Website = 'http://www.website.com',
      RecordTypeId = ACCOUNT_BRAND_RECORD_TYPE_ID
    );

    // Inserting Test Accounts.
    insert new List<Account> {
      acc,
      theTestBrand
    };

    // Inserting Test Tour Instance.
    Tour_Instance__c test_TourInstance = theTestDataFactory.createTourInstance('test tour', 'Abcd', false); 
    test_TourInstance.Allocated_TD__c = acc.id;
    test_TourInstance.Operating_Product_Code__c = 'AAE34921';
    test_TourInstance.Brand__c = theTestBrand.Id;
        insert test_TourInstance;

    // Inserting Test Tour Instance Itinerary.
    Tour_Instance_Itinerary__c tii = theTestDataFactory.createTourInstanceItinerary(acc.id, test_TourInstance.id, false);
    tii.Component_Type__c  = 'Hotel';
    tii.day_Number__c = 1;
    insert tii;

    // Inserting Test Tour Passengers.
    Passenger__c p = null;
    List<Passenger__c> lstPassanger = new List<Passenger__c>();
    for(Integer i = 1;i < 10;i++) {
      p = theTestDataFactory.createPassenger('Test Passenger' + String.valueOf(i), test_TourInstance.Id, false);
      p.Email_Share_Opt_In__c = true;
      p.Dietary_Requirements__c = 'I would prefer green meal';

      if(i== 1 || i == 4 || i == 7) {
        p.Actual_Room_Type__c = 'Twin';
      }
      else if(i == 2 || i == 5 || i == 8) {
        p.Actual_Room_Type__c = 'Triple';
      }
      else if( i == 3 || i == 6 || i == 9) {
        p.Actual_Room_Type__c = 'Quad';
      }

      if(i == 1) {
        p.Passenger_Class__c = 'Tour Director';
      }
      if(i == 2) {
        p.Passenger_Class__c = 'Tour Director';
        p.Account__c = acc.id;
      }
      lstPassanger.add(p);
    } 
    insert lstPassanger;

        // Inserting Test Email Print Request Record.
    Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
      'Test Email Subject',
      'This is a test email print request data string.',
      'nitish.bansal@appirio.com',
      'New',
      'Meal Selections Email',
      false
    );
        theTestEmailPrintRequest.Related_Object_Id__c = tii.Id;
        theTestEmailPrintRequest.Data__c = 'This is the test application data.';
        theTestEmailPrintRequest.Preview__c = true; 
        insert theTestEmailPrintRequest;

    // Instantiating Hotel Email Processor.
    //TOPS_HotelEmailProcessor objHotelProcessor = new TOPS_HotelEmailProcessor();
        //TOPS_EmailWrapper testEmailWrapper = objHotelProcessor.createEmailWrapper(theTestEmailPrintRequest, testEmailPrintConfig);
        //system.assertEquals(testEmailWrapper.emailSubject, 'Hotel Email');
    }
    //
    static Testmethod void test_checkEmailToOA(){
        TestDataFactory theTestDataFactory = new TestDataFactory();
        
        Email_Print_Request_Config__c testEmailPrintConfig = theTestDataFactory.createEmailPrintRequestConfig(
              'testHotelEmail',
              'TOPS_HotelEmailProcessor',
              'testFieldset',
          'testSubject',
          'testBody',
          'Hotel Email',
          'Email',
          true
        );
        
        
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
        
        insert lstTI;
        Account acc = new Account();
        //acc.FirstName = 'Test Account';
        //acc.LastName = 'Test'; //Business Unit
        acc.Name = 'Test Account';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Unit').getRecordTypeId(); 
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
        
        List<Tour_Instance_Itinerary__c> lstTII  = tiGen.createNewTII(mapModCSVRecords , lstTI , lstSupplier);
        insert lstTII;
        List<Tour_Instance_Itinerary__c> updateList = new List<Tour_Instance_Itinerary__c>();
        
        StaticResource PAXdefaultResource = [Select  s.Body From StaticResource s where s.Name LIKE 'PassangerData%'];
        blob PAXtempB = PAXdefaultResource.Body;
        String PAXDataFile = PAXtempB.toString();
        List<List<String>> PAXcsvList = CSVReader.readCSVFile(PAXDataFile);
        List<Passenger__c> paxList = new List<Passenger__c>();
        Integer ct = 0;
        
        Booking__c booking = new Booking__c();
        booking.recordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        booking.Selling_Company__c = acc.Id;
        booking.Original_Booking_Date__c = system.today();
        booking.Name = 'Test Booking';
        insert booking;
        
        Booking_Passenger__c bc = new Booking_Passenger__c();
        bc.Name = 'Test Booking Passenger';
        bc.RecordTypeId = Schema.SObjectType.Booking_Passenger__c.getRecordTypeInfosByName().get('Booking Passengers').getRecordTypeId();
        bc.Booking__c = booking.Id;
        insert bc;
        
        Booking_Component__c b = new Booking_Component__c();
        b.Status__c = 'CF';
        b.Name = 'Test Booking Component';
        b.Booking_Passenger__c = bc.Id;
        b.RecordTypeId = Schema.SObjectType.Booking_Component__c.getRecordTypeInfosByName().get('Tour').getRecordTypeId();
        insert b;
      
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
        
        
        list<string> roomTypes = new list<string>{'SIG','TWN','TRP','QAD'};
            //tiGen.createRoomingLists(false);
            
        Test.startTest();  
        TOPS_CreateRoomingList batch = new TOPS_CreateRoomingList();
        Id batchID = database.executeBatch(batch); 
        Test.stopTest();
        
        
        Tour_Instance__c tourInstance = new Tour_Instance__c();
        tourInstance.Operating_Product_Code__c = 'VBS';
        tourInstance.Departure_Code__c  = 'd';
        tourInstance.CurrencyIsoCode = 'EUR';
        tourInstance.Allocated_TD__c = acc.Id;
        insert tourInstance;
        
        Passenger__c pax1 = new Passenger__c();
        pax1.Name = 'Test Passenger';
        pax1.Module_Code__c = 'AAIMSEEE06';
        pax1.Start_Date__c = system.today().addDays(2);
        pax1.End_Date__c= system.today().addDays(10);
        pax1.PAX_Timeline__c= '{"days":{"0":{"Actual_Room_ID__c":2,"Actual_Room_Type__c":"Quad"},"1":{"Actual_Room_ID__c":2,"Actual_Room_Type__c":"Quad","RoomingList_ID":"a2P9E0000005bR6UAI","PAX_On_Tour":false}}}';
        pax1.Bag_Number__c= '16';
        pax1.Booking_Component__c = b.Id;
        pax1.Passenger_Status__c = 'Active';
        pax1.Passenger_Class__c = 'Driver';
        pax1.Tour_Instance__c = tourInstance.Id;
        insert pax1;
        
        String str = '{"modules" : [ {"name" : "AAIMSEEE06"} ]}';
            
        List<Tour_Instance_Itinerary__c> lstofTour = new List<Tour_Instance_Itinerary__c>();
        Tour_Instance_Itinerary__c tour1 = new Tour_Instance_Itinerary__c(component_type__c = 'RoomingList',Tour_Instance__c=tourInstance.Id,day_number__c=1,Service_Start_Date__c=system.today().addYears(-1),TII_Data__c= str,Module_Code__c='AAIMSEEE06');
        lstofTour.add(tour1);
        Tour_Instance_Itinerary__c tour2 = new Tour_Instance_Itinerary__c(component_type__c = 'RoomingList',Tour_Instance__c=tourInstance.Id,day_number__c=2,Service_Start_Date__c=system.today().addYears(-2),TII_Data__c= str,Module_Code__c='AAIMSEEE06');
        lstofTour.add(tour2);
        Tour_Instance_Itinerary__c tour3 = new Tour_Instance_Itinerary__c(component_type__c = 'RoomingList',Tour_Instance__c=tourInstance.Id,day_number__c=3,Service_Start_Date__c=system.today(),TII_Data__c= str,Module_Code__c='AAIMSEEE06');   
        lstofTour.add(tour3);
        Tour_Instance_Itinerary__c tour4 = new Tour_Instance_Itinerary__c(component_type__c = 'RoomingList',Tour_Instance__c=tourInstance.Id,day_number__c=4,Service_Start_Date__c=system.today().addDays(-10),TII_Data__c= str,Module_Code__c='AAIMSEEE06');
        lstofTour.add(tour4);
        
        insert lstofTour;
        
        Map<String, List<Passenger__c>> mapStringWRTPass = new Map<String, List<Passenger__c>>();
        mapStringWRTPass.put('Twin',paxList);
         
        List<Tour_Instance_Itinerary__c> recievedTII = [SELECT ID, Tour_Instance__c, Supplier__c,
                                                        component_type__c , TII_Data__c,Module_Code__c
                                                        FROM Tour_Instance_Itinerary__c 
                                                        WHERE component_type__c = 'RoomingList' AND Id IN:lstofTour];
        //System.assertEquals(recievedTII, null);
        //Updated By Ravi--Start
        if(!recievedTII.isEmpty())
        TOPS_HotelEmailProcessor.emailToOA(recievedTII[0].id);
        //System.assertEquals(true,TOPS_HotelEmailProcessor.roomTypeToPaxVF.containsKey('Twin'));
        //
        List <Passenger__c> passangerList= new List<Passenger__c>(); 
      
        if(TOPS_HotelEmailProcessor.roomTypeToPaxVF != null && !TOPS_HotelEmailProcessor.roomTypeToPaxVF.isEmpty())
        {
        for(Passenger__c pass : TOPS_HotelEmailProcessor.roomTypeToPaxVF.get('Twin')){
            System.assertEquals('-1', pass.Bag_Number__c);
            //Updated By Ravi--End
            break;
        }
        }
        
            Email_Print_Request__c theTestEmailPrintRequest = theTestDataFactory.createEmailPrintRequest(
              'Test Email Subject',
              'This is a test email print request data string.',
              'nitish.bansal@appirio.com',
              'New',
              'Meal Selections Email',
              false
            );
            
            //
            theTestEmailPrintRequest.Related_Object_Id__c = recievedTII[2].id;
            theTestEmailPrintRequest.Data__c = 'This is the test application data.';
            theTestEmailPrintRequest.Preview__c = true;
            theTestEmailPrintRequest.Parameters__c = 'V2';
            theTestEmailPrintRequest.Additional_Emails__c = '{"cc":"jai@test.com,jai@success.com"}'; // Added by Jai Gupta S-568616
            insert theTestEmailPrintRequest;
            
        Map<String, List<TOPS_WrapperUtility.paxWrapper>> mapStringWRTWrapper = new Map<String, List<TOPS_WrapperUtility.paxWrapper>>(); 
        //START- Modifed by Sajal for C-00226000
        //Double roomId = 10.00;
        String roomId = '10.00';
        //END for C-00226000
        List<TOPS_WrapperUtility.paxWrapper> lstWrapper = new List<TOPS_WrapperUtility.paxWrapper>();
        //START- Modified by Sajal for C-00226000
        //lstWrapper.add(new TOPS_WrapperUtility.paxWrapper(paxList[0],10,'Twin'));
        lstWrapper.add(new TOPS_WrapperUtility.paxWrapper(paxList[0],'10','Twin'));
        //END for C-00226000
        mapStringWRTWrapper.put('Twin',lstWrapper);
        
        //START- Modified by Sajal for C-00226000
        //Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>> mapDecimalWRTWrapper = new Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>>(); 
        Map<String, List<TOPS_WrapperUtility.paxWrapper>> mapDecimalWRTWrapper = new Map<String, List<TOPS_WrapperUtility.paxWrapper>>(); 
        //mapDecimalWRTWrapper.put(10,lstWrapper);
        mapDecimalWRTWrapper.put('10',lstWrapper);
        //END for C-00226000
        
        TOPS_HotelEmailProcessor objHotelProcessor = new TOPS_HotelEmailProcessor();
        TOPS_HotelEmailProcessor.roomTypeToPax(mapStringWRTPass,'Twin',paxList[0]);
        TOPS_HotelEmailProcessor.getCrewOnDay(tourInstance.Id, tour1.Id);
        TOPS_HotelEmailProcessor.fillWrapperData(mapStringWRTWrapper, roomId, 'Twin', paxList[0]);
        TOPS_HotelEmailProcessor.roomToPax(mapDecimalWRTWrapper, roomId, 'Twin', paxList[0]);
        TOPS_EmailWrapper testEmailWrapper = objHotelProcessor.createEmailWrapper(theTestEmailPrintRequest, testEmailPrintConfig);
        
        
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