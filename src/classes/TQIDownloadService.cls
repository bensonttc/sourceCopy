/**
 *  Interface that describes what a Download service should offer
 */
public interface TQIDownloadService {
    /**
     *  Checks if data should be loaded for this object or it's only-metadata object
     *
     *  @param objectApiName object API Name
     *  @returns Boolean true if data should be loaded for current object
     */ 
    Boolean shouldLoadData(String objectApiName);
    
    /**
     *  Compute which kind of synchronisation a particular object needs considering the defined timeframe
     *
     *  @param objectApiName object API Name
     *  @param fromDateTime temporal lower bound  
     *  @param toDateTime temporal upper bound
     *  @returns sync type for the object (TQDownloadSyncType)
     */
    TQDownloadObjectSyncType computeObjectSyncType(String objectApiName, DateTime fromDateTime, DateTime toDateTime); // throw TQDownloadException
    
    /**
     *  Compute which kind of synchronisation a particular object needs considering the defined timeframe
     *
     *  @param objectApiName object API Name
     *  @param fromDateTime temporal lower bound 
     *  @param toDateTime temporal upper bound
     *  @returns sync type for the object
     */
    String computeObjectSyncQuery(String objectApiName, DateTime fromDateTime, DateTime toDateTime); // throw TQDownloadException

}