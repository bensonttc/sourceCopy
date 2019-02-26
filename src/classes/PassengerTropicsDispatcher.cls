/*
    (c) 2016 Appirio, Inc.

    Created By : Leo Alves
    Created On : Jun 20, 2016
    Purpose : Class to write back to tropics whenever a

*/
public class PassengerTropicsDispatcher implements Queueable, Database.AllowsCallouts {

	Passenger__c passenger;

	public PassengerTropicsDispatcher(Passenger__c passenger)
	{
		this.passenger = passenger;
	}

    public void execute(QueueableContext context){
    
    //26.07.06 Fergal McMenamin - Added if statement to stop write back where account has been flagged as a possible dupe
    	if (passenger.account__r.stop_tropics_write_back__c == FALSE){
        
        	{
				String xmlBody = generateXml();
				Boolean result = sendCallout(xmlBody);
				if (!result)
					reportFailure();
				else
					System.debug('Bridge update successfully completed.');

				if(!Test.isRunningTest())
				{
                    system.debug('Result of callout: '+result);
		  		    reportFailure();
				}
			}
    	}
    }
    
	private String generateXml()
	{
		String surname = passenger.Family_Name__c;
        String preferredName = passenger.Preferred_Name__c;
        String mobileNumber = passenger.Mobile__c;
        String email = passenger.Email__c;
        String address1 = passenger.Address_Line_1__c;
        String city = passenger.Address_City__c;
        String region = passenger.Address_Region__c;
        String postcode = passenger.Address_Postcode__c;
        String country = passenger.Address_Country__c;
        String middleName = passenger.Middle_Name__c;
        String homeCountryCode = passenger.Home_Phone_Intl_Code__c;
        String homeareaCode = passenger.Home_Phone_Area_Code__c;
        String homenumber = passenger.Home_Phone_Base_Number__c;
        String name = passenger.Emergency_Contact_Name__c;
        String relationship = passenger.Emergency_Contact_Relationship__c;
        String emergencycountryCode = passenger.Emergency_Contact_Intl__c;
        String emergencyareaCode = passenger.Emergency_Contact_Area__c;
        String emergencynumber = passenger.Emergency_Contact_Base__c;
        String uniqueCustomerId = passenger.Booking_Passenger__r.Client_ID__c;
        DateTime lastModifiedDateTime = passenger.LastModifiedDate;
        String lastModified = lastModifiedDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss.sss');
        
        // 25.07.16 Fergal McMenamin - hardcoding value for this field until it's no longer required by the bridge
        String revisionId = 'pleaseIgnoreMe';
        
        String clientId = passenger.Booking_Passenger__r.Client_ID__c;
        String bookingId = passenger.Booking_Number__c;
        String sellingCompanyName = passenger.Selling_company_code__c;

        Dom.Document xmlDoc = new Dom.Document();
        dom.XmlNode synchroniseCustomer = xmlDoc.createRootElement('synchroniseCustomer', 'http://www.travcorp.com/habs/customer/sync/ws/domain', '');
        dom.XmlNode customer = synchroniseCustomer.addChildElement('customer', null, null);

        dom.XmlNode clientProfile = customer.addChildElement('clientProfile', null, null);
        
        //createNotNullChildElement(clientProfile, 'surname', surname);
        createNotNullChildElement(clientProfile, 'middleName', middleName);
        createNotNullChildElement(clientProfile, 'preferredName', preferredName);
        createNotNullChildElement(clientProfile, 'mobileNumber', mobileNumber);
        createNotNullChildElement(clientProfile, 'email', email);
        createNotNullChildElement(clientProfile, 'address1', address1);
        createNotNullChildElement(clientProfile, 'city', city);
        createNotNullChildElement(clientProfile, 'region', region);
        createNotNullChildElement(clientProfile, 'postcode', postcode);
        createNotNullChildElement(clientProfile, 'country', country);
		

        dom.XmlNode preferredPhoneNumber = clientProfile.addChildElement('preferredPhoneNumber', null, null);
        createNotNullChildElement(preferredPhoneNumber, 'countryCode', homeCountryCode);
        createNotNullChildElement(preferredPhoneNumber, 'areaCode', homeareaCode);
        createNotNullChildElement(preferredPhoneNumber, 'number', homenumber);

        dom.XmlNode emergencyContact = customer.addChildElement('emergencyContact', null, null);
        createNotNullChildElement(emergencyContact, 'name', name);
        createNotNullChildElement(emergencyContact, 'relationship', relationship);

        dom.XmlNode phoneNumber = emergencyContact.addChildElement('phoneNumber', null, null);
        createNotNullChildElement(phoneNumber, 'countryCode', emergencyCountryCode);
        createNotNullChildElement(phoneNumber, 'areaCode', emergencyareaCode);
        createNotNullChildElement(phoneNumber, 'number', emergencynumber);

        dom.XmlNode metadata = synchroniseCustomer.addChildElement('metadata', null, null);
        createNotNullChildElement(metadata, 'uniqueCustomerId', uniqueCustomerId);
        createNotNullChildElement(metadata, 'revisionId', revisionId);
        createNotNullChildElement(metadata, 'lastModified', lastModified);

        dom.XmlNode passengers = metadata.addChildElement('passengers', null, null);
        dom.XmlNode passenger = passengers.addChildElement('passenger', null, null);

        createNotNullChildElement(passenger, 'clientId', clientId);
        createNotNullChildElement(passenger, 'bookingId', bookingId);
        createNotNullChildElement(passenger, 'sellingCompanyName', sellingCompanyName);

        String xml = xmlDoc.toXmlString();
        System.debug(xml);
        return xml;
	}
    
    private void createNotNullChildElement(dom.XmlNode node, String elementName, String value) {
        String elementValue = '';
        if (value != null) {
            elementValue = value;
        }
        
        node.addChildElement(elementName, null, null).addTextNode(elementValue);
    }

	/**
      * @description  Sends callout to update account in tropics
      *
      * @param        String xmlBody
      * @return       boolean
    **/
    private Boolean sendCallout(String xmlBody)
    {
        Http protocol;
        String requestBody;
        HttpRequest request;
        HttpResponse response;

        request = new HttpRequest();
        request.setHeader('x-api-key', getKey());
        request.setHeader('Content-Type', 'application/xml');
        request.setMethod('POST');
        request.setEndpoint(getEndpoint());
        request.setBody(xmlBody);
        protocol = new Http();
        response = protocol.send(request);
        System.debug('response: ' + response);
        if (response.getStatus() == 'Accepted')
            return true;
        else
            return false;
    }

    /**
      * @description  Sends emails to report failures
      *
      * @return       boolean
    **/
    private void reportFailure()
    {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { getFailureEmails() });
            mail.setSubject('Topics Callout Failure');
            mail.setHtmlBody('The following update to Tropics has failed ' + passenger);
            if(!runningInASandbox())
                Messaging.sendEmail(new Messaging.Email[] { mail });    
            else
                System.debug('Error but is running in sandbox. Message is: '+mail);
    }

    private String getEndpoint()
    {
        return [SELECT Value__c FROM Key_Value__mdt where DeveloperName = 'Tropics_EndPoint_Passenger' limit 1].Value__c;
    }

    private String getKey()
    {
        return [SELECT Value__c FROM Key_Value__mdt where DeveloperName = 'Tropics_API_Key' limit 1].Value__c;
    }

    private String getFailureEmails()
    {
        return [SELECT Value__c FROM Key_Value__mdt where DeveloperName = 'Tropics_Failure_Emails' limit 1].Value__c;
    }

    public static Boolean runningInASandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}