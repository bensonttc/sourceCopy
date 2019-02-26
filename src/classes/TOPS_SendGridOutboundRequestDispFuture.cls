//
// (c) 2017 Appirio, Inc.
//
// Apex Class Name: TOPS_SendGridOutboundRequestDispFuture
// Description: This apex class integrates with SendGrid API to send mass emails.
//
// 22th June 2017   Abhishek Saxena     Original (T-624297)

public without sharing class TOPS_SendGridOutboundRequestDispFuture {
  // Private Constants.
  private static final String ENCODING = 'UTF-8';
  private static final String DEFAULT_BRAND_NAME = 'Trafalgar';

  // Private Data Members.
  private static String API_URL;
  private static String API_USER;
  private static String API_KEY;
  private static Boolean sendErrorEmail;
  // Public Data Members.
  public static Boolean status { get; set; }

  // The Constructor.
  public TOPS_SendGridOutboundRequestDispFuture(List<TOPS_EmailWrapper> emailsToProcess) {
      // Sending Emails Using SendGrid API.
      List<String> emailsToProcessString = new List<String>();
      for(TOPS_EmailWrapper wrapper : emailsToProcess){
          emailsToProcessString.add(JSON.serialize(wrapper));
      //status = this.sendEmails(emailsToProcessString);
    }
    sendEmails(emailsToProcessString);
  }

  @future(callout=true)
  public static void sendEmails(List<String> emailsToProcessString){
     // Extracting SendGrid API End Point From Custom Metadata Type API Named "SendGrid_API_Credentials__mdt".
    API_URL = TOPS_SendGridHelper.getEndPoint('MailSend');
    System.debug('TRACE: TOPS_SendGridOutboundRequestDispFuture API_URL = '+API_URL);
    // Validating API URL.
    if(String.isBlank(API_URL)) {
      status = false;
      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - Constructor - Error - SendGrid API End Point URL Not Properly Configured.');
      return;
    }
     List<TOPS_EmailWrapper> emailsToProcess = new List<TOPS_EmailWrapper>();
     for(String joinedString : emailsToProcessString){
         TOPS_EmailWrapper wrapper = new TOPS_EmailWrapper();
         wrapper = (TOPS_EmailWrapper) JSON.deserialize(joinedString, TOPS_EmailWrapper.class);
         emailsToProcess.add(wrapper);
     }
    system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - emailsToProcess - ' + emailsToProcess);
    if(emailsToProcess == null) {
      return;
    }

    Boolean theResult = true;
    try {
      // Sending Emails Using SendGrid API.
      if(emailsToProcess.size() > 0) {
        String status;
        Http protocol;
        String requestBody;
        HttpRequest request;
        HttpResponse response;
        String pdfAttachment;
        String theBrandName;
        TOPS_SendGridHelper.SendGridCredentials credentialsWrapper;
        for(TOPS_EmailWrapper wrapper : emailsToProcess) {
          system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - wrapper - ' + wrapper);

          // Extracting SendGrid API Access Details From Custom Metadata Type API Named "SendGrid_API_Credentials__mdt".
          theBrandName = String.isNotBlank(wrapper.brand) ? wrapper.brand.trim().replace(' ','_') : DEFAULT_BRAND_NAME;
          credentialsWrapper = TOPS_SendGridHelper.getCredentials(theBrandName);
          if(String.isNotBlank(credentialsWrapper.username) && String.isNotBlank(credentialsWrapper.key)) {
            API_USER = credentialsWrapper.username;
            API_KEY = credentialsWrapper.key;
          }
          else {
            system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - Brand Name Not Configured - ' + theBrandName);
            theResult = false;
            continue;
          }

          // Processing Email Wrapper.
          if(
            String.isNotBlank(API_USER) &&
            String.isNotBlank(API_KEY) &&
            String.isNotBlank(wrapper.toEmail) &&
            String.isNotBlank(wrapper.emailSubject) &&
            String.isNotBlank(wrapper.emailBody)
          ) {
            // Data Boundary.
            String boundary = '----------------------------741e90d31eff';

            // Building Header.
            String header = '';
            header += '--' + boundary + '\r\n';
            header += 'Content-Disposition: form-data; name="api_user"\r\n\r\n' + API_USER + '\r\n';
            header += '--' + boundary + '\r\n';
            header += 'Content-Disposition: form-data; name="api_key"\r\n\r\n' + API_KEY + '\r\n';
            header += '--' + boundary + '\r\n';

            // Processing TO Emails.
            String[] toEmails = wrapper.toEmail.trim().split(',');
            if(toEmails.size() > 1) {
              for(String toEmail : toEmails) {
                header += 'Content-Disposition: form-data; name="to[]"\r\n\r\n' + toEmail + '\r\n';
                header += '--' + boundary + '\r\n';
              }
            }
            else {
              header += 'Content-Disposition: form-data; name="to"\r\n\r\n' + wrapper.toEmail + '\r\n';
              header += '--' + boundary + '\r\n';
            }

            // Processing CC Emails.
            if(wrapper.cc != null) {
              String[] ccEmails = wrapper.cc.trim().split(',');
              if(ccEmails.size() > 1) {
                for(String ccEmail : ccEmails) {
                  header += 'Content-Disposition: form-data; name="cc[]"\r\n\r\n' + ccEmail + '\r\n';
                  header += '--' + boundary + '\r\n';
                }
              }
              else {
                header += 'Content-Disposition: form-data; name="cc"\r\n\r\n' + wrapper.cc + '\r\n';
                header += '--' + boundary + '\r\n';
              }
            }

            // Processing BCC Emails.
            if(wrapper.bcc != null) {
              String[] bccEmails = wrapper.bcc.trim().split(',');
              if(bccEmails.size() > 1) {
                for(String bccEmail : bccEmails) {
                  header += 'Content-Disposition: form-data; name="bcc[]"\r\n\r\n' + bccEmail + '\r\n';
                  header += '--' + boundary + '\r\n';
                }
              }
              else {
                header += 'Content-Disposition: form-data; name="bcc"\r\n\r\n' + wrapper.bcc + '\r\n';
                header += '--' + boundary + '\r\n';
              }
            }

            header += 'Content-Disposition: form-data; name="from"\r\n\r\n' + wrapper.fromEmail + '\r\n';
            header += '--' + boundary + '\r\n';
            header += 'Content-Disposition: form-data; name="replyto"\r\n\r\n' + wrapper.replyTo + '\r\n';
            header += '--' + boundary + '\r\n';
            header += 'Content-Disposition: form-data; name="subject"\r\n\r\n' + wrapper.emailSubject + '\r\n';
            header += '--' + boundary + '\r\n';
            header += 'Content-Disposition: form-data; name="text"\r\n\r\n' + wrapper.emailBody + '\r\n';
            header += '--' + boundary + '\r\n';
            header += 'Content-Disposition: form-data; name="html"\r\n\r\n' + wrapper.emailBody + '\r\n';

            String footer = '--' + boundary + '--';
            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
            while(headerEncoded.endsWith('=')) {
              header += ' ';
              headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
            }

            String attachmentsStr = '';
            String lastPrepend = '';
            if(wrapper.attachments != null && wrapper.attachments.size() > 0) {
              for(String fileName : wrapper.attachments.keySet()) {
                Blob fileBlob = wrapper.attachments.get(fileName);
                String fHeader = lastPrepend + '--' + boundary + '\r\n';
                fHeader += 'Content-Disposition: form-data; name="files[' + filename + ']"; filename="' + filename + '"\r\nContent-Type: application/octet-stream';

                String fHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(fheader + '\r\n\r\n'));
                while(fHeaderEncoded.endsWith('=')) {
                  fHeader += ' ';
                  fHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(fHeader + '\r\n\r\n'));
                }

                String fbodyEncoded = fileBlob != null ? EncodingUtil.base64Encode(fileBlob) : '';
                if(String.isNotBlank(fbodyEncoded)) {
                  String last4Bytes = fbodyEncoded.substring(fbodyEncoded.length() - 4, fbodyEncoded.length());
                  if(last4Bytes.endsWith('==')) {
                    last4Bytes = last4Bytes.substring(0, 2) + '0K';
                    fBodyEncoded = fbodyEncoded.substring(0, fbodyEncoded.length() - 4) + last4Bytes;
                    lastPrepend = '';
                  }
                  else if(last4Bytes.endsWith('=')) {
                    last4Bytes = last4Bytes.substring(0, 3) + 'N';
                    fBodyEncoded = fbodyEncoded.substring(0, fbodyEncoded.length() - 4) + last4Bytes;
                    lastPrepend = '\n';
                  }
                  else {
                    lastPrepend = '\r\n';
                  }
                }
                attachmentsStr += fHeaderEncoded + fBodyEncoded;
              }
              footer = lastPrepend + footer;
            }
            else {
              footer = '\r\n' + footer;
            }

            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            Blob bodyBlob = EncodingUtil.base64Decode(headerEncoded + attachmentsStr + footerEncoded);

            request = new HttpRequest();
            request.setHeader('Content-Type','multipart/form-data; boundary=' + boundary);
            request.setMethod('POST');
            request.setEndpoint(API_URL);
            request.setBodyAsBlob(bodyBlob);
            request.setTimeout(120000);

            protocol = new Http();
            response = protocol.send(request);

            // Logging Http Request And Response For Debugging Purpose.
            system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - request - ' + request);
            system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - response - ' + response);

            // Validating Response.
            status = response.getStatus();
    				if(status.toUpperCase() != 'OK') {
    					theResult = false;
    					system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - Email Sending Process Failed For Wrapper Record - ' + wrapper);
    				}
    				else {
    				  theResult = true;

              // If Http Request Successfully Reaches SendGrid API, Call It Again To Check For Invalid, Bounces And Blocked Results.
              List<String> emailFailuresToCheck = new List<String>();
              emailFailuresToCheck.addAll(wrapper.toEmail.trim().split(','));
              if(wrapper.cc != null) {
                emailFailuresToCheck.addAll(wrapper.cc.trim().split(','));
              }
              if(wrapper.bcc != null) {
                emailFailuresToCheck.addAll(wrapper.bcc.trim().split(','));
              }
              system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - emailFailuresToCheck - ' + emailFailuresToCheck);

              sendFailureEmail(
                wrapper.fromEmail,
                emailFailuresToCheck,
                EncodingUtil.urlEncode(String.valueOf(System.now()), ENCODING)
              );
            }
          }
        }
      }
    }
    catch(Exception e) {
      theResult = false;

      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - Exception Message - ' + e.getMessage());
      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - Exception Stack Trace - ' + e.getStackTraceString());
    }

    system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendEmails - theResult - ' + theResult);
    return;
  }
  /**
  * @description  This method processes emails that were successfully sent to SendGrid API for invalid,
  *               bounces and blocked Results.
  *
  * @param        String recipient, List<String> emailFailuresToCheck, String startDate
  * @return       void
  */
  public static void sendFailureEmail(String recipient, List<String> emailFailuresToCheck, String startDate) {
    // Removing Duplicate Email Addresses.
    Set<String> uniqueEmails = new Set<String>();
    uniqueEmails.addAll(emailFailuresToCheck);
    system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendFailureEmail - uniqueEmails - ' + uniqueEmails);

    // Building Email Body.
    sendErrorEmail = false;
    String emailBody = buildEmailBody(startDate, uniqueEmails);
    if(sendErrorEmail) {
      // Instantiating Http Request.
      HttpRequest request = new HttpRequest();

      // Building SendGrid API Request.
      String requestBody = 'api_user=' + API_USER + '&api_key=' + API_KEY;
      requestBody += '&from=' + recipient;
      requestBody += '&to=' + recipient;
      requestBody += '&subject=' + Label.TOPS_Email_Failure_Subject;
      requestBody += '&text=' + emailBody;
      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendFailureEmail - requestBody - ' + requestBody);

      // Building Http Request To Be Sent To SendGrid API.
      request.setMethod('POST');
      request.setEndpoint(TOPS_SendGridHelper.getEndPoint('MailSend'));
      request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      request.setHeader('Content-Length', String.valueof(requestBody.length()));
      request.setBody(requestBody);

      // Sending Http Request To SendGrid Server.
      Http protocol = new Http();
      HttpResponse response = protocol.send(request);
      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendFailureEmail - response - ' + response);
    }
  }

  /**
  * @description  This method is used to generate failure email body.
  *
  * @param        String startDate, Set<String> uniqueEmails
  * @return       String emailBody
  */
  private static String buildEmailBody(String startDate, Set<String> uniqueEmails) {
    String emailBody = '';

    // Invalid Email Addresses.
    Set<String> invalidEmails = getInvalid(startDate);

    // Blocked Email Addresses.
    Set<String> blockedEmails = getBlocked(startDate);

    // Bounced Emails Addresses.
    Set<String> bouncedEmails = getBounced(startDate);

    // Building Email Body For Invalid Email Addresses.
    if(invalidEmails.size() > 0) {
      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - buildEmailBody - invalidEmails - ' + invalidEmails);

      emailBody += Label.Invalid_Emails + '\n\r';
      for(String email : invalidEmails) {
        if(uniqueEmails.contains(email)) {
          sendErrorEmail = true;
          emailBody += email + '\n\r';
        }
      }
    }

    // Building Email Body For Blocked Email Addresses.
    if(blockedEmails.size() > 0) {
      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - buildEmailBody - blockedEmails - ' + blockedEmails);

      emailBody += emailBody != '' ? '\n\r' : '';
      emailBody += Label.Blocked_Emails + '\n\r';
      for(String email : blockedEmails) {
        if(uniqueEmails.contains(email)) {
          sendErrorEmail = true;
          emailBody += email + '\n\r';
        }
      }
    }

    // Building Email Body For Bounced Email Addresses.
    if(bouncedEmails.size() > 0) {
      system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - buildEmailBody - bouncedEmails - ' + bouncedEmails);

      emailBody += emailBody != '' ? '\n\r' : '';
      emailBody += Label.Bounced_Emails + '\n\r';
      for(String email : bouncedEmails) {
        if(uniqueEmails.contains(email)) {
          sendErrorEmail = true;
          emailBody += email + '\n\r';
        }
      }
    }

    return emailBody;
  }

  /**
  * @description  This method extracts invalid email addresses.
  *
  * @param        String startDate
  * @return       Set<String> extractedAddresses
  */
  private static Set<String> getInvalid(String startDate) {
    return extractAddressesFromXml(
      sendRequestFailure(
        TOPS_SendGridHelper.getEndPoint('getInvalid'),
        startDate
      )
    );
  }

  /**
  * @description  This method extracts blocked email addresses.
  *
  * @param        String startDate
  * @return       Set<String> extractedAddresses
  */
  private static Set<String> getBlocked(String startDate) {
    return extractAddressesFromXml(
      sendRequestFailure(
        TOPS_SendGridHelper.getEndPoint('getBlocked'),
        startDate
      )
    );
  }

  /**
  * @description  This method extracts bounced email addresses.
  *
  * @param        String startDate
  * @return       Set<String> extractedAddresses
  */
  private static Set<String> getBounced(String startDate) {
    return extractAddressesFromXml(
      sendRequestFailure(
        TOPS_SendGridHelper.getEndPoint('getBounced'),
        startDate
      )
    );
  }

  /**
  * @description  This method extracts email addresses from the response XML.
  *
  * @param        String startDate
  * @return       Set<String> extractedAddresses
  */
  private static Set<String> extractAddressesFromXml(Dom.Document document) {
    Set<String> extractedAddresses = new Set<String>();
    Dom.XMLNode root = document.getRootElement();
    for(Dom.XMLNode child : root.getChildElements()) {
      for(Dom.XMLNode grandChild : child.getChildElements()) {
        if(grandChild.getName() == 'email') {
          extractedAddresses.add(grandChild.getText());
        }
      }
    }
    return extractedAddresses;
  }

  /**
  * @description  This method is used to determine if there were any failures while sending emails via SendGrid. This method
  *               returns response XML which contains invalid, blocked or bounced email addresses if any.
  *
  * @param        String endpoint, String startDate
  * @return       Dom.Document theResponseXML
  */
  private static Dom.Document sendRequestFailure(String endpoint, String startDate) {
    // Building Http Request End Point.
    endpoint += '?api_user=' + API_USER + '&api_key=' + API_KEY + '&startDate=' + startDate;

    // Building Http Request.
    HttpRequest request = new HttpRequest();
    request.setMethod('GET');
    request.setEndpoint(endpoint);

    // Fetching Http Response.
    Http protocol = new Http();
    HttpResponse response = protocol.send(request);

    system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendRequestFailure - request - ' + request);
    system.debug('TRACE: TOPS_SendGridOutboundRequestDispatcher - sendRequestFailure - response - ' + response);

    return response.getBodyDocument();
  }
}