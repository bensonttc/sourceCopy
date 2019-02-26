trigger myOppforQuest on Questionnaire__c (after update) {

    List<Opportunity> oppList = new List<Opportunity>();
    
    for(Questionnaire__c co : System.Trigger.new) {
    
    Questionnaire__c oldQ = Trigger.oldMap.get(co.ID);
    
   if(((co.Booking__c != NULL) || (co.Booking_Ref__c != ' ')) &&
   (co.Customer__c == oldQ.Customer__c) &&
   (co.Selling_Company__c != NULL) &&
   (co.Customer__c != NULL) &&
   (co.Departure_Date__c > System.today() - 180) &&
   (co.Opportunity_ID__c == NULL) &&
   ((co.Comms__c == 'Y') || (co.Comms_Email__c == 'Y')) &&
   (((co.Travel_Again_NPS__c == NULL) &&
   ((co.Recommend_NPS__c == ('8')) || (co.Recommend_NPS__c == ('9')) || (co.Recommend_NPS__c == ('10'))))||    
   ((co.Travel_Again_NPS__c == ('8')) || (co.Travel_Again_NPS__c == ('9')) || (co.Travel_Again_NPS__c == ('10')) || (co.Recommend_NPS__c == ('8')) || (co.Recommend_NPS__c == ('9')) || (co.Recommend_NPS__c == ('10'))))) {
       
        oppList.add(new Opportunity
        (OwnerID = co.ownerID, 
        Name = co.First_Name__c + ' ' + co.Last_Name__c + ' - ' + co.name, 
        AccountId = co.Customer__c,  
        CloseDate = System.today() + 30 , 
        StageName = 'Prospecting', 
        Type = 'Existing Business', 
        I_am_a_past_passenger__c = TRUE, 
        CTQ_Name__C = co.ID,
        RecordtypeID = '01220000000VCat',
        CTQ_Booking_Link__c = co.booking__c,
        business_unit__c = co.selling_company__c,
        brand__c = co.Company__c,
        Travel_Again__c = co.Travel_Again__c,
        Recommend_NPS__c = co.Recommend_NPS__c, 
        Travel_Again_NPS__c = co.Travel_Again_NPS__c,
        Next_Plan__c = co.Next_Plan__c,
        LeadSource = 'CTQ',
        Request_Type__c = 'CTQ'));      
           
    }
    
    } //Close FOR loop
    
    insert oppList;
    
    }