/*-------------------------------------------------------
*----------API call for mapping bookings-----------------
*----------Used by MTS-----------------------------------
*----------created by Mark Mulholland--------------------
*----------18/10/2016------------------------------------
*--------------------------------------------------------
*----------Modified by MTS Team--------------------
*----------Added Special Brand field in request and modified the query--------------------
*----------21/12/2017------------------------------------
*
*  Example json Query  *
{
 "findPassenger" :{
  "firstName" : "Zaheed",
  "lastName" : "Shariff",
  "BookingRef" : "A481786",
  "accountId" : "0012500000dOq5p",
  "bookingRegion" : "CH",
  "specialBrand" : "UBU"
 }
} 
*
*firstName = the first name of the booking passenger - User entered
*lastName = the family name of the booking passenger - user entered
*BookingRef = Booking Number of the booking - user entered
*accountId = Id of the currently logged in MTS user
*BookingRegion = the first two letters of the Selling Company Code of the Booking
*specialBrand = Special brand field to identify sub brand from Booking component
*/
@RestResource(urlMapping='/v1/FindPassengerRecords/*')
global with sharing class REST_FindPassengerRecords_V1 {
    
    @HttpPatch
    global static PassengerWrapper doPatch(bookingDetails findPassenger) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        PassengerWrapper response = new PassengerWrapper();
        
        //check that the user inputted strings are not blank
        validateInput(findPassenger.firstName, findPassenger.lastName, findPassenger.bookingRef, response);
        
        //if the strings are blank then end the process there are return the Failure response
        If(response.status == 'Failure'){
        
            return response;
            
        }
        
        else{

            //using the accopuntId passed by the site, create an Account variable
            Account currentAccount = new Account(id = findPassenger.accountId);
            
            String BookingRegion = findPassenger.bookingRegion + '%';
            
         if (findPassenger.bookingRegion != 'UN' && findPassenger.bookingRegion != 'UU') {
           
             response.passList = [SELECT Id, First_Name__c, Family_Name__c, name, Passenger_External_Id__c,
              Account__c, Account__r.Id, Booking_Passenger__r.Booking__r.Name, Selling_Company_Short_Name__c,
               Tour_Product__r.Product_Name__c, Booking_Passenger__r.Pax_No__c FROM Passenger__c WHERE
                First_Name__c = :findPassenger.firstName AND Family_Name__c = :findPassenger.lastName 
                AND Booking_Passenger__r.Booking__r.Name = :findPassenger.BookingRef AND
                 Selling_Company_Code__c LIKE :BookingRegion AND Status__c != 'CX'];
            
            } else {
            
             response.passList = [SELECT Id, First_Name__c, Family_Name__c, name, Passenger_External_Id__c, Account__c,
             Account__r.Id, Booking_Passenger__r.Booking__r.Name, Selling_Company_Short_Name__c, 
             Tour_Product__r.Product_Name__c, Booking_Passenger__r.Pax_No__c FROM Passenger__c 
             WHERE First_Name__c = :findPassenger.firstName AND Family_Name__c = :findPassenger.lastName 
             AND Booking_Passenger__r.Booking__r.Name = :findPassenger.bookingRef AND 
             Selling_Company_Code__c LIKE :BookingRegion AND Status__c != 'CX' AND
              Booking_Component__r.Special_Brand__c = :findPassenger.specialBrand];
            
            }
            
             
            //if the SOQL query returns no results then send a Failure response
            If(response.passList.size() == 0){
            
                response.status = 'Failure';
                response.message = 'No bookings were found based on that criteria';
                response.errorCode = '060';
                
                return response;
            
            }
            
            boolean differentRegion = FALSE;
            
            //Once the search has been completed, check if more than 1 Booking Region was returned
            If(response.passList.size() > 1){
            
                string regionCheck = response.passList[0].Selling_Company_Short_Name__c;
                
                for(integer i = 0; i < response.passList.size(); i++){
                
                    if (regionCheck != response.passList[i].Selling_Company_Short_Name__c){
                    
                        differentRegion = TRUE;
                    
                    }
                
                }
                
            }
                
            //If more than 1 Booking Region was returned then throw an error
            if(differentRegion == TRUE){
            
                response.status = 'Failure';
                response.message = 'The results returned are over multiple Regions';
                response.errorCode = '080';
                
                return response;
            
            }
            
            if(response.passList.size() > 1){
            
                //If there were no errors and multiple records were found then send a Success message and say how many were returned
                response.status = 'Success';
                response.message = response.passList.size() + ' bookings were found based on that criteria. Please choose which one you would like to have put into your name';
                response.errorCode = '000';
                
                return response;
            
            }
            
            //return the Success response letting the user know how many Passenger records are now available to them
            response.status = 'Success';
            response.message = 'Are you sure you would like this Booking put into your name?';
            response.errorCode = '000';
                
            return response;
            
        }
        
    }
    
    //For validating the input, go through each user entered field and for each field not filled in, add it to
    //an error message given back to the front end
    private static void validateInput(String firstName, String lastName, String bookingRef, PassengerWrapper response){
        
        If(bookingRef == '' || bookingRef == Null){
        
            response.status = 'Failure';
            response.message = 'you must enter a Booking Reference';
            response.errorCode = '010';
        
        }
        
        If((lastName == '' || lastName == Null) & response.message == Null){
        
            response.status = 'Failure';
            response.message = 'you must enter a Last Name';
            response.errorCode = '020';
        
        }
        
        Else If(lastName == '' || lastName == Null){
        
            response.status = 'Failure';
            response.message += ' and you must enter a Last Name';
            response.errorCode += ', 020';
        
        }
        
        If((firstName == '' || firstName == Null) & response.message == Null){
        
            response.status = 'Failure';
            response.message = 'you must enter a First Name';
            response.errorCode = '030';
        
        }
        
        Else If(firstName == '' || firstName == Null){
        
            response.status = 'Failure';
            response.message += ' and you must enter a First Name';
            response.errorCode += ', 030';
        
        }
        
    }
    
    global class PassengerWrapper {
        public List<Passenger__c> passList;
        public String status;
        public String message;
        public String errorCode;
        
        public PassengerWrapper(){
            passList = new List<Passenger__c>();
        }
    }
    
    global class bookingDetails{
    
        public string firstName;
        public string lastName;
        public string bookingRef;
        public string accountId;
        public string bookingRegion;
        public string specialBrand;
        
        public bookingDetails(){
            
        }
    
    }
}