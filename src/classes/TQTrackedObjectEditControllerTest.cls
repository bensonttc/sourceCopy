/**
 *  Test Class for the TQTrackedObjectEditController
 */
@isTest
private class TQTrackedObjectEditControllerTest {

    static testMethod void testWithoutParams() {
        TQTrackedObjectEditController cont = new TQTrackedObjectEditController();
        system.assert(cont.err);
        
        cont.save();
        system.assert(cont.err);
    }
    
    static testMethod void testNewConfig() {
        ApexPages.currentPage().getParameters().put('clientAppId', 'newApp');
        ApexPages.currentPage().getParameters().put('objApiName', 'Account');
        
        TQTrackedObjectEditController cont = new TQTrackedObjectEditController();
        system.assert(!cont.err);
        
        //test save
        cont.config.Custom_Index_List__c = 'Name';
        cont.save();
        system.assert(!cont.err);
        
        //test custom index list
        List<TQTrackedObjectEditController.FieldsetWrapper> custFields = cont.getCustomIndexFields();
        System.assert(custFields.size() > 0);
        System.assertEquals(false, custFields[0].selected);
        
        //test list header field set
        custFields = cont.getListHeaderFields();
        System.assert(custFields.size() > 0);
        
        //test sorted list of fieldsets for the object of interest - getFSL()
        custFields = cont.getFSL();
        System.assert(custFields.size() > 0);
    }
}