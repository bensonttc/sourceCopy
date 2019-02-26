//
// (c) 2016 Appirio, Inc.
//
// Test Class Name: TOPS_EmailIconsController_Test
// For Apex Class: TOPS_EmailIconsController
// Description: Used to generate passenger pdf
//
// 2th February 2016    Vinod Kumar  Original (Task # T-466992)
//
@isTest(SeeAllData=true)
private class TOPS_EmailIconsController_Test {

    static testMethod void testTOPS_EmailIconsController() {
        // TO DO: implement unit test
       PageReference passPage = Page.TOPS_Email;
       Test.setCurrentPage(passPage);
       ApexPages.currentPage().getParameters().put('Brand','Brendan' );
       TOPS_EmailIconsController cont = new TOPS_EmailIconsController();
       system.assert(cont.socialList != null);
    }
}