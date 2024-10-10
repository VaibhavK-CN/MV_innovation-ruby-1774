global class LeadScoreBatch implements Database.Batchable<sObject>, Database.Stateful {
    // List of newly created or updated leads
    private List<Lead> newLeads;

    // Constructor to pass new leads from the trigger
    public LeadScoreBatch(List<Lead> leadsToProcess) {
        this.newLeads = leadsToProcess;
    }

    // Start method to define the query and records to process
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all leads that already have a lead score, sorted by Status, Created Date, Time, and Lead Number
        return Database.getQueryLocator([
            SELECT Id, Lead_Score__c, Status, CreatedDate, Lead_Number__c 
            FROM Lead 
            WHERE Lead_Score__c != null 
            ORDER BY Status, CreatedDate, Lead_Number__c
        ]);
    }

    // Execute method to process each batch
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        // Get the highest current lead score
        Integer highestScore = 0;
        
        // Fetch the highest score from the scope (if any leads have scores already)
        if (scope.size() > 0) {
            Lead highestScoredLead = (Lead)scope[scope.size() - 1];  // Get the last lead in the sorted list
            highestScore = (highestScoredLead.Lead_Score__c!= null) ? Integer.valueOf(highestScoredLead.Lead_Score__c) : 0;
        }

        // Sort new leads based on:
        // 1. Status__c (Super Hot > Hot > Warm > Cold)
        // 2. CreatedDate (earliest first)
        // 3. CreatedTime__c (earliest within same day)
        // 4. Lead Number__c (lowest first)
        newLeads.sort(new LeadComparator());

        // Assign scores to new leads
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead lead : newLeads) {
            highestScore++;  // Increment score for the new lead
            lead.Lead_Score__c = highestScore;  // Assign the score to the lead
            leadsToUpdate.add(lead);
        }

        // Update leads with new scores
        if (leadsToUpdate.size() > 0) {
            update leadsToUpdate;
        }
    }

    // Finish method (optional) to run any post-processing or logging
    global void finish(Database.BatchableContext BC) {
        // Optionally add logging, notifications, or further actions here
        System.debug('Batch processing completed. Leads scored.');
    }

    // Custom comparator class to handle the sorting based on the criteria
    global class LeadComparator implements Comparator<Lead> {
        public Integer compare(Lead lead1, Lead lead2) {
            // 1. Compare by Status (Super Hot > Hot > Warm > Cold)
            Integer status1 = mapStatusToRank(lead1.Status);
            Integer status2 = mapStatusToRank(lead2.Status);
                if (status1 != status2) {
                 return (status1 < status2) ? -1 : 1; // Higher priority status has a lower rank number
            }

            // 2. Compare by Created Date
            if (lead1.CreatedDate != lead2.CreatedDate) {
            return (lead1.CreatedDate < lead2.CreatedDate) ? -1 : 1;
        }


            // 4. Compare by Lead Number (smallest is better)
            return lead1.Lead_Number__c.compareTo(lead2.Lead_Number__c);
        }

        // Helper function to map Status to a rank value
        private Integer mapStatusToRank(String status) {
            if (status == 'Super Hot') return 1;
            if (status == 'Hot') return 2;
            if (status == 'Warm') return 3;
            return 4;  // Cold is the lowest rank
        }
    }
}