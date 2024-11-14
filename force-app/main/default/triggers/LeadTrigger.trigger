trigger LeadTrigger on Lead (after insert, after update) {

    Boolean shouldRunBatch = false;
    Set<Id> usersWhoTriggeredEvent = new Set<Id>();

    System.debug('Lead Trigger Started. Context: ' + Trigger.operationType + ', Size: ' + Trigger.new.size());

    // Iterate through the trigger's leads
    for (Lead lead : Trigger.new) {
        Lead oldLead = Trigger.oldMap != null ? Trigger.oldMap.get(lead.Id) : null;

        // Check if Lead_Temperature__c has changed during an update or it's a new insert
        if (Trigger.isInsert || 
           (Trigger.isUpdate && oldLead != null && lead.Lead_Temperature__c != oldLead.Lead_Temperature__c)) {
            shouldRunBatch = true;
            System.debug('Lead_Temperature__c change detected. Lead ID: ' + lead.Id);
        }

        // Check if Feedback__c or Sub_Feedback__c has changed
        if (Trigger.isUpdate && oldLead != null && 
           (lead.Feedback__c != oldLead.Feedback__c || lead.Latest_Sub_Feedback__c != oldLead.Latest_Sub_Feedback__c)) {
            // Add the user who triggered the feedback update
            usersWhoTriggeredEvent.add(UserInfo.getUserId());
            System.debug('Feedback update detected. Lead ID: ' + lead.Id + ', User ID: ' + UserInfo.getUserId());

            // Update the current lead's OwnerId to Call Agent Queue
            LeadAssignmentHelper.updateLeadOwnerToQueue(lead.Id);

            // Fetch the preferred language of the lead
            String preferredLanguage = lead.Langauge_Prefered__c;
            System.debug('Preferred Language for the Lead: ' + preferredLanguage);

            // Assign a new lead to the user based on the preferred language, excluding the current lead
            LeadAssignmentHelper.assignNewLeadToUser(preferredLanguage, UserInfo.getUserId(), lead.Id);
        }
    }

    // If batch criteria are met, run the LeadScoreBatch for all leads
    if (shouldRunBatch) {
        System.debug('Batch criteria met. Executing LeadScoreBatch.');
        LeadScoreBatch leadBatch = new LeadScoreBatch();
        Database.executeBatch(leadBatch, 2000);
    } else {
        System.debug('Batch criteria not met. No batch execution.');
    }
}