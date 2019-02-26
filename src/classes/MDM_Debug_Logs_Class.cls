public class MDM_Debug_Logs_Class
{
    
    public String pName='';
    public integer SequenceCounter = 0;
    public DateTime LogStartDateTime;
    public integer y = 0; 
    public String StandardCat='';
    public boolean LogsEnabled;
    public Boolean UseShortLog;		//True = short, false =long
    public Debug_Log__c log;
    public List<Debug_Log__c> DLogList = new List<Debug_Log__c>();
    public decimal InstanceNumber;
    public string GroupTime;
    //constructor
    public MDM_Debug_Logs_Class(String InName, String DefaultCategory, boolean shortLog){
        pName = InName;
        LogStartDateTime = system.now();
        StandardCat = DefaultCategory;
        UseShortLog = shortLog;
        LogsEnabled = true;
        InstanceNumber = MDM_Recursion_Handler.getInstanceNumber();
        GroupTime = MDM_Recursion_Handler.getTriggerTime();

    }
    
     // *****************************************************************************************
    // *********** Drop In A New Transaction ***************************************************
    // *****************************************************************************************
    public void LogIt(String LogText, String LogCategory, Boolean LogErrors)
    {
		system.debug('Adding to Debug Log ='+LogText);
        if(LogsEnabled){
	        if (UseShortLog)
	        {
				SequenceCounter++;
				log = new Debug_Log__c(Name=pName);
				log.Job_Start_Date_Time_string__c = string.valueof(LogStartDateTime);
				if (LogCategory=='') {LogCategory=StandardCat;}
				log.Log_Type__c = LogCategory;
				log.Contains_Errors__c = logErrors; 
				log.Log__c = LogText; 
				log.TransactionDateTime__c = LogStartDateTime; 
				log.Sequence_Counter__c  = SequenceCounter;
                log.Instance_Number__c = InstanceNumber;
                log.Group_Time__c = GroupTime;
				// if the length is greater than the field length then split the record up into multiple records
				if (logText.length()>254) 
				{
				    log.log__c = logText.substring(0,240) + ' (...split)';
				    logIt('(split...) ' + LogText.substring(240,logtext.length()),LogCategory,LogErrors);
				}
	        
	        DLogList.add(log);
	        }
	        else // use short log (multiple entries per field)
	        {
	            if (log!=null) 
	            {   
	                if (log.Log_Long__c.length()+ logtext.length()>131072)
	                {
	                    DLogList.add(log);
	                    log = null;
	                }
	                else
	                {
	                     log.Log_Long__c =log.Log_Long__c+ LogText + '\n';    
	                     return;
	                }
	            }

	            SequenceCounter++;
	            log = new Debug_Log__c(Name=pName);
	            log.Job_Start_Date_Time_string__c = string.valueof(LogStartDateTime);
	            
                if (LogCategory=='') {LogCategory=StandardCat;}
                log.Log_Type__c = LogCategory;

	            if (logErrors) log.Contains_Errors__c = logErrors; 
	            log.Log_Long__c = LogText + '\n'; 
	            log.Sequence_Counter__c  = SequenceCounter;
	            log.TransactionDateTime__c = LogStartDateTime;  
                log.Instance_Number__c = InstanceNumber;
                log.Group_Time__c = GroupTime;
	        }  
	    } 
        
    } // end method 
    public void Quicklog(String LogText) // quick log
    {
        Logit(LogText,'',false);
    }
    public void BlankLog(String LogText) // quick log with a blank line after
    {
        Logit(LogText,'',false);
        Logit(' ','',false);
    }
    
    
    // *************************************************************
    // ********** Commit the Transactions To The System ************
    // *************************************************************
    public void Comit()
    {
    	if(LogsEnabled){
    		if (UseShortLog==false && log != null) 
	        {
	            DLogList.add(log); // if part way through a page, close the page
	            log = null;
	        }
	        insert DLogList;
	        
	        DLogList.clear();
    	}
    }

    // *************************************************************
    // *********************** Log an Error ************************
    // *************************************************************

    public void LogError()
    {
        log.Contains_Errors__c = true;
    }
    
    
    // *****************************************************************************************
    // ******* For The Log Name, Delete Rows Which Are Older Than the N Days Specified ********
    // *****************************************************************************************
    public void PurgeLogs(integer OlderThanNDays, Boolean AllTypes)
    {
        OlderThanNDays= OlderThanNDays * -1;
        DateTime t = DateTime.now();
        t = t.addDays(OlderThanNDays);
        List<Debug_Log__c> PurgeList;
        if (AllTypes)
        {
            PurgeList = [Select Name, ID from Debug_Log__c where TransactionDateTime__c < :t limit 9000];
        }
        else
        {
            PurgeList = [Select Name, ID from Debug_Log__c where Name=:pName and TransactionDateTime__c < :t limit 9000];
        }
        LogIt('Purging ' + String.valueOf(PurgeList.size()) + ' records','Purge',false);
        delete PurgeList;
    } // end method   
} // end class