/**
 *  Web Service Response for the Attachment
 */
global class TQAttachmentResponse {

    public TQAttachmentResponse(String result) {
    	setResult(result);
    }
    public TQAttachmentResponse(Integer result) {
    	setResult('' + result);
    }
    
    public String result {get; set;}

    public void setResult(String result) {
        this.result = result;
    }

    public String getResult() {
    	return this.result;
    }
    
}