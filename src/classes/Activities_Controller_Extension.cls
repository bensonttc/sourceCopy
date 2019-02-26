public with sharing class Activities_Controller_Extension 
{
	public Account ThisAccount{get;set;}
	public Contact ThisContact{get;set;}
	public string SObjectType{get;set;}
	public Sobject ThisSobject{get;set;}
	public ID ThisID{get;set;}

	// *********************************
	// *********** Constructor *********
	// *********************************
	public Activities_Controller_Extension(ApexPages.StandardController stdController) 
	{
			/*boolean ErrorSoFar = false;
			// Is This An Account ????
			if (!ErrorSoFar)
			{
				try
				{
					ThisAccount = (Account)stdController.getRecord();
					SObjectType = 'Account';
				}
				catch(exception e) 
				{
					ErrorSoFar = true;
				}
			}
			// Is This An Account ????
			if (ErrorSoFar)
			{
				ErrorSoFar = false;
				try
				{
					ThisContact = (Contact)stdController.getRecord();
					SObjectType = 'Contact';
				}
				catch(exception e)
				{
					ErrorSoFar = true;
				}
			}
			*/
			ThisID = (id) stdController.getId();
			ThisSobject = stdController.getRecord();
			SObjectType = ThisID.getSObjectType().getDescribe().getName();


	} // end constructor

}