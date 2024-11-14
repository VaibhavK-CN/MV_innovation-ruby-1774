public with sharing class PriorityLeadController {
    @AuraEnabled(cacheable=true)
    public static Lead getHighestPriorityLead() {
        Id userId = UserInfo.getUserId();
    
        List<Lead> leads = [SELECT Id, Name, Lead_Score__c FROM Lead WHERE OwnerId = :userId ORDER BY Lead_Score__c DESC LIMIT 1];
        
        if (!leads.isEmpty()) {
            return leads[0];
        } else {
            throw new AuraHandledException('No leads found for the user.');
        }
    }
}