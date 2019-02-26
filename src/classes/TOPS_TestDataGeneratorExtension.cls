public with sharing class TOPS_TestDataGeneratorExtension {

  private final Account acct;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public TOPS_TestDataGeneratorExtension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }

    public PageReference generateTestData(){
        System.enqueueJob(new TOPS_TestDataGenerator(acct));
        return new PageReference('/' + acct.id);
    }
}