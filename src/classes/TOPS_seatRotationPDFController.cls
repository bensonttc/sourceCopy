//
// 
//
// Apex Class Name: TOPS_seatRotationPDFController
// For Apex Page: TOPS_seatRotationPDFExp
// Description: This apex controller is used to generate PDF of seating layout on a variety of coach layouts.
//
// Code base (c) Appirio, RoomListPDF controller
// 13th Feb 2017 Calvin Goodenough modified for proof of concept for seat rotation
// 
// 

public without sharing class TOPS_seatRotationPDFController {
  // Private Constants.
  private final Integer MAX_RECORDS = 58;
  private final String COMPONENT_TYPE_ITINERARY = 'Itinerary';
  private final String PASSENGER_CLASS_PASSENGER = 'Passenger';
  private final String PASSENGER_CLASS_TOUR_DIRECTOR = 'Tour Director';
  private final String PASSENGER_CLASS_DRIVER = 'Driver';
  private final String PASSENGER_CLASS_COOK = 'Cook';
  private final String PASSENGER_CLASS_OSTM = 'OSTM';
  private final String PASSENGER_CLASS_NATIONAL_GUIDE = 'National Guide';

  // Private Data Members.
  private String theTourInstanceId { get; set; }
  private String theTourInstanceItineraryId { get; set; }
  private String theRegionCode { get; set; }
  private String theAbbreviatedRole { get; set; }
  private String theSeatingJSON { get; set; }
  private String dayWiseSeatingPlan { get; set; }
  private String theLayoutToShow { get; set; }

  // Public Data Members.
  public String theLanguage { get; private set; }
  public List<StaticImageManager> footerlogoList {get; set;}
  public Tour_Instance__c tourRecord{get; set;}
  public String theBrandName { get; set; }
  public string theDay { get; set; }  
  public string theRoute { get; set; } 
  public Date theArrivalDate { get; private set; } 
  public String hashTag {get; set;}
  public Integer size {get; set;}  
  
  //rotation members  
  public integer theTotalRows { get; set; } 
  public integer theRowsBeforeStairs { get; set; } 
  public integer theRowsAfterStairs { get; set; } 
  public integer theNumberOfStairs { get; set; }   
  public string theDriverSide { get; set; }   
  public string theOrientation { get; set; }  
  public string theMethod { get; set; }  
  public integer theSeatsToRotate { get; set; }  
  public boolean theBackMiddleSeatThere { get; set; }  
  public List<SeatingWrapper> theCoachSeatPlan { get; private set; }
  public List<SeatingWrapper> theTempCoachSeatPlan { get; private set; }  
  
  // RJ changes
  public List<DayWiseSeatingWrapper> firstRowAfterStairs { get; private set; }  
  public List<DayWiseSeatingWrapper> firstRowBeforeStairs { get; private set; }  
  public List<DayWiseSeatingWrapper> secondRowAfterStairs { get; private set; }  
  public List<DayWiseSeatingWrapper> secondRowBeforeStairs { get; private set; }  
  public List<DayWiseSeatingWrapper> thirdRow { get; private set; }  
  public List<DayWiseSeatingWrapper> fourthRow { get; private set; }  
  public List<DayWiseSeatingWrapper> fifthRow { get; private set; } 
  public List<MergeList> mergeRow { get; set; }  
  public List<String> stairs { get; private set; } 
   
  public string myTemp {get; set;}   
    
  public String theItineraryName { get; private set; }
  public String theItineraryCode { get; private set; }  
  public String tripCode { get; private set; }
  public String cityName { get; private set; }
  public String theFontSize { get; private set; }
  public String userLocale { get; private set; }      
  public boolean isTourInstance = false ;
  private List<Tour_Instance_Itinerary__c> tourInstanceItinerary;
  
  private String[] guestNameArray = null; 
  private String guestName = '';
      
  // Class Constructor.
  public TOPS_seatRotationPDFController() {
    try {
    tourInstanceItinerary =  new List<Tour_Instance_Itinerary__c>();

     Map<String, String> parameters = ApexPages.currentPage().getParameters();
     Id relatedObjectId = (Id)parameters.get('relatedObjectId');
     if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance__c') {
         isTourInstance  = true ;
         theTourInstanceId = ApexPages.currentPage().getParameters().get('relatedObjectId');
         theTourInstanceItineraryId = findMyTII(theTourInstanceId);
     }else if (relatedObjectId.getSobjectType().getDescribe().getName() == 'Tour_Instance_Itinerary__c') {
         isTourInstance  = false;
         theTourInstanceItineraryId = ApexPages.currentPage().getParameters().get('relatedObjectId');
          system.debug('TRACE: TOPS_seatRotationPDFControllerExp - TOPS_seatRotationPDFControllerExp - theTourInstanceItineraryId - ' + theTourInstanceItineraryId);
          theTourInstanceId = findTI(theTourInstanceItineraryId);
     } 
      theLayoutToShow = ApexPages.currentPage().getParameters().get('Parameters');
      theCoachSeatPlan = new List<SeatingWrapper>();
      
      // RJ changes
      
      firstRowAfterStairs = new List<DayWiseSeatingWrapper>();
      firstRowBeforeStairs = new List<DayWiseSeatingWrapper>();
      secondRowAfterStairs = new List<DayWiseSeatingWrapper>();
      secondRowBeforeStairs = new List<DayWiseSeatingWrapper>();
      thirdRow = new List<DayWiseSeatingWrapper>();
      fourthRow  = new List<DayWiseSeatingWrapper>();
      fifthRow = new List<DayWiseSeatingWrapper>();
      mergeRow = new List<MergeList>();
      stairs = new List<String>();
      
      theTempCoachSeatPlan = new List<SeatingWrapper>();  
      theFontSize = '10.5pt';
      theSeatingJSON = '';
      dayWiseSeatingPlan = '';
      getRegionCodeAndFooterLogoList();
      getPDFLanguage();
      setLayoutVars();
        if ( theLayoutToShow == 'Layout') { 
            getCoachSeatingPlan();
        } else {    
            rotateSeats();
        }       
    }
    catch(Exception e) {
      system.debug('TRACE: TOPS_seatRotationPDFControllerExp - TOPS_seatRotationPDFControllerExp - Exception Message - ' + e.getMessage());
      system.debug('TRACE: TOPS_seatRotationPDFControllerExp - TOPS_seatRotationPDFControllerExp - Exception Stack Trace - ' + e.getStackTraceString());
    }
  }
  
  
  public Id findTI(Id theTourInstanceItineraryId)  {     
      // add select to find the Tour Instance so the we get the correct TII in the final step
    return [SELECT Tour_Instance__C from Tour_instance_Itinerary__C WHERE
                        id =:theTourInstanceItineraryID].Tour_Instance__C;
  }
    
    public id findMyTII(id theTourInstanceID)   {
     return [SELECT Id FROM Tour_Instance_Itinerary__c WHERE  Component_Type__c = :COMPONENT_TYPE_ITINERARY  AND Tour_instance__C = :theTourInstanceID
            order by Day_Number__c asc limit 1].Id;   
    }
    

    // Seating Wrapper Class.
    public class SeatingWrapper {
        public Integer theSeatNumber { get; private set; }
        public String theGuestName { get; private set; }
        public Boolean theNonRotator { get; private set; }
        public String theAnnotation  { get; private set; }   

        // Wrapper Class Parameterized Constructor.
        public SeatingWrapper(
          Integer seatNumber,
          String guestName,
          Boolean nonRotator,
          String annotation
        ) {
          theSeatNumber = seatNumber;
          theGuestName = guestName;
          theNonRotator = nonRotator;
          theAnnotation = annotation;
        }
  }
 
    public class seatingPlan {
         public  List<mySeating> seatingPlan;
    }
    
    public class mySeating {
        public Integer theSeatNumber; 
        public String theGuestName;
        public Boolean theNonRotator; 
        public String theAnnotation; 
        
        public mySeating(integer seatNumber, string guestName, boolean nonRotator, string annotation){
            theSeatNumber = seatNumber;
            theGuestNAme = guestName;
            theNonRotator = nonRotator;
            theAnnotation = annotation;
        }
    } 
    
    // DayWise Seating Wrapper Class.
    public class DayWiseSeatingWrapper {
        public Integer theSeatNumber { get; private set; }
        public String theGuestName { get; private set; }
        public Boolean theNonRotator { get; private set; }
        public String theGuestId { get; private set; }  
        public Integer theSeatIndex { get; private set; }
        public String theSeatColumnType { get; private set; } 

        // Wrapper Class Parameterized Constructor.
        public DayWiseSeatingWrapper(
          integer seatNumber, 
          string guestName, 
          boolean nonRotator, 
          string guestId, 
          Integer seatIndex, 
          string seatColumnType
        ) {
          theSeatNumber = seatNumber;
          theGuestName = guestName;
          theNonRotator = nonRotator;
          theGuestId = guestId;
          theSeatIndex = seatIndex;
          theSeatColumnType = seatColumnType;
        }
  }
    
     public class DayWiseSeatingPlan{
         public  List<DayWiseSeating> seatingPlan;
    }
    
    public class DayWiseSeating{
        public Integer theSeatNumber; 
        public String theGuestName;
        public Boolean theNonRotator; 
        public String theGuestId; 
        public Integer theSeatIndex; 
        public String theSeatColumnType; 
        
        public DayWiseSeating(integer seatNumber, string guestName, boolean nonRotator, string guestId, Integer seatIndex, string seatColumnType){
            theSeatNumber = seatNumber;
            theGuestName = guestName;
            theNonRotator = nonRotator;
            theGuestId = guestId;
            theSeatIndex = seatIndex;
            theSeatColumnType = seatColumnType;
        }
    }  
     
  /**
  * @description  This method is used to determine the region code and the footer logos.
  *
  * @param        void
  * @return       void
  */
  public void getRegionCodeAndFooterLogoList() {
      String productCode = '';
    footerlogoList = new List<StaticImageManager>();

    for(Tour_Instance__c  tour : [SELECT id,Name, Product_Name__c,Special_Brand__c, Operating_Product_Code__c,Travel_Director__c,Instance_Code__c, coach_size__C
                                      FROM Tour_Instance__c
                                      WHERE id=: theTourInstanceId]) {
          productCode = tour.Operating_Product_Code__c;
          tourRecord = tour;
          theItineraryCode = tour.Instance_Code__c; 
          //String coachSize = tour.coach_size__C; 
          //if(string.isblank(coachSize) || integer.valueOf(coachSize)<1 ) {
            //  theBackMiddleSeatThere = TRUE;
          //} else {                                         
          //theBackMiddleSeatThere = (math.MOD(integer.valueof(coachSize), 2) == 1); 
          //}    
        }
        if(productCode != '' && productCode.length() >= 2) {
          theRegionCode = productCode.subString(0,2);
        }
        for(Region_Code_Brand_Mapping__mdt mapRec : [SELECT DeveloperName, HashTag__C, Brand__c, Colour__c,Logos__c
                                                     FROM Region_Code_Brand_Mapping__mdt
                                                     WHERE DeveloperName =: theRegionCode]) {
         hashTag = mapRec.HashTag__c;
         theBrandName = mapRec.brand__C;                                                         
          if(mapRec.Logos__c != '' && mapRec.Logos__c.contains(',')) {
            List<String> tmpSplitedLogoName = mapRec.Logos__c.split(',');
            for(String logoName : tmpSplitedLogoName) {
                footerlogoList.add(new StaticImageManager(logoName,tourRecord.Special_Brand__c));
            }
          }else {
            footerlogoList.add(new StaticImageManager(mapRec.Logos__c,tourRecord.Special_Brand__c));
          }
        }
      tour_Instance_Itinerary__C myTII = [select id, day_number__C, start_Date_of_Service__C, journey_leg_name__C from tour_instance_itinerary__C where id = :theTourInstanceItineraryId limit 1];
      theDay = string.valueof(myTII.day_number__C);
      theArrivalDate = myTII.start_Date_of_service__C;
      theRoute = myTII.journey_leg_name__C;
  }

  /**
  * @description  This method is used to determine the language in which the PDF will be generated.
  *
  * @param        void
  * @return       void
  */
  public void getPDFLanguage() {
    theLanguage = 'en-US';
    if(theRegionCode == 'VB' || theRegionCode == 'VE') {
      theLanguage = 'fr';
    }
  }
 
    //setLayoutVars
    //
  public void setLayoutVars(){
    for(Tour_Instance__c theRecord : [SELECT rotate_driver_side__c, rotate_orientation__c, rotate_method__c, rotate_num_seats__C, rotate_rows_behind_driver__C, rotate_rows_behind_TDTM__C, rotate_rows_after_stairs__C FROM Tour_Instance__c
                    WHERE Id = :theTourInstanceId limit 1]){
       theTotalRows = Integer.valueof(theRecord.rotate_rows_behind_driver__C);  
       theRowsBeforeStairs = Integer.valueof(theRecord.rotate_rows_behind_TDTM__C);
       theRowsAfterStairs = Integer.valueof(theRecord.rotate_rows_after_stairs__C);
       theNumberOfStairs = Integer.valueof(theTotalRows-theRowsBeforeStairs-theRowsAfterStairs);
       theDriverSide = theRecord.rotate_driver_side__C;
       theOrientation = theRecord.rotate_orientation__c;
       theMethod = theRecord.rotate_method__c;
       theSeatsToRotate = Integer.valueof(theRecord.rotate_num_seats__C); 
       
       // RJ changes
       Integer rowsAfterStairs = theTotalRows  -  theRowsBeforeStairs - 2;
       for(integer i = 0; i < rowsAfterStairs;i++)
       {
            firstRowAfterStairs.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
            secondRowAfterStairs.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
       }
       for(integer i = 0; i < theRowsBeforeStairs +1;i++)
       {
            firstRowBeforeStairs.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
       }
       
       for(integer i = 0; i < theRowsBeforeStairs +1;i++)
       {
            secondRowBeforeStairs.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
       }
       
       for(integer i = 0;i < 1;i++)
       {
            thirdRow.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
       }
       
       for(integer i = 0; i < theTotalRows +1;i++)
       {
            fourthRow.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
            fifthRow.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
       }
       
       //for(integer i = 0; i < theTotalRows;i++)
       //{
         //   fifthRow.add(new DayWiseSeatingWrapper(null,' ',null,null,null,null));
       //}
       
       for(integer i = 0; i < 2; i++)
       {
            stairs.add(' ');
       }
    }
  } 
  
    public void popSeatWrapperFromJSON(List<SeatingWrapper> theLocalCoachSeatPlan){
   //    JSONParser parser = JSON.createParser(theSeatingJSON); 
         
       System.debug('theSeatingJSON ::::'+' '+theSeatingJSON);
       System.debug('dayWiseSeatingPlan ::::'+' '+dayWiseSeatingPlan);       
       seatingPlan localSeating = (seatingPlan)JSON.deserialize(theSeatingJSON, seatingPlan.class);
       DayWiseSeatingPlan dayWiseSeating = (DayWiseSeatingPlan)JSON.deserialize(dayWiseSeatingPlan, DayWiseSeatingPlan.class);
        
       for(DayWiseSeating DayWiseSeatingData : dayWiseSeating.seatingPlan) 
       {
         if(DayWiseSeatingData.theSeatColumnType == 'firstRowAfterStairs')
         {
           firstRowAfterStairs.set(DayWiseSeatingData.theSeatIndex, new DayWiseSeatingWrapper(DayWiseSeatingData.theSeatNumber, DayWiseSeatingData.theGuestName, DayWiseSeatingData.theNonRotator, DayWiseSeatingData.theGuestId, DayWiseSeatingData.theSeatIndex, DayWiseSeatingData.theSeatColumnType));
           //System.debug('dayWiseSeating.seatingPlan11111 :::'+ ' '+firstRowAfterStairs);
         }
         else if(DayWiseSeatingData.theSeatColumnType == 'firstRowBeforeStairs')
         {
           firstRowBeforeStairs.set(DayWiseSeatingData.theSeatIndex, new DayWiseSeatingWrapper(DayWiseSeatingData.theSeatNumber, DayWiseSeatingData.theGuestName, DayWiseSeatingData.theNonRotator, DayWiseSeatingData.theGuestId, DayWiseSeatingData.theSeatIndex, DayWiseSeatingData.theSeatColumnType));
         }
          
         else if(DayWiseSeatingData.theSeatColumnType == 'secondRowAfterStairs')
         {
           secondRowAfterStairs.set(DayWiseSeatingData.theSeatIndex, new DayWiseSeatingWrapper(DayWiseSeatingData.theSeatNumber, DayWiseSeatingData.theGuestName, DayWiseSeatingData.theNonRotator, DayWiseSeatingData.theGuestId, DayWiseSeatingData.theSeatIndex, DayWiseSeatingData.theSeatColumnType));
         } 
         else if(DayWiseSeatingData.theSeatColumnType == 'secondRowBeforeStairs')
         {
           secondRowBeforeStairs.set(DayWiseSeatingData.theSeatIndex, new DayWiseSeatingWrapper(DayWiseSeatingData.theSeatNumber, DayWiseSeatingData.theGuestName, DayWiseSeatingData.theNonRotator, DayWiseSeatingData.theGuestId, DayWiseSeatingData.theSeatIndex, DayWiseSeatingData.theSeatColumnType));
         }
         
         else if(DayWiseSeatingData.theSeatColumnType == 'thirdRow')
         {
           thirdRow.set(DayWiseSeatingData.theSeatIndex, new DayWiseSeatingWrapper(DayWiseSeatingData.theSeatNumber, DayWiseSeatingData.theGuestName, DayWiseSeatingData.theNonRotator, DayWiseSeatingData.theGuestId, DayWiseSeatingData.theSeatIndex, DayWiseSeatingData.theSeatColumnType));
         } 
         else if(DayWiseSeatingData.theSeatColumnType == 'fourthRow')
         {
           fourthRow.set(DayWiseSeatingData.theSeatIndex, new DayWiseSeatingWrapper(DayWiseSeatingData.theSeatNumber, DayWiseSeatingData.theGuestName, DayWiseSeatingData.theNonRotator, DayWiseSeatingData.theGuestId, DayWiseSeatingData.theSeatIndex, DayWiseSeatingData.theSeatColumnType));
         } 
         
         else if(DayWiseSeatingData.theSeatColumnType == 'fifthRow')
         {
           fifthRow.set(DayWiseSeatingData.theSeatIndex, new DayWiseSeatingWrapper(DayWiseSeatingData.theSeatNumber, DayWiseSeatingData.theGuestName, DayWiseSeatingData.theNonRotator, DayWiseSeatingData.theGuestId, DayWiseSeatingData.theSeatIndex, DayWiseSeatingData.theSeatColumnType));
         } 
         
       } 
       
       System.debug('dayWiseSeating.seatingPlan11111 :::'+ ' '+firstRowAfterStairs.size());
       List<DayWiseSeatingWrapper> tempfirstRowAfterStairs = new List<DayWiseSeatingWrapper>();
       List<DayWiseSeatingWrapper> tempfirstRowBeforeStairs = new List<DayWiseSeatingWrapper>();
       List<DayWiseSeatingWrapper> tempsecondRowAfterStairs = new List<DayWiseSeatingWrapper>();
       List<DayWiseSeatingWrapper> tempsecondRowBeforeStairs = new List<DayWiseSeatingWrapper>();
       List<DayWiseSeatingWrapper> tempThirdRow = new List<DayWiseSeatingWrapper>();
       List<DayWiseSeatingWrapper> tempfourthRow = new List<DayWiseSeatingWrapper>();
       List<DayWiseSeatingWrapper> tempfifthRow = new List<DayWiseSeatingWrapper>();
       
       for(integer i = 0;i<(theTotalRows  -  theRowsBeforeStairs - 2);i++)
       { 
           tempfirstRowAfterStairs.add(firstRowAfterStairs[i]);
       }
       firstRowAfterStairs = tempfirstRowAfterStairs;
        
       for(integer j = 0;j<(theRowsBeforeStairs+1);j++)
       { 
          tempfirstRowBeforeStairs.add(firstRowBeforeStairs[j]);
       } 
       firstRowBeforeStairs = tempfirstRowBeforeStairs;
       
       for(integer i = 0;i<(theTotalRows  -  theRowsBeforeStairs - 2);i++)
       { 
           tempSecondRowAfterStairs.add(secondRowAfterStairs[i]);
       }
       secondRowAfterStairs = tempSecondRowAfterStairs;
       
       for(integer i = 0;i<(theRowsBeforeStairs +1);i++)
       { 
           tempSecondRowBeforeStairs.add(secondRowBeforeStairs[i]);
       }
       secondRowBeforeStairs = tempSecondRowBeforeStairs;
       
       for(integer j=0;j<1;j++)
       { 
          tempThirdRow.add(thirdRow[j]);
       } 
       thirdRow = tempThirdRow;
       
       for(integer j = 0;j<(theTotalRows +1);j++)
       { 
          tempFourthRow.add(fourthRow[j]);
       } 
       fourthRow = tempFourthRow;
       
       for(integer j = 0;j<(theTotalRows+1);j++)
       { 
          tempFifthRow.add(fifthRow[j]);
       } 
       fifthRow = tempFifthRow;
       
       System.debug('dayWiseSeating.seatingPlan11111 :::'+ ' '+firstRowAfterStairs);
       System.debug('dayWiseSeating.seatingPlan22222 :::'+ ' '+firstRowBeforeStairs);
       System.debug('dayWiseSeating.seatingPlan33333 :::'+ ' '+secondRowAfterStairs);
       System.debug('dayWiseSeating.seatingPlan44444 :::'+ ' '+secondRowBeforeStairs);
       System.debug('dayWiseSeating.seatingPlan55555 :::'+ ' '+thirdRow);
       System.debug('dayWiseSeating.seatingPlan66666 :::'+ ' '+fourthRow);
       System.debug('dayWiseSeating.seatingPlan77777 :::'+ ' '+fifthRow);
       
       size = fourthRow.size();
       Integer totalSize = fourthRow.size()-1;
       Integer firstRowAftersize = firstRowAfterStairs.size() -1 ;
       Integer firstRowBeforesize = firstRowBeforeStairs.size() -1;
       Integer secondRowAftersize = secondRowAfterStairs.size() -1;
       Integer secondRowBeforesize = secondRowBeforeStairs.size() -1;
       
       Integer j = 0;
       Integer k = 0;
       for(integer i = 0; i < size; i++) {
           
           MergeList mRow = new MergeList();
           
           
           
           if(i == 0)
           {
                mRow.startNumbering = 'Back Seat';
           }
           else if(i<firstRowAfterStairs.size())
           {
              mRow.startNumbering = String.valueOf(firstRowAftersize);
              firstRowAftersize--;
           }
           else if(i == firstRowAfterStairs.size() || i ==firstRowAfterStairs.size()+1)
           {
              mRow.startNumbering = 'Back Door';
           }
           else if(i == size-1)
           {
              if(theDriverSide == 'Left')
              {
                 mRow.startNumbering = '';
              }
              else
              {
                 mRow.startNumbering = 'Front Door';
              }
           }
           else if(i>=firstRowAfterStairs.size() +2 && i < size -1)
           {
              mRow.startNumbering = String.valueOf(firstRowBeforesize);
              firstRowBeforesize--;
           }
           
           
           if(i == 0)
           {
                mRow.endNumbering = 'Back Seat';
           }
           else if(i == size-1)
           {
              if(theDriverSide == 'Left')
              {
                 mRow.endNumbering = 'Front Door';
              }
              else
              {
                 mRow.endNumbering = '';
              }
           }
           else if(i<size-1)
           {
              mRow.endNumbering = String.valueOf(totalSize-1);
              totalSize--;
           }
           
           if(i == size-1)
           {
               if(theDriverSide == 'Left')
               {
                   mRow.firstRow = 'Driver';
               }
               else
               {
                   mRow.firstRow = 'TD';
               }
           }
           else if(i>=firstRowAfterStairs.size()+2) {
            guestName = '';
            if(firstRowBeforeStairs[j].theGuestName != null && String.isNotBlank(firstRowBeforeStairs[j].theGuestName))
            {
            guestNameArray = firstRowBeforeStairs[j].theGuestName.split(','); 
           
            System.debug('Guest Array Name Value :::'+' '+guestNameArray);
            for (integer m = guestNameArray.size();m>0;m--) 
            {
                guestName = guestName + ' ' + guestNameArray[m-1];
                System.debug('Guest Name Value ::::'+' '+guestName); 
            }
                firstRowBeforeStairs[j].theGuestName = firstRowBeforeStairs[j].theNonRotator == true ?'*'+guestName: guestName;
            }
               mRow.firstRow = j < firstRowBeforeStairs.size() ? firstRowBeforeStairs[j].theGuestName: '';
               j++;
           } else  if(i ==firstRowAfterStairs.size() || i ==firstRowAfterStairs.size()+1) {
               
               mRow.firstRow = '**S T A I R S';
           }
           
           else
           {
                guestName = '';
                if(firstRowAfterStairs[i].theGuestName != null && String.isNotBlank(firstRowAfterStairs[i].theGuestName))
                {
                guestNameArray = firstRowAfterStairs[i].theGuestName.split(','); 
               
                System.debug('Guest Array Name Value :::'+' '+guestNameArray);
                for (integer m = guestNameArray.size();m>0;m--) 
                {
                    guestName = guestName + ' ' + guestNameArray[m-1];
                    System.debug('Guest Name Value ::::'+' '+guestName); 
                }
                    firstRowAfterStairs[i].theGuestName = firstRowAfterStairs[i].theNonRotator == true ?'*'+guestName: guestName;
                }
               mRow.firstRow = i < firstRowAfterStairs.size() ? firstRowAfterStairs[i].theGuestName : '';
           }
           
           
           if(i>=secondRowAfterStairs.size()+2) {
               
               guestName = '';
                if(secondRowBeforeStairs[k].theGuestName != null && String.isNotBlank(secondRowBeforeStairs[k].theGuestName))
                {
                guestNameArray = secondRowBeforeStairs[k].theGuestName.split(','); 
               
                System.debug('Guest Array Name Value :::'+' '+guestNameArray);
                for (integer m = guestNameArray.size();m>0;m--) 
                {
                    guestName = guestName + ' ' + guestNameArray[m-1];
                    System.debug('Guest Name Value ::::'+' '+guestName); 
                }
                    secondRowBeforeStairs[k].theGuestName = secondRowBeforeStairs[k].theNonRotator == true ?'*'+guestName: guestName;
                }
               
               mRow.secondRow = k < secondRowBeforeStairs.size() ? secondRowBeforeStairs[k].theGuestName : '';
               k++;
           }  else if(i ==secondRowAfterStairs.size() || i ==secondRowAfterStairs.size()+1) {
               
               mRow.secondRow = '**S T A I R S';
           }
           else
           {
                guestName = '';
                if(secondRowAfterStairs[i].theGuestName != null && String.isNotBlank(secondRowAfterStairs[i].theGuestName))
                {
                guestNameArray = secondRowAfterStairs[i].theGuestName.split(','); 
                for (integer m = guestNameArray.size();m>0;m--) 
                {
                    guestName = guestName + ' ' + guestNameArray[m-1];
                    System.debug('Guest Name Value ::::'+' '+guestName); 
                }
                    secondRowAfterStairs[i].theGuestName = secondRowAfterStairs[i].theNonRotator == true ?'*'+guestName: guestName;
                }
           mRow.secondRow= i < secondRowAfterStairs.size() ? secondRowAfterStairs[i].theGuestName : '';
           }
            if(i == 0)
            {
                guestName = '';
                if(thirdRow[i].theGuestName != null && String.isNotBlank(thirdRow[i].theGuestName))
                {
                guestNameArray = thirdRow[i].theGuestName.split(','); 
                for (integer m = guestNameArray.size();m>0;m--) 
                {
                    guestName = guestName + ' ' + guestNameArray[m-1];
                    System.debug('Guest Name Value ::::'+' '+guestName); 
                }
                    thirdRow[i].theGuestName = thirdRow[i].theNonRotator == true ?'*'+guestName: guestName;
                }
           mRow.thirdRow= i < thirdRow.size() ? thirdRow[i].theGuestName: '';
           }
           if(i < size)
           {
                guestName = '';
                if(fourthRow[i].theGuestName != null && String.isNotBlank(fourthRow[i].theGuestName))
                {
                guestNameArray = fourthRow[i].theGuestName.split(','); 
                for (integer m = guestNameArray.size();m>0;m--) 
                {
                    guestName = guestName + ' ' + guestNameArray[m-1];
                    System.debug('Guest Name Value ::::'+' '+guestName); 
                }
                    fourthRow[i].theGuestName = fourthRow[i].theNonRotator == true ?'*'+guestName: guestName;
                }
                
           mRow.fourthRow= i < fourthRow.size() ? fourthRow[i].theGuestName : '';
           }
           
           if(i == size-1)
           {
               if(theDriverSide == 'Right')
               {
                   mRow.fifthRow = 'Driver';
               }
               else
               {
                guestName = '';
                if(fifthRow[i].theGuestName != null && String.isNotBlank(fifthRow[i].theGuestName) && fifthRow[i].theSeatNumber != 1)
                {
                guestNameArray = fifthRow[i].theGuestName.split(','); 
                for (integer m = guestNameArray.size();m>0;m--) 
                {
                    guestName = guestName + ' ' + guestNameArray[m-1];
                    System.debug('Guest Name Value ::::'+' '+guestName); 
                }
                    mRow.fifthRow = fifthRow[i].theNonRotator == true ?'*'+guestName: guestName;
                }
                else
                {
                   mRow.fifthRow = 'TD';
                }
               }
           }
           else
           {
                guestName = '';
                if(fifthRow[i].theGuestName != null && String.isNotBlank(fifthRow[i].theGuestName))
                {
                guestNameArray = fifthRow[i].theGuestName.split(','); 
                for (integer m = guestNameArray.size();m>0;m--) 
                {
                    guestName = guestName + ' ' + guestNameArray[m-1];
                    System.debug('Guest Name Value ::::'+' '+guestName); 
                }
                    fifthRow[i].theGuestName = fifthRow[i].theNonRotator == true ?'*'+guestName: guestName;
                }
           mRow.fifthRow = i < fifthRow.size() ? fifthRow[i].theGuestName.replace(',','') : '';
           }
           System.debug('mRow ::::'+ mRow);
           mergeRow.add(mRow);
       }
       
       System.debug('mergeRow :::'+ mergeRow);
       integer thisCount;
       
       thisCount = 0;
       for(mySeating thisSeat : localSeating.seatingPlan) {
           theLocalCoachSeatPlan[thisCount].theSeatNumber  = thisSeat.theSeatNumber;
           theLocalCoachSeatPlan[thisCount].theGuestName  = thisSeat.theGuestName; 
           theLocalCoachSeatPlan[thisCount].theNonRotator  = thisSeat.theNonRotator; 
           theLocalCoachSeatPlan[thisCount].theAnnotation  = thisSeat.theAnnotation; 
           if (theLocalCoachSeatPlan[thisCount].theNonRotator == true) {
               //theLocalCoachSeatPlan[thisCount].theGuestName = '*' + theLocalCoachSeatPlan[thisCount].theGuestName; 
               theLocalCoachSeatPlan[thisCount].theGuestName = theLocalCoachSeatPlan[thisCount].theGuestName;   
           } 
           thisCount++;    
       }  
    }    
    
    public void  createSeatLayout() {
    //class to autofill the seat layout in order based on rooming list    
    }  
    
    private integer miniRotate(integer localRowsToMove, integer localCurrentSeat) {  
    // method to fid the next available seat  
        integer thisRow;
        integer thisSign;
        integer thisRowsFromEnd;
        integer thisColumn;
        integer addFactor;  
        // first setup all the variables for the seat position 
        thisRow =(localCurrentSeat-1-math.mod(localCurrentSeat-1,4))/4+1;    // which row of the seat plan - 1 always top no matter what orientation
        thisColumn =localCurrentSeat-4*(thisRow-1);                   // which col of teh seat plan
        thisRowsFromEnd = theTotalRows-thisRow;                           // num of rows from either top or bottom, whichever smaller
        if ( thisRowsFromEnd > thisRow-1 ) {
            thisRowsfromEnd = thisRow -1;
        }
        // the col the seat is in and the direction of rotation determines  plus or minus sign of the factor later on  
        thisSign = 1;
        if (thisColumn <3 ){  /// col 1 or 2                  
            if (theMethod == 'Clockwise') {
                thisSign = -1;
            }    
        } else {  // col 3 or 4
            if (theMethod == 'Clockwise') {
                thisSign = 1;
            }    
        }
        addFactor = 0;
        if ((thisColumn < 3 && thisRow <= localRowsToMove) || (thisColumn> 2 && theTotalRows-thisRow < localRowsToMove)) {
            addFactor = 2*thisSign*(-2*localRowsToMove+1+4*thisRowsFromEnd);
        } else {
            addFactor = thisSign*4*localRowsToMove;
        }
        return localCurrentSeat+addFactor;
    }
    
    public void rotateSeats() {
        // Create blank temp array size of coach
        for (integer counter = 0; counter <=theTotalRows*4+3; counter++) {
           theTempCoachSeatPlan.add(new seatingWrapper(counter, '', False, ''));
        }   
        // read in the JSON from the current TII into internal array
        theSeatingJSON = [SELECT rotate_seat_plan__C from tour_instance_itinerary__C where id = :theTourInstanceItineraryId limit 1].rotate_seat_plan__C;                  
        System.debug('Rotate Seat Value Data' + ' ' + theSeatingJSON);
        dayWiseSeatingPlan = [SELECT Day_Wise_Seating_Plan__c from tour_instance_itinerary__C where id = :theTourInstanceItineraryId limit 1].Day_Wise_Seating_Plan__c;
        popSeatWrapperFromJSON(theTempCoachSeatPlan);
        //popSeatWrapperFromJSON(tourInstanceItinerary);
        // Copy non rotators into new layout array
        integer  thisCount;
        thisCount = 0;
        for(SeatingWrapper thisSeat : theTempCoachSeatPlan) {           
           if (thisSeat.theNonRotator == true) {
               theCoachSeatPlan.add(new seatingWrapper(thisSeat.theSeatNumber, thisSeat.theGuestName, True, thisSeat.theAnnotation)); 
           } else {
               theCoachSeatPlan.add(new seatingWrapper(thisCount, '', False, ''));               
           }
           thisCount++;    
       }  
        // loop through old array and rotate guests into new postions in new array
        integer currentSeat;
         integer nextSeat;
        integer seatCounter;
        currentSeat = 1;
        for(SeatingWrapper thisSeat : theTempCoachSeatPlan) {           
           if (thisSeat.theNonRotator == false) {    // not a permanent seat so find a new position for it
               seatCounter = 0;
               nextSeat = miniRotate(1, currentSeat);
               if (theCoachSeatPlan[nextSeat-1].theNonRotator == false){
                   seatCounter++;
               }
               while ( seatCounter < theSeatsToRotate) {
                   nextSeat = miniRotate(1, nextSeat);    
                   if (theCoachSeatPlan[nextSeat-1].theNonRotator == false){
                       seatCounter++;
                   }    
               }
               if (theCoachSeatPlan[nextSeat-1].theGuestName == '') {  /// the proposed next seat is blank, so fill it
                   theCoachSeatPlan[nextSeat-1].theGuestName = thisSeat.theGuestName;   
                   theCoachSeatPlan[nextSeat-1].theSeatNumber  = thisSeat.theSeatNumber;
                   theCoachSeatPlan[nextSeat-1].theAnnotation  = thisSeat.theAnnotation; 
                   theCoachSeatPlan[nextSeat-1].theNonRotator  = thisSeat.theNonRotator;
               }  
           }
           currentSeat++;    
       }  
        // copy new array back into JSON on current TII    
    } 
    
    
    
    
 public void getCoachSeatingPlan(){
// method to get the JSON from the TII and extract it into array for seating plan 
// get the JSON from the TII
     try{     
        theSeatingJSON = [SELECT rotate_seat_plan__C from tour_instance_itinerary__C where id = :theTourInstanceItineraryId limit 1].rotate_seat_plan__C;
        System.debug('theSeatingJSON'+' '+theSeatingJSON);
        integer myCounter;
        mycounter = 0;
        //create blank seating array
       // myTemp = theSeatingJSON;
        //// now put the random names in the array
        for (integer counter = 0; counter <=theTotalRows*4+3; counter++) {
           theCoachSeatPlan.add(new seatingWrapper(counter, 'Guest FamilyName-' + string.valueof(counter), False, ''));
           if (math.mod(counter,10)==0) { // make every 10th guest a non rotator
             theCoachSeatPlan[counter].theNonRotator=TRUE;
           }    
        }  
        // temp fix to auto populate all guests
        List<Passenger__c> theGuests = new List<Passenger__c>();
        if (string.isblank(theSeatingJSON)){    //no JSON string populated so randomly assign names for testing purposes
          if(String.isNotBlank(theTourInstanceId)) {
             theGuests = [SELECT Salutation__c, Family_Name__c, First_Name__c, Preferred_Name__c,  Actual_Room_ID__c, 
                       Passenger_Class__c FROM Passenger__c WHERE Tour_Instance__c = :theTourInstanceId
                       AND Status__c != 'CX' AND Passenger_Status__c != 'Deleted' AND Passenger_Class__c = 'Passenger' ORDER BY Actual_Room_ID__c ASC
                       ];
          }    
          // now insert guest names into array for use on the PDF   
        
          for(passenger__C thePass : theGuests){
            if ( string.isblank(thePass.Preferred_Name__c) ){
                theCoachSeatPlan[mycounter].theGuestName = thePass.First_Name__C;    
            } else {
                theCoachSeatPlan[mycounter].theGuestName = thePass.Preferred_Name__C;         
            }
            theCoachSeatPlan[mycounter].theGuestName = theCoachSeatPlan[mycounter].theGuestName + ' ' + thePass.Family_Name__C;
            if (theCoachSeatPlan[mycounter].theNonRotator == true) {
               theCoachSeatPlan[mycounter].theGuestName = '*' + theCoachSeatPlan[mycounter].theGuestName;   
            }
            System.debug('Seating Plan'+' '+theCoachSeatPlan);
            mycounter++;
        }  
     } else{    ///there is a JSON string so parse that and insert into the internal array
         // myTemp = 'here';
          popSeatWrapperFromJSON(theCoachSeatPlan);   
     }
     } 
         catch(Exception e) {
      system.debug('TRACE: TOPS_seatRotationPDFControllerExp - getCoachSeatingPlan - Exception Message - ' + e.getMessage());
      system.debug('TRACE: TOPS_seatRotationPDFControllerExp - getCoachSeatingPlan - Exception Stack Trace - ' + e.getStackTraceString());
    }
   
  
}

    public class MergeList
    {
      public String startNumbering {get; set;}
      public String endNumbering {get; set;}
      public String firstRow {get; set;}
      public String secondRow {get; set;}
      public String thirdRow {get; set;}
      public String fourthRow {get; set;}
      public String fifthRow {get; set;}
    }
}