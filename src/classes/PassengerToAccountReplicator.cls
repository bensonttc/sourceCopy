/*
  Appirio Inc (c) 2016
  Leo Alves
  This class replicates data from passenger to account
*/
public class PassengerToAccountReplicator implements Queueable
{

  Set<Id> passengerIds;
  public PassengerToAccountReplicator(Set<Id> passengerIds)
  {
    this.passengerIds = passengerIds;
  }

  public void execute(QueueableContext context)
  {
    List<Account> accountsToUpdate = new List<Account>();
    for (Passenger__c p : Database.query(buildQuery()))
    {
      System.debug('p ' + p);
      System.debug('a ' + p.Account__c);
      if (p.Account__c != null)
      {
        Account a = new Account(Id = p.Account__c);
        updateAccountFields(p, a);
        accountsToUpdate.add(a);
      }
    }
    if (accountsToUpdate.size() > 0)
      update accountsToUpdate;
  }

  // method to build query on fields that need to be replicated
  private String buildQuery()
  {
    // build query from account and children passengers
    return 'SELECT ' + AccountPassengerMappingHelper.getPassengerFields() + ' FROM Passenger__c WHERE ID IN: passengerIds';
  }

  private void updateAccountFields(Passenger__c p, Account a)
  {
    a.BillingCity           = p.Address_City__c;
    a.BillingCountry        = p.Address_Country__c;
    a.BillingStreet          = p.Address_Line_1__c;
    a.BillingPostalCode        = p.Address_Postcode__c;
    a.BillingState          = p.Address_Region__c;
    a.PersonBirthdate        = p.Date_of_Birth__c;
    a.PersonEmail          = p.Email__c;
    a.LastName            = p.Family_Name__c;
    a.FirstName            = p.First_Name__c;
    a.Middle_Name_or_Initials__pc  = p.Middle_Name__c;
    a.PersonMobilePhone        = p.Mobile__c;
    a.Gender__c            = p.Gender__c;
    a.Special_Diet__c        = p.Dietary_Requirements__c;
    a.Birth_City__c          = p.City_Of_Birth__c;
    a.Birth_Country__c        = p.Country_Of_Birth__c;
    a.Passport_Country_of_Issue__c  = p.Country_of_Issue__c;
    a.Nationality__c        = p.Nationality__c;
    a.Passport_Issue_Date__c    = p.Passport_Issue_Date__c;
    a.Passport_expiry__c      = p.Passport_Expiry_Date__c;
    a.Passport_number__c      = p.Passport_number__c;
  }
}