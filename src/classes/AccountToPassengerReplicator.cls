/*
	Appirio Inc (c) 2016
	Leo Alves
	This class replicates data from account to passenger
*/
public class AccountToPassengerReplicator implements Queueable
{
	Set<Id> accountIds;
	public AccountToPassengerReplicator(Set<Id> accountIds)
	{
		this.accountIds = accountIds;
	}

	public void execute(QueueableContext context)
	{
		// identify potential accounts that need to be replicated - those with passenger records with tours in the future
		List<Passenger__c> passengersToUpdate = new List<Passenger__c>();
		for (Account a : Database.query(buildQuery()))
		{
			if (a.Passengers__r.size() > 0)
			{
				replicateDataToPassengers(a);
				passengersToUpdate.addAll(a.Passengers__r);
			}
		}
		if (passengersToUpdate.size() > 0)
			update passengersToUpdate;
	}

	// method to build query on fields that need to be replicated
	private String buildQuery()
	{
		// build query from account and children passengers
		return 'SELECT ' + AccountPassengerMappingHelper.getAccountFields() + ', (SELECT id FROM Passengers__r WHERE Status__c != \'CX\') ' +
											   'FROM Account WHERE ID IN: accountIds';
	}

	// simple method to make sure data is the same on parent and child objects
	private void replicateDataToPassengers(Account a)
	{
		for (Passenger__c p : a.Passengers__r)
		{
			p.Address_City__c 			= a.BillingCity;
			p.Address_Country__c 		= a.BillingCountry;
			p.Address_Line_1__c 		= a.BillingStreet;
			p.Address_Postcode__c		= a.BillingPostalCode;
			p.Address_Region__c 		= a.BillingState;
			p.Date_of_Birth__c			= a.PersonBirthdate;
			p.Email__c					= a.PersonEmail;
			p.Family_Name__c 			= a.LastName;
			p.First_Name__c				= a.FirstName;
			p.Middle_Name__c			= a.Middle_Name_or_Initials__pc;
			p.Mobile__c					= a.PersonMobilePhone;
			p.Gender__c					= a.Gender__c;
			p.Dietary_Requirements__c	= a.Special_Diet__c;
			p.City_Of_Birth__c			= a.Birth_City__c;
			p.Country_Of_Birth__c		= a.Birth_Country__c;
			p.Country_of_Issue__c		= a.Passport_Country_of_Issue__c;
			p.Nationality__c			= a.Nationality__c;
			p.Passport_Issue_Date__c	= a.Passport_issue_date__c;
			p.Passport_Expiry_Date__c	= a.Passport_expiry__c;
			p.Passport_number__c		= a.Passport_number__c;
		}
	}
}