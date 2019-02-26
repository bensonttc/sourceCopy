//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_SuppliersListPDFController_Test
// For Apex Class: TOPS_SuppliersListPDFController
// Description: Used to generate Seppliers list pdf
//
// 31st Jan 2017    Ravi Jain      Modified (Story# S-461046) - Please see the story description for more details.
// 15th May 2018    Calvin Goodenough Cloned and modified for Book Out Visualforce page
//

@isTest(seeAllData=false)
public class TOPS_BookOutController_Test {
    public static Tour_Instance__c tourInstance;
    private static final Id ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Supplier - Hotel').RecordTypeId;
    static testMethod void TOPS_BookOutController_Test() { 
        
        tourInstance = new Tour_Instance__c();
        tourInstance.Operating_Product_Code__c = 'VBS';
        tourInstance.Departure_Code__c  = 'd';
        tourInstance.CurrencyIsoCode = 'EUR';
        insert tourInstance;
        
       PageReference passPage = Page.TOPS_BookOut;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('relatedObjectId',tourInstance.id);
        
         // Inserting Test Old Supplier Hotel Account.
    Account theOldSupplier = new Account(
      Name = 'Executive Style Hotel Rome',
      RecordTypeId = ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID
    );
    insert theOldSupplier;
    
            // Inserting Test New Supplier Hotel Account.
    Account theNewSupplier = new Account(
      Name = 'Black Hotel Rome',
      RecordTypeId = ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID
    );
    insert theNewSupplier;

        
       // Inserting Test Tour Instance Itineraries.
    Tour_Instance_Itinerary__c theTourInstanceItinerary = null;
    List<Tour_Instance_Itinerary__c> theTestTourInstanceItineraries = new List<Tour_Instance_Itinerary__c>();
    for(Integer index = 0;index <= 2;index++) {
      theTourInstanceItinerary = new Tour_Instance_Itinerary__c(
        Tour_Instance__c = tourInstance.Id,
        Supplier__c = theOldSupplier.Id,
        City__c = 'Rome',
        Arrival_Time__c = '07:00',
        Dinner_Time__c = '20:00',
        Morning_Call_Time__c = '08:00',
        Bags_Time__c = '07:30',
        Depart_Time__c = '10:00',
        Breakfast_time__c = '08:00',
        Day_Number__c = index + 1,
        Component_Type__c = 'Hotel'
      );

      theTestTourInstanceItineraries.add(theTourInstanceItinerary);
    }
    insert theTestTourInstanceItineraries; 
        
       ApexPages.currentPage().getParameters().put('relatedObjectId', tourInstance.Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(tourInstance ); 
       TOPS_BookOutController tc = new TOPS_BookOutController();  
       tc.newSupplier = 'Rome';
       tc.oldSupplier =  theOldSupplier.ID; 
       tc.searchBox(); 
       tc.foundSupplier =  theNewSupplier.ID; 
       tc.changeTIIs();   
    }
}