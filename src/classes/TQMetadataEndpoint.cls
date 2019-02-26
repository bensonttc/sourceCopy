/**
 * Class to host the endpoint of the Metadata WebService 
 */
@RestResource(urlMapping='/tqmetadata/*')
global with sharing class TQMetadataEndpoint {
    
    /**
     * Return metadata information on the tracked objects 
     */
    @HttpPost
    webservice static TQMetadataResponse trackedObjectsInfo(String clientAppID) {
        //Prepare the output
        TQMetadataResponse response = new TQMetadataResponse();
        
        //Init the sevice
        TQIMetadataService metadataService = new TQMetadataService(clientAppID);
        
        //Get all the tracked objects
        List<TQMetadataResponse.TQMetadataResponseItem> responseItems = new List<TQMetadataResponse.TQMetadataResponseItem>();
        TQMetadataResponse.TQMetadataResponseItem trackedObject = null;
        
        try {
            for(String trackedObjectAPIName : metadataService.trackedObjectsAPINames(clientAppID)) {
                if (!metadataService.trackedObjectAccessible(trackedObjectAPIName)) continue;

                //Prepare the wrapper
                trackedObject = new TQMetadataResponse.TQMetadataResponseItem();
                
                //Set the API name
                trackedObject.setObjectApiName(trackedObjectAPIName);
                
                //Check if this object needs to be displayed
                trackedObject.setDisplayable(metadataService.trackedObjectDisplayable(trackedObjectAPIName));
                
                //Check the layout
                trackedObject.setLayoutNeeded(metadataService.trackedObjectLayouts(trackedObjectAPIName));
                
                //Check if only metadata should be dowloaded
                trackedObject.setOnlyMetadataNeeded(metadataService.trackedObjectOnlyMetadataNeeded(trackedObjectAPIName));
                
                //Include the list of custom indexes
                trackedObject.setObjectCustomIndexList(metadataService.trackedObjectCustomIndexList(trackedObjectAPIName));
                
                //Include the list of header fields
                trackedObject.setListHeaderFieldSet(metadataService.trackedObjectHeaderFieldSet(trackedObjectAPIName));
                
                //Get the fieldsets and parse them
                List<TQMetadataResponse.TQMetadataResponseFieldSet> fieldSets = new List<TQMetadataResponse.TQMetadataResponseFieldSet>();
                List<String> trackedObjectFieldSetsList = metadataService.trackedObjectFieldSetList(trackedObjectAPIName);
                Map<String, List<String>> trackedObjectFieldSetsMap = metadataService.trackedObjectFieldSets(trackedObjectAPIName);
                List<String> trackedObjectFieldSet = new List<String>();
                Set<String> includedFields = new Set<String>();
                
                // Unique set of fields in the fieldset(s) specified by the admin
                for(String trackedObjectFieldSetName : trackedObjectFieldSetsList) {
                    if (!trackedObjectFieldSetsMap.containsKey(trackedObjectFieldSetName)) continue;
                    fieldSets.add(new TQMetadataResponse.TQMetadataResponseFieldSet(trackedObjectFieldSetName, 
                        trackedObjectFieldSetsMap.get(trackedObjectFieldSetName)));
                        
                    for(String trackedObjectField : trackedObjectFieldSetsMap.get(trackedObjectFieldSetName)) {
                        if (!includedFields.contains(trackedObjectField)) {
                            trackedObjectFieldSet.add(trackedObjectField);
                            includedFields.add(trackedObjectField);
                        }
                    }
                }
                
                String nameField = metadataService.getNameField(trackedObjectAPIName);
                if (nameField != null && !includedFields.contains(nameField)){
                    trackedObjectFieldSet.add(nameField);
                    includedFields.add(nameField);
                }
                
                trackedObject.fieldSetList = fieldSets;
                trackedObject.detailFieldSet = trackedObjectFieldSet;
                
                // Add all the fields if no field sets are specified in the custom setting
                // RawRecordFieldSet contains detailFieldSet + Required fields + relathionship fields + system fields
                if(trackedObject.detailFieldSet == null || trackedObject.detailFieldSet.size() == 0) {
                    trackedObject.detailFieldSet = metadataService.getAllFieldSet(trackedObjectAPIName);
                    trackedObject.rawRecordFieldSet = trackedObject.detailFieldSet;
                } else {
                    trackedObject.rawRecordFieldSet = metadataService.getFullRecordFieldSet(trackedObjectAPIName, trackedObjectFieldSet);
                }
                
                // Include extra information
                // createFieldSet is the rawRecord - not creatable fields
                trackedObject.createFieldSet = metadataService.getCreateableFieldSet(trackedObjectAPIName, trackedObject.rawRecordFieldSet);
                
                // editableFieldSet is the rawRecord - not editable fields
                trackedObject.editFieldSet = metadataService.getUpdateableFieldSet(trackedObjectAPIName, trackedObject.rawRecordFieldSet);
                
                // default values for the sObject
                trackedObject.defaultValuesMap = metadataService.trackedObjectDefaultValues(trackedObjectAPIName);
                
                //Add this object to the main response wrapper
                responseItems.add(trackedObject);
            }
        
            //Wrap the response
            response.setBody(responseItems);
            response.setStatus(TQWebServiceResponse.SUCCESS);
            
        } catch(TQException e) {
            response.setStatus(e.getErrorCode());
        } catch(Exception e) {
            response.setStatus(TQWebServiceResponse.SERVER_GENERIC_ERROR);
        }
        
        return response;
    }

}