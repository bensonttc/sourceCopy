global class Empty_Recycling_Bin implements Database.Batchable<sObject>   {
    private string query;
    global Empty_Recycling_Bin(string qu){
        query = qu;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    } 


    //Execute method for the batchable interface
    global void execute(Database.BatchableContext BC, list<sObject> scope){      
        DataBase.emptyRecycleBin(scope); 
    }

    global void finish(Database.BatchableContext BC){}
}