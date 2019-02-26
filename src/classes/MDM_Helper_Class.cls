public with sharing class MDM_Helper_Class {

    //***Class Variables***
    private string ObjectName;
    
    //***Properties***
    public Map <String, Schema.SObjectField> fieldMap{
        get{
            if(fieldMap == null){
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                fieldMap = gd.get(ObjectName).getDescribe().fields.getMap();
            }
            return fieldMap;
        }
        set;
    }
            

    public set<String> AllFieldsInObject 
    {
        get{
            if(AllFieldsInObject == null){
                AllFieldsInObject = new set<string>();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe();               
                    AllFieldsInObject.add(dfield.getname().toUpperCase());
                }  
                system.debug('Build Field Set for object ' + ObjectName + ' = ' + AllFieldsInObject);
            }
            return AllFieldsInObject;
        }
        set; 
    }

    public set<String> WritableFieldsInObject 
    {
        get{
            if(WritableFieldsInObject  == null){
                WritableFieldsInObject  = new set<string>();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe(); 
                    if(dfield.isUpdateable()){

                        WritableFieldsInObject.add(dfield.getname().toUpperCase());
                    }           
                }  
                system.debug('Build Field Set for object ' + ObjectName + ' = ' + WritableFieldsInObject);
            }
            return WritableFieldsInObject;
        }
        set; 
    }

    public static map<String, Schema.DisplayType> AccountWritableFieldsWithType 
    {
        get{
            if(AccountWritableFieldsWithType  == null){
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Map <String, Schema.SObjectField> fieldMap = gd.get('Account').getDescribe().fields.getMap();

                AccountWritableFieldsWithType  = new map<String, Schema.DisplayType>();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe(); 
                    if(dfield.isUpdateable()){
                        AccountWritableFieldsWithType.put(dfield.getname().toUpperCase(), dfield.getType());
                    }           
                }  
            }
            return AccountWritableFieldsWithType;
        }
        set; 
    }


    //*** Convert Master Bean fields to the Account datatype ***
    public static object setValue(string sourceField, object sourceValue, string targetField, object targetValueOld){
        object targetValue = targetValueOld;
        if(sourceValue != null){
            //String Type
            if(AccountWritableFieldsWithType.get(targetField.ToUppercase()).name() == 'String'){
                targetValue = sourceValue;
            }
            //Date Type
            else if(AccountWritableFieldsWithType.get(targetField.ToUppercase()).name() == 'Date'){
                object returnObj = ObjectToDate(sourceValue);
                if(returnObj != null) targetValue = returnObj;
            }
            else{
                targetValue = sourceValue;
            }
            return targetValue;
        }
        else{
            return null;
        }
    }


    //*** Convert String Object to Date Format ***
    public static object ObjectToDate(object sourceValue){
        string sourceValueString;
        object targetValue;
        try{
            sourceValueString = (string) sourceValue;
            if(sourceValueString.length() > 10){
                sourceValueString = sourceValueString.substring(0, 10);
            }
            if(sourceValueString.length() == 10){
                targetValue = date.valueOf(sourceValueString);
            }
        }
        catch(exception e){
            system.debug(sourceValueString + ' is not a valid date');
        }
        return targetValue;
    }


    //Constructor
    public MDM_Helper_Class(string objName){
        ObjectName = objName;
    }

    private static Pattern dissallowedCharsP 
    {
        get 
        {
            if(dissallowedCharsP == null)
            {
                dissallowedCharsP = Pattern.compile('[\\s\\p{Punct}´ªº’€£₤©®™℠]');
            }
            return dissallowedCharsP;
        }
        set;
    }

    public static String removeNull(String name){
    	if(name == null){
            return '';
        }
        else{
        	return name;
        }
    }

	public static String sanitiseName(String name){
        if(name == null || name == ''){
            return name;
        }
        
        String s = name.toUpperCase().replaceAll('[ÀÂÁÃ]','A').replaceAll('[ÉÈẼÊË]','E').replaceAll('[ÎÏÌÍĨ]','I').replaceAll('[ÔÓÒÕ]','O').replaceAll('[ÛÚÙŨ]','U').replaceAll('[Ñ]','N').replaceAll('[Ç]','C').replaceAll('[Ü]','UE').replaceAll('[ŒÖ]','OE').replaceAll('[ÆÄ]','AE');
        
        Matcher m = dissallowedCharsP.matcher(s);
        
        return m.replaceAll('');
    }

    public static String sanitiseAndRemoveCommonWordsName(String name){
        if(name == null || name == ''){
            return name;
        }
        
        String s = name.toUpperCase().replaceAll('[ÀÂÁÃ]','A').replaceAll('[ÉÈẼÊË]','E').replaceAll('[ÎÏÌÍĨ]','I').replaceAll('[ÔÓÒÕ]','O').replaceAll('[ÛÚÙŨ]','U').replaceAll('[Ñ]','N').replaceAll('[Ç]','C').replaceAll('[Ü]','UE').replaceAll('[ŒÖ]','OE').replaceAll('[ÆÄ]','AE');
        
        Matcher m = nameP.matcher(s);
        
        m = dissallowedCharsP.matcher(m.replaceAll(''));
        
        return m.replaceAll('');
    }

    public static String RemoveCommonWords(String name){
        if(name == null || name == ''){
            return name;
        }
        
        Matcher m = nameP.matcher(name);
        
        return m.replaceAll('');
    }

    private static Pattern nameP 
    {
        get 
        {
            if(nameP == null)
            {
                nameP = Pattern.compile('TRAVEL|AMERICAN|AMERICA|FLIGHT');
            }
            return nameP;
        }
        set;
    }

    /**
     * @description This will set the Business unit lookup and Brand lookup from the Business Unit external ID
     * @param BU_ExternalID_Field Name of the field that holds the business unit external ID
     * @param BU_Lookup_Field Name of the field that holds the Business Unit Lookup 
     * @param Brand_Lookup_Field Name of the field that holds the Brand Lookup 
     * @param sobjectList list of the Sobjects that will have the BU and Brands set
     */
    public static Map<id, Account> setBusinessUnit(string BU_ExternalID_Field, string BU_Lookup_Field, string Brand_Lookup_Field, list<sobject> sobjectList){
        set<string> BUExtIDs = new set<string>();
        set<id> BUIDs = new set<id>();

        //Get list of Business Unit IDs and External IDs from object
        for(sobject sobj : sobjectList){
            if(sobj.get(BU_Lookup_Field) != null){
                BUIDs.add((ID) sobj.get(BU_Lookup_Field));
            }
            else if(sobj.get(BU_ExternalID_Field)!= null){
                BUExtIDs.add((String) sobj.get(BU_ExternalID_Field) );
            }
        }

        //Get a list of Accounts from above IDs
        Map<id, Account> AccMap = new Map<id, Account>([select id, External_ID__c, parentID, Parent.name, parent.RecordType.developername, name, RecordType.developername from Account where External_ID__c in :BUExtIDs OR id in :BUIDs]);
        map<string, Account> ExtMap = new map<string, Account>();
        for(Account Acc : AccMap.values()){
            ExtMap.put(Acc.External_ID__c, Acc);
        }

        //Get brand from SellingCompanyID
        for(sobject sobj : sobjectList){
            if(sobj.get(BU_ExternalID_Field) != null){
                Account BU = ExtMap.get((String) sobj.get(BU_ExternalID_Field));
                if(BU != null){
                    if(BU.RecordType.developername == 'Selling_Company'){
                        sobj.put(BU_Lookup_Field, BU.ID);
                    }
                }
            }
            if(sobj.get(BU_Lookup_Field) != null && AccMap != null && Brand_Lookup_Field != null){
                ID BusinessUnitID = (ID) sobj.get(BU_Lookup_Field);
                Account BUAcc = AccMap.get(BusinessUnitID);

                if(BUAcc.parent.RecordType.developername == 'Brand'){
                    sobj.put(Brand_Lookup_Field, BUAcc.parentID);
                }
            }
        }

        return AccMap;
    }
}