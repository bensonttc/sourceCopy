//
// (c) 2016 Appirio, Inc.
//
// Apex Batch Class Name: TOPS_EmailPrintEngine
// Description: Email Print Engine For Tops App.
//
// 22 June 2017  Abhishek Saxena    (T-624297)-Replaced TOPS_SendGridOutboundRequestDispatcher 
//                                  call with TOPS_SendGridOutboundRequestDispFuture 
public without sharing class TOPS_EmailPrintEngine implements Queueable, Database.AllowsCallouts {

  private Map<String, Email_Print_Request_Config__c> configRecordMap { get; set; }
  private List<Email_Print_Request__c> toBeProcessed { get; set; }


    public TOPS_EmailPrintEngine(List<sObject> emailPrintRequestRecords)
    {
        toBeProcessed = (List<Email_Print_Request__c>)emailPrintRequestRecords;
        system.debug('TRACE: TOPS_EmailPrintEngine - TOPS_EmailPrintEngine - toBeProcessed - ' + toBeProcessed);
    }

  /**
  * @description  Query config records and set values on configRecordMap.
  *
  * @param        void
  * @return       void
  */
    private void queryConfigRecords()
    {
        configRecordMap = new Map<String, Email_Print_Request_Config__c>();
        for(Email_Print_Request_Config__c config : [SELECT Name, Template__c, Field_Sets__c, Page_Or_Class__c, Type__c, Attachments_to_include__c, Default_Subject__c, Default_Body__c FROM Email_Print_Request_Config__c])
        {
            configRecordMap.put(config.Template__c, config);
        }
        system.debug('TRACE: TOPS_EmailPrintEngine - queryConfigRecords - configRecordMap - ' + configRecordMap);
    }

    /**
    * @description  Calls TOPS_EmailPrintEngine batch job to send emails and print requests to TDs and/or other relevant third parties.
    *
    * @param        Database.BatchableContext BC
    * @param        List<sObject> scope - Scope of records being processed at a given context.
    *                                     Note that scope should always be 10 max, in order to avoid governor limits.
    */
    public void execute(QueueableContext context) {
        try
        {
            // Fetching Config Records.
            this.queryConfigRecords();

            if(toBeProcessed.size() > 0)
            {
                Email_Print_Request_Config__c configRecord = null;
                List<TOPS_EmailWrapper> theEmailWrappersToProcess = new List<TOPS_EmailWrapper>();

                // Iterate through all requests in current scope.
                String theTemplate = null;
                for(Email_Print_Request__c theRequest : toBeProcessed)
                {
                    theTemplate = (String)theRequest.get('Template__c');
                    if(configRecordMap.containsKey(theTemplate))
                    {
                        // Retrieve the config record for a specific template.
                        configRecord = configRecordMap.get(theTemplate);

                        if(configRecord.Type__c == Label.Print)
                        {
                            system.debug('TRACE: TOPS_EmailPrintEngine - execute - Initiating Print Service.');
                            theEmailWrappersToProcess.add(TOPS_PrintService.createEmailWrapper(theRequest, configRecord));
                        }
                        else if(configRecord.Type__c == Label.Email)
                        {
                            system.debug('TRACE: TOPS_EmailPrintEngine - execute - Initiating Email Service.');
                            theEmailWrappersToProcess.add(TOPS_EmailService.createEmailWrapper(theRequest, configRecord));
                        }
                    }
                }

                if(theEmailWrappersToProcess.size() > 0)
                {
                    // set from addresses using helper method
                    TOPS_Helper.setFromAddresses(theEmailWrappersToProcess);
                    // Sending Emails Using SendGrid API.
                    // 22 June 2017  Abhishek Saxena    (T-624297)
                    //TOPS_SendGridOutboundRequestDispatcher theEmailDispatcher = new TOPS_SendGridOutboundRequestDispatcher(theEmailWrappersToProcess);
                    TOPS_SendGridOutboundRequestDispFuture theEmailDispatcher = new TOPS_SendGridOutboundRequestDispFuture(theEmailWrappersToProcess);
                }
            }
        }
        catch(Exception e) {
            system.debug('TRACE: TOPS_EmailPrintEngine - execute - Exception Message - ' + e.getMessage());
            system.debug('TRACE: TOPS_EmailPrintEngine - execute - Exception Stack Trace - ' + e.getStackTraceString());
        }
    }
}