public class LeadAssignmentHelper {

    public static Id callAgentQueueId = getQueueId('Call Agent Queue');
    public static Id consultantQueueId = getQueueId('Consultant Health Inc');

    // Fetch Queue ID by name
    private static Id getQueueId(String queueName) {
        try {
            System.debug('Fetching Queue ID for: ' + queueName);
            Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :queueName LIMIT 1];
            System.debug('Fetched Queue ID: ' + (queue != null ? queue.Id : 'null') + ' for Queue: ' + queueName);
            return queue != null ? queue.Id : null;
        } catch (Exception e) {
            System.debug('Error fetching Queue ID for ' + queueName + ': ' + e.getMessage());
            return null;
        }
    }

    // Asynchronously assign newly created leads to Call Agent Queue
    @future
    public static void assignNewLeadsToQueueAsync(List<Id> leadIds) {
        System.debug('Assigning new leads to Call Agent Queue. Lead IDs: ' + leadIds);
        if (callAgentQueueId == null) {
            System.debug('Call Agent Queue ID is null. Exiting assignment.');
            return;
        }

        List<Lead> leadsToUpdate = [SELECT Id, OwnerId FROM Lead WHERE Id IN :leadIds];
        System.debug('Leads fetched for Call Agent Queue assignment: ' + leadsToUpdate);

        for (Lead lead : leadsToUpdate) {
            lead.OwnerId = callAgentQueueId;
            System.debug('Setting OwnerId to Call Agent Queue for Lead: ' + lead.Id);
        }

        if (!leadsToUpdate.isEmpty()) {
            try {
                update leadsToUpdate;
                System.debug('Successfully updated leads to Call Agent Queue: ' + leadsToUpdate);
            } catch (Exception e) {
                System.debug('Error assigning leads to Call Agent Queue: ' + e.getMessage());
            }
        }
    }

    // Asynchronously assign leads to Consultant_Health_Inc queue
    @future
    public static void assignLeadsToConsultantQueueAsync(List<Id> leadIds) {
        System.debug('Assigning leads to Consultant_Health_Inc Queue. Lead IDs: ' + leadIds);
        if (consultantQueueId == null) {
            System.debug('Consultant_Health_Inc Queue ID is null. Exiting assignment.');
            return;
        }

        List<Lead> leadsToUpdate = [SELECT Id, OwnerId FROM Lead WHERE Id IN :leadIds];
        System.debug('Leads fetched for Consultant_Health_Inc Queue assignment: ' + leadsToUpdate[0]);

        for (Lead lead : leadsToUpdate) {
            lead.OwnerId = consultantQueueId;
            System.debug('Setting OwnerId to Consultant_Health_Inc Queue for Lead: ' + lead.Id);
        }

        if (!leadsToUpdate.isEmpty()) {
            try {
                update leadsToUpdate;
                System.debug('Successfully updated leads to Consultant_Health_Inc Queue: ' + leadsToUpdate);
            } catch (Exception e) {
                System.debug('Error assigning leads to Consultant_Health_Inc Queue: ' + e.getMessage());
            }
        }
    }


    //Asynchronously assign leads to Call Agent Queue queue
    @future
    public static void updateLeadOwnerToQueueAsync(List<Id> leadIds) {
        System.debug('Updating lead owner to Call Agent Queue. Lead IDs: ' + leadIds);
        if (callAgentQueueId == null) {
            System.debug('Call Agent Queue ID is null. Exiting update.');
            return;
        }

        List<Lead> leadsToUpdate = [SELECT Id, OwnerId FROM Lead WHERE Id IN :leadIds];
        System.debug('Leads fetched for owner update: ' + leadsToUpdate);

        for (Lead lead : leadsToUpdate) {
            lead.OwnerId = callAgentQueueId;
            System.debug('Setting OwnerId to Call Agent Queue for Lead: ' + lead.Id);
        }

        if (!leadsToUpdate.isEmpty()) {
            try {
                update leadsToUpdate;
                System.debug('Successfully updated leads to Call Agent Queue: ' + leadsToUpdate);
            } catch (Exception e) {
                System.debug('Error updating lead Owner to Call Agent Queue: ' + e.getMessage());
            }
        }
    }


    // Find the next assigned lead for the current user
    @AuraEnabled
    public static String findNextAssignedLead(Id currentLeadId) {
        Id userId = UserInfo.getUserId();
        System.debug('Finding next assigned lead for user: ' + userId + ', Excluding Lead ID: ' + currentLeadId);

        List<Lead> nextLeads = [
            SELECT Id 
            FROM Lead 
            WHERE OwnerId = :callAgentQueueId 
              AND Id != :currentLeadId
            ORDER BY CreatedDate ASC 
            LIMIT 1
        ];

        System.debug('Next lead found: ' + (nextLeads.isEmpty() ? 'null' : nextLeads[0].Id));
        /////////////////////////////////////Assign the Next lead Owner ID to the Current User/////////
        // List to store updated leads
        List<Lead> leadsToUpdate = new List<Lead>();

        // Perform CRUD operations (Update)
        for (Lead lead : nextLeads) {
            lead.OwnerId = userId;
            leadsToUpdate.add(lead);
        }

        // Bulk update leads
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
            System.debug('Successfully Assigner leads to User: ' + leadsToUpdate);
        }

        ///////////////////////////////////////////////////////////////////////////////////////////

        return nextLeads.isEmpty() ? null : nextLeads[0].Id;
    }
}