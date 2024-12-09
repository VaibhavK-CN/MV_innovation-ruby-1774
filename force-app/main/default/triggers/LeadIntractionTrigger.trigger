trigger LeadIntractionTrigger on Lead_Interaction_Detail__c (after insert) {
    Map<Id, Integer> leadNotInterestedCountMap = new Map<Id, Integer>();
    Map<Id, Integer> leadNotReachedCountMap = new Map<Id, Integer>();
    Set<Id> leadIds = new Set<Id>();
    for (Lead_Interaction_Detail__c lid : Trigger.New) {
        if (lid.Lead__c != null) {
            if (lid.Sub_Feedback__c == 'Not Interested / Wrong Timing') {
                leadIds.add(lid.Lead__c);
            }
            if (lid.Sub_Feedback__c == 'Not Reached') {
                leadIds.add(lid.Lead__c);
            }
        }
    }
    if (!leadIds.isEmpty()) {
        List<AggregateResult> results = [
            SELECT Lead__c, 
                   COUNT(Id) totalCount,
                   Sub_Feedback__c
            FROM Lead_Interaction_Detail__c
            WHERE Lead__c IN :leadIds
            AND (Sub_Feedback__c = 'Not Interested / Wrong Timing' OR Sub_Feedback__c = 'Not Reached')
            GROUP BY Lead__c, Sub_Feedback__c
        ];
        for (AggregateResult ar : results) {
            Id leadId           = (Id)ar.get('Lead__c');
            String feedbackType = (String)ar.get('Sub_Feedback__c');
            Integer count       = (Integer)ar.get('totalCount');
            
            if (feedbackType == 'Not Interested / Wrong Timing') {
                leadNotInterestedCountMap.put(leadId, count);
            } else if (feedbackType == 'Not Reached') {
                leadNotReachedCountMap.put(leadId, count);
            }
        }
    }
    List<Lead> leadsToUpdate = new List<Lead>();
    for (Id leadId : leadNotInterestedCountMap.keySet()) {
        Lead leadToUpdate = new Lead(Id = leadId);
        leadToUpdate.Not_Intrested_Count__c = leadNotInterestedCountMap.get(leadId);
        if (leadNotReachedCountMap.containsKey(leadId)) {
            leadToUpdate.Not_Reached_Count__c = leadNotReachedCountMap.get(leadId);
        }

        leadsToUpdate.add(leadToUpdate);
    }
    if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
    }
}