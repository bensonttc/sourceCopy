@isTest
private class TOPS_FormulaUpdateCheckTest {
	private static Map<String, Tour_Optional__c> tourOptionalsByName;

	static {}

	private static void init() {

		// Create some Optionals with adult and child prices
		Map<String, Optional__c> optionalsByName = new Map<String, Optional__c>();
		optionalsByName.put('opt1', createOptional('opt1',22,33));
		optionalsByName.put('opt2', createOptional('opt2',44,55));
		insert optionalsByName.values();

		// Create a tour instance
		Tour_Instance__c ti = createTourInstance('123','456');
		insert ti; 

		// Create some tour optionals with invalid current values for adult and child prices
		tourOptionalsByName = new Map<String, Tour_Optional__c>();
		tourOptionalsByName.put('to1', createTourOptional(ti.Id, optionalsByName.get('opt1').Id,'Tour Opt 1',2,3));
		tourOptionalsByName.put('to2', createTourOptional(ti.Id, optionalsByName.get('opt2').Id,'Tour Opt 2',2,3));
		tourOptionalsByName.put('to3', createTourOptional(ti.Id, optionalsByName.get('opt2').Id,'Tour Opt 3',44,55));
		insert tourOptionalsByName.values();

	}

	/**
	 * @description Test that for a given object the update code reviews and cheanges the record
	 **/
	static testMethod void testUpdateSuccess() {

		// Setup data
		init();

		// Start the test
		Test.startTest();

		// Create a service object and process the tour optionals
		TOPS_FormulaUpdateCheckService updateService = new TOPS_FormulaUpdateCheckService();
		updateService.checkFormulaFields(tourOptionalsByName.values(), 'Tour_Optional__c');

		// Stop the test
		Test.stopTest();

		// Check that just two records were updated
		System.assertEquals(2, updateService.updateCount);

		// Get the tour optionals and check that values have been updated
		List<Tour_Optional__c> updatedTourOptionals = [SELECT Id, Adult_Price_Copy__c, Child_Price_Copy__c, Name FROM Tour_Optional__c];
		for (Tour_Optional__c to : updatedTourOptionals) {
			if (to.Id == tourOptionalsByName.get('to1').Id) {
				System.assertEquals(22, to.Adult_Price_Copy__c);
				System.assertEquals(33, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to2').Id) {
				System.assertEquals(44, to.Adult_Price_Copy__c);
				System.assertEquals(55, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to3').Id) {
				System.assertEquals(44, to.Adult_Price_Copy__c);
				System.assertEquals(55, to.Child_Price_Copy__c);
			} else {
				System.assert(false, 'This Tour Optional ID is invalid');
			}
		}

	}

	/**
	 * @description Test that the batch job fires for a simple process
	 **/
	static testMethod void testBatchProcess() {

		// Setup data
		init();

		// Start the test
		Test.startTest();

		// Create a list of objects to process
		Set<String> objectNames = new Set<String>();
		objectNames.add('Tour_Optional__c');

		// Start the batch for just this one object
		TOPS_FormulaUpdateCheckBatch statBatch = new TOPS_FormulaUpdateCheckBatch(objectNames);
       	ID batchId = Database.executeBatch(statBatch, 2000);     		

		// Stop the test
		Test.stopTest();

		// Test that only two records were updated
		//System.assertEquals(2, statBatch.updatedObjectCount);

		// Get the tour optionals and check that values have been updated
		List<Tour_Optional__c> updatedTourOptionals = [SELECT Id, Adult_Price_Copy__c, Child_Price_Copy__c, Name FROM Tour_Optional__c];
		for (Tour_Optional__c to : updatedTourOptionals) {
			if (to.Id == tourOptionalsByName.get('to1').Id) {
				System.assertEquals(22, to.Adult_Price_Copy__c);
				System.assertEquals(33, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to2').Id) {
				System.assertEquals(44, to.Adult_Price_Copy__c);
				System.assertEquals(55, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to3').Id) {
				System.assertEquals(44, to.Adult_Price_Copy__c);
				System.assertEquals(55, to.Child_Price_Copy__c);
			} else {
				System.assert(false, 'This Tour Optional ID is invalid');
			}
		}

	}

	/**
	 * @description Test updating two objects
	 **/
	static testMethod void testMultiObjectUpdate() {

		// Setup data
		init();

		// Create a selling company
		Account sellCompany = createSellingCompany('Test Co');
		insert sellCompany;

		// Create a booking
		Booking__c booking = createBooking('Name1', sellCompany.Id);
		insert booking;

		// Create some booking passengers
		Booking_Passenger__c bookPass = createBookingPassenger('PassBook',booking.Id);
		insert bookPass;

		// Add a passenger
		Passenger__c pass = createPassenger('Fred','Bloggs',null,bookPass.Id);
		insert pass;

		// Start the test
		Test.startTest();

		// Create a list of objects to process
		Set<String> objectNames = new Set<String>();
		objectNames.add('Tour_Optional__c');
		objectNames.add('Passenger__c');

		// Start the batch for just this one object
		TOPS_FormulaUpdateCheckBatch statBatch = new TOPS_FormulaUpdateCheckBatch(objectNames);
       	ID batchId = Database.executeBatch(statBatch, 2000);     		

		// Stop the test
		Test.stopTest();

		// Get the tour optionals and check that values have been updated
		List<Tour_Optional__c> updatedTourOptionals = [SELECT Id, Adult_Price_Copy__c, Child_Price_Copy__c, Name FROM Tour_Optional__c];
		for (Tour_Optional__c to : updatedTourOptionals) {
			if (to.Id == tourOptionalsByName.get('to1').Id) {
				System.assertEquals(22, to.Adult_Price_Copy__c);
				System.assertEquals(33, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to2').Id) {
				System.assertEquals(44, to.Adult_Price_Copy__c);
				System.assertEquals(55, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to3').Id) {
				System.assertEquals(44, to.Adult_Price_Copy__c);
				System.assertEquals(55, to.Child_Price_Copy__c);
			} else {
				System.assert(false, 'This Tour Optional ID is invalid');
			}
		}

		// Test that the passenger has been updated
		Passenger__c updatedPassenger = [SELECT Id, Booking_Number_Copy__c FROM Passenger__c WHERE Id=:pass.Id];
		System.assertEquals('Name1',updatedPassenger.Booking_Number_Copy__c);

	}

	/**
	 * @description Test that a scheduled job can be created
	 **/
	static testMethod void testSchedule() {

		// Setup data
		init();

		// Start the test
		Test.startTest();

		// Create a list of objects to process
		Set<String> objectNames = new Set<String>();
		objectNames.add('Tour_Optional__c');

      	// Schedule the test job
      	String jobId = System.schedule('ScheduleApexClassTest','0 0 0 15 3 ? 2022', new TOPS_FormulaUpdateCheckSchedulable());
         
      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      	// Verify the expressions are the same
      	System.assertEquals('0 0 0 15 3 ? 2022', ct.CronExpression);

      	// Verify the job has not run
      	System.assertEquals(0, ct.TimesTriggered);

      	// Verify the next time the job will run
      	System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
      
      	// Stop the test which will trigger the job
	    Test.stopTest();

	    // Unable to test this since the batch called from teh schedule wont be fired
		/*// Get the tour optionals and check that values have been updated
		List<Tour_Optional__c> updatedTourOptionals = [SELECT Id, Adult_Price_Copy__c, Child_Price_Copy__c, Name FROM Tour_Optional__c];
		for (Tour_Optional__c to : updatedTourOptionals) {
			if (to.Id == tourOptionalsByName.get('to1').Id) {
				System.assertEquals(22.2, to.Adult_Price_Copy__c);
				System.assertEquals(33.3, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to2').Id) {
				System.assertEquals(44.4, to.Adult_Price_Copy__c);
				System.assertEquals(55.5, to.Child_Price_Copy__c);
			} else if (to.Id == tourOptionalsByName.get('to3').Id) {
				System.assertEquals(44.4, to.Adult_Price_Copy__c);
				System.assertEquals(55.5, to.Child_Price_Copy__c);
			} else {
				System.assert(false, 'This Tour Optional ID is invalid');
			}
		}*/

	}

	/************************* PRIVATE METHODS ************************/
	private static Tour_Instance__c createTourInstance(String departmentCode, String operatingProductCode) {
	    Tour_Instance__c theTestTourInstance = new Tour_Instance__c();
    	theTestTourInstance.Departure_Code__c = departmentCode;
    	theTestTourInstance.Operating_Product_Code__c = operatingProductCode;
        return theTestTourInstance;		
	}

	private static Optional__c createOptional(String name, Decimal adultPrice, Decimal childPrice) {
		Optional__c newOptional = new Optional__c();
		newOptional.Name = name;
		newOptional.Adult_Price__c = adultPrice;
		newOptional.Child_Price__c = childPrice;
		return newOptional;

	}

	private static Tour_Optional__c createTourOptional(Id tourInstanceId, Id optionalId, String name, Decimal oldAdultPrice, Decimal oldChildPrice) {
		Tour_Optional__c newOptional = new Tour_Optional__c();
		newOptional.Name = name;
		newOptional.Tour_Instance__c = tourInstanceId;
		newOptional.Optional__c = optionalId;
		newOptional.Adult_Price_Copy__c = oldAdultPrice;
		newOptional.Child_Price_Copy__c = oldChildPrice;
		return newOptional;

	}

	private static Booking__c createBooking(String name, Id sellingCompanyId) {
		Booking__c newBooking = new Booking__c();
		newBooking.Name = name;
		newBooking.Selling_Company__c = sellingCompanyId;
		return newBooking;
	}

	private static Booking_Passenger__c createBookingPassenger(String name, Id bookingId) {
		Booking_Passenger__c bookingPassenger = new Booking_Passenger__c();
		bookingPassenger.Name = name;
		bookingPassenger.Booking__c = bookingId;
		return bookingPassenger;
	}

	private static Passenger__c createPassenger(String firstName, String lastName, String oldBookingNumber, Id bookPassId) {
		Passenger__c pass = new Passenger__c();
		pass.First_Name__c = firstName;
		pass.Family_Name__c = lastName;
		pass.Booking_Passenger__c = bookPassId;
		pass.Booking_Number_Copy__c = oldBookingNumber;
		pass.Passenger_External_Id__c = firstName + System.now();		
		return pass;
	}
	
	private static Account createSellingCompany(String name) {
		Account sellCompany = new Account();
		sellCompany.Name = name;
		sellCompany.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Selling_Company' AND SobjectType='Account'].Id;
		return sellCompany;
	}

}