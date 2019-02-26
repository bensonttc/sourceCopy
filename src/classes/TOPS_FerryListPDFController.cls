//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_FerryListPDFController
// Description: Used in get list of passenger and other information the get PDF data for passengers
//
// 1st feb 2016   Kirti Agarwal  Original (Task # T-467687)
// 04th Jan 2017    Ravi Jain              Modified (Story# S-455844) - Please see the story description for more details.
//
public without sharing class TOPS_FerryListPDFController {
   public String colourCodeVal {get; set;}
   public String fontSize {get; set;}
   public Passenger__c tourDriver;
   public Passenger__c tourDirector;
   public List<Passenger__c> passengerList{get; set;}
   public Tour_Instance__c tourRecord{get; set;}
   public List<WrapperPassenger> wrapperPassengerList{get; set;}
   public String tourDriverName  {get; set;}
   public Integer totalAdult {get; set;}
   public Integer totalChild {get; set;}
   public Integer totalInfant {get; set;}
   public Integer totalPassenger {get; set;}
   public Tour_Instance_Itinerary__c tourInstanceItineraryRec{get; set;}
   public String theSupplierName { get; private set; }
   public Boolean showPassportNumbers { get; private set; }
   public Boolean showSpecialAssistance { get; private set; }

   // Public Data Members.
   public Boolean hasTourDirector { get; private set; }
   public Boolean hasDriver { get; private set; }
   public Boolean hasCook { get; private set; }
   public Boolean hasOSTM { get; private set; }
   public Boolean hasNationalGuide { get; private set; }
    
   // Code changes done by Ravi Jain for story S-455844   
   public String userLocale { get; private set; }   

   // Private Data Members.
   private final String TOUR_DIRECTOR = 'Tour Director';
   private final String DRIVER = 'Driver';
   private final String COOK = 'Cook';
   private final String OSTM = 'OSTM';
   private final String NATIONAL_GUIDE = 'National Guide';
   private final Map<Integer, String> theCrewMembersRanking = new Map<Integer, String> {
     1 => Label.Ferry_List_Courier,
     2 => Label.Ferry_List_Driver,
     3 => Label.Ferry_List_Cook,
     4 => Label.Ferry_List_OSTM,
     5 => Label.Ferry_List_National_Guide
   };
   private Map<Integer, Passenger__c> theCrewMembers;
   private String tourInstanceItinerary, tourInstance, regionCode;

   public TOPS_FerryListPDFController() {
        totalAdult = 0;
        totalChild = 0;
        totalInfant = 0;
        totalPassenger = 0;
        colourCodeVal = '';
        tourDriverName = '';
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        tourInstanceItinerary = parameters.get('relatedObjectId');
        fontSize = '14px';
        String query = 'SELECT Id, Supplier__r.Name, Tour_Instance__c, Start_Date_of_Service__c, Ferry_Booking_Reference__c, Ferry_Direction_Travel__c FROM Tour_Instance_Itinerary__c Where id =\'' + tourInstanceItinerary + '\'';
        for(Tour_Instance_Itinerary__c tii : database.query(query)) {
            tourInstance = tii.Tour_Instance__c;
            tourInstanceItineraryRec = tii;
            theSupplierName = tii.Supplier__r.Name;
        }
        wrapperPassengerList = new List<wrapperPassenger>();
        getRegionCode();
        getPassengers();

        showPassportNumbers = false;
        String theParameters = parameters.get('Parameters');
        if(String.isNotBlank(theParameters) && theParameters.equalsIgnoreCase('Passport Numbers')) {
          showPassportNumbers = true;
        }
  }

   /**
     * @description  This method is used to get colour code of passengers pdf
     * @created By : Kirti Agarwal
     * @created Date : 1st feb 2016
     * @return       : void
     */
    public void getRegionCode() {
        String productCode = '';
        String dateVal;
        for(Tour_Instance__c  tour : [SELECT id, Name, Operating_Product_Code__c,Product_Name__c,
                                              Travel_Director__c,Instance_Code__c,Start_Date__c,
                                              Ferry_Direction_Travel__c,Coach_Registration_Number__c
                                      FROM Tour_Instance__c
                                      WHERE id=: tourInstance]) {
          productCode = tour.Operating_Product_Code__c;
          tourRecord = tour;
        }

        if(productCode != '' && productCode.length() >= 2) {
          regionCode = productCode.subString(0,2);
        }
    }

    /**
    * @description  This method is used to get list of passengers
    * @created By : Kirti Agarwal
    * @created Date : 1st feb 2016
    * @return       : void
    */
    public void getPassengers() {
      try {
          
        // Code changes done by Ravi Jain for story S-455844   
        userLocale = UserInfo.getLocale();
          
        hasTourDirector = hasDriver = hasCook = hasOSTM = hasNationalGuide = false;
        totalPassenger = 0;
        passengerList = new List<Passenger__c>();
        theCrewMembers = new Map<Integer, Passenger__c>();

        List<Passenger__c> passengersToQuery;
        
        /*Changes done by Maksud Ali. for Case 00180775, (I have added an extra clause in where condition which is status__C != 'CX')*/
        if (!Test.isRunningTest())
          passengersToQuery = [SELECT Name, Family_Name__c, Other_Special_Requirements__c, First_Name__c, Age__c, Gender__c, Nationality__c,
                              Passport_Issue_Date__c, Passport_Expiry_Date__c, Passport_Number__c, Country_of_Issue__c, Date_of_Birth__c, Disabilities__c,
                              Passenger_Class__c FROM Passenger__c WHERE Ferry_List_Incl__c = true and Passenger_Status__c != 'Deleted' AND Tour_Instance__c = :tourInstance AND Ferry_List_Incl__c = true AND status__C != 'CX' order by Family_Name__c, First_Name__c asc ];
        else
          passengersToQuery = [SELECT Name, Family_Name__c, Other_Special_Requirements__c, First_Name__c, Age__c, Gender__c, Nationality__c,
                              Passport_Issue_Date__c, Passport_Expiry_Date__c, Passport_Number__c, Country_of_Issue__c, Date_of_Birth__c, Disabilities__c,
                              Passenger_Class__c FROM Passenger__c WHERE Passenger_Status__c != 'Deleted' AND Tour_Instance__c = :tourInstance AND Ferry_List_Incl__c = true AND status__C != 'CX' order by Family_Name__c, First_Name__c asc ];
        for(Passenger__c theRecord : passengersToQuery) {
          if(theRecord.Passenger_Class__c == TOUR_DIRECTOR) {
            hasTourDirector = true;
            theCrewMembers.put(1, theRecord);
          }
          else if(theRecord.Passenger_Class__c == DRIVER) {
            hasDriver = true;
            theCrewMembers.put(2, theRecord);
          }
          else if(theRecord.Passenger_Class__c == COOK) {
            hasCook = true;
            theCrewMembers.put(3, theRecord);
          }
          else if(theRecord.Passenger_Class__c == OSTM) {
            hasOSTM = true;
            theCrewMembers.put(4, theRecord);
          }
          else if(theRecord.Passenger_Class__c == NATIONAL_GUIDE) {
            hasNationalGuide = true;
            theCrewMembers.put(5, theRecord);
          }
          else {
            if(String.isNotBlank(theRecord.Other_Special_Requirements__c)) {
              showSpecialAssistance = true;
            }
            passengerList.add(theRecord);
          }

          totalPassenger++;
        }
        system.debug('TRACE: TOPS_FerryListPDFController - getPassengers - theCrewMembers - ' + theCrewMembers);
        system.debug('TRACE: TOPS_FerryListPDFController - getPassengers - passengerList - ' + passengerList);

        String theAge;
        Passenger__c theCrewMember = null;

        // Processing Tour Crew Members.
        for(Integer theRank : theCrewMembersRanking.keySet()) {
          if(theCrewMembers.containsKey(theRank)) {
            theCrewMember = theCrewMembers.get(theRank);

            theAge = getAD_CH_NF(theCrewMember);
            getTotalForPassenger(theAge);

            wrapperPassengerList.add(new WrapperPassenger(
              theCrewMembersRanking.get(theRank),
              theCrewMember,
              getFullName(theCrewMember),
              theAge
            ));
          }
        }

        // Processing Tour Passengers.
        for(Passenger__c theRecord : passengerList) {
          theAge = getAD_CH_NF(theRecord);
          getTotalForPassenger(theAge);

          wrapperPassengerList.add(new WrapperPassenger(
            '',
            theRecord,
            getFullName(theRecord),
            theAge
          ));
        }
        system.debug('TRACE: TOPS_FerryListPDFController - getPassengers - wrapperPassengerList - ' + wrapperPassengerList);

        getFontSizeBasedOnRecords(totalPassenger);
      }
      catch(Exception e) {
        system.debug('TRACE: TOPS_FerryListPDFController - getPassengers - Exception Message - ' + e.getMessage());
        system.debug('TRACE: TOPS_FerryListPDFController - getPassengers - Exception Stack Trace - ' + e.getStackTraceString());
      }
    }

    /**
     * @description  This method is used to get total passenger
     * @created By : Kirti Agarwal
     * @created Date : 1st feb 2016
     * @return       : void
     */
    private void getTotalForPassenger(String age) {
      if(age == 'AD') {
         totalAdult++;
      }else if(age == 'CH') {
         totalChild++;
      }else if(age == 'NF') {
         totalInfant++;
      }
    }

    /**
     * @description  This method is used to get full name
     * @created By : Kirti Agarwal
     * @created Date : 27th jan 2015
     * @return       : void
     */
    private String getFullName(Passenger__c pass) {
      String fullName = '';
          if(pass.First_Name__c != null) {
             fullname = pass.First_Name__c + ' ';
            }
            if(pass.First_Name__c != null) {
             fullname += pass.Family_Name__c;
            }
            return fullName;
    }

    /**
     * @description  This method is used to get age
     * @created By : Kirti Agarwal
     * @created Date : 1st feb 2016
     * @return       : void
     */
    private String getAD_CH_NF(Passenger__c pass) {
      String AD_CH_NF = '';
      Integer ageVal = Integer.valueOF(pass.Age__c);
      if(ageVal  != null) {
         if(ageVal  >= 18) {
            AD_CH_NF = 'AD';
         }
         else if(ageVal  < 18 && ageVal > 3) {
            AD_CH_NF = 'CH';
         }
         else if( ageVal  <= 3) {
            AD_CH_NF = 'NF';
         }
      } else{
          AD_CH_NF = 'AD';
      }
      return AD_CH_NF;
    }

    /**
     * @description  This method is used to get font size of passengers pdf
     * @created By : Kirti Agarwal
     * @created Date : 1st feb 2016
     * @return       : void
     */
    private void getFontSizeBasedOnRecords(Integer listSize) {
        addBlankRow();
        //Changes done by Maksud Ali for Story - S-438217
        /*
        if(listSize <= 15 && listSize >= 0) {
            fontSize = '14px';
        }else if(listSize <= 20 && listSize > 15) {
            fontSize = '13px';
        }else if(listSize <= 25 && listSize > 20) {
            fontSize = '12px';
        }else if(listSize <= 30 && listSize > 25) {
            fontSize = '11px';
        }else if(listSize <= 35 && listSize > 30) {
            fontSize = '10px';
        }else {
          fontSize = '9px';
        }
        */
        
        if(listSize >= 56 && listSize <= 58) {
          fontSize = '8pt';
        } 
        else if(listSize >= 52 && listSize <= 55) {
          fontSize = '8.5pt';
        } 
        else if(listSize >= 43 && listSize <= 51) {
          fontSize = '9pt';
        }
        //End Changes for Story - S-438217
    }

    /**
     * @description  This method is used to get blank rows
     * @created By : Kirti Agarwal
     * @created Date : 1st feb 2016
     * @return       : void
     */
    private void addBlankRow() {
       Integer loopSize = 0;
       if(wrapperPassengerList.size() < 15) {
          loopSize = 30 - wrapperPassengerList.size();
       }
       for(Integer i=0; i<loopSize ; i++) {
         wrapperPassengerList.add(new wrapperPassenger('', new Passenger__c(), '', ''));
       }
    }


    class WrapperPassenger {
       public String passengerClass { get; set; }
       public Passenger__c pass{get;set;}
       public String fulName{get;set;}
       public String age{get;set;}

       public WrapperPassenger(String theClass, Passenger__c passP, String nameP, String ageP) {
         passengerClass = theClass;
         fulName = nameP;
         pass = passP;
         age = ageP;
       }
    }
}