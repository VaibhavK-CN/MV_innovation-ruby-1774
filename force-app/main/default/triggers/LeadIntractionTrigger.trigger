trigger LeadIntractionTrigger on Lead_Interaction_Detail__c (after insert) {
    Map<Id, Integer> leadNotInterestedCountMap = new Map<Id, Integer>();
    Set<Id> leadIds = new Set<Id>();
    for (Lead_Interaction_Detail__c lid : Trigger.New) {
        if (lid.Lead__c != null && lid.Sub_Feedback__c == 'Not Interested / Wrong Timing') {
            leadIds.add(lid.Lead__c);
        }
    }
    if (!leadIds.isEmpty()) {
        List<AggregateResult> results = [
            SELECT Lead__c, COUNT(Id) totalCount
            FROM Lead_Interaction_Detail__c
            WHERE Lead__c IN :leadIds
            AND Sub_Feedback__c = 'Not Interested / Wrong Timing'
            GROUP BY Lead__c
        ];
        for (AggregateResult ar : results) {
            Id leadId     = (Id)ar.get('Lead__c');
            Integer count = (Integer)ar.get('totalCount');
            leadNotInterestedCountMap.put(leadId, count);
        }
    }
    List<Lead> leadsToUpdate = new List<Lead>();
    for (Id leadId : leadNotInterestedCountMap.keySet()) {
        Lead leadToUpdate                   = new Lead(Id = leadId);
        leadToUpdate.Not_Intrested_Count__c = leadNotInterestedCountMap.get(leadId);
        leadsToUpdate.add(leadToUpdate);
    }
    if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
    }
}