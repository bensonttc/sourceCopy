/**
 *	Custom Exception for the TQDownload services
 */
public with sharing class TQDownloadException extends Exception {
	
	/**
	 *	Holder for the error code
	 */
	private Integer errorCode;
	
	public TQDownloadException(String message, Integer errorCode) {
		setMessage(message);
		setErrorCode(errorCode);
	}
	
	/**
	 *	Getter & Setter
	 */
	public Integer getErrorCode() {
		return this.errorCode;		
	}
	public void setErrorCode(Integer errorCode) {
		this.errorCode = errorCode;
	}
	
}