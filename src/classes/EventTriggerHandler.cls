public with sharing class EventTriggerHandler  extends TriggerHandler 
{

	// written 04/09/2014 by John Jordan for Cloud Perspective
	
	// **************************
	// **** Constructor *********
	// **************************
	public EventTriggerHandler() 
	{
		
	}


	// **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
    	s_SetupBrands(newobjects); // Get User Brands And Decide What Brand To Stick On This event
    }

    // **********************************
    // ******* Before Update *************
    // **********************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) 
    {
 
    }

    // **********************************
    // ******* Before Delete *************
    // **********************************
    public override void beforeDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
    }

    // **********************************
    // ******* After Insert *************
    // **********************************
    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
       
    }


    // **********************************
    // ******* After Update *************
    // **********************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) 
    {

    }

    // **********************************
    // ******* After Delete *************
    // **********************************
    public override void afterDelete(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) 
    {
    }

    // **********************************
    // ******* After UnDelete *************
    // **********************************
    public override void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap)
    {       
    }

    // *****************************************************************************************************************************************************************************************************************************************************************************************************************************************************
    
    // *********************************************************************************************
    // *************** Get User Brands And Decide What Brand To Stick On This Task *****************
    // *********************************************************************************************

    private void s_SetupBrands(list<sobject> newevents)
    {
    	list<string> SelectedBrands = new list<string>();
    	list<string> UserBrandlist = ActivitiesByBrand_Controller.s_SetUserBrandList();
    	if (UserBrandList.size()==1) // easy decision, just use this brand
    	{
    		SelectedBrands = userBrandList; 
    	}
    	else 
    	{
    		// now try and find a default brand on the user record and if it exists, use that. 
    		user ThisUser = [select default_brand__c from user where id=:UserInfo.getUserId() limit 1];
    		if (ThisUser.default_brand__c != null && thisUser.default_brand__c != '')
    		{
    			SelectedBrands.add(ThisUser.Default_brand__C);
    		}
    		else
    		{
    			SelectedBrands.add(''); // this is the default and means "ALL"
    		}

    	}
    	string BrandString = '';
    	for(string s:SelectedBrands) BrandString = BrandString + s + ';';
    	// now put this brand onto the task
    	system.debug('brandstring:' + brandstring);
    	for(sobject so:newevents) so.put('Brands__C',brandstring);

 
    }



} // end class