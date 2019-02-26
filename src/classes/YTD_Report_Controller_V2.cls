//SHARING RULES REMINDER. IT IS LOOKING LIKE IF YOU ARE LOOKING AT A SINGLE BUSINESS UNIT THEN YOU 
//SHOULD ONLY SEE ONE CONSULTANT, ONE TRAVEL AGENT ETC WHEN SPLIT BY OWNER

//SO WHEN WE ARE DOING THE GROUP BY OWNER AND BUSIENSS UNIT, THE ONLY REASON WE ARE GROUPING BY OWNER
//IS TO ADD THE OWNER TO THE SUMMARY ANALYSIS RECORD SO SHARING RULES APPLY


//To Deploy
// 1) YTD_Report_Controller class
// 2) Aggregate Class
// 3) YTD_page VF page
// 4) Brochure Fields: Hidden_Booking_Payment_Status__c, Hidden_Brand__c, Hidden_Region__c, Hidden_Booking_Owner__c
// 5) Aggregate ICS jobs
// 6) Reports Common Code
//



public with sharing class YTD_Report_Controller_V2 {
	public LIST<Aggregate> AllAgg {get; set;}
	public string DrillDownTo {get; set;}
	public string BusinessUnit {get; set;}
	public integer CurrentRow {get; set;}
	public integer LastCurrentRow {get; set;}
	//Column Renderings
	public boolean Brochures {get;set;}
	public boolean TravelAgents {get;set;}
	public boolean Consultants {get;set;}
	public boolean SMs {get;set;}
	public boolean Consortia {get;set;}

	public boolean DrillDown {get;set;}
	public integer sizeOfAddOn {get;set;}
	public string RecordId {get;set;}
	private decimal ConversionRate;
	public string userCurrency {get;set;}
	public string thisVSLast {get;set;}
	public string thisVSNext {get;set;}

	public string PaxOrVal {get;set;}

	private final integer TravelAgencyRowLimit = 20;
	private final integer ConsultancyRowLimit = 20;
	private final integer ConsortiumRowLimit = 20;

	public YTD_Report_Controller_V2() {
		AllAgg = new list<Aggregate>();
		Brochures = false;
		TravelAgents = false;
		Consultants = false;
		SMs = false;
		Consortia = false;
		PaxOrVal = 'pax';

		sizeOfAddOn = 0;
		DrillDown = false;

		//Get the current year for the grouped header
		integer thisYear = date.today().year();
		integer lastYear = thisYear - 1;
		integer nextYear = thisYear + 1;
		thisVSLast = lastYear + ' v ' + thisYear;
		thisVSNext = thisYear+ ' v ' + nextYear;


		//Get users Currency value so that we can convert the Aggregated results into the users currency
		userCurrency = UserInfo.getDefaultCurrency();
		system.debug('User Currency = '+userCurrency);
		ConversionRate = [SELECT conversionrate FROM currencytype WHERE isocode =: userCurrency LIMIT 1].conversionRate;
		system.debug('Conversion rate = '+ConversionRate);
		CalculateBUAgg();

	}




	public void CalculateBUAgg(){
		
		try{
			set<ID> BUIDs = new set<ID>();

			//add grouped Header row
			Aggregate AggGrouped = new Aggregate (ConversionRate, PaxOrVal, false, null, null, false, null, null, null, null);
	        AggGrouped.GroupedHeaderRow = true;
	        AggGrouped.CY_VF = thisVSLast;
	        AggGrouped.CYP1_VF = thisVSNext;
	        AggGrouped.HideDrillDown = true;
			AllAgg.add(AggGrouped);

			//add Header row
			Aggregate Agg = new Aggregate (ConversionRate, PaxOrVal, true, null, null, false, null, null, null, null);
	        Agg.UltimateHeaderRow = true;
			AllAgg.add(Agg);

			//Add in the results

			list<Aggregate> BUAgg = new list<Aggregate>();
			integer j = 0;
			for(AggregateResult SA :[Select Brand__c, Account__c, SUM(CY_Minus_1_Pax__c) CYM1Pax, SUM(YTD_Previous_Year_Departure_Pax__c) YTD, SUM(CY_Pax__c) CYPax, SUM(CY_Pax_Paid__c) CYPaxPaid, SUM(Departure_this_year_booked_last_year__c) BookedLast, SUM(CY_plus_1_Pax__c) CYP1Pax, SUM(CY_Minus_1_Sales__c) CYM1Val, SUM(YTD_Previous_Year_Departure_Value__c) YTDVal, SUM(CY_Sales__c) CYVal, SUM(CY_Value_Paid__c) CYValPaid, SUM(Departure_CY_Booked_Last_Value__c) BookedLastVal, SUM(CY_Plus_1_Sales__c) CYP1Val from Summary_analysis_2__c where Type__c = 'Business Unit - YTD - By Owner'  AND Active__c = TRUE GROUP BY RollUp (Brand__c, Account__c) order by Brand__c asc nulls last]){
				Aggregate thisAgg = new Aggregate (ConversionRate, PaxOrVal, false, SA, null, false, null, null, null, null);
				BUAgg.add(thisAgg);

				if((string) SA.get('Account__c') == null && (string) SA.get('Brand__c') != null){
					//Brand Summary - therefore place after results
					thisAgg.subTotalRow = true;
					thisAgg.HideDrillDown = true;
					thisAgg.BUorder = string.valueOf(j) + string.valueOf(2);
					
					//insert blank row after subtotal row - place after Brand Summary
					Aggregate AggBlank = new Aggregate (ConversionRate, PaxOrVal, false, null, null, true, null, null, null, null);
					AggBlank.BUorder = string.valueOf(j)+ string.valueOf(3);
					AggBlank.BlankRow = true;
					BUAgg.add(AggBlank);

					j++;
				}
				else if ((string) SA.get('Account__c') == null && (string) SA.get('Brand__c') == null){
					//Grand Summary level - place at end of report
					thisAgg.GrandTotalRow = true;
					thisAgg.HideDrillDown = true;
					thisAgg.BUorder = 'ZZZZEND';
				}
				else{
					//BU Level - place at start
					thisAgg.BUorder = string.valueOf(j)+ string.valueOf(1);
				}
				
				BUIDs.add( (ID) SA.get('Account__c') );
			}

			map<id, Account> AccountMap = new map<id, Account>([select id, name, parent.name, parentID from Account where id in : BUIDs]);

			//Add in the Business Units name and add BU name to the order field
			for(Aggregate Agg2 : BUAgg){
				Account thisAccount = AccountMap.get(Agg2.AccId);
				Agg2.Acc = thisAccount;
				if(!Agg2.subTotalRow && !Agg2.BlankRow){
					Agg2.BUorder += Agg2.Acc.name;
				}
				system.debug('Order Value = '+ Agg2.BUorder);
			}

			Aggregate.SortBy = 'ByBU';
			BUAgg.sort();

			integer count = 1;
			for(Aggregate Agg2 : BUAgg){
				Agg2.rowNum = count;
				count++;
				AllAgg.add(Agg2);
			}
		}
		catch(exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.error,'There was an error: ' + string.valueof(e.getcause())+ ' : ' + string.valueof(e.getLineNumber()) + ' : ' + e.getMessage() + ' : ' + e.getTypeName() + ' : ' + e.getStackTracestring()));
		}
		
	}

	public pageReference GoToRecord(){
		PageReference PR = new pageReference('/'+ RecordId);
		return PR;
	}

	public pageReference GoHome(){
		PageReference pg=new pagereference('/home/home.jsp');//work all salesforce servers.
		pg.setredirect(true);
		return pg;
	}

	public void ExpandSection(){

	}

	public void removeDrillDown(){
		DrillDown = false;
		Brochures = false;
		TravelAgents = false;
		Consultants = false;
		SMs = false;
		Consortia = false;

		//Copy the list
		list<Aggregate> AllCopy = new list<Aggregate>();
		AllCopy = AllAgg.clone();
		AllAgg = new list<Aggregate>();


		integer i = 0;
		for(Aggregate Agg: AllCopy){
			if(i > LastCurrentRow && i <= LastCurrentRow + sizeOfAddOn){

			}
			else{
				Agg.UpDrillDown = false;
				AllAgg.add(Agg);
			}
			i++;
		}
	}

	public void addBrochures(){
		//Remove old Drill Down
		if(DrillDown){
			removeDrillDown();
		}
		
		list<Aggregate> AggBrochure = new list<Aggregate>();
		integer count = 0;
		for(AggregateResult SA :[Select Brochure_Text__c, SUM(CY_Minus_1_Pax__c) CYM1Pax, SUM(YTD_Previous_Year_Departure_Pax__c) YTD, SUM(CY_Pax__c) CYPax, SUM(CY_Pax_Paid__c) CYPaxPaid, SUM(Departure_this_year_booked_last_year__c) BookedLast, SUM(CY_plus_1_Pax__c) CYP1Pax, SUM(CY_Minus_1_Sales__c) CYM1Val, SUM(YTD_Previous_Year_Departure_Value__c) YTDVal, SUM(CY_Sales__c) CYVal, SUM(CY_Value_Paid__c) CYValPaid, SUM(Departure_CY_Booked_Last_Value__c) BookedLastVal, SUM(CY_Plus_1_Sales__c) CYP1Val from Summary_analysis_2__c where Type__c = 'Business Unit - Brochure - Split By Owner' AND Account__c = :BusinessUnit AND (CY_Minus_1_Pax__c >0 OR YTD_Previous_Year_Departure_Pax__c > 0 OR CY_Pax__c > 0 OR CY_Pax_Paid__c>0 OR Departure_this_year_booked_last_year__c > 0 OR CY_plus_1_Pax__c > 0)  AND Active__c = TRUE  GROUP BY Brochure_Text__c]){
			AggBrochure.add(new Aggregate(ConversionRate, PaxOrVal, false, SA, null, true, null, null, string.valueOf(SA.get('Brochure_Text__c')), null));
			count++;
		}

		//If there are none to drill down then show warning
		if(AggBrochure.size() ==0){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.info,'No Brochures to Drill Down to'));
			return;
		}

		//Change the name of the Null Brochures to 'other'
		for(Aggregate Agg : AggBrochure){
			if(Agg.RecordName == null){
				Agg.RecordName = 'Other';
			}
		}

		//Sort Brochures
		Aggregate.SortBy = 'ByName';
		//AggBrochure.Sort();

		addIn(AggBrochure);
		Brochures = true;

	}

	public void addTravelAgents(){
		//Remove old Drill Down
		if(DrillDown){
			removeDrillDown();
		}

		set<id> IdsAlreadyInList = new set<id>();
		list<Aggregate> TravelAgg = new list<Aggregate>();

		//Add in the Top X amount
		for(Summary_analysis_2__c SA : [Select ID, Account__c, Account__r.Name, CY_Minus_1_Pax__c, YTD_Previous_Year_Departure_Pax__c, CY_Pax__c, CY_Pax_Paid__c, Departure_this_year_booked_last_year__c, CY_plus_1_Pax__c, convertCurrency(CY_Minus_1_Sales__c), convertCurrency(YTD_Previous_Year_Departure_Value__c), convertCurrency(CY_Sales__c), convertCurrency(CY_Value_Paid__c), convertCurrency(Departure_CY_Booked_Last_Value__c), convertCurrency(CY_Plus_1_Sales__c) from Summary_analysis_2__c where Type__c = 'Travel Agent - Split By Owner' AND Business_Unit__c = :BusinessUnit  AND Active__c = TRUE order by CY_Pax__c desc nulls last limit :TravelAgencyRowLimit]){
			system.debug('Account ID = '+SA.get('Account__c'));
			IdsAlreadyInList.add(SA.ID);
			TravelAgg.add(new Aggregate (ConversionRate, PaxOrVal, false, null, SA, true, SA.Account__r, null, null, null));
		}
		
		if(TravelAgg.size() ==0){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.info,'No Travel Agents to Drill Down to'));
			return;
		}
		//Aggregate the rest of the Data into 'Other'

		for(AggregateResult SA :[Select Business_Unit__c, SUM(CY_Minus_1_Pax__c) CYM1Pax, SUM(YTD_Previous_Year_Departure_Pax__c) YTD, SUM(CY_Pax__c) CYPax, SUM(CY_Pax_Paid__c) CYPaxPaid, SUM(Departure_this_year_booked_last_year__c) BookedLast, SUM(CY_plus_1_Pax__c) CYP1Pax, SUM(CY_Minus_1_Sales__c) CYM1Val, SUM(YTD_Previous_Year_Departure_Value__c) YTDVal, SUM(CY_Sales__c) CYVal, SUM(CY_Value_Paid__c) CYValPaid, SUM(Departure_CY_Booked_Last_Value__c) BookedLastVal, SUM(CY_Plus_1_Sales__c) CYP1Val from Summary_analysis_2__c where Type__c = 'Travel Agent - Split By Owner' AND Business_Unit__c = :BusinessUnit AND id not in : IdsAlreadyInList  AND Active__c = TRUE GROUP BY Business_Unit__c]){
			TravelAgg.add(new Aggregate (ConversionRate, PaxOrVal, false, SA, null, true, new Account(name = 'Other'), null, null, null));
		}

		addIn(TravelAgg);
		TravelAgents = true;
	}


	public void addConsortium(){
		//Remove old Drill Down
		if(DrillDown){
			removeDrillDown();
		}

		set<id> ConsortID = new set<id>();
		list<Aggregate> ConsortAgg = new list<Aggregate>();

		for(AggregateResult SA :[Select Account__c, SUM(CY_Minus_1_Pax__c) CYM1Pax, SUM(YTD_Previous_Year_Departure_Pax__c) YTD, SUM(CY_Pax__c) CYPax, SUM(CY_Pax_Paid__c) CYPaxPaid, SUM(Departure_this_year_booked_last_year__c) BookedLast, SUM(CY_plus_1_Pax__c) CYP1Pax, SUM(CY_Minus_1_Sales__c) CYM1Val, SUM(YTD_Previous_Year_Departure_Value__c) YTDVal, SUM(CY_Sales__c) CYVal, SUM(CY_Value_Paid__c) CYValPaid, SUM(Departure_CY_Booked_Last_Value__c) BookedLastVal, SUM(CY_Plus_1_Sales__c) CYP1Val from Summary_analysis_2__c where Type__c = 'Business Unit - Consortium - Split Owner' AND Business_Unit__c = :BusinessUnit AND Active__c = TRUE GROUP BY Account__c ]){
			ID conID = (ID) SA.get('Account__c');
			if(conID != null){
				ConsortID.add(conID);
			}
			ConsortAgg.add(new Aggregate (ConversionRate, PaxOrVal, false, SA, null, true, null, null, null, conID));
		}

		map<id, Account> ConsortMap = new map<id, Account>([select id, name from Account where id in :ConsortID]);

		//Sort Consortia
		Aggregate.SortBy = 'ByCYPax';
		ConsortAgg.Sort();

		//Get the top X
		set<ID> IdsAlreadyInList = new set<ID>();
		list<Aggregate> AggConsortiaTopX = new list<Aggregate>();
		integer i = 0;
		for(Aggregate Ag:ConsortAgg){
			if(i >= ConsortiumRowLimit){
				break;
			}
			else{
				Account Cons = ConsortMap.get(Ag.RecordID);
				if(Cons != null){
					Ag.RecordName = Cons.Name;
					AggConsortiaTopX.add(Ag);
					IdsAlreadyInList.add(Ag.RecordID);
					i++;
				}
				else{
					//Ag.RecordName = 'Other';
				}
			}
		}

		for(AggregateResult SA :[Select Business_Unit__c, SUM(CY_Minus_1_Pax__c) CYM1Pax, SUM(YTD_Previous_Year_Departure_Pax__c) YTD, SUM(CY_Pax__c) CYPax, SUM(CY_Pax_Paid__c) CYPaxPaid, SUM(Departure_this_year_booked_last_year__c) BookedLast, SUM(CY_plus_1_Pax__c) CYP1Pax, SUM(CY_Minus_1_Sales__c) CYM1Val, SUM(YTD_Previous_Year_Departure_Value__c) YTDVal, SUM(CY_Sales__c) CYVal, SUM(CY_Value_Paid__c) CYValPaid, SUM(Departure_CY_Booked_Last_Value__c) BookedLastVal, SUM(CY_Plus_1_Sales__c) CYP1Val from Summary_analysis_2__c where Type__c = 'Business Unit - Consortium - Split Owner' AND Business_Unit__c = :BusinessUnit AND Account__c not in : IdsAlreadyInList AND Account__c != null AND Active__c = TRUE GROUP BY Business_Unit__c]){
			AggConsortiaTopX.add(new Aggregate (ConversionRate, PaxOrVal, false, SA, null, true, null, null, 'Other', null));
		}
		
		addIn(AggConsortiaTopX);
		Consortia = true;
	}


	public void addConsultants(){
		//Remove old Drill Down
		if(DrillDown){
			removeDrillDown();
		}

		set<id> IdsAlreadyInList = new set<id>();
		list<Aggregate> ConsultAgg = new list<Aggregate>();

		//Add in the Top X amount
		for(Summary_analysis_2__c SA : [Select ID, Account__c, Contact__c, Contact__r.name, Contact__r.Lastname, CY_Minus_1_Pax__c, YTD_Previous_Year_Departure_Pax__c, CY_Pax__c, CY_Pax_Paid__c, Departure_this_year_booked_last_year__c, CY_plus_1_Pax__c, convertCurrency(CY_Minus_1_Sales__c), convertCurrency(YTD_Previous_Year_Departure_Value__c), convertCurrency(CY_Sales__c), convertCurrency(CY_Value_Paid__c), convertCurrency(Departure_CY_Booked_Last_Value__c), convertCurrency(CY_Plus_1_Sales__c)  from Summary_analysis_2__c where Type__c = 'Business Unit - Consultant - Split Owner' AND Account__c = :BusinessUnit AND Active__c = TRUE order by CY_Pax__c desc  nulls last limit :ConsultancyRowLimit]){
			IdsAlreadyInList.add(SA.ID);
			ConsultAgg.add(new Aggregate (ConversionRate, PaxOrVal, false, null, SA, true, null, SA.Contact__r, null, null));
		}
		
		if(ConsultAgg.size() ==0){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.info,'No Consultants to Drill Down to'));
			return;
		}

		//Aggregate the rest of the Data into 'Other'
		for(AggregateResult SA :[Select Account__c, SUM(CY_Minus_1_Pax__c) CYM1Pax, SUM(YTD_Previous_Year_Departure_Pax__c) YTD, SUM(CY_Pax__c) CYPax, SUM(CY_Pax_Paid__c) CYPaxPaid, SUM(Departure_this_year_booked_last_year__c) BookedLast, SUM(CY_plus_1_Pax__c) CYP1Pax, SUM(CY_Minus_1_Sales__c) CYM1Val, SUM(YTD_Previous_Year_Departure_Value__c) YTDVal, SUM(CY_Sales__c) CYVal, SUM(CY_Value_Paid__c) CYValPaid, SUM(Departure_CY_Booked_Last_Value__c) BookedLastVal, SUM(CY_Plus_1_Sales__c) CYP1Val from Summary_analysis_2__c where Type__c = 'Business Unit - Consultant - Split Owner' AND Account__c = :BusinessUnit AND id not in : IdsAlreadyInList AND Active__c = TRUE GROUP BY Account__c]){
			ConsultAgg.add(new Aggregate (ConversionRate, PaxOrVal, false, SA, null, true, null, new Contact(lastName = 'Other'), null, null));
		}

		addIn(ConsultAgg);
		Consultants = true;
	}


	public void addSM(){
		//Remove old Drill Down
		if(DrillDown){
			removeDrillDown();
		}

		list<Aggregate> SMAgg = new list<Aggregate>();

		//Add in the Top X amount
		for(Summary_analysis_2__c SA : [Select ID, Account__c, owner.name, ownerID, CY_Minus_1_Pax__c, YTD_Previous_Year_Departure_Pax__c, CY_Pax__c, CY_Pax_Paid__c, Departure_this_year_booked_last_year__c, CY_plus_1_Pax__c, convertCurrency(CY_Minus_1_Sales__c), convertCurrency(YTD_Previous_Year_Departure_Value__c), convertCurrency(CY_Sales__c), convertCurrency(CY_Value_Paid__c), convertCurrency(Departure_CY_Booked_Last_Value__c), convertCurrency(CY_Plus_1_Sales__c)  from Summary_analysis_2__c where Type__c = 'Business Unit - YTD - By Owner' AND Account__c = :BusinessUnit AND Active__c = TRUE order by CY_Pax__c desc nulls last]){
			SMAgg.add(new Aggregate (ConversionRate, PaxOrVal, false, null, SA, true, null, null, SA.owner.name, SA.ownerID));
		}
		
		if(SMAgg.size() ==0){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.info,'No Sales Managers to Drill Down to'));
			return;
		}


		addIn(SMAgg);
		SMs = true;
	}


	public void addIn(list<Aggregate> AddInAgg){
		//Add in Brochures to current list
		list<Aggregate> AllCopy = new list<Aggregate>();
		AllCopy = AllAgg.clone();
		AllAgg = new list<Aggregate>();


		integer i = 0;
		for(Aggregate Agg: AllCopy){
			//Change current row to have the reverse drilldown
			if(i == CurrentRow + 1){
				Agg.UpDrillDown = true;
			}
			//Add in the drill down results
			else if(i == CurrentRow +2){
				//add grouped Header row
				Aggregate AggGrouped = new Aggregate (ConversionRate, PaxOrVal, false, null, null, false, null, null, null, null);
		        AggGrouped.GroupedHeaderRow = true;
		        AggGrouped.CY_VF = thisVSLast;
	        	AggGrouped.CYP1_VF = thisVSNext;
		        AggGrouped.HideDrillDown = true;
				AllAgg.add(AggGrouped);

				//Add sub header row
				Aggregate HeaderAgg = new Aggregate (ConversionRate, PaxOrVal, true, null, null, false, null, null, null, null);
		        HeaderAgg.HeaderRow = true;
		        HeaderAgg.HideDrillDown = true;
				AllAgg.add(HeaderAgg);
				AllAgg.addAll(AddInAgg);
				//insert blank row after subtotal row
				AllAgg.add(new Aggregate (ConversionRate, PaxOrVal, false, null, null, true, null, null, null, null));

			}
			i++;
			
			AllAgg.add(Agg);
		}
		
		//Set add on size so it can be removed later
		sizeOfAddOn = AddInAgg.size() + 3;
		LastCurrentRow = CurrentRow + 1;
		DrillDown = true;
	}


	public void changeValOrPax(){
		for(Aggregate Ag:AllAgg){
			if(Ag.ResultRow){
				Ag.switchBetweenPaxandVal(PaxOrVal);
			}
		}
	}

	public List<SelectOption> getOptions() {
        List<SelectOption> opt = new List<SelectOption>(); 
        opt.add(new SelectOption('pax','Show Pax Figures')); 
        opt.add(new SelectOption('val','Show Revenue Figures')); return opt; 
    }


}