//Aggregate class to hold Agency Prod Results
    public class Aggregate_AgencyProd implements Comparable
    {
    	//Group name columns
        public string GroupedByCode {get;set;}
        public string GroupedByName {get;set;}
        public string OrderByVal {get;set;}
        public string Type {get;set;}
        public string VarianceType {get;set;}
        
        //Current year values
        public integer CY_Pax {get;set;}
        public decimal CY_Value {get;set;}
        public string CY_ValueFormat {get;set;}

        //Current year minus one values
        public integer CYMOne_Pax {get;set;}
        public decimal CYMOne_Value {get;set;}
        public string CYMOne_ValueFormat {get;set;}

        //Current year minus 2 values
        public integer CYMTwo_Pax {get;set;}
        public decimal CYMTwo_Value {get;set;}
        public string CYMTwo_ValueFormat {get;set;}

        //Current year plus one values
        public integer CYPOne_Pax {get;set;}
        public decimal CYPOne_Value {get;set;}
        public string CYPOne_ValueFormat {get;set;}

        //Current year YTD values
        public integer YTD_CY_Pax {get;set;}
        public decimal YTD_CY_Val {get;set;}
        public string YTD_CY_ValFormat {get;set;}

        //Last year YTD values
        public integer YTD_CYM1_Pax {get;set;}
        public decimal YTD_CYM1_Val {get;set;}
        public string YTD_CYM1_ValFormat {get;set;}

        //Variance Values
        public string CY_VarienceValue {get;set;}
        public decimal CY_VariencePax {get;set;}
        public string CY_VariencePaxFormat {get;set;}

        //Signing of the Variances
        public boolean PaxNegative {get;set;}
        public boolean ValueNegative {get;set;}

        public Aggregate_AgencyProd(string GroupBy, string typ)
        {
        	YTD_CY_Pax = 0;
			YTD_CY_Val = 0.00;
            YTD_CY_ValFormat = '0.00';
			YTD_CYM1_Pax = 0;
			YTD_CYM1_Val = 0.00;
            YTD_CYM1_ValFormat = '0.00';

            CY_Pax = 0;
            CY_Value = 0.00;
            CY_ValueFormat = '0.00';
            CYMOne_Pax = 0;
            CYMOne_Value = 0.00;
            CYMOne_ValueFormat = '0.00';
            CYMTwo_Pax = 0;
            CYMTwo_Value = 0.00;
            CYMTwo_ValueFormat = '0.00';
            CYPOne_Pax = 0;
            CYPOne_Value = 0.00;
            CYPOne_ValueFormat = '0.00';

            CY_VariencePaxFormat = '0 (0.00%)';
            CY_VarienceValue = '0.00 (0.00%)';


            CY_VariencePax = 0;
            PaxNegative = false;
            ValueNegative = false;

            Type = typ;
            GroupedByCode = GroupBy;

            if(Type == 'Month'){
            	OrderByVal = GroupedByCode;
            	if(OrderByVal == '01'){
	            	GroupedByName = 'January';
	            }
	            else if(OrderByVal == '02'){
	            	GroupedByName = 'February';
	            }
	            else if(OrderByVal == '03'){
	            	GroupedByName = 'March';
	            }
	            else if(OrderByVal == '04'){
	            	GroupedByName = 'April';
	            }
	            else if(OrderByVal == '05'){
	            	GroupedByName = 'May';
	            }
	            else if(OrderByVal == '06'){
	            	GroupedByName = 'June';
	            }
	            else if(OrderByVal == '07'){
	            	GroupedByName = 'July';
	            }
	            else if(OrderByVal == '08'){
	            	GroupedByName = 'August';
	            }
	            else if(OrderByVal == '09'){
	            	GroupedByName = 'September';
	            }
	            else if(OrderByVal == '10'){
	            	GroupedByName = 'October';
	            }
	            else if(OrderByVal == '11'){
	            	GroupedByName = 'November';
	            }
	            else if(OrderByVal == '12'){
	            	GroupedByName = 'December';
	            }
	            else{
	            	GroupedByName = 'Total';
	            	OrderByVal = '13';
	            }
            }
            else if (Type == 'Brochure Group'){ 
                if(GroupedByCode == null){
                    GroupedByName = 'Other';
                    OrderByVal= 'zzzzz';
                }
                else if(GroupedByCode == 'Total'){
                    GroupedByName = 'Total';
                    OrderByVal= 'zzzzzz';
                }
                else{
                    GroupedByName = GroupedByCode;
                    OrderByVal = GroupedByCode;
                }
            }
        }

        public void CalculateValues(double conversionRate, string VarType){
            //Calculate the values in the correct currency
            decimal CY_Conv = (CY_Value*conversionRate).setScale(2);
            decimal CYMOne_Conv = (CYMOne_Value*conversionRate).setScale(2);
            decimal CYMTwo_Conv = (CYMTwo_Value*conversionRate).setScale(2);
            decimal CYPOne_Conv = (CYPOne_Value*conversionRate).setScale(2);
            decimal YTD_CY_Val_Conv = (YTD_CY_Val*conversionRate).setScale(2);
            decimal YTD_CYM1_Val_Conv = (YTD_CYM1_Val*conversionRate).setScale(2);

            //format the Values
            CY_ValueFormat = Reports_Common_Code.formatTheCurrency(CY_Conv, true);
            CYMOne_ValueFormat = Reports_Common_Code.formatTheCurrency(CYMOne_Conv, true);
            CYMTwo_ValueFormat = Reports_Common_Code.formatTheCurrency(CYMTwo_Conv, true);
            CYPOne_ValueFormat = Reports_Common_Code.formatTheCurrency(CYPOne_Conv, true);
            YTD_CY_ValFormat = Reports_Common_Code.formatTheCurrency(YTD_CY_Val_Conv, true);
            YTD_CYM1_ValFormat = Reports_Common_Code.formatTheCurrency(YTD_CYM1_Val_Conv, true);

            //Variances
            if(VarType == 'Next'){
            	CalcValueVariance(YTD_CY_Val_Conv, CYPOne_Conv);
            	CalcPaxVariance(YTD_CY_Pax, CYPOne_Pax);
            }
            else if(VarType == 'Last'){
            	CalcValueVariance(YTD_CYM1_Val_Conv, CY_Conv);
            	CalcPaxVariance(YTD_CYM1_Pax, CY_Pax);
            }
            
            //Calculate Value Varience 
            /*system.debug('***Values for Month = '+ GroupedByName);
            system.debug('CY_Conv = '+ CY_Conv);
            system.debug('CYMOne_Conv = '+ CYMOne_Conv);
            system.debug('CY_VarienceValue  = '+ CY_VarienceValue );
            system.debug('***End***');
            */
        }

        public void CalcValueVariance(decimal oldValue, decimal newValue){
            //system.debug(loggingLevel.ERROR,'Old Value = '+oldValue);
            //system.debug(loggingLevel.ERROR,'New Value = '+newValue);

        	//Calculate the difference for the Value
            decimal diff = newValue - oldValue;
            if(newValue >= oldValue){
                ValueNegative = false;
            }
            else{
                ValueNegative = true;
            }

            //Calculate Value varience 
            string CY_VarienceValDiff = Reports_Common_Code.formatTheCurrency(diff, !ValueNegative);
            //system.debug(loggingLevel.ERROR,'Difference = '+CY_VarienceValDiff);

            decimal VarianceValPercentage;
            if(oldValue > 0){
                VarianceValPercentage = (diff/oldValue)*100;
            }
            else{
                VarianceValPercentage = 0;
            }

            CY_VarienceValue = CY_VarienceValDiff + ' ('+ VarianceValPercentage.setScale(2) + '%)';
        }

        public void CalcPaxVariance(integer oldValue, integer newValue){
        	//Calculate Pax Count Varience
            CY_VariencePax = newValue - oldValue;
            if(newValue >= oldValue){
                PaxNegative = false;
            }
            else{
                PaxNegative = true;
            }

            decimal PaxVarPercentage;
            if(oldValue > 0){
                PaxVarPercentage = (CY_VariencePax/oldValue)*100;
            }
            else{
                PaxVarPercentage = 0;
            }

            
            CY_VariencePaxFormat = CY_VariencePax + ' ('+ PaxVarPercentage.setScale(2) + '%)';
        }

        //order by OrderValue
        public Integer compareTo(Object compareTo) {
			Aggregate_AgencyProd Agg = (Aggregate_AgencyProd) compareTo;
            if (OrderByVal == Agg.OrderByVal) return 0;
            if (OrderByVal > Agg.OrderByVal) return 1;
        	return -1; 
        }

    }