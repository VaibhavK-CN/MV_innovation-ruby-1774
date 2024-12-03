public with sharing class UserStatusController {
    

    // Fetch current user details
    @AuraEnabled(cacheable=true)
    public static User getCurrentUser() {
        return [SELECT Id, Name, Availability_Status__c 
                FROM User 
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1];
    }

    // Update user status and manage lead assignment for multiple users
    @AuraEnabled
    public static String updateUserStatus(String status) {
        try {
            // Get current user along with Profile Name
            User currentUser = [SELECT Id, Name, Availability_Status__c, Profile.Name 
                                FROM User 
                                WHERE Id = :UserInfo.getUserId()
                                LIMIT 1];

            // Log current status before updating
            System.debug('Current status for user ' + currentUser.Name + ' is: ' + currentUser.Availability_Status__c);
            
            // Update the Availability Status for the user
            currentUser.Availability_Status__c = status;
            update currentUser;
            System.debug('User ' + currentUser.Name + ' status updated to: ' + status);

            // Handle lead assignment based on the new status
            if (status == 'Logged In') {
                String leadUrl = assignLeadToUser(currentUser.Id); // Store the assigned lead ID
                System.debug('Lead assigned to user ' + currentUser.Name + ' with URL: ' + leadUrl);
                return leadUrl;  // Return the URL of the lead record
            } else if (status == 'Logged Out' || status == 'Break') {
                releaseLeadFromUser(currentUser.Id);
                System.debug('Lead released for user ' + currentUser.Name);
            }

            return null;  // Return null if not 'Logged In' status

        } catch (DmlException dmlEx) {
            // Log the DML exception error details
            System.debug('DML Error: ' + dmlEx.getMessage());
            throw new AuraHandledException('Error updating status. Please try again later.');
        } catch (Exception e) {
            // Log general exception
            System.debug('General Error: ' + e.getMessage());
            throw new AuraHandledException('Error updating status. Please try again later.');
        }
    }

    // Assign the best lead from Call Agent Queue to the user
    private static String assignLeadToUser(Id userId) {
        try {
            // Get the Call Agent Queue ID
            Id callAgentQueueId = [SELECT Id 
                                   FROM Group 
                                   WHERE Name = 'Call Agent Queue' 
                                   AND Type = 'Queue' 
                                   LIMIT 1].Id;

            // Get the best lead in the queue
            Lead bestLead = [SELECT Id, OwnerId 
                             FROM Lead 
                             WHERE OwnerId = :callAgentQueueId 
                             ORDER BY Lead_Score__c ASC 
                             LIMIT 1];

            if (bestLead != null) {
                bestLead.OwnerId = userId;
                update bestLead;
                System.debug('Lead ' + bestLead.Id + ' assigned to user ' + userId);

                // Return the lead URL for redirection
                return '/' + bestLead.Id;  // Return the URL of the lead detail page
            } else {
                System.debug('No leads available in the Call Agent Queue for assignment.');
                return null;  // Return null if no lead is available
            }
        } catch (Exception e) {
            System.debug('Error assigning lead: ' + e.getMessage());
            return null;  // Return null if an error occurs
        }
    }

    // Release the lead assigned to the user back to the Call Agent Queue
    private static void releaseLeadFromUser(Id userId) {
        try {
            // Get the Call Agent Queue ID
            Id callAgentQueueId = [SELECT Id 
                                   FROM Group 
                                   WHERE Name = 'Call Agent Queue' 
                                   AND Type = 'Queue' 
                                   LIMIT 1].Id;

            // Get the leads assigned to the user
            List<Lead> userLeads = [SELECT Id 
                                    FROM Lead 
                                    WHERE OwnerId = :userId];

            // Release each lead back to the Call Agent Queue
            for (Lead lead : userLeads) {
                lead.OwnerId = callAgentQueueId;
            }

            if (!userLeads.isEmpty()) {
                update userLeads;
                System.debug('Released ' + userLeads.size() + ' leads from user ' + userId + ' back to the Call Agent Queue.');
            } else {
                System.debug('No leads to release for user ' + userId);
            }
        } catch (Exception e) {
            System.debug('Error releasing lead: ' + e.getMessage());
        }
    }
}