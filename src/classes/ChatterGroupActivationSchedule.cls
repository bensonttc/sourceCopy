global class ChatterGroupActivationSchedule implements Schedulable{
    public static String sched = '0 00 00 * * ?';  //Every Day at Midnight 
    private Boolean isArchivingJob;
    
    public ChatterGroupActivationSchedule(Boolean isItArchivingJob){
    	isArchivingJob = isItArchivingJob;
    }

    global static List<String> setupScheduleJobs() {
        ChatterGroupActivationSchedule scheduleToArchive = new ChatterGroupActivationSchedule(true); 
        ChatterGroupActivationSchedule scheduleActivate = new ChatterGroupActivationSchedule(false); 
        String archivingName = 'Batch archiving chatter groups';
        String activationName = 'Batch activation chatter groups';
        
        if (Test.isRunningTest()){
        	archivingName += '[Test]';
        	activationName += '[Test]';
        }
        
        return new List<String>{
        	System.schedule(archivingName, sched, scheduleToArchive),
        	System.schedule(activationName, sched, scheduleActivate)
        };
    }

    global void execute(SchedulableContext sc) {
        ChatterGroupActivationBatch batchJob = new ChatterGroupActivationBatch(isArchivingJob);
        ID batchprocessid = Database.executeBatch(batchJob, 100);
        System.debug('Batch job has been started with id: ' + batchprocessid);           
    }
}