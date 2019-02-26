/*
	(c) 2016 Appirio, Inc.
	
	Created By : Manisha Gupta
	Created On : Jan 28, 2016
	Purpose : Trigger on Passenger with below functionality:
			- Whenever Age, Gender or MTS User field is updated on Passenger, update following fields on Tour Instance:
					1. Age Count - Sum of age
					2. Average Age - Sum of age / Number of passengers
					3. Number of Children - number of passengers where age < 18
					4. Average Age of Children -  sum of age < 18 / number of passengers where age < 18 
					5. Number of Men - Sum of passengers where Gender = Male
					6. Number of Women - Sum of passengers where Gender = Female
					7. Number of Men with Past Trips -  Sum of passengers where Gender = Male AND Previous_Trips__c > 0
					8. Number of Women with Past Trips - Number (2, 0) - Sum of passengers where Gender = Female AND Previous_Trips__c > 0
					9. To calculate Number Grand European, look at the selling company code. If the code starts with 'GE', it is a Grand European passenger.
					10. To calculate Number of MTS Users, sum all passengers where MTS_User__c == True
	
*/
trigger PassengerTrigger on Passenger__c (before insert, before update, after insert, after update, before delete, 
																after delete, after undelete)
{
    system.debug('Checking recursion');
    /*if (s_CheckRecursionOnTriggers.runonce())
    {
        system.debug('Recursion OK');*/
        PassengerTriggerHandler triggerHandler = new PassengerTriggerHandler();
        triggerHandler.execute();
        system.debug('Done execute');
    //}
}