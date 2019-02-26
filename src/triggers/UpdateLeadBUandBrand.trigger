trigger UpdateLeadBUandBrand on Lead (before insert,before update){
    
    //Create a list of Custom Settings from Business_Units__c. This grabs all data in the Custom Setting
    List<Business_Units__c> businessUnits = Business_Units__c.getAll().Values();
    //Create a Map that will be used to grab certain values from the Custom Setting record based on a field that is not the key (name field)
    Map<String, String> BUtoSC = new Map<String, String>();
    Map<String, String> BUtoCU = new Map<String, String>();
    Map<String, String> BUtoBR = new Map<String, String>();
    
    //This for loop iterates through the businessUnits List and for each value you add the Business Unit Id and the name to the Map BUtoSC
    for(integer i = 0; i < businessUnits.size(); i++){
        
        BUtoSC.put(businessUnits.get(i).Business_Unit_Id__c, businessUnits.get(i).Selling_Company_Code__c);
        BUtoCU.put(businessUnits.get(i).Business_Unit_Id__c, businessUnits.get(i).Currency__c);
        BUtoBR.put(businessUnits.get(i).Business_Unit_Id__c, businessUnits.get(i).Brand__c);
        
    }
    
    for(lead lead1:trigger.new){
        
        Business_Units__c BU = new Business_Units__c();
        
        //pull out the Business_Units__c record based on the Selling_Company_Code__c of the current lead
        if(lead1.Selling_Company_Code__c != '' && lead1.Selling_Company_Code__c != Null){
        
            BU = Business_Units__c.getInstance(lead1.Selling_Company_Code__c.toUpperCase());
        
        }
        
        String noSCC = '';
        
        //Make sure that there is a Selling_Company_Code__c on the lead, then make sure the corresponding Business_Units__c is not null
        if(lead1.Selling_Company_Code__c!=null && lead1.Selling_Company_Code__c!=''){
            
            if(BU != Null){
                
                //set the lead's Business Unit and Brand fields
                lead1.Business_Unit__c = BU.Business_Unit_Id__c;
                lead1.Brand__c = BU.Brand__c;
                
            }
            else{
                noSCC = 'Selling Company Not Found';
            }
      
        }
        //If the Selling_Company_Code__c is not filled in then see if the Business_Unit__c IS filled in
        if(lead1.Business_Unit__c != null && noSCC == 'Selling Company Not Found'){
      
            //Go into the Map and find the corresponding Name based on the Id of the Business_Unit__c
            String SC = BUtoSC.get(lead1.Business_Unit__c);
            String CU = BUtoCU.get(lead1.Business_Unit__c);
            String BR = BUtoBR.get(lead1.Business_Unit__c);
            //Make sure the search was successful and if it was then set the Selling_Company_Code__c of the lead
            if(SC != Null && SC != ''){
            
                lead1.Selling_Company_Code__c = SC;
                lead1.CurrencyISOCode = CU;
                lead1.Brand__c = BR;
                
            }
      
        }
        else if(lead1.Business_Unit__c != null && (lead1.Selling_Company_Code__c == '' || lead1.Selling_Company_Code__c == Null)){
      
            //Go into the Map and find the corresponding Name based on the Id of the Business_Unit__c
            String SC = BUtoSC.get(lead1.Business_Unit__c);
            String CU = BUtoCU.get(lead1.Business_Unit__c);
            String BR = BUtoBR.get(lead1.Business_Unit__c);
            //Make sure the search was successful and if it was then set the Selling_Company_Code__c of the lead
            if(SC != Null && SC != ''){
            
                lead1.Selling_Company_Code__c = SC;
                lead1.CurrencyISOCode = CU;
                lead1.Brand__c = BR;
                
            }
      
        }
        
        if(lead1.Selling_Company_Code__c != Null && lead1.Selling_Company_Code__c != ''){
        
            Business_Units__c BU2 = Business_Units__c.getInstance(lead1.Selling_Company_Code__c.toUpperCase());
            
            if(BU2 != Null){
            
                lead1.CurrencyISOCode = BU2.Currency__c;
            
            }
            
        }

    }

}