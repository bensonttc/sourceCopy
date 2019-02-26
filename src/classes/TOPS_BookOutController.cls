//
// (c) 2016 Appirio, Inc.
//
// Class Name: TOPS_BookOutController
// Description: Used in get list of passenger and other information the get PDF data for passengers
//
// 27th January 2016   Kirti Agarwal  Original (Task # T-465523)
//
// 17 Feb 2016, Maksud Ali Modified (Story# S-455965) - Please see the story description for more details.
// 11 May 2018 Calvin Goodenough Modified to make suppliers list

public without sharing class TOPS_BookOutController{

    public String fontSize{get; set;}

    public Tour_Instance__c tourRecord{get; set;}
    public String blankSupplierCSS {get; set;}
    public List<selectOption> supplierOptions {get; set;}
    public List<selectOption> supplierSearch {get; set;}
    public String oldSupplier {get; set;}
    public String newSupplier {get; set;}
     public String foundSupplier {get; set;}
    public List<Tour_Instance_Itinerary__c> blankSupplier {get; set;}
    public List<Tour_Instance_Itinerary__c> supplierList {get; set;} 
     public List<Tour_Instance_Itinerary__c> supsToUpdate {get; set;} 

    
    String tourInstance;

    public static final String roomType = 'RoomingList';
    public static final String itinType = 'Itinerary';

    //constructor
    public TOPS_BookOutController() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        Id relatedObjectId = (Id)parameters.get('relatedObjectId');
        tourInstance = parameters.get('relatedObjectId');       
        fontSize ='14px';
        tourRecord = [select ID, Instance_Code__c, Operating_Product_Code__c from tour_instance__C where ID = :tourInstance LIMIT 1];
        getSuppliers();
    }
    
    public void getSuppliers(){
   //     List<Tour_Instance_Itinerary__c> tempList = new List<Tour_Instance_Itinerary__c>();
        supplierOptions = new List<SelectOption>();   
        String query = 'SELECT Component_Type__c, Supplier__r.Name,Supplier__r.ID, City__c, module_code__C  '
                    + 'FROM Tour_Instance_Itinerary__c '
                    + 'WHERE Component_Type__c != :roomType '
                    + 'AND Component_Type__c != :itinType '
                    + 'AND Tour_Instance__c = :tourInstance ' 
                    + 'AND Supplier__c != null '
                    + 'ORDER BY Supplier__r.Name';
                                               
        for(Tour_Instance_Itinerary__c supp: Database.query(query)) {
             Boolean found = false;
             for(Integer i=0; i < supplierOptions.size(); i++){
                if(supp.Supplier__r.Name == supplierOptions[i].getlabel()){
                   found = true;
                   break;
                }
             }
             if (!found){
              supplierOptions.add(new SelectOption(supp.Supplier__r.ID, supp.Supplier__r.Name));
             } 
        }
        blankSupplierCSS = 'pRowEven,pRowOdd';
    }
  
    public void searchBox(){
        supplierSearch = new List<SelectOption>();   
        string tempSupplier = '%' + newSupplier + '%'; 
        String query = 'SELECT ID, Name  '
                    + 'FROM Account '
                    + 'WHERE name like :tempSupplier '
                    + 'ORDER BY Name';
                                               
        for(Account supp: Database.query(query)) {     
              supplierSearch.add(new SelectOption(supp.ID, supp.Name));
        } 
        supplierList = new List<Tour_Instance_Itinerary__c>();        
        query = 'SELECT id, Component_Type__c, Supplier__r.Name,Supplier__r.ID, City__c, start_date_of_service__c, day_number__c, module_code__C  '
                    + 'FROM Tour_Instance_Itinerary__c '
                    + 'WHERE Tour_Instance__c = :tourInstance ' 
                    + 'AND Supplier__c = :oldSupplier '
                    + 'ORDER BY day_number__c';
                                               
        for(Tour_Instance_Itinerary__c supp: Database.query(query)) {           
             supplierList.add(supp); 
        }
   } 
   
   public void changeTIIs(){
      List<Tour_Instance_Itinerary__c> tempSups = new List<Tour_Instance_Itinerary__c>();        
      tempSups= [SELECT id, Component_Type__c, Supplier__r.Name,Supplier__r.ID, City__c, start_date_of_service__c, day_number__c, module_code__C FROM Tour_Instance_Itinerary__c WHERE Tour_Instance__c = :tourInstance AND Supplier__c = :oldSupplier AND Archive__c = false order by day_number__C];
      if (tempSups.isEMpty()) return;
      for (Tour_Instance_Itinerary__C myTII : tempSups) myTII.Supplier__c = foundSupplier;
            update tempSups;
            supsToUpdate = [SELECT id, Component_Type__c, Supplier__r.Name,Supplier__r.ID, City__c, start_date_of_service__c, day_number__c, module_code__C FROM Tour_Instance_Itinerary__c WHERE Tour_Instance__c = :tourInstance AND Supplier__c = :foundSupplier AND Archive__c = false order by day_number__C];
   } 
}