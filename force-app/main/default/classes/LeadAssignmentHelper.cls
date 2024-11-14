public class LeadAssignmentHelper {

    // Static variable for Call Agent Queue ID
    public static Id callAgentQueueId = getCallAgentQueueId();

    // Method to fetch Call Agent Queue ID
    private static Id getCallAgentQueueId() {
        try {
            Group callAgentQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Call Agent Queue' LIMIT 1];
            System.debug('Fetched Call Agent Queue ID: ' + (callAgentQueue != null ? callAgentQueue.Id : 'null'));
            return callAgentQueue != null ? callAgentQueue.Id : null;
        } catch (Exception e) {
            System.debug('Error fetching Call Agent Queue ID: ' + e.getMessage());
            return null;
        }
    }

    // Method to update the current lead's OwnerId to Call Agent Queue
    public static void updateLeadOwnerToQueue(Id leadId) {
        try {
            Lead leadToUpdate = [SELECT Id, OwnerId FROM Lead WHERE Id = :leadId LIMIT 1];

            if (leadToUpdate != null) {
                leadToUpdate.OwnerId = callAgentQueueId;
                update leadToUpdate;
                System.debug('Existing lead Owner updated to Call Agent Queue. Lead ID: ' + leadToUpdate.Id);
            } else {
                System.debug('Lead not found with ID: ' + leadId);
            }
        } catch (Exception e) {
            System.debug('Error updating lead Owner to Call Agent Queue: ' + e.getMessage());
        }
    }

    // Find a new lead based on preferred language and least lead score, excluding the current lead
    public static Lead findNewLeadWithCriteria(String preferredLanguage, Id currentLeadId) {
        System.debug('Finding new lead with criteria. Preferred Language: ' + preferredLanguage);

        if (String.isBlank(preferredLanguage)) {
            System.debug('Preferred language is blank. Returning null.');
            return null;
        }

        // Query to find a new lead with matching language, least lead score, and excluding the current lead
        List<Lead> availableLeads = [
            SELECT Id, OwnerId, Lead_Score__c 
            FROM Lead 
            WHERE Langauge_Prefered__c = :preferredLanguage
              AND OwnerId = :callAgentQueueId
              AND Id != :currentLeadId
            ORDER BY Lead_Score__c ASC
            LIMIT 1
        ];

        System.debug('Available leads found: ' + availableLeads.size());

        // Return the first available lead that meets the criteria
        if (!availableLeads.isEmpty()) {
            Lead newLead = availableLeads[0];
            System.debug('New lead found for assignment. Lead ID: ' + newLead.Id + ', Lead Score: ' + newLead.Lead_Score__c);
            return newLead;
        } else {
            System.debug('No matching new lead found for preferred language: ' + preferredLanguage);
        }

        return null;
    }

    // Assign a new lead to the current user
    public static void assignNewLeadToUser(String preferredLanguage, Id userId, Id currentLeadId) {
        System.debug('Assigning new lead to user. User ID: ' + userId + ', Preferred Language: ' + preferredLanguage);

        Lead newLead = findNewLeadWithCriteria(preferredLanguage, currentLeadId);

        if (newLead != null) {
            try {
                newLead.OwnerId = userId;
                update newLead;
                System.debug('New lead assigned to user: ' + userId + ', Lead ID: ' + newLead.Id);
            } catch (Exception e) {
                System.debug('Error assigning new lead to user: ' + userId + ', Error: ' + e.getMessage());
            }
        } else {
            System.debug('No new lead available for assignment to user: ' + userId);
        }
    }

    // New method to find the next assigned lead for the current user
    @AuraEnabled
    public static String findNextAssignedLead(Id currentLeadId) {
        System.debug('Finding next assigned lead for user: ' + UserInfo.getUserId());

        // Get the current user ID
        Id currentUserId = UserInfo.getUserId();

        // Query to find the next assigned lead for the user, excluding the current lead
        List<Lead> nextLeads = [SELECT Id 
                                FROM Lead 
                                WHERE OwnerId = :currentUserId 
                                  AND Id != :currentLeadId
                                ORDER BY CreatedDate ASC 
                                LIMIT 1];

        if (!nextLeads.isEmpty()) {
            System.debug('Next assigned lead found. Lead ID: ' + nextLeads[0].Id);
            return nextLeads[0].Id;
        } else {
            System.debug('No next lead found for user.');
            return null;
        }
    }
}