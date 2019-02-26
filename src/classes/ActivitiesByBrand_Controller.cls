// **** Built By John Jordan (Cloud Perspective) 01/09/2014
// **** Acts as a component controller for component ActivitiesByBrand which is used to
// **** restrict access to tasks/events that belong to accounts/contacts based on roles that the user
// **** belongs to. This is not true SFDC security, merely a way of hiding irrelevant activity
 

/* TO DO LIST */
// 1) ********* Get all brands a user can see from their role into a list 
// a) ********* get list from accounts where rt = brand
// b) ********* search user role for all these brands and put them into brand list - or if none found, give htem access to all. 
// 2) ********* Write code to list out all activities and events for an account - showing only those for the required brands
// a) ********* intiially combine tasks and events into same list upto n records
// b) ********* Sort list into date order
// c) ********* Filter by the brand stamp. 
// d) ******** if more than n records displayed (ie. any not displayed) then allow user to clcik on either "more tasks" or "more events" which uses querymore stuff to page through and has column headings sortable
// d1) ********Event List
// d2) ********Task List
// d3) ********Attachment List
// d4) ******** Note List
// 3) ********* Add buttons to add 
// a) ********** Task
// b) ********* Event
// c) ********* Log A Call
// d) ********* Mail Merge
// e) ********* New Note - use the task object but don't show then anything other than text box. 
// f) ********* Attach a file - use  custom object to store brand (object sits between the account and the attachment) 
// 4) ********* Build VF screens to handle the above button functions internally to the VF screen
// a) ********* Task
// a1) ******** No Longer Neeeded Ensure all fields and functionality is there inc validation etc. 
// b) ********* No Longer Neeeded Event
// c) ********* Log A Call 
// d) ********* Mail Merge
// e) ********* New Note
// f) ********* Attach a file
// 5) ********* Put VF screen only on travel agent office record type. 
// 6) ********* Add edit/delete/close controls to left of activity table
// 7) ********* No Longer Neeeded Pretty up task screen - buttons and field sequence
// 8) ********* Add a "ALL" to brand list for everyone when creating tasks but have it map to null or '' so that everyone see's it (ensure search pulls up '' as well as null)
// 9) ********* Do we split active tasks and history tasks into 2x screens or have it all in one table. Split I think 
// 10) ******** Write a trigger so that when a task or event is created, it calculates (for single brands) the brand, for multi brands, if there is a default on the user record it uses that, otherwise it sets to all available
// 10b) ******** Write trigger for event also. 
// 11) ********* Add a function for multi brand users to edit brand without editing the actual record. 
// 12) ********* Only people with no brand should have the ability to change brands after creation. or System admin
// 13) ********* Does this need to appear on contacts also ? Need to make a component if so
// 14) ********* Test on SF 1
// 15) ********* Hide create buttons VF screen from SF1 users as they don't work
// 16) Maybe change layout of view on SF1 user screen to make it simpler? 
// 17) ******** How do we add to new objects - documentation required. 
// 18) ******** Make sure "all" appears in the list of brands to everyone on screen. -- nobody see's this now. 
// 19) ******** Make body field on "Note" a bit bigger on screen. - if we keep it
// 20) ******** Can we put a first 255 characters of note on screen in table display. 
// 21) ******** Try and put a trigger on attachment so that when it is saved, if not attached to an interim object, link to that instead of account/contact and calculate brand as we do it. 
// 22) ******** If 21 works hide all record creation on screen and make buttons call standard objects as per tasks and activities. 
// 23) ******** Split out active  / non active events and tasks. 
// 24) ******** Drop down list to select whether to show "current activities" or "notes/attachments" or "activity history " - default is to show current activities. 
// 25) ******** Add a status wheel when changing drop down on display table (egg timer) - same for delete function 
// 26) ******** Column Heading Sorting On All "More data" lists (separate page)
// 27) ******* New note button not working. 
// 28) ******** Test coverage
// 29) ******* Deployment List
// 30) Testing
// 31) ******** Security setup - add to all profiles on sandbox. 
// 32) ******** Add documentation on new pages to spec document. 
// 32) ******** Add deployment list to documentation


// ************ Objects To Deploy ***************
// ** Account_Activities_Controller - class
// ** TaskTriggerHandler - class
// ** AttachmentTriggerHandler - class
// ** NoteTriggerHandler - class
// ** EventTriggerHandler - class
// ** TriggerHandler - class 
// ** s_CheckRecursionOnTrigger - class
// ** ActivityBrandStamping_Tests   - class. 
// ** Brand__c - new custom field on activities
// ** Default_Brand__c - field from user object. 
// ** Note_Attachment_Connector__c object and associated fields
// ** ActivitiesByBrand - component
// ** Contact_Activities - page
// ** ActivitiesByBrandMore - page
// ** Account_Activities - page
// ** AttachmentTrigger - trigger
// ** NoteTrigger - trigger
// ** EventTrigger - trigger
// ** TaskTrigger - trigger

// done : 
//  There are now actions against each row of ativities
//  More screen now works on all object types
//  drop down list drives what is seen on main screen. 
//  Body field now displays truncated on screen. 
//  Body field now bigger
// nice spinner shows when changing drop down list
// now any created note or attachment gets branded
// old note/attachment creation removed and commented out (uses standard now)
// can now edit brands (if you are a multi brand user)
// Edit/del items now on MORE page 
// Columns now all sort on "more" page. 


//Known Issues:
// - On the More Activities page for Tasks/Activities/Notes/Attachments the paged results page will fail if a user hits the last page if there are over 2000 records in the list.


 
global with sharing class ActivitiesByBrand_Controller 
{
    // shared variables
    public string SObjectType{get;set;} // component parameters 
    public string tempdebug{get;set;}
    public string userbrandliststr;

    // component variables 
    public ID sObjectID{get;set;} // component parameters 
    public boolean Display_Table{get;set;}
    //public boolean Display_Attachment{get;set;}
    //public boolean Display_Note{get;set;} 
    public boolean Display_UpdateBrands{get;set;}
    public list<string> SelectedBrandsOpt{get;set;}
    public List<SelectOption> BrandOptions{get;set;}
    public list<string> UserBrandList{get;set;}
    public string TaskType{get;set;}
    //public Attachment NewAttachment{get;set;}
    //public Note NewNote{get;set;}
    public integer MaxActivitiesInPageOneDisplay{get;set;}
    public integer activitywlistsize{get;set;}
    public List<SelectOption> DisplayOptions{get;set;}
    public string SelectedDisplay{get;set;}
    public Boolean EditAccessToThisObject{get;set;}

    public string Brand_ActivityID;
    public string Brand_ObjectType;

    // For More Page variables
    public integer MorePageSize = 50; // max number of rows per page on "more tasks" screen. 
    public list<task> MoreTasks{get;set;}
    public list<event> MoreEvents{get;set;}
    public list<AttachmentCombo> MoreNoteAttachments{get;set;}
    public string SourceRecordName{get;set;}
    public id ParentRecordID{get;set;}
    public string SourceObjectType{get;set;}
    public boolean disablePrevious{get;set;}
    public boolean disableNext{get;set;}
    public integer BigCounter{get;set;}
    public integer PosnCounter{get;set;}
    public string SortBy{get;set;}
    public string SortSeq{get;set;}


    // *********************************
    // *********** Constructor *********
    // *********************************
    public ActivitiesByBrand_Controller() 
    {
        display_table=true;
        disablePrevious = true;
        disablenext = false;
        USerBrandList = new list<string>();
        s_CalculateRoleBrandSettings();
        userbrandliststr = '';
        for(string s: userbrandlist) 
        {
            if (s!=null && userbrandliststr != '') userbrandliststr = userbrandliststr + ',';
            if (s!=null) userbrandliststr = userbrandliststr + '\'' + s + '\'';
        }
        selectedDisplay = 'Activities';
        DisplayOptions = new List<SelectOption>();
        DisplayOptions.add(new SelectOption('Activities','Open Activities'));
        DisplayOptions.add(new SelectOption('History','Activity History'));
        DisplayOptions.add(new SelectOption('NotesAttachments','Notes And Attachments'));

        // find out if the user is allowed to edit this object - ie. are they allowed to create notes/attachments
        EditAccessToThisObject = false; // by default - unless unset later 
    } 


    // *********************************************************************************
    // ******** Based on users role , which brands should they see / not see ***********
    // *********************************************************************************
    Private void s_CalculateRoleBrandSettings()
    {
        UserBrandList = s_SetUserBrandList();
        MaxActivitiesInPageOneDisplay = 999;
        Brandoptions = new List<SelectOption>();
        for(string s:userbrandlist) Brandoptions.add(new SelectOption(s,s));
        if (brandoptions.size()>1) Brandoptions.add(new SelectOption('*','ALL Brands'));
        SelectedBrandsOpt = new list<string>();
    }


    public static list<string> s_SetUserBrandList()
    {
        list<string> rUserBrandList = new list<string>();
        list<userrole> theRole = [select name from userrole where id=:userinfo.getUserRoleId() limit 1];
        RecordType RT = [select id from recordtype where name='Brand' and sobjecttype = 'Account' limit 1];
        list<account> brands = [select name from account where recordtypeid=:rt.id  limit 999];
        if (therole.size()>0) 
        {   
            for(account ac:brands)
            {
                if (TheRole[0].Name.toUppercase().contains(ac.name.ToUppercase())) ruserbrandlist.add(ac.name);
            }
        } 
        if (rUserBrandList.size()==0) for(account ac:brands) ruserbrandlist.add(ac.name); // no brands means ALL brands
        return RUserBrandList;  
    }

    // *******************************************************************
    // ***** Get all Activities That The User Is Allowed To See **********
    // *******************************************************************
    

    public list<activitywrapper> getActivitywList ()
    {
        // show the new note / new attachment buttons if the user has access to edit the account, otherwise hide them. 
        userRecordAccess ura = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId()  AND RecordId =:sobjectid limit 1];//:sobjectid limit 1];
        EditAccessToThisObject = ura.HasEditAccess;
    
        //set the field used for the task/event lookup
        //Lead/Contact = whoID
        //Account = AccountID
        //Other = WhatID

        string QueryStr = '';

        if(SObjectType == 'Account'){
             TaskType = 'accountid'; // used in the soql to find tasks
        }
        else if(SObjectType == 'Contact' || SObjectType == 'Lead'){
            TaskType='whoid'; // used in the SOQL to find tasks
        }
        else{
            TaskType='whatID'; // used in the SOQL to find tasks
        }
       

        list<activitywrapper> activitywlist = new list<activitywrapper>();

        //get the lookup field name from the custom Setting
        Branded_Notes__c BrandedSettings = Branded_Notes__c.getValues(SobjectType);
        if(BrandedSettings == null) BrandedSettings = new Branded_Notes__c();

        // ************* Attachments ***********
        if(SelectedDisplay=='NotesAttachments')
        {

            list<Note_Attachment_Connector__c> natlist = new list<Note_Attachment_Connector__c>();
            if(BrandedSettings.Attachment_Lookup__c != null){
                //Generic query using the object name
                querystr = 'select id,type__c,Name,brands__c,ownerID,owner.name,createddate from Note_Attachment_Connector__c where ' + BrandedSettings.Attachment_Lookup__c + ' = \'' + sObjectID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + '))order by createddate desc limit '+ MaxActivitiesInPageOneDisplay;    

                try{
                    natlist = database.query(querystr);
                }
                catch (exception e){
                    natlist = new list<Note_Attachment_Connector__c>();
                }
            }
            
            list<id> natids = new list<id>();
            for(Note_Attachment_Connector__c nat:natlist) natids.add(nat.id);
            list<attachment> atlist = [select id,parentid,name from attachment where parentid in:natids];
            list<Note> notelist = [select id,parentid,title,body from note where parentid in:natids];
            map<id,attachment> atmap = new map<id,attachment>();
            map<id,note> notemap = new map<id,note>();
            for(attachment at:atlist) atmap.put(at.parentid,at);
            for(note anot:notelist) notemap.put(anot.parentid,anot);
        
            for(Note_Attachment_Connector__c nat:natlist) 
            {
                Activity act = new Activity();
                act.subject = '??';
                if (atmap.containskey(nat.id)) 
                {
                    act.subject = atmap.get(nat.id).name; // get attachment file name
                    act.activityid = atmap.get(nat.id).id;
                    act.ObjectType = 'Attachment';
                }
                if (notemap.containskey(nat.id)) 
                {
                    act.subject = notemap.get(nat.id).title; // get note name
                    act.activityid = notemap.get(nat.id).id;
                    string Body = notemap.get(nat.id).body;
                    if (body != null && body.length()>255) Body=body.left(255);
                    act.body = body;
                    act.ObjectType = 'Note';

                }
            
                act.activitydate = null;
                act.ownerID = nat.ownerid;
                act.ownername = nat.owner.name;
                act.acttype = nat.type__c;
                act.createddate =  nat.createddate;
                act.brands = nat.brands__c;
                activitywrapper actw = new activitywrapper(act);
                activitywlist.add(actw);
            }
        

        } // else its tasks n that
        else
        {
            // ************* Tasks ***********
            if (SelectedDisplay=='History')
            {
                querystr = 'select id,brands__c,createddate,calltype,subject,ActivityDate,isclosed,status,owner.name,type,ownerID from task where  IsClosed=true and ' + tasktype +  ' = \'' + sObjectID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by activitydate desc, createddate desc limit '+ MaxActivitiesInPageOneDisplay; 
            }
            else
            {
                querystr = 'select id,brands__c,createddate,calltype,subject,ActivityDate,isclosed,status,owner.name,type,ownerID from task where IsClosed=false and ' + tasktype +  ' = \'' + sObjectID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by activitydate desc, createddate desc limit '+ MaxActivitiesInPageOneDisplay;    
            }

            list<task> tasklist = database.query(querystr);
            // ************* Events ***********

            if (SelectedDisplay=='History')
            {
                querystr = 'select id,brands__c,createddate,ActivityDateTime,ActivityDate,enddatetime,owner.name,subject,type,ownerID from event where ((isalldayevent=false and activitydatetime< ' + GetSOQLDateString(system.now()) + ') or (isalldayevent=true and activitydate< ' + GetSOQLDateString(system.today()) + ')) and ' + tasktype + ' = \'' + sObjectID + '\' and  (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by activitydate desc, createddate desc limit '+ MaxActivitiesInPageOneDisplay;        
            }
            else
            {
                querystr = 'select id,brands__c,createddate,ActivityDateTime,ActivityDate,enddatetime,owner.name,subject,type,ownerID from event where ((isalldayevent=false and activitydatetime>= ' + GetSOQLDateString(system.now()) + ') or (isalldayevent=true and activitydate>= ' + GetSOQLDateString(system.today()) + ')) and '  + tasktype + ' = \'' + sObjectID + '\' and  (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by activitydate desc, createddate desc limit '+ MaxActivitiesInPageOneDisplay;     
            }
            list<event> eventlist = database.query(querystr);
            system.debug('Query = '+querystr);
            system.debug('DateTime = '+system.now());

            for(task t:tasklist) 
            {
                Activity act = new Activity();
                act.subject = t.subject;
                act.istask = true;
                act.ownerID = t.ownerid;
                act.ownername = t.owner.name;
                act.ActivityID = t.id;
                act.activitydate = t.ActivityDate;
                //act.activitydatetime = t.ActivityDatetime;  //DateTime
                act.status = t.status;
                act.acttype = t.type;
                act.calltype= t.calltype;
                act.createddate =  t.createddate;
                act.brands = t.brands__c;
                act.objecttype = 'Task';
                activitywrapper actw = new activitywrapper(act);
                activitywlist.add(actw);
            
            } 

            for(event event:eventlist) 
            {
                Activity act = new Activity();
                act.subject = event.subject;
                act.activityid = event.id;
                act.activitydate = event.ActivityDate;  
                act.activitydatetime = event.ActivityDatetime;  //DateTime
                act.ownerID = event.ownerid;
                act.ownername = event.owner.name;
                act.acttype = event.type;
                act.createddate =  event.createddate;
                act.brands = event.brands__c;
                act.ObjectType = 'Event';
                activitywrapper actw = new activitywrapper(act);
                activitywlist.add(actw);
            }
        }

        // now sort and display
        activitywlist.sort();

        // now just load the most recent n 
        list<activitywrapper> templist = new list<activitywrapper>();
        integer AddCount = 1; 
        for(activitywrapper aw:activitywlist)
        {
            if (MaxActivitiesInPageOneDisplay>=AddCount) 
            {
                templist.add(aw);
                AddCount++;
            }
        }
        activitywlist = templist; 
        activitywlistsize = addcount;
        return activitywlist;
    
}

    // *************************************************
    // ************* Edit Brands    ********************
    // *************************************************
    public pageReference s_EditBrands()
    {

        string ActivityAction = ApexPages.currentPage().getParameters().get('ActivityAction');
        if (ActivityAction=='Edit')
        {
            Brand_ActivityID = ApexPages.currentPage().getParameters().get('ActivityID');
            Brand_ObjectType = ApexPages.currentPage().getParameters().get('ObjectType');
            // set the default in the picklist to what ever it already is
            string BrandsNow = ApexPages.currentPage().getParameters().get('ExistingBrands');
            SelectedBrandsOpt = BrandsNow.split(';');
            Display_Table = false; 
            Display_UpdateBrands = true;
        }
        if (ActivityAction=='Cancel')
        {
            Display_Table = true; 
            Display_UpdateBrands = false;
        }
        if (ActivityAction=='Save')
        {
            if (SelectedBrandsOpt==null || SelectedBrandsOpt.size()==0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'You must select a brand.'));
                return null;
            }
            
            // make sure selection is logical 
            boolean SelectedAll = false;
            boolean NotSelectedAll = false;
            for(string s:selectedbrandsOpt)
            {
                if (s=='*') SelectedAll = true; 
                if (s!='*') NotSelectedAll = true; 
            }
            if (SelectedAll && NotSelectedAll)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'You can only select "All Brands" if no other Brands are selected?'));
                return null;
            }

            // build list of selected brands
            string SelectedBrandsstr = '';
            for(string s:selectedbrandsOpt) SelectedBrandsstr = selectedbrandsstr + s+';'; // glue all brands together
            if (selectedBrandsstr=='*;') selectedBrandsstr='';


            // now locate the record in question and set the brand and update
            if (Brand_ObjectType=='Task')
            {
                list<task> tasklist = [select brands__c from task where id=:Brand_ActivityID limit 1];
                if (tasklist.size()<>1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Can not locate Task with ID of :' + brand_activityid));
                    return null;
                }
                tasklist[0].brands__c = selectedbrandsstr;
                update tasklist;
            }
            if (Brand_ObjectType=='Event')
            {
                list<event> eventlist = [select brands__c from event where id=:Brand_ActivityID limit 1];
                if (eventlist.size()<>1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Can not locate Event with ID of :' + brand_activityid));
                    return null;
                }
                eventlist[0].brands__c = selectedbrandsstr;
                update eventlist; 
            }
            if (Brand_ObjectType=='Attachment')
            {
                list<attachment> atlist = [select parentid from attachment where id=:Brand_ActivityID limit 1];
                if (atlist.size()<>1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Can not locate Attachment with ID of :' + brand_activityid));
                    return null;
                }
                list<Note_Attachment_Connector__c> NAClist = [select brands__c from Note_Attachment_Connector__c where id=:atlist[0].parentid limit 1];
                if (NAClist.size()<>1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Can not locate Note/Attachment connector with ID of :' + atlist[0].parentid ));
                    return null;
                }
                NAClist[0].brands__c = selectedbrandsstr;
                update NAClist; 
            }
            if (Brand_ObjectType=='Note')
            {
                list<note> notelist = [select parentid from note where id=:Brand_ActivityID limit 1];
                if (notelist.size()<>1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Can not locate Note with ID of :' + brand_activityid));
                    return null;
                }
                list<Note_Attachment_Connector__c> NAClist = [select brands__c from Note_Attachment_Connector__c where id=:notelist[0].parentid limit 1];
                if (NAClist.size()<>1)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Can not locate Note/Attachment connector with ID of :' + notelist[0].parentid ));
                    return null;
                }
                NAClist[0].brands__c = selectedbrandsstr;
                update NAClist; 
            }

            getActivitywList();
            Display_Table = true; 
            Display_UpdateBrands = false;


        }

        return null;
    }

    // *************************************************
    // ************* Add Attachment ********************
    // *************************************************
    /* No Longer Used 
    public pageReference NewAttachment_Go()
    {
        if (display_table==true) // nothing to do but show the attachment 
        {
            NewAttachment = new attachment();
            display_table=false;
            Display_Attachment = true;
            return null;
        }
        // if table not visible then we must be doing some further action
        string ActivityAction = ApexPages.currentPage().getParameters().get('ActivityAction');
        if(ActivityAction=='Cancel')
        {
            NewAttachment = new attachment();
            display_table=true;
            Display_Attachment = false;
            return null;
        }
        if(ActivityAction=='Save')
        {
            if (selectedBrands==null || selectedbrands.size()==0 )
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'You must select a brand for this attachment.'));
                return null;
            } 
            if (NewAttachment.name==null || NewAttachment.name=='') 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'You must select a file to attach.'));
                return null; // no file selected
            }
            // all looks good so go ahead and save things now
            Note_Attachment_Connector__c NA = new Note_Attachment_Connector__c();
            if (SObjectType=='Account') NA.Account__C = sObjectID;
            if (SObjectType=='Contact') NA.Contact__C = SobjectID;
            string SelectedBrandsstr = '';
            for(string s:selectedbrands) SelectedBrandsstr = selectedbrandsstr + s+';'; // glue all brands together
            NA.Brands__c = SelectedBrandsstr;
            NA.Type__C = 'Attachment'; 
            insert NA;
            NEwAttachment.parentID = NA.id;
            insert NewAttachment;
            NewAttachment.body = null; // clear the memory in case it was a large attachment
            display_table=true;
            display_attachment=false;
            list<activitywrapper> ll =  getActivitywList(); 
        }
        
        return null;
    }

    // *************************************************
    // ************* Add Attachment ********************
    // *************************************************
    public pageReference NewNote_Go()
    {
        if (display_table==true) // nothing to do but show the attachment 
        {
            NewNote = new Note();
            display_table=false;
            Display_Note = true;
            return null;
        }
        // if table not visible then we must be doing some further action
        string ActivityAction = ApexPages.currentPage().getParameters().get('ActivityAction');
        if(ActivityAction=='Cancel')
        {
            Newnote = new Note();
            display_table=true;
            Display_note = false;
            return null;
        }
        if(ActivityAction=='Save')
        {
            if (selectedBrands==null || selectedbrands.size()==0 )
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'You must select a brand for this note.'));
                return null;
            } 
            if (NewNote.Title==null || NewNote.title=='') 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'You must enter a note Title.'));
                return null; // no file selected
            }
            // all looks good so go ahead and save things now
            Note_Attachment_Connector__c NA = new Note_Attachment_Connector__c();
            if (SObjectType=='Account') NA.Account__C = sObjectID;
            if (SObjectType=='Contact') NA.Contact__C = SobjectID;
            string SelectedBrandsstr = '';
            for(string s:selectedbrands) SelectedBrandsstr = selectedbrandsstr + s+';'; // glue all brands together
            NA.Brands__c = SelectedBrandsstr;
            NA.Type__C = 'Note';
            insert NA;
            NewNote.parentID = NA.id;
            insert NewNote;
            display_table=true;
            display_Note=false;
            list<activitywrapper> ll =  getActivitywList(); 
        }
        
        return null;
    }
    */

    // ******************************************
    // ************ Table Actions ***************
    // ******************************************

    public pageReference s_Delete()
    {
        string ActionID = ApexPages.currentPage().getParameters().get('ActivityAction'); 
        string Objecttype = ApexPages.currentPage().getParameters().get('ObjectType');
        string SourceScreen = ApexPages.currentPage().getParameters().get('SourceScreen');

        if (ActionID!= null && ActionID != '')
        {
            if (ObjectType!=null || ObjectType!='')
            {
                if(ObjectType=='Task')
                {
                    list<task> tasklist = [select id from task where id=:ActionID limit 1];
                    system.debug('tl=' + tasklist.size());
                    if (tasklist.size()==1) delete tasklist;
                }
                if(ObjectType=='Event')
                {
                    list<event> eventlist = [select id from event where id=:ActionID limit 1];
                    if (eventlist.size()==1) delete eventlist;
                }
                if(ObjectType=='Attachment')
                {
                    list<attachment> at = [select parentid from attachment where id=:actionid limit 1];
                    if (at.size()==1)
                    {
                        list<Note_Attachment_Connector__c> at2 = [select id from Note_Attachment_Connector__c where id=:at[0].parentid limit 1];
                        if (at2.size()>0) 
                        {
                            delete at;
                            delete at2;
                        }
                    }
                }
                if(ObjectType=='Note')
                {
                    list<note> at = [select parentid from note where id=:actionid limit 1];
                    if (at.size()==1)
                    {
                        list<Note_Attachment_Connector__c> at2 = [select id from Note_Attachment_Connector__c where id=:at[0].parentid limit 1];
                        if (at2.size()>0) 
                        {
                            delete at;
                            delete at2;
                        }
                    }
                }
                if (SourceScreen != 'More') list<activitywrapper> ll =  getActivitywList(); // refresh screen 
                if (SourceScreen =='More') s_RefreshList();
            }
        } 
        return null; 
    }


    // ********************************************************************************
    // ********************** Class of Combined Activities And Task And Events ********
    // ********************************************************************************
    public class Activity 
    {
        public string Subject{get;set;}
        public id ActivityID{get;set;}
        public boolean IsTask{get;set;}
        public date ActivityDate{get;set;}
        public datetime ActivityDateTime{get;set;}
        public id OWnerID{get;set;}
        public string OwnerName{get;set;}
        public string ActType{get;set;}
        public string Status{get;set;}
        public string CallType{get;set;}
        public datetime createdDate{get;set;}
        public string brands{get;set;}
        public string ObjectType{get;set;}
        public string Body{get;set;}
    }

    global class ActivityWrapper implements comparable // just used so we can sort the activities 
    {
        public Activity Act1{get;set;}
        public String CreatedDateLocale{get;set;}   //Date in the User Locale format
        public String DueDateLocale{get;set;}       //Date in the User Locale format

        // constructor 
        public activitywrapper(Activity Act)
        {
            CreatedDateLocale = '';
            DueDateLocale = '';
            Act1 = Act;
            if(Act1 != null){
                if(Act1.createddate != null){
                    Date CreatedDate = date.newinstance(Act1.createddate.year(), Act1.createddate.month(), Act1.createddate.day());
                    CreatedDateLocale = CreatedDate.format();
                }
                if(Act1.activitydatetime != null){
                    DueDateLocale = Act1.activitydatetime.format();
                }
                else if(Act1.activitydate != null){
                    DueDateLocale = Act1.activitydate.format(); 
                }
                
            }
        }

        global Integer compareTo(Object compareTo) 
        {
            Activitywrapper Act2 = (Activitywrapper)CompareTo;
            if (Act1.ActivityDate == Act2.act1.ActivityDate) return 0;
            if (Act1.ActivityDate > Act2.act1.ActivityDate) return -1;
            return 1;
        }
    }


    // *****************************************************************************************************************************************************************************
    // *************************************************************************** Get More Records ********************************************************************************
    // *****************************************************************************************************************************************************************************
    public pageReference s_GetMoreRecords()
    {
        ParentRecordID = ApexPages.currentPage().getParameters().get('ID');
        SObjectType = ApexPages.currentPage().getParameters().get('Type');
        SourceObjectType = ApexPages.currentPage().getParameters().get('SourceObjectType');
        string TaskType2 = '';

        if(SourceObjectType == 'Account'){
             TaskType = 'accountid'; // used in the soql to find tasks
        }
        else if(SourceObjectType == 'Contact' || SourceObjectType == 'Lead'){
            TaskType='whoid'; // used in the SOQL to find tasks
        }
        else{
            TaskType='whatID'; // used in the SOQL to find tasks
        }

        //get the lookup name for the object
        Branded_Notes__c BrandedSettings = Branded_Notes__c.getValues(SourceObjectType);
        if(BrandedSettings == null) BrandedSettings = new Branded_Notes__c();
        if(BrandedSettings.Attachment_Lookup__c != null) TaskType2 = BrandedSettings.Attachment_Lookup__c;

        string queryName = '';
        //Get the Name of the Object
        try{
            queryName = 'SELECT ID, Name FROM ' + SourceObjectType + ' WHERE id = \'' + parentrecordid + '\' LIMIT 1';
            list<SObject> sobj = database.query(queryName);
            if(sobj.size() == 1){
                SourceRecordName = (string) sobj[0].get('Name');
            }
        }
        catch(exception e){
            system.debug(LOGGINGLEVEL.ERROR, 'Error querying Record Name = '+ e.getMessage());
            SourceRecordName = '';
        }

    
        try{
            PosnCounter = 0;
            if (SobjectType=='Task')
            {  
                
                string querystr = 'select  id from task where ' + tasktype +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + '))' ; 
                moretasks = database.query(querystr);
                BigCounter = moreTasks.size();
            } 
            if (SobjectType=='Event')
            {  
                
                string querystr = 'select  id from event where ' + tasktype +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + '))' ; 
                moreevents = database.query(querystr);
                BigCounter = moreevents.size();
            } 
            if (SobjectType=='Note')
            {
                string querystr = 'select  id,account__c,brands__c,contact__c,ownerid,owner.name,createddate,lastmodifiedDate from Note_Attachment_Connector__c where type__c = \'Note\'  and ' + tasktype2 +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + '))' ; 
                list<Note_Attachment_Connector__c> moreConnect = database.query(querystr);
                BigCounter = MoreConnect.size();
            }
            if (SobjectType=='Attachment')
            {
                string querystr = 'select  id,account__c,brands__c,contact__c,ownerid,owner.name,createddate,lastmodifiedDate from Note_Attachment_Connector__c where type__c = \'Attachment\'  and ' + tasktype2 +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + '))' ; 
                list<Note_Attachment_Connector__c> moreConnect = database.query(querystr);
                BigCounter = MoreConnect.size();
            }    
        }
        catch(queryException e){
            system.debug(LOGGINGLEVEL.ERROR, 'Error querying Records = '+ e.getMessage());
        }
        

        if (PosnCounter+MorePageSize>=BigCounter) DisableNext=true;
        s_RefreshList();        

        return null;
    }
    // *******************************************
    // ***** Refresh Current Page Of Records *****
    // *******************************************
    private void s_RefreshList()
    {
        string TaskType2 = '';
        //get the lookup name for the object
        Branded_Notes__c BrandedSettings = Branded_Notes__c.getValues(SourceObjectType);
        if(BrandedSettings == null) BrandedSettings = new Branded_Notes__c();
        if(BrandedSettings.Attachment_Lookup__c != null) TaskType2 = BrandedSettings.Attachment_Lookup__c;

        /*if (SourceObjectType=='Account') TaskType2 = 'Account__c';
        if (SourceObjectType=='Contact') TaskType2 = 'Contact__c';
        */
        
        ParentRecordID = ApexPages.currentPage().getParameters().get('ID');
        
        if (Sortby==null || sortBy=='') SortBy = 'activitydate';
        if (SortSeq==null || SortSeq=='') SortSeq = 'Desc';

        if (sobjectType=='Task')
        {       

            string querystr = 'select id,priority,brands__c,createddate,calltype,subject,ActivityDate,isclosed,status,owner.name,type,ownerID from task where ' + tasktype +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by ' + SortBy + ' ' + SortSeq + '  limit '+ MorePageSize+ ' offset ' + posnCounter; 
            moretasks = database.query(querystr);
        } 
        if (SobjectType=='Event')
        {       
            string querystr = 'select id,brands__c,createddate,subject,ActivityDate,owner.name,type,ownerID from event where ' + tasktype +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by ' + SortBy + ' ' + Sortseq + '  limit '+ MorePageSize+ ' offset ' + posnCounter; 
            moreevents = database.query(querystr);
        } 
        if (sobjectType=='Note') 
        {
            string querystr = 'select  id,account__c,brands__c,contact__c,ownerid,owner.name,createddate,lastmodifiedDate from Note_Attachment_Connector__c where type__c = \'Note\'  and ' + tasktype2 +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by createdDate desc limit '+ MorePageSize+ ' offset ' + posnCounter ; 
            list<Note_Attachment_Connector__c> moreConnect = database.query(querystr);
            s_RefreshRelatedCombo('Note',moreconnect);
        }
        if (sobjectType=='Attachment') 
        {
            string querystr = 'select  id,account__c,brands__c,contact__c,ownerid,owner.name,createddate,lastmodifiedDate from Note_Attachment_Connector__c where type__c = \'Attachment\'  and ' + tasktype2 +  ' = \'' + ParentRecordID + '\' and (brands__c=null or brands__c includes(' + userbrandliststr + ')) order by createdDate desc limit '+ MorePageSize+ ' offset ' + posnCounter ; 
            system.debug(LOGGINGLEVEL.error, '-----> Query = '+querystr);

            list<Note_Attachment_Connector__c> moreConnect = database.query(querystr);
            s_RefreshRelatedCombo('Attachment',moreconnect);
        }


    }

    // ******************************************************************************
    // *************** Refresh Combo Screen For Notes / Attachments *****************
    // ******************************************************************************
    private void s_RefreshRelatedCombo(string TypeofRefresh,list<Note_Attachment_Connector__c> ConnectorList)
    {
        MoreNoteAttachments = new list<AttachmentCombo>(); // clear out old list
        map<id,note> NotesubIDmap = new map<id,note>();
        map<id,attachment> AttachmentsubIDmap = new map<id,Attachment>();
        
        // get all related ID's from this connector list
        list<id> idlist = new list<id>();
        for(note_attachment_connector__c nac:connectorlist) idlist.add(nac.id);
        // get all notes or attachments that match the connector list and put them into a map for furture lookup
        if (TypeofRefresh=='Note')
        {
            list<note> notelist = [select title,body,id,parentid from note where parentid in:idlist];
            for(note n:notelist) NoteSubIDMap.put(n.parentid,n);
        }
        if (TypeofRefresh=='Attachment')
        {
            list<Attachment> Atlist = [select id,parentid,name from Attachment where parentid in:idlist];
            for(attachment a:atlist) AttachmentSubIDMap.put(a.parentid,a);
        }
    
        for(note_attachment_connector__c nac:connectorlist)
        {
            AttachmentCombo ac = new AttachmentCombo();
            ac.ownerID = nac.ownerID;
            ac.ownername = nac.owner.name;
            ac.createddate = nac.createddate;
            ac.LastMod = nac.lastmodifiedDate;
            ac.brands = nac.brands__c;
            if (typeofrefresh=='Note')
            {
                if (notesubidmap.containskey(nac.id))
                {
                    ac.subject = notesubidmap.get(nac.id).title;
                    ac.relatedid = notesubidmap.get(nac.id).id;
                }
            }
            if (typeofrefresh=='Attachment')
            {
                if (attachmentsubidmap.containskey(nac.id))
                {
                    ac.subject = attachmentsubidmap.get(nac.id).Name;
                    ac.relatedid = attachmentsubidmap.get(nac.id).id;
                }
            }
            MoreNoteAttachments.add(ac); 
        }
    }
    // ***********************************************
    // ******** Next & Previous Navigation ***********
    // ***********************************************
    public pageReference Previous()
    {
        PosnCounter = PosnCounter - MorePageSize;
        if (PosnCounter<MorePageSize) disableprevious = true;
        if (PosnCounter+MorePageSize<BigCounter) DisableNext=false;
        s_RefreshList();
        return null;
    }
    public pageReference Next()
    {
        PosnCounter = PosnCounter + MorePageSize;
        if (PosnCounter>=MorePageSize) disableprevious = false;
        if (PosnCounter+MorePageSize>=BigCounter) DisableNext=true;
        s_RefreshList();
        return null;
    }
    public pageReference Beginning()
    {
        PosnCounter=0;
        s_RefreshList();
        disableprevious = true;
        if (PosnCounter+MorePageSize<BigCounter) DisableNext=false;
        return null;
    }
    public pageReference End()
    {
        Posncounter = BigCounter - math.mod(BigCounter, MorePageSize);
        if (PosnCounter==BigCounter) PosnCounter = PosnCounter - MorePageSize;
        DisableNext = true;
        if (PosnCounter>=MorePageSize) disableprevious = false;
        s_RefreshList();
        return null;
    }
    // *************************************
    // ****** Change Sort Sequence *********
    // *************************************
    public pageReference ChangeSort()
    {
        string TempSortBy = ApexPages.currentPage().getParameters().get('SortBy');
        if (SortBy==TempSortBy)
        {
            if (SortSeq=='Desc')
            {
                SortSeq='Asc';
            }
            else
            {
                SortSeq='Desc';
            }
        }
        else
        {
            Sortby = TempSortBy;
        }
        Posncounter = 0; // if we change the sequence of sorting then we need to go back to P1;
        DisablePrevious = true;
        s_RefreshList();
        return null;
    }

    // *****************************************************************
    // ******** Return A SOQL Valid Date String From A Date Time *******
    // *****************************************************************
    public static string GetSOQLDateString(datetime InpDateTime)
    {
        //changed ot use GMT as SOQl queyr uses GMT
        string RetString = '';
        string TempString;
        RetString = RetString + InpDateTime.yearGmt();
        TempString = string.valueof(InpDateTime.monthGmt());
        if (TempString.length()==1) TempString = '0' + TempString;
        RetString = RetString + '-' + TempString;
        TempString = string.valueof(InpDateTime.dayGmt());
        if (TempString.length()==1) TempString = '0' + TempString;
        RetString = RetString + '-' + TempString  + 'T'; 
        Tempstring = string.valueof(InpDateTime.hourGmt());
        if (TempString.length()==1) TempString = '0' + TempString;
        RetString = RetString + TempString +':';
        Tempstring = string.valueof(InpDateTime.minuteGmt());
        if (TempString.length()==1) TempString = '0' + TempString;
        RetString = RetString + Tempstring +':';
        Tempstring = string.valueof(InpDateTime.secondGmt());
        if (TempString.length()==1) TempString = '0' + TempString;
        RetString = RetString + tempstring + 'Z';            
        return RetString;
    }

    public static string GetSOQLDateString(date InpDate)
    {
        string RetString = '';
        string TempString;
        RetString = RetString + InpDate.year();
        TempString = string.valueof(InpDate.month());
        if (TempString.length()==1) TempString = '0' + TempString;
        RetString = RetString + '-' + TempString;
        TempString = string.valueof(InpDate.day());
        if (TempString.length()==1) TempString = '0' + TempString;
        RetString = RetString + '-' + TempString ;                 
        return RetString;
    }

    // *********************************************************************************************************************
    // ********** Notes And Attachments Combined With The Notes And Attachments Connector For Combined Display *************
    // *********************************************************************************************************************
    public class AttachmentCombo
    {
        public string subject{get;set;}
        public string Body{get;set;}
        public datetime lastMod{get;set;}
        public datetime createddate{get;set;}
        public id lastModByID{get;set;}
        public string LastModBy{get;set;}
        public id relatedID{get;set;}
        public id ownerID{get;set;}
        public string ownername{get;set;}
        public string Brands{get;set;}
    }

}