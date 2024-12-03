global class LeadBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.debug('Running the scheduled batch process.');
        // Execute the batch
        Database.executeBatch(new AssignLeadToConsultantBatch(), 50);

        // Re-schedule this scheduler for the next minute
        String cron = System.now().addSeconds(60).format('s m H d M \'?\' yyyy');
        System.schedule('LeadBatchScheduler', cron, new LeadBatchScheduler());
    }
}