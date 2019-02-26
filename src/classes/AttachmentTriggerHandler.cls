public with sharing class AttachmentTriggerHandler extends TriggerHandler 
{
	// written 04/09/2014 by John Jordan for Cloud Perspective
	
	// **************************
	// **** Constructor *********
	// **************************
	public AttachmentTriggerHandler() 
	{		
	} 

	// **********************************
    // ******* Before Insert *************
    // **********************************
    public override void beforeInsert(List<SObject> newObjects) 
    {
    	RelocateToInterimLinkedObject(newobjects);
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
    
    // ************************************************************************************************************************************************************
    // ***** If These Attachments Are Linked To Accounts or Contacts, re-connect them to a Note_Attachment_Connector__c object and populate with a brand **********
    // ************************************************************************************************************************************************************
    private void RelocateToInterimLinkedObject(list<sobject> newobjects)
    {

    	// locate any attachments that are connected to records in the Branded Notes list
    	list<attachment> needsprocessing = new list<attachment>();
    	for(sobject a:newobjects) 
    	{
    		attachment at = (attachment)a;
    		ID pid= at.parentid;
    		String parentObjectType = pid.getSObjectType().getDescribe().getName();
            Branded_Notes__c BrandedSettings = Branded_Notes__c.getValues(parentObjectType);

            //If there is a branded Setting then proceed
            if(BrandedSettings != null){
                needsprocessing.add(at);
            }
    	}
    	if (NeedsProcessing.size()==0) return; // nothing to do as nothing related to accounts or contacts in the list

    	// get brands as we will need it : 
    	String TheBrand='';
    	list<string> brands = ActivitiesByBrand_Controller.s_SetUserBrandList();
    	if (brands.size()==1) TheBrand = Brands[0];


    	// create link objects and store the ID's of the newly created objects in a map so we can find them to link to the attachments
        map<attachment, Note_Attachment_Connector__c> attachToConnector = new map<attachment, Note_Attachment_Connector__c>();
        list<Note_Attachment_Connector__c> naclist = new list<Note_Attachment_Connector__c>();

    	for(attachment a:needsprocessing)
    	{
    		Note_Attachment_Connector__c nac = new Note_Attachment_Connector__c();
            ID pid=a.parentid;
            String parentObjectType = pid.getSObjectType().getDescribe().getName();
            Branded_Notes__c BrandedSettings = Branded_Notes__c.getValues(parentObjectType);
            if(BrandedSettings.Attachment_Lookup__c != null){
                try{
                    nac.put(BrandedSettings.Attachment_Lookup__c, a.parentid);
                }
                catch(exception e){
                    system.debug(LOGGINGLEVEL.ERROR, 'Error Setting Lookup = '+ e.getMessage());
                }
            }
			nac.type__c = 'Attachment';
			nac.brands__c = TheBrand;	
			naclist.add(nac);
            attachToConnector.put(a, nac);
    	}
        insert naclist;

        //add Connector ID to the Attachment
        for(attachment a: attachToConnector.keySet()){
            Note_Attachment_Connector__c Connect = attachToConnector.get(a);
            if(Connect != null){
                a.parentid = Connect.id;
            }
        }
    }
    
}