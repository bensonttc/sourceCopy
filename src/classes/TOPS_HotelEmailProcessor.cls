//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_HotelEmailProcessor
// Description: Used in email print service.
//
// 8th Feb 2016    Kirti Agarwal    Modified (Task # T-465528)
// 11th Feb 2016    Nitish Bansal    Modified (Task # T-465528)
// 24th October 2016    Ravi Jain    Modified (Story# S-428448) - Please see the story description for more details.
// 14th Feb 2017    Abhishek Saxena  Modified (T-568303)
// 29 June 2018     Sajal Shah       Modified (C-00226000)
// 10th Aug 2018    Jai Gupta       Modified (Story S-568616) - Send email to cc email addresses
public without sharing class TOPS_HotelEmailProcessor implements TOPS_EmailProcessorInterface {
  // Private Data Members.
  private static final Integer MAX_RECORDS = 58;

  // Public Data Members.
  public static List < Passenger__c > passengerListArray;
  public static String nameString='';
    
  public static String tourInstanceId;
  public static String brandName;
  public static String toEmail;
  public static String fromEmail;
  public static String ccEmail;
  public static String regionCode;
  public static String brand;
  public static boolean preview;
  public static final String TDhotelSalutation = '[TDhotelSalutation]';
  public static final String brandNameField = '[brandName]';
  public static final String tourCode = '[tourCode]';
  public static final String TDbusinessEmailAdr = '[TDbusinessEmailAdr]';
  public static final String TDselectedContactNum = '[TDselectedContactNum]';
  public static final String TDhotelSignoff = '[TDhotelSignoff]';
  public static final String tourNametourCode = '[tourName tourCode]';
  public static final String TDfullName = '[TDfullName]';
  public static final String tourBrandName = '[tourBrandName]';
  public static final String TDroleNameField = '[TDroleName]';
  public static final String summaryOfRoomTypesNeededField = '[summaryOfRoomTypesNeeded]';
  public static final String summaryOfDietaryNeedsField = '[summaryOfDietaryNeeds]';
  public static final String tourBrandName_TDroleNameField = '[tourBrandName TDroleName]';
  public static final String theApplicationDataField = '[App Data]';
  public static string BrandMessage = '[BrandMessage]';
  
  public static Map<String, List<Passenger__c>> roomTypeToPaxVF;
  public static Map<String, List<TOPS_WrapperUtility.paxWrapper>> roomTypeToPaxWrapper;
  public static Map<Integer, List<TOPS_WrapperUtility.paxWrapper>> roomNumToPaxWrapper;
  public static String sortType;
  public static Map<Date, Map<Integer, List<TOPS_WrapperUtility.paxWrapper>>> dateToActualRoomPax;
  public static Map<Date, Map<String, List<TOPS_WrapperUtility.paxWrapper>>> dateToRTPAXWrapper;
  //Map of Service Date to Day Number
  public static Map<Date, Decimal> mapDateToDay;
  //Creating a Map of all Modules on a particular Service Date
  public static Map<Date, Set<String>> mapDatetoModules;
  //Map of TII's on a particular Date.
  public static Map<Date, List<Tour_Instance_Itinerary__c>> mapDateToTII;
  public static Tour_Instance_Itinerary__c recievedTII;
  public static Map<Date, Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>>> dateToRoomPAX;
  
   //================================================================      
   // Name         : emailToOA
   // Description  : Creates and Sends a Rooming List to OA
   // Created Date : 14th Feb 2017 
   // Created By   : Abhishek Saxena (Appirio)
   // Task        : T-568303
   //==================================================================
  public static void emailToOA(ID recievedTIIID){
  
      //Retrieving the TII sent from the App
      recievedTII = [SELECT ID, Tour_Instance__c,Tour_Instance__r.Allocated_TD__c, Supplier__c,
                                                Service_Start_Date__c, day_Number__c 
                                                FROM Tour_Instance_Itinerary__c
                                                WHERE ID =: recievedTIIID LIMIT 1];
      sortType = [SELECT Id, Room_Sort_Preference__c FROM Account WHERE Id =: recievedTII.Tour_Instance__r.Allocated_TD__c].Room_Sort_Preference__c;
                                                
      Map<String, List<Passenger__c>> mapModtoPax = getMapModToPax(recievedTII);
      
      
      //Creating a Map of Passengers on a Particular Service Date
      Map<Date, List<Passenger__c>> mapDatetoPax = new Map<Date, List<Passenger__c>>();
      //Creating a Map which contains Passengers sorted by their room type on every service date
      Map<Date, Map<String, List<Passenger__c>>> dateToRTPAX = new Map<Date, Map<String, List<Passenger__c>>>();
      //Creating a Map of Passengers in a Room on a particular Service Date
      //START- Modified by Sajal for C-00226000
      //Map<Date, Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>>> dateToRoomPAX = new Map<Date, Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>>>();
      Map<Date, Map<String, List<TOPS_WrapperUtility.paxWrapper>>> dateToRoomPAX = new Map<Date, Map<String, List<TOPS_WrapperUtility.paxWrapper>>>();
      //END for C-00226000
      //Creating a Map of Passengers sorted by Bag Number
      dateToActualRoomPax = new Map<Date, Map<Integer, List<TOPS_WrapperUtility.paxWrapper>>>();
      //Creating a Map of Passenger Wrapper in sorted by Room Type on every service date
      dateToRTPAXWrapper = new Map<Date, Map<String, List<TOPS_WrapperUtility.paxWrapper>>>();
      for(Date serviceDate : mapDatetoModules.keySet()){
        //Creating a Map of Passengers in same room type
        Map<String, List<Passenger__c>> paxSortedByRT = new Map<String, List<Passenger__c>>();
        //Creating a Map of Passengers sharing the same room
        //START- Modified by Sajal for C-00226000
        //Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>> roomPax = new Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>>();
         Map<String, List<TOPS_WrapperUtility.paxWrapper>> roomPax = new Map<String, List<TOPS_WrapperUtility.paxWrapper>>();
        //END for C-00226000
        
        //Creating a Map of Passengers with Actual Room Number value (Lowest Bag Number in a room+)
        Map<Integer, List<TOPS_WrapperUtility.paxWrapper>> actualRoomPax = new Map<Integer, List<TOPS_WrapperUtility.paxWrapper>>();
        //Creating a Map of Room Type to Passenger Wrapper to be displayed on page
        Map<String, List<TOPS_WrapperUtility.paxWrapper>> rtToPaxWrapper = new Map<String, List<TOPS_WrapperUtility.paxWrapper>>(); 
        //Creating a Map of Actual Room Nummber to Passenger Wrapper to be displayed on page
        Map<Integer, List<TOPS_WrapperUtility.paxWrapper>> arnToPaxWrapper = new Map<Integer, List<TOPS_WrapperUtility.paxWrapper>>();
        for(String moduleName : mapDatetoModules.get(serviceDate)){
          if(mapDatetoPax.get(serviceDate) == null){
            mapDatetoPax.put(serviceDate, new List<Passenger__c>());
          }
          for(Passenger__c pax : mapModtoPax.get(moduleName)){
            if(pax.PAX_Timeline__c != null && !String.isEmpty(pax.PAX_Timeline__c)){
              String jsonInput = pax.PAX_Timeline__c;
              //json = json.replace('__c','');
              //TOPS_WrapperUtility.PAXTimeline obj = TOPS_WrapperUtility.parsePAXTimeline(json);
              Map<String, Object> timeline = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
              Map<String, Object> days = (Map<String, Object>)timeline.get('days');
              for(String day : days.keySet()){
                Map<String, Object> eachDay = (Map<String, Object>)days.get(day);
                if(Integer.valueOf(day) == mapDateToDay.get(serviceDate)
                    && eachDay.get('PAX_On_Tour') != null
                    && eachDay.get('PAX_On_Tour') == true
                    && eachDay.get('Actual_Room_Type__c')  != null
                    && eachDay.get('Actual_Room_Type__c')  != ''
                    && eachDay.get('Actual_Room_ID__c') != null
                    && pax.Start_Date__c != null && pax.End_Date__c != null 
                    && pax.Start_Date__c <= serviceDate  && pax.End_Date__c >= serviceDate){
                      mapDatetoPax.get(serviceDate).add(pax);
                      //START- Modified by Sajal for C-00226000
                      String actualRoomIdString = String.valueOf(eachDay.get('Actual_Room_ID__c'));
                      //roomPax = roomToPax(roomPax, Decimal.valueOf(String.valueOf(eachDay.get('Actual_Room_ID__c'))), String.valueOf(eachDay.get('Actual_Room_Type__c')), pax);
                      roomPax = roomToPax(roomPax, actualRoomIdString, String.valueOf(eachDay.get('Actual_Room_Type__c')), pax);
                      paxSortedByRT = roomTypeToPax(paxSortedByRT, String.valueOf(eachDay.get('Actual_Room_Type__c')), pax);
                      //rtToPaxWrapper = fillWrapperData(rtToPaxWrapper, Decimal.valueOf(String.valueOf(eachDay.get('Actual_Room_ID__c'))), String.valueOf(eachDay.get('Actual_Room_Type__c')), pax);
                      rtToPaxWrapper = fillWrapperData(rtToPaxWrapper, actualRoomIdString, String.valueOf(eachDay.get('Actual_Room_Type__c')), pax);
                      //END for C-00226000
                }
              }
            }
          }
        }
        dateToRTPAX.put(serviceDate, paxSortedByRT);
        //dateToRoomPAX.put(serviceDate, roomPax);
        dateToRTPAXWrapper.put(serviceDate, rtToPaxWrapper);
        //START- Modifed by Sajal for C-00226000
        //for(Decimal roomId : roomPax.keySet()){
        for(String roomId : roomPax.keySet()){
        //END for C-00226000
          if(roomPax.get(roomId) != null && !String.isEmpty(roomPax.get(roomId)[0].pax.Bag_Number__c)){
            actualRoomPax.put(Integer.valueOf(roomPax.get(roomId)[0].pax.Bag_Number__c), roomPax.get(roomId));
            for(TOPS_WrapperUtility.paxWrapper pax : roomPax.get(roomId)){
              //START- Modifed by Sajal for C-00226000
              //pax.roomNumber = Integer.valueOf(roomPax.get(roomId)[0].pax.Bag_Number__c);
              pax.roomNumber = String.valueOf(roomPax.get(roomId)[0].pax.Bag_Number__c);   
              //END for C-00226000
            }
          }
        }
        dateToRoomPAX.put(serviceDate, roomPax);
        if(actualRoomPax.size() > 0)
          dateToActualRoomPax.put(serviceDate, actualRoomPax);
      }
      System.debug('mapDatetoPax'+mapDateToPax);
      System.debug('dateToRTPAX'+dateToRTPAX);
      System.debug('dateToRoomPAX'+dateToRoomPAX);
      System.debug('dateToActualRoomPax'+dateToActualRoomPax);
      // System.assert(false,'dateToRTPAX '+dateToRTPAX);
      roomTypeToPaxVF = dateToRTPAX.get(recievedTII.Service_Start_Date__c);
      //Data for PDF sorted by Room Type
      roomTypeToPaxWrapper = dateToRTPAXWrapper.get(recievedTII.Service_Start_Date__c);
      roomNumToPaxWrapper = dateToActualRoomPax.get(recievedTII.Service_Start_Date__c);
      //System.assert(false,'roomTypeToPaxWrapper'+roomTypeToPaxWrapper);
   }//T-568303 - AS - Changes end
   
   //================================================================      
   // Name         : roomTypeToPax
   // Description  : Creates and Sends a Room Type to PAX map
   // Created Date : 19th Feb 2017 
   // Created By   : Abhishek Saxena (Appirio)
   // Task        : T-568303
   //==================================================================
   @TestVisible
   private static Map<String, List<Passenger__c>> roomTypeToPax(Map<String, List<Passenger__c>> initialMap, String actualRoomType, Passenger__c pax){
    if(initialMap.get(actualRoomType) == null){
      initialMap.put(actualRoomType, new List<Passenger__c>());
    }
    initialMap.get(actualRoomType).add(pax);
    return initialMap;
   }
   
   
   
   //================================================================      
   // Name         : fillWrapperData
   // Description  : RoomType to SortedPax Map
   // Created Date : 27th Nov 2017 
   // Created By   : Anuj Khanna (Appirio)
   // Task        : T-568303
   //==================================================================
   //START- Modified by Sajal for C-00226000
   @TestVisible
   //private static Map<String, List<TOPS_WrapperUtility.paxWrapper>> fillWrapperData(Map<String, List<TOPS_WrapperUtility.paxWrapper>> initialMap, decimal actualRoomId, String actualRoomType, Passenger__c pax){
   private static Map<String, List<TOPS_WrapperUtility.paxWrapper>> fillWrapperData(Map<String, List<TOPS_WrapperUtility.paxWrapper>> initialMap, String actualRoomId, String actualRoomType, Passenger__c pax){
   //END for C-00226000
    if(initialMap.get(actualRoomType) == null){
      initialMap.put(actualRoomType, new List<TOPS_WrapperUtility.paxWrapper>());
    }
    initialMap.get(actualRoomType).add(new TOPS_WrapperUtility.paxWrapper(pax, actualRoomId, actualRoomType));
    
    //Additional Sorting Starts - AK
    List<TOPS_WrapperUtility.paxWrapper> sortedList = getSortedPaxByBagNumbers(initialMap.get(actualRoomType));
    
    initialMap.put(actualRoomType, sortedList);
    //Additional Sorting End - AK
    
    return initialMap;
   }
   
   
   //================================================================      
   // Name         : roomToPax
   // Description  : Creates and Sends a map based on Actual room Number
   //                after sorting the bag numbers.
   // Created Date : 14th Feb 2017 
   // Created By   : Abhishek Saxena (Appirio)
   // Task        : T-568303
   //==================================================================
   //START- Modified by Sajal for C-00226000   
   @TestVisible
   //private static Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>> roomToPax(Map<Decimal, List<TOPS_WrapperUtility.paxWrapper>> initialMap, Decimal actualRoomId, String actualRoomType, Passenger__c pax){
   private static Map<String, List<TOPS_WrapperUtility.paxWrapper>> roomToPax(Map<String, List<TOPS_WrapperUtility.paxWrapper>> initialMap, String actualRoomId, String actualRoomType, Passenger__c pax){
   //END for C-00226000    
    if(initialMap.get(actualRoomId) == null){
      initialMap.put(actualRoomId, new List<TOPS_WrapperUtility.paxWrapper>());
    }
    initialMap.get(actualRoomId).add(new TOPS_WrapperUtility.paxWrapper(pax, actualRoomId, actualRoomType));
    List<TOPS_WrapperUtility.paxWrapper> sortedList = getSortedPaxByBagNumbers(initialMap.get(actualRoomId));
    
    initialMap.put(actualRoomId, sortedList);
    
    return initialMap;
   }
   
   //================================================================      
   // Name         : getSortedPaxByBagNumbers
   // Description  : sorting the PAX by bag numbers.
   // Created Date : 27th Nov 2017 
   // Created By   : Anuj Khanna (Appirio)
   // Task        : T-568303
   //==================================================================
   private static List<TOPS_WrapperUtility.paxWrapper> getSortedPaxByBagNumbers(List<TOPS_WrapperUtility.paxWrapper> sortedList){
       TOPS_WrapperUtility.paxWrapper temp = new TOPS_WrapperUtility.paxWrapper();
        for(Integer i = 0; i < sortedList.size(); i++){
            if(sortedList[i].pax.Bag_Number__c == null)
                sortedList[i].pax.Bag_Number__c = '-1';
        }
        //Sorting the data
        for(Integer i = 0; i < sortedList.size(); i++){
          for(Integer j = 1; j < sortedList.size()-i; j++){
            // System.debug('sortedList[j].pax.Bag_Number__c'+sortedList[j-1].pax.Bag_Number__c+'sortedList[j].pax.Bag_Number__c'+sortedList[j].pax.Bag_Number__c);
            if(Integer.valueOf(sortedList[j-1].pax.Bag_Number__c) > Integer.valueOf(sortedList[j].pax.Bag_Number__c)){
              temp = sortedList[j-1];
              sortedList[j-1] = sortedList[j];
              sortedList[j] = temp;
            }
          }
        }
        return sortedList;
   }
   
   private static Map<String, List<Passenger__c>> getMapModToPax(Tour_Instance_Itinerary__c recievedTII){
      
      //Creating a map between Tour Instance and child Tour Instance itenaries
      Map<Id, List<Tour_Instance_Itinerary__c>> mapTItoTII = new Map<Id, List<Tour_Instance_Itinerary__c>>();
      //Map depicting how many TII's are on a particular service date
      mapDateToTII = new Map<Date, List<Tour_Instance_Itinerary__c>>();
      //Map of Service Date to Day Number
      mapDateToDay = new Map<Date, Decimal>();
      
      Integer dayTII = integer.valueOf(recievedTII.day_number__c);
      
      //Retrieving related TII records
      for(Tour_Instance_Itinerary__c tii : [SELECT ID, Component_Type__c, Tour_Instance__c, TII_Data__c, 
                                            Day_Number__c, Service_Start_Date__c, Supplier__c,
                                            DR_Split__c, DR_Change_Of_MOD__c
                                            FROM Tour_Instance_Itinerary__c
                                            WHERE Supplier__c =: recievedTII.Supplier__c
                                            AND Tour_Instance__c =: recievedTII.Tour_Instance__c
                                            AND Component_Type__c = 'RoomingList'
                                            AND (Day_Number__c >=: dayTII-2 AND Day_Number__c <=: dayTII+2 )
                                            ORDER BY Day_Number__c]){
        if(tii.Tour_Instance__c != null){                                    
            if(mapTItoTII.get(tii.Tour_Instance__c) == null){
                mapTItoTII.put(tii.Tour_Instance__c , new List<Tour_Instance_Itinerary__c>());
            }
            mapTItoTII.get(tii.Tour_Instance__c).add(tii);
          }
        
        if(tii.Tour_Instance__c != null && tii.Service_Start_Date__c != null && tii.Day_Number__c != null){
          
          if(mapTItoTII.get(tii.Tour_Instance__c) == null){
                mapTItoTII.put(tii.Tour_Instance__c , new List<Tour_Instance_Itinerary__c>());
            }
            mapTItoTII.get(tii.Tour_Instance__c).add(tii);
            
            if(mapDateToTII.get(tii.Service_Start_Date__c) == null){
              mapDateToTII.put(tii.Service_Start_Date__c, new List<Tour_Instance_Itinerary__c>());
          }
          mapDateToTII.get(tii.Service_Start_Date__c).add(tii);
          
          if(mapDateToDay.get(tii.Service_Start_Date__c) == null){
              mapDateToDay.put(tii.Service_Start_Date__c, tii.Day_Number__c);
          }
        }
      }
      
      //Creating a Map of all Modules on a particular Service Date
      mapDatetoModules = new Map<Date, Set<String>>();
      //Set of All Modules, used in the Query on Passengers
      Set<String> allModules = new Set<String>();
      
      for(Date serviceDate : mapDateToTII.keySet()){
        for(Tour_Instance_Itinerary__c tiiRec : mapDateToTII.get(serviceDate)){
            TOPS_WrapperUtility.TIIData obj = TOPS_WrapperUtility.parseTIIData(tiiRec.TII_Data__c);
            if(mapDatetoModules.get(serviceDate) == null){
              mapDatetoModules.put(serviceDate, new Set<String>());
            }
            for(TOPS_WrapperUtility.Modules module : obj.modules){
              mapDatetoModules.get(serviceDate).add(module.Name);
              if(!allModules.contains(module.Name)){
                allModules.add(module.Name);
              }
            }
        }
      }
      //System.debug('mapDateToTII'+mapDateToTII);
      
      //Creating a Map of Modules to Passengers
      Map<String, List<Passenger__c>> mapModtoPax = new Map<String, List<Passenger__c>>();
      for(Passenger__c pax : [SELECT ID, Module_Code__c, Start_Date__c, End_Date__c,
                              Actual_Room_Type__c,Room_Type_Booked__c, Bag_Number__c, 
                              Room_Number__c, PAX_Timeline__c,Salutation__c, 
                              Family_Name__c, First_Name__c, Preferred_Name__c, 
                              Dietary_Requirements__c, Age__c, Room_Special_Instructions__c, 
                              Room_Near_Group__c, Passenger_Class__c, Room_Preference__c, V2_Status__c, Status__c//Added V2_Status__c, Status__c by Ankit Kungwani for case 00225679
                              FROM Passenger__c
                              WHERE Module_Code__c IN: allModules AND  Tour_Instance__c IN: mapTItoTII.keySet() AND (Status__c != 'CX' AND V2_Status__c != 'CX')//Modified By Ankit Kungwani for case 00225679 
                              ]){
        if(pax.Module_Code__c != null){      
          if(mapModtoPax.get(pax.Module_Code__c) == null){
            mapModtoPax.put(pax.Module_Code__c, new List<Passenger__c>());
          }
          mapModtoPax.get(pax.Module_Code__c).add(pax);
        }
      }
      
      //Handling cases where there was no Passenger for a particular Module
      for(String module : allModules){
        if(mapModtoPax.get(module) == null)
          mapModtoPax.put(module, new List<Passenger__c>());
      }
      System.debug('mapModtoPax'+mapModtoPax);
      return mapModtoPax;
   }


     public static List<TOPS_WrapperUtility.paxWrapper> getCrewOnDay(String theTourInstanceId, String theTourInstanceItineraryId){
        List<TOPS_WrapperUtility.paxWrapper> crewMem = new List<TOPS_WrapperUtility.paxWrapper>();
        Date serviceDate = [SELECT ID, Service_Start_Date__c FROM Tour_Instance_Itinerary__c WHERE ID = :theTourInstanceItineraryId].Service_Start_Date__c;
         
        for(Passenger__c pax : [SELECT Salutation__c, Family_Name__c, First_Name__c, Preferred_Name__c, 
                                Dietary_Requirements__c, Age__c, Room_Special_Instructions__c, 
                                Room_Near_Group__c, Actual_Room_ID__c, Bag_Number__c, Actual_Room_Type__c,
                                Passenger_Class__c, Room_Type_Booked__c, Room_Preference__c, PAX_Timeline__c 
                                FROM Passenger__c 
                                WHERE Tour_Instance__c = :theTourInstanceId
                                AND Status__c != 'CX' 
                                AND Passenger_Status__c != 'Deleted' 
                                AND Passenger_Class__c != null 
                                AND Passenger_Class__c != 'Passenger']){
        if(pax.PAX_Timeline__c != null && !String.isEmpty(pax.PAX_Timeline__c)){
          String jsonInput = pax.PAX_Timeline__c;
          Map<String, Object> timeline = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
          Map<String, Object> days = (Map<String, Object>)timeline.get('days');
          for(String day : days.keySet()){
            Map<String, Object> eachDay = (Map<String, Object>)days.get(day);
            //START- Added by Sajal for C-00226000
            String actualRoomIdString = String.valueOf(eachDay.get('Actual_Room_ID__c'));
            //END for C-00226000
            if(Integer.valueOf(day) == mapDateToDay.get(serviceDate)
                && eachDay.get('PAX_On_Tour') != null
                && eachDay.get('PAX_On_Tour') == true
                && eachDay.get('Actual_Room_Type__c')  != null
                && eachDay.get('Actual_Room_Type__c')  != ''
                && eachDay.get('Actual_Room_ID__c') != null
                && pax.Start_Date__c != null && pax.End_Date__c != null 
                && pax.Start_Date__c <= serviceDate  && pax.End_Date__c >= serviceDate){
                  // START- Modified by Sajal for C-00226000
                  //crewMem.add(new TOPS_WrapperUtility.paxWrapper(pax,Integer.valueOf(eachDay.get('Actual_Room_ID__c')),eachDay.get('Actual_Room_Type__c')+''));
                  crewMem.add(new TOPS_WrapperUtility.paxWrapper(pax, actualRoomIdString,eachDay.get('Actual_Room_Type__c')+''));
                  //END for C-00226000
            }
          }
        }
      }
      return crewMem;
    }
  /**
   * @description  Used to generate emails.
   *
   * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
   * @return       TOPS_EmailWrapper
   */
  public TOPS_EmailWrapper createEmailWrapper(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    emailToOA(request.Related_Object_Id__c);
    String defaultBody = TOPS_HotelEmailProcessor.mergeFields(request, configRecord);
    defaultBody.replace('\n', '<br/>');
    
      //Code changes done by Ravi Jain for Case - 00176851
      //Code Changes start here
       
    defaultBody.replace(' ', ' ');
      //Code changes end here
      
    PageReference emailPage = new PageReference('/apex/TOPS_Email' + '?data=' + EncodingUtil.urlEncode(defaultBody.unescapeHtml4(), 'UTF-8') + '&Brand='+brandName);
    String emailContent = Test.isRunningTest() ? 'Test Email Content' : emailPage.getContent().toString();
      //Added single line by ankit kungwani for case 00229261 on 14-05-2018
    emailContent = emailContent.replaceAll('%(?![0-9a-fA-F]{2})', '%25');
    String emailBody = EncodingUtil.urlDecode(emailContent, 'UTF-8');
    System.debug('emailBody ' + emailBody);

    fromEmail = '';
    String tdId;
    if(String.isNotBlank(tourInstanceId)) {
      for(Tour_Instance__c theRecord : [SELECT Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c FROM Tour_Instance__c
                                        WHERE Allocated_TD__c != null AND Id = :tourInstanceId]) {
        fromEmail = theRecord.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c;
        tdId = theRecord.Allocated_TD__c;
      }
    }

    if(request.Preview__c) {
      toEmail = fromEmail;
    } else {
      ccEmail = fromEmail;
    }
    
     // Start - Jai S-568616 - Parsing cc emails and sending email to these addresses as well - Aug 09,2018
      if(String.isNotBlank(request.Additional_Emails__c)) {
        Map<String,Object> additionalEmails = (Map<String, Object>)JSON.deserializeUntyped(request.Additional_Emails__c);
        if(additionalEmails.containsKey('cc')) {
          if(String.isNotBlank(ccEmail)) {
            ccEmail += ', ';
          } else {
            ccEmail = '' ;
          }
          ccEmail += (String)additionalEmails.get('cc');
        }
      }
      // End S-568616

    TOPS_EmailWrapper theEmailWrapper = new TOPS_EmailWrapper(
      toEmail,
      '',
      'Hotel Email',
      emailBody,
      null
    );
    theEmailWrapper.replyTo = fromEmail;
    theEmailWrapper.regionCode = regionCode;
    theEmailWrapper.tdId = tdId;
    theEmailWrapper.cc = ccEmail;
    theEmailWrapper.brand = brand;
    theEmailWrapper.emailSubject = getSubject(request.Related_Object_Id__c);
    return theEmailWrapper;
  }

  private static String getSubject(String tourInstanceItineraryId){
      //return [SELECT Hotel_Email_Subject__c FROM Tour_Instance_Itinerary__c WHERE Id =: tourInstanceItineraryId].Hotel_Email_Subject__c;
       // Code changes done by Ravi Jain for story S-428448
      // Code changes start here
      return [SELECT Hotel_Email_Subject__c FROM Tour_Instance_Itinerary__c WHERE Tour_Instance__c = : tourInstanceItineraryId OR Id =: tourInstanceItineraryId Limit 1].Hotel_Email_Subject__c;
     // Code changes end here
  }
  /**
   * @description  Used to process merge fields.
   *
   * @param        void
   * @return       void
   */
  public static String mergeFields(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    Map <String, String> fieldMapping = getFieldMapping(request);
    List <Passenger__c> passengerList = getPasserngerList(request); 
   
    String summaryOfRoomType = getSummaryOfRoomTypesNeeded(passengerList);
    String summaryOfDietaryNeeds = getSummaryOfDietaryNeeds(passengerList);
    system.debug('-------summaryOfRoomType------'+summaryOfRoomType);
    system.debug('-------summaryOfDietaryNeeds------'+summaryOfDietaryNeeds);

    fieldMapping.put(summaryOfRoomTypesNeededField, summaryOfRoomType);
    fieldMapping.put(summaryOfDietaryNeedsField, summaryOfDietaryNeeds);   
    String defaultBody = request.Data__c.replace('\n', '<br/>'); 
    defaultBody = defaultBody.replace(BrandMessage, fieldMapping.get(BrandMessage));
    defaultBody = defaultBody.replace(summaryOfRoomTypesNeededField, summaryOfRoomType);
    for (String field: fieldMapping.keyset()) {
      System.debug('field: ' + defaultBody);
      if (fieldMapping.get(field) != null) {
        defaultBody = defaultBody.replace(field, fieldMapping.get(field));
      } else {
        defaultBody = defaultBody.replace(field, '');
      }
    }

    /*
    if(String.isNotBlank(request.Data__c)) {
      defaultBody = defaultBody.replace(theApplicationDataField, request.Data__c);
    }
    defaultBody = request.Data__c;

    for (String field: fieldMapping.keyset()) {
      if (fieldMapping.get(field) != null) {
        defaultBody = defaultBody.replace(field, fieldMapping.get(field));
      } else {
        defaultBody = defaultBody.replace(field, '');
      }
    }
    */
    return defaultBody;
  }

  /**
   * @description  Used to get Passernger List
   * @param        void
   * @return       void
   */
  private static List < Passenger__c > getPasserngerList(Email_Print_Request__c request) {
     
    /*List < Passenger__c > passengerList = new List < Passenger__c > ([SELECT Id, Actual_Room_Type__c,
      Dietary_Requirements__c,
      Passenger_Class__c,
      Account__c, Account__r.Email__c, Account__r.PersonEmail, Actual_Room_ID__c
      FROM Passenger__c
      WHERE
        Tour_Instance__c = :tourInstanceId and
        Status__c != 'CX' and
        Passenger_Class__c != null and
        Passenger_Status__c != 'Deleted'
      ORDER BY Actual_Room_ID__c ASC
      LIMIT :MAX_RECORDS
    ]);*/
    
     Tour_Instance_Itinerary__c tiiReqRec = [SELECT ID, Tour_Instance__c,Tour_Instance__r.Allocated_TD__c, Supplier__c,
                                                Service_Start_Date__c , Day_Number__c 
                                                FROM Tour_Instance_Itinerary__c
                                                WHERE ID =: request.Related_Object_Id__c LIMIT 1];
     Map<String, List<Passenger__c>> mapModAllPAX = getMapModToPax(tiiReqRec);
    
      Set<Id> modPaxId = new Set<Id>();
      for(String mod : mapModAllPAX.keySet()){
          for(Passenger__c paxRec : mapModAllPAX.get(mod)){
              modPaxId.add(paxRec.Id);
          }
      }
      
       //Code changes done by Ravi Jain for Case - 00176851
       //Code Changes start here
        
      passengerListArray = new List < Passenger__c > ([SELECT Id, Actual_Room_Type__c,Salutation__c,
      Name,Family_Name__c, First_Name__c,Preferred_Name__c,Room_Special_Instructions__c,Dietary_Requirements__c,
      Passenger_Class__c,
      Account__c, Account__r.Email__c, Account__r.PersonEmail, Actual_Room_ID__c
      FROM Passenger__c
      WHERE
        Tour_Instance__c = :tourInstanceId and
        Id = :modPaxId and    //Changes to include valid passengers in email Not All
        Status__c != 'CX' and
        Passenger_Class__c != null and
        Passenger_Status__c != 'Deleted'
        ORDER BY Actual_Room_ID__c ASC
      LIMIT :MAX_RECORDS
    ]);
      
    //Code changes end here
    
    if (preview) {
        //Code changes done by Ravi Jain for Case - 00176851
       //Code Changes start here
 
      for (Passenger__c pass: passengerListArray) {
      //Code changes end here    
        if (pass.Passenger_Class__c == 'Tour Director' && pass.Account__c != null && pass.Account__r.PersonEmail != '') {
          toEmail = pass.Account__r.PersonEmail;
        }
        else if (pass.Passenger_Class__c == 'Tour Director' && pass.Account__c != null && pass.Account__r.Email__c != ''
                  && (pass.Account__r.PersonEmail == '' || pass.Account__r.PersonEmail == null)
                ) {
          toEmail = pass.Account__r.Email__c;
        }

      }
    }
    return passengerListArray;
  }

  /**
   * @description  Used to get Summary Of Dietary needs
   * @param        void
   * @return       void
   */
  private static String getSummaryOfDietaryNeeds(List < Passenger__c > passengerList) {
    String dietaryNeeds = '';
    Integer count = 0;
    Map < String, Integer > dietaryNeedsMap = new Map < String, Integer > ();
    for (Passenger__c pass: passengerList) {
      if (pass.Dietary_Requirements__c != null && pass.Dietary_Requirements__c != '') {
        if (!dietaryNeedsMap.containsKey(pass.Dietary_Requirements__c)) {
          dietaryNeedsMap.put(pass.Dietary_Requirements__c, 1);
        } else {
          count = dietaryNeedsMap.get(pass.Dietary_Requirements__c);
          count++;
          dietaryNeedsMap.put(pass.Dietary_Requirements__c, count);
        }
      }
    }

    for (String dietary: dietaryNeedsMap.keyset()) {
      dietaryNeeds += dietaryNeedsMap.get(dietary) + ' ' + dietary + '<br>';
    }

    return dietaryNeeds;
  }

  /**
  * @description  Used to get Summary Of Room Types Needed
  * @param        void
  * @return       void
  */
  private static String getSummaryOfRoomTypesNeeded(List<Passenger__c> passengerList) {
    final String PASSENGER_CLASS_PASSENGER = 'Passenger';
    final Set<String> ROOM_TYPE_SINGLES = new Set<String> { 'Single' };
    final Set<String> ROOM_TYPE_DOUBLES = new Set<String> { 'Double' };
    final Set<String> ROOM_TYPE_TWINS = new Set<String> { 'Twin', 'Twin Share' };
    final Set<String> ROOM_TYPE_TRIPLES = new Set<String> { 'Triple', 'Triple Share' };
    final Set<String> ROOM_TYPE_QUADS = new Set<String> { 'Quad', 'Quadruple', 'Quadruple Share' };

    Integer totalSingles, totalTwins, totalDoubles, totalTriples, totalQuads;
    totalSingles = totalTwins = totalDoubles = totalTriples = totalQuads = 0;
    Boolean hasDriver = false;
    String roomType = '';
    Map<Decimal, String> theRoomTypes = new Map<Decimal, String>();
    /*for(Passenger__c theRecord : passengerList) {
      roomType = String.isNotBlank(theRecord.Actual_Room_Type__c) ? theRecord.Actual_Room_Type__c.toLowerCase().capitalize() : '';

      // Determining Crew Members Room Types.
      if(String.isNotBlank(theRecord.Passenger_Class__c) &&
        !theRecord.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)
      ) {
        if (theRecord.Passenger_Class__c == 'Driver'){
          hasDriver = true;
        }
        if(ROOM_TYPE_SINGLES.contains(roomType)) {
          totalSingles++;
        }
        else if(ROOM_TYPE_DOUBLES.contains(roomType)) {
          totalDoubles++;
        }
        else if(ROOM_TYPE_TWINS.contains(roomType)) {
          totalTwins++;
        }
        else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
          totalTriples++;
        }
        else if(ROOM_TYPE_QUADS.contains(roomType)) {
          totalQuads++;
        }
      }
      // Determining Unique Passenger Room Types.
      else if(theRecord.Actual_Room_ID__c != null) {
        theRoomTypes.put(theRecord.Actual_Room_ID__c, roomType);
      }
    }*/


    // Determining Passenger Room Types.
    roomType = '';
    set<String> setActRoomids = new set<String>();
    for(String actRoomType : roomTypeToPaxWrapper.keySet()){
        for(TOPS_WrapperUtility.paxWrapper paxWrp : roomTypeToPaxWrapper.get(actRoomType)){
             if (paxWrp.pax.Passenger_Class__c == 'Driver'){
                  hasDriver = true;
            }
            String combsRmTypNum = actRoomType + '_' + paxWrp.roomNumber;
            if(setActRoomids.contains(combsRmTypNum)){
                continue;
            }
            roomType = paxWrp.roomType;
            setActRoomids.add(combsRmTypNum);
            
            if(ROOM_TYPE_SINGLES.contains(roomType)) {
              totalSingles++;
            }
            else if(ROOM_TYPE_DOUBLES.contains(roomType)) {
              totalDoubles++;
            }
            else if(ROOM_TYPE_TWINS.contains(roomType)) {
              totalTwins++;
            }
            else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
              totalTriples++;
            }
            else if(ROOM_TYPE_QUADS.contains(roomType)) {
              totalQuads++;
            }
            
        }
    }



    // AK FINAL CHANGES
    /*if(theRoomTypes.size() > 0) {
      for(Decimal actualRoomId : theRoomTypes.keySet()) {
        roomType = theRoomTypes.get(actualRoomId);
        if(ROOM_TYPE_SINGLES.contains(roomType)) {
          totalSingles++;
        }
        else if(ROOM_TYPE_DOUBLES.contains(roomType)) {
          totalDoubles++;
        }
        else if(ROOM_TYPE_TWINS.contains(roomType)) {
          totalTwins++;
        }
        else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
          totalTriples++;
        }
        else if(ROOM_TYPE_QUADS.contains(roomType)) {
          totalQuads++;
        }
      }
    }*/
      
      
    String roomsSummary = '';
    if(totalSingles > 0) roomsSummary += totalSingles + ' SINGLE rooms (including [TDroleName]' + (hasDriver ? ' & Driver)' : ')') + '<br>';
    if(totalDoubles > 0) roomsSummary += totalDoubles + ' DOUBLE (matrimonial/large bed) rooms <br/>';
    if(totalTwins > 0) roomsSummary += totalTwins + ' TWIN (separate beds) rooms <br/>';
    if(totalTriples > 0) roomsSummary += totalTriples + ' TRIPLE rooms<br/>';
    if(totalQuads > 0) roomsSummary += totalQuads + ' QUAD room<br/>';
    
    //Code changes done by Ravi Jain for Case - 00176851
    //Code Changes start here
    
    /*if(passengerListArray.size()>0)
    {
       roomsSummary +='<br/><br/>';
       roomsSummary +='Please note for our group the following special room instructions:'+'<br/><br/>';
       roomsSummary += '<table border="1" style="border-collapse:collapse;width: 600px;"><tr><th style="text-align:right;border-right: none;">Guest’s Name</th><th style="border-left: none;">  </th></tr>';

       for (Passenger__c pass: passengerListArray)
       {
          if(pass.Room_Special_Instructions__c != null)
        {
            if(pass.Salutation__c !=null)
            {
                if(pass.Preferred_Name__c != null)
               {
                     nameString = pass.Salutation__c+' '+pass.Family_Name__c+','+' '+pass.Preferred_Name__c;
                     roomsSummary += '<tr><td style="text-align: left; border-right: none;">' + nameString + '</td>';
               }
                else
                {
                     nameString = pass.Salutation__c+' '+pass.Family_Name__c+','+' '+pass.First_Name__c;
                     roomsSummary += '<tr><td style="text-align: left; border-right: none;">' + nameString + '</td>';
                }
            }
            else 
            {
               nameString = pass.Family_Name__c+','+' '+pass.First_Name__c;
               roomsSummary += '<tr><td style="text-align: left; border-right: none;">' + nameString + '</td>';
            }
            
          System.debug('pass.Room_Special_Instructions__c Value'+pass.Room_Special_Instructions__c);
          roomsSummary += '<td style="text-align: right; border-left: none;">' + pass.Room_Special_Instructions__c + '</td></tr>';
        }
       } 
        roomsSummary += '</table>';
    }*/
    // Code Changes end here  

    return roomsSummary;
  }

  /**
   * @description  Used to get field mapping
   * @param        void
   * @return       void
   */
  private static Map < String, String > getFieldMapping(Email_Print_Request__c request) {
    Map < String, String > fieldMapping = new Map < String, String > ();
    List < String > fields = getFields();
    for (String field: fields) {
      fieldMapping.put(field, '');
    }

    brandName = '';
    preview = request.Preview__c;
    List<User> listRequestCreators = [Select Id, Email from User where Id =:request.CreatedById]; //NB - 02/10 - Query the user email, to populate from Emaol

    /*for (Tour_Instance_Itinerary__c tour: [SELECT id, Tour_Instance__c, Tour_Instance__r.Allocated_TD__c, Tour_Instance__r.Allocated_TD__r.Email__c,
        Tour_Instance__r.Allocated_TD__r.Crew_Contact_Number_1__c, Tour_Instance__r.Allocated_TD__r.Hotel_Cover_Email_Signoff__c,
        Tour_Instance__r.Allocated_TD__r.Hotel_Cover_Email_Salutation__c,
        Tour_Instance__r.Allocated_TD__r.Name,
        Tour_Instance__r.Brand_Name__c, Tour_Instance__r.Brand__r.Name,
        Tour_Instance__r.Instance_Code__c, Tour_Instance__r.Operating_Product_Code__c, Supplier__c, Supplier__r.Reception_email__c,
        Supplier__r.PersonEmail,
        Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c,
        Name, Tour_Instance__r.Name,
        Tour_Instance__r.Tour_series__r.Name,
        Tour_Instance__r.Departure_Code__c
        FROM Tour_Instance_Itinerary__c WHERE Id = : request.Related_Object_Id__c OR Id = : tourInstanceId*/
        // Code changes done by Ravi Jain for story S-428448
       // Code changes start here
                                         
        for (Tour_Instance_Itinerary__c tour: [SELECT id, Tour_Instance__c, Tour_Instance__r.Allocated_TD__c, Tour_Instance__r.Allocated_TD__r.Email__c,
        Tour_Instance__r.Allocated_TD__r.Crew_Contact_Number_1__c, Tour_Instance__r.Allocated_TD__r.Hotel_Cover_Email_Signoff__c,
        Tour_Instance__r.Allocated_TD__r.Hotel_Cover_Email_Salutation__c,
        Tour_Instance__r.Allocated_TD__r.Name,
        Tour_Instance__r.Brand_Name__c, Tour_Instance__r.Brand__r.Name,
        Tour_Instance__r.Instance_Code__c, Tour_Instance__r.Operating_Product_Code__c, Supplier__c, Supplier__r.Reception_email__c,
        Supplier__r.PersonEmail,
        Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c,
        Name, Tour_Instance__r.Name,
        Tour_Instance__r.Tour_series__r.Name,
        Tour_Instance__r.Departure_Code__c
        FROM Tour_Instance_Itinerary__c WHERE (Id = : request.Related_Object_Id__c OR Tour_Instance__c = : request.Related_Object_Id__c) LIMIT 1
        // Code changes end here
        
      ]) {
      tourInstanceId = tour.Tour_Instance__c;

      System.debug('Tour Instance Product Code'+tour.Tour_Instance__r.Operating_Product_Code__c);
      if (tour.Tour_Instance__r.Operating_Product_Code__c != null) {
        if (tour.Tour_Instance__r.Operating_Product_Code__c.length() > 2) {
          String code = tour.Tour_Instance__r.Operating_Product_Code__c.subString(0, 2);
          Region_Code_Brand_Mapping__mdt regionMapping = getRegionCode(code);
          if (regionMapping != null) {
            regionCode = code;
            brandName = regionMapping.Brand__c;
            brand = brandName;
            fieldMapping.put(tourBrandName, brandName);
            fieldMapping.put(TDroleNameField, regionMapping.TD_Role_Name__c);
            fieldMapping.put(tourBrandName_TDroleNameField, brandName + ' ' + regionMapping.TD_Role_Name__c);
          }
        }
      }
      if (!preview && tour.Supplier__c != null && tour.Supplier__r.Reception_email__c != null) {//NB - 02/10 - Associated Account's email
        toEmail = tour.Supplier__r.Reception_email__c; //NB - 02/10
      }
      if (tour.Tour_Instance__r.Allocated_TD__c != null) {
        fieldMapping.put(TDhotelSalutation, tour.Tour_Instance__r.Allocated_TD__r.Hotel_Cover_Email_Salutation__c);
        fieldMapping.put(TDbusinessEmailAdr, tour.Tour_Instance__r.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c);
        fieldMapping.put(TDselectedContactNum, tour.Tour_Instance__r.Allocated_TD__r.Crew_Contact_Number_1__c);
        fieldMapping.put(TDhotelSignoff, tour.Tour_Instance__r.Allocated_TD__r.Hotel_Cover_Email_Signoff__c);
        fieldMapping.put(TDfullName, tour.Tour_Instance__r.Allocated_TD__r.Name);
        //fromEmail = tour.Tour_Instance__r.Allocated_TD__r.PersonEmail;
      }

      if (tour.Tour_Instance__r.Brand_Name__c != null) {
        fieldMapping.put(brandNameField, brandName);
      }
      if (tour.Tour_Instance__r.Operating_Product_Code__c != null) {
        fieldMapping.put(tourCode, tour.Tour_Instance__r.Operating_Product_Code__c);
      }
      if (tour.Tour_Instance__r.Operating_Product_Code__c != null) {
        fieldMapping.put(tourNametourCode, tour.Tour_Instance__r.Tour_series__r.Name + ' ' + tour.Tour_Instance__r.Operating_Product_Code__c + '/' + tour.Tour_Instance__r.Departure_Code__c);
      }
    }
    //NB - 02/10 - Populating from and to email fields as per the Chatter from Leo.
    if(listRequestCreators.size() > 0) {
      fromEmail = listRequestCreators.get(0).Email;
    }
    if(toEmail != null && request.Email_Addresses__c != null){
      toEmail = toEmail + ', '+ request.Email_Addresses__c;
    } else if (toEmail == null && request.Email_Addresses__c != null){
      toEmail = request.Email_Addresses__c;
    }

    Id recordTypeId = Schema.SObjectType.Account.getRecordtypeInfosByName().get('Brand').getRecordTypeId();
    for (Account a : [SELECT Name, Brand_Hotel_Message__c FROM Account WHERE Name LIKE :brandName + '%' AND recordTypeId =: recordTypeId limit 1]){
      System.debug('Account found for this brand: ' + a);
      fieldMapping.put(brandNameField, a.Name);
      fieldMapping.put(BrandMessage, + a.Brand_Hotel_Message__c);
    }


    system.debug('-------toEmail-------'+toEmail);
    System.debug('field mapping: ' + fieldMapping);
    return fieldMapping;
  }


  /**
   * @description  Used to get get Region Code mapping
   * @param        void
   * @return       void
   */
  private static Region_Code_Brand_Mapping__mdt getRegionCode(String code) {

    for (Region_Code_Brand_Mapping__mdt mapRec: [SELECT DeveloperName, Brand__c, TD_Role_Name__c
        FROM Region_Code_Brand_Mapping__mdt
        WHERE DeveloperName = : code
      ]) {
      return mapRec;
    }
    return null;
  }

  /**
   * @description  Used to get Fields
   * @param        void
   * @return       void
   */
  private static List < String > getFields() {

    List < String > fields = new List < String > {
      TDhotelSalutation,
      brandNameField,
      tourCode,
      TDbusinessEmailAdr,
      TDselectedContactNum,
      TDhotelSignoff,
      tourNametourCode,
      TDfullName,
      tourBrandName,
      TDroleNameField,
      summaryOfRoomTypesNeededField,
      summaryOfDietaryNeedsField,
      tourBrandName_TDroleNameField,
      BrandMessage
    };
        
    return fields;
  }
}