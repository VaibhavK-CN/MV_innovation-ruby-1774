trigger LeadScoreTrigger on Lead (after insert) {
    // The batch will process all leads, not just the newly inserted/updated ones

    // Instantiate the batch class
    LeadScoreBatch leadBatch = new LeadScoreBatch();

    // Execute the batch with a batch size of 2000 records per batch
    Database.executeBatch(leadBatch, 2000);
}