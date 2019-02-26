/**
 *  Web Service Request for the Download Webservice
 */
global with sharing class TQDownloadRequest {
            
    /**
     *  From. Date is in GMT, format yyyy-MM-ddTHH:mm:ss.SSSZ
     */ 
    private String fromDateTime;
    
    /**
     *  To. Date is in GMT, format yyyy-MM-ddTHH:mm:ss.SSSZ
     */ 
    private String toDateTime;
    
    /**
     *  API Name of the object
     */ 
    private String objectApiName;
    
    
    /**
     *  Getters & Setters
     */
    public String getObjectApiName() {
        return this.objectApiName;
    }
    public void setObjectApiName(String objectApiName) {
        this.objectApiName = objectApiName;
    }
    public String getFromDateTime() {
        return this.fromDateTime;
    }
    public void setFromDateTime(String fromDateTime) {
        this.fromDateTime = fromDateTime;
    }
    public String getToDateTime() {
        return this.toDateTime;
    }
    public void setToDateTime(String toDateTime) {
        this.toDateTime = toDateTime;
    }

}