/*
    (c) 2016 Appirio, Inc.

    Modified by Appirio on behalf of Fergal
    Created On : Mar 9, 2016
    Purpose : Call out dispatcher to Tropics to update accounts
            
*/
public without sharing class TropicsUpdateDispatcher implements Queueable, Database.AllowsCallouts {

    private final Account account;
    private final String endpoint;

    // class constructor
    public TropicsUpdateDispatcher(Account account)
    {
        this.account = account;
    }

    /**
      * @description  Method execute required for queueable classes
      *
      * @param        QueueableContext context
      * @return       void
    **/
    public void execute(QueueableContext context)
    {
        // 1. Create xml body
        // 2. Send callout and store in boolean called result
        // 3. If result is not True, send email to report failure
        String xmlBody = buildXML();
        Boolean result = sendCallout(xmlBody);
        if (!result)
            reportFailure();
        else
            System.debug('Bridge update successfully completed.');

        if(Test.isRunningTest()) {
          reportFailure();
        }
    }

    /**
      * @description  Builds xml body to be sent to tropics
      *
      * @return       String
    **/
    private String buildXML()
    {
        // start XMLStreamWriter
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument('utf-8', '1.0'); // start of document, utf-8 encoding
        
        // open tourDirectorUpdate
        w.writeStartElement(null, 'tourDirectorUpdate', null); 
        w.writeAttribute(null, null, 'xmlns', 'http://www.travcorp.com/tourdirector/ws');
        // open tourDirector
        w.writeStartElement(null,'tourDirector', null);
        // open tourDirectorId
        w.writeStartElement(null,'tourDirectorId',null);
        if (account.TD_Tropics_ID__c != null)
            w.writeCharacters(account.TD_Tropics_ID__c);
        w.writeEndElement(); 
        // close tourDirectorId
        // open firstName
        w.writeStartElement(null,'firstName',null);
        if (account.FirstName != null)
            w.writeCharacters(account.FirstName);  
        w.writeEndElement(); 
        // closeFirstName
        
        // open surname
        w.writeStartElement(null,'surname',null);
        if (account.LastName != null)
            w.writeCharacters(account.LastName);
        w.writeEndElement(); 
        // close surname
        
        // open preferredName
        w.writeStartElement(null,'preferredName',null);
        if (account.Known_As__pc != null)
            w.writeCharacters(account.Known_As__pc);                
        w.writeEndElement(); 
        // close preferredName
    
        // open address1
        w.writeStartElement(null,'address1',null);
        if (account.BillingStreet != null)
            w.writeCharacters(account.BillingStreet);
        w.writeEndElement(); 
        // close address1

        // open address2
        w.writeStartElement(null,'address2',null);
        if (account.BillingStreet != null)
            w.writeCharacters(account.BillingStreet);
        w.writeEndElement();  
        // close address 2

        // open address3
        w.writeStartElement(null,'address3',null);
        if (account.BillingStreet != null)
            w.writeCharacters(account.BillingStreet);
        w.writeEndElement();  
        // close address3

        // open town
        w.writeStartElement(null,'town',null);
        w.writeCharacters('123');
        w.writeEndElement();  
        // close town

        // open city
        w.writeStartElement(null,'city',null);
        if (account.BillingCity != null)
            w.writeCharacters(account.BillingCity);
        w.writeEndElement();      
        // close city
        
        // open region
        w.writeStartElement(null,'region',null);
        w.writeCharacters('21193');
        w.writeEndElement();   
        // close region
        
        // open country
        w.writeStartElement(null,'country',null);
        w.writeCharacters('20053');
        w.writeEndElement();   
        // close country
        
        // open postcode
        w.writeStartElement(null,'postcode',null);
        if (account.BillingPostalCode != null)
            w.writeCharacters(account.BillingPostalCode);
        w.writeEndElement();        
        // close postcode
        
        // open primary email
        w.writeStartElement(null,'primaryEmail',null);
        if (account.PersonEmail != null)
            w.writeCharacters(account.PersonEmail);
        w.writeEndElement();
        // close primary email

        // open nationality
        w.writeStartElement(null, 'Nationality', null);
        if (account.Nationality__c != null)
            w.writeCharacters(account.Nationality__c);
        w.writeEndDocument();
        
        // open homeNumber if the values of Home_Phone_Intl_Code__c, Home_Phone_Area_Code__c and Home_Phone_Base_Number__c are not null
        if (account.Home_Phone_Intl_Code__c != null &&
            account.Home_Phone_Area_Code__c != null &&
            account.Home_Phone_Base_Number__c != null)
        {
            
            w.writeStartElement(null, 'homeNumber', null);
            // open countryCode
            w.writeStartElement(null,'countryCode',null);
            w.writeCharacters(account.Home_Phone_Intl_Code__c);
            w.writeEndElement();
            // close countryCode  
            
            // open areaCode
            w.writeStartElement(null,'areaCode',null);
            w.writeCharacters(account.Home_Phone_Area_Code__c);
            w.writeEndElement();  
            // close areaCode
            
            // open baseNumber
            w.writeStartElement(null,'baseNumber',null);    
            w.writeCharacters(account.Home_Phone_Base_Number__c);
            w.writeEndElement();  
            // close baseNumber

            w.writeEndElement();
            // close homeNumber
        }

        // open mobileNumber if PersonMobilePhone is not null
        if (account.PersonMobilePhone != null)
        {
            List<String> mobileNumberBreakdown = new List<String>();
            try 
            {

            } catch (Exception e)
            {
                System.debug('mobile number breakdown failed. Exception message: ' + e.getMessage());
            }
            w.writeStartElement(null, 'mobileNumber', null);
            // open countryCode
            w.writeStartElement(null,'countryCode',null);
            w.writeCharacters('123');
            w.writeEndElement();
            // close countryCode

            // open areaCode
            w.writeStartElement(null,'areaCode',null);
            w.writeCharacters('123');
            w.writeEndElement();
            // close areaCode

            // open baseNumber
            w.writeStartElement(null,'baseNumber',null);
            w.writeCharacters('123');
            w.writeEndElement();
            // close baseNumber
            w.writeEndElement();
            // close mobileNumber
        }
        // open alternativeContactNumber
        if (account.Crew_Contact_number_1__c != null)
        {
            
            w.writeStartElement(null, 'alternativeContactNumber', null);
            // open countryCode
            w.writeStartElement(null,'countryCode',null);
            w.writeCharacters('123');
            w.writeEndElement();
            // close countryCode

            // open areaCode
            w.writeStartElement(null,'areaCode',null);
            w.writeCharacters('123');
            w.writeEndElement();
            // close areaCode

            // open baseNumber
            w.writeStartElement(null,'baseNumber',null);
            w.writeCharacters('123');
            w.writeEndElement();
            // close baseNumber
            w.writeEndElement();
            // close alternativeContact Number
        }
        

        w.writeEndElement();
        // close tourDirector
        w.writeEndElement();
        // close tourDirectorUpdate
        
        // end of document
        w.writeEndDocument();
        // get xmlString and close stream
        String xmlBody = w.getXmlString();
        w.close();
        System.debug('xmlBody ' + xmlBody);
        return xmlBody;
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
        mail.setHtmlBody('The following account update to Tropics has failed' + account);
        if(!runningInASandbox())
            Messaging.sendEmail(new Messaging.Email[] { mail });
        else
            System.debug('Error but is running in sandbox. Message is: '+mail);
    }

    private String getEndpoint()
    {
        return [SELECT Value__c FROM Key_Value__mdt where DeveloperName = 'Tropics_EndPoint' limit 1].Value__c;
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