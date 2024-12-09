global class LeadQueueAssignmentScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Id callAgentQueueId = [SELECT Id FROM Group WHERE Name = 'Call Agent Queue' AND Type = 'Queue' LIMIT 1].Id;
        Id holdingQueueId = [SELECT Id FROM Group WHERE Name = 'Holding Queues' AND Type = 'Queue' LIMIT 1].Id;
        List<Lead> leadsToProcess = [
            SELECT Id, OwnerId, Not_Intrested_Count__c, Latest_Sub_Feedback__c, LastModifiedDate,Lead_Score__c
            FROM Lead
            WHERE Latest_Sub_Feedback__c = 'Not Interested / Wrong Timing'
            AND Not_Intrested_Count__c != NULL
        ];
        
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Lead lead : leadsToProcess) {
            Integer count = (Integer)lead.Not_Intrested_Count__c;
            Integer delayDays = 7;
            
            for (Integer i = 1; i < count; i++) {
                delayDays *= 2;
            }
            delayDays = Math.min(delayDays, 1095);
            if (lead.LastModifiedDate <= System.today().addDays(-delayDays)) {
                if (lead.OwnerId == holdingQueueId) {
                    lead.OwnerId = callAgentQueueId;
                    lead.Lead_Score__c = (lead.Lead_Score__c == null) ? 15 : lead.Lead_Score__c + 15;
                } else if (lead.OwnerId == callAgentQueueId) {
                    lead.OwnerId = holdingQueueId;
                }
                leadsToUpdate.add(lead);
            }
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
}