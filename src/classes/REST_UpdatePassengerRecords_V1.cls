/*-------------------------------------------------------
*----------API call for mapping bookings-----------------
*----------Used by MTS-----------------------------------
*----------created by Mark Mulholland--------------------
*----------29/11/2016------------------------------------
*--------------------------------------------------------
*
*  Example json Query  *
{
    "passengers": {
        "updatePassengers": [{
            "accountId": "0012500000dOq5p",
            "passengerId": "a2D20000000XACs"
        }, {
            "accountId": "0012500000dOq5p",
            "passengerId": "a2D20000000XI2t"
        }]
    }
}
*
*accountId = Id of the currently logged in MTS user
*passengerId = Id of the Passenger record that the user selected for reassigning
*/
@RestResource(urlMapping='/v1/UpdatePassengerRecords/*')
global class REST_UpdatePassengerRecords_V1 {
    
    @HttpPatch
    global static PassengerResponse doPatch(passengers passengers) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        PassengerResponse response = new PassengerResponse();
        
        response.updatePassengers = passengers.updatePassengers;
        
        //Make sure the data passed for this call is valid. If it is not then return an error stating the error
        validateInput(response);
        
        if(response.status == 'Failure'){
        
            return response;
        
        }
        
        List<Passenger__c> passList = new List<Passenger__c>();
        Account currentAccount = new Account();
        
        //Start looping through the records to get updated
        for(integer i = 0; i < response.updatePassengers.size(); i++){
            
            Passenger__c oldPassenger = [SELECT Id, Account__c FROM Passenger__c WHERE Id = :response.updatePassengers[i].passengerId LIMIT 1];
            
            currentAccount.Id = response.updatePassengers[i].accountId;
            currentAccount.Passenger_details_to_be_moved_from__c = oldPassenger.Account__c;
            
            //Each time, create a Passenger__c variable using the Passenger Id and the Account Id. Then add that variable to a list of Passenger__c
            Passenger__c currentPassenger = new Passenger__c(Id = response.updatePassengers[i].passengerId, Account__c = response.updatePassengers[i].accountId);
            
            passList.add(currentPassenger);
        
        }
        
        //Try to update those Passenger records
        Try{
        
            update passList;
            update currentAccount;
            
            if(passList.size() > 1){
            
                //If the update works then return a Success message and state how many Passengers were updated
                response.Status = 'Success';
                response.Message = passList.size() + ' Passenger records are now visible to you';
                response.errorCode = '000';
                
            }
            
            else if(passList.size() == 1){
            
                //If the update works then return a Success message and state that Passenger is now visible
                response.Status = 'Success';
                response.Message = 'That passenger record is now visible to you';
                response.errorCode = '000';
            
            }
        
        }
        Catch(Exception exc) {
        
            //If the update fails then return a Failure message
            response.Status = 'Failure';
            response.Message =  'The mapping failed with the following error: ' + exc.getMessage();
            response.errorCode = '550';
        
        }
        
        return response;
    }
    
    //This is the method that accepts the response data and makes sure the data is accurate
    private static void validateInput(PassengerResponse response){
        
        //First thing that is checked is whether there are no passengers to be updated.
        //If that is the case then send a Failure message
        If(response.updatePassengers.size() == 0){
        
            response.status = 'Failure';
            response.message = 'There were no Passenger Records to be updated';
            response.errorCode = '580';
        
        }
        
        //Next, check that there are more than 1 passengers to be updated
        else if(response.updatePassengers.size() > 0){
        
            //If there are, then start looping through those Passegners
            for(integer i = 0; i < response.updatePassengers.size(); i++){
            
                //At each passenger, check if either the passegnerId or accountId are not filled in. If so then add
                //Failure to the status and state what was missing in the Message
                if((response.updatePassengers[i].accountId == '' || response.updatePassengers[i].accountId == Null) && (response.updatePassengers[i].passengerId == '' || response.updatePassengers[i].passengerId == Null)){
                
                    response.status = 'Failure';
                    i++;
                    if(response.message != Null){
                    
                        response.message += ' and the accountId and the PassengerId are blank on Passenger ' + i;
                        response.errorCode = ', 500';
                        
                    }
                    else {
                    
                        response.message = 'The accountId and the PassengerId are blank on Passenger ' + i;
                        response.errorCode = '500';
                        
                    }
                    i--;
                
                }
                
                else if(response.updatePassengers[i].accountId == '' || response.updatePassengers[i].accountId == Null){
                
                    response.status = 'Failure';
                    i++;
                    if(response.message != Null){
                    
                        response.message += ' and the accountId is blank on Passenger ' + i;
                        response.errorCode = ', 510';
                        
                    }
                    else {
                    
                        response.message = 'The accountId is blank on Passenger ' + i;
                        response.errorCode = '510';
                        
                    }
                    i--;
                
                }
                
                else if(response.updatePassengers[i].passengerId == '' || response.updatePassengers[i].passengerId == Null){
                
                    response.status = 'Failure';
                    i++;
                    if(response.message != Null){
                    
                        response.message += ' and the passengerId is blank on Passenger ' + i;
                        response.errorCode = ', 520';
                        
                    }
                    else {
                    
                        response.message = 'The passengerId is blank on Passenger ' + i;
                        response.errorCode = '520';
                        
                    }
                    i--;
                
                }
            
            }
        
        }
        
    }
    
    global class PassengerResponse {
        public List<updatePassengers> updatePassengers;
        public String status;
        public String message;
        public String errorCode;
    }
    
    global class passengers{
    
        public List<updatePassengers> updatePassengers = new List<updatePassengers>();
    
    }
    
    global class updatePassengers{
    
        public string accountId;
        public string passengerId;
    
    }
    
}