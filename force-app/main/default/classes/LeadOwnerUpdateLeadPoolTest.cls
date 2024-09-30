@isTest
public class LeadOwnerUpdateLeadPoolTest {
    @isTest
    static void testUpdateLeadOwnerQueueLeadPool() {
        // Create a Lead with Status 'Cancelled'
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Status = 'Cancelled'
        );
        insert testLead;
        
        // Call the method to be tested
        LeadOwnerUdpateLeadPool.updateLeadOwnerQueueLeadPool(new List<Lead>{ testLead });
        
        // Retrieve the updated Lead
        Lead updatedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        
        // Verify that the Lead OwnerId is updated to the QueueId
        System.assertEquals([SELECT Queue.Id FROM queuesobject WHERE queue.Name = 'Lead Pool' LIMIT 1].Queue.Id,updatedLead.OwnerId,'Lead OwnerId should be updated to the QueueId' );
    }
}