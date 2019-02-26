global class TQUploadResponse extends TQWebServiceResponse {
	public static final String OperationDelete = 'DELETE';
	public static final String OperationUpsert = 'UPSERT';
	
	public List<TQUploadResponseItem> body {get; set;}

	public TQUploadResponse(){
		super();
		body = new List<TQUploadResponseItem>();
	}

	global class TQUploadResponseItem
	{
		public String objectApiName{get; set;}	
		//TODO find a way how to put there xsd:anyType
		public sObject record {get; set;}
		public String responseId {get; set;}
		public String requestId {get; set;}
		public String operation {get; set;}
		public Boolean success {get; set;}
		public Boolean executed {get; set;}
		public String changeDate {get; set;}
		public List<String> errorList{get; set;}
		
		public TQUploadResponseItem(String objectApiName, String requestId){
			this.errorList = new List<String>();
			this.success = true;
			this.objectApiName = objectApiName;
			this.requestId = requestId;
		}
	}
}