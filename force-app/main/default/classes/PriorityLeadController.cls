public with sharing class PriorityLeadController {

    // Assign the best lead (highest aggregate score) from the Call Agent Queue to the specified user
    @AuraEnabled(cacheable=true)
    public static Lead getHighestPriorityLead() {
        // Get the Call Agent Queue ID
        Id callAgentQueueId = [SELECT Id 
                               FROM Group 
                               WHERE Name = 'Call Agent Queue' 
                               AND Type = 'Queue' 
                               LIMIT 1].Id;

        // Query to get all leads in the Call Agent Queue
        List<Lead> leadsInQueue = [SELECT Id, OwnerId, Lead_Score__c, Priority__c 
                                   FROM Lead 
                                   WHERE OwnerId = :callAgentQueueId];
        
        // Variable to hold the best lead (highest aggregate score)
        Lead bestLead = null;
        Double highestScore = -1.0;

        // Iterate over the leads and calculate the aggregate score
        for (Lead lead : leadsInQueue) {
            // Calculate the aggregate score for the lead
            Double aggregateScore = (lead.Lead_Score__c != null ? lead.Lead_Score__c : 0) +
                                    (lead.Priority__c != null ? lead.Priority__c : 0);

            // Check if this lead has the highest score
            if (aggregateScore > highestScore) {
                highestScore = aggregateScore;
                bestLead = lead;
            }
        }

        // If a best lead is found, return it
        if (bestLead != null) {
            return bestLead;
        } else {
            // Throw an exception if no leads are found in the queue
            throw new AuraHandledException('No leads found in the Call Agent Queue.');
        }
    }

    // Method to assign the best lead from the Call Agent Queue to a specified user
    @AuraEnabled
    public static void assignLeadToUser(Id userId) {
        // Get the Call Agent Queue ID
        Id callAgentQueueId = [SELECT Id 
                               FROM Group 
                               WHERE Name = 'Call Agent Queue' 
                               AND Type = 'Queue' 
                               LIMIT 1].Id;

        // Query to get all leads in the Call Agent Queue
        List<Lead> leadsInQueue = [SELECT Id, OwnerId, Lead_Score__c, Priority__c 
                                   FROM Lead 
                                   WHERE OwnerId = :callAgentQueueId];

        // Variable to hold the best lead (highest aggregate score)
        Lead bestLead = null;
        Double highestScore = -1.0;

        // Iterate over the leads and calculate the aggregate score
        for (Lead lead : leadsInQueue) {
            // Calculate the aggregate score for the lead
            Double aggregateScore = (lead.Lead_Score__c != null ? lead.Lead_Score__c : 0) +
                                    (lead.Priority__c != null ? lead.Priority__c : 0);

            // Check if this lead has the highest score
            if (aggregateScore > highestScore) {
                highestScore = aggregateScore;
                bestLead = lead;
            }
        }

        // If the best lead is found, assign it to the user
        if (bestLead != null) {
            bestLead.OwnerId = userId;
            update bestLead;
        } else {
            throw new AuraHandledException('No leads found in the Call Agent Queue to assign.');
        }
    }

    // Method to release the lead assigned to a user back to the Call Agent Queue
    @AuraEnabled
    public static void releaseLeadFromUser(Id userId) {
        // Get the Call Agent Queue ID
        Id callAgentQueueId = [SELECT Id 
                               FROM Group 
                               WHERE Name = 'Call Agent Queue' 
                               AND Type = 'Queue' 
                               LIMIT 1].Id;

        // Query to get all leads owned by the user
        List<Lead> userLeads = [SELECT Id 
                                FROM Lead 
                                WHERE OwnerId = :userId];

        // Iterate over the leads and change the owner to the Call Agent Queue
        for (Lead lead : userLeads) {
            lead.OwnerId = callAgentQueueId;
        }

        // If there are leads to update, perform the update operation
        if (!userLeads.isEmpty()) {
            update userLeads;
        }
    }
}