//
// (c) 2016 Appirio, Inc.
//
// Apex Class Name: TOPS_EmailWrapper
// Description: It is a wrapper class for email print service.
//
public without sharing class TOPS_EmailWrapper
{

    public String toEmail;
    public String fromEmail;
    public String emailSubject;
    public String emailBody;
    public String cc;
    public String bcc;
    public String relatedObjectId;
    public String brand;
    public String regionCode;
    public String replyTo;
    public String tdId;
    public Map<String, Blob> attachments;

    public TOPS_EmailWrapper()
    {
        attachments = new Map<String, Blob>();
    }


    public TOPS_EmailWrapper(String toEmail, String fromEmail, String emailSubject, String emailBody, Map<String, Blob> attachments)
    {
        this.toEmail = toEmail;
        this.fromEmail = fromEmail;
        this.emailSubject = emailSubject;
        this.emailBody = emailBody;
        this.attachments = attachments;
    }
}