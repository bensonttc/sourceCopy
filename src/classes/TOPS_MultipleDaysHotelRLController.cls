//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_MultipleDaysHotelRLController
// Description: Used in .Multi Days PDF generation
//
// 2 Nov 2017          Neeraj Kumawat         #I-300408 Implmented Sorting based on Room Type and Bag Number
// 3 December          Neeraj Kumawat         #I-303234 Updated thehotelData Key with Room Number and Room Type
// 10th March, 2018    Ravi Jain              #T-676446 Remove the duplicate Bag Numbers

public class TOPS_MultipleDaysHotelRLController {
  
  // Private Constants.
  private final Integer MAX_RECORDS = 58;
  private final Set<String> ROOM_TYPE_SINGLES = new Set<String> { 'Single' };
  private final Set<String> ROOM_TYPE_DOUBLES = new Set<String> { 'Double' };
  private final Set<String> ROOM_TYPE_TWINS = new Set<String> { 'Twin', 'Twin Share' };
  private final Set<String> ROOM_TYPE_TRIPLES = new Set<String> { 'Triple', 'Triple Share' };
  private final Set<String> ROOM_TYPE_QUADS = new Set<String> { 'Quad', 'Quadruple', 'Quadruple Share' };
  private final String COMPONENT_TYPE_ITINERARY = 'Itinerary';
  private final String COMPONENT_TYPE_ROOMINGLIST = 'RoomingList';
  private final String PASSENGER_CLASS_PASSENGER = 'Passenger';
  private final String PASSENGER_CLASS_TOUR_DIRECTOR = 'Tour Director';
  private final String PASSENGER_CLASS_DRIVER = 'Driver';
  private final String PASSENGER_CLASS_COOK = 'Cook';
  private final String PASSENGER_CLASS_OSTM = 'OSTM';
  private final String PASSENGER_CLASS_NATIONAL_GUIDE = 'National Guide';
  private final Map<String, String> ROOM_TYPE_MAPPING = new Map<String, String> {
    'SIG' => 'Single',
    'TWN-DBL' => 'Double',
    'TWN-TWN' => 'Twin',
    'TWN' => 'Twin',
    'TWS' => 'Twin Share',
    'TRP' => 'Triple',
    'TRS' => 'Triple Share',
    'QAD' => 'Quadruple',
    'QDS' => 'Quadruple Share'
  };
  
  // Private Data Members.
  private String theTourInstanceId { get; set; }
  private String theTourInstanceItineraryId { get; set; }
  private String theTourInstanceRoomingId {get; set;}
  private String theRegionCode { get; set; }
  private String theBrandName { get; set; }
  private String theAbbreviatedRole { get; set; }
  private Tour_Instance_Itinerary__c tourRoomingRecord {get; set;}

  // Public Data Members.
  public String theLanguage { get; private set; }
  public String theRoomListTitle { get; private set; }
  //Changes Start,Done by Maksud Ali for Story : S-455965
  public List<StaticImageManager> theFooterLogoList { get; private set; }
  //End code.
  public List<BookedRoomWrapper> theBookedRoomsList { get; private set; }
  public String theItineraryName { get; private set; }
  public String theItineraryCode { get; private set; }
  public String theHotelName { get; private set; }
  
  public String tripCode { get; private set; }
  public String cityName { get; private set; }
  
  public Date theArrivalDate { get; private set; }
  public String theArrivalTime { get; private set; }
  public Integer totalRooms { get; private set; }
  public Integer totalSingles { get; private set; }
  public Integer totalTwins { get; private set; }
  public Integer totalDoubles { get; private set; }
  public Integer totalTriples { get; private set; }
  public Integer totalQuads { get; private set; }
  public Integer totalHotelGuests { get; private set; }
  public String matrimonialBeds { get; private set; }
  public String nearbyRooms { get; private set; }
  public Set<String> specialDiets { get; private set; }
  public Date firstColumnDate { get; private set; }
  public String firstColumnDinnerTime { get; private set; }
  public String firstColumnBaggageTime { get; private set; }
  public Date secondColumnDate { get; private set; }
  public String secondColumnWakeUpTime { get; private set; }
  public String secondColumnBaggageTime { get; private set; }
  public String secondColumnDepartTime { get; private set; }
  public String secondColumnBreakfastTime { get; private set; }
  public String secondColumnDinnerTime { get; private set; }
  public Date thirdColumnDate { get; private set; }
  public String thirdColumnWakeUpTime { get; private set; }
  public String thirdColumnBaggageTime { get; private set; }
  public String thirdColumnDepartTime { get; private set; }
  public String thirdColumnBreakfastTime { get; private set; }
  public String thirdColumnDinnerTime {get; private set;}
  public Date fourthColumnDate { get; private set; }
  public String fourthColumnWakeUpTime { get; private set; }
  public String fourthColumnBaggageTime { get; private set; }
  public String fourthColumnDepartTime { get; private set; }
  public String fourthColumnBreakfastTime { get; private set; }
  public String fourthColumnDinnerTime {get; private set; }
  public String theCrewDetails { get; private set; }
  public String theFontSize { get; private set; }
  public String tdPhoneNumber { get; private set; }
  public String sortType {get;set;}
  public Integer duration {get; set;}
  public String dur1 {get;set;}
  public String dur2 {get;set;}
  public String dur3 {get;set;}
  public String durationDates {get; set;}
  public String earliestArrivalDate {get;set;}
  public String changeOverDay {get; set;}
  public Integer changeOver {get; set;}
  String theGuestName;
  String theTourCrewMemberName;
  String specialDietRequestedGuestName;
  Map<String, BookedRoomWrapper> theHotelData = new Map<String, BookedRoomWrapper>();
  Map<String, SpecialDietaryRequirementsWrapper> theSpecialDietMapping = new Map<String, SpecialDietaryRequirementsWrapper>();
  Map<String, Set<String>> bagNumToDates = new Map<String, Set<String>>();
  // Code changes done by Ravi Jain for story S-455844  
  public String userLocale { get; private set; }  
  public String theFontSizeHotelName { get; private set; }

  public Map<Date, set<String>> mapDateToMods {get; set;}
  // Code changes done by Ravi Jain for story S-428448
  // Code changes start here
     
  public boolean isTourInstance = false ;
  // Code changes end here
  
  // Class Constructor.
  public TOPS_MultipleDaysHotelRLController () {
    try {
    
    // Code changes done by Ravi Jain for story S-428448
   // Code changes start here
  
     Map<String, String> parameters = ApexPages.currentPage().getParameters();
     Id relatedObjectId = (Id)parameters.get('relatedObjectId');
     if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance__c') {
         isTourInstance  = true ;
         theTourInstanceId = ApexPages.currentPage().getParameters().get('relatedObjectId');
     }else if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance_Itinerary__c') {
          isTourInstance  = false;
          // Extracting Tour Instance Itinerary Id From URL Parameter Named "relatedObjectId".
          theTourInstanceItineraryId = ApexPages.currentPage().getParameters().get('relatedObjectId');
          theTourInstanceRoomingId = ApexPages.currentPage().getParameters().get('relatedObjectId');
          TOPS_HotelEmailProcessor.emailToOA((ID)theTourInstanceItineraryId);
          mapDateToMods = TOPS_HotelEmailProcessor.mapDatetoModules;
          system.debug('TRACE: TOPS_HotelActivePassengerListCont - theTourInstanceItineraryId - ' + theTourInstanceItineraryId);
          theTourInstanceItineraryId = findFirstTII(theTourInstanceItineraryId);
     }
      sortType = TOPS_HotelEmailProcessor.sortType;
      getRegionCodeAndFooterLogoList();
      getBookedList();
      fillPassengerData();
      getPDFLanguage();
      //System.debug('theBookedRoom.theGuestNames.size'+theBookedRoom.theGuestNames.size);
      setTdPhoneNumber();
    }
    catch(Exception e) {
      system.debug('TRACE: TOPS_RoomListPDFController - TOPS_RoomListPDFController - Exception Message - ' + e.getMessage());
      system.debug('TRACE: TOPS_RoomListPDFController - TOPS_RoomListPDFController - Exception Stack Trace - ' + e.getStackTraceString());
    }
  }
  
  public void getBookedList(){
      if(String.isNotBlank(theTourInstanceItineraryId)) {
        Id theSupplierId = null;
        tourRoomingRecord = [SELECT Supplier__c, Tour_Instance__c, Day_Number__c, Supplier__r.Name, City__c, Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c, Arrival_Time__c, Start_Date_of_Service__c, Depart_Time__c,
                                                  Breakfast_time__c, Morning_Call_Time__c, Dinner_Time__c, Bags_Time__c FROM Tour_Instance_Itinerary__c WHERE Id = :theTourInstanceRoomingId];
        Integer dayTII = integer.valueOf(tourRoomingRecord.Day_Number__c);
        //for(Tour_Instance_Itinerary__c theRecord : [SELECT Tour_Instance__c, Supplier__r.Name, City__c, Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c, Arrival_Time__c, Start_Date_of_Service__c, Depart_Time__c,
        //                                          Breakfast_time__c, Morning_Call_Time__c, Dinner_Time__c, Bags_Time__c FROM Tour_Instance_Itinerary__c WHERE Id = :theTourInstanceItineraryId
        //                                          AND Component_Type__c = :COMPONENT_TYPE_ITINERARY]) {
        
        
        List<Tour_Instance_Itinerary__c> tourReservationTimes = [SELECT Tour_Instance__c, Supplier__r.Name, City__c, Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c, Arrival_Time__c, Start_Date_of_Service__c, Depart_Time__c,
                                                  Breakfast_time__c, Morning_Call_Time__c, Dinner_Time__c, Bags_Time__c FROM Tour_Instance_Itinerary__c 
                                                  WHERE Supplier__c =: tourRoomingRecord.Supplier__c
                                                  AND Tour_Instance__c =: tourRoomingRecord.Tour_Instance__c
                                                  AND Component_Type__c = 'RoomingList'
                                                  AND (Day_Number__c >=: dayTII-2 AND Day_Number__c <=: dayTII+2 )
                                                  ORDER BY Day_Number__c];
        for(Tour_Instance_Itinerary__c theRecord : tourReservationTimes) {
        
        theTourInstanceId = theRecord.Tour_Instance__c;
        theSupplierId = theRecord.Supplier__c;
        tripCode = theRecord.Operating_Product_Code__c + '-' + theRecord.Tour_Instance__r.Departure_Code__c;
        theHotelName = tourRoomingRecord.Supplier__r.Name;
        if(theHotelName.length() > 35)
            theFontSizeHotelName = '10px';
        else
            theFontSizeHotelName = '14px';
        cityName = theRecord.City__c;
        theArrivalTime = theRecord.Arrival_Time__c;
        theArrivalDate = theRecord.Start_Date_of_Service__c;
           
        // Code changes done by Ravi Jain for story S-455844                                  
        userLocale = UserInfo.getLocale(); 
                                                      
        firstColumnBaggageTime = theArrivalTime;

        firstColumnDate = theArrivalDate;
        firstColumnDinnerTime = theRecord.Dinner_Time__c;
        secondColumnBreakfastTime = theRecord.Breakfast_time__c;
        secondColumnWakeUpTime = theRecord.Morning_Call_Time__c;
        secondColumnBaggageTime = theRecord.Bags_Time__c;
        secondColumnDepartTime = theRecord.Depart_Time__c;
        secondColumnDate = theArrivalDate.addDays(1);
        
        break;
        system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - Tour Instance Itinerary Record - ' + theRecord);
      }

      // Determining Reserve Times For Second And Third Day.
      if(theSupplierId != null && String.isNotBlank(theTourInstanceId)) {
        Integer counter = -1;
        //for(Tour_Instance_Itinerary__c theRecord : [SELECT Morning_Call_Time__c, Bags_Time__c, Depart_Time__c, Breakfast_time__c, Start_Date_of_Service__c,
        //                                            Dinner_Time__c FROM Tour_Instance_Itinerary__c WHERE Supplier__c = :theSupplierId AND
        //                                            Tour_Instance__c = :theTourInstanceId AND Component_Type__c = :COMPONENT_TYPE_ITINERARY
        //                                            AND Id != :theTourInstanceItineraryId ORDER By Day_Number__c ASC LIMIT 2]) {
        
        
        for(Tour_Instance_Itinerary__c theRecord : tourReservationTimes) {
          if(counter == -1) {
              counter++;
              continue;
          }
          if(counter == 0) {

            secondColumnDinnerTime = theRecord.Dinner_Time__c;
            thirdColumnBreakfastTime = theRecord.Breakfast_time__c;
            thirdColumnWakeUpTime = theRecord.Morning_Call_Time__c;
            thirdColumnBaggageTime = theRecord.Bags_Time__c;
            thirdColumnDinnerTime = theRecord.Dinner_Time__c;
            thirdColumnDepartTime = theRecord.Depart_Time__c;
            thirdColumnDate = theArrivalDate.addDays(2);
          }
          if (counter == 1) {
            thirdColumnDinnerTime = theRecord.Dinner_Time__c;
            fourthColumnBreakfastTime = theRecord.Breakfast_time__c;
            fourthColumnWakeUpTime = theRecord.Morning_Call_Time__c;
            fourthColumnBaggageTime = theRecord.Bags_Time__c;
            fourthColumnDinnerTime = theRecord.Dinner_Time__c;
            fourthColumnDepartTime = theRecord.Depart_Time__c;
            fourthColumnDate = theArrivalDate.addDays(3);

          } else {
            fourthColumnDinnerTime = theRecord.Dinner_Time__c;
          }
          counter++;
        }
      }
    }
  }
  public List<String> theCrewMemberDetails;
  public Map<String, List<String>> CREW_MEMBERS_RANKING;
  public Set<String> theCrewMembers;
  public Map<Integer, BookedRoomWrapper> theCrewMembersMapping;
  public void crewData(){
    // Building Hotel Guest Data.
    theCrewMemberDetails = null;
    CREW_MEMBERS_RANKING = new Map<String, List<String>> {
      PASSENGER_CLASS_TOUR_DIRECTOR => new List<String> { '1', theAbbreviatedRole },
      PASSENGER_CLASS_DRIVER => new List<String> { '2', 'DR' },
      PASSENGER_CLASS_COOK => new List<String> { '3', 'Cook' },
      PASSENGER_CLASS_OSTM => new List<String> { '4', 'OSTM' },
      PASSENGER_CLASS_NATIONAL_GUIDE => new List<String> { '5', 'NG' }
    };

    theCrewMembers = new Set<String>();
    theCrewMembersMapping = new Map<Integer, BookedRoomWrapper>();
  }
  
  public void fillPassengerData(){
      crewData();  
      changeOver = 0;
      List<Date> allDates = new List<Date>();
      allDates.addAll(TOPS_HotelEmailProcessor.mapDatetoModules.keySet());
      system.debug('allDates>>>>' +allDates);
      allDates.sort();
      duration = allDates.size();
      system.debug('duration>>>>' +duration);
      //system.assertEquals(duration, 0);
      
      List<TOPS_WrapperUtility.paxWrapper> day1Pax = new List<TOPS_WrapperUtility.paxWrapper>();
      List<TOPS_WrapperUtility.paxWrapper> day2Pax = new List<TOPS_WrapperUtility.paxWrapper>();
      List<TOPS_WrapperUtility.paxWrapper> day3Pax = new List<TOPS_WrapperUtility.paxWrapper>();
      
      Set<ID> day1PaxID = new Set<ID>();
      Set<ID> day2PaxID = new Set<ID>();
      Set<ID> day3PaxID = new Set<ID>();
      if(!allDates.isEmpty())
      for(String roomType: TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(allDates[0]).keySet()){
            day1Pax.addAll(TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(allDates[0]).get(roomType));          
      }
      day1PaxID = makeIDSet(day1Pax);
      
      //Fill GuestNames with Day 1 Pax
      if(!allDates.isEmpty()){
      earliestArrivalDate = String.valueOf(allDates[0].format())+'';
      dur1 = String.valueOf(allDates[0].format())+'';
      }
        for(TOPS_WrapperUtility.paxWrapper theRecord : day1Pax){
        System.debug('Day 1 Pax Value'+' '+theRecord.pax.Bag_Number__c);
        fillTheHotelDataForNewPax(theRecord);
        //Add the PAX TO GN
        if(theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER))
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theGuestNames.add(theGuestName);
      }
      System.debug('Duration Value'+' '+duration);
      if(duration > 1){
          for(String roomType: TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(allDates[1]).keySet()){
                day2Pax.addAll(TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(allDates[1]).get(roomType));          
          }
          day2PaxID = makeIDSet(day2Pax);
          if(areSetSame(day1PaxID,day2PaxID)){
              dur1 += ', '+String.valueOf(allDates[1].format());
          }
          else{
              dur2 = String.valueOf(allDates[1].format())+'';
              changeOver = 2;
              for(TOPS_WrapperUtility.paxWrapper theRecord : day2Pax){
              
              // Code commented amd changes done by Ravi Jain for task T-676446
               //if(!theHotelData.containsKey(theRecord.roomNumber+theRecord.roomType)){
               // fillTheHotelDataForNewPax(theRecord);
               // Start - Ravi Jain - T-676446 - 10th March, 2018 - Check on the basis of bag numbers
               if(!theHotelData.containsKey(theRecord.pax.Bag_Number__c))
                  {
                  fillTheHotelDataForNewPax(theRecord);
                }
                // End - Ravi Jain - T-676446 - 10th March, 2018
                 
                else{
                       // Determining Guest Names.
                       theGuestName = (String.isNotBlank(theRecord.pax.Salutation__c) ? theRecord.pax.Salutation__c.capitalize() + ' ' : '') +
                                      (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                                      (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                       String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');
            
                       // Determining Guest Age.
                       if(theRecord.pax.Age__c <= 18) {
                         theGuestName += ' (Age ' + String.valueOf(theRecord.pax.Age__c) + ')';
                       }
                }   
                system.debug('AK - ' + theRecord.pax.Passenger_Class__c + ' ARM : ' + theRecord.roomNumber + ' RM - ' + theGuestName);
                    
                //Add the PAX TO GN1
                if(theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)){
                    theHotelData.get(theRecord.roomNumber+theRecord.roomType).theGuestNames1.add(theGuestName);
                }else{
                    setCrewDetails(theRecord,1);
                
                }
              }      
          }
      }
      
      if(duration == 3){
          for(String roomType: TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(allDates[2]).keySet()){
                day3Pax.addAll(TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(allDates[2]).get(roomType));          
          }
          day3PaxID = makeIDSet(day3Pax);
          if(areSetSame(day2PaxID,day3PaxID)){
              if(dur1.contains(allDates[1].format()+''))
                dur1 += ', '+String.valueOf(allDates[2].format());
              else{
                  dur2 += ', '+String.valueOf(allDates[2].format());
              }
          }
          else{
              if(dur1.contains(allDates[1].format()+'')){
                  dur2 = String.valueOf(allDates[2].format())+'';
                  changeOver = 2;
                  for(TOPS_WrapperUtility.paxWrapper theRecord : day3Pax){
                  
                  // Code commented amd changes done by Ravi Jain for task T-676446
                  //if(!theHotelData.containsKey(theRecord.roomNumber+theRecord.roomType)){
                  //fillTheHotelDataForNewPax(theRecord);
                  // Start - Ravi Jain - T-676446 - 10th March, 2018 - Check on the basis of bag numbers
                  if(!theHotelData.containsKey(theRecord.pax.Bag_Number__c))
                  {
                  fillTheHotelDataForNewPax(theRecord);
                    }
                    // End - Ravi Jain - T-676446 - 10th March, 2018
                    
                    else{
                       // Determining Guest Names.
                       theGuestName = (String.isNotBlank(theRecord.pax.Salutation__c) ? theRecord.pax.Salutation__c.capitalize() + ' ' : '') +
                                      (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                                      (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                       String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');
            
                       // Determining Guest Age.
                       if(theRecord.pax.Age__c <= 18) {
                         theGuestName += ' (Age ' + String.valueOf(theRecord.pax.Age__c) + ')';
                       }
                    }
                    
                    //Add the PAX TO GN1
                    if(theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)){
                        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theGuestNames1.add(theGuestName);
                        }else{
                    setCrewDetails(theRecord,1);
                    }
                  }     
              }
              else{
                  dur3 = String.valueOf(allDates[2].format())+'';
                  changeOver = 3;
                  for(TOPS_WrapperUtility.paxWrapper theRecord : day3Pax){
                  
                  // Code commented amd changes done by Ravi Jain for task T-676446
                  //if(!theHotelData.containsKey(theRecord.roomNumber+theRecord.roomType)){
                  //fillTheHotelDataForNewPax(theRecord);
                  // Start - Ravi Jain - T-676446 - 10th March, 2018 - Check on the basis of bag numbers
                  if(!theHotelData.containsKey(theRecord.pax.Bag_Number__c))
                  {
                  fillTheHotelDataForNewPax(theRecord);
                    }
                  // End - Ravi Jain - T-676446 - 10th March, 2018
                    
                    else{
                       // Determining Guest Names.
                       theGuestName = (String.isNotBlank(theRecord.pax.Salutation__c) ? theRecord.pax.Salutation__c.capitalize() + ' ' : '') +
                                      (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                                      (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                       String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');
            
                       // Determining Guest Age.
                       if(theRecord.pax.Age__c <= 18) {
                         theGuestName += ' (Age ' + String.valueOf(theRecord.pax.Age__c) + ')';
                       }
                    }
                    //Add the PAX TO GN1
                    if(theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)){
                        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theGuestNames2.add(theGuestName);
                        }else{
                    setCrewDetails(theRecord,2);
                    }
                  }
              }
          }
      }
      // Determining Total Rooms.
    //System.assert(false, theCrewMembers);
    totalRooms = theHotelData.size();

    // Determining Total Hotel Guests.
    //totalHotelGuests = theGuests.size();
    day1PaxID.addAll(day2PaxID);
    day1PaxID.addAll(day3PaxID);
    totalHotelGuests = day1PaxID.size();
    // Determining Font Size.
    //Start Changes done by Maksud Ali. for story : S-428444 Date :19-Aug-2016
    //Start Changes done by Maksud Ali. suggest by client (Calvin Goodenough) for story : S-428444 Date :26-Aug-2016
    
    
    if(totalHotelGuests >=  56 && totalHotelGuests <= 58) {
      theFontSize = '8pt';
    }
    else if(totalHotelGuests >= 51 && totalHotelGuests <= 55) {
      theFontSize = '8.5pt';
    }
    else if(totalHotelGuests >= 43 && totalHotelGuests <= 50) {
      theFontSize = '9pt';
    }
    
    if(dur1 != null){    //if(duration == 1){
        theFontSize = '10.5pt';
    }   
    if(dur2 != null){    //if(duration == 2){
        theFontSize = '8pt';
    }
    if(dur3 != null){   //if(duration == 3){
        theFontSize = '6pt';
    }
    
    If(dur1 != null && (dur2 == null && dur3 == null)){
          durationDates = dur1;
          dur1 = System.label.Guest_s_Name;
          
          if(totalHotelGuests >=  56 && totalHotelGuests <= 58) {
              theFontSize = '8pt';
          }
          else if(totalHotelGuests >= 51 && totalHotelGuests <= 55) {
              theFontSize = '8.5pt';
          }
          else if(totalHotelGuests >= 43 && totalHotelGuests <= 50) {
              theFontSize = '9pt';
          }
          
      }
   
    //End for story : S-428444 Date :19-Aug-2016, 26-Aug-2016
 
    // Determining Total Singles, Twins, Triples And Quads.
    totalSingles = 0;
    totalTwins = 0;
    totalDoubles = 0;
    totalTriples = 0;
    totalQuads = 0;
    matrimonialBeds = '';
    String roomType;
    String theNearbyRoomSymbol;
    Map<String, Set<String>> theNearbyRoomsMapping = new Map<String, Set<String>>();
    for(String roomNumber : theHotelData.keySet()) {
      // Processing Room Types.
      roomType = theHotelData.get(roomNumber).theRoomType;
      if(String.isNotBlank(roomType)) {
        if(ROOM_TYPE_SINGLES.contains(roomType)) {
          totalSingles++;
        }
        else if(ROOM_TYPE_DOUBLES.contains(roomType) || ROOM_TYPE_TWINS.contains(roomType)) {
          if(ROOM_TYPE_DOUBLES.contains(roomType)) {
            // Determining Matrimonial Beds.
            for(String theMatrimonialBed : theHotelData.get(roomNumber).theBagNumbers) {
              matrimonialBeds += theMatrimonialBed + '/';
            }
            matrimonialBeds = matrimonialBeds.subString(0, matrimonialBeds.length() - 1) + ', ';

            totalDoubles++;
          }
          totalTwins++;
        }
        else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
          totalTriples++;
        }
        else if(ROOM_TYPE_QUADS.contains(roomType)) {
          totalQuads++;
        }
      }

      // Processing Nearby Room Symbols.
      theNearbyRoomSymbol = theHotelData.get(roomNumber).theNearbyRoomSymbol;
      if(String.isNotBlank(theNearbyRoomSymbol)) {
        if(!theNearbyRoomsMapping.containsKey(theNearbyRoomSymbol)) {
          theNearbyRoomsMapping.put(
            theNearbyRoomSymbol,
            new Set<String>()
          );
        }
        theNearbyRoomsMapping.get(theNearbyRoomSymbol).add(roomNumber);
      }
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theNearbyRoomsMapping - ' + theNearbyRoomsMapping);

    if(matrimonialBeds.length() > 0) {
      matrimonialBeds = matrimonialBeds.subString(0, matrimonialBeds.length() - 2);
    }

    // Determining Nearby Rooms.
    nearbyRooms = '';
    String nearbyRoomBagNumbers = '';
    List<String> theBagNumbers = null;
    if(theNearbyRoomsMapping.size() > 0) {
      for(String nearbyRoomSymbol : theNearbyRoomsMapping.keySet()) {
        nearbyRooms += '(';
        for(String theRoomNumber : theNearbyRoomsMapping.get(nearbyRoomSymbol)) {
          if(theHotelData.containsKey(theRoomNumber)) {
            theBagNumbers = theHotelData.get(theRoomNumber).theBagNumbers;
            nearbyRoomBagNumbers = String.join(theBagNumbers, '/');
            nearbyRooms += nearbyRoomBagNumbers + ' & ';
          }
        }
        nearbyRooms = nearbyRooms.subString(0, nearbyRooms.length() - 3);
        nearbyRooms += ')-' + nearbyRoomSymbol + ' ';
      }
      nearbyRooms = nearbyRooms.subString(0, nearbyRooms.length() - 1);
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - nearbyRooms - ' + nearbyRooms);

    // Determining Special Dietary Requirements.
    specialDiets = new Set<String>();
    if(theSpecialDietMapping.size() > 0) {
      String theSpecialDietDataString;
      for(String theSpecialDietName : theSpecialDietMapping.keySet()) {
        theSpecialDietDataString = String.valueOf(theSpecialDietMapping.get(theSpecialDietName).theTotalCount) + ' x ' + theSpecialDietName + ' (';
        for(String theGuestFullName : theSpecialDietMapping.get(theSpecialDietName).theGuestNames) {
          theSpecialDietDataString += theGuestFullName + ', ';
        }
        theSpecialDietDataString = theSpecialDietDataString.subString(0, theSpecialDietDataString.length() - 2) + ')';
        specialDiets.add(theSpecialDietDataString);
      }
    }

    // Initializing Booked Rooms List.
    theBookedRoomsList = new List<BookedRoomWrapper>();

    // Integrating Tour Crew Members Information.
    BookedRoomWrapper theBookedRoomWrapperInstance = null;
    for(Integer index = 1;index <= 5;index++) {
      if(theCrewMembersMapping.containsKey(index)) {
        theBookedRoomWrapperInstance = theCrewMembersMapping.get(index);
        theBookedRoomsList.add(theBookedRoomWrapperInstance);

        // Processing Room Types.
        roomType = theBookedRoomWrapperInstance.theRoomType;
        if(String.isNotBlank(roomType)) {
          if(ROOM_TYPE_SINGLES.contains(roomType)) {
            totalSingles++;
          }
          else if(ROOM_TYPE_DOUBLES.contains(roomType) || ROOM_TYPE_TWINS.contains(roomType)) {
            if(ROOM_TYPE_DOUBLES.contains(roomType)) {
              totalDoubles++;
            }
            totalTwins++;
          }
          else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
            totalTriples++;
          }
          else if(ROOM_TYPE_QUADS.contains(roomType)) {
            totalQuads++;
          }
        }
        //totalRooms++;
      }
    }
    
    // Sorting Actual Room Ids.
    Set<String> actualRoomIds = theHotelData.keySet();
    List<String> theActualRoomIds = new List<String>();
    theActualRoomIds.addAll(actualRoomIds);
    theActualRoomIds.sort();
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theActualRoomIds - ' + theActualRoomIds);

    // Integrating Tour Passengers Information.
    for(String theActualRoomId : theActualRoomIds) {
      theBookedRoomsList.add(theHotelData.get(theActualRoomId));
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theBookedRoomsList - ' + theBookedRoomsList);

   //Sorting Booked Room list based on sort Type
    if(sortType != '' && sortType == 'By Room Type'){
      sortByBookedRoomType();
      // Categorizing Booked Room List By Room Type.
      categorizeBookedRoomListByRoomType();
    }else if(sortType != '' && sortType == 'By Bag Number'){
        sortByBagNumber();
    }
   // totalHotelGuests = totalSingles - theCrewMembers.size() + totalTwins * 2 + totalTriples * 3 + totalQuads * 4;
  }
  
  
  
  public void setCrewDetails(TOPS_WrapperUtility.paxWrapper theRecord , integer GuestVal){
  if(!theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)) {
        if(CREW_MEMBERS_RANKING.containsKey(theRecord.pax.Passenger_Class__c)) {
          theCrewMemberDetails = CREW_MEMBERS_RANKING.get(theRecord.pax.Passenger_Class__c);

          // Determining Tour Crew Member Name.
          theTourCrewMemberName = (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                                  (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                   String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');
            // Code commented and changes done by Ravi Jain for case 00176851
          // Code changes start here 
          if(GuestVal == 1){
              //START: Commented by Sajal for C-00227488
              //theCrewMembersMapping.get(Integer.valueOf(theCrewMemberDetails.get(0))).theGuestNames1.add(theGuestName);
              //END for C-00227488
          }
          
          if(GuestVal == 2){
          //START: Commented by Sajal for C-00227488
          //theCrewMembersMapping.get(Integer.valueOf(theCrewMemberDetails.get(0))).theGuestNames2.add(theGuestName);
          //END for C-00227488
          }
         
          
          // Code changes end here
          theCrewMembers.add(theCrewMemberDetails.get(1));
        }
      }
  }
  
  
  
  
  public Boolean areSetSame(Set<ID> set1, Set<ID> set2){
      if(set1.size() == set2.size()){
          if(set1.containsAll(set2))
            return true;
          else
            return false;
      }
      return false;
  }
  public void fillTheHotelDataForNewPax(TOPS_WrapperUtility.paxWrapper theRecord){
      System.debug('theRecord Value>>>>'+theRecord.pax + ' :::: '+ theRecord.pax.Bag_Number__c);
      String theRoomTypeBooked = '';
      // Determining Room Type Booked.
      theRoomTypeBooked = theRecord.roomType;
      
      if(theRecord.pax.Bag_Number__c.contains('-1'))
        {
           theRecord.pax.Bag_Number__c = ''; 
        }
      if(!theHotelData.containsKey(theRecord.roomNumber+theRecord.roomType)) {
          theHotelData.put(theRecord.roomNumber+theRecord.roomType, new BookedRoomWrapper(
            '',
            new List<String>(),
            new List<String>(),
            new List<String>(),
            new List<String>(),
            new List<String>(),
            '',
            false
          ));
        }
        if(!theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)) {
        if(CREW_MEMBERS_RANKING.containsKey(theRecord.pax.Passenger_Class__c)) {
          theCrewMemberDetails = CREW_MEMBERS_RANKING.get(theRecord.pax.Passenger_Class__c);

          // Determining Tour Crew Member Name.
          theTourCrewMemberName = (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                                  (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                   String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');
            // Code commented and changes done by Ravi Jain for case 00176851
          // Code changes start here 
          
          theCrewMembersMapping.put(
            Integer.valueOf(theCrewMemberDetails.get(0)),
            new BookedRoomWrapper(
              theRoomTypeBooked,
              new List<String> {
                theCrewMemberDetails.get(1)
              },
              new List<String> {
                theTourCrewMemberName
              },
              
              //START: Modified by Sajal for C-00227488
              new List<String>{ 
                  theTourCrewMemberName
              } ,
              new List<String>{ 
                  theTourCrewMemberName 
              },
              
             //END for C-00227488
             
              new List<String> {
                theRecord.pax.Room_Special_Instructions__c
              },
              theRecord.pax.Room_Near_Group__c,
              false
            )
          );
          
         
          // Code changes end here
          theCrewMembers.add(theCrewMemberDetails.get(1));
        }
      }
      else if(theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)){
      
          System.debug('Padmesh :::::'+ theRecord.pax.Bag_Number__c);
        // Determining Room Type.
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theRoomType = theRoomTypeBooked;
        // Determining Bag Number.
        if(!theHotelData.containsKey(theRecord.pax.Bag_Number__c))
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers.add(theRecord.pax.Bag_Number__c);
        else
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers.add('');
            
        // Code changes done by Ravi Jain for task T-676446
        // Start - Ravi Jain - T-676446 - 10th March, 2018 - Remove the duplicate bag numbers  
        Set<String> setBagNumbers = new Set<String>();
        setBagNumbers.addAll(theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers);
        
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers = new List<String>();
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers.addAll(setBagNumbers);
        // End - Ravi Jain - T-676446 - 10th March, 2018
        
        // Determining Nearby Room Symbol.
        if(String.isBlank(theHotelData.get(theRecord.roomNumber+theRecord.roomType).theNearbyRoomSymbol)) {
          //theHotelData.get(theRecord.roomNumber).theNearbyRoomSymbol = theRecord.roomNumber+'';
          theHotelData.get(theRecord.roomNumber+theRecord.roomType).theNearbyRoomSymbol =
            String.isNotBlank(theRecord.pax.Room_Near_Group__c) ? theRecord.pax.Room_Near_Group__c.toUpperCase() : '';
        }
        // Determining Guest Names.
        theGuestName = (String.isNotBlank(theRecord.pax.Salutation__c) ? theRecord.pax.Salutation__c.capitalize() + ' ' : '') +
                       (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                       (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                        String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');
        // Determining Guest Age.
        if(theRecord.pax.Age__c <= 18) {
          theGuestName += ' (Age ' + String.valueOf(theRecord.pax.Age__c) + ')';
        }
        
        String specialInst = theRecord.pax.Room_Special_Instructions__c == null ? '' : theRecord.pax.Room_Special_Instructions__c;
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theRoomSpecialInstructions.add(specialInst);
      }
      // Determining Special Diets.
      if(String.isNotBlank(theRecord.pax.Dietary_Requirements__c)) {
        if(!theSpecialDietMapping.containsKey(theRecord.pax.Dietary_Requirements__c)) {
          theSpecialDietMapping.put(
            theRecord.pax.Dietary_Requirements__c,
            new SpecialDietaryRequirementsWrapper(
              0,
              new Set<String>()
            )
          );
        }

        // Determining Total Special Diets Count.
          theSpecialDietMapping.get(theRecord.pax.Dietary_Requirements__c).theTotalCount =
          theSpecialDietMapping.get(theRecord.pax.Dietary_Requirements__c).theTotalCount + 1;

        // Determining Special Diet Requested Guest Name.
        /*specialDietRequestedGuestName = (String.isNotBlank(theRecord.Preferred_Name__c) ? theRecord.Preferred_Name__c.capitalize() + ' ' : '') +
                                        (String.isNotBlank(theRecord.Family_Name__c) ? theRecord.Family_Name__c.substring(0, 1).toUpperCase() : '');
         theSpecialDietMapping.get(theRecord.Dietary_Requirements__c).theGuestNames.add(specialDietRequestedGuestName); */ 
          
        /* Code commented and changes done by Ravi Jain for story S-443720 */
        /* Code changes start here*/
          
        specialDietRequestedGuestName = (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                         String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '') + (' ') +
                                        (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.substring(0, 1).toUpperCase() : '');
        theSpecialDietMapping.get(theRecord.pax.Dietary_Requirements__c).theGuestNames.add(specialDietRequestedGuestName);  
        /* Code changes end here */ 
      }
  }
  public static Set<ID> makeIDSet(List<TOPS_WrapperUtility.paxWrapper> paxWrapper){
      Set<ID> paxID = new Set<ID>();
      for(TOPS_WrapperUtility.paxWrapper p : paxWrapper){
          paxID.add(p.pax.ID);                
      }
      return paxID;
  }
  
  // AK : 26/10 : Additional Changes to remove supplier from query.
  // Issue (I-299488) : Multiple Rooming List for a day cause Supplier Search issue in Itinerary Type Record
  // FIX : Updates the return query by adding day number instead of Supplier.
  public Id findFirstTII(Id theTourInstanceItineraryId)
  // Code changes end here
  {
      // add select to find the Tour Instance so the we get the correct TII in the final step
    Tour_instance_Itinerary__C tourInstanceID = [SELECT Tour_Instance__C , Day_Number__c from Tour_instance_Itinerary__C WHERE
                        id =:theTourInstanceItineraryID];
       
    return [SELECT Id FROM Tour_Instance_Itinerary__c WHERE Day_Number__c =: tourInstanceID.Day_Number__c AND Component_Type__c = :COMPONENT_TYPE_ITINERARY  AND Tour_instance__C = :tourInstanceID.Tour_Instance__C
            order by Day_Number__c asc limit 1].Id;
  }

  // Booked Room Wrapper Class.
  public class BookedRoomWrapper {
    public String theRoomType { get; private set; }
    public List<String> theBagNumbers { get; private set; }
    public List<String> theGuestNames { get; private set; }
    public List<String> theGuestNames1 { get; private set; }
    public List<String> theGuestNames2 { get; private set; }
    //theBagNumber is used in sorting the room based on bag number
    public Integer theBagNumber { get; private set; }
    //public String theRoomSpecialInstructions { get; private set; }
    // Code commented and changes done by Ravi Jain for case 00176851
    // Code changes start here
    
    public List<String> theRoomSpecialInstructions { get; private set; }
    // Code changes end here
    
    public String theNearbyRoomSymbol { get; private set; }
    public Boolean isBlankRow { get; private set; }

    // Wrapper Class Parameterized Constructor.
    public BookedRoomWrapper(
      String roomType,
      List<String> bagNumbers,
      List<String> guestNames,
      List<String> guestNames1,
      List<String> guestNames2,
      //String roomSpecialInstructions,
      // Code commented and changes done by Ravi Jain for case 00176851
     // Code changes start here
     
      List<String> roomSpecialInstructions,
      // Code changes end here
      
      String nearbyRoomSymbol,
      Boolean isBlank
    ) {
      theRoomType = roomType;
      theBagNumbers = bagNumbers;
      theGuestNames = guestNames;
      theGuestNames1 = guestNames1;
      theGuestNames2 = guestNames2;
      theRoomSpecialInstructions = roomSpecialInstructions;
      theNearbyRoomSymbol = nearbyRoomSymbol;
      isBlankRow = isBlank;
    }
  }

  // Special Dietary Requirements Wrapper Class.
  private class SpecialDietaryRequirementsWrapper {
    private Integer theTotalCount { get; set; }
    private Set<String> theGuestNames { get; set; }

    // Wrapper Class Parameterized Constructor.
    public SpecialDietaryRequirementsWrapper(Integer totalCount, Set<String> guestNames) {
      theTotalCount = totalCount;
      theGuestNames = guestNames;
    }
  }

  /**
  * @description  This method is used to fetch all booked rooms data for the tour instance Id passed as the URL parameter.
  *
  * @param        void
  * @return       void
  */
    
 // Code changes done by Ravi Jain for case 00226031
 // Start - Ravi Jain - 00226031 - 17th April, 2018 - Make method visible for test class
 @TestVisible 
 // End - Ravi Jain - 00226031 - 17th April, 2018 
    
 private void getBookedRoomsList(Integer dur, Date dateKey) {
    // Extracting Hotel Information.
    if(String.isNotBlank(theTourInstanceItineraryId)) {
      Id theSupplierId = null;
        for(Tour_Instance_Itinerary__c theRecord : [SELECT Tour_Instance__c, Supplier__r.Name, City__c, Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c, Arrival_Time__c, Start_Date_of_Service__c, Depart_Time__c,
                                                  Breakfast_time__c, Morning_Call_Time__c, Dinner_Time__c, Bags_Time__c FROM Tour_Instance_Itinerary__c WHERE Id = :theTourInstanceItineraryId
                                                  AND Component_Type__c = :COMPONENT_TYPE_ITINERARY]) {
        theTourInstanceId = theRecord.Tour_Instance__c;
        theSupplierId = theRecord.Supplier__c;
        tripCode = theRecord.Operating_Product_Code__c + '-' + theRecord.Tour_Instance__r.Departure_Code__c;
        theHotelName = theRecord.Supplier__r.Name;
        if(theHotelName.length() > 35)
            theFontSizeHotelName = '10px';
        else
            theFontSizeHotelName = '14px';
        cityName = theRecord.City__c;
        theArrivalTime = theRecord.Arrival_Time__c;
        theArrivalDate = theRecord.Start_Date_of_Service__c;
            
        // Code changes done by Ravi Jain for story S-455844                                  
        userLocale = UserInfo.getLocale(); 
                                                      
        firstColumnBaggageTime = theArrivalTime;

        firstColumnDate = theArrivalDate;
        firstColumnDinnerTime = theRecord.Dinner_Time__c;
        secondColumnBreakfastTime = theRecord.Breakfast_time__c;
        secondColumnWakeUpTime = theRecord.Morning_Call_Time__c;
        secondColumnBaggageTime = theRecord.Bags_Time__c;
        secondColumnDepartTime = theRecord.Depart_Time__c;
        secondColumnDate = theArrivalDate.addDays(1);
        
        system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - Tour Instance Itinerary Record - ' + theRecord);
      }

      // Determining Reserve Times For Second And Third Day.
      if(theSupplierId != null && String.isNotBlank(theTourInstanceId)) {
        Integer counter = 0;
        for(Tour_Instance_Itinerary__c theRecord : [SELECT Morning_Call_Time__c, Bags_Time__c, Depart_Time__c, Breakfast_time__c, Start_Date_of_Service__c,
                                                    Dinner_Time__c FROM Tour_Instance_Itinerary__c WHERE Supplier__c = :theSupplierId AND
                                                    Tour_Instance__c = :theTourInstanceId AND Component_Type__c = :COMPONENT_TYPE_ITINERARY
                                                    AND Id != :theTourInstanceItineraryId ORDER By Day_Number__c ASC LIMIT 2]) {
          if(counter == 0) {

            secondColumnDinnerTime = theRecord.Dinner_Time__c;
            thirdColumnBreakfastTime = theRecord.Breakfast_time__c;
            thirdColumnWakeUpTime = theRecord.Morning_Call_Time__c;
            thirdColumnBaggageTime = theRecord.Bags_Time__c;
            thirdColumnDinnerTime = theRecord.Dinner_Time__c;
            thirdColumnDepartTime = theRecord.Depart_Time__c;
            thirdColumnDate = theArrivalDate.addDays(2);
          }
          if (counter == 1) {
            thirdColumnDinnerTime = theRecord.Dinner_Time__c;
            fourthColumnBreakfastTime = theRecord.Breakfast_time__c;
            fourthColumnWakeUpTime = theRecord.Morning_Call_Time__c;
            fourthColumnBaggageTime = theRecord.Bags_Time__c;
            fourthColumnDinnerTime = theRecord.Dinner_Time__c;
            fourthColumnDepartTime = theRecord.Depart_Time__c;
            fourthColumnDate = theArrivalDate.addDays(3);

          } else {
            fourthColumnDinnerTime = theRecord.Dinner_Time__c;
          }
          counter++;
        }
      }
    }

    // Room Number And Data Mapping.
    
    // Determining Hotel Guests.
    List<TOPS_WrapperUtility.paxWrapper> theGuests = new List<TOPS_WrapperUtility.paxWrapper>();
    List<Passenger__c> crewMem = [SELECT Salutation__c, Family_Name__c, First_Name__c, Preferred_Name__c, Dietary_Requirements__c, Age__c,
                                  Room_Special_Instructions__c, Room_Near_Group__c, Actual_Room_ID__c, Bag_Number__c, Actual_Room_Type__c,
                                  Passenger_Class__c, Room_Type_Booked__c, Room_Preference__c FROM Passenger__c WHERE Tour_Instance__c = :theTourInstanceId
                                  AND Status__c != 'CX' AND Passenger_Status__c != 'Deleted' AND Passenger_Class__c != null AND Passenger_Class__c != 'Passenger'
                                 ];
    System.debug('TRACE: TOPS_HotelRLPDFController - crewMem'+crewMem);
    for(Passenger__c pax : crewMem){
        //START- Modified by Sajal for C-00226000
        //theGuests.add(new TOPS_WrapperUtility.paxWrapper(pax,-1,'Single'));
        theGuests.add(new TOPS_WrapperUtility.paxWrapper(pax,'-1','Single'));
        //END for C-00226000
    }
    
    if(String.isNotBlank(theTourInstanceId)){
        Date maxDate;
        integer maxModules = 0;
        for(Date serviceDate : TOPS_HotelEmailProcessor.mapDatetoModules.keySet()){
            if(TOPS_HotelEmailProcessor.mapDatetoModules.get(serviceDate).size() > maxModules){
                maxModules = TOPS_HotelEmailProcessor.mapDatetoModules.get(serviceDate).size();
                maxDate = serviceDate;
            }
        }
        for(String roomType: TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(maxDate).keySet()){
            theGuests.addAll(TOPS_HotelEmailProcessor.dateToRTPAXWrapper.get(maxDate).get(roomType));          
        }
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theGuests - ' + theGuests);
    
    // Building Hotel Guest Data.
    List<String> theCrewMemberDetails = null;
    Map<String, List<String>> CREW_MEMBERS_RANKING = new Map<String, List<String>> {
      PASSENGER_CLASS_TOUR_DIRECTOR => new List<String> { '1', theAbbreviatedRole },
      PASSENGER_CLASS_DRIVER => new List<String> { '2', 'DR' },
      PASSENGER_CLASS_COOK => new List<String> { '3', 'Cook' },
      PASSENGER_CLASS_OSTM => new List<String> { '4', 'OSTM' },
      PASSENGER_CLASS_NATIONAL_GUIDE => new List<String> { '5', 'NG' }
    };

    String theRoomTypeBooked = '';
    Set<String> theCrewMembers = new Set<String>();
    Map<Integer, BookedRoomWrapper> theCrewMembersMapping = new Map<Integer, BookedRoomWrapper>();
    for(TOPS_WrapperUtility.paxWrapper theRecord : theGuests) {
      // Determining Room Type Booked.
      theRoomTypeBooked = theRecord.roomType;
    
      // Determining Tour Passengers.
      {
        
        
        if(!theHotelData.containsKey(theRecord.roomNumber+theRecord.roomType)) {
          theHotelData.put(theRecord.roomNumber+theRecord.roomType, new BookedRoomWrapper(
            '',
            new List<String>(),
            new List<String>(),
            new List<String>(),
            new List<String>(),
            new List<String>(),
            '',
            false
          ));
         // Code changes end here
         
        }
        
             //System.debug(theRecord.pax.Name + '::: theRecord.pax.Bag_Number__c :::'+ theRecord.pax.Bag_Number__c);
       
        // Determining Tour Crew Members.
      if(!theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)) {
        if(CREW_MEMBERS_RANKING.containsKey(theRecord.pax.Passenger_Class__c)) {
          theCrewMemberDetails = CREW_MEMBERS_RANKING.get(theRecord.pax.Passenger_Class__c);

          // Determining Tour Crew Member Name.
          theTourCrewMemberName = (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                                  (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                   String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');
           // Code commented and changes done by Ravi Jain for case 00176851
          // Code changes start here 
          
          theCrewMembersMapping.put(
            Integer.valueOf(theCrewMemberDetails.get(0)),
            new BookedRoomWrapper(
              theRoomTypeBooked,
              new List<String> {
                theCrewMemberDetails.get(1)
              },
              new List<String> {
                theTourCrewMemberName
              },
              new List<String>(),
              new List<String>(),
              new List<String> {
                theRecord.pax.Room_Special_Instructions__c
              },
              theRecord.pax.Room_Near_Group__c,
              false
            )
          );
          // Code changes end here
          
          theCrewMembers.add(theCrewMemberDetails.get(1));
        }
      }
      else if(theRecord.pax.Passenger_Class__c.equalsIgnoreCase(PASSENGER_CLASS_PASSENGER)){
        
        // Determining Room Type.
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theRoomType = theRoomTypeBooked;
            
        // Determining Bag Number.
        //if(!theRecord.pax.Bag_Number__c.contains('-1'))
        if(!theHotelData.containsKey(theRecord.pax.Bag_Number__c))
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers.add(theRecord.pax.Bag_Number__c);
        else
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers.add('');
        
        // Code changes done by Ravi Jain for task T-676446
        // Start - Ravi Jain - T-676446 - 10th March, 2018 - Remove the duplicate bag numbers    
        Set<String> setBagNumbers = new Set<String>();
        setBagNumbers.addAll(theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers);
        
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers = new List<String>();
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theBagNumbers.addAll(setBagNumbers);
        // End - Ravi Jain - T-676446 - 10th March, 2018 

        // Determining Nearby Room Symbol.
        if(String.isBlank(theHotelData.get(theRecord.roomNumber+theRecord.roomType).theNearbyRoomSymbol)) {
          //theHotelData.get(theRecord.roomNumber).theNearbyRoomSymbol = theRecord.roomNumber+'';
           theHotelData.get(theRecord.roomNumber+theRecord.roomType).theNearbyRoomSymbol =
            String.isNotBlank(theRecord.pax.Room_Near_Group__c) ? theRecord.pax.Room_Near_Group__c.toUpperCase() : '';
        }
        
        // Determining Guest Names.
        theGuestName = (String.isNotBlank(theRecord.pax.Salutation__c) ? theRecord.pax.Salutation__c.capitalize() + ' ' : '') +
                       (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.toUpperCase() + ', ' : '') +
                       (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                        String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '');

        // Determining Guest Age.
        if(theRecord.pax.Age__c <= 18) {
          theGuestName += ' (Age ' + String.valueOf(theRecord.pax.Age__c) + ')';
        }
        
        if(changeOverDay != ''){
           dateKey = Date.valueOf(changeOverDay.split('~')[2]);
           Set<String> modules = TOPS_HotelEmailProcessor.mapDatetoModules.get(dateKey);
           if(modules.contains(theRecord.pax.Module_Code__c))
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theGuestNames1.add(theGuestName);
           dateKey = dateKey.addDays(-1);
           System.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - dateKey - '+dateKey);
           modules = TOPS_HotelEmailProcessor.mapDatetoModules.get(dateKey);
           if(modules.contains(theRecord.pax.Module_Code__c))
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theGuestNames.add(theGuestName);
            
        }
        else
            theHotelData.get(theRecord.roomNumber+theRecord.roomType).theGuestNames.add(theGuestName);

        /*if(changeOverDay.contains('Split')){
           dateKey = Date.valueOf(changeOverDay.split('+')[2]);
           System.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - dateKey - '+dateKey);
           Set<String> modules = TOPS_HotelEmailProcessor.mapDatetoModules.get(dateKey);
           if(modules.contains(theRecord.pax.Module_Code__c))
            theHotelData.get(theRecord.roomNumber).theGuestNames1.add(theGuestName);
        }*/
        
        // Adding The Generated Guest Name To String List.
        //theHotelData.get(theRecord.roomNumber).theGuestNames.add(theGuestName);
        
        /*if(changeOverDay && (dur == 3 && bagNumToDates.get(theRecord.pax.Bag_Number__c).size() == 3)){
        // Adding The Generated Guest Name To String List.
        theHotelData.get(theRecord.roomNumber).theGuestNames2.add(theGuestName);
        }*/

    
        // Determining Room Special Instructions.
        //theHotelData.get(theRecord.Actual_Room_ID__c).theRoomSpecialInstructions = theRecord.Room_Special_Instructions__c;
        // Code commented and changes done by Ravi Jain for case 00176851
        // Code changes start here 
        
        String specialInst = theRecord.pax.Room_Special_Instructions__c == null ? '' : theRecord.pax.Room_Special_Instructions__c;
        theHotelData.get(theRecord.roomNumber+theRecord.roomType).theRoomSpecialInstructions.add(specialInst);
        // Code changes end here
        
        }
      // Determining Special Diets.
      if(String.isNotBlank(theRecord.pax.Dietary_Requirements__c)) {
        if(!theSpecialDietMapping.containsKey(theRecord.pax.Dietary_Requirements__c)) {
          theSpecialDietMapping.put(
            theRecord.pax.Dietary_Requirements__c,
            new SpecialDietaryRequirementsWrapper(
              0,
              new Set<String>()
            )
          );
        }

        // Determining Total Special Diets Count.
          theSpecialDietMapping.get(theRecord.pax.Dietary_Requirements__c).theTotalCount =
          theSpecialDietMapping.get(theRecord.pax.Dietary_Requirements__c).theTotalCount + 1;

        // Determining Special Diet Requested Guest Name.
        /*specialDietRequestedGuestName = (String.isNotBlank(theRecord.Preferred_Name__c) ? theRecord.Preferred_Name__c.capitalize() + ' ' : '') +
                                        (String.isNotBlank(theRecord.Family_Name__c) ? theRecord.Family_Name__c.substring(0, 1).toUpperCase() : '');
         theSpecialDietMapping.get(theRecord.Dietary_Requirements__c).theGuestNames.add(specialDietRequestedGuestName); */ 
          
        /* Code commented and changes done by Ravi Jain for story S-443720 */
        /* Code changes start here*/
          
        specialDietRequestedGuestName = (String.isNotBlank(theRecord.pax.Preferred_Name__c) ? theRecord.pax.Preferred_Name__c.capitalize() :
                                         String.isNotBlank(theRecord.pax.First_Name__c) ? theRecord.pax.First_Name__c.capitalize() : '') + (' ') +
                                        (String.isNotBlank(theRecord.pax.Family_Name__c) ? theRecord.pax.Family_Name__c.substring(0, 1).toUpperCase() : '');
        theSpecialDietMapping.get(theRecord.pax.Dietary_Requirements__c).theGuestNames.add(specialDietRequestedGuestName);  
        /* Code changes end here */ 
          
      }
    }
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theHotelData - ' + theHotelData);
      
    // Determining Total Rooms.
    totalRooms = theHotelData.size();

    // Determining Total Hotel Guests.
    totalHotelGuests = theGuests.size();
    
    // Determining Font Size.
    //Start Changes done by Maksud Ali. for story : S-428444 Date :19-Aug-2016
    //Start Changes done by Maksud Ali. suggest by client (Calvin Goodenough) for story : S-428444 Date :26-Aug-2016
    
    
    if(totalHotelGuests >=  56 && totalHotelGuests <= 58) {
      theFontSize = '8pt';
    }
    else if(totalHotelGuests >= 51 && totalHotelGuests <= 55) {
      theFontSize = '8.5pt';
    }
    else if(totalHotelGuests >= 43 && totalHotelGuests <= 50) {
      theFontSize = '9pt';
    }
    
    if(dur == 1){
        theFontSize = '10.5pt';
    }   
    if(dur == 2){
        theFontSize = '7pt';
    }
    if(dur == 3){
        theFontSize = '7pt';
    }
    
    //theFontSize = '7pt';
    //End for story : S-428444 Date :19-Aug-2016, 26-Aug-2016
 
    // Determining Total Singles, Twins, Triples And Quads.
    totalSingles = 0;
    totalTwins = 0;
    totalDoubles = 0;
    totalTriples = 0;
    totalQuads = 0;
    matrimonialBeds = '';
    String roomType;
    String theNearbyRoomSymbol;
    Map<String, Set<String>> theNearbyRoomsMapping = new Map<String, Set<String>>();
    for(String roomNumber : theHotelData.keySet()) {
      // Processing Room Types.
      roomType = theHotelData.get(roomNumber).theRoomType;
      if(String.isNotBlank(roomType)) {
        if(ROOM_TYPE_SINGLES.contains(roomType)) {
          totalSingles++;
        }
        else if(ROOM_TYPE_DOUBLES.contains(roomType) || ROOM_TYPE_TWINS.contains(roomType)) {
          if(ROOM_TYPE_DOUBLES.contains(roomType)) {
            // Determining Matrimonial Beds.
            for(String theMatrimonialBed : theHotelData.get(roomNumber).theBagNumbers) {
              matrimonialBeds += theMatrimonialBed + '/';
            }
            matrimonialBeds = matrimonialBeds.subString(0, matrimonialBeds.length() - 1) + ', ';

            totalDoubles++;
          }
          totalTwins++;
        }
        else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
          totalTriples++;
        }
        else if(ROOM_TYPE_QUADS.contains(roomType)) {
          totalQuads++;
        }
      }

      // Processing Nearby Room Symbols.
      theNearbyRoomSymbol = theHotelData.get(roomNumber).theNearbyRoomSymbol;
      if(String.isNotBlank(theNearbyRoomSymbol)) {
        if(!theNearbyRoomsMapping.containsKey(theNearbyRoomSymbol)) {
          theNearbyRoomsMapping.put(
            theNearbyRoomSymbol,
            new Set<String>()
          );
        }
        theNearbyRoomsMapping.get(theNearbyRoomSymbol).add(roomNumber);
      }
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theNearbyRoomsMapping - ' + theNearbyRoomsMapping);

    if(matrimonialBeds.length() > 0) {
      matrimonialBeds = matrimonialBeds.subString(0, matrimonialBeds.length() - 2);
    }

    // Determining Nearby Rooms.
    nearbyRooms = '';
    String nearbyRoomBagNumbers = '';
    List<String> theBagNumbers = null;
    if(theNearbyRoomsMapping.size() > 0) {
      for(String nearbyRoomSymbol : theNearbyRoomsMapping.keySet()) {
        nearbyRooms += '(';
        for(String theRoomNumber : theNearbyRoomsMapping.get(nearbyRoomSymbol)) {
          if(theHotelData.containsKey(theRoomNumber)) {
            theBagNumbers = theHotelData.get(theRoomNumber).theBagNumbers;
            nearbyRoomBagNumbers = String.join(theBagNumbers, '/');
            nearbyRooms += nearbyRoomBagNumbers + ' & ';
          }
        }
        nearbyRooms = nearbyRooms.subString(0, nearbyRooms.length() - 3);
        nearbyRooms += ')-' + nearbyRoomSymbol + ' ';
      }
      nearbyRooms = nearbyRooms.subString(0, nearbyRooms.length() - 1);
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - nearbyRooms - ' + nearbyRooms);

    // Determining Special Dietary Requirements.
    specialDiets = new Set<String>();
    if(theSpecialDietMapping.size() > 0) {
      String theSpecialDietDataString;
      for(String theSpecialDietName : theSpecialDietMapping.keySet()) {
        theSpecialDietDataString = String.valueOf(theSpecialDietMapping.get(theSpecialDietName).theTotalCount) + ' x ' + theSpecialDietName + ' (';
        for(String theGuestFullName : theSpecialDietMapping.get(theSpecialDietName).theGuestNames) {
          theSpecialDietDataString += theGuestFullName + ', ';
        }
        theSpecialDietDataString = theSpecialDietDataString.subString(0, theSpecialDietDataString.length() - 2) + ')';
        specialDiets.add(theSpecialDietDataString);
      }
    }

    // Initializing Booked Rooms List.
    theBookedRoomsList = new List<BookedRoomWrapper>();

    // Integrating Tour Crew Members Information.
    BookedRoomWrapper theBookedRoomWrapperInstance = null;
    for(Integer index = 1;index <= 5;index++) {
      if(theCrewMembersMapping.containsKey(index)) {
        theBookedRoomWrapperInstance = theCrewMembersMapping.get(index);
        theBookedRoomsList.add(theBookedRoomWrapperInstance);

        // Processing Room Types.
        roomType = theBookedRoomWrapperInstance.theRoomType;
        if(String.isNotBlank(roomType)) {
          if(ROOM_TYPE_SINGLES.contains(roomType)) {
            totalSingles++;
          }
          else if(ROOM_TYPE_DOUBLES.contains(roomType) || ROOM_TYPE_TWINS.contains(roomType)) {
            if(ROOM_TYPE_DOUBLES.contains(roomType)) {
              totalDoubles++;
            }
            totalTwins++;
          }
          else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
            totalTriples++;
          }
          else if(ROOM_TYPE_QUADS.contains(roomType)) {
            totalQuads++;
          }
        }
        totalRooms++;
      }
    }
    
    // Sorting Actual Room Ids.
    Set<String> actualRoomIds = theHotelData.keySet();
    List<String> theActualRoomIds = new List<String>();
    theActualRoomIds.addAll(actualRoomIds);
    theActualRoomIds.sort();
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theActualRoomIds - ' + theActualRoomIds);

    // Integrating Tour Passengers Information.
    for(String theActualRoomId : theActualRoomIds) {
      theBookedRoomsList.add(theHotelData.get(theActualRoomId));
    }
    system.debug('TRACE: TOPS_RoomListPDFController - getBookedRoomsList - theBookedRoomsList - ' + theBookedRoomsList);

    //Sorting Booked Room list based on sort Type
    if(sortType != '' && sortType == 'By Room Type'){
      sortByBookedRoomType();
      // Categorizing Booked Room List By Room Type.
      categorizeBookedRoomListByRoomType();
    }else if(sortType != '' && sortType == 'By Bag Number'){
        sortByBagNumber();
    }
    totalHotelGuests = totalSingles - theCrewMembers.size() + totalTwins * 2 + totalTriples * 3 + totalQuads * 4;
  }

  /**
  * @description  This method is used to categorize booked room list by room type.
  *
  * @param        void
  * @return       void
  */
  private void categorizeBookedRoomListByRoomType() {
    if(theBookedRoomsList.size() > 0) {
      // Declaring Booked Room Wrapper Lists.
      List<BookedRoomWrapper> crewMembersOnly = new List<BookedRoomWrapper>();
      List<BookedRoomWrapper> singleRoomsOnly = new List<BookedRoomWrapper>();
      List<BookedRoomWrapper> doubleRoomsOnly = new List<BookedRoomWrapper>();
      List<BookedRoomWrapper> tripleRoomsOnly = new List<BookedRoomWrapper>();
      List<BookedRoomWrapper> quadRoomsOnly = new List<BookedRoomWrapper>();

      // Processing Booked Rooms List.
      final Set<String> crewMemberBagNumbers = new Set<String> {
        theAbbreviatedRole,
        'DR',
        'Cook',
        'OSTM',
        'NG'
      };
      String roomType, bagNumber;
      System.debug('theBookedRoomsList value='+theBookedRoomsList);
      for(BookedRoomWrapper theInstance : theBookedRoomsList) {
        bagNumber = theInstance.theBagNumbers != null && theInstance.theBagNumbers.size() > 0 ? String.join(theInstance.theBagNumbers, ';') : '';
        if(crewMemberBagNumbers.contains(bagNumber)) {
          crewMembersOnly.add(theInstance);
        }
        else {
          // Processing Room Types.
          roomType = theInstance.theRoomType;
          if(String.isNotBlank(roomType)) {
            if(ROOM_TYPE_SINGLES.contains(roomType)) {
              singleRoomsOnly.add(theInstance);
            }
            else if(ROOM_TYPE_DOUBLES.contains(roomType) || ROOM_TYPE_TWINS.contains(roomType)) {
              doubleRoomsOnly.add(theInstance);
            }
            else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
              tripleRoomsOnly.add(theInstance);
            }
            else if(ROOM_TYPE_QUADS.contains(roomType)) {
              quadRoomsOnly.add(theInstance);
            }
          }
        }

        // Rearranging Rooms As Per Room Type.
        theBookedRoomsList = new List<BookedRoomWrapper>();
        if(crewMembersOnly.size() > 0) {
          theBookedRoomsList.addAll(crewMembersOnly);
          if(singleRoomsOnly.size() > 0 && totalHotelGuests <= 51) {
            theBookedRoomsList.add(getBlankBookedRoomWrapper());
          }
        }
        if(singleRoomsOnly.size() > 0) {
          theBookedRoomsList.addAll(singleRoomsOnly);
          if(doubleRoomsOnly.size() > 0 && totalHotelGuests <= 51) {
            theBookedRoomsList.add(getBlankBookedRoomWrapper());
          }
        }
        if(doubleRoomsOnly.size() > 0) {
           System.debug('Rooming list befor double='+theBookedRoomsList);
          theBookedRoomsList.addAll(doubleRoomsOnly);
          System.debug('Rooming list after double='+theBookedRoomsList);
          if(tripleRoomsOnly.size() > 0 && totalHotelGuests <= 51) {
            theBookedRoomsList.add(getBlankBookedRoomWrapper());
          }
        }
        if(tripleRoomsOnly.size() > 0) {
          theBookedRoomsList.addAll(tripleRoomsOnly);
          if(quadRoomsOnly.size() > 0 && totalHotelGuests <= 51) {
            theBookedRoomsList.add(getBlankBookedRoomWrapper());
          }
        }
        if(quadRoomsOnly.size() > 0) {
          theBookedRoomsList.addAll(quadRoomsOnly);
        }
      }
      System.debug('theBookedRoomsList value After categorization='+theBookedRoomsList);
    }
  }

  /**
  * @description  This method is used to generate a blank booked room wrapper instance.
  *
  * @param        void
  * @return       BookedRoomWrapper theInstance
  */
  private BookedRoomWrapper getBlankBookedRoomWrapper() {
    /*return new BookedRoomWrapper(
      '',
      new List<String>(),
      new List<String>(),
      '',
      '',
      true
    );*/
    
    // Code commented and changes done by Ravi Jain for case 00176851
   // Code changes start here 
   
    return new BookedRoomWrapper(
      '',
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      '',
      true
    );
    // Code changes end here
    
  }

  /**
  * @description  This method is used to determine the region code and the footer logos.
  *
  * @param        void
  * @return       void
  */
  private void getRegionCodeAndFooterLogoList() {
  //Changes Start,Done by Maksud Ali for Story : S-455965
    theFooterLogoList = new List<StaticImageManager>();

    // Extracting the tour instance id.
    // Code changes done by Ravi Jain for story S-428448
   // Code changes start here
    if(isTourInstance) {
        
    } else {
        theTourInstanceId = null;
        for(Tour_Instance_Itinerary__c theRecord : [SELECT Tour_Instance__c FROM Tour_Instance_Itinerary__c WHERE
                                                    Id = :theTourInstanceItineraryId AND Component_Type__c = :COMPONENT_TYPE_ITINERARY]) {
          theTourInstanceId = theRecord.Tour_Instance__c;
        }
        // Code changes end here
    }
    if(String.isBlank(theTourInstanceId)) {
      return;
    }
    // Extracting operating product code for the tour instance Id passed as the URL parameter.
    String theOperatingProductCode;
    String specialBrand = '';
    for(Tour_Instance__c theRecord : [SELECT Operating_Product_Code__c,Special_Brand__c, Tour_Series__r.Name, Departure_Code__c
                                      FROM Tour_Instance__c WHERE Id = :theTourInstanceId]) {
      theOperatingProductCode = theRecord.Operating_Product_Code__c;
      theItineraryName = theRecord.Tour_Series__r.Name;
      theItineraryCode = theOperatingProductCode + '/' + theRecord.Departure_Code__c;
      specialBrand = theRecord.Special_Brand__c;
    }

    // Determining the region code.
    if(String.isNotBlank(theOperatingProductCode) && theOperatingProductCode.length() >= 2) {
      theRegionCode = theOperatingProductCode.subString(0, 2);
    }

    theAbbreviatedRole = '';
    // Extracting configuration information.
    for(Region_Code_Brand_Mapping__mdt theRecord : [SELECT DeveloperName, Brand__c, Colour__c, Logos__c, Abbreviated_Role__c
                                                    FROM Region_Code_Brand_Mapping__mdt WHERE DeveloperName = :theRegionCode]) {
      theAbbreviatedRole = theRecord.Abbreviated_Role__c;
      theBrandName = String.isNotBlank(theRecord.Brand__c) ? theRecord.Brand__c.capitalize() : '';
      if(String.isNotBlank(theRecord.Logos__c) && theRecord.Logos__c.contains(',')) {
        List<String> tmpSplitedLogoName = theRecord.Logos__c.split(',');
        for(String logoName : tmpSplitedLogoName) {
            theFooterLogoList.add(new StaticImageManager(logoName,specialBrand));
        }
      }
      else {
            theFooterLogoList.add(new StaticImageManager(theRecord.Logos__c,specialBrand));
      }
    }
    //End code here.
    
    // Determining Room List Title.
    theRoomListTitle = Label.Room_List_title;
    //theRoomListTitle = tripCode + '-' + Label.Room_List_title;
    if(String.isNotBlank(theRoomListTitle) && String.isNotBlank(theBrandName)) {
      theRoomListTitle = theRoomListTitle.replace('{0}', theBrandName);
    }
  }

  /**
  * @description  This method is used to determine the language in which the PDF will be generated.
  *
  * @param        void
  * @return       void
  */
  private void getPDFLanguage() {
    theLanguage = 'en-US';
    if(theRegionCode == 'VB' || theRegionCode == 'VE') {
      theLanguage = 'fr';
    }
  }

  private void setTdPhoneNumber(){
    tdPhoneNumber = [SELECT Allocated_TD__r.Crew_Contact_Number_1__c FROM Tour_Instance__c
                    WHERE Id = :theTourInstanceId].Allocated_TD__r.Crew_Contact_Number_1__c;
  }
    /**
    * @description  This method is used to sort By the booked room Type
    *
    * @param        void
    * @return       void
    * #I-300408     Neeraj Kumawat
    */
    private void sortByBookedRoomType() {
        if(theBookedRoomsList.size() > 0) {
            // Declaring Booked Room Wrapper Lists.
            List<BookedRoomWrapper> crewMembersOnly = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> singleRoomsOnly = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> doubleRoomsOnly = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> twinRoomsOnly = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> tripleRoomsOnly = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> quadRoomsOnly = new List<BookedRoomWrapper>();
            
            // Processing Booked Rooms List.
            final Set<String> crewMemberBagNumbers = new Set<String> {
                theAbbreviatedRole,
                    'DR',
                    'Cook',
                    'OSTM',
                    'NG'
                    };
                        String roomType, bagNumber;
            for(BookedRoomWrapper theInstance : theBookedRoomsList) {
                bagNumber = theInstance.theBagNumbers != null && theInstance.theBagNumbers.size() > 0 ? String.join(theInstance.theBagNumbers, ';') : '';
                if(crewMemberBagNumbers.contains(bagNumber)) {
                    crewMembersOnly.add(theInstance);
                }
                else {
                    // Processing Room Types.
                    roomType = theInstance.theRoomType;
                    if(String.isNotBlank(roomType)) {
                        if(ROOM_TYPE_SINGLES.contains(roomType)) {
                            singleRoomsOnly.add(theInstance);
                        }
                        else if(ROOM_TYPE_DOUBLES.contains(roomType)) {
                            doubleRoomsOnly.add(theInstance);
                        }
                        else if(ROOM_TYPE_TWINS.contains(roomType)) {
                            twinRoomsOnly.add(theInstance);
                        }
                        else if(ROOM_TYPE_TRIPLES.contains(roomType)) {
                            tripleRoomsOnly.add(theInstance);
                        }
                        else if(ROOM_TYPE_QUADS.contains(roomType)) {
                            quadRoomsOnly.add(theInstance);
                        }
                    }
                }
            }
            // Rearranging Rooms As Per Room Type.
            theBookedRoomsList = new List<BookedRoomWrapper>();
            if(crewMembersOnly.size() > 0) {
                theBookedRoomsList.addAll(crewMembersOnly);
            }
            if(singleRoomsOnly.size() > 0) {
                theBookedRoomsList.addAll(singleRoomsOnly);
            }
            if(doubleRoomsOnly.size() > 0) {
                theBookedRoomsList.addAll(doubleRoomsOnly);
            }
            if(twinRoomsOnly.size() > 0) {
                theBookedRoomsList.addAll(twinRoomsOnly);
            }
            if(tripleRoomsOnly.size() > 0) {
                theBookedRoomsList.addAll(tripleRoomsOnly);
            }
            if(quadRoomsOnly.size() > 0) {
                theBookedRoomsList.addAll(quadRoomsOnly);
            }
        }
    }
    /**
    * @description  This method is used to sort By the Bag number
    *
    * @param        void
    * @return       void
    * #I-300408     Neeraj Kumawat
    */
    private void sortByBagNumber() {
        if(theBookedRoomsList.size() > 0) {
            System.debug('theBookedRoomsList Value before bag number sorting='+theBookedRoomsList);
            // Declaring Booked Room Wrapper Lists.
            List<BookedRoomWrapper> crewMembersOnly = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> blankBagNumberList = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> sortedBagNumberRoomList = new List<BookedRoomWrapper>();
            List<BookedRoomWrapper> unSortedBagNumberRoomList = new List<BookedRoomWrapper>();
            List<Integer> unSortedBagNumberList = new List<Integer>();
            
            Map<Integer, BookedRoomWrapper> bagNumberBookedRoomMap= new Map<Integer, BookedRoomWrapper>();
            
            // Processing Booked Rooms List.
            final Set<String> crewMemberBagNumbers = new Set<String> {
                theAbbreviatedRole,
                    'DR',
                    'Cook',
                    'OSTM',
                    'NG'
                    };
            String roomType, bagNumber;
            //Iterating theBookedRoomsList 
            for(BookedRoomWrapper theInstance : theBookedRoomsList) {
                bagNumber = theInstance.theBagNumbers != null && theInstance.theBagNumbers.size() > 0 ? String.join(theInstance.theBagNumbers, ';') : '';
                //Sperating crewmember list
                if(crewMemberBagNumbers.contains(bagNumber)) {
                    crewMembersOnly.add(theInstance);
                }
                else if(theInstance.theBagNumbers.size()>0){
                    // preparing unsorted bug number room list
                    List<Integer> bagNumList=convertStringToItegerListAndSort(theInstance.theBagNumbers);
                    //unSortedBagNumberList which is used to sort the unSortedBagNumberRoomList
                    unSortedBagNumberList.add(bagNumList[0]);
                    //Adding minimum value of bag number in the record 
                    theInstance.theBagNumber=bagNumList[0];
                    //adding the record in the unSortedBagNumberRoomList
                    unSortedBagNumberRoomList.add(theInstance);
                } 
                else if(theInstance.theBagNumbers.size() == 0){
                    //Preparing blankBagNumberList whic don't have bag number
                    blankBagNumberList.add(theInstance);
                }
            }
            // Sorting Based on Bag Number.
            //Set<Integer> bagNumberList = bagNumberBookedRoomMap.keySet();
            system.debug('unSortedBagNumberList  Value - ' + unSortedBagNumberList);
            List<Integer> sortedBagNumberList = new List<Integer>();
            sortedBagNumberList.addAll(unSortedBagNumberList);
            //sorting bag number list
            sortedBagNumberList.sort();
            system.debug('SortedBagNumberList Value - ' + sortedBagNumberList);
            
            //preparing sorted Bag Number Room List
            for(Integer bagNum : sortedBagNumberList) {
                for(Integer i=0; i<unSortedBagNumberRoomList.size(); i++){
                    if(unSortedBagNumberRoomList[i].theBagNumber == bagNum){
                        sortedBagNumberRoomList.add(unSortedBagNumberRoomList[i]);
                        unSortedBagNumberRoomList.remove(i);
                    }
                }
            }  
            //Reinitilizing theBookedRoomsList and sorting based on bag number
            theBookedRoomsList = new List<BookedRoomWrapper>();
            if(crewMembersOnly.size() > 0) {
                theBookedRoomsList.addAll(crewMembersOnly);
            }
            if(sortedBagNumberRoomList.size() > 0) {
                theBookedRoomsList.addAll(sortedBagNumberRoomList);
            }
            if(blankBagNumberList.size() > 0) {
                theBookedRoomsList.addAll(blankBagNumberList);
            }
            System.debug('theBookedRoomsList Value after bag number sorting='+theBookedRoomsList);
        }
    }
    /**
    * @description  This method is used to convert String list to Integer and sort them
    *
    * @param        List<String>
    * @return       List<Integer>
    * #I-300408     Neeraj Kumawat
    */
    private List<Integer> convertStringToItegerListAndSort(List<String> strList){
        List<Integer> intgerList=new List<Integer>();
        for(String str:strList){
            try{
                Integer bagNumber=Integer.valueOf(str);
                intgerList.add(bagNumber);
            }catch(Exception ex){
                
            }
        }
        intgerList.sort();
        return intgerList;
    }

}