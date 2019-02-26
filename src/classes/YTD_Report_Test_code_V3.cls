@isTest (seealldata = false)
private class YTD_Report_Test_code_V3
{
	@isTest
	static void InsertTestRecords()
	{
		//get Account record Types
		map<string, id> mapRT = new map<string, id>();
		for(RecordType RT : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account']){
			mapRT.put(RT.DeveloperName, RT.id);
		}

		//get Contact record Types
		map<string, id> mapRTCon = new map<string, id>();
		for(RecordType RT2 : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Contact']){
			mapRTCon.put(RT2.DeveloperName, RT2.id);
		}

		//get Booking__c record Types
		map<string, id> mapRTBooking = new map<string, id>();
		for(RecordType RT3 : [SELECT id, DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Booking__c']){
			mapRTBooking.put(RT3.DeveloperName, RT3.id);
		}


		//Insert Business Unit
		Account BU = new Account(name = 'Business Unit', recordTypeID = mapRT.get('Selling_Company'));
		insert BU;

		//Insert Travel Agencies
		Account TA = new Account(name = 'Travel Agency', recordTypeID = mapRT.get('Agency'));
		insert TA;

		//Insert Consultants
		Contact Consult = new Contact(firstname = 'Consultant', lastname = '1', recordTypeID = mapRTCon.get('Travel_Consultant'));
		insert Consult;

		//insert Consortia
		Account Consortia = new Account(name = 'Consortia', recordTypeID = mapRT.get('Consortia'));
		insert Consortia;

		//Insert Brochure
		Brochure__c Brochure = new Brochure__c(name = 'BROCH1', Brochure_name__c = 'Brochure one');
		insert Brochure;

		//Insert Brochure
		Brochure__c Brochure2 = new Brochure__c(name = 'BROCH2', Brochure_name__c = 'Brochure two');
		insert Brochure2;

		//get random user id
		user user1 = [select id from user where isActive = true and profile.name = 'System Administrator' limit 1];

		//Insert BU and Salesmanager Summary Analysis
		Summary_Analysis_2__c SA_BU_SM = new Summary_Analysis_2__c(CY_Minus_1_Pax__c = 1, YTD_Previous_Year_Departure_Pax__c = 1, CY_Pax__c = 1, CY_Pax_Paid__c = 1, Departure_this_year_booked_last_year__c = 1,
																CY_plus_1_Pax__c = 1, CY_Minus_1_Sales__c = 1, YTD_Previous_Year_Departure_Value__c = 1, CY_Sales__c = 1, CY_Value_Paid__c = 1, Departure_CY_Booked_Last_Value__c = 1, 
																CY_Plus_1_Sales__c = 1, ownerid = user1.id, Account__c = BU.id, type__c = 'Business Unit - YTD - By Owner', active__c = true);
		insert SA_BU_SM;

		//insert BU and TA SA
		Summary_Analysis_2__c SA_BU_TA = new Summary_Analysis_2__c(CY_Minus_1_Pax__c = 1, YTD_Previous_Year_Departure_Pax__c = 1, CY_Pax__c = 1, CY_Pax_Paid__c = 1, Departure_this_year_booked_last_year__c = 1,
																CY_plus_1_Pax__c = 1, CY_Minus_1_Sales__c = 1, YTD_Previous_Year_Departure_Value__c = 1, CY_Sales__c = 1, CY_Value_Paid__c = 1, Departure_CY_Booked_Last_Value__c = 1, 
																CY_Plus_1_Sales__c = 1, ownerid = user1.id, Business_Unit__c = BU.id, Account__c = TA.id, type__c = 'Travel Agent - Split By Owner', active__c = true);
		insert SA_BU_TA;

		//Insert Consultant and BU SA
		Summary_Analysis_2__c SA_BU_Consultant = new Summary_Analysis_2__c(CY_Minus_1_Pax__c = 1, YTD_Previous_Year_Departure_Pax__c = 1, CY_Pax__c = 1, CY_Pax_Paid__c = 1, Departure_this_year_booked_last_year__c = 1,
																CY_plus_1_Pax__c = 1, CY_Minus_1_Sales__c = 1, YTD_Previous_Year_Departure_Value__c = 1, CY_Sales__c = 1, CY_Value_Paid__c = 1, Departure_CY_Booked_Last_Value__c = 1, 
																CY_Plus_1_Sales__c = 1, ownerid = user1.id, Business_Unit__c = BU.id, Account__c = BU.id, Contact__c = Consult.id, type__c = 'Business Unit - Consultant - Split Owner', active__c = true);
		insert SA_BU_Consultant;

		//Insert Brochure and BU SA
		Summary_Analysis_2__c SA_BU_Brochure = new Summary_Analysis_2__c(CY_Minus_1_Pax__c = 1, YTD_Previous_Year_Departure_Pax__c = 1, CY_Pax__c = 1, CY_Pax_Paid__c = 1, Departure_this_year_booked_last_year__c = 1,
																CY_plus_1_Pax__c = 1, CY_Minus_1_Sales__c = 1, YTD_Previous_Year_Departure_Value__c = 1, CY_Sales__c = 1, CY_Value_Paid__c = 1, Departure_CY_Booked_Last_Value__c = 1, 
																CY_Plus_1_Sales__c = 1, ownerid = user1.id, Business_Unit__c = BU.id, Account__c = BU.id, Brochure__c = Brochure.id, type__c = 'Business Unit - Brochure - Split By Owner', active__c = true);
		insert SA_BU_Brochure;

		//insert BU and consortia SA
		Summary_Analysis_2__c SA_BU_Consortia = new Summary_Analysis_2__c(CY_Minus_1_Pax__c = 1, YTD_Previous_Year_Departure_Pax__c = 1, CY_Pax__c = 1, CY_Pax_Paid__c = 1, Departure_this_year_booked_last_year__c = 1,
																CY_plus_1_Pax__c = 1, CY_Minus_1_Sales__c = 1, YTD_Previous_Year_Departure_Value__c = 1, CY_Sales__c = 1, CY_Value_Paid__c = 1, Departure_CY_Booked_Last_Value__c = 1, 
																CY_Plus_1_Sales__c = 1, ownerid = user1.id, Business_Unit__c = BU.id, Account__c = Consortia.id, type__c = 'Business Unit - Consortium - Split Owner', active__c = true);
		insert SA_BU_Consortia;


		//insert Brochure for APR Summary Analysis record
		Summary_Analysis_2__c SA_APR = new Summary_Analysis_2__c(CY_Minus_1_Pax__c = 1, YTD_Previous_Year_Departure_Pax__c = 1, CY_Pax__c = 1, CY_Pax_Paid__c = 1, Departure_this_year_booked_last_year__c = 1,
																CY_plus_1_Pax__c = 1, CY_Minus_1_Sales__c = 1, YTD_Previous_Year_Departure_Value__c = 1, CY_Sales__c = 1, CY_Value_Paid__c = 1, Departure_CY_Booked_Last_Value__c = 1, 
																CY_Plus_1_Sales__c = 1, ownerid = user1.id, Business_Unit__c = BU.id, Account__c = TA.id, Brochure_Text__c = 'Test Brochure',
																Apr_CY_M1_YTD_Pax__c = 1, Aug_CY_M1_Pax__c = 1, Aug_CY_YTD_Sales__c = 2.00, type__c = 'Business Unit - Brochure - Agency - Split By Owner', active__c = true);
		insert SA_APR;

		//Get current year
		integer thisYear = date.today().year();

		//insert CY
		list<booking__c> Bookings = new list<booking__c>();
		Booking__c BookCY = new Booking__c(Original_Booking_Date__c = date.today(), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111', Travel_Agent__c = TA.id, Hidden_First_Departure_Month__c = '01', Hidden_First_Departure_Year__c = string.valueof(thisYear), Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
		Bookings.add(BookCY);

		Booking__c BookCYYTD = new Booking__c(Original_Booking_Date__c = date.today().addyears(-1), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111', Travel_Agent__c = TA.id, Hidden_First_Departure_Month__c = '01', Hidden_First_Departure_Year__c = string.valueof(thisYear), Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
		Bookings.add(BookCYYTD);

		//insert CYM1
		Booking__c BookCYM1 = new Booking__c(Original_Booking_Date__c = date.today(), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111', Travel_Agent__c = TA.id, Hidden_First_Departure_Month__c = '01', Hidden_First_Departure_Year__c = string.valueof(thisYear -1 ), Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
		Bookings.add(BookCYM1);

		Booking__c BookCYM1YTD = new Booking__c(Original_Booking_Date__c = date.today().addyears(-1), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111', Travel_Agent__c = TA.id, Hidden_First_Departure_Month__c = '01', Hidden_First_Departure_Year__c = string.valueof(thisYear - 1), Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
		Bookings.add(BookCYM1YTD);

		//insert CYM2
		Booking__c BookCYM2 = new Booking__c(Original_Booking_Date__c = date.today(), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111', Travel_Agent__c = TA.id, Hidden_First_Departure_Month__c = '01', Hidden_First_Departure_Year__c = string.valueof(thisYear - 2), Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
		Bookings.add(BookCYM2);

		//insert CYP1
		Booking__c BookCYP1 = new Booking__c(Original_Booking_Date__c = date.today(), recordTypeID = mapRTBooking.get('Booking'), Selling_Company__c = BU.id, name = '1111', Travel_Agent__c = TA.id, Hidden_First_Departure_Month__c = '01', Hidden_First_Departure_Year__c = string.valueof(thisYear + 1), Payment_Status__c = 'FP', First_Departure_Date__c = date.today(), Status__c = 'CO');
		Bookings.add(BookCYP1);
		insert Bookings;

		//insert booking pax
		list<Booking_Passenger__c> BookingPaxList = new list<Booking_Passenger__c>();
		Booking_Passenger__c BookingPax1 = new Booking_Passenger__c(Booking__c = BookCY.id, name = 'test');
		BookingPaxList.add(BookingPax1);
		Booking_Passenger__c BookingPax2 = new Booking_Passenger__c(Booking__c = BookCYYTD.id, name = 'test');
		BookingPaxList.add(BookingPax2);
		Booking_Passenger__c BookingPax3 = new Booking_Passenger__c(Booking__c = BookCYM1.id, name = 'test');
		BookingPaxList.add(BookingPax3);
		Booking_Passenger__c BookingPax4 = new Booking_Passenger__c(Booking__c = BookCYM1YTD.id, name = 'test');
		BookingPaxList.add(BookingPax4);
		Booking_Passenger__c BookingPax5 = new Booking_Passenger__c(Booking__c = BookCYM2.id, name = 'test');
		BookingPaxList.add(BookingPax5);
		Booking_Passenger__c BookingPax6 = new Booking_Passenger__c(Booking__c = BookCYP1.id, name = 'test');
		BookingPaxList.add(BookingPax6);
		insert BookingPaxList;



		//insert booking components 
		list<Booking_Component__c> ComponentsList = new list<Booking_Component__c>();
		Booking_Component__c CompCY = new Booking_Component__c(Hidden_Start_Date_Year__c = string.valueof(thisYear), Status__c = 'CO', Booking_Number__c = BookCY.ID, Brochure__c = Brochure.id, Booking_Passenger__c = BookingPax1.id);
		ComponentsList.add(CompCY);
		Booking_Component__c CompCYYTD = new Booking_Component__c(Hidden_Start_Date_Year__c = string.valueof(thisYear), Status__c = 'CO', Booking_Number__c = BookCYYTD.ID, Brochure__c = Brochure.id, Booking_Passenger__c = BookingPax2.id);
		ComponentsList.add(CompCYYTD);
		Booking_Component__c CompCYM1 = new Booking_Component__c(Hidden_Start_Date_Year__c = string.valueof(thisYear-1), Status__c = 'CO', Booking_Number__c = BookCYM1.ID, Brochure__c = Brochure.id, Booking_Passenger__c = BookingPax3.id);
		ComponentsList.add(CompCYM1);
		Booking_Component__c CompCYM1YTD = new Booking_Component__c(Hidden_Start_Date_Year__c = string.valueof(thisYear-1), Status__c = 'CO', Booking_Number__c = BookCYM1YTD.ID, Brochure__c = Brochure2.id, Booking_Passenger__c = BookingPax4.id);
		ComponentsList.add(CompCYM1YTD);
		Booking_Component__c CompCYM2 = new Booking_Component__c(Hidden_Start_Date_Year__c = string.valueof(thisYear-2), Status__c = 'CO', Booking_Number__c = BookCYM2.ID, Brochure__c = Brochure2.id, Booking_Passenger__c = BookingPax5.id);
		ComponentsList.add(CompCYM2);
		Booking_Component__c CompCYP1 = new Booking_Component__c(Hidden_Start_Date_Year__c = string.valueof(thisYear+1), Status__c = 'CO', Booking_Number__c = BookCYP1.ID, Brochure__c = Brochure2.id, Booking_Passenger__c = BookingPax6.id);
		ComponentsList.add(CompCYP1);
		insert ComponentsList;


	}

	@isTest
	static void TestYTDReportWithData()
	{
		//insert test records
		InsertTestRecords();

		test.startTest();

		//Set page and initialise Controller
		YTD_Report_Controller_V2 YTDCon = new YTD_Report_Controller_V2();

		//Set Business Unit ID and current row
		YTDCon.CurrentRow = 0;
		YTDCon.BusinessUnit = [select id from account where name = 'Business Unit'].id;

		//Get value options 
		YTDCon.getOptions();

		//Drill down to Consultants
		YTDCon.addConsultants();

		//Switch to revenue
		YTDCon.PaxOrVal = 'Val';
		YTDCon.changeValOrPax();

		//Close drill down
		YTDCon.removeDrillDown();

		//Drill down to TA
		YTDCon.addTravelAgents();

		//Switch back to pax count
		YTDCon.PaxOrVal = 'Pax';
		YTDCon.changeValOrPax();

		//Drill down to Sales manager
		YTDCon.addSM();

		//Drill down to consortia
		YTDCon.addConsortium();

		//drill down to Brochures
		YTDCon.addBrochures();

		//switch back to Revenue
		YTDCon.PaxOrVal = 'Val';
		YTDCon.changeValOrPax();

		//Close drill down
		YTDCon.removeDrillDown();

		test.stopTest();

	}

	@isTest
	static void TestReportWithNoData()
	{

		//Set page and initialise Controller
		YTD_Report_Controller_V2 YTDCon = new YTD_Report_Controller_V2();

	}

	@isTest
	static void TestAgencyProduction()
	{
		
		//insert test records
		InsertTestRecords();
		string busUnitID = [select id from account where name = 'Business Unit'].id;
		string BusName;

		//Set page and initialise Controller extension
		Account TA = [select id, name, CurrencyIsoCode from account where name = 'Travel Agency'];
		ApexPages.StandardController stdAcc = new ApexPages.StandardController(TA);
		Agency_Production_V2 AgencyProd = new Agency_Production_V2(stdAcc);

		//Select last year variance
		AgencyProd.VarianceSelected = 'Last';
		AgencyProd.switchVariance();

		//Select next year variance
		AgencyProd.VarianceSelected = 'Next';
		AgencyProd.switchVariance();

		//Show filters
		AgencyProd.GenerateFilters();

		//select a business unit and run 
		AgencyProd.BusinessUnit = busUnitID;
		BusName = AgencyProd.BusinessUnitName;
		AgencyProd.getBookings();

		//Select last year variance
		AgencyProd.VarianceSelected = 'Last';
		AgencyProd.switchVariance();

		//Select next year variance
		AgencyProd.VarianceSelected = 'Next';
		AgencyProd.switchVariance();

		//Set Group Booking filter and run
		AgencyProd.GroupBookingOnly = true;
		AgencyProd.getBookings();

		//remove Business unit filter and run
		AgencyProd.BusinessUnit = 'ALL';
		AgencyProd.getBookings();

		//close filters
		AgencyProd.closeFilters();

		//**** Page variables ****
		AgencyProd.getTypeOptions();
		AgencyProd.getVarianceOptions();
		AgencyProd.getVarianceLabel();
		AgencyProd.BackToAcc();
		AgencyProd.RenderPdf();
		AgencyProd.RenderExcel();

		
	}

	@isTest
	static void TestAgencyProduction_Brochures()
	{
		
		//insert test records
		InsertTestRecords();
		string busUnitID = [select id from account where name = 'Business Unit'].id;
		string BusName;

		//Set page and initialise Controller extension
		Account TA = [select id, name, CurrencyIsoCode from account where name = 'Travel Agency'];
		
		test.starttest();
		ApexPages.StandardController stdAcc = new ApexPages.StandardController(TA);
		Agency_Production_V2 AgencyProd = new Agency_Production_V2(stdAcc);

		//****Change to brochures*****
		AgencyProd.Type = 'Brochure';
		AgencyProd.getBookings();

		//Select last year variance
		AgencyProd.VarianceSelected = 'Last';
		AgencyProd.switchVariance();

		//Select next year variance
		AgencyProd.VarianceSelected = 'Next';
		AgencyProd.switchVariance();

		//Show filters
		AgencyProd.GenerateFilters();

		//select a business unit and run 
		AgencyProd.BusinessUnit = busUnitID;
		busName = AgencyProd.BusinessUnitName;
		AgencyProd.getBookings();

		//Select last year variance
		AgencyProd.VarianceSelected = 'Last';
		AgencyProd.switchVariance();

		//Select next year variance
		AgencyProd.VarianceSelected = 'Next';
		AgencyProd.switchVariance();

		//Set Group Booking filter and run
		AgencyProd.GroupBookingOnly = true;
		AgencyProd.getBookings();

		//remove Business unit filter and run
		AgencyProd.BusinessUnit = 'ALL';
		busName = AgencyProd.BusinessUnitName;
		AgencyProd.getBookings();

		//close filters
		AgencyProd.closeFilters();


		//Back to Month
		AgencyProd.Type = 'Month';
		AgencyProd.getBookings();
		test.stopTest();

	}
	

	@isTest
	static void TestCommon()
	{
		Reports_Common_Code.ConvertThis(null, 5);
		Reports_Common_Code.formatTheCurrency(0.5, false);
	}

	
}