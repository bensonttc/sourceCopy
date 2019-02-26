/**
 *	Wrapper of each WebService Response
 */
global abstract class TQWebServiceResponse {
	
	public final static Integer SUCCESS = 0;
	public final static Integer CLIENT_GENERIC_ERROR = -400;
	public final static Integer SERVER_GENERIC_ERROR = -500;
	
	/**
	 *	Status of the Response
 	 */	
	private Integer status;
	
	/**
	 *	Verbose error
 	 */	
	private String error;
	
	
	/**
	 *	Default constructor
 	 */
	public TQWebServiceResponse() {}
	
	/**
	 *	Getter of the status
 	 */
	public Integer getStatus() {
		return this.status;
	}
	
	/**
	 *	Setter of the status
 	 */
	public void setStatus(Integer status) {
		this.status = status;
	}
	
	/**
	 *	Getter of the error
 	 */
	public String getError() {
		return this.error;
	}
	
	/**
	 *	Setter of the error
 	 */
	public void setError(String error) {
		this.error = error;
	}

}