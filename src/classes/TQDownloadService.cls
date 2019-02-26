/**
 * Implementation of the TQIDownloadService, to handle the download information
 */
public with sharing class TQDownloadService implements TQIDownloadService {
    public final String ClientAppId;
    
    private final String SOQL_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'; //'yyyy-mm-ddThh:mm:ss.000Z';
    private final String API_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss';
    private final static String DefaultAppId = 'TquilaONE';
    public static Set<String> queryParameterVariables =  new Set<String>{'User', 'Query'};
    
    
    /*
     *  Holder for the custom settings
     */ 
    private Map<String, TQ_Tracked_Object_Config__c> objectsSetting;
    
    /*
     *  Default constructor
     */
    public TQDownloadService() {
        this(DefaultAppId); 
    }
    
    /*
    *  Constructor with ClientAppId
    */
    public TQDownloadService(String clientAppId) {
        this.ClientAppId = clientAppId;
        //Init the custom setting
        objectsSetting = TQTrackingUtils.getObjects(clientAppId);  
    }
    
    
    /**
     * Implementation of TQIDownloadService.shouldLoadData()
     */
    public Boolean shouldLoadData(String objectApiName){
        if (objectsSetting.containsKey(objectApiName)){
            TQ_Tracked_Object_Config__c trackedObjectSetting = objectsSetting.get(objectApiName);
            return !trackedObjectSetting.Only_Metadata_Needed__c;
        }
        else
            return false;
    }
    
    /**
     * Implementation of TQIDownloadService.computeObjectSyncType()
     */
    public TQDownloadObjectSyncType computeObjectSyncType(String objectApiName, DateTime fromDateTime, DateTime toDateTime) {
        // Check if the object has been correctly specified
        if(objectApiName != null && objectApiName.length() > 0) {
            //Check if this object should download data as well and not only metadata object
            if (!shouldLoadData(objectApiName)){
                return new TQDownloadObjectSyncType(TQDownloadSyncType.NONE, 0);    
            }
            
            // Check if at least the to date/time has been specified
            if(toDateTime != null) {
                
                String query = 'SELECT count() ' + computeQueryBodyCount(objectApiName, fromDateTime, toDateTime) + ' ALL ROWS ';
                system.debug('query--->'+query );

                Long countRecords = -1;
                try {
                    countRecords = Database.countQuery(query);
                } catch(Exception e) {
                    throw new TQDownloadException('Error executing query ' + query + ' | ' + e.getMessage(), TQDownloadResponse.SERVER_ERROR_COUNTQUERYERROR);
                }
                
                if(countRecords == 0) {
                    return new TQDownloadObjectSyncType(TQDownloadSyncType.NONE, 0);
                } else {
                    TQ_Tracked_Object_Config__c trackedObjectSetting = objectsSetting.get(objectApiName);
                    Integer maxRecordsBeforeFullSync = trackedObjectSetting != null && trackedObjectSetting.Max_Records_Before_Full_Sync__c > 0
                        ? Integer.valueOf(trackedObjectSetting.Max_Records_Before_Full_Sync__c) : 25000;
                
                    return new TQDownloadObjectSyncType(
                        (countRecords > maxRecordsBeforeFullSync || fromDateTime == null) ? TQDownloadSyncType.FULL : TQDownloadSyncType.INC,
                        countRecords);
                }
            } else {
                throw new TQDownloadException('toDateTime not defined', TQDownloadResponse.SERVER_ERROR_TODATENOTSPECIFIED);
            }
        } else {
            throw new TQDownloadException('objectApiName not defined', TQDownloadResponse.SERVER_ERROR_OBJECTNOTSPECIFIED);
        }
    }

    /**
     * Implementation of TQIDownloadService.computeObjectSyncQuery()
     */
    public String computeObjectSyncQuery(String objectApiName, DateTime fromDateTime, DateTime toDateTime) {
        
        // Check if the object has been correctly specified
        if(objectApiName != null && objectApiName.length() > 0) {
            
            // Check if at least the to date/time has been specified
            if(toDateTime != null) {
                
                // Get the unique list of fields from the fieldsets 
                List<String> fieldsSet = new List<String>();
                Set<String> includedFields = new Set<String>();
                
                TQIMetadataService metadataService = new TQMetadataService(ClientAppId);
                Map<String, List<String>> trackedObjectFieldSetsMap = metadataService.trackedObjectFieldSets(objectApiName);
                for(String trackedObjectFieldSetName : trackedObjectFieldSetsMap.keySet()) {
                    for(String trackedObjectField : trackedObjectFieldSetsMap.get(trackedObjectFieldSetName)) {
                        if (!includedFields.contains(trackedObjectField)) {
                            fieldsSet.add(trackedObjectField);
                            includedFields.add(trackedObjectField);
                        }
                    }
                }
                
                // Add all the fields if no field sets are specified in the custom setting
                // RawRecordFieldSet contains detailFieldSet + Required fields + relathionship fields + system fields
                fieldsSet = (fieldsSet == null || fieldsSet.size() == 0)
                    ? metadataService.getAllFieldSet(objectApiName)
                    : metadataService.getFullRecordFieldSet(objectApiName, fieldsSet);
                
                // Bring all together: fields and body of the query
                if(fieldsSet.size() == 0) {
                    throw new TQDownloadException('no field sets defined for ' + objectApiName, TQDownloadResponse.SERVER_ERROR_MISSINGFIELDSET);
                } else {
                    String fields = '';
                    Integer c = 1;
                    
                    for(String field : fieldsSet) {
                        fields += field + (c < fieldsSet.size() ? ',' : '');
                        c++;
                    }
                    
                    return 'SELECT ' + fields + ' ' + computeQueryBodyFields(objectApiName, fromDateTime, toDateTime);          
                }
            } else {
                throw new TQDownloadException('toDateTime not defined', TQDownloadResponse.SERVER_ERROR_TODATENOTSPECIFIED);
            }
        } else {
            throw new TQDownloadException('objectApiName not defined', TQDownloadResponse.SERVER_ERROR_OBJECTNOTSPECIFIED);
        }
    }
    
    /**
     * Prepare a date/time for Apex SOQL
     * @param dt instance of date time
     * @returns string to use in SOQL
     */
    private String apiFriendlyDateTime(DateTime dt, Boolean apiFriendlyDateTime) {
        return (apiFriendlyDateTime) 
            ? dt.formatGmt(API_DATETIME_FORMAT) + 'Z'
            : dt.formatGmt(SOQL_DATETIME_FORMAT);
    }
    
    /**
     * In regards of the specified timeframe, create the FROM/WHERE statement of the SOQL query
     * @param objectApiName name of the object
     * @param fromDateTime from date
     * @param toDateTime to date
     */
    private String computeQueryBodyFields(String objectApiName, DateTime fromDateTime, DateTime toDateTime) {
        return computeQueryBody(objectApiName, false, fromDateTime, toDateTime, true);
    }
    
    /**
     * In regards of the specified timeframe, create the FROM/WHERE statement of the SOQL query
     * @param objectApiName name of the object
     * @param fromDateTime from date
     * @param toDateTime to date
     */
    private String computeQueryBodyCount(String objectApiName, DateTime fromDateTime, DateTime toDateTime) {
        return computeQueryBody(objectApiName, true, fromDateTime, toDateTime, false);
    }

    /**
     * Prepare where clause for the concrete object query
     * @param objectApiName name of the object
     * @param apiFriendlyDateTime to make it nice for the api  
     */    
    public String calculateWhereClauseForObject(String objectApiName, Boolean apiFriendlyDateTime){
        // Get the custom setting for the object 
        TQ_Tracked_Object_Config__c trackedObjectSetting = objectsSetting.get(objectApiName);
        
        if (trackedObjectSetting != null){
            String whereClause = trackedObjectSetting != null && trackedObjectSetting.Where__c != null 
                    && trackedObjectSetting.Where__c.trim() != '' ? ' ( ' + trackedObjectSetting.Where__c + ' ) ' : null;
                    
            if (whereClause != null) {
                whereClause = extendSyncWithCustomLogic(objectApiName, whereClause);
                whereClause = replaceQueryParameters(whereClause, apiFriendlyDateTime);
            }
                
            return whereClause;
        }
        else
            return null;
    }

    /**
     * Extend the creation of the where clause with a custom logic - project specific
     * @param objectApiName name of the object
     * @param whereClause where clause to extend
     */  
    @testVisible
    private String extendSyncWithCustomLogic(String objectApiName, String whereClause) {

        // Extend the records that we sync for the Tour Product and the Itinerary Items
        if(objectApiName.equalsIgnoreCase('Tour_Product__c') || objectApiName.equalsIgnoreCase('Itinerary_Item__c')) {
            // Find the tour products related to the tour instances that the user can see
            Set<Id> tourProductIds = new Set<Id>();

            // Booking components are what we need to check if the running user is the Guest
            List<Booking_Component__c> userBookingComponents = [SELECT Product__c FROM Booking_Component__c];
            if(userBookingComponents.size() > 0) {
                for(Booking_Component__c userBookingComponent : userBookingComponents) {
                    if(userBookingComponent != null && userBookingComponent.Product__c != null) {
                        tourProductIds.add(userBookingComponent.Product__c);
                    }
                }
            }

            // Sync also the Tour Product specified in the Tour Instance - if the running user is a TD
            Id runningUserID = UserInfo.getUserId();
            if(runningUserID != null) {
                List<User> runningUsers = [SELECT Id, Is_Travel_Director__c FROM User WHERE Id = :runningUserID];
                if(runningUsers != null && runningUsers.size() > 0) {
                    User runningUser = runningUsers.get(0);
                    
                    // If the running user is a TD, make sure we are syncing also 
                    // the Tour Product specified for him in the Tour Instance
                    if(runningUser != null && runningUser.Is_Travel_Director__c) {
                        // Get all the related tour instances
                        List<Tour_Instance__c> tdTourInstances = [SELECT Tour_Product__c FROM Tour_Instance__c 
                            WHERE Tour_Product__c != null AND Travel_Director__c = :runningUserID];
                        if(tdTourInstances.size() > 0) {
                            // Concatenate a 
                            for(Tour_Instance__c tdTourInstance : tdTourInstances) {
                                if(tdTourInstance != null && tdTourInstance.Tour_Product__c != null) {
                                    tourProductIds.add(tdTourInstance.Tour_Product__c);
                                }
                            }
                        }
                    }
                }
            }
                
            if(tourProductIds.size() > 0) {
                // Concatendate the tour product ids in a single string
                String productIds = '';
                List<Id> tourProductIdList = new List<Id>(tourProductIds);
                for(Integer i = 0; i < tourProductIdList.size(); i++) {
                    productIds += '\'' + tourProductIdList.get(i) + '\'';
                    if(i < tourProductIdList.size() - 1) productIds += ', ';
                }

                // Append the list of ids in the query
                if(objectApiName.equalsIgnoreCase('Tour_Product__c')) {
                    whereClause = '( (' + whereClause + ') OR Id IN (' + productIds + ') )';
                } else if(objectApiName.equalsIgnoreCase('Itinerary_Item__c')) {
                    whereClause = '( (' + whereClause + ') OR Tour_Product__c IN (' + productIds + ') )';
                }
            }
        }

        // Extend the records that we sync for the Booking Components
        if(objectApiName.equalsIgnoreCase('Booking_Component__c')) {
            Id personAccountId = TQRegistrationService.getPersonAccountIdFromUser(UserInfo.getUserId());
            if(personAccountId != null) {
                whereClause = ' (' + whereClause + ') AND Booking_Passenger__r.Customer__c = \'' + personAccountId + '\' ';
            }
        }

        System.debug('TQDownloadService.extendSyncWithCustomLogic.'+objectApiName+': ' + whereClause);
        return whereClause;
    }

    /**
     * In regards of the specified timeframe, create the FROM/WHERE statement of the SOQL query
     * @param objectApiName name of the object
     * @param ignoreOrderBy true if orderBy part should not be added to the query body
     * @param fromDateTime from date
     * @param toDateTime to date
     * @param apiFriendlyDateTime to make it nice for the api  
     */
    private String computeQueryBody(String objectApiName, Boolean ignoreOrderBy, DateTime fromDateTime, DateTime toDateTime, Boolean apiFriendlyDateTime) {
        // Get the custom setting for the object 
        TQ_Tracked_Object_Config__c trackedObjectSetting = objectsSetting.get(objectApiName);
        
        // Fetch the where and the orderBy configurations
        String whereClause = calculateWhereClauseForObject(ObjectApiName, apiFriendlyDateTime);
        String orderBy = trackedObjectSetting != null && !ignoreOrderBy && trackedObjectSetting.Order_By__c != null
                && trackedObjectSetting.Order_By__c.trim() != '' ? trackedObjectSetting.Order_By__c : null;
        
        String dateFilterField = getDateFilterFieldName(ObjectApiName);
        
        // Build the body of the query
        // Sync problems are related with upper limit of dateTime we use to upload the sync configuration
        String query = ' FROM ' + objectApiName + (
                fromDateTime != null ? ( ' WHERE '
                    + (fromDateTime != null ? ' ' + dateFilterField + ' >= ' + apiFriendlyDateTime(fromDateTime, apiFriendlyDateTime) + ' ' : '')
                  //  + (fromDateTime != null && toDateTime != null ? ' AND ' : '')
                  //  + (toDateTime != null ? ' ' + dateFilterField + ' <= ' + apiFriendlyDateTime(toDateTime, apiFriendlyDateTime) + ' ' : '')
                ) : ''
            )
            + ' ' + (whereClause != null ? ( fromDateTime != null ? ' AND ' : ' WHERE ' ) + whereClause : '')
            + ' ' + ((orderBy != null) ? (' ORDER BY ' + orderBy) : '');
            
        System.debug('TQDownloadService.computeQueryBody: ' + objectApiName + '  -  ' + query);
        return query;       
    }
    
    /**
     * Recognizes which field should be used in query to put timeline conditions
     * @param objectApiName name of the object
     */
    private String getDateFilterFieldName(String ObjectApiName){
        String dateFilterField = 'LastModifiedDate';
        
        if (ObjectApiName == 'FeedItem' || ObjectApiName == 'FeedComment')
            dateFilterField = 'SystemModStamp';
        
        try {
            SObject defaultSObject = (sObject)Type.forName(objectApiName).newInstance();
            defaultSObject.get(dateFilterField);
        }
        catch(Exception e) {
            dateFilterField = 'CreatedDate';
        }
        return dateFilterField;
    }
    
    /**
     * Stringify default object to put it correctly in SOQL string
     * @param objectApiName name of the object
     * @param apiFriendlyDateTime which format of Datetime should be used for API or Apex SOQL
     */
    private String stringifyObjectForQuery(Object obj, Boolean apiFriendlyDateTime){
        if (obj == null)
            return 'null';
        else if (obj instanceof DateTime)
            return apiFriendlyDateTime((DateTime)obj, apiFriendlyDateTime);
        else if (obj instanceof Integer || obj instanceof Decimal || obj instanceof Boolean)
            return String.valueOf(obj);
        else
            return '\'' + String.valueOf(obj) + '\'';
    }
    
    
    /**
     * Returns update query string with all string parameters replaced into original values
     * @param objectApiName name of the object
     * @param apiFriendlyDateTime which format of Datetime should be used for API or Apex SOQL
     */
    private String replaceQueryParameters(String query, Boolean apiFriendlyDateTime){
        Map<String, String> parameterReplacementMap = new Map<String, String>();
        Pattern ParameterPattern = Pattern.compile('\\$([A-Za-z]+)\\.([A-Za-z0-9_]+)');
        
        Matcher ParameterMatcher = ParameterPattern.matcher(query);
        while (ParameterMatcher.find()){
            String ParameterGroup = ParameterMatcher.group(1);
            String ParameterVariable = ParameterMatcher.group(2);
            
            if (ParameterGroup != null || queryParameterVariables.contains(ParameterGroup)){
                String resultValue = '';
                if (ParameterGroup == 'User'){
                    User currentUser = TQTrackingUtils.getCurrentUser();
                    Object fieldValue = currentUser.get(ParameterVariable);
                    resultValue = stringifyObjectForQuery(fieldValue, apiFriendlyDateTime);
                }
                
                if (ParameterGroup == 'Query'){
                    resultValue = '(SELECT Id ' + computeQueryBody(ParameterVariable, true, null, null, apiFriendlyDateTime) + ')';                 
                }
                
                parameterReplacementMap.put(ParameterMatcher.group(), resultValue);
            }
        }
        
        for (String parameterToReplace : parameterReplacementMap.keySet()){
            query = query.replace(parameterToReplace, parameterReplacementMap.get(parameterToReplace));
        }
        
        return query;
    }
}