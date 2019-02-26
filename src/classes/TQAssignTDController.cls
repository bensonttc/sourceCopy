/**
 *  Controller for the TD Assignment functionality 
 *  required by the myTrafalgar app
 */
public with sharing class TQAssignTDController {

    public String nameFile {get; set;}
    public Blob contentFile {get; set;}
    String[] filelines = new String[]{};
    
    public List<Tour_Instance__c> tourInstances {get; set;}
    public List<String> error {get; set;}
    public List<String> success {get; set;}

    /**
     *  Generic Constructor
     */
    public TQAssignTDController() {}

    /**
     *  Upload the file and process it
     */
    public Pagereference parseTDAssignments() {
        nameFile = contentFile.toString();
        if(nameFile != null && nameFile.length() > 0) {
            String separator = nameFile.countMatches('\n') > 0 ? '\n' : '\r';
            saveTDAssignments(nameFile.split(separator));
        }
        return null;
    }

    /**
     *  Upload the file and process it
     */
    public void saveTDAssignments(String[] filelines) {
        // Output
        tourInstances = new List<Tour_Instance__c>();

        // Create the result
        error = new List<String>(filelines.size());
        success = new List<String>(filelines.size());

        //Get all the TD names and query the users
        Set<String> tdNames = new Set<String>();
        String tdname = null;
        String[] inputvalues = new String[]{};
        for(Integer i=1; i < filelines.size(); i++) {
            if(filelines[i] != null) {
                inputvalues = filelines[i].split(',');
                tdname = null;
                try {
                    tdname = inputvalues[4];
                } catch(Exception e) {
                    System.debug('TQAssignTDController.saveTDAssignments: TD name not found at line ' + i + ' ' + e.getMessage());   
                }
                if(tdname != null && tdname.length() > 0) {
                    tdNames.add(tdname);
                }
            }
        }

        if(tdNames != null && tdNames.size() > 0) {
            // Query the Salesforce users, to extract all the TDs
            Map<String, User> tdMap = new Map<String, User>();
            for(User td : [Select Id,Name FROM User 
                    WHERE Name IN :tdNames AND Is_Travel_Director__c = true and IsActive = true]) {
                tdMap.put(td.Name, td);
            }

            // Iterate over the assignments and create the Tour Instances
            if(tdMap != null && tdMap.size() > 0) {
                // Setup initial variables
                Tour_Instance__c tourInstance = null;
                User td = null;
                String operatingProductCode = null, departureCode = null;
                Date startDate = null, endDate = null;

                //Read the file and create the tour instances
                for(Integer i=1; i < filelines.size(); i++) {
                    // Empty shared variables
                    td = null;
                    operatingProductCode = null; departureCode = null;
                    startDate = null; endDate = null;

                    // Get the line
                    if(filelines[i] != null) {
                        inputvalues = new String[]{};
                        inputvalues = filelines[i].split(',');

                        if(inputvalues != null && inputvalues.size() > 0) {
                            // Get the TD
                            try {
                                td = tdMap.get(inputvalues[4]);    
                            } catch(Exception e) {
                                System.debug('TQAssignTDController.saveTDAssignments: TD name not found at line ' 
                                    + i + ' ' + e.getMessage());   
                            }

                            // Read the line
                            operatingProductCode = cleanField(inputvalues[0]);
                            departureCode = cleanField(inputvalues[1]);
                            startDate = parseDate(inputvalues[2]);
                            endDate = parseDate(inputvalues[3]);

                            // Check we have all we need
                            if(td == null) {
                                addErrorMessage('TD not found for name', i, inputvalues[4]);
                            } else if(operatingProductCode == null) {
                                addErrorMessage('operating Product Code not found', i);
                            } else if(departureCode == null) {
                                addErrorMessage('departure code not found', i);
                            } else if(startDate == null) {
                                addErrorMessage('start date not found', i);
                            } else if(endDate == null) {
                                addErrorMessage('end date not found', i);
                            } else {
                                tourInstance = new Tour_Instance__c();
                                tourInstance.Operating_Product_Code__c = operatingProductCode;
                                tourInstance.Departure_Code__c = departureCode;
                                tourInstance.Start_Date__c = startDate;
                                tourInstance.End_Date__c = endDate;
                                tourInstance.Travel_Director__c = td.Id;

                                tourInstances.add(tourInstance);
                            }
                        }
                    }
                }
            } else {
                addErrorMessage('No TD Users found', 0);
            }
        } else {
            addErrorMessage('No TD names found', 0);
        }

        if(tourInstances != null && tourInstances.size() > 0) {
            List<Database.SaveResult> dbResult = Database.insert(tourInstances, false);

            for(Integer i = 0; i < dbResult.size(); i++) {
                Database.SaveResult sr = dbResult.get(i);

                if (sr.isSuccess()) {
                    addSuccessMessage(sr.getId(), i);
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        addErrorMessage('Error saving tour instances ' + err.getMessage(), i, ''+err.getFields());
                    }
                }
            }
        }
    }

    /**
     *  Add an error log in memory
     */
    private void addErrorMessage(String text, Integer line) {
        addErrorMessage(text, line, null);
    }

    /**
     *  Add an error log in memory
     */
    private void addErrorMessage(String text, Integer line, String parameterValue) {
        storeMessage(error, line,  text + ' ' + (parameterValue != null ? parameterValue : '')); 
    }

    /**
     *  Add an success log in memory
     */
    private void addSuccessMessage(Id tourInstanceId, Integer line) {
        storeMessage(success, line, 'Tour Instance created ' + tourInstanceId); 
    }

    /**
     *  Add an success log in memory
     */
    private void storeMessage(List<String> buff, Integer line, String message) {
        System.debug('storeMessage: ' + message + ' ' + line);
        buff.add(line, '' + line + ': ' + message);
    }

    /**
     *  Clean a string input
     */
    private String cleanField(String fieldValue) {
        return fieldValue != null
            ? fieldValue.trim()
            : null;
    }

    /**
     *  Clean a date input
     */
    private Date parseDate(String fieldValue) {
        Date fv = null;
        if(fieldValue != null) {
            try {
                // Try in the easy / canonical way
                fv = Date.parse(fieldValue);
            } catch(Exception e) {
                // Get a different expected format: 02-AUG
                Map <String, Integer> monthNames = new Map <String, Integer> {'jan'=>1, 'feb'=>2, 'mar'=>3, 'apr'=>4, 'may'=>5, 
                    'jun'=>6, 'jul'=>7, 'aug'=>8, 'sep'=>9, 'oct'=>10, 'nov'=>11, 'dec'=>12};
                List <String> stringParts = fieldValue.trim().split('-');

                try {
                    fv = Date.newinstance(System.Today().year(), monthNames.get(stringParts[1].toLowerCase()), 
                        Integer.valueOf(stringParts[0]));
                } catch(Exception e1) {
                    System.debug('Error parsing date' + e1.getMessage());   
                }
            }
        } 
        return fv;
    }
    
}