global class LeadQueueAssignmentBatch implements Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext context) {
        System.debug('Start Method!');
        return Database.getQueryLocator([
            SELECT Id, OwnerId, Not_Intrested_Count__c, Latest_Sub_Feedback__c, LastModifiedDate, Lead_Score__c
            FROM Lead
            WHERE Latest_Sub_Feedback__c = 'Not Interested / Wrong Timing'
            AND Not_Intrested_Count__c != NULL
        ]);
    }

    global void execute(Database.BatchableContext context, List<Lead> scope) {
        Id callAgentQueueId = [SELECT Id FROM Group WHERE Name = 'Call Agent Queue' AND Type = 'Queue' LIMIT 1].Id;
        Id holdingQueueId = [SELECT Id FROM Group WHERE Name = 'Holding Queues' AND Type = 'Queue' LIMIT 1].Id;
		System.debug('callAgentQueueId-->'+callAgentQueueId);
        System.debug('holdingQueueId-->'+holdingQueueId);
        List<Lead> leadsToUpdate = new List<Lead>();
		System.debug('scope-->'+scope);
        for (Lead lead : scope) {
            Integer count = (Integer)lead.Not_Intrested_Count__c;
            System.debug('count-->'+count);
            Integer delayDays = 7;

            for (Integer i = 1; i < count; i++) {
                delayDays *= 2;
            }
            delayDays = Math.min(delayDays, 1095 * 24 * 60);
            lead.Holding_Queue_Duration__c = String.valueOf(delayDays);
            if (lead.LastModifiedDate <= System.now().addMinutes(-delayDays)) {
                if (lead.OwnerId == holdingQueueId) {
                    lead.OwnerId = callAgentQueueId;
                    //lead.Lead_Score__c = (lead.Lead_Score__c == null) ? 10 : lead.Lead_Score__c - 10;
                } else if (lead.OwnerId == callAgentQueueId) {
                    lead.OwnerId = holdingQueueId;
                    //lead.Lead_Score__c = (lead.Lead_Score__c == null) ? 15 : lead.Lead_Score__c + 15;
                }
                leadsToUpdate.add(lead);
            }
        }

        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    global void finish(Database.BatchableContext context) {}
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new LeadQueueAssignmentBatch(), 200);
    }
}