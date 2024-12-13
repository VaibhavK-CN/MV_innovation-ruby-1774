trigger A_LeadTrigger on Lead (after insert, after update) {
    System.debug('--- LeadTrigger execution started ---');
    System.debug('Trigger context: ' + (Trigger.isInsert ? 'Insert' : 'Update') + ', After: ' + Trigger.isAfter);

    // Check recursion
    if (TriggerHelper.isTriggerAllowed()) {
        System.debug('Recursion allowed. Processing trigger logic.');
        try {
            Boolean shouldRunBatch           = false;
            List<Id> newLeadIds              = new List<Id>(); //For newly inserted lead without PF Date Time
            List<Id> newLeadwithInteraction  = new List<Id>(); //For newly inserted lead with PF Date Time
            List<Id> leadsForConsultantQueue = new List<Id>(); //For Lead Updates with Appointments
            List<Id> leadIdForQueueUpdate    = new List<Id>(); //For Lead Updates without Appointments
            List<Id> leadIdForHoldingQueue   = new List<Id>(); //For Storing a holding lead ids
            

            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    Lead_Interaction_Detail__c LID = new Lead_Interaction_Detail__c();
                    System.debug('Processing after insert trigger for Lead.');

                    // Handle new leads
                    for (Lead lead : Trigger.new) {
                        //System.debug('New Lead ID identified for Call Agent Queue: ' + lead.Id);
                        if (lead.Preferred_Date_Time__c != null) {
                              newLeadwithInteraction.add(Lead.Id);
                        }
                        else{
                             newLeadIds.add(lead.Id);
                        }
                        
                    }

                    // Call helper method to assign leads to queue
                    if (!newLeadIds.isEmpty()) {
                        System.debug('Calling LeadAssignmentHelper to assign new leads to Call Agent Queue. Lead IDs: ' + newLeadIds);
                        LeadAssignmentHelper.assignNewLeadsToQueueAsync(newLeadIds);
                        shouldRunBatch = true;
                    } 
                     if (!newLeadwithInteraction.isEmpty()) {
                        System.debug('New leads with interaction: ' + newLeadwithInteraction);
                        shouldRunBatch = true;
                        // Call helper method with newLeadwithInteraction
                        LeadAssignmentHelper.assignLeadsToConsultantQueueAsync(newLeadwithInteraction);
                        // Debug the first element of the newLeadwithInteraction list
                        System.debug('Lead Sent for Consultant Queue: ' + newLeadwithInteraction[0]);
                         /////////////////////////////////Create Related Lead Interaction Record//////////////////////////////////
                        try {
                            List<Lead_Interaction_Detail__c> interactionDetails = new List<Lead_Interaction_Detail__c>();
                        
                            // Query the Lead records to get the Preferred_Date_Time__c field
                            List<Lead> leadsWithInteraction = [
                                SELECT Id, Preferred_Date_Time__c 
                                FROM Lead 
                                WHERE Id IN :newLeadwithInteraction
                            ];
                        
                            // Iterate through the queried Lead records
                            for (Lead lead : leadsWithInteraction) {
                                // Create a new Lead_Interaction_Detail__c record for each Lead
                                Lead_Interaction_Detail__c interactionDetail = new Lead_Interaction_Detail__c();
                                interactionDetail.Lead__c = lead.Id; // Assuming Lead__c is the relationship field
                                interactionDetail.Preferred_Date_Time__c = lead.Preferred_Date_Time__c;
                                interactionDetail.Comment__c = 'Self Interaction with Preferred Date/Time';
                                interactionDetail.Interaction_Type__c = 'Self';
                                interactionDetail.Feedback__c = 'Appointment planned';
                                interactionDetail.Sub_Feedback__c = 'Future appointment planned';
                        
                                interactionDetails.add(interactionDetail);
                            }
                        
                            // Insert the records
                            if (!interactionDetails.isEmpty()) {
                                insert interactionDetails;
                                System.debug('Successfully created Lead_Interaction_Detail__c records: ' + interactionDetails);
                            } else {
                                System.debug('No Lead_Interaction_Detail__c records to create.');
                            }
                        } catch (Exception e) {
                            System.debug('Error in createLeadInteractions: ' + e.getMessage());
                        }
                         ///////////////////////////////////////////////////////////////////////////////////////////////////////////
                         
                    }
                }

                if (Trigger.isUpdate && newLeadwithInteraction.isEmpty() && newLeadIds.isEmpty()) {
                    System.debug('Processing after update trigger for Lead.');
                    
                    for (Lead lead : Trigger.New) {
                        Lead oldLead = Trigger.oldMap != null ? Trigger.oldMap.get(lead.Id) : null;
                        
                        if(lead.Not_Intrested_Count__c != null && lead.Not_Intrested_Count__c != oldLead.Not_Intrested_Count__c){
                            leadIdForHoldingQueue.add(lead.Id);
                        }else if(lead.Not_Reached_Count__c == 5 && lead.Not_Reached_Count__c != oldLead.Not_Reached_Count__c){
                            leadIdForHoldingQueue.add(lead.Id);
                        }

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
                                 
                                     leadIdForQueueUpdate.add(lead.Id); 
                                 
                               
                        

                        }
                    }
                    //line added by tayab
                    
                    //line added by tayab
                    // Assign leads to Consultant_Health_Inc queue
                    if (!leadsForConsultantQueue.isEmpty()) {
                        System.debug('Calling LeadAssignmentHelper to assign leads to Consultant_Health_Inc Queue. Lead IDs: ' + leadsForConsultantQueue);
                        LeadAssignmentHelper.assignLeadsToConsultantQueueAsync(leadsForConsultantQueue);
                    } else if (!leadIdForQueueUpdate.isEmpty()) {
                        System.debug('Calling LeadAssignmentHelper to update Lead Owner to Call Agent Queue. Lead ID: ' + leadIdForQueueUpdate);
                        LeadAssignmentHelper.updateLeadOwnerToQueueAsync(leadIdForQueueUpdate);
                    } else if(!leadIdForHoldingQueue.isEmpty()) {
                        System.debug('Leads will be move to Holding Queue');
                        LeadAssignmentHelper.moveToHolding(leadIdForHoldingQueue);                        
                    }else{
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