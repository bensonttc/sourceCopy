global class UpdateLastTTactivity {

    @InvocableMethod(label='Update Last TT Activity')
    public static void UpdateLastTTActivityMethod(list<String> accountId_set) {


        
               
        List<Account> account_recent_task = [
        SELECT Id, 
        (
            SELECT Id, ActivityDate
            FROM ActivityHistories 
            WHERE Brands__c includes ('Trafalgar') AND (NOT Subject  LIKE 'Mass Email:%')
            ORDER BY ActivityDate DESC 
            LIMIT 1
        ) 
        FROM Account 
        WHERE Id in :accountId_set
        ];


        
        List<Account> accts = new List<Account>();
        
        if(!account_recent_task.isEmpty()){

            
            for(Account a : account_recent_task){
         
                
                if( !a.ActivityHistories.isEmpty() ){

                    
                    Date LAST = a.ActivityHistories[0].ActivityDate;
                    System.debug(LAST);
                    a.TT_Last_Activity__c = LAST;
                    accts.add(a);  
                                         
           
                }
                
            }
            
        }
     
        update accts;


    } //end of method

} //end of class