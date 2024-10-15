public with sharing class LeadControllerNextLead {
    private static Decimal lastPriority = 0; // Track the last fetched priority
    private static Integer leadIndex = 0; // Track the index of leads for the current priority
    private static List<Lead> leads = new List<Lead>(); // Store the fetched leads

    @AuraEnabled(cacheable=true)
    public static List<Lead> getNextLead() {
        // Check if we need to fetch leads for the next priority
        if (leads.isEmpty() || leadIndex >= leads.size()) {
            leads = [
                SELECT Id, Name, Priority__c, CreatedDate
                FROM Lead
                WHERE Priority__c > :lastPriority
                ORDER BY Priority__c ASC, CreatedDate ASC
                LIMIT 2000 // Add a limit to avoid fetching too many records at once
            ];
            leadIndex = 0; // Reset the index for the new set of leads
        }

        // If we have leads, return the next one
        // if (!leads.isEmpty() && leadIndex < leads.size()) {
        //     Lead nextLead = leads[leadIndex];
        //     leadIndex++;
            
        //     lastPriority = nextLead.Priority__c; // Update the lastPriority
        //     return nextLead;
        // }

        return leads; // No more leads available
    }
}