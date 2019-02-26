public class CTQ_BarcodeController {
    
    public String recordId {get;set;}
    public String barcode {get;set;}
    public String encodedBarcode {get;set;}
    public String barcodeURL {get;set;}
    public String batchName {get;set;}
    public String scanboxName {get;set;}
    public Boolean success {get;set;}
    public String errorMessage {get;set;}
    public Batch__c batch {get;set;}

    public CTQ_BarcodeController(){
        this.recordId = apexPages.currentPage().getParameters().get('recordId');
        try{
            if(recordId == null || recordId == '') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No barcode found in this batch.');
            } else {
                this.success = true;
                this.batch = [Select Id, Name, Barcode__c, Scan_Box__r.Name from Batch__c 
                            Where Id =:recordId limit 1];
                if(batch.Barcode__c != null){
                    this.barcode = batch.Barcode__c;
                    this.batchName = batch.Name;
                    this.scanboxName = batch.Scan_Box__r.Name;
                    this.encodedBarcode = EncodingUtil.urlEncode(barcode, 'UTF-8');
                    this.barcodeURL = 'https://barcode.tec-it.com/barcode.ashx?data='+encodedBarcode+'&code=Code39FullASCII&dpi=96&dataseparator=';
                } else {
                    this.success = false;
                    this.errorMessage = 'No barcode found';
                }
            }
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No barcode found in this batch.');
        }
    }  
}