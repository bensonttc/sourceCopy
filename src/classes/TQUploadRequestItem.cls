global class TQUploadRequestItem {
	public String objectApiName {get; set;}
	public String Id {get; set;}
	public String record {get; set;}
	public String changeDate {get; set;}
	
	public TQUploadRequestItem(){
	}
	
	public TQUploadRequestItem(String objectApiName, String objectId, String record){
		this(objectApiName, objectId, record, null);
	}
		
	public TQUploadRequestItem(String objectApiName, String objectId, String record, String changeDate){
		this.objectApiName = objectApiName;
		this.Id = objectId;
		this.record = record;
		this.changeDate = changeDate;
	}
}