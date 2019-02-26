/**
 *  Web Service Response for the Registration Webservice
 */
global class TQRegistrationResponse extends TQWebServiceResponse {
    
	public final static Integer SUCCESS_USER_CREATED = 1;	                   //User created

    // Registration & Registration check API
    public final static Integer SERVER_ERROR_NO_INPUT = -501;                   //Missing parameters
    public final static Integer SERVER_ERROR_EMPTY_FIELD = -502;                //Error loading required field
    public final static Integer SERVER_ERROR_INVALID_PASSWORD = -503;           //Invalid password field
    public final static Integer SERVER_ERROR_INVALID_EMAIL = -504;              //Invalid email field
    public final static Integer SERVER_ERROR_USER_EXISTS = -505;                //User already exists
    public final static Integer SERVER_ERROR_BOOKING_NOT_FOUND = -506;          //Booking not found
    public final static Integer SERVER_ERROR_PACCOUNT_NOT_FOUND = -507;         //BookingPassenger without PersonAccount
    public final static Integer SERVER_ERROR_INVALID_BOOKING = -508;            //Invalid booking, not confirmed
    public final static Integer SERVER_ERROR_TOUR_INSTANCE_NOT_FOUND = -509;    //Tour instance not found
    public final static Integer SERVER_ERROR_DISPATCH_KEY_NOT_FOUND = -510;     //Dispatch key not found
    public final static Integer SERVER_ERROR_DISPATCH_KEY_NOT_RECOGNISED = -511;//Dispatch key not recognised
    public final static Integer SERVER_ERROR_REGISTRATION_KEY_NOT_FOUND = -512;	//Registration key is missing
    public final static Integer SERVER_ERROR_USER_CREATION = -513;				//Issues during the registration
    public final static Integer SERVER_GENERIC_ERROR_USER_CREATION = -514;		//Generic issue during the registration
    public final static Integer SERVER_ERROR_PACCOUNT_HAS_USER = -520;          //Person Account has already a user associated to it

    // Manual add trip functionality
    public final static Integer SERVER_ERROR_USER_TRIP_MISSING = -515;			//Missing user ID or trip ID in the manual add trip feature
    public final static Integer SERVER_ERROR_USER_NOT_FOUND = -516;				//User not found 
    public final static Integer SERVER_ERROR_SHARING_ISSUE = -517;				//Problems in sharing the trip instance
    public final static Integer SERVER_ERROR_BOOKING_PASSENGER_NOT_FOUND = -518;//Booking Passenger not found
    public final static Integer SERVER_ERROR_BOOKING_PA_NOT_FOUND = -519;       //Book PersonAccount not found
    

    public TQRegistrationResponse() {}
    
    /**
     *  Id of the registration request
     */ 
    public String registrationRequestCode {get; set;}

    /**
     *  User
     */ 
    public User user {get; set;}

    /**
     *  Tour instance
     */ 
    public List<Tour_Instance__c> tourInstances  {get; set;}

    /**
     *  Map with parameters
     */ 
    public Map<String, String> parameters  {get; set;}


    public void setUser(User user) {
        this.user = user;
    }

    public void setRegistrationRequestCode(String registrationRequestCode) {
        this.registrationRequestCode = registrationRequestCode;
    }

    public void setTourInstances(List<Tour_Instance__c> tourInstances) {
    	this.tourInstances = tourInstances;
    }

    public void setParameters(Map<String, String> parameters) {
    	this.parameters = parameters;
    }

}