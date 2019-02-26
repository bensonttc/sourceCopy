public with sharing class s_CheckRecursionOnTriggers 
{
	private static boolean run = true;


    public static boolean runOnce()
    {
        system.debug('Recursion : run=' + run);
    	if(run)
    	{
     		run=false;
            system.debug('Returning true');
    	 	return true;
    	}else{
            system.debug('Returning ' + run);
        	return run;
    	}
    }
}