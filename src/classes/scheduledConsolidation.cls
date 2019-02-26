global class scheduledConsolidation implements Schedulable {


   global void execute(SchedulableContext SC) {
        DSE.API_JobManager.runConcurrentJob('Consolidation',3);
   }
}