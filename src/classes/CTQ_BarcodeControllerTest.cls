@isTest
public class CTQ_BarcodeControllerTest {

    public static testMethod void testBarcodeController() {
        //This test needs to be improved by created a Batch__c record.
        //There are other dependant records such as Box, Tour instance, 
        //Account etc that is also needed
        PageReference pageRef = new PageReference('/apex/CTQ_Barcode_PDF');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recordId', 'yyyy');
        
        CTQ_BarcodeController controller = new CTQ_BarcodeController();
        system.assertEquals(controller.recordId,'yyyy');
    }

}