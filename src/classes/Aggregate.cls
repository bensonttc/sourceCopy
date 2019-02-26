//Aggregate inner class to hold results - am hard coding columns for now
    public class Aggregate implements Comparable
    {
        //Object Names and IDs
        public id AccId {get;set;}
        public Account Acc {get; set;}
        public Account OtherAccount {get; set;}
        public Contact Consultant {get; set;}
        public string RecordName {get; set;}
        public string RecordID {get; set;}
        public string Brand {get; set;}
        public string BUorder {get; set;}

        //Type of row
        public boolean HeaderRow {get; set;}
        public boolean ResultRow {get; set;}
        public boolean UltimateHeaderRow {get; set;}
        public boolean subTotalRow {get; set;}
        public boolean HideDrillDown {get;set;}
        public boolean UpDrillDown {get;set;}
        public boolean GrandTotalRow {get;set;}
        public boolean GroupedHeaderRow {get;set;}
        public boolean BlankRow {get;set;}
        

        //Misc
        public static string SortBy {get;set;}
        public decimal ConversionRate {get;set;}
        public integer rowNum {get;set;}

        //Pax Results Storage Columns 
        public decimal CYM1Pax {get;set;}
        public decimal YTDPax {get;set;}
        public decimal CYPax {get;set;}
        public decimal CYPaxPaid {get;set;}
        public decimal BookedLastPax {get;set;}
        public decimal CYP1Pax {get;set;}

        //Value Results Storage Columns 
        public decimal CYM1Val {get;set;}
        public decimal YTDVal {get;set;}
        public decimal CYVal {get;set;}
        public decimal CYValPaid {get;set;}
        public decimal BookedLastVal {get;set;}
        public decimal CYP1Val {get;set;}


        //VF Columns 
        public string CYM1_VF {get;set;}
        public string YTD_VF {get;set;}
        public string CY_VF {get;set;}
        public string CYVariance_VF {get;set;}
        public string CYPaid_VF {get;set;}
        public string BookedLast_VF {get;set;}
        public string CYP1_VF {get;set;}
        public string CYP1Variance_VF {get;set;}


        public Aggregate(decimal conv, string PaxOrVal, Boolean HeaderRow, AggregateResult ar, Sobject SA, boolean tHideDrillDown, Account other, Contact con, string recName, string recID)
        {
            CYM1Pax = 0.00;
            YTDPax = 0.00;
            CYPax = 0.00;
            CYPaxPaid = 0.00;
            BookedLastPax = 0.00;
            CYP1Pax = 0.00;
            CYM1Val = 0.00;
            YTDVal = 0.00;
            CYVal = 0.00;
            CYValPaid = 0.00;
            BookedLastVal = 0.00;
            CYP1Val = 0.00;


            ConversionRate = conv;
            ResultRow = false;
            //Aggregated Fields
            if(ar != null){
                //Store Value results

                //Aggregate results for currency fields are in Org default - need to convert to user
                CYM1Val = Reports_Common_Code.ConvertThis(ConversionRate, (decimal) ar.get('CYM1Val'));
                YTDVal = Reports_Common_Code.ConvertThis(ConversionRate, (decimal) ar.get('YTDVal'));
                CYVal = Reports_Common_Code.ConvertThis(ConversionRate, (decimal) ar.get('CYVal'));
                CYValPaid = Reports_Common_Code.ConvertThis(ConversionRate, (decimal) ar.get('CYValPaid'));
                BookedLastVal = Reports_Common_Code.ConvertThis(ConversionRate, (decimal) ar.get('BookedLastVal'));
                CYP1Val = Reports_Common_Code.ConvertThis(ConversionRate, (decimal) ar.get('CYP1Val'));

                //Store Pax count results
                CYM1Pax = Reports_Common_Code.SetNullToZero((decimal) ar.get('CYM1Pax'));
                YTDPax = Reports_Common_Code.SetNullToZero((decimal)  ar.get('YTD'));
                CYPax = Reports_Common_Code.SetNullToZero((decimal)  ar.get('CYPax'));
                CYPaxPaid = Reports_Common_Code.SetNullToZero((decimal)  ar.get('CYPaxPaid'));
                BookedLastPax = Reports_Common_Code.SetNullToZero((decimal)  ar.get('BookedLast'));
                CYP1Pax = Reports_Common_Code.SetNullToZero((decimal)  ar.get('CYP1Pax'));
                
                ResultRow = true;
                switchBetweenPaxandVal(PaxOrVal);


                //Group By Fields - same for both Pax and Val
                try{
                    AccId = (string) ar.get('Account__c');
                }
                catch(exception e){
                    AccId = null;
                }

                try{
                    Brand = (string) ar.get('Brand__c');
                }
                catch(exception e){
                    Brand = null;
                }
            }
            else if(SA != null){
                //Store Value Results
                //results straight from Summary analysis are in the correct currency (because the convertCurrency() in query)
                CYM1Val =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_Minus_1_Sales__c'));
                YTDVal =  Reports_Common_Code.SetNullToZero((decimal) SA.get('YTD_Previous_Year_Departure_Value__c'));
                CYVal =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_Sales__c'));
                CYValPaid =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_Value_Paid__c'));
                BookedLastVal =  Reports_Common_Code.SetNullToZero((decimal) SA.get('Departure_CY_Booked_Last_Value__c'));
                CYP1Val =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_Plus_1_Sales__c'));

                //Store Pax count results
                CYM1Pax =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_Minus_1_Pax__c'));
                YTDPax =  Reports_Common_Code.SetNullToZero((decimal) SA.get('YTD_Previous_Year_Departure_Pax__c'));
                CYPax =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_Pax__c'));
                CYPaxPaid =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_Pax_Paid__c'));
                BookedLastPax =  Reports_Common_Code.SetNullToZero((decimal) SA.get('Departure_this_year_booked_last_year__c'));
                CYP1Pax =  Reports_Common_Code.SetNullToZero((decimal) SA.get('CY_plus_1_Pax__c'));

                ResultRow = true;
                switchBetweenPaxandVal(PaxOrVal);

            }
            else if(HeaderRow){
                CYM1_VF = 'Last Year';
                YTD_VF = 'Last YTD';
                CY_VF ='This Year';
                CYVariance_VF = 'Variance';
                CYPaid_VF = 'Actual Paid';
                BookedLast_VF = 'This YTD';
                CYP1_VF = 'Next year';
                CYP1Variance_VF = 'Variance';
            }
            else{
                CYM1_VF =  '';
                YTD_VF =  '';
                CY_VF =  '';
                CYVariance_VF =  '';
                CYPaid_VF =  '';
                BookedLast_VF =  '';
                CYP1_VF =  '';
                CYP1Variance_VF =  '';
            }
            

            //Input Objects
            OtherAccount = other;
            Consultant = con;
            
            
            RecordName = Recname;
            RecordID = RecID;


            //Extras
            rowNum = 0;
        	HideDrillDown = tHideDrillDown;
            HeaderRow = false;
            UltimateHeaderRow = false;
            subTotalRow = false;
            GrandTotalRow = false;
            GroupedHeaderRow = false;
            UpDrillDown = false;
            BlankRow = false;
        }

        public void switchBetweenPaxandVal(string PaxOrVal){
            //Switch to Values
            if(PaxOrVal == 'val'){
                FormatAndCalcVar(PaxOrVal, CYM1Val, YTDVal, CYVal, CYValPaid, BookedLastVal, CYP1Val);
            }
            //switch to Pax count
            else if (PaxOrVal == 'pax'){
                FormatAndCalcVar(PaxOrVal, CYM1Pax, YTDPax, CYPax, CYPaxPaid, BookedLastPax, CYP1Pax);
            }
        }

        public void FormatAndCalcVar(string PaxOrVal, decimal CYM1_both, decimal YTD_both, decimal CY_both, decimal CYPaid_both, decimal BookedLast_both, decimal CYP1_both){
            //Current Year variance Calculated
            if(YTD_both > 0){
                CYVariance_VF = (((CY_both - YTD_both) / YTD_both) * 100).setScale(2).format() + '%';
            }
            else{
                CYVariance_VF = '0.0%';
            }
            
            //Next Year variance Calculated
            if(BookedLast_both > 0){
                CYP1Variance_VF = (((CYP1_both - BookedLast_both) / BookedLast_both) * 100).setScale(2).format() + '%';
            }
            else{
                CYP1Variance_VF = '0.0%';
            }

            //Results formatted into String
            if(PaxOrVal == 'pax'){
                CYM1_VF = CYM1_both.intValue().format();
                YTD_VF = YTD_both.intValue().format();
                CY_VF = CY_both.intValue().format();
                CYPaid_VF = CYPaid_both.intValue().format();
                BookedLast_VF = BookedLast_both.intValue().format();
                CYP1_VF = CYP1_both.intValue().format();
            }
            else{
                CYM1_VF = Reports_Common_Code.formatTheCurrency(CYM1_both, true);
                YTD_VF = Reports_Common_Code.formatTheCurrency(YTD_both, true);
                CY_VF = Reports_Common_Code.formatTheCurrency(CY_both, true);
                CYPaid_VF = Reports_Common_Code.formatTheCurrency(CYPaid_both, true);
                BookedLast_VF = Reports_Common_Code.formatTheCurrency(BookedLast_both, true);
                CYP1_VF = Reports_Common_Code.formatTheCurrency(CYP1_both, true);
            }
            
        }

        //order by Acc name
        public Integer compareTo(Object compareTo) {
        	if(SortBy == 'ByAccount'){
				Aggregate Agg = (Aggregate) compareTo;
	            if (Acc.name == Agg.Acc.name) return 0;
	            if (Acc.name > Agg.Acc.name) return 1;
            	return -1; 
        	}
        	else if(SortBy == 'ByName'){
        		Aggregate Agg = (Aggregate) compareTo;
                if(RecordName == 'Other') return 1; //put Other last
                if(RecordName == Agg.RecordName) return 0;
	            if (RecordName > Agg.RecordName) return 1;
            	return -1; 
        	}
            else if(SortBy == 'ByCYPax'){
                Aggregate Agg = (Aggregate) compareTo;
                if (CYPax == Agg.CYPax) return 0;
                if (CYPax < Agg.CYPax) return 1;
                return -1; 
            }
            else if(SortBy == 'ByBU'){
                Aggregate Agg = (Aggregate) compareTo;
                if (BUorder == Agg.BUorder) return 0;
                if (BUorder > Agg.BUorder) return 1;
                return -1; 
            }
        	return -1;
        }
    }