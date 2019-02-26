public with sharing class MDM_Recursion_Handler {
	public static boolean TurnOffCMDMAccountTrigger = false;
	public static boolean TurnOffMasterBeanTrigger = false;
	public static boolean TurnOffBeforeMB = false;
	public static boolean TurnOffAfterMB = false;
	
	
	public static list<Account> PersonAccounts;
	public static integer TriggerNumber = 1;
	public static string FirstTriggerTime;

	public static string getTriggerTime(){
		if(FirstTriggerTime == null){
			FirstTriggerTime = string.ValueOf(dateTime.now());
		}
		return FirstTriggerTime;
	}

	public static integer getInstanceNumber(){
		return TriggerNumber ++;
	}
}