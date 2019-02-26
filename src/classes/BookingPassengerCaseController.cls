public without sharing class BookingPassengerCaseController {
    
    public case TheCase {get; set;}
    //private booking_Passenger__c pax;
    private ApexPages.StandardSetController stdController;
    public boolean renderPage {get; set;}
    private CaseInfo CaseIn;


    public BookingPassengerCaseController(ApexPages.StandardSetController stdC) { 
        stdController = stdC; 
        renderPage = false;    
        Init();
    }
    
    public class CaseInfo{
        private ID ObjectID;
        private list<booking_Passenger__c> pax;
        private list<booking_component__c> comp;
        public ID paxID;
        public ID BookingID;
        public ID BookOwnerID;
        public boolean OwnerActive;
        public ID BusinessUnitID;
        public ID LeadPassengerID;
        public ID PassengerCustomer;
        public ID ComponentID;
        public string bookStatus;

        public CaseInfo(ID ObjID){
            ObjectID = ObjID;
            pax = [Select id, name,booking__c, booking__r.ownerID, booking__r.Selling_company__c, booking__r.Status__c, booking__r.owner.IsActive, customer__c, booking__r.lead_passenger__c From booking_passenger__c Where Id = :ObjectID];
            system.debug(pax);

            comp = [Select id, name,booking_passenger__c, booking_passenger__r.booking__c, booking_passenger__r.booking__r.ownerID, booking_passenger__r.booking__r.Selling_company__c, booking_passenger__r.booking__r.Status__c, booking_passenger__r.booking__r.owner.IsActive, booking_passenger__r.customer__c, booking_passenger__r.booking__r.lead_passenger__c From booking_component__c Where Id = :ObjectID];
            system.debug(pax);

            if(pax.size() > 0){
                booking_passenger__c paxSingle = pax[0];
                paxID = paxSingle.ID;
                BookingID = paxSingle.booking__c;
                BookOwnerID = paxSingle.booking__r.ownerID;
                OwnerActive = paxSingle.booking__r.owner.IsActive;
                BusinessUnitID = paxSingle.booking__r.Selling_company__c;
                LeadPassengerID = paxSingle.booking__r.lead_passenger__c;
                PassengerCustomer = ConvertPersonToContactID(paxSingle.customer__c);
                bookStatus = paxSingle.booking__r.Status__c;
            }
            else if(comp.size() > 0){
                booking_component__c compSingle = comp[0];
                ComponentID = compSingle.ID;
                paxID = compSingle.booking_passenger__c;
                BookingID = compSingle.booking_passenger__r.booking__c;
                BookOwnerID = compSingle.booking_passenger__r.booking__r.ownerID;
                OwnerActive = compSingle.booking_passenger__r.booking__r.owner.IsActive;
                BusinessUnitID = compSingle.booking_passenger__r.booking__r.Selling_company__c;
                LeadPassengerID = compSingle.booking_passenger__r.booking__r.lead_passenger__c;
                PassengerCustomer = ConvertPersonToContactID(compSingle.booking_passenger__r.customer__c);
                bookStatus = compSingle.booking_passenger__r.booking__r.Status__c;
            }

        }

        public ID ConvertPersonToContactID(ID AccountID){
            //Get the Pax customer if one exists
            list<Account> Acc = new list<Account>();
            if(AccountID != null){
                Acc = [select PersonContactId from Account where id = :AccountID];
            }
            if(Acc.size() > 0){
                return Acc[0].PersonContactId;
            }
            else{
                return null;
            }
        }
    }


    public void Init(){
        //Get the Case
        TheCase = (case) stdController.getRecord();

        String ObjId = ApexPages.currentPage().getParameters().get('id');

        CaseIn = new CaseInfo(ObjId);

        //Get the Pax
        
        if(CaseIn.paxID == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'No Booking Passenger Selected'));
            return;
        }
        else if(CaseIn.BookingID == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'No Booking Found'));
            return;
        }
        else if(CaseIn.bookStatus != 'CO'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Booking is not Confirmed. Case cannot be created.'));
            return;
        }

        //get Case record Types
        map<string, id> caseRT = new map<string, id>();
        for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Case']){
            CaseRT.put(RT.DeveloperName, RT.id);
        }

        TheCase.RecordTypeID = CaseRT.get('Guest_Relations');

        //Set values on the case
        TheCase.OwnerID = userInfo.getUserId();
        TheCase.Business_Unit__c = CaseIn.BusinessUnitID;
        TheCase.Booking_passenger__c = CaseIn.paxID;
        TheCase.Lead_Passenger__c = CaseIn.LeadPassengerID;
        TheCase.ContactID = CaseIn.PassengerCustomer;
        TheCase.Booking_Component__c = CaseIn.ComponentID;
        TheCase.Case_Team_Members_Added__c = True;
        
        TheCase.Booking__c = CaseIn.BookingID;
        //TheCase.status = 'New';
        TheCase.ID = null;
        renderPage = true;
    }



    public pageReference SaveCase(){
        //Page reference
        PageReference PR;
        
        //Insert Case
        Database.SaveResult Casesr = database.insert(TheCase,false);
        if(Casesr.isSuccess()) {
            //Operation was successful, so get the ID of the record that was processed
            system.debug('Successfully inserted Case: ' + Casesr.getId());
            PR = new pageReference('/'+TheCase.ID);
        }
        else{
            //Operation failed, so get all errors 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Failed to create a case:'));                
            for(Database.Error err : Casesr.getErrors()) {
                                   
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,err.getStatusCode() + ': ' + err.getMessage()));
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Case fields that caused this error: ' + err.getFields()));
            }
            renderPage = false;
            return null;
        }
        
        
        //Inserting the Case Roles
        try{
            //List of Case roles
            map<string, ID> RoleNameToID = new map<string, ID>();
            for(CaseTeamRole CaseRole : [SELECT ID, Name FROM CaseTeamRole]){
                RoleNameToID.put(CaseRole.Name, CaseRole.ID);
            }
            
            //Delete Existing
            list<CaseTeamMember> CaseMemb = [select ID, parentID, teamroleID, MemberId from CaseTeamMember where parentID = :TheCase.ID];
            if(CaseMemb.size() > 0){
                database.delete(CaseMemb, false);
            }
            
            list<CaseTeamMember> CaseTeamListToUpsert = new list<CaseTeamMember>();

            //Create the Creator
            if(RoleNameToID.containsKey('Creator')){
                system.debug('Create Team Role Exists - create a new CaseTeamMember'); 
                CaseTeamMember CaseCreator = new CaseTeamMember(parentID = TheCase.ID, teamroleID = RoleNameToID.get('Creator'), MemberId = UserInfo.getUserId());
                CaseTeamListToUpsert.add(CaseCreator);
            }

            //Create the viewer
            if(RoleNameToID.containsKey('Viewer')){
                system.debug('Viewer Team Role Exists - create a new CaseTeamMember'); 
                if(CaseIn.OwnerActive){
                    system.debug('Booking owner is active'); 
                    CaseTeamMember CaseViewer = new CaseTeamMember(parentID = TheCase.ID, teamroleID = RoleNameToID.get('Viewer'), MemberId = CaseIn.BookOwnerID);
                    CaseTeamListToUpsert.add(CaseViewer);
                }
            }
            
            //Insert caseTeamMembers
            if(CaseTeamListToUpsert.size() > 0){
                for(Database.SaveResult sr : database.insert(CaseTeamListToUpsert,false)) {
                    if(sr.isSuccess()) {
                        //Operation was successful, so get the ID of the record that was processed
                        system.debug('Successfully inserted CaseTeamRole: ' + sr.getId());
                    }
                    else{
                        //Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            system.debug('The following error has occurred.');                    
                            system.debug(err.getStatusCode() + ': ' + err.getMessage());
                            system.debug('Case Team Role fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
        catch(exception e){
            system.debug('Error Occured');         
        }
        return PR;
    }
}