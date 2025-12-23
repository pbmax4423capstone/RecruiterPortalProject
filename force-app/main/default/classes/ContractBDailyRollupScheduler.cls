/**
 * @description Schedulable class to run daily FYC rollup updates for all Contract B Candidates
 * @author Contract Lifecycle Tracking System
 * @date December 2025
 */
global class ContractBDailyRollupScheduler implements Schedulable {
    
    /**
     * @description Execute method called by the scheduler
     * @param sc SchedulableContext
     */
    global void execute(SchedulableContext sc) {
        // Update all Contract B candidates
        CandidateFYCRollupService.updateAllContractBCandidates();
    }
    
    /**
     * @description Schedule this job to run daily at 6 AM
     * @return The Job ID of the scheduled job
     */
    public static String scheduleDailyJob() {
        String jobName = 'Contract B Daily FYC Rollup';
        String cronExp = '0 0 6 * * ?'; // Every day at 6 AM
        
        ContractBDailyRollupScheduler scheduler = new ContractBDailyRollupScheduler();
        return System.schedule(jobName, cronExp, scheduler);
    }
    
    /**
     * @description Unschedule all instances of this job
     */
    public static void unscheduleJob() {
        List<CronTrigger> jobs = [
            SELECT Id 
            FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'Contract B Daily FYC Rollup%'
        ];
        
        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
    }
}
