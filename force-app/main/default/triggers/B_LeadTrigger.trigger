trigger B_LeadTrigger on Lead (before update) {
    // IDs for queues (replace with actual record IDs of queues)
    String holdingQueueId = '00GFS000007NNpV2AW'; // Holding Queue Id
    String callAgentQueueId = '00G5r0000073n7YEAQ'; // Call Agent Queue Id
	/************************************************
	 Id callAgentQueueId = [SELECT Id FROM Group WHERE Name = 'Call Agent Queue' AND Type = 'Queue' LIMIT 1].Id;
     Id holdingQueueId = [SELECT Id FROM Group WHERE Name = 'Holding Queues' AND Type = 'Queue' LIMIT 1].Id;
	************************************************added by tayab*/
    for (Lead lead : Trigger.new) {
        Lead oldLead = Trigger.oldMap.get(lead.Id);

        // Check if OwnerId has changed from 'Holding Queues' to 'Call Agent Queue'
        if (oldLead.OwnerId == holdingQueueId && lead.OwnerId == callAgentQueueId) {
            // Convert Holding_Queue_Duration__c to an Integer (assuming it's a text or number field)
            Integer duration = lead.Holding_Queue_Duration__c != null ? Integer.valueOf(lead.Holding_Queue_Duration__c) : 0;

            // Calculate Rank_Decrement_CA__c based on the duration
            if (duration == 7) {
                lead.Rank_Decrement_CA__c = '15';
            } else if (duration == 14) {
                lead.Rank_Decrement_CA__c = '30';
            } else if (duration == 28) {
                lead.Rank_Decrement_CA__c = '45';
            } else if (duration == 56) {
                lead.Rank_Decrement_CA__c = '60';
            } else if (duration == 112) {
                lead.Rank_Decrement_CA__c = '75';
            } else if (duration == 224) {
                lead.Rank_Decrement_CA__c = '90';
            } else if (duration == 448) {
                lead.Rank_Decrement_CA__c = '105';
            } else if (duration == 896) {
                lead.Rank_Decrement_CA__c = '120';
            } else {
                lead.Rank_Decrement_CA__c = '0'; // Default value
            }
        }
    }

}