global class TourInstanceChatterGroupCreatorBatch implements Database.Batchable<sObject>{
   String whereCondition;
   
   global TourInstanceChatterGroupCreatorBatch(String tourInstanceWhereCondition){
       whereCondition = tourInstanceWhereCondition;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'SELECT Id, Instance_Code__c, Start_Date__c, End_Date__c, ' +
        'Name, Chatter_Group_Id__c, Travel_Director__c ' +
        'FROM Tour_Instance__c ' +
        'WHERE Chatter_Group_Id__c = null ';
      if (whereCondition != null && whereCondition != ''){
          query += ' AND (' + whereCondition + ')';
      }
      
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> tourInstances){
       List<Tour_Instance__c> instanceToExecute = new List<Tour_Instance__c>();
       for (sObject tourInstance: tourInstances){
           instanceToExecute.add((Tour_Instance__c) tourInstance);
       }
       ChatterGroupHandler.createChatterGroupsForTourInstances(instanceToExecute, true);
   }

   global void finish(Database.BatchableContext BC){
   }
   
   global static void run(String whereCondition){
       TourInstanceChatterGroupCreatorBatch batchObject = new TourInstanceChatterGroupCreatorBatch(whereCondition);
       Database.executeBatch(batchObject);
   }
   
   global static void run(){
       run(null);
   }
}