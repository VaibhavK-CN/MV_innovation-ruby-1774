public class OldestLeadUpdater {

    @InvocableMethod(label='Update Oldest Lead Field' description='Updates a checkbox field on the oldest Lead record for a specific owner')
    public static List<Lead> updateOldestLeadField(List<Id> ownerIds) {
        List<Lead> leadsToUpdate = [
            SELECT Id, CreatedDate, Assigned__c, Status
            FROM Lead 
            WHERE OwnerId IN :ownerIds AND Status NOT IN ('Converted', 'Cancelled') 
            ORDER BY CreatedDate ASC 
            LIMIT 1
        ];

        if (!leadsToUpdate.isEmpty()) {
            Lead oldestLead = leadsToUpdate[0];

            // Set the Assigned__c field to true for the oldest Lead record
            oldestLead.Assigned__c = true;
            System.debug(oldestLead.id);
            System.debug(oldestLead.Assigned__c);

            // Check if the current record is 'Cancelled' or 'Converted'
            if (oldestLead.Status == 'Cancelled' || oldestLead.Status == 'Converted') {
                // If yes, find the second oldest lead and update its Assigned__c to true
                List<Lead> secondOldestLeadToUpdate = [
                    SELECT Id, Assigned__c 
                    FROM Lead 
                    WHERE OwnerId IN :ownerIds AND Id != :oldestLead.Id AND Status NOT IN ('Converted', 'Cancelled')
                    ORDER BY CreatedDate ASC 
                    LIMIT 1
                ];

                if (!secondOldestLeadToUpdate.isEmpty()) {
                    Lead secondOldestLead = secondOldestLeadToUpdate[0];
                    secondOldestLead.Assigned__c = true;
                    System.debug(secondOldestLead.id);
                    System.debug(secondOldestLead.Assigned__c);

                    // Update the second oldest Lead record
                    update secondOldestLead;
                }
            }

            // Update the Lead record
            update oldestLead;

            // Set the Assigned__c field to false for all other Lead records for the same owner
            List<Lead> otherLeadsToUpdate = [
                SELECT Id, Assigned__c 
                FROM Lead 
                WHERE OwnerId IN :ownerIds AND Id != :oldestLead.Id AND Status NOT IN ('Converted', 'Cancelled')
            ];

            for (Lead leadToUpdate : otherLeadsToUpdate) {
                leadToUpdate.Assigned__c = false;
                System.debug(leadToUpdate.id);
                System.debug(leadToUpdate.Assigned__c);
            }

            // Update the other Lead records
            update otherLeadsToUpdate;
        }

        return leadsToUpdate;
    }

    private static Boolean isExecuting = false;

    public static void afterUpdateHandler(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        if (!isExecuting) {
            isExecuting = true;

            List<Id> ownerIdsToUpdate = new List<Id>();
            for (Lead lead : newLeads) {
                ownerIdsToUpdate.add(lead.OwnerId);
            }

            List<Id> distinctOwnerIds = new List<Id>(new Set<Id>(ownerIdsToUpdate));

            OldestLeadUpdater.updateOldestLeadField(distinctOwnerIds);

            isExecuting = false;
        }
    }
}