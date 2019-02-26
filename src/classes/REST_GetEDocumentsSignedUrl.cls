/*-------------------------------------------------------
*----------API call for my documents view and download-----------------
*----------Used by MTS-----------------------------------
*--------------------------------------------------------
*
*  Post request parameters  *
{ 
"passenger":{
"Id":"a2D5E00000009U5UAI",
"sellingCompanyShortName": "CHUSAS",
"BookingRef": "A242440",
"actionType":"pageLoad",
"documentId":null
    }
} 
*
*Id = id of the selected passenger
*sellingCompanyShortName = selling company name for the selected passenger
*BookingRef = Booking Number of the booking for the selected passenger
*actionType = action type defined by user ('single' or 'multiple', 'pageLoad')
*documentId = id of the document whose signed url is required to view and single download
*
/**/
@RestResource(urlMapping='/v1/getPassengerDocumentList/*')
global with sharing class REST_GetEDocumentsSignedUrl {
    
    @HttpPost
    global static postMMDJson doPOST(passengerDetails passenger) {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        postMMDJson response = new postMMDJson();
        
        validateInput(passenger, response);
        
        if(response.status != 'Failure') { 
         if(isAuthorizedUser(passenger.Id)) {
                response.rawRecord.addAll(getResponseModelList(passenger, response));
                if(response.status != 'Failure') { 
                response.status = 'Success';
                response.errorCode.add('000');
                response.message.add('Operation successful');
                }
            } else {
                response.status = 'Failure';
                response.errorCode.add('080');
                response.message.add('You are not allowed to view or download the documents');
            }      
        }
    
        return response;
    }
    
    //this class has the request payload details
    global class passengerDetails {
    
        public String id;
        public String sellingCompanyShortName;
        public String bookingRef; 
        public String actionType;
        public String documentId;
        
        public passengerDetails() {
            
        }
    }
   
   //this class has the response data fields 
   global class postMMDJson {
        public List<ResponseModel> rawRecord;
        public String status;
        public String [] message;
        public String [] errorCode;
        public Boolean leadPassenger;
                
        public postMMDJson(){
            rawRecord = new List<ResponseModel>();
            message = new List<String>();
            errorCode = new List<String>();
        }
    }

    //this is custom response data model 
   global class ResponseModel {
        public String documentId;
        public String passengerName;
        public String passengerNumber;
        public String documentType;
        public String signedURL;
        public String documentName;
        public String leadPassenger;
        public Decimal isDocListAvailable;

        
        public ResponseModel(String documentId, String passengerName, String passengerNumber, String documentType, 
        String signedURL, String documentName, String leadPassenger, Decimal isDocListAvailable){
            this.documentId = documentId;
            this.passengerName = passengerName;
            this.passengerNumber = passengerNumber;
            this.documentType = documentType;
            this.signedURL = signedURL;
            this.documentName = documentName;
            this.leadPassenger = leadPassenger;
            this.isDocListAvailable = isDocListAvailable;
        }
        
        public ResponseModel(){}
    }
    //post request param to MMD {"documentUrl":"https://unSignedURL"}
    global class JSONToApex {
        public String documentUrl {get;set;}
    }
    
     //For validating the input, go through each user entered field and for each field not filled in, add it to
    //an error message given back to the front end
    private static void validateInput(passengerDetails passenger, postMMDJson response){ 
    
          If(passenger.id == '' || passenger.id == Null){
            response.status = 'Failure';
            response.message.add('you must enter a selected passenger id');
            response.errorCode.add('010');
        
        }
         If(passenger.BookingRef == '' || passenger.BookingRef == Null){
            response.status = 'Failure';
            response.message.add('you must enter a booking reference');
            response.errorCode.add('020');
        
        }
        
        If(passenger.actionType == '' || passenger.actionType == Null){
            response.status = 'Failure';
            response.message.add('you must choose a action type');
            response.errorCode.add('030');
        }
        
        If((passenger.sellingCompanyShortName == '' || passenger.sellingCompanyShortName == Null)){
            response.status = 'Failure';
            response.message .add('you must enter a selling company short name');
            response.errorCode.add('050');
        }
        
        If(passenger.actionType == 'single' && (passenger.documentId == '' || passenger.documentId == Null)){
            response.status = 'Failure';
            response.message.add('you must enter a document id');
            response.errorCode.add('060');
        }
    }
    
     //For validating that user is a loggedIn and authenticated
    private static Boolean isAuthorizedUser(String passengerId){ 
        //return loggedIn and running user account id
        Id personAccountId = TQRegistrationService.getPersonAccountIdFromUser(UserInfo.getUserId());
        //return account id of the passenger whose document is requested
        Passenger__c loggedInPax = [SELECT Id, Account__c FROM Passenger__c WHERE Id = :passengerId];
        return personAccountId == loggedInPax.Account__c;
    }
    
      //call to MMD and return signed URL as string
    private static String getDocumentSignedUrl(String unsignedUrl, postMMDJson response){ 
                String signedUrl;
                
                JSONToApex jsonRequest = new JSONToApex();
                jsonRequest.documentUrl = unsignedUrl; 
                
                
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                App_Settings__c settings = App_Settings__c.getValues('mtsApp');
                
                String reqBody= JSON.serialize(jsonRequest);  
                req.setEndPoint(settings.MMD_URL__c);
                req.setMethod('POST');
                req.setHeader('content-type','application/json');
                req.setHeader('x-api-key', settings.MMD_X_API_header_key__c);
                req.setBody(reqBody);
                
                try {
                HTTPResponse res = http.send(req);
                signedUrl = res.getBody();
                } catch(Exception e) {
                signedUrl = 'blank';
                response.status = 'Failure';
                response.errorCode.add('070');
                response.message.add('Not able to get signed url');
                } 
                return signedUrl;
    }
    
    //build query request and return document list from documents object
    private static List<Passenger_Document__c> getDocumentsList(passengerDetails passenger, postMMDJson response){ 
    
             List<Passenger_Document__c> documentList = new  List<Passenger_Document__c>();
             
             String passengerId = passenger.Id;
             String documentId = passenger.documentId;
             String bookingRef = passenger.bookingRef;
             String sellingCompany = passenger.sellingCompanyShortName;
             
             String query= 'Select Id, Document_Name__c, Document_URL__c, Passenger__r.Name, Passenger__r.Lead_Passenger__c, Lead_Passenger_Name__c, Passenger_Number__c, Document_Type__c, MTS_Messaging__c FROM Passenger_Document__c WHERE Passenger__c = :passengerId AND Selling_Company_Code_Text__c = :sellingCompany AND Booking_Number__c = :bookingRef';
            
             If(passenger.actionType == 'single') {
                 query += ' AND Id = :documentId';
             }
             documentList =  Database.query(query);
 
        return documentList; 
    }
    
    //Build response model and return to user
    private static List<ResponseModel> getResponseModelList(passengerDetails passenger, postMMDJson response){ 
    
            String signedUrl = null;
            //Get loggedIn user Id from session.
            //Take Passenger Object and lookup corresponding User Id. 
            //Check if User Id is matching the session.
         
            List<ResponseModel> responseModelList =new List<ResponseModel>();
           
            for(Passenger_Document__c document : getDocumentsList(passenger, response))
            {   
                if(passenger.actionType != 'pageLoad'){
                    signedUrl = getDocumentSignedUrl(document.Document_URL__c, response).replace('"', '');
                }
   
                responseModelList.add(new ResponseModel(document.Id, document.Passenger__r.Name, document.Passenger_Number__c,
                document.Document_Type__c, signedUrl, document.Document_Name__c, document.Lead_Passenger_Name__c, document.MTS_Messaging__c));
            }
            Passenger__c leadPassenger = [SELECT Lead_Passenger__c from Passenger__c where Id = :passenger.Id];
            response.leadPassenger = leadPassenger.Lead_Passenger__c == passenger.Id;
            
            return responseModelList;
        }
    

}