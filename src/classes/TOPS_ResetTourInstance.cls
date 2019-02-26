/*********************************************************************
* Appirio a WiPro Company
* Name: TOPS_ResetTourInstance 
* Description: [This class is used to reset the Tour Instance]
* Created Date: [21-Sept-2017]
* Created By: [Neeraj Kumawat] (Appirio)
* 
* Date Modified                Modified By                  Description of the update
  10-Oct-2017                  Neeraj Kumawat               Not deleting Tour Director record and removed reseting the Room Type Booked or Actual Room Type fields.
**********************************************************************/
global class TOPS_ResetTourInstance {
    public static String compTypeRoomList = 'RoomingList';
    public static String compTypeItinerary = 'Itinerary';
    public static String passengerClass = 'Passenger';
    public static String tourDirector = 'Tour Director';
    public static String successMsg='Tour Instance Reset Successfully.';
    public static String inValidTourInstance='Not a valid Tour Instance for Reset.Tour Instance Process Status should be Process Completed.';
    //******************************************************************************************
    // Method to reset Tour instance
    // @param tourInstanceId:Id of tourInstance record 
    // @return String: return Message of tour instance
    // 21 Sept 2017 Neeraj Kumawat
    //******************************************************************************************
    webservice static String resetTourInstance(String tourInstanceId){
        try{
            List<Tour_Instance__c> tourInstanceList=[Select Id, Process_Status__c,ActualRoomTrigger__c, 
                                                     (Select Id, Component_Type__c From Tour_Instance_Itineraries__r 
                                                      Where Component_Type__c=:compTypeRoomList OR Component_Type__c=:compTypeItinerary),
                                                     (Select Id,Welcome_Email_Send_Status__c, Welcome_Email_Send_Date__c, 
                                                      TD_PAX_Status__c, TD_PAX_Start_Date__c, TD_PAX_End_Date__c, TD_Notes__c, 
                                                      TD_ModuleCode__c, TD_Accommodation_Class__c, Sent_welcome_email__c, 
                                                      Sent_farewell_email__c, PAX_Timeline__c, 
                                                      Init_Status__c, Init_Start_Location_City__c, Init_Start_Location_City_Code__c, 
                                                      Init_Start_Date__c, Init_Room_Preference__c, Init_Preferred_Name__c, 
                                                      Init_Pre_Trip_Accom__c, Init_Post_Trip_Accom__c, Init_Passport_Number__c, 
                                                      Init_Passport_Issue_Date__c, Init_Passport_Expiry_Date__c, 
                                                      Init_Nationality__c, Init_Module__c, Init_End_Location_City__c, 
                                                      Init_End_Location_City_Code__c, Init_End_Date__c, Init_Email__c, 
                                                      Init_Dietary_Requirements__c, Init_Country_of_Issue__c, 
                                                      Init_Country_of_Birth__c, Init_City_of_Birth__c,
                                                      Start_Location_City__c,Start_Location_City_Code__c,
                                                      Start_Date__c,Preferred_Name__c,Pre_Trip_Accom__c,
                                                      Post_Trip_Accom__c,Passport_Number__c,Passport_Issue_Date__c,
                                                      Passport_Expiry_Date__c,Nationality__c,End_Location_City__c,
                                                      End_Location_City_Code__c,End_Date__c,Email__c,Dietary_Requirements__c,
                                                      Country_of_Issue__c,Country_of_Birth__c,City_of_Birth__c,
                                                      Ferry_List_Incl__c, Farewell_Email_Send_Status__c, 
                                                      Farewell_Email_Send_Date__c, 
                                                      Failure_welcome_email__c, Failure_farewell_email__c, Bag_Number__c, 
                                                      Amount_Paid_Optionals__c, Amount_Owed_Optionals__c, Actual_Room_Type__c, 
                                                      Actual_Room_ID__c, Account__c, AccommodationClass__c, Passenger_Class__c,
                                                      Room_Special_Instructions__c, Room_Preference__c, Room_Number__c, 
                                                      Room_Near_Group__c, Room_List_TD_Confirmation__c,Room_Type_Booked__c,
                                                      Last_Module_Code__c,Module_Code__c
                                                      From Passengers__r),
                                                     (Select Id, Name, Day__c, Short_Description__c, Sort_Order__c, 
                                                      Supplier_Menu__c, Supplier__c, TD_Notes__c, Time__c, Use_Optional__c From Tour_Optionals__r)
                                                     From Tour_Instance__c 
                                                     Where Id =:tourInstanceId AND Process_Status__c='Process Completed'];
            Tour_Instance__c tourInstance=null;
            if(tourInstanceList.size()>0){
                tourInstance=tourInstanceList.get(0);
                tourInstance.Process_Status__c='Unprocessed';
                tourInstance.ActualRoomTrigger__c='Pending';
                //Set tour Instance Itineraries list
                List<Tour_Instance_Itinerary__c> tourIIList= tourInstance.Tour_Instance_Itineraries__r;
                //Set passenger list
                List<Passenger__c> passengerList= tourInstance.Passengers__r;
                List<Tour_Optional__c> tourOptionalList=tourInstance.Tour_Optionals__r;
                //Reset passenger fields and delete passenger records which don't have passenger class as passenger
                resetPassengers(passengerList);
                //Reset tour optional fields. Will be uncomment if we want to reset tour optional fields
                //resetTourOptionFields(tourOptionalList);
                
                //delete tour instance Itineraries and roomlist
                delete tourIIList;
                //Update  tour instance process status and actual romm trigger
                update tourInstance;
                return successMsg;
            }else{
                return inValidTourInstance;
            }
        }catch(Exception ex){
            return ex.getMessage();
        }
    }
    //******************************************************************************************
    // Method to remove Tour Instance Itineraries
    // @param tourIIList: List of Tour Instance Itinerary
    // 21 Sept 2017 Neeraj Kumawat
    //******************************************************************************************
    public static void resetTourOptionFields(List<Tour_Optional__c> tourOptionalList){
        List<Tour_Optional__c> updatedTourOptList=new List<Tour_Optional__c>();
        for(Tour_Optional__c tourOptional: tourOptionalList){
            tourOptional.Name='';
            tourOptional.Day__c=0;
            updatedTourOptList.add(tourOptional);
        }
        update updatedTourOptList;
    }
    //******************************************************************************************
    // Method to reset Passengers
    // @param passengerList: List of Passenger
    // 21 Sept 2017 Neeraj Kumawat
    //******************************************************************************************
    public static void resetPassengers(List<Passenger__c> passengerList){
        List<Passenger__c> updatePassengerList=new List<Passenger__c>();
        List<Passenger__c> deletePassengerList=new List<Passenger__c>();
        for(Passenger__c passenger: passengerList){
            if(passenger.Passenger_Class__c!=passengerClass && passenger.Passenger_Class__c!=tourDirector){
                deletePassengerList.add(passenger);
            }else if(passenger.Passenger_Class__c==passengerClass){
                copyInitFields(passenger);
                passenger.Welcome_Email_Send_Status__c=null;
                passenger.Welcome_Email_Send_Date__c=null;
                passenger.TD_PAX_Status__c=null; 
                passenger.TD_PAX_Start_Date__c=null;
                passenger.TD_PAX_End_Date__c=null;
                passenger.TD_Notes__c=null;
                passenger.TD_ModuleCode__c=null;
                passenger.TD_Accommodation_Class__c=null;
                passenger.Sent_welcome_email__c=false;
                passenger.Sent_farewell_email__c=false;
                passenger.Room_List_TD_Confirmation__c=null;
                passenger.PAX_Timeline__c=null;
                passenger.Init_Status__c=null;
                passenger.Init_Start_Location_City__c=null;
                passenger.Init_Start_Location_City_Code__c=null;
                passenger.Init_Start_Date__c=null;
                passenger.Init_Room_Preference__c=null;
                passenger.Init_Preferred_Name__c=null;
                passenger.Init_Pre_Trip_Accom__c=null;
                passenger.Init_Post_Trip_Accom__c=null;
                passenger.Init_Passport_Number__c=null;
                passenger.Init_Passport_Issue_Date__c=null;
                passenger.Init_Passport_Expiry_Date__c=null;
                passenger.Init_Nationality__c=null;
                passenger.Init_Module__c=null;
                passenger.Init_End_Location_City__c=null;
                passenger.Init_End_Location_City_Code__c=null;
                passenger.Init_End_Date__c=null;
                passenger.Init_Email__c=null;
                passenger.Init_Dietary_Requirements__c=null;
                passenger.Init_Country_of_Issue__c=null;
                passenger.Init_Country_of_Birth__c=null;
                passenger.Init_City_of_Birth__c=null;
                passenger.Ferry_List_Incl__c=false;
                passenger.Farewell_Email_Send_Status__c=null;
                passenger.Farewell_Email_Send_Date__c=null;
                passenger.Failure_welcome_email__c=false;
                passenger.Failure_farewell_email__c=false;
                passenger.Bag_Number__c=null;
                passenger.Amount_Paid_Optionals__c=null;
                passenger.Amount_Owed_Optionals__c=null;
                passenger.Actual_Room_ID__c=null;
                passenger.Account__c=null;
                passenger.AccommodationClass__c=null;
                passenger.Room_Special_Instructions__c=null;
                passenger.Room_Preference__c=null;
                passenger.Room_Number__c=null;
                passenger.Room_Near_Group__c=null;
                passenger.Room_List_TD_Confirmation__c=null;
                updatePassengerList.add(passenger);
            }
        }
        update updatePassengerList;
        delete deletePassengerList;
    }
    //******************************************************************************************
    // Method to copy Passengers init fields to their respactive fields of  Passengers
    // @param passenger: passenger record
    // 21 Sept 2017 Neeraj Kumawat
    //******************************************************************************************
    public static void copyInitFields(Passenger__c passenger){
        if(passenger.Init_City_of_Birth__c!=null){
            passenger.City_of_Birth__c=passenger.Init_City_of_Birth__c;
        }
        if(passenger.Init_Country_of_Birth__c!=null){
            passenger.Country_of_Birth__c=passenger.Init_Country_of_Birth__c;
        }
        if(passenger.Init_Country_of_Issue__c!=null){
            passenger.Country_of_Issue__c=passenger.Init_Country_of_Issue__c;
        }
        if(passenger.Init_Dietary_Requirements__c!=null){
            passenger.Dietary_Requirements__c=passenger.Init_Dietary_Requirements__c;
        }
        if(passenger.Init_Email__c!=null){
            passenger.Email__c=passenger.Init_Email__c;
        }
        if(passenger.Init_End_Date__c!=null){
            passenger.End_Date__c=passenger.Init_End_Date__c;
        }
        if(passenger.Init_End_Location_City__c!=null){
            passenger.End_Location_City__c=passenger.Init_End_Location_City__c;
        }
        if(passenger.Init_End_Location_City_Code__c!=null){
            passenger.End_Location_City_Code__c=passenger.Init_End_Location_City_Code__c;
        }
        if(passenger.Init_Nationality__c!=null){
            passenger.Nationality__c=passenger.Init_Nationality__c;
        }
        if(passenger.Init_Passport_Expiry_Date__c!=null){
            passenger.Passport_Expiry_Date__c=passenger.Init_Passport_Expiry_Date__c;
        }
        if(passenger.Init_Passport_Issue_Date__c!=null){
            passenger.Passport_Issue_Date__c=passenger.Init_Passport_Issue_Date__c;
        }
        if(passenger.Init_Passport_Number__c!=null){
            passenger.Passport_Number__c=passenger.Init_Passport_Number__c;
        }
        if(passenger.Init_Post_Trip_Accom__c!=null){
            passenger.Post_Trip_Accom__c=passenger.Init_Post_Trip_Accom__c;
        }
        if(passenger.Init_Preferred_Name__c!=null){
            passenger.Preferred_Name__c=passenger.Init_Preferred_Name__c;
        }
        if(passenger.Init_Pre_Trip_Accom__c!=null){
            passenger.Pre_Trip_Accom__c=passenger.Init_Pre_Trip_Accom__c;
        }
        if(passenger.Init_Room_Preference__c!=null){
            passenger.Room_Preference__c=passenger.Init_Room_Preference__c;
        }
        if(passenger.Init_Start_Date__c!=null){
            passenger.Start_Date__c=passenger.Init_Start_Date__c;
        }
        if(passenger.Init_Start_Location_City__c!=null){
            passenger.Start_Location_City__c=passenger.Init_Start_Location_City__c;
        }
        if(passenger.Init_Start_Location_City_Code__c!=null){
            passenger.Start_Location_City_Code__c=passenger.Init_Start_Location_City_Code__c;
        }
        if(passenger.Last_Module_Code__c!=null){
            passenger.Module_Code__c=passenger.Last_Module_Code__c;
        }
    }
}