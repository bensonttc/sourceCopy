/**
 * @description This is used to schedule the batch update job that updates records if a formula value changes
 **/
global with sharing class TOPS_FormulaUpdateCheckSchedulable implements Schedulable {

	global void execute(SchedulableContext ctx) {
		TOPS_FormulaUpdateCheckBatch formulaUpdateBatch = new TOPS_FormulaUpdateCheckBatch(null);
       	ID batchId = Database.executeBatch(formulaUpdateBatch, 2000);
	}
}