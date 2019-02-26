//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_FlightListPDFController
// For Apex Page: TOPS_FlightListPDF
// Description: This apex controller is used to generate PDF of flight passengers.
//
// 29th January 2016   Hemendra Singh Bhati   Original (Task # T-467673)
//
// 17 Feb 2016, Maksud Ali Modified (Story# S-455965) - Please see the story description for more details.
//
public without sharing class TOPS_FlightListPDFController {
  // Private Data Members.
  private String theTourInstanceId { get; set; }
  private String theRegionCode { get; set; }

  // Public Data Members.
  public String theLanguage { get; private set; }
  //Changes Start,Done by Maksud Ali for Story : S-455965
  public List<StaticImageManager> theFooterLogoList { get; private set; }
  //End changes
  public String theColourCode { get; private set; }
  public String theFontSize { get; private set; }
  public List<Passenger__c> vacantFlightSeats { get; private set; }
  public List<Passenger__c> theFlightPassengersList { get; private set; }
  public String vacantFlightSeatsCSS { get; private set; }
  public String theInstanceCode { get; private set; }

  // The Class Constructor.
  public TOPS_FlightListPDFController() {
    theTourInstanceId = ApexPages.currentPage().getParameters().get('relatedObjectId');
    getFlightPassengersList();
    getColorCode();
    getPDFLanguage();
  }

  /**
  * @description  This method is used to fetch all flight passengers for the tour instance Id passed as the URL parameter.
  *
  * @param        void
  * @return       void
  */
  public void getFlightPassengersList() {
    //Changes Done by Nishant Singh for 00189158 added filter for PassengerClass
    //Changes Start
    theFlightPassengersList = [SELECT First_Name__c, Family_Name__c FROM Passenger__c WHERE Status__c != 'CX' and Tour_Instance__c = :theTourInstanceId and Passenger_Class__c='Passenger' order by Family_Name__c];
    //Changes End
    getVacantFlightSeatsList();
    getCSS();
    computeFontSize(Integer.valueOf(theFlightPassengersList.size()));
  }

  /**
  * @description  This method is used to determine vacant flight seats.
  *
  * @param        void
  * @return       void
  */
  private void getVacantFlightSeatsList() {
    vacantFlightSeats = new List<Passenger__c>();
    if(theFlightPassengersList.size() < 42) {
      Integer totalFlightPassengers = theFlightPassengersList.size();
      for(Integer i = totalFlightPassengers; i <= 42; i++) {
        vacantFlightSeats.add(new Passenger__c(Name = 'Vacant Flight Seat'));
      }
    }
  }

  /**
  * @description  This method is used to determine CSS classes.
  *
  * @param        void
  * @return       void
  */
  private void getCSS() {
    if(theFlightPassengersList.size() > 0 && vacantFlightSeats.size() > 0) {
      if(Math.mod(theFlightPassengersList.size(), 2) == 0) {
        vacantFlightSeatsCSS = 'pRowEven, pRowOdd';
      }
      else {
        vacantFlightSeatsCSS = 'pRowOdd, pRowEven';
      }
    }
  }

  /**
  * @description  This method is used to compute font-size.
  *
  * @param        void
  * @return       void
  */
  private void computeFontSize(Integer totalFlightPassengers) {
    if(totalFlightPassengers <= 40 && totalFlightPassengers >= 0) {
      theFontSize = '14px';
    }
    else if(totalFlightPassengers <= 45 && totalFlightPassengers > 40) {
      theFontSize = '13px';
    }
    else if(totalFlightPassengers <= 50 && totalFlightPassengers > 45) {
      theFontSize = '12px';
    }
    else if(totalFlightPassengers <= 55 && totalFlightPassengers > 50) {
      theFontSize = '11px';
    }
    else if(totalFlightPassengers <= 60 && totalFlightPassengers > 55) {
      theFontSize = '10px';
    }
    else {
      theFontSize = '9px';
    }
  }

  /**
  * @description  This method is used to determine the color code of the flight passengers PDF.
  *
  * @param        void
  * @return       void
  */
  //Changes Start,Done by Maksud Ali for Story : S-455965
  public void getColorCode() {
    String theOperatingProductCode;
    theFooterLogoList = new List<StaticImageManager>();
    String specialBrand = '';
    // Extracting operating product code for the tour instance Id passed as the URL parameter.
    for(Tour_Instance__c  theRecord : [SELECT Instance_Code__c, Special_Brand__c,Operating_Product_Code__c FROM Tour_Instance__c WHERE Id = :theTourInstanceId]) {
      theOperatingProductCode = theRecord.Operating_Product_Code__c;
      theInstanceCode = theRecord.Instance_Code__c;
      specialBrand = theRecord.Special_Brand__c;
    }

    // Determining the region code.
    if(String.isNotBlank(theOperatingProductCode) && theOperatingProductCode.length() >= 2) {
      theRegionCode = theOperatingProductCode.subString(0, 2);
    }

    // Extracting configuration information.
    for(Region_Code_Brand_Mapping__mdt theRecord : [SELECT DeveloperName, Brand__c, Colour__c, Logos__c FROM Region_Code_Brand_Mapping__mdt 
                                                    WHERE DeveloperName = :theRegionCode]) {
      theColourCode = theRecord.Colour__c;
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
  }
    //End changes
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
}