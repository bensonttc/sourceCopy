/**
 * Registration Service, to enable users to access the myTrafalgar app
 */
public without sharing class TQRegistrationService {

  /**
     * Record type names
     */
    public static final String ACCOUNT_RECORD_TYPE_CUSTOMER = 'Customer';
    public static final String BOOKING_PASSENGER_RECORD_TYPE_BOOKING_PASSENGER = 'Booking Passengers';
    public static final String BOOKING_COMPONENT_RECORD_TYPE_TOUR = 'Tour';

    /**
     * Profile assigned to customers
     */
    public static final String CUSTOMER_PROFILE_NAME = 'Trafalgar Guest User (CC Plus)';

    /**
     * Suffix for the usernames
     */
    private static final String USERNAME_SUFFIX = '.mytrafalgar';
    private static final String MYTRAFALGAR_CUSTOM_SETTING_NAME = 'guestApp';

  /**
     *  Internal map keys
     */
    private final static String STATUS_KEY = 'status';
    private final static String TOUR_INSTANCE_KEY = 'tourInstance';
    private final static String BOOKING_PASSENGER_PA_KEY = 'bookingPassengerPA';
    
    /**
     *  Community Name
     */
    public static final String TRAFALGAR_COMMUNITY_NAME = 'myTrafalgar';
    public static final String TRAFALGAR_BRANDING_NAME = 'Trafalgar';


  public TQRegistrationService() {}

  /**
     *  Register user API
     */
    public TQRegistrationResponse manuallyRegisterUser(String firstName, String lastName, String email, String password, String countryCode, String bookingNumber) {
        //Prepare the output
        TQRegistrationResponse response = new TQRegistrationResponse();

    // All mandatory fields
        if(isEmpty(firstName) || isEmpty(lastName) || isEmpty(email) || isEmpty(password) || isEmpty(countryCode) || isEmpty(bookingNumber)) {
            System.debug('TQRegistrationService: ' + firstName + ' ' + lastName + ' ' + email + ' ' + password + ' ' + countryCode + ' ' + bookingNumber);

            response.setStatus(TQRegistrationResponse.SERVER_ERROR_EMPTY_FIELD);
        } else {
            // Check password
            if(invalidPassword(password)) {
                response.setStatus(TQRegistrationResponse.SERVER_ERROR_INVALID_PASSWORD);
            } else {

                // Check email format
                if(invalidEmail(email)) {
                    response.setStatus(TQRegistrationResponse.SERVER_ERROR_INVALID_EMAIL);
                } else {

                    // Check if a user with same first name, last name and email already exists
                    User existingUser = findExistingUser(firstName, lastName, email);
                    if(existingUser != null) {
                        response.setStatus(TQRegistrationResponse.SERVER_ERROR_USER_EXISTS);
                        response.setUser(existingUser);
                    } else {

                        Map<String, List<SObject>> accessResult = grantBookingAccess(bookingNumber, firstName, lastName, email);
                        if(accessResult != null && accessResult.containsKey(TOUR_INSTANCE_KEY) 
                                && accessResult.containsKey(BOOKING_PASSENGER_PA_KEY)) {
                            
                            // Generate self-registration request code
                            String selfRegistrationRequestCode = generateSelfRegistrationRequestCode();
                            response.setRegistrationRequestCode(selfRegistrationRequestCode);

                            // Get the tour instances
                            response.setTourInstances((List<Tour_Instance__c>) accessResult.get(TOUR_INSTANCE_KEY));

                            // Get the personAccount
                            List<Account> bookingPassengerPAccounts = (List<Account>) accessResult.get(BOOKING_PASSENGER_PA_KEY);
                            if(bookingPassengerPAccounts != null && bookingPassengerPAccounts.size() > 0) {
                              Account bookingPassengerPAccount = bookingPassengerPAccounts.get(0);

                                // Check if the person account already has an associated user
                                User previouslyCreatedUser = bookingPassengerHasUserAlready(bookingPassengerPAccount);
                                if(previouslyCreatedUser != null) {
                                    response.setUser(previouslyCreatedUser);
                                    response.setStatus(TQRegistrationResponse.SERVER_ERROR_PACCOUNT_HAS_USER);
                                } else {
                                    // Call the async registration
                                    createUserAsync(firstName, lastName, email, password, countryCode,
                                        bookingPassengerPAccount.Id, selfRegistrationRequestCode);

                                    // Update the PersonAccount if needed (email address)
                                    updatePassengerPAccount(bookingPassengerPAccount, email);

                                    // Success
                                    response.setStatus(TQWebServiceResponse.SUCCESS);
                                }
                            } else {
                              response.setStatus(TQRegistrationResponse.SERVER_ERROR_BOOKING_PA_NOT_FOUND);  
                            }
                        } else {
                            response.setStatus(restoreInfo( (List<TQ_Local_Assignment__c>) accessResult.get(STATUS_KEY)));
                        }
                    }
                }
            }
        }

        return response;
    }

    /**
     *  Create the user asynchronously
     */
    @future 
    public static void createUserAsync(String firstName, String lastName, String email, String password, String countryCode,
            String bookingPassengerPAccountId, String selfRegistrationRequestCode) {

        Exception userIssue = null;             // Issue creating a user
        String sharingIssue = null;             // Issue granting permissions
        Boolean missingProfile = false;         // Issue with the requested profile
        Boolean missingPersonAccount = false;   // Issue with the person account

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;

        // Get the right profile
        Profile customerProfile = findCustomerProfileByName(CUSTOMER_PROFILE_NAME);
        if(customerProfile != null) {

            // Get the ContactId of the PersonAccount 
            List<Account> personAccounts = [Select PersonContactId From Account Where Id = :bookingPassengerPAccountId];
            if(personAccounts == null || personAccounts.size() == 0) {
                missingPersonAccount = true;
            } else {
                String bookingPassengerPAContactId = personAccounts.get(0).PersonContactId;

                // Iteratively try multiple times if needed - unpredictable already-in use usernames
                Integer count = 0, maxAttempts = 10;
                String username, alias;
                Set<String> previousUsernames = new Set<String>();    // keep memory of all the usernames
                Boolean userInserted = false;
                User user = null;
                do {
                    userName = generateUsername(email, previousUsernames);
                    previousUsernames.add(userName);

                    //take the first few characters of the username for the alias
                    alias = userName.substring(0, 7);
                    user = new User(
                        alias = alias, 
                        firstname = firstName,  
                        lastname = lastName, 
                        email = email, 
                        username = username,
                        profileid = customerProfile.Id, 
                        contactId = bookingPassengerPAContactId,
                        Self_Registration_Request_Code__c = selfRegistrationRequestCode,
                        emailencodingkey = 'UTF-8',
                        languagelocalekey = 'en_US', 
                        localesidkey = 'en_GB', 
                        timezonesidkey = 'GMT',
                        UserPreferencesDisableAllFeedsEmail = true,
                        UserPreferencesDisableBookmarkEmail = true,
                        UserPreferencesDisableChangeCommentEmail = true,
                        UserPreferencesDisableEndorsementEmail = true,
                        UserPreferencesDisableFileShareNotificationsForApi = true,
                        UserPreferencesDisableFollowersEmail = true,
                        UserPreferencesDisableLaterCommentEmail = true,
                        UserPreferencesDisableLikeEmail = true,
                        UserPreferencesDisableMentionsPostEmail = true,
                        UserPreferencesDisableProfilePostEmail = true,
                        UserPreferencesDisableSharePostEmail = true,
                        UserPreferencesDisCommentAfterLikeEmail = true,
                        UserPreferencesDisMentionsCommentEmail = true,
                        UserPreferencesDisableMessageEmail = true,
                        UserPreferencesDisProfPostCommentEmail = true,
                        DefaultGroupNotificationFrequency = 'N',
                        DigestFrequency = 'N',
                        Country__c = countryCode
                    );
                    user.setOptions(dmo);

                    try {
                        insert user;
                        userInserted = true;
                        userIssue = null;
                    } catch(Exception e) {
                        userIssue = e;
                    }
                    count++;
                } while(!userInserted && count < maxAttempts);

                // If user has been created, proceed with the update of the password and with the sharing                
                if(userInserted) {
                    // Set the password for the user
                    System.setPassword(user.Id, password);
                }
            }
        } else {
            missingProfile = true;
        }

        // Log the issue if any
        if(missingProfile || missingPersonAccount || sharingIssue != null || userIssue != null) {
            String errorMessage = userIssue != null
                ? userIssue.getMessage()
                : sharingIssue != null
                    ? sharingIssue
                    : missingPersonAccount
                        ? 'Person Account ' + bookingPassengerPAccountId + ' not found'
                        : 'Profile ' + CUSTOMER_PROFILE_NAME + ' is missing';
            TQ_Local_Assignment__c errorLog = new TQ_Local_Assignment__c(
                Self_Registration_Request_Code__c = selfRegistrationRequestCode,
                Error_Message__c = errorMessage,
                Local_Id__c = 'TQ_Registration_Log',
                Salesforce_Id__c = 'TQ_Registration'
            );
            insert errorLog;
        }
    }

    /**
     *  Check the result of the Register user API Call
     */
    public TQRegistrationResponse manuallyRegisterUserCheck(String selfRegistrationCode, List<Id> tourInstanceIds) {
        //Prepare the output
        TQRegistrationResponse response = new TQRegistrationResponse();

      // Check if a user has been created
        List<User> createdUsers = [SELECT Id, username, firstName, lastName, email 
            FROM User WHERE Self_Registration_Request_Code__c = :selfRegistrationCode];

        if(createdUsers != null && createdUsers.size() > 0) {
            // Return the user
            User createdUser = createdUsers.get(0);
            response.setUser(createdUser);
            response.setStatus(TQRegistrationResponse.SUCCESS_USER_CREATED);

            // Clean all the error logs
            List<TQ_Local_Assignment__c> errorLogs = [SELECT Id FROM TQ_Local_Assignment__c 
                WHERE Self_Registration_Request_Code__c = :selfRegistrationCode];
            if(errorLogs != null && errorLogs.size() > 0) {
                delete errorLogs;
            }

            // Follow all the Trip Instances
            if(tourInstanceIds != null) {
                // Open visibility on the trip instance
                shareTripInstances(tourInstanceIds, createdUser.Id);

                // Open up chatter
                chatterFollowTrips(tourInstanceIds, createdUser.Id);

                // Mute email notifications
                muteEmailNotifications(createdUser.Id);
            }
        } else {
            // Get all the errors (last first)
            List<TQ_Local_Assignment__c> errorLogs = [SELECT Id, Error_Message__c 
                FROM TQ_Local_Assignment__c 
                WHERE Self_Registration_Request_Code__c = :selfRegistrationCode
                ORDER BY LastModifiedDate DESC];
            
            // Return the error
            if(errorLogs != null && errorLogs.size() > 0) {
                response.setStatus(TQRegistrationResponse.SERVER_ERROR_USER_CREATION);
                response.setError(errorLogs.get(0).Error_Message__c);
            } else {
                response.setStatus(TQRegistrationResponse.SERVER_GENERIC_ERROR_USER_CREATION);
            }
        }

        return response;
    }

    /**
     *  Manually add a trip
     */
    public TQRegistrationResponse manuallyAddTrip(String userID, String reservationNumber) {
        //Prepare the output
        TQRegistrationResponse response = new TQRegistrationResponse();

        // Get the user
        User user = findUser(userId);
        if(user == null) {
            response.setStatus(TQRegistrationResponse.SERVER_ERROR_USER_NOT_FOUND);
        } else {
            // Validate the request and find the Trip Instance
            Map<String, List<SObject>> accessResult = grantBookingAccess(reservationNumber, user.FirstName, user.LastName, user.Email);
            if(accessResult != null && accessResult.containsKey(TOUR_INSTANCE_KEY) 
                    && accessResult.containsKey(BOOKING_PASSENGER_PA_KEY)) {
                
                // Get the tour instance
                List<Tour_Instance__c> tourInstances = (List<Tour_Instance__c>) accessResult.get(TOUR_INSTANCE_KEY);
                response.setTourInstances(tourInstances);

                // Get just the Tour Instance Ids
                List<Id> tourInstanceIds = convertToIds(tourInstances);

                // Open up the visibility of the Trip Instance
                String sharingIssue = shareTripInstances(tourInstanceIds, user.Id);
                if(sharingIssue != null) {
                    response.setStatus(TQRegistrationResponse.SERVER_ERROR_SHARING_ISSUE);
                    response.setError(sharingIssue);
                } else {
                    // Follow the record
                    chatterFollowTrips(tourInstanceIds, user.Id);

                    // Success
                    response.setStatus(TQWebServiceResponse.SUCCESS);
                }
            } else {
                response.setStatus(restoreInfo( (List<TQ_Local_Assignment__c>) accessResult.get(STATUS_KEY)));
            }
        }

        return response;
    }

    /**
     *  Give access to the user to the booking
     */
    private Map<String, List<SObject>> grantBookingAccess(String bookingNumber, String firstName, String lastName, String email) {
        Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
        Integer finalStatus = null;

        // Check if the bookingNumber exists
        Booking__c booking = findBooking(bookingNumber);
        if(booking == null) {
            finalStatus = TQRegistrationResponse.SERVER_ERROR_BOOKING_NOT_FOUND;
        } else {

            // Check if the booking is valid (confirmed)
            if(invalidBooking(booking)) {
                finalStatus = TQRegistrationResponse.SERVER_ERROR_INVALID_BOOKING;
            } else {

                // Check if a Booking Passenger exists
                Booking_Passenger__c bookingPassenger = findBookingPassenger(booking, firstName, lastName, email);
                
                // Person Account associated to the booking passenger
                Account bookingPassengerPAccount = null;

                // Passenger didn't provide details while booking
                if(bookingPassenger == null) {
                    // Creating PersonAccount is complicated!!! - avoiding in this phase
                    //bookingPassengerPAccount = createAccountAndPassenger(booking, firstName, lastName, email);
                    //// Get the new booking passenger
                    //bookingPassenger = findBookingPassenger(bookingPassengerPAccount);

                    finalStatus = TQRegistrationResponse.SERVER_ERROR_BOOKING_PASSENGER_NOT_FOUND;
                }
                // Passenger has alreadyprovided details
                else {
                    // Check if the PersonAccount is there as expected, if the booking passenger exists
                    if(invalidPersonAccount(bookingPassenger)) {
                        finalStatus = TQRegistrationResponse.SERVER_ERROR_PACCOUNT_NOT_FOUND;
                    } else {
                        bookingPassengerPAccount = findAccount(bookingPassenger.Customer__c);
                    }
                }

// !!! 30/08/2016 Fergal McMenamin - commented out the code below as it references the findCreateTourInstances method
                
                // Check if there is an available slot - shall we skip this control?
         //       if(bookingPassengerPAccount != null) {
                    // Find or Create a tour instance
         //           List<Tour_Instance__c> tourInstances = findCreateTourInstances(bookingPassenger);

                    // Problems creating / finding the tour instance: does the bookingComponent exist?
         //           if(tourInstances == null) {
         //               finalStatus = TQRegistrationResponse.SERVER_ERROR_TOUR_INSTANCE_NOT_FOUND;
         //           } else {
                        // Success
         //               resultMap.put(TOUR_INSTANCE_KEY, tourInstances);

         //               List<Account> bookingPassengerPAccounts = new List<Account>();
         //               bookingPassengerPAccounts.add(bookingPassengerPAccount);
         //               resultMap.put(BOOKING_PASSENGER_PA_KEY, bookingPassengerPAccounts);
         //               finalStatus = null;
                    }
                }
//FMM - this line has been brought up from end of method        
             return resultMap;
            }
    //    }

        // Error reported
     //   if(finalStatus != null) {
     //       resultMap.put(STATUS_KEY, hideInfo(finalStatus));
     //   }

    //    return resultMap;
    //}

    /**
     *  Hide / un-hide info on an object
     */
    private static List<TQ_Local_Assignment__c> hideInfo(Integer s) {
      List<TQ_Local_Assignment__c> hiddenInfo = new List<TQ_Local_Assignment__c>();
      hiddenInfo.add(new TQ_Local_Assignment__c(Local_Id__c = String.valueOf(s)));
      return hiddenInfo;
    }
    private static Integer restoreInfo(List<TQ_Local_Assignment__c> infos) {
        return infos != null && infos.size() > 0 ? Integer.valueOf(infos.get(0).Local_Id__c) : -599;
    }

    /**
     *  String check if empty
     */
    private Boolean isEmpty(String str) {
        if(str == null) {
            return true;
        } else {
            str = str.trim();
            return str.length() == 0;
        }
    }

    /**
     *  Check if the password is inline with security 
     */
    private Boolean invalidPassword(String password) {
        password = password.trim();

        Pattern alphaPattern = Pattern.compile('.*[a-zA-Z].*');
        Matcher alphaPatternMatcher = alphaPattern.matcher(password);

        Pattern numericPattern = Pattern.compile('.*[0-9].*');
        Matcher numericPatternMatcher = numericPattern.matcher(password);
        
        return !(password.length() >= 8 && alphaPatternMatcher.matches() && numericPatternMatcher.matches());
    }

    /**
     *  Check if the email is a valid one
     */
    private Boolean invalidEmail(String email) {
        email = email.trim();

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailPatternMatcher = emailPattern.matcher(email);

        return !emailPatternMatcher.matches();
    }

    /**
     *  Try to search for a user with the same details
     */
    private User findExistingUser(String firstName, String lastName, String email) {
        List<User> users = [SELECT Id, username, firstName, lastName, email FROM User 
            WHERE FirstName like :firstName AND LastName like :lastName AND email like :email ];
        return users != null && users.size() > 0 ? users.get(0) : null;
    }

    /**
     *  Find a user
     */
    private User findUser(String userId) {
        List<User> users = [SELECT Id, username, firstName, lastName, email FROM User WHERE Id = :userId ];
        return users != null && users.size() > 0 ? users.get(0) : null;
    }

    /**
     *  Find a booking from a booking number
     */
    private Booking__c findBooking(String bookingNumber) {
      System.debug('TQRegistrationService.findBooking: Looking for a booking for ' + bookingNumber + ' - ' + TRAFALGAR_BRANDING_NAME);
        List<Booking__c> bookings = [SELECT Id, Name, External_ID__c, Status__c FROM Booking__c 
            WHERE External_ID__c = :bookingNumber AND Brand__c = :TRAFALGAR_BRANDING_NAME
            AND (Status__c = 'CO' OR Status__c = 'UC')];

        return bookings != null && bookings.size() > 0 ? bookings.get(0) : null;
    }

    /**
     *  Check if the booking is valid
     */
    private Boolean invalidBooking(Booking__c booking) {
        return booking == null || (!booking.Status__c.equals('CO') && !booking.Status__c.equals('UC'));
    }

    /**
     *  Find a booking passenger from a booking number and user's details
     */
    private Booking_Passenger__c findBookingPassenger(Booking__c booking, String firstName, String lastName, String email) {
        List<Booking_Passenger__c> bookingPassengers = [SELECT Id, Customer__c 
            FROM Booking_Passenger__c WHERE Booking__c = :booking.Id
            AND First_Name__c = :firstName AND Last_Name__c = :lastName];   //Don't check for the email field
        return bookingPassengers != null && bookingPassengers.size() > 0 ? bookingPassengers.get(0) : null;
    }

    /**
     *  Find a booking passenger from a related person account
     */
    private Booking_Passenger__c findBookingPassenger(Account bookingPassengerPAccount) {
        List<Booking_Passenger__c> bookingPassengers = [SELECT Id, Customer__c FROM Booking_Passenger__c 
            WHERE Customer__c = :bookingPassengerPAccount.Id ];
        return bookingPassengers != null && bookingPassengers.size() > 0 ? bookingPassengers.get(0) : null;
    }

    /**
     *  Check if the booking passenger has no person account attached
     */
    private Boolean invalidPersonAccount(Booking_Passenger__c bookingPassenger) {
        return bookingPassenger == null || bookingPassenger.Customer__c == null;
    }

    public static Map<String, String> getRecordTypeMap(String objectApiName) {
        Map<String,String> accountRecordTypesMap = new Map<String,String>{};
        
        for(RecordType rt : [Select Name, Id From RecordType where sObjectType=:objectApiName and isActive=true]) {
            accountRecordTypesMap.put(rt.Name, rt.Id);
        }
        return accountRecordTypesMap;
    }

    /**
     *  Create a Person Account given customer's details
     */
    private Account createAccountAndPassenger(Booking__c booking, String firstName, String lastName, String email) {
        // Create the account
        Map<String, String> accountRecordTypeMap = getRecordTypeMap('Account');
        Account customerPA = new Account(
            RecordTypeId = accountRecordTypeMap.get(ACCOUNT_RECORD_TYPE_CUSTOMER),
            FirstName = firstName,
            LastName = lastName, 
            Email__c = email
        );
        insert customerPA;

        // Create the booking passenger
        Map<String, String> bookingPassengerRecordTypeMap = getRecordTypeMap('Booking_Passenger__c');

        List<Booking_Passenger__c> otherPassengers = [select Name from Booking_Passenger__c where Booking__c = :booking.Id];

        // QUESTION: Understand how this works
        String bookingPassengerName = null;
        if(otherPassengers == null || otherPassengers.size() == 0) {
            bookingPassengerName = 'TTUKLS#' + booking.External_ID__c + '#001';
        } else {
            String otherPassegnersName = otherPassengers.get(0).Name;
            bookingPassengerName = otherPassegnersName.substring(0, otherPassegnersName.lastIndexOf('#')+1) 
                + formatNumber(otherPassengers.size() + 1);
        }

        // Create a new booking passenger
        Booking_Passenger__c bookingPassenger = new Booking_Passenger__c(
            RecordTypeId = bookingPassengerRecordTypeMap.get(BOOKING_PASSENGER_RECORD_TYPE_BOOKING_PASSENGER),
            Booking__c = booking.Id,
            Customer__c = customerPA.Id,
            Name = bookingPassengerName
        );
        insert bookingPassenger;

        // QUESTION: Shall we save also a booking component?

        return customerPA;
    }

    /**
     *  Format an integer, returning always a 3-digits string
     */
    private String formatNumber(Integer n) {
        return n > 99 
            ? '' + n
            : n > 9
                ? '0' + n
                : '00' + n;
    }

    /**
     *  Find an account
     */
    private Account findAccount(String accountId) {
        List<Account> accounts = [SELECT Id, PersonEmail FROM Account WHERE Id = :accountId];
        return accounts != null && accounts.size() > 0 ? accounts.get(0) : null;
    }

    /**
     *  Align the Person Account with the values specified in the form
     */
    private void updatePassengerPAccount(Account bookingPassengerPAccount, String email) {
        if(bookingPassengerPAccount != null) {
            bookingPassengerPAccount.PersonEmail = email;
            update bookingPassengerPAccount;
        }
    }


    /**
     *  Find or create a tour instance
     * !!!! 30/08/2016 FMM Commented out this method, Tour Instances should only be created via the Informatica routine
     */
//    private List<Tour_Instance__c> findCreateTourInstances(Booking_Passenger__c bookingPassenger) {
//      List<Tour_Instance__c> tourInstances = new List<Tour_Instance__c>();

//        Map<String, String> bookingComponentRecordTypeMap = getRecordTypeMap('Booking_Component__c');
//        String bookingComponentTourRecordTypeId = bookingComponentRecordTypeMap.get(BOOKING_COMPONENT_RECORD_TYPE_TOUR);

        // Load the related booking component
//        List<Booking_Component__c> bookingComponents = [SELECT Id, Name, Tour_Product_Operating_Product_Code__c, Departure_Code__c,
//            Booking_Number__c, Booking_Number__r.Name, Booking_Number__r.External_ID__c, Start_Date__c, End_Date__c
//            FROM Booking_Component__c 
//            WHERE RecordTypeId = :bookingComponentTourRecordTypeId 
//            AND Booking_Passenger__c = :bookingPassenger.Id AND Status__c = 'CF' ];

//       if(bookingComponents != null && bookingComponents.size() > 0) {

          // Loop on all the booking components, they are different tours booked under the same booking
//          for(Booking_Component__c bookingComponent : bookingComponents) {
//                String departureCode = bookingComponent.Departure_Code__c;
//                String operatingProductCode = bookingComponent.Tour_Product_Operating_Product_Code__c;

                // Check if any expected info is null
//                if(departureCode == null || operatingProductCode == null) {
//                    System.debug('findCreateTourInstances: not enough information on booking component ' + departureCode + ' ' + operatingProductCode);
//                    return null;
//                } else {
            
                  // Check if a tour instance is already been created
//                  Tour_Instance__c tourInstance = null;
//                  List<Tour_Instance__c> existingTourInstances = [SELECT Id, Name FROM Tour_Instance__c 
//                      WHERE Operating_Product_Code__c = :operatingProductCode AND Departure_Code__c = :departureCode];
//                  if(existingTourInstances != null && existingTourInstances.size() > 0) {
//                      tourInstance = existingTourInstances.get(0);
//                  } 
                  // Create a new tour instance if required
//                  else {
                      // Create a Tour instance
//                      tourInstance = new Tour_Instance__c(
//                          Operating_Product_Code__c = operatingProductCode,
//                          Departure_Code__c = departureCode
//                      );
//                      insert tourInstance;
//                  }

                  // Loop back the booking component with the right tour instance
//                  bookingComponent.Tour_Instance__c = tourInstance.Id;

//                  tourInstances.add(tourInstance);
//                }
//          }

            // Update all the booking components with a loop back to the tour instance
//            update bookingComponents;

            // Return all the tour instances
//            return tourInstances;
//        } else {
//            System.debug('findCreateTourInstance: booking component not found');
//            return null;
//        }
//    }

    /**
     *  Find a tour instance by Id
     */
    private static Tour_Instance__c findTourInstance(Id tourInstanceId) {
        List<Tour_Instance__c> tourInstances = [SELECT Id, Name, Amount_of_Guests__c FROM Tour_Instance__c WHERE Id = :tourInstanceId];
        return (tourInstances != null && tourInstances.size() > 0) ? tourInstances.get(0) : null;
    }

    /**
     *  Find tour instances by Id
     */
    private static List<Tour_Instance__c> findTourInstances(List<Id> tourInstanceIds) {
        List<Tour_Instance__c> tourInstancesFetched = [SELECT Id, Name, Amount_of_Guests__c FROM Tour_Instance__c WHERE Id IN :tourInstanceIds];
        return (tourInstancesFetched != null && tourInstancesFetched.size() > 0) ? tourInstancesFetched : null;
    }

    /**
     *  Generate Self Registration Request Code
     */
    private static String generateSelfRegistrationRequestCode() {
        DateTime now = DateTime.now();
        Long currentTime = now.getTime();
        Double random = Math.random() * 100000;
        String randomStr = String.valueOf(random);

        return String.valueOf(currentTime) + randomStr.substring(0, randomStr.indexOf('.'));
    }
    
    /**
     *  Find a profile
     */
    public static Profile findCustomerProfileByName(String profileName) {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
        return profiles != null && profiles.size() > 0 ? profiles.get(0) : null;
    }

    /**
     *  Generate a username
     */
    private static String generateUsername(String email, Set<String> previousUsernames) {
        // For testing...
        email = getUsernamePrefix() + email + getUsernameSuffix();

        // Query similar users
        String emailFilter = email + '%';
        List<User> similarUsers = [SELECT username FROM User WHERE username = :emailFilter LIMIT 100];

        // If none has been found, email is a valid username
        if((similarUsers == null || similarUsers.size() == 0) && !previousUsernames.contains(email)) {
            System.debug('generateUsername: email as candidate ' + email);
            return email;    
        } else {
            // Loop to find a feasible one
            Set<String> usernames = new Set<String>();
            for(User similarUser : similarUsers) {
                usernames.add(similarUser.username);
            }

            // Try with the simple suffix
            String candidate = email + USERNAME_SUFFIX;
            if(!usernames.contains(candidate) && !previousUsernames.contains(candidate)) {
                System.debug('generateUsername: email and suffix as candidate ' + candidate);
                return candidate;
            } 
            // If all taken, try with numeric combinations
            else {
                String alternative;
                for(Integer i=0; i < 10; i++) {
                    alternative = candidate + String.valueOf(i);
                    if(!usernames.contains(alternative) && !previousUsernames.contains(alternative)) {
                        System.debug('generateUsername: email and suffix as candidate ' + alternative);
                        return alternative;
                    }
                }

                // Return a random one
                return generateSelfRegistrationRequestCode() + '@' + USERNAME_SUFFIX + '.com';
            }

        }
    }

    /**
    * Get the app settings
    */
    private static App_Settings__c getAppSettings() {
      return App_Settings__c.getValues(MYTRAFALGAR_CUSTOM_SETTING_NAME);
    }

    /**
    * Return the prefix to use for the username prefix
    */
    private static String getUsernamePrefix() {
      App_Settings__c appSettings = getAppSettings();
      return appSettings != null && appSettings.Username_Prefix__c != null 
        ? appSettings.Username_Prefix__c : '';
    }

    /**
    * Return the prefix to use for the username prefix
    */
    private static String getUsernameSuffix() {
      App_Settings__c appSettings = getAppSettings();
      return appSettings != null && appSettings.Username_Suffix__c != null 
        ? appSettings.Username_Suffix__c : '';
    }

    /**
    * Return the network ID
    */
    private static Id getNetworkId() {
      Network n = [Select Id from Network Where Name = :TRAFALGAR_COMMUNITY_NAME];
    return n != null ? n.Id : null;
    }

    /**
    * Follow a record on Chatter, if not followed already
    */
    private static Boolean chatterFollowTrips(List<Id> tourInstanceIds, String subscriberId) {
      if(tourInstanceIds != null && tourInstanceIds.size() > 0) {
          Id networkID = getNetworkId();
      if(networkID != null) {
              // check if the user is not already following the Trip Instance
              List<EntitySubscription> followedRecords = [SELECT Id, ParentId FROM EntitySubscription
                  WHERE ParentId IN :tourInstanceIds AND SubscriberId = :subscriberId AND NetworkId = :networkID];
              Set<Id> existingSubscriptions = new Set<Id>();
              for(EntitySubscription followedRecord : followedRecords) {
                existingSubscriptions.add(followedRecord.ParentId);
              }

              // Create new subscriptions if required
              List<EntitySubscription> newSubscriptions = new List<EntitySubscription>();
              for(Id tourInstanceId : tourInstanceIds) {
                if(!existingSubscriptions.contains(tourInstanceId)) {
                  newSubscriptions.add(new EntitySubscription(
                        ParentId = tourInstanceId,
                        SubscriberId = subscriberId,
                        NetworkId = networkID
                    ));
                }
              }

              // Persist the new feed subscriptions
              if(newSubscriptions.size() > 0) {
                insert newSubscriptions;
              }
        return true;
          }
      }
        return false;
    }

    /**
    * Mute all the email notifications related to the user - attached to the Network
    */
    private static void muteEmailNotifications(String userId) {
      Id networkID = getNetworkId();

    if(networkID != null) {
      //Find the team member for the user 
      List<NetworkMember> networkMembers = [ SELECT DefaultGroupNotificationFrequency,
        DigestFrequency,PreferencesDisableAllFeedsEmail,
        PreferencesDisableBookmarkEmail,PreferencesDisableChangeCommentEmail,
        PreferencesDisableFollowersEmail,PreferencesDisableItemFlaggedEmail,
        PreferencesDisableLaterCommentEmail,PreferencesDisableLikeEmail,
        PreferencesDisableMentionsPostEmail,PreferencesDisableProfilePostEmail,
        PreferencesDisableSharePostEmail,PreferencesDisCommentAfterLikeEmail,
        PreferencesDisMentionsCommentEmail,PreferencesDisProfPostCommentEmail
        FROM NetworkMember
        WHERE NetworkId = :networkID AND MemberId = :userId ];

      // Turn off all the email flags
      if(networkMembers != null && networkMembers.size() > 0) {
        NetworkMember networkMember = networkMembers.get(0);
        networkMember.DefaultGroupNotificationFrequency = 'N';
        networkMember.DigestFrequency = 'N';
        networkMember.PreferencesDisableAllFeedsEmail = true;
        networkMember.PreferencesDisableBookmarkEmail = true;
        networkMember.PreferencesDisableChangeCommentEmail = true;
        networkMember.PreferencesDisableFollowersEmail = true;
        networkMember.PreferencesDisableItemFlaggedEmail = true;
        networkMember.PreferencesDisableLaterCommentEmail = true;
        networkMember.PreferencesDisableLikeEmail = true;
        networkMember.PreferencesDisableMentionsPostEmail = true;
        networkMember.PreferencesDisableProfilePostEmail = true;
        networkMember.PreferencesDisableSharePostEmail = true;
        networkMember.PreferencesDisCommentAfterLikeEmail = true;
        networkMember.PreferencesDisMentionsCommentEmail = true;
        networkMember.PreferencesDisProfPostCommentEmail = true;

        update networkMember;
      }
    }
    }

    /**
    * Grab just the ids of the tour instance
    */
    private static List<Id> convertToIds(List<Tour_Instance__c> tourInstances) {
      List<Id> ids = new List<Id>();

      if(tourInstances != null) {
        for(Tour_Instance__c tourInstance : tourInstances) {
          ids.add(tourInstance.Id);
        }
      }

      return ids;
    }

    /**
    * Share the trip instance with a specific user
    */
    private static String shareTripInstances(List<Id> tourInstanceIds, Id userId) {
      if(tourInstanceIds != null && userId != null) {

        List<Tour_Instance__Share> tourInstaceShares = new List<Tour_Instance__Share>();
        for(Id tourInstanceId : tourInstanceIds) {
            Tour_Instance__Share tripInstanceShare = new Tour_Instance__Share();
            tripInstanceShare.ParentId = tourInstanceId;
            tripInstanceShare.UserOrGroupId = userId;
            tripInstanceShare.AccessLevel = 'Read';
            //tripInstanceShare.RowCause = Schema.Tour_Instance__Share.RowCause.Manual;
            
            tourInstaceShares.add(tripInstanceShare);
        }
          List<Database.SaveResult> saveResults = Database.insert(tourInstaceShares, false);

          // Check if they are all succesfull
          Boolean globalResult = true;
          String errors = '';
          for(Database.SaveResult saveResult : saveResults) {
            if(!saveResult.isSuccess()) {
              globalResult = false;
              errors += ' ' + saveResult.getErrors().get(0).getMessage();
            }
          }

          if(globalResult) {
                // Get the PersonAccountID of the created User
                Id personAccountId = getPersonAccountIdFromUser(userId);

                // Share also the booking with the user
                List<Booking__Share> bookingShares = new List<Booking__Share>();
                List<Booking_Component__c> bookingComponents = [SELECT Booking_Passenger__r.Booking__c 
                    FROM Booking_Component__c 
                    WHERE Tour_Instance__c IN :tourInstanceIds AND Booking_Passenger__r.Customer__c = :personAccountId];
                Booking__Share bookingShare = null;

                if(bookingComponents != null && bookingComponents.size() > 0) {
                    for(Booking_Component__c bookingComponent : bookingComponents) {
                        bookingShare = new Booking__Share();
                        bookingShare.ParentId = bookingComponent.Booking_Passenger__r.Booking__c;
                        bookingShare.UserOrGroupId = userId;
                        bookingShare.AccessLevel = 'Read';
                        //bookingShare.RowCause = Schema.Booking__Share.RowCause.Manual;
                        
                        bookingShares.add(bookingShare);
                    }
                }

                saveResults = Database.insert(bookingShares, false);

                // Check if they are all succesfull
                globalResult = true;
                errors = '';
                for(Database.SaveResult saveResult : saveResults) {
                    if(!saveResult.isSuccess()) {
                        globalResult = false;
                        errors += ' ' + saveResult.getErrors().get(0).getMessage();
                    }
                }

                if(globalResult) {
                  // Increase the amount of guests
                  updateTourInstancesGuests(tourInstanceIds);
                }
      } else {
              System.debug('TQRegistration - Failed to share a trip instance');
          }

          return globalResult ? null : errors;
        } else {
         return 'tour instances or user Id are null';
        }
    }

    /**
    * Update the amount of users on the tour instance - to trigger the sync on the app
    */
    @future
    private static void updateTourInstancesGuests(List<Id> tourInstancesInput) {
      List<Tour_Instance__c> tourInstances = findTourInstances(tourInstancesInput);
        
        if(tourInstances != null) {
          for(Tour_Instance__c tourInstance : tourInstances) {
            if(tourInstance.Amount_of_Guests__c == null) {
                  tourInstance.Amount_of_Guests__c = 0;
              }

              tourInstance.Amount_of_Guests__c++;
          }
            
            update tourInstances;
        }
    }

    /**
    * Search for existing users associated to the booking passenger account 
    */
    private static User bookingPassengerHasUserAlready(Account bookingPassengerPAccount) {
        if(bookingPassengerPAccount != null) {
            // Get the PersonContactId of the booking passenger account
            List<Account> personAccounts = [Select PersonContactId From Account Where Id = :bookingPassengerPAccount.Id];
            if(personAccounts != null && personAccounts.size() >= 0) {
                // Count if there is an existing user under the same Person Account
                String bookingPassengerPAContactId = personAccounts.get(0).PersonContactId;
                List<User> previousUsers = [SELECT Id, FirstName, LastName, Email, Username 
                    FROM User WHERE contactId = :bookingPassengerPAContactId];
                return previousUsers != null && previousUsers.size() > 0 ? previousUsers.get(0) : null;
            }    
        }
        return null;
    }

    /**
    * Get the PersonAccount ID from the UserID
    */
    public static Id getPersonAccountIdFromUser(Id userId) {
        if(userId != null) {
            List<User> users = [SELECT contactId FROM User WHERE Id = :userId];
            
            if(users != null && users.size() > 0) {
                Id contactId = users.get(0).contactId;
                List<Account> personAccounts = [Select Id From Account Where PersonContactId = :contactId];
                return personAccounts != null && personAccounts.size() > 0 ? personAccounts.get(0).Id : null;
            }
        }
        return null;
    }

}