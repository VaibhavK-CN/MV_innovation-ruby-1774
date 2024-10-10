trigger LeadRankTrigger on Lead (after insert) {
    // Collect newly inserted leads
    List<Lead> newLeads = new List<Lead>();
    
    for (Lead lead : Trigger.new) {
        // Only include records where the ranking hasn't been assigned yet (Lead_Score__c is null)
        if (lead.Lead_Score__c == null) {
            newLeads.add(lead);
        }
    }

    // Check if there are leads to process
    if (newLeads.size() > 0) {
        // Pass the list of leads to the batch class
        LeadScoreBatch rankingBatch = new LeadScoreBatch(newLeads);
        // Execute the batch with a batch size of 200 (max batch size)
        Database.executeBatch(rankingBatch, 200);
    }
}