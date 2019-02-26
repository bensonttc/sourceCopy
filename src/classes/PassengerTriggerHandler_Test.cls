@isTest
private class PassengerTriggerHandler_Test {
  // Private Data Members.
  private static final Id ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Business Unit').RecordTypeId;
    
    // Lucas Isla - C-00234088 - 8/6/2018 - Moved setup into its own method
    @testSetup static void setup() {
        // Inserting Tour_Instance__c
        Tour_Instance__c ti = new Tour_Instance__c(
            Instance_Code__c = 'Test Instance',
            Operating_Product_Code__c = 'Test code',
            Departure_Code__c = 'Test Departure code'
        );
        insert ti; 
        
        // Inserting Test Selling Company Account.
        Account theTestSellingCompany = new Account(
            Name = 'Test Selling Company',
            Selling_Company_Short_Name__c = 'GE',
            RecordTypeId = ACCOUNT_BUSINESS_UNIT_RECORD_TYPE_ID
        );
        insert theTestSellingCompany;
        
        // Inserting Test Booking.
        Booking__c theTestBooking = new Booking__c(
            Name = 'Test Booking',
            Selling_Company__c = theTestSellingCompany.Id
        );
        insert theTestBooking;
        
        // Inserting Test Booking Passenger.
        Booking_Passenger__c theTestBookingPassenger = new Booking_Passenger__c(
            Name = 'Test Booking Passenger',
            Booking__c = theTestBooking.Id
        );
        insert theTestBookingPassenger;
        
        // Inserting Test Booking Component.
        Booking_Component__c theTestBookingComponent = new Booking_Component__c(
            Name = 'Test Booking Component',
            Booking_Passenger__c = theTestBookingPassenger.Id,
            Status__c = 'CF'
        );
        insert theTestBookingComponent;
        
        // Instantiating Test Passengers.
        List<Passenger__c> listPassenger = new List<Passenger__c>();
        for(Integer index = 0;index < 5;index++) {
            listPassenger.add(new Passenger__c(
                Name = 'Test Passenger #' + index,
                Gender__c = Math.mod(index, 2) == 0 ? 'Male' : 'Female',
                Date_Of_Birth__c = Math.mod(index, 2) == 0 ? System.Today().addYears(-21) :
                (index == 1) ? System.Today().addYears(-25) : System.Today().addYears(-10),
                Passenger_External_Id__c = '1234',
                Passenger_Class__c = 'Passenger',
                User__c = UserInfo.getUserId(),
                Booking_Passenger__c = theTestBookingPassenger.Id,
                Previous_Trips__c = 2,
                Tour_Instance__c = ti.Id,
                /*Changes done by Maksud Ali*/
                Nationality__c = 'India',
                Preferred_Name__c = (index == 1) ? ',' : 'Jonny Jeth',
                Dietary_Requirements__c = 'none',
                /* End changes */
                // Lucas Isla - C-00234088 - 8/6/2018 - Added below line
                V2_Status__c = 'CF'
            ));
        }
        insert listPassenger;
    }

    static testmethod void calculateTourInstanceFieldValues() {
        
        List<Passenger__c> listPassenger = [SELECT Name, Gender__c, Date_Of_Birth__c, Passenger_External_Id__c, Passenger_Class__c, User__c, 
                                            Booking_Passenger__c, Previous_Trips__c, Tour_Instance__c, Nationality__c, Preferred_Name__c, Dietary_Requirements__c, V2_Status__c
                                            FROM Passenger__c WHERE Name LIKE 'Test Passenger #%'];
       
        Test.StartTest();
        
        // Updating Test Passenger.
        listPassenger.get(0).Gender__c = 'Female';
        update listPassenger.get(0);
        
        // Deteting Test Passenger.
        delete listPassenger;
        
        // Undelete Test Passenger.
        undelete listPassenger;

        Test.StopTest();

        Tour_Instance__c ti = [SELECT Age_Count__c, Average_Age__c, Number_of_Children__c, Average_Age_of_Children__c, Number_of_Men__c, 
                               Number_of_Men_with_Past_Trips__c, Number_of_Women__c, Number_of_Women_with_Past_Trips__c, Number_MTS_Users__c,
                               Number_Grand_European__c FROM Tour_Instance__c WHERE Instance_Code__c = 'Test Instance'];
        system.assertEquals(true, ti.Age_Count__c == 93); //Lucas Isla - C-00234088 - 8/6/18
        //system.assertEquals(1, ti.Number_of_Children__c); //changes done by Maksud Ali
        system.assertEquals(2, ti.Number_of_Men__c);
        system.assertEquals(2, ti.Number_of_Women__c); //Lucas Isla - C-00234088 - 8/6/18
        //Lucas Isla - C-00234088 - 8/6/18 <START>
        system.assertEquals(18.6, ti.Average_Age__c);
        system.assertEquals(2, ti.Number_of_Men_with_Past_Trips__c);
        system.assertEquals(2, ti.Number_of_Women_with_Past_Trips__c);
        system.assertEquals(1, ti.Number_of_Children__c);
        system.assertEquals(9, ti.Average_Age_of_Children__c);
        //Lucas Isla - C-00234088 - 8/6/18 <END>
    }
    
    //Lucas Isla - C-00234088 - 8/6/18 - Added below test method
    static testmethod void calculateTourInstanceFieldValues2() {
      List<Passenger__c> listPassenger = [SELECT Name, Gender__c, Date_Of_Birth__c, Passenger_External_Id__c, Passenger_Class__c, User__c, 
                                            Booking_Passenger__c, Previous_Trips__c, Tour_Instance__c, Nationality__c, Preferred_Name__c, Dietary_Requirements__c, V2_Status__c
                                            FROM Passenger__c WHERE Name LIKE 'Test Passenger #%'];
       
        Test.StartTest();
        
        // Updating Test Passengers.
        listPassenger.get(0).Date_Of_Birth__c = System.Today().addYears(-30).addDays(-1);
        update listPassenger.get(0);
        // Updating Test Passengers.
        listPassenger.get(2).Date_Of_Birth__c = System.Today().addYears(-30).addDays(-1);
        update listPassenger.get(2);
        // Updating Test Passengers.
        listPassenger.get(4).Date_Of_Birth__c = System.Today().addYears(-30).addDays(-1);
        update listPassenger.get(4);
        
        
        // Deteting Test Passenger.
        delete listPassenger;
        
        // Undelete Test Passenger.
        undelete listPassenger;

        Test.StopTest();

        Tour_Instance__c ti = [SELECT Age_Count__c, Average_Age__c, Number_of_Children__c, Average_Age_of_Children__c, Number_of_Men__c, 
                               Number_of_Men_with_Past_Trips__c, Number_of_Women__c, Number_of_Women_with_Past_Trips__c, Number_MTS_Users__c,
                               Number_Grand_European__c FROM Tour_Instance__c WHERE Instance_Code__c = 'Test Instance'];
        system.assertEquals(123, ti.Age_Count__c); //Lucas Isla - C-00234088 - 8/6/18
        //system.assertEquals(1, ti.Number_of_Children__c); //changes done by Maksud Ali
        system.assertEquals(3, ti.Number_of_Men__c);
        system.assertEquals(1, ti.Number_of_Women__c); //Lucas Isla - C-00234088 - 8/6/18
        //Lucas Isla - C-00234088 - 8/6/18 <START>
        system.assertEquals(24.6, ti.Average_Age__c);
        system.assertEquals(3, ti.Number_of_Men_with_Past_Trips__c);
        system.assertEquals(1, ti.Number_of_Women_with_Past_Trips__c);
        system.assertEquals(1, ti.Number_of_Children__c);
        system.assertEquals(9, ti.Average_Age_of_Children__c);
        //Lucas Isla - C-00234088 - 8/6/18 <END>
    }
}