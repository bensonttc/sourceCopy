/**
 *  Test Class for the TQTrackingUtils
 */
@isTest
private class TQTrackingUtilsTest {
	
	static testMethod void testGettFieldSetFields() {
		
		TQTrackingUtils.FieldSetSelectionCriteria params = new TQTrackingUtils.FieldSetSelectionCriteria();
		params.objectAPIName = 'Account';
		params.fieldSetName = 'FieldSet';
		
		List<String> res = TQTrackingUtils.getFieldSetFields(TQTrackingUtils.getGlobalDescribe(), params);
		
		System.assertEquals(0, res.size());
	}

}