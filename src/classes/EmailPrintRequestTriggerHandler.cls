// 
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: EmailPrintRequestTriggerHandler
// For Apex Trigger: EmailPrintRequestTrigger
// Description: Apex trigger handler class for sobject "Email_Print_Request__c".
//
// 12th January 2016    Leo Alves             Original
// 05th February 2016   Hemendra Singh Bhati  Modified (Task # T-473038) - Please see the task description for more details.
// 03rd March 2017      Abhishek Saxena Modified(T-568313)
// 08rd Nov 2017        Neeraj Kumawat Added check for Farewell Email Merge field(I-299931)
public class EmailPrintRequestTriggerHandler extends TriggerHandler {
  /**
  * @description  This method is called on after insert trigger event.
  *
  * @param        List<SObject> newObjects, Map<Id, SObject> newObjectsMap
  * @return       void
  */
  public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap)
  {
    processEmailPrintRequests(newObjects);
    generateFarewellRequest(newObjects);
  }


  /**
  * @description  This method is called on before insert trigger event.
  *
  * @param        List<SObject> newObjects
  * @return       void
  */
  public override void beforeInsert(List<SObject> newObjects){
      List<Email_Print_Request__c> newEmails = (List<Email_Print_Request__c>)newObjects;
      bisectModularRequests(newEmails);
  }
  
  
  private void bisectModularRequests(List<Email_Print_Request__c> newEmail){
      
       List<Email_Print_Request__c> eprV2 = new List<Email_Print_Request__c>();
       //List of tour instance ids.(I-299931)
       List<Id> tourInstanceIds=new List<Id>();
       //Map of tour Instance (I-299931)
       Map<Id, Tour_Instance__c> tourInstanceMap=new Map<Id,Tour_Instance__c>();
       List<Email_Print_Request__c> upsertEPR ;
       for(Email_Print_Request__c epr : newEmail){
          if(epr.Parameters__c != null && epr.Parameters__c.containsIgnoreCase('V2')){
              eprV2.add(epr);
              //Initializing tour instance ids list
              if(epr.Template__c == 'Farewell Email' || epr.Template__c == 'Farewell Email - Opt Out'){
                  tourInstanceIds.add(epr.Related_Object_Id__c);
              }
          }
       }
       //Fetching tour instance based of tour instance ids
       tourInstanceMap=new Map<Id, Tour_Instance__c>([Select Id, Farewell_Email_Merge__c From Tour_Instance__c where Id IN: tourInstanceIds]);
       if(eprV2 != null && eprV2.size() > 0){
            upsertEPR = getV2EPRs(eprV2,tourInstanceMap);
       }
     
       if(upsertEPR != null && upsertEPR.size() > 0){
            insert upsertEPR; 
       }
     
  } 
  
  /**
  * @description  This method is called to Clone Request based on No. Of Modules.
  *
  * @param        List<Email_Print_Request__c> newList
  * @return       List<Email_Print_Request__c> returnList : TO Save Modules Differently
  */
  private List<Email_Print_Request__c> getV2EPRs(List<Email_Print_Request__c> newEPRs,Map<Id,Tour_Instance__c> tourInstanceMap){
      List<Email_Print_Request__c> retEPRList = new List<Email_Print_Request__c>();
      for(Email_Print_Request__c epr : newEPRs){
        if(epr.Processing_Data__c != null && ( epr.Template__c == 'Welcome Email' ||
           epr.Template__c == 'Farewell Email' || epr.Template__c == 'Farewell Email - Opt Out')){
            TOPS_WelcomeEmailProcessor.BookingModule bModule;
            bModule = (TOPS_WelcomeEmailProcessor.BookingModule)JSON.deserializeStrict(epr.Processing_Data__c, TOPS_WelcomeEmailProcessor.BookingModule.class);
            if(bModule.modular == 'Yes' && (bModule.modules.size() > 1 && bModule.modules[0] != 'NONMOD')){
                Integer eprToClone = bModule.modules.size() - 1;
                epr.Processing_Data__c = null;
                TOPS_WelcomeEmailProcessor.BookingModule bMod = new TOPS_WelcomeEmailProcessor.BookingModule(
                                                        new List<String>(), bModule.Modular , bModule.booking);
                bMod.modules.add(bModule.modules[0]);
                String jsonPD = JSON.serialize(bMod);
                epr.Processing_Data__c = jsonPD;
                bModule.modules.remove(0);
                // Getting Tour Instance value of email print request(I-299931)
                Tour_Instance__c tourInstanceObj=tourInstanceMap.get(epr.Related_Object_Id__c);
                String FarewellEmailMerge='';
                //Initinize FarewellEmailMerge variable (I-299931)
                if(tourInstanceObj!=null){
                    FarewellEmailMerge=tourInstanceObj.Farewell_Email_Merge__c;
                }
                //Skip Bisect if template is farewell and farewell email is Only one farewell email for whole tour/trip(I-299931)
                if(!(FarewellEmailMerge=='Only one farewell email for whole tour/trip' && (epr.Template__c == 'Farewell Email' ||   epr.Template__c == 'Farewell Email - Opt Out'))){
                        for(integer ct = 0; ct < eprToClone ; ct++){
                            Email_Print_Request__c newEPR = epr.clone(false,false,false,false);
                            TOPS_WelcomeEmailProcessor.BookingModule bModNew = new TOPS_WelcomeEmailProcessor.BookingModule(
                                                                new List<String>(), bModule.Modular , bModule.booking);
                            bModNew.modules.add(bModule.modules[0]);
                            String jsonPDNew = JSON.serialize(bModNew);
                            newEPR.Processing_Data__c = jsonPDNew;
                            retEPRList.add(newEPR);
                            bModule.modules.remove(0);
                        }
               } 
            } 
        }
      }
        return retEPRList;
  }
  
  /**
  * @description  Calls TOPS_EmailPrintEngine batch job to send emails and print requests to TDs and/or other relevant third parties.
  *
  * @param        List<sObject> newObjects
  * @return       void
  */
  private void processEmailPrintRequests(List<sObject> newObjects)
  {
    // Initiating Email Print Service Engine.
    ID theJobID = System.enqueueJob(new TOPS_EmailPrintEngine(newObjects));
    system.debug('TRACE: EmailPrintRequestTriggerHandler - processEmailPrintRequests - theJobID - ' + theJobID);
  }

  private void generateFarewellRequest(List<sObject> newObjects)
  {
    List<sObject> optOutRequests = new List<sObject>();
    for (sObject obj : newObjects)
    {
      if (obj.get('Template__c') == 'Farewell Email')
      {
        sObject clonedObject = obj.clone();
        clonedObject.put('Template__c', 'Farewell Email - Opt Out');
        optOutRequests.add(clonedObject);
      }
    }
    if (optOutRequests.size() > 0)
      insert optOutRequests;
  }
}