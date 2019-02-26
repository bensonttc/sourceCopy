/**
 * 	Holding object to wrap information on the synchronisation type for an object
 */
public with sharing class TQDownloadObjectSyncType {

	/**
	 *	Sync type
	 */
	private String syncType;
	
	/**
	 *	Amount of records
	 */
	private Long recordCount;
	
	/**
	 *	Constructors
	 */
	public TQDownloadObjectSyncType() {}
	
	public TQDownloadObjectSyncType(String syncType, Long recordCount) {
		this.setSyncType(syncType);
		this.setRecordCount(recordCount);
	}
	
	
	/**
	 *	Getter & Setter
	 */
	public void setSyncType(String syncType) {
		this.syncType = syncType;		
	}
	public String getSyncType() {
		return this.syncType;		
	}
	public void setRecordCount(Long recordCount) {
		this.recordCount = recordCount;		
	}
	public Long getRecordCount() {
		return this.recordCount;		
	}

}