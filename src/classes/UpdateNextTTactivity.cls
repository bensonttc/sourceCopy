global class UpdateNextTTactivity {

   @InvocableMethod(label='Update Next TT Activity')
    public static void UpdateNextTTActivityMethod(list<String> accountId_set) {

        System.debug('Update Next TT Activity');
        
        List<Account> account_soon_task = [
        SELECT Id, 
        (
            SELECT Id, ActivityDate
            FROM OpenActivities 
            WHERE Brands__c includes ('Trafalgar')
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
                    a.TT_Next_Activity__c = NEXT;
                    accts.add(a);  
                                         
                }else{
                    a.TT_Next_Activity__c = null;
                    accts.add(a);  
                } 
                
                
            }
        }
     
        update accts;
    
    } //end of method
} //end of class