/*
	Appirio Inc (c) 2016
	Leo Alves
	Helper class for Account and Passenger Data Replication
*/
public with sharing class AccountPassengerMappingHelper {

	public static String getAccountFields()
	{
		return 'BillingCity, BillingCountry, BillingStreet, BillingPostalCode, BillingState, PersonBirthdate, PersonEmail, FirstName, LastName, Middle_Name_or_Initials__pc, PersonMobilePhone, Gender__c, Age__pc, Salutation, Birth_Country__c, Special_Diet__c, Birth_City__c, Passport_Country_of_Issue__c, Nationality__c, Passport_issue_date__c, Passport_expiry__c, Passport_number__c,Emergency_Contact_Intl__c,Emergency_Contact_Area__c,Emergency_Contact_Base__c,Emergency_Contact_Name__c,Emergency_Contact_Relationship__c';
	}

	public static String getPassengerFields()
	{
		return 'Account__c, Address_City__c, Address_Country__c, Address_Line_1__c, Address_Postcode__c, Address_Region__c, Date_of_Birth__c, Email__c, Family_Name__c, First_Name__c, Middle_Name__c, Mobile__c, Gender__c, Dietary_Requirements__c, City_Of_Birth__c, Country_Of_Birth__c, Country_of_Issue__c, Nationality__c, Passport_Issue_Date__c, Passport_Expiry_Date__c, Passport_number__c,Emergency_Contact_Intl__c,Emergency_Contact_Area__c,Emergency_Contact_Base__c,Emergency_Contact_Name__c,Emergency_Contact_Relationship__c';
	}
}