trigger LeadTrigger on Lead (after insert, after update) {
    System.debug('--- LeadTrigger execution started ---');
    System.debug('Trigger context: ' + (Trigger.isInsert ? 'Insert' : 'Update') + ', After: ' + Trigger.isAfter);

    // Check recursion
    if (TriggerHelper.isTriggerAllowed()) {
        System.debug('Recursion allowed. Processing trigger logic.');
        try {
            Boolean shouldRunBatch = false;
            List<Id> newLeadIds = new List<Id>();
            List<Id> leadsForConsultantQueue = new List<Id>();
            String leadIdForQueueUpdate;

            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    System.debug('Processing after insert trigger for Lead.');

                    // Handle new leads
                    for (Lead lead : Trigger.new) {
                        System.debug('New Lead ID identified for Call Agent Queue: ' + lead.Id);
                        newLeadIds.add(lead.Id);
                    }

                    // Call helper method to assign leads to queue
                    if (!newLeadIds.isEmpty()) {
                        System.debug('Calling LeadAssignmentHelper to assign new leads to Call Agent Queue. Lead IDs: ' + newLeadIds);
                        LeadAssignmentHelper.assignNewLeadsToQueueAsync(newLeadIds);
                        shouldRunBatch = true;
                    } else {
                        System.debug('No new Lead IDs found for Call Agent Queue assignment.');
                    }
                }

                if (Trigger.isUpdate) {
                    System.debug('Processing after update trigger for Lead.');

                    for (Lead lead : Trigger.new) {
                        Lead oldLead = Trigger.oldMap != null ? Trigger.oldMap.get(lead.Id) : null;

                        // Check for Appointment Status change
                        if (oldLead != null && 
                            lead.Latest_Appointment_Status__c == 'Appointment Scheduled' && 
                            oldLead.Latest_Appointment_Status__c != 'Appointment Scheduled') {
                            System.debug('Lead marked as "Appointment Scheduled". ID: ' + lead.Id);
                            leadsForConsultantQueue.add(lead.Id);
                        }

                        // Check if Lead_Temperature__c has changed
                        if (oldLead != null && lead.Lead_Temperature__c != oldLead.Lead_Temperature__c) {
                            System.debug('Lead_Temperature__c changed for Lead ID: ' + lead.Id);
                            shouldRunBatch = true;
                        }

                        // Handle Feedback updates
                        if (oldLead != null && 
                            (lead.Feedback__c != oldLead.Feedback__c || 
                             lead.Latest_Sub_Feedback__c != oldLead.Latest_Sub_Feedback__c)) {
                            System.debug('Feedback or Sub-Feedback updated for Lead ID: ' + lead.Id);
                            leadIdForQueueUpdate = lead.Id;

                            // Assign new lead to user based on feedback
                            String preferredLanguage = lead.Langauge_Prefered__c;
                            System.debug('Calling LeadAssignmentHelper to assign new lead to user. Preferred Language: ' + preferredLanguage);
                            LeadAssignmentHelper.assignNewLeadToUser(preferredLanguage, UserInfo.getUserId(), lead.Id);
                        }
                    }

                    // Assign leads to Consultant_Health_Inc queue
                    if (!leadsForConsultantQueue.isEmpty()) {
                        System.debug('Calling LeadAssignmentHelper to assign leads to Consultant_Health_Inc Queue. Lead IDs: ' + leadsForConsultantQueue);
                        LeadAssignmentHelper.assignLeadsToConsultantQueueAsync(leadsForConsultantQueue);
                    } else if (leadIdForQueueUpdate != null) {
                        System.debug('Calling LeadAssignmentHelper to update Lead Owner to Call Agent Queue. Lead ID: ' + leadIdForQueueUpdate);
                        LeadAssignmentHelper.updateLeadOwnerToQueueAsync(new List<Id>{ leadIdForQueueUpdate });
                    } else {
                        System.debug('No updates required for Consultant_Health_Inc Queue or Call Agent Queue.');
                    }
                }
            }

            // Execute LeadScoreBatch if necessary
            if (shouldRunBatch) {
                System.debug('Executing LeadScoreBatch.');
                Database.executeBatch(new LeadScoreBatch(), 2000);
            } else {
                System.debug('LeadScoreBatch execution skipped.');
            }
        } finally {
            // Reset recursion control
            System.debug('Resetting recursion control in TriggerHelper.');
            TriggerHelper.resetTrigger();
        }
    } else {
        System.debug('Recursion detected. Trigger execution skipped.');
    }

    System.debug('--- LeadTrigger execution ended ---');
}