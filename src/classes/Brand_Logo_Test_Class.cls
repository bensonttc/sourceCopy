@istest (seeAllData=false)

public with sharing class Brand_Logo_Test_Class  
{
   static testMethod void methodOne(){
        BrandLogos__c BL = new BrandLogos__c();
        BL.name = 'Default';
        BL.Static_Resource_Name__c = 'TravCorp_Logo';
        BL.Width__c = 100;
        BL.Height__c = 100;
        insert BL;
        
        list<user> u = [select id from User where userRoleID != null and isActive = true limit 1];
        System.runAs(u[0]){
            Brand_logo_Controller BrandCon = new Brand_logo_Controller();
        }
        

   }
    
}