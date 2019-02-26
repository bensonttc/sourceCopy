//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_SuppliersListPDFController_Test
// For Apex Class: TOPS_SuppliersListPDFController
// Description: Used to generate Seppliers list pdf
//
// 31st Jan 2017    Ravi Jain      Modified (Story# S-461046) - Please see the story description for more details.
// 15th May 2018    Calvin Goodenough Cloned and modified for Suppliers list PDF
//

@isTest(seeAllData=false)
public class TOPS_SuppliersListPDFController_Test {
    public static Tour_Instance__c tourInstance;
    private static final Id ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Supplier - Hotel').RecordTypeId;
    static testMethod void TOPS_SuppliersListPDFController_Test() { 
        
        tourInstance = new Tour_Instance__c();
        tourInstance.Operating_Product_Code__c = 'VBS';
        tourInstance.Departure_Code__c  = 'd';
        tourInstance.CurrencyIsoCode = 'EUR';
        insert tourInstance;
      
        //initTourOptional(tourInstance);
        
       PageReference passPage = Page.TOPS_SuppliersListPDF;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('relatedObjectId',tourInstance.id);
        
         // Inserting Test Supplier Hotel Account.
    Account theSupplier = new Account(
      Name = 'Executive Style Hotel Rome',
      RecordTypeId = ACCOUNT_SUPPLIER_HOTEL_RECORD_TYPE_ID
    );
    insert theSupplier;
        
       // Inserting Test Tour Instance Itineraries.
    Tour_Instance_Itinerary__c theTourInstanceItinerary = null;
    List<Tour_Instance_Itinerary__c> theTestTourInstanceItineraries = new List<Tour_Instance_Itinerary__c>();
    for(Integer index = 0;index <= 2;index++) {
      theTourInstanceItinerary = new Tour_Instance_Itinerary__c(
        Tour_Instance__c = tourInstance.Id,
        Supplier__c = theSupplier.Id,
        City__c = 'Rome',
        Arrival_Time__c = '07:00',
        Dinner_Time__c = '20:00',
        Morning_Call_Time__c = '08:00',
        Bags_Time__c = '07:30',
        Depart_Time__c = '10:00',
        Breakfast_time__c = '08:00',
        Day_Number__c = index + 1,
        Component_Type__c = 'Itinerary'
      );

      theTestTourInstanceItineraries.add(theTourInstanceItinerary);
    }
    insert theTestTourInstanceItineraries; 
        
       ApexPages.currentPage().getParameters().put('relatedObjectId', theTestTourInstanceItineraries.get(0).Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(tourInstance); 
       TOPS_SuppliersListPDFController tc = new TOPS_SuppliersListPDFController(); 
       getPassengers();
       
       ApexPages.currentPage().getParameters().put('relatedObjectId', tourInstance.Id);
       ApexPages.StandardController sc1 = new ApexPages.StandardController(tourInstance); 
       TOPS_SuppliersListPDFController tc1 = new TOPS_SuppliersListPDFController(); 
       getPassengers();
        
    }
    
    static void getPassengers() {
        List<Passenger__c> passengerList = new List<Passenger__c>();
        List<Passenger__c> tourDriverList = new List<Passenger__c>();
        List<Passenger__c> tourDirectorList = new List<Passenger__c>();
        //String travelDirectorName = ''; 
        
        Tour_Instance__c tour = [Select id from Tour_Instance__c where id = :tourInstance.Id];
        for(integer i=1;i<=70;i++) {
            
            Passenger__c objPassenger = new Passenger__c();
            objPassenger.Tour_Instance__c = tour.Id;
            if(i == 1) {
                Passenger__c objPassenger1 = new Passenger__c();
                objPassenger1.Tour_Instance__c = tour.Id;
                objPassenger1.Passenger_Status__c = 'Confirmed';
                objPassenger1.Preferred_Name__c = '';
                objPassenger1.Family_Name__c = 'Jonny';
                objPassenger1.First_Name__c = 'Depp';
                objPassenger1.Passenger_Class__c = 'Tour Director';
                tourDirectorList.add(objPassenger1);
            }
            
            if(i == 2) {
                Passenger__c objPassenger2 = new Passenger__c();
                objPassenger2.Passenger_Status__c = 'Driver';
                objPassenger2.Name = 'Tom Cruise';
                tourDriverList.add(objPassenger2);
            }
            
             if(i == 3) {
                Passenger__c objPassenger3 = new Passenger__c();
                 objPassenger3.Tour_Instance__c = tour.Id;
                objPassenger3.Passenger_Status__c = 'Confirmed';
                objPassenger3.Preferred_Name__c = '';
                objPassenger3.Family_Name__c = 'Jonny';
                objPassenger3.First_Name__c = 'Depp';
                objPassenger3.Passenger_Class__c = 'Driver';
                tourDriverList.add(objPassenger3);
            }
            else {
                objPassenger.Preferred_Name__c = 'Test';
                objPassenger.Family_Name__c = 'Family';
                objPassenger.Name = 'Temp';
                objPassenger.Passenger_Status__c = 'Confirmed';
                objPassenger.Passenger_Class__c = 'Passenger';
                passengerList.add(objPassenger);
            }
        }
        
        insert tourDirectorList;
        insert tourDriverList;
        insert passengerList;
    }
    
    static void initTourOptional(Tour_Instance__c tour) {
         
        List<Tour_Optional__c> tourOptionalList = new List<Tour_Optional__c>();
        
        Optional__c  optn = new Optional__c();
        optn.Name = 'test optional';
        optn.Included_in_Tour__c = false; 
        optn.Duplicate__c  = false;
        insert optn;
        
        for(integer i=1;i<=20;i++) {
            
            Tour_Optional__c objOptional = new Tour_Optional__c();
            objOptional.Tour_Instance__c = tour.Id;
            objOptional.Optional__c = optn.Id;
            objOptional.Name = 'Temp Testign Data';
            objOptional.Use_Optional__c = true;
            objOptional.Brand_Name__c = 'Trafalgar';
            tourOptionalList.add(objOptional);
        }    
        
        insert tourOptionalList;
    }

}