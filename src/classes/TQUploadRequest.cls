global class TQUploadRequest {
	public List<String> recordList {get; set;}

	public TQUploadRequest(){
		recordList = new List<String>();
	}
	
	/*global class TQUploadRequestItem {
		public String objectApiName {get; set;}
		public Map<String, String> record {get; set;}
		
		public Map<String, String> getRecord(){
			return record;
		}
	
		public String getObjectApiName(){
			return objectApiName;
		}	
	}*/
}