global class UpdateNextUWactivity {

   @InvocableMethod(label='Update Next UW Activity')
    public static void UpdateNextUWActivityMethod(list<String> accountId_set) {

        System.debug('Update Next UW Activity');
        
        List<Account> account_soon_task = [
        SELECT Id, 
        (
            SELECT Id, ActivityDate
            FROM OpenActivities 
            WHERE Brands__c includes ('Uniworld')
            ORDER BY ActivityDate ASC 
            LIMIT 1
        ) 
        FROM Account 
        WHERE Id in :accountId_set
        ];

        List<Account> accts = new List<Account>();
        
        if(!account_soon_task.isEmpty()){
            for(Account a : account_soon_task){
            
                if( !a.OpenActivities.isEmpty() ){  //The Account has an Open Activity
                    Date NEXT = a.OpenActivities[0].ActivityDate; 
                    a.UW_Next_Activity__c = NEXT;
                    accts.add(a);  
                                         
                }else{
                    a.UW_Next_Activity__c = null;
                    accts.add(a);  
                } 
                
                
            }
        }
     
        update accts;
    
    } //end of method
} //end of class