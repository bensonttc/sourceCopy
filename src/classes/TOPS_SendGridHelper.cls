//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_SendGridHelper
// Description: Helper class for shared methods related to SendGrid
//
// 6th February 2016   Leo Alves              Original
// 9th February 2016   Hemendra Singh Bhati   Modified (Task # T-471567) - Please see the task description for more details.
//
public without sharing class TOPS_SendGridHelper {
  /**
  * @description  This method extracts SendGrid API credentials from custom metadata type API named "SendGrid_API_Credentials__mdt".
  *
  * @param        void
  * @return       SendGridCredentials
  */
  public static SendGridCredentials getCredentials() {
    SendGridCredentials credentials = new SendGridCredentials();
    for(SendGrid_API_Credentials__mdt theConfigRecord : [SELECT DeveloperName, Value__c FROM SendGrid_API_Credentials__mdt]) {
      if(theConfigRecord.DeveloperName.equalsIgnoreCase('API_USER')) {
        credentials.username = theConfigRecord.Value__c;
      }
      else if(theConfigRecord.DeveloperName.equalsIgnoreCase('API_KEY')) {
        credentials.key = theConfigRecord.Value__c;
      }
    }
    return credentials;
  }

  /**
  * @description  This method is used to get username and password of SendGrid API for the provided brand name.
  *
  * @param        String brandName
  * @return       SendGridCredentials
  */
  public static SendGridCredentials getCredentials(String brandName) {
    SendGridCredentials credentials = new SendGridCredentials();
    String brandNameFilter = brandName;
    brandNameFilter = brandNameFilter.replace(' ', '_') + '%';
    System.debug('credentials + ' + brandName + ' filter ' + brandNameFilter);
    for(SendGrid_API_Credentials__mdt theConfigRecord : [SELECT DeveloperName, Value__c FROM SendGrid_API_Credentials__mdt WHERE DeveloperName LIKE :brandNameFilter]) {
      if(theConfigRecord.DeveloperName.equalsIgnoreCase(brandName + '_User')) {
        credentials.username = theConfigRecord.Value__c;
      }
      else if(theConfigRecord.DeveloperName.equalsIgnoreCase(brandName + '_Key')) {
        credentials.key = theConfigRecord.Value__c;
      }
    }
    return credentials;
  }

  /**
  * @description  This method is used to determine end point URL for the provided method name.
  *
  * @param        String methodName
  * @return       String theEndPointURL
  */
  public static String getEndPoint(String methodName) {
    String theEndPointURL = '';
    for(SendGrid_API_Credentials__mdt theConfigRecord : [SELECT Value__c FROM SendGrid_API_Credentials__mdt WHERE DeveloperName = :methodName]) {
      theEndPointURL = theConfigRecord.Value__c;
    }
    return theEndPointURL;
  }

  // SendGridCredentials Wrapper Class.
  public class SendGridCredentials {
    public String username { get; set; }
    public String key { get; set; }
  }
}