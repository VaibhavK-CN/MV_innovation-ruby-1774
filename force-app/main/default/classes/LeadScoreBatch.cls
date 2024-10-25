global class LeadScoreBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Integer currentRank; // Store the current rank starting from 1

    // Constructor
    public LeadScoreBatch() {
        this.currentRank = 0; // Start rank from 0 (will increment)
    }

    // Start method: Return all leads to be processed
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Starting the batch process for lead ranking.');
        return Database.getQueryLocator([SELECT Id, Lead_Temperature__c, CreatedDate, Lead_Number__c FROM Lead]);
    }

    // Execute method: Process each batch of leads
    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        if (scope.isEmpty()) {
            System.debug('No leads found in this batch scope.');
            return;
        }

        System.debug('Leads before sorting: ' + scope);

        // Sort leads based on Lead_Temperature__c, created date, and lead number
        scope.sort(new LeadComparator());

        System.debug('Leads after sorting: ' + scope);

        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead lead : scope) {
            currentRank++; // Increment rank for each lead
            lead.Lead_Score__c = currentRank; // Assign the rank
            
          
            System.debug('Lead: ' + lead.Id + ' | New Rank: ' + currentRank);
            leadsToUpdate.add(lead);
        }

        if (!leadsToUpdate.isEmpty()) {
            System.debug('Updating leads with new rankings: ' + leadsToUpdate);
            update leadsToUpdate;
        } else {
            System.debug('No leads to update in this batch.');
        }
    }

    // Finish method: End of batch process
    global void finish(Database.BatchableContext bc) {
        System.debug('Lead ranking batch job finished. Final rank assigned: ' + currentRank);
    }

    // Custom comparator class to handle the sorting based on the criteria
    global class LeadComparator implements Comparator<Lead> {
        public Integer compare(Lead lead1, Lead lead2) {
            // 1. Compare by Lead_Temperature__c (Super Hot > Hot > Warm > Cold)
            Integer tempRank1 = mapTemperatureToRank(lead1.Lead_Temperature__c);
            Integer tempRank2 = mapTemperatureToRank(lead2.Lead_Temperature__c);
            
            // Debug: Comparing temperatures
            System.debug('Comparing Lead_Temperature__c | Lead1: ' + lead1.Id + ' (Lead_Temperature__c: ' + lead1.Lead_Temperature__c + ') vs Lead2: ' + lead2.Id + ' (Lead_Temperature__c: ' + lead2.Lead_Temperature__c + ')');
            
            if (tempRank1 != tempRank2) {
                System.debug('Lead_Temperature__c ranks are different. TempRank1: ' + tempRank1 + ' vs TempRank2: ' + tempRank2);
                return tempRank1 - tempRank2; // Compare by temperature rank
            }

            // 2. Compare by Created Date (earlier is better)
            if (lead1.CreatedDate != null && lead2.CreatedDate != null) {
                Long time1 = lead1.CreatedDate.getTime();
                Long time2 = lead2.CreatedDate.getTime();

                // Debug: Comparing created dates
                System.debug('Comparing CreatedDate | Lead1: ' + lead1.Id + ' (CreatedDate: ' + lead1.CreatedDate + ') vs Lead2: ' + lead2.Id + ' (CreatedDate: ' + lead2.CreatedDate + ')');

                if (time1 != time2) {
                    System.debug('Created dates are different. Time1: ' + time1 + ' vs Time2: ' + time2);
                    return (time1 > time2) ? 1 : -1; // Compare by created date/time
                }
            } else if (lead1.CreatedDate == null) {
                return 1; // Null created date should be ranked lower
            } else if (lead2.CreatedDate == null) {
                return -1; // Null created date should be ranked lower
            }

            // 3. Compare by Lead Number (smaller is better)
            if (lead1.Lead_Number__c != null && lead2.Lead_Number__c != null) {
                // Debug: Comparing lead numbers
                System.debug('Comparing LeadNumber | Lead1: ' + lead1.Id + ' (LeadNumber: ' + lead1.Lead_Number__c + ') vs Lead2: ' + lead2.Id + ' (LeadNumber: ' + lead2.Lead_Number__c + ')');
                return lead1.Lead_Number__c.compareTo(lead2.Lead_Number__c); // Compare by lead number
            } else if (lead1.Lead_Number__c == null) {
                return 1; // Null Lead Number should be ranked lower
            } else if (lead2.Lead_Number__c == null) {
                return -1; // Null Lead Number should be ranked lower
            }

            // If all comparisons are equal, return 0
            return 0;
        }

        // Helper method to map Lead_Temperature__c to a rank
        private Integer mapTemperatureToRank(String temperature) {
            if (temperature == null) return 5; // Null temperature is considered lowest rank
            if (temperature == 'Super Hot') return 1;
            if (temperature == 'Hot') return 2;
            if (temperature == 'Warm') return 3;
            return 4; // Cold is the lowest rank
        }
    }
}