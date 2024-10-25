trigger LeadTrigger on Lead (after insert, after update) {
    Boolean shouldRunBatch = false;

    // Check if the trigger is an insert or if the Lead_Temperature__c has changed during an update
    for (Lead lead : Trigger.new) {
        if (Trigger.isInsert || 
           (Trigger.isUpdate && lead.Lead_Temperature__c != Trigger.oldMap.get(lead.Id).Lead_Temperature__c)) {
            shouldRunBatch = true;
            break; // Exit the loop as we only need one change to trigger the batch
        }
    }

    // If a lead temperature change or new insert is detected, run the batch for all leads
    if (shouldRunBatch) {
        // Instantiate the batch class
        LeadScoreBatch leadBatch = new LeadScoreBatch();

        // Execute the batch with a batch size of 2000 records per batch
        Database.executeBatch(leadBatch, 2000);
    }
}