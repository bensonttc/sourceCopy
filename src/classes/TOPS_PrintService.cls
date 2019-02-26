//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_PrintService
// Description: Used in email print service.
//
// 15th January 2016    Leo Alves             Original
// 27th January 2016    Hemendra Singh Bhati  Modified (Task # T-465464) - Please see the task description for more details.
// 9th February 2016    Hemendra Singh Bhati  Modified (Task # T-471063) - Please see the task description for more details.
// 21st October 2016    Ravi Jain             Modified (Story# S-428354) - Please see the story description for more details.
// 20th October 2016    Ravi Jain             Modified (Story# S-428449) - Please see the story description for more details.
// 25th Nov 2016        Maksud Ali            Modified (Story# S-455645) - Please see the story description for more details.
// 31st Jan 2017        Ravi Jain             Modified (Story# S-461046) - Please see the story description for more details.
// 1st  Mar 2017        Abhishek Saxena       Modified(T-568301)
// 2 June 2017          Richard Boyd          I-276189 attachment name of optionals
// 24th Aug 2017        Abhishek Saxena       Modified(Replaced Request.Template__c with configRecord.Template__c)
// 06th Sep 2017        Abhishek Saxena       Modified(Added Label for Optional_Sign_Up_Contiki)
// 21 Sep 2017          Neeraj Kumawat        #I-293817(#T-633100) Adding Email Print Request Title in PDF file name
// 24 Nov 2017          Neeraj Kumawat        (I-303231) Added check for Ferry List template( getting TI id from TII)
public without sharing class TOPS_PrintService {
  // Private Data Members.
  private static Id theTourInstanceRecordId = null;
  
  // Code changes done by Ravi Jain for Story S-491089
  // Start - Ravi Jain - S-491089 - 24th Aug, 2018 - define the variable seatRotationSubject
  private static String seatRotationSubject = null;
  private static String templateName = null;
  // End - Ravi Jain - S-491089 - 24th Aug, 2018
  
  /*private static final Map<String, String> theRelatedObjectIdTypeMapping = new Map<String, String> {
    'Tour_Instance_Itinerary__c' => 'SELECT Supplier__c, Supplier__r.Name, Tour_Instance__c, Tour_Instance__r.Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c FROM Tour_Instance_Itinerary__c WHERE Id = ',
    'Tour_Optional__c' => 'SELECT Supplier__c, Supplier__r.Name, Tour_Instance__c, Tour_Instance__r.Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c FROM Tour_Optional__c WHERE Id = ',
    'Tour_Instance__c' => 'SELECT Operating_Product_Code__c, Departure_Code__c FROM Tour_Instance__c WHERE Id = '
  };*/
  
  // Code commented and changes done by Ravi Jain for Story S-428449
  // Code changes start here
     
  private static final Map<String, String> theRelatedObjectIdTypeMapping = new Map<String, String> {
    'Tour_Instance_Itinerary__c' => 'SELECT Supplier__c, Supplier__r.Name, Tour_Instance__c, Tour_Instance__r.Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c,City__c, Start_Date_of_Service__c FROM Tour_Instance_Itinerary__c WHERE Id = ',
    'Tour_Optional__c' => 'SELECT Supplier__c, Supplier__r.Name, Tour_Instance__c, Tour_Instance__r.Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c FROM Tour_Optional__c WHERE Id = ',
    'Tour_Instance__c' => 'SELECT Id, Operating_Product_Code__c, Departure_Code__c FROM Tour_Instance__c WHERE Id = '
  };
  // Code changes end here    

  /**
  * @description  This method is used generate email attachment.
  *
  * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
  * @return       Blob
  */
  public static Blob processAttachment(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    Blob pdf = null;
    try {
      system.debug('TRACE: TOPS_PrintService - processAttachment - request - ' + request);
      system.debug('TRACE: TOPS_PrintService - processAttachment - configRecord - ' + configRecord);

      // Instantiate visualforce page to be used, based on the visualforce page pointed in the config record.
      PageReference p = new PageReference('/apex/' + configRecord.Page_Or_Class__c);

      // Pass all parameters required to the visualforce page instantiated.
      p.getParameters().put('data', request.Data__c);
      //p.getParameters().put('relatedObjectId', request.Related_Object_Id__c); //comment added by Maksud Ali for Story S-455645
      p.getParameters().put('Parameters', request.Parameters__c);
      
      //1st  Mar 2017        Abhishek Saxena        (T-568301)
      //24th Aug 2017        Abhishek Saxena        Replaced Request.Template__c with configRecord.Template__c
      //06th Sep 2017        Abhishek Saxena       Modified(Added Label for Optional_Sign_Up_Contiki)
      //1st  May 2018        Calvin Goodenough     Added below template check for farewell email to bring in line with production code
      if(request.Template__c == 'Farewell Email' || request.Template__c == Label.Optional_Sign_up || configRecord.Template__c == Label.Hotel_Contact_List || request.Template__c == Label.Optional_Sign_Up_Contiki){  
        p.getParameters().put('processingData',request.Processing_Data__c);
        System.debug('TRACE: TOPS_PrintService - processingData' + request.Processing_Data__c);  
      }
      
      
      //Code added by Maksud Ali for story S-455645 
      if(request.Template__c == 'Optional Easy View') {
          p.getParameters().put('Id', request.Related_Object_Id__c);  
      }
      
      // Code changes done by Ravi Jain for story S-491089
      // Start - Ravi Jain - S-491089 - 24th Aug, 2018 - Pass the data 
      else if(request.Template__c == 'Seating Plan') {
          p.getParameters().put('relatedObjectId', request.Related_Object_Id__c);  
          p.getParameters().put('data', request.Data__c);  
          seatRotationSubject = request.Subject__c; 
      }
      // End - Ravi Jain - S-491089 - 24th Aug, 2018
      
      else {
          p.getParameters().put('relatedObjectId', request.Related_Object_Id__c);
      }
      //Code ended.
      
      // Create a blob object from the content passed to the page.
      if(Test.isRunningTest()) {
        pdf = Blob.valueOf('Test PDF');
      }
      else {
        pdf = p.getContent();
      }
    }
    catch(Exception e) {
        system.debug('TRACE: TOPS_PrintService - processAttachment - Exception Message - ' + e.getMessage());
        system.debug('TRACE: TOPS_PrintService - processAttachment - Exception Stack Trace - ' + e.getStackTraceString());
    }
    return pdf;
  }

  /**
  * @description  This method is used to generate PDF filename.
  *
  * @param        String theRelatedObjectId
  * @return       String theFileName
  */
  //private static String generatePDFFileName(String theRelatedObjectId, String theDocumentName) {
  // Code commented and changes done by Ravi Jain for Story S-428449
  // Code changes start here
  
    public static String generatePDFFileName(String theRelatedObjectId, String theDocumentName,String optionalTitle) {
    //Code changes end here
    String theFileName = theDocumentName + '.pdf';
    try {
      String relatedObjectId = String.escapeSingleQuotes(theRelatedObjectId);
      if(
        String.isNotBlank(relatedObjectId) &&
        (relatedObjectId.length() == 15 || relatedObjectId.length() == 18) &&
        Pattern.matches('^[a-zA-Z0-9]*$', relatedObjectId)
      ) {
         // Code changes done by Ravi Jain for Story S-428449
        // Code changes start here
        
        String city = '';
        //Code changes end here
        
        String theTourCode = '';
        String theHotelName = '';
        String theSupplierId = '';
        String theTourInstanceId = '';

        String theRelatedObjectIdType = Id.valueOf(theRelatedObjectId).getSObjectType().getDescribe().getName();
        system.debug('TRACE: TOPS_PrintService - generatePDFFileName - theRelatedObjectIdType - ' + theRelatedObjectIdType);

        if(theRelatedObjectIdTypeMapping.containsKey(theRelatedObjectIdType)) {
          String theQuery = theRelatedObjectIdTypeMapping.get(theRelatedObjectIdType) + '\'' + theRelatedObjectId + '\'';
          system.debug('TRACE: TOPS_PrintService - generatePDFFileName - theRelatedObjectId - ' + theRelatedObjectId);
          system.debug('TRACE: TOPS_PrintService - generatePDFFileName - theQuery - ' + theQuery);
          //List<Tour_Instance_Itinerary__c> tourInstanceItinerary =  new List<Tour_Instance_Itinerary__c>();

          for(Sobject theRecord : Database.query(theQuery)) {
                // Processing Related Object Id Of Type 'Tour_Instance_Itinerary__c' OR 'Tour_Optional__c'.
                if(theRelatedObjectIdType == 'Tour_Instance_Itinerary__c' || theRelatedObjectIdType == 'Tour_Optional__c') {
                   // Code changes done by Ravi Jain for Story S-428449
                   // Code changes start here
                   if(theRelatedObjectIdType == 'Tour_Instance_Itinerary__c')
                     {
                           
                           String tourInstance = String.valueOf(theRecord.get('Tour_Instance__c'));
              
                           city=String.valueOf(theRecord.get('City__c'));
                           Date dt = (Date)theRecord.get('Start_Date_of_Service__c');
                           String monthValue = '';
                           if(dt.month() == 1)
                           {
                              monthValue = 'Jan';
                           } 
                           else if(dt.month() == 2)
                           {
                              monthValue = 'Feb';
                           } 
                            else if(dt.month() == 3)
                           {
                              monthValue = 'Mar';
                           } 
                            else if(dt.month() == 4)
                           {
                              monthValue = 'Apr';
                           } 
                            else if(dt.month() == 5)
                           {
                              monthValue = 'May';
                           } 
                            else if(dt.month() == 6)
                           {
                              monthValue = 'Jun';
                           } 
                            else if(dt.month() == 7)
                           {
                              monthValue = 'Jul';
                           } 
                            else if(dt.month() == 8)
                           {
                              monthValue = 'Aug';
                           } 
                            else if(dt.month() == 9)
                           {
                              monthValue = 'Sep';
                           } 
                            else if(dt.month() == 10)
                           {
                              monthValue = 'Oct';
                           } 
                            else if(dt.month() == 11)
                           {
                              monthValue = 'Nov';
                           } 
                           else
                           {
                              monthValue = 'Dec';
                           } 
                           //Date d = dt.format('MM/dd/yyyy');
                           //Date dt = theRecord.get('Start_Date_of_Service__c');
                           
                           //String formattedDate = dt.format('DD MMM');

                           seatRotationSubject = theRecord.getSobject('Tour_Instance__r').get('Operating_Product_Code__c') + '-' + theRecord.getSobject('Tour_Instance__r').get('Departure_Code__c') + '-seating-'+ dt.day() + ' '+monthValue;
                     }
                    // Code changes end here
                 
                      // Determining The Supplier Name.
                      theSupplierId = String.valueOf(theRecord.get('Supplier__c'));
                      if(String.isNotBlank(theSupplierId)) {
                        theHotelName = String.valueOf(theRecord.getSobject('Supplier__r').get('Name'));
                      }

                      // Determining The Tour Code.
                      theTourInstanceId = String.valueOf(theRecord.get('Tour_Instance__c'));
                      if(String.isNotBlank(theTourInstanceId)) {
                        theTourInstanceRecordId = Id.valueOf(theTourInstanceId);
                        theTourCode = theRecord.getSobject('Tour_Instance__r').get('Operating_Product_Code__c') + '-' + theRecord.getSobject('Tour_Instance__r').get('Departure_Code__c');
                      }
            }
                // Processing Related Object Id Of Type 'Tour_Instance__c'
                else if(theRelatedObjectIdType == 'Tour_Instance__c') {
                  // Determining The Tour Code.
                  theTourInstanceRecordId = Id.valueOf(theRelatedObjectId);
                  theTourCode = theRecord.get('Operating_Product_Code__c') + '-' + theRecord.get('Departure_Code__c');
                }
          }
          if(theDocumentName == 'Multi Room List') {
          //theFileName = theTourCode + '-' + theHotelName + '-RoomingList.pdf';
            
           //trip code - Rooming_List - city - hotel name
           
           // Code commented and changes done by Ravi Jain for Story S-428449
           // Code changes start here
           theFileName = (String.isNotBlank(theTourCode) ? theTourCode + '-' : '') + 
                         ('Rooming_List') + ('-') +
                         (String.isNotBlank(city) ? city + '-' : '') +
                         (String.isNotBlank(theHotelName) ? theHotelName : ''); 
           // Code changes end here
          
          }
             // Code changes done by Ravi Jain for Story S-428354
            // Code changes start here
            else if(theDocumentName.equalsIgnoreCase('Passport List')) {
           //trip code - Passport_List
           theFileName = (String.isNotBlank(theTourCode) ? theTourCode + '-' : '') + 
                         ('Passport_List'); 
          } 
          // Code changes end here
          //Code added by Maksud Ali for Story - S-455645
          else if(theDocumentName.equalsIgnoreCase('Optional Easy View')) {
            theFileName = theTourCode + '-Optional_Easy_View.pdf';  
          } //Code Ended Here.
          
           // Code changes done by Ravi Jain for Story S-491089
           // Start - Ravi Jain - S-491089 - 24th Aug, 2018 - Set the pdf name
           else if(theDocumentName.equalsIgnoreCase('Seating Plan')) {
            theFileName = seatRotationSubject + '.pdf';  
          }
          // End - Ravi Jain - S-491089 - 24th Aug, 2018
            
           // Code changes done by Ravi Jain for Story S-461046
           // Code changes start here
             
          else if(theDocumentName == 'Guest Checklist') {
          //theFileName = TourCode-DepartureCode-Guest_Checklist.pdf;
           theFileName = (String.isNotBlank(theTourCode) ? theTourCode + '-' : '') + 'Guest_Checklist.pdf';
           // Code changes end here
          }
          else if(theDocumentName == 'Optional Sign up'){
              //I-276189
              if(optionalTitle!=null && optionalTitle!=''){
                  //#I-293817 Adding Email Print Request Title in PDF file name
                  theFileName = (String.isNotBlank(theTourCode) ? theTourCode + '-' : '') + 'OptionalSignup-'+optionalTitle + '.pdf';
              }else{
                  theFileName = (String.isNotBlank(theTourCode) ? theTourCode + '-' : '') + 'OptionalSignup' + '.pdf';
              }
          }
          else {
            theFileName = theTourCode + '-' + theDocumentName + '.pdf';
          }
        }
      }
    }
    catch(Exception e) {
        system.debug('TRACE: TOPS_PrintService - generatePDFFileName - Exception Message - ' + e.getMessage());
        system.debug('TRACE: TOPS_PrintService - generatePDFFileName - Exception Stack Trace - ' + e.getStackTraceString());
    }
    return theFileName;
  }

  /**
  * @description  This method is used to determine the tour director's email address.
  *
  * @param        Id createdById
  * @return       String theEmailAddress
  */
  private static String determineTourDirectorEmailAddress(Id createdById) {
    String theEmailAddress = '';
    try {
      if(theTourInstanceRecordId != null) {
        for(Tour_Instance__c theRecord : [SELECT Allocated_TD__c, Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c, Allocated_TD__r.TD_Email_for_Supplier_Office_use__c
                                          FROM Tour_Instance__c WHERE Id = :theTourInstanceRecordId]) {
          if(theRecord.Allocated_TD__c != null) {
            if(templateName == 'Seating Plan')
            {
               theEmailAddress = theRecord.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c;
            }
            else
            {
                theEmailAddress = theRecord.Allocated_TD__r.Crew_Email_for_Supplier_Office_use__c;
            }
          }
        }
      }
    }
    catch(Exception e) {
      theEmailAddress = [SELECT Email from User where Id = :createdById].Email;

        system.debug('TRACE: TOPS_PrintService - determineTourDirectorEmailAddress - Exception Message - ' + e.getMessage());
        system.debug('TRACE: TOPS_PrintService - determineTourDirectorEmailAddress - Exception Stack Trace - ' + e.getStackTraceString());
    }

    system.debug('TRACE: TOPS_PrintService - determineTourDirectorEmailAddress - theEmailAddress - ' + theEmailAddress);
    return theEmailAddress;
  }

   /**
  * @description  #I-293817 This method is used to get title of Email print request object.
  *
  * @param        Email_Print_Request__c request
  * @return       optionalTitle: Title of Email print request object
  */
    public static String getOptionalTitle(Email_Print_Request__c request){
        String processingData=request.Processing_Data__c;
        //Retrieving dates from the JSON data
        if(!(processingData == null || processingData.equalsIgnoreCase('none'))){
            Map<String, Object> jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped(processingData);
            if(jsonUntyped!=null){
                String optionalTitle=String.valueOf(jsonUntyped.get('title'));
                return optionalTitle;
            }else{
                return '';
            }
        }else{
            return '';
        }
    }
  /**
  * @description  This method is used generate email attachment.
  *
  * @param        Email_Print_Request__c request, Email_Print_Request_Config__c configRecord
  * @return       TOPS_EmailWrapper
  */
  public static TOPS_EmailWrapper createEmailWrapper(Email_Print_Request__c request, Email_Print_Request_Config__c configRecord) {
    TOPS_EmailWrapper theEmailWrapper = null;
    try {
       //#I-293817 Calling getOptionalTitle for getting the title of Email Print Request
       String optionalTitle=getOptionalTitle(request);
      // Generating PDF File Name.
      String theFileName = generatePDFFileName(request.Related_Object_Id__c, configRecord.Template__c,optionalTitle);
       
      system.debug('FileName : ' + theFileName);
      // Generating Required PDF.
      Blob pdf = processAttachment(request, configRecord);

      // Determining FROM Email Address.
      templateName = configRecord.Template__c;
      String creatorEmail = determineTourDirectorEmailAddress(request.CreatedById);

      // Instantiating Email Wrapper.
      theEmailWrapper = new TOPS_EmailWrapper(
        creatorEmail,
        creatorEmail,
        configRecord.Template__c,
        configRecord.Template__c,
        new Map<String, Blob> {
          theFileName => pdf
        }
      );
      // Code for updating the Rotate_seat_plan__c in Tour Itinerary
      //Tour_Instance__c tc = new Tour_ Inctance__C (id = request.Related_Object_Id__c, Rotate_seat_plan__c = 'Hello');
      EmailDataWrapper wrapper = getTourInstanceData(request.Related_Object_Id__c, configRecord.Template__c);
      theEmailWrapper.tdId = wrapper.tdId;
      theEmailWrapper.replyTo = creatorEmail;
      theEmailWrapper.regionCode = wrapper.regionCode;
      theEmailWrapper.emailSubject = wrapper.subject;
      theEmailWrapper.brand = wrapper.brand;
      system.debug('TRACE: TOPS_PrintService - createEmailWrapper - theEmailWrapper - ' + theEmailWrapper);
    }
    catch(Exception e) {
      system.debug('TRACE: TOPS_PrintService - createEmailWrapper - Exception Message - ' + e.getMessage());
      system.debug('TRACE: TOPS_PrintService - createEmailWrapper - Exception Stack Trace - ' + e.getStackTraceString());
    }
    return theEmailWrapper;
  }

  /* helper method - constructs subject of email wrapper */
    private static EmailDataWrapper getTourInstanceData(String relatedObjectId, String theDocumentName)
    {
        String tdId, regionCode, subject, brand;
        if (!new Set<String>{'Personal Menu', 'Menu Sign Up'}.contains(theDocumentName))
        {
            //(I-303231) Added check for Ferry List template( getting TI id from TII) Neeraj Kumawat 24 November 2017
            System.debug('theDocumentName Value>>>>='+theDocumentName);
            if(theDocumentName!=null && (theDocumentName=='Ferry List' || theDocumentName.equalsIgnoreCase('Seating Plan'))){
                List<Tour_Instance_Itinerary__c> tiiList=[Select Id, Tour_Instance__r.Id From Tour_Instance_Itinerary__c Where Id =: relatedObjectId];
                if(tiiList.size()>0){
                    relatedObjectId=tiiList[0].Tour_Instance__r.Id;
                }
            }
            Tour_Instance__c tourInstance = [SELECT Operating_Product_Code__c, Departure_Code__c, Allocated_TD__c, Brand_Name__c
                                     FROM Tour_Instance__c WHERE Id =: relatedObjectId][0];
            tdId = tourInstance.Allocated_TD__c;
            regionCode = tourInstance.Operating_Product_Code__c.subString(0, 2);
            
            //Code added by Maksud Ali for Story - 455645
            if(theDocumentName.equalsIgnoreCase('Optional Easy View')) {
                subject = tourInstance.Operating_Product_Code__c + '-' + tourInstance.Departure_Code__c + '-Optional_Easy_View';
            }
            
            // Code changes done by Ravi Jain for Story S-491089
            // Start - Ravi Jain - S-491089 - 24th Aug, 2018 - Set the subject
            if(theDocumentName.equalsIgnoreCase('Seating Plan')) {
                subject = seatRotationSubject;
                
            }
            // End - Ravi Jain - S-491089 - 24th Aug, 2018
            
            else if(theDocumentName.equalsIgnoreCase('Guest Checklist')) {
                subject = tourInstance.Operating_Product_Code__c + '-' + tourInstance.Departure_Code__c + '-Guest_Checklist.pdf';
            }
            // Code changes end here
            
            else {
                subject = tourInstance.Operating_Product_Code__c + '-' + tourInstance.Departure_Code__c + '-' + theDocumentName;
            }
            brand = tourInstance.Brand_Name__c;
        }
        else
        {
            Tour_Optional__c tourOptional = [SELECT Supplier__r.Name, Tour_Instance__r.Operating_Product_Code__c, Tour_Instance__r.Departure_Code__c, Tour_Instance__r.Allocated_TD__c, Tour_Instance__r.Brand_Name__c
                                             FROM Tour_Optional__c WHERE Id =: relatedObjectId];
            tdId = tourOptional.Tour_Instance__r.Allocated_TD__c;
            regionCode = tourOptional.Tour_Instance__r.Operating_Product_Code__c.subString(0, 2);
            if(tourOptional.Supplier__r.Name!=null){
                subject = tourOptional.Tour_Instance__r.Operating_Product_Code__c + '-' + tourOptional.Tour_Instance__r.Departure_Code__c + '-' + theDocumentName + '-' + tourOptional.Supplier__r.Name;
            }else{
                 subject = tourOptional.Tour_Instance__r.Operating_Product_Code__c + '-' + tourOptional.Tour_Instance__r.Departure_Code__c + '-' + theDocumentName;
            }
            brand = tourOptional.tour_Instance__r.Brand_Name__c;
        }
        return new EmailDataWrapper(tdId, regionCode, subject, brand);
    }

  class EmailDataWrapper
  {
      protected String tdId;
      protected String regionCode;
      protected String subject;
      protected String brand;

      EmailDataWrapper(String tdId, String regionCode, String subject, String brand)
      {
          this.tdId = tdId;
          this.regionCode = regionCode;
          this.subject = subject;
          this.brand = brand;
      }
  }
}