/**
 *	Web Service Response for the Download Webservice
 */
global class TQDownloadResponse extends TQWebServiceResponse {

	public final static Integer SERVER_ERROR_NOITEMS = -501;				//Objects not specified in the request
	public final static Integer SERVER_ERROR_OBJECTNOTFOUND = -502;			//Object specified in the request not found in Salesforce
	public final static Integer SERVER_ERROR_OBJECTNOTSPECIFIED = -503;		//Object not specified when asking the service to compute sync type / query
	public final static Integer SERVER_ERROR_TODATENOTSPECIFIED = -504;		//To Date not specified when asking the service to compute sync type / query
	public final static Integer SERVER_ERROR_MISSINGFIELDSET = -505;		//Field set not specified for a tracked object
	public final static Integer SERVER_ERROR_COUNTQUERYERROR = -506;		//Error running the count query to define which sync type is needed
	
	
	/**
	 *	Response items for the download request
	 */	
	private List<TQDownloadResponseItem> body;
	
	/**
	 *	Getters & Setters
	 */
	public List<TQDownloadResponseItem> getBody() {
		return this.body;
	}
	public void setBody(List<TQDownloadResponseItem> body) {
		this.body = body;
	}
	

	/**
	 *	Descriptor for a single Object
	 */
	public class TQDownloadResponseItem extends TQWebServiceResponse {
		
		/**
		 *	API Name of the object
		 */	
		private String objectApiName;
		
		/**
		 *	From 
		 */	
		private String fromDateTime;
		
		/**
		 *	To
		 */	
		private String toDateTime;
		
		/**
		 *	Query for the object
		 */	
		private String query;
		
		/**
		 *	Query for the object
		 */	
		private String syncType;
		
		/**
		 *	Amount of records
		 */
		private Long recordCount;
		
		
		/**
		 *	Getters & Setters
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
		public String getQuery() {
			return this.query;
		}
		public void setQuery(String query) {
			this.query = query;
		}
		public String getSyncType() {
			return this.syncType;
		}
		public void setSyncType(String syncType) {
			this.syncType = syncType;
		}
		public Long getRecordCount() {
			return this.recordCount;		
		}
		public void setRecordCount(Long recordCount) {
			this.recordCount = recordCount;		
		}
	}
	
}