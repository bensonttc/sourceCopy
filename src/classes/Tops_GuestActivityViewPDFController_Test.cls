//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: Tops_GuestActivityViewPDFController_Test
// For Apex Class: Tops_GuestActivityViewPDFController
// Description: Used to generate guest activity view pdf
//
// 12th Dec 2016    Maksud Ali  (Story# - S-453096)
//
@isTest(seeAllData=false)
class Tops_GuestActivityViewPDFController_Test{

    static testMethod void Tops_GuestActivityViewPDFController_Test() { 
        
        Tour_Instance__c tourInstance = new Tour_Instance__c();
        tourInstance.Operating_Product_Code__c = 'cas';
        tourInstance.Departure_Code__c  = 'd';
        tourInstance.CurrencyIsoCode = 'EUR';
        insert tourInstance;
        initPassengerData(tourInstance);
        initTourOptional(tourInstance);
        
       PageReference passPage = Page.Tops_GuestActivityViewPDF;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('id',tourInstance.id );
       ApexPages.StandardController sc = new ApexPages.StandardController(tourInstance); 
       Tops_GuestActivityViewPDFController tc = new Tops_GuestActivityViewPDFController(sc); 
        
    }
    
    static void initPassengerData(Tour_Instance__c tour) {
        List<Passenger__c> passengerList = new List<Passenger__c>();
        
        for(integer i=1;i<=50;i++) {
            
            Passenger__c objPassenger = new Passenger__c();
            objPassenger.Tour_Instance__c = tour.Id;
            if(i == 0) {
                objPassenger.Preferred_Name__c = '';
            }
            else {
                objPassenger.Preferred_Name__c = 'Test';
            }
            
            objPassenger.Family_Name__c = 'Family';
            objPassenger.Name = 'Temp';
            objPassenger.Passenger_External_Id__c = 'adfcv';
            objPassenger.Passenger_Class__c = 'Passenger';
            
            passengerList.add(objPassenger);
        }
        
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
            
            tourOptionalList.add(objOptional);
        }    
        
        insert tourOptionalList;
        
    }
}