//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TestDataFactory
// Description: This class is used to generate test data for apex test classes.
//
// 27th January 2016    Hemendra Singh Bhati  Original (Task # T-465464)
//
public class TestDataFactory {
  /**
  * @description  This method is used to instantiate/insert a new record of type "Email_Print_Request__c".
  *
  * @param        String theSubject, String theData, String theEmailAddresses, String theStatus, String theTemplate, Boolean isInsert
  * @return       Email_Print_Request__c theEmailPrintRequest
  */
  public Email_Print_Request__c createEmailPrintRequest(
    String theSubject,
    String theData,
    String theEmailAddresses,
    String theStatus,
    String theTemplate,
    Boolean isInsert
  ) {
    Email_Print_Request__c theEmailPrintRequest = new Email_Print_Request__c(
      Subject__c = theSubject,
      Data__c = theData,
      Email_Addresses__c = theEmailAddresses,
      Status__c = theStatus,
      Template__c = theTemplate
    );
    if(isInsert) {
      insert theEmailPrintRequest;
    }
    return theEmailPrintRequest;
  }

  /**
  * @description  This method is used to instantiate/insert a new record of type "Email_Print_Request_Config__c".
  *
  * @param        String theApexPageOrClass, String theFieldSets, String theDefaultSubject, String theDefaultBody,
  *               String theTemplate, String theType, Boolean isInsert
  * @return       Email_Print_Request_Config__c theEmailPrintRequestConfig
  */
  public Email_Print_Request_Config__c createEmailPrintRequestConfig(
    String theName,
    String theApexPageOrClass,
    String theFieldSets,
    String theDefaultSubject,
    String theDefaultBody,
    String theTemplate,
    String theType,
    Boolean isInsert
  ) {
    Email_Print_Request_Config__c theEmailPrintRequestConfig = new Email_Print_Request_Config__c(
      Page_or_Class__c = theApexPageOrClass,
      Field_Sets__c = theFieldSets,
      Default_Subject__c = theDefaultSubject,
      Default_Body__c = theDefaultBody,
      Template__c = theTemplate,
      Type__c = theType
    );
    if(isInsert) {
      insert theEmailPrintRequestConfig;
    }
    return theEmailPrintRequestConfig;
  }

  /**
  * @description  This method is used to instantiate/insert a new record of type "Tour_Instance__c".
  *
  * @param        String departmentCode, String operatingProductCode,  Boolean isInsert
  * @return       Email_Print_Request__c theEmailPrintRequest
  */
  public Tour_Instance__c createTourInstance(
    String departmentCode,
    String operatingProductCode,
    Boolean isInsert
  ) {
    Tour_Instance__c theTestTourInstance = new Tour_Instance__c();
    theTestTourInstance.Departure_Code__c = departmentCode;
    theTestTourInstance.Operating_Product_Code__c = operatingProductCode;
    if(isInsert) {
      insert theTestTourInstance;
    } 
    return theTestTourInstance;
  }

  /**
  * @description  This method is used to instantiate/insert a new record of type "Passenger__c".
  *
  * @param        String name, ID tourId,  Boolean isInsert
  * @return       Email_Print_Request__c theEmailPrintRequest
  */
  public Passenger__c createPassenger(
    String name,
    ID tourId,
    Boolean isInsert
  ) {
    Passenger__c theTestPassenger = new Passenger__c();
    theTestPassenger.Name = name;
    theTestPassenger.Passenger_External_Id__c = 'Test' + String.valueOF(DateTime.Now().millisecondGmt());
    theTestPassenger.Date_Of_Birth__c = Date.Today().addYears(-25);
    theTestPassenger.Tour_Instance__c = tourId; 
    if(isInsert) {
      insert theTestPassenger;
    }
    return theTestPassenger;
  }

  /**
  * @description  This method is used to instantiate/insert a new record of type "Tour_Instance_Itinerary__c".
  *
  * @param        String name, ID tourId, Boolean isInsert
  * @return       Email_Print_Request__c theEmailPrintRequest
  */
  public Tour_Instance_Itinerary__c createTourInstanceItinerary(
    ID accID,
    ID tourId,
    Boolean isInsert
  ) {
    Tour_Instance_Itinerary__c theTestTII = new Tour_Instance_Itinerary__c ();
    theTestTII.Supplier__c = accID;
    theTestTII.Tour_Instance__c = tourId; 
    if(isInsert) {
      insert theTestTII;
    }
    return theTestTII;
  }
  
  /**
  * @description  This method is used to instantiate/insert a new record of type "Tour_Optional__c".
  *
  * @param        String name, ID tourId, ID optionalId,  Boolean isInsert
  * @return       Tour_Optional__c theTourOptional
  */
  public Tour_Optional__c createTourOptional(
    String name,
    ID tourId,
    ID optionalId,
    Boolean isInsert
  ) {
    Tour_Optional__c tourOpt = new Tour_Optional__c();
    tourOpt.Name = name;
    tourOpt.Optional__c = optionalId;
    tourOpt.Tour_Instance__c = tourId; 
    if(isInsert) {
      insert tourOpt;
    }
    return tourOpt;
  }

  /**
  * @description  This method is used to instantiate/insert a new record of type "Optional__c".
  *
  * @param        String name, Boolean isInsert
  * @return       Tour_Optional__c theOptional
  */
  public Optional__c createOptional(
    String name,
    Boolean isInsert
  ) {
    Optional__c opt = new Optional__c();
    opt.Name = name;
    if(isInsert) {
      insert opt;
    }
    return opt;
  }

  /**
  * @description  This method is used to instantiate/insert a new record of type "Account".
  *
  * @param        String theFirstName, String theLastName, Boolean isInsert
  * @return       Account theTestAccount
  */
  public Account createAccount(String theFirstName, String theLastName, Boolean isInsert) {
    Account theTestAccount = new Account(
      FirstName = theFirstName,
      LastName = theLastName
    );
    if(isInsert) {
      insert theTestAccount;
    }
    return theTestAccount;
  }
}