/**
 *  Controller for the TquilaONE Trafalgar API, required during the registration process
 */
public without sharing class TQAPIController {

/**
     * Dispatcher options
     */
    public final static String ACTION_TYPE = 'type';
    public final static String ACTION_MANUALLY_REGISTER = 'register';
    public final static String ACTION_MANUALLY_REGISTER_CHECK = 'registercheck';
    public final static String ACTION_ADD_TRIP = 'addtrip';

    /**
     *  Parameters for the self-registration
     */
    public final static String FIRST_NAME = 'firstname';
    public final static String LAST_NAME = 'lastname';
    public final static String EMAIL_KEY = 'email';
    public final static String PASSWORD_KEY = 'password';
    public final static String COUNTRY_CODE = 'country';
    public final static String BOOKING_NUMBER = 'bookingnumber';

    /**
     *  Parameters for the self-registration check
     */
    public final static String REGISTRATION_CODE = 'registrationcode';
    public final static String TRIP_IDS = 'tripids';
    public final static String TRIP_IDS_SEPARATOR = ',';

    /**
     *  Parameters for add trip functionality
     */
    public final static String USER_ID = 'userid';


    /**
     *  JSON Result
     */
    private String result;

    /**
     *  Default Controller
     */    
    public TQAPIController() {}
    
    /**
     *  Dispatch:
     *  - Manually register user
     *  - Fetch manually register user response
     *  - Add trip
     */    
    public void dispatch() {
        
        // Get the parameters
        Map<String, String> parameters = ApexPages.currentPage().getParameters();

        // Check if the key has been specified
        TQRegistrationResponse response = null;

        // Registration Service
        TQRegistrationService registrationService = new TQRegistrationService();

        if(parameters != null && parameters.containsKey(ACTION_TYPE)) {
            String actionType = parameters.get(ACTION_TYPE);

            // Manual registration
            if(actionType.equalsIgnoreCase(ACTION_MANUALLY_REGISTER)) {
                // Get all the expected parameters
                String firstName = parameters.get(FIRST_NAME);
                String lastName = parameters.get(LAST_NAME);
                String email = parameters.get(EMAIL_KEY);
                String password = parameters.get(PASSWORD_KEY);
                String countryCode = parameters.get(COUNTRY_CODE);
                String bookingNumber = parameters.get(BOOKING_NUMBER);

                response = registrationService.manuallyRegisterUser(firstName, lastName, email, password, countryCode, bookingNumber);
            }

            // Manual registration check
            else if(actionType.equalsIgnoreCase(ACTION_MANUALLY_REGISTER_CHECK)) {
                // Get the self-registration code
                String selfRegistrationCode = parameters.get(REGISTRATION_CODE);

                // Get the tour instance IDs
                List<Id> tourInstanceIds = new List<Id>();
                String tourInstanceIdsInput = parameters.get(TRIP_IDS);
                if(tourInstanceIdsInput != null) {
                    // Split the ids using the agreed separator
                    List<String> tourInstanceIdsStrArray = tourInstanceIdsInput.split(TRIP_IDS_SEPARATOR, 0);
                    if(tourInstanceIdsStrArray != null && tourInstanceIdsStrArray.size() > 0) {
                        // Convert and add each tour instance ID
                        for(String tourInstanceIdsStr : tourInstanceIdsStrArray) {
                            try {
                                tourInstanceIds.add(Id.valueOf(tourInstanceIdsStr));
                            } catch(Exception e) {
                                System.debug('TQAPIController.manuallyRegisterUserCheck invalid Tour Instance IDs ' + parameters.get(TRIP_IDS));
                            }
                        }
                    }
                }
                response = registrationService.manuallyRegisterUserCheck(selfRegistrationCode, tourInstanceIds);
            }

            // Manually add a trip
            else if(actionType.equalsIgnoreCase(ACTION_ADD_TRIP)) {
                // Get the user ID and the reservation number
                response = registrationService.manuallyAddTrip(parameters.get(USER_ID), parameters.get(BOOKING_NUMBER));
            }

            // Dispatch key not recognised
            else {
                response = new TQRegistrationResponse();
                response.setStatus(TQRegistrationResponse.SERVER_ERROR_DISPATCH_KEY_NOT_RECOGNISED);
            }

        } else {
            response = new TQRegistrationResponse();
            response.setStatus(TQRegistrationResponse.SERVER_ERROR_DISPATCH_KEY_NOT_FOUND);
        }

        // Serialise the response
        setResult(JSON.serialize(response));
    }

    /**
     *  Getters / Setters
     */
    public String getResult() {
        return this.result;
    }
    public void setResult(String result) {
        this.result = result;
    }

}