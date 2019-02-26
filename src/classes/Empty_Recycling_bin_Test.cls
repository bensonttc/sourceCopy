@isTest (seealldata = false)
global class Empty_Recycling_bin_Test {
  
    
	static testmethod void testrecycling_Bin() {
		Account Acc = new Account(name = 'Test');
  		insert Acc;
    	delete Acc;
     
   		Test.startTest();
		Database.executeBatch(new Empty_recycling_bin('Select id from Account where isDeleted=true ALL ROWS'));
    	Test.StopTest();
        system.assert([select count() from Account] == 0);
    
    }
}