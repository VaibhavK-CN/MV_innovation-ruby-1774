global class AssignLeadToConsultantBatch implements Database.Batchable<SObject>, Schedulable {

    // Schedule the batch job
    global void execute(SchedulableContext SC) {
        System.debug('Executing scheduled job for AssignLeadToConsultantBatch...');
        Database.executeBatch(new AssignLeadToConsultantBatch(), 50);
    }

    // Define the query for leads with valid appointment times
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queueName = 'Consultant Health Inc';
        List<Group> consultantQueue = [
            SELECT Id 
            FROM Group 
            WHERE Name = :queueName AND Type = 'Queue'
        ];

        if (consultantQueue.isEmpty()) {
            System.debug('No Queue found with the name: ' + queueName);
            return Database.getQueryLocator([SELECT Id FROM Lead WHERE Id = null]);
        }

        Id queueId = consultantQueue[0].Id;
        System.debug('Queue ID for ' + queueName + ': ' + queueId);

        // Fetch leads associated with the queue and meeting the criteria
        Datetime currentTime = System.now();

        return Database.getQueryLocator([
            SELECT Id, Name, OwnerId, Latest_Appointment_Status__c, Langauge_Prefered__c,
                (SELECT Id, Preferred_Date_Time__c FROM Lead_Interaction_Details__r WHERE Preferred_Date_Time__c <= :currentTime)
            FROM Lead 
            WHERE Latest_Appointment_Status__c = 'Appointment Scheduled' 
              AND OwnerId = :queueId 
              AND Langauge_Prefered__c = 'German'
        ]);
    }

    // Process leads and assign them to consultants
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        Datetime currentTime = System.now();
        Time startOfDay = Time.newInstance(10, 0, 0, 0); // 2:00 AM
        Time endOfDay = Time.newInstance(17, 0, 0, 0);  // 2:00 PM

        if (currentTime.time() < startOfDay || currentTime.time() > endOfDay) {
            System.debug('Batch execution is outside the allowed time range (2:00 AM to 2:00 PM).');
            return;
        }

        // Fetch available consultants with preferred language as German and Lead_Assigned__c = false
        List<User> availableConsultants = [
            SELECT Id, Name, Lead_Assigned__c 
            FROM User 
            WHERE Availability_Status__c = 'Logged In'  
              AND Language__c = 'German'
              AND Lead_Assigned__c = false
        ];

        if (availableConsultants.isEmpty()) {
            System.debug('No consultants available for assignment.');
            return;
        }

        System.debug('Available Consultants: ' + availableConsultants);

        List<Lead> updatedLeads = new List<Lead>();
        List<User> updatedConsultants = new List<User>();
        List<Lead> unassignedLeads = new List<Lead>();
        Integer consultantIndex = 0;
        Integer totalConsultants = availableConsultants.size();

        for (Lead lead : scope) {
            if (consultantIndex >= totalConsultants) {
                unassignedLeads.add(lead); // Mark lead as unassigned if no consultants are left
                continue;
            }

            // Check if the lead's appointment time matches the current time
            Boolean isValidForAssignment = false;

            for (Lead_Interaction_Detail__c interaction : lead.Lead_Interaction_Details__r) {
                if (interaction.Preferred_Date_Time__c.date() == currentTime.date() &&
                    interaction.Preferred_Date_Time__c.time() <= currentTime.time()) {
                    isValidForAssignment = true;
                    break;
                }
            }

            if (!isValidForAssignment) {
                unassignedLeads.add(lead); // Add to unassigned if appointment time hasn't arrived
                continue;
            }

            User currentConsultant = availableConsultants[consultantIndex];

            // Assign the lead to the consultant
            lead.OwnerId = currentConsultant.Id;
            updatedLeads.add(lead);

            // Mark the consultant as having a lead
            currentConsultant.Lead_Assigned__c = true;
            updatedConsultants.add(currentConsultant);

            consultantIndex++;
        }

        try {
            // Update leads and consultants
            if (!updatedLeads.isEmpty()) {
                update updatedLeads;
                System.debug('Leads successfully updated: ' + updatedLeads);
            }

            if (!updatedConsultants.isEmpty()) {
                update updatedConsultants;
                System.debug('Consultants successfully updated: ' + updatedConsultants);
            }

            // Move unassigned leads to the Call Agent Queue
            if (!unassignedLeads.isEmpty()) {
                Id callAgentQueueId = [
                    SELECT Id 
                    FROM Group 
                    WHERE Name = 'Call Agent Queue' AND Type = 'Queue'
                    LIMIT 1
                ].Id;

                for (Lead lead : unassignedLeads) {
                    lead.OwnerId = callAgentQueueId;
                }
                update unassignedLeads;
                System.debug('Unassigned leads moved to Call Agent Queue: ' + unassignedLeads);
            }
        } catch (DmlException e) {
            System.debug('Error updating leads or consultants: ' + e.getMessage());
        }
    }

    // Finalize the batch and chain another batch job
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch process completed.');

        try {
            // Reset Lead_Assigned__c for consultants with no active leads
            List<User> consultantsToReset = [
                SELECT Id, Lead_Assigned__c 
                FROM User 
                WHERE Lead_Assigned__c = TRUE 
                  AND Id NOT IN (SELECT OwnerId FROM Lead WHERE Latest_Appointment_Status__c = 'Appointment Scheduled' 
                                 AND Langauge_Prefered__c = 'German')
            ];

            if (!consultantsToReset.isEmpty()) {
                for (User user : consultantsToReset) { 
                    user.Lead_Assigned__c = false;
                }
                update consultantsToReset;
                System.debug('Consultants reset for future assignments: ' + consultantsToReset);
            }
        } catch (Exception e) {
            System.debug('Error while resetting consultants: ' + e.getMessage());
        }

        // Add batch chaining
        try {
            System.debug('Chaining the next batch job...');
            Database.executeBatch(new AssignLeadToConsultantBatch(), 50);
        } catch (Exception e) {
            System.debug('Error while chaining batch: ' + e.getMessage());
        }
    }
}