public class NotReachedLeadController {
    public static void handleLeadsToHoldingQueue(List<Lead> newLeads, Map<Id, Lead> oldLeads) {
        Id callAgentQueueId = [SELECT Id FROM Group WHERE Name = 'Call Agent Queue' AND Type = 'Queue' LIMIT 1].Id;
        Id holdingQueueId = [SELECT Id FROM Group WHERE Name = 'Holding Queues' AND Type = 'Queue' LIMIT 1].Id;
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead lead : newLeads) {
            Lead oldLead = oldLeads.get(lead.Id);
            if (lead.Not_Reached_Count__c == 5 && 
                lead.Not_Reached_Count__c != oldLead.Not_Reached_Count__c &&
                lead.OwnerId == callAgentQueueId) {
                lead.OwnerId = holdingQueueId;
                lead.Holding_Queue_Assigned_Date__c = System.today(); // Store today's date to track when the lead entered the holding queue
                leadsToUpdate.add(lead);
            }
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
    public static void handleLeadsToCallAgentQueue(List<Lead> newLeads) {
        Id callAgentQueueId = [SELECT Id FROM Group WHERE Name = 'Call Agent Queue' AND Type = 'Queue' LIMIT 1].Id;
        List<User> callAgentUsers = [SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :callAgentQueueId) AND IsActive = TRUE];
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead lead : newLeads) {
            if (lead.OwnerId == callAgentQueueId) {
                Date holdingQueueAssignedDate = lead.Holding_Queue_Assigned_Date__c;
                if (holdingQueueAssignedDate != null && System.today() >= holdingQueueAssignedDate.addDays(30)) {
                    User currentOwner = [SELECT Id FROM User WHERE Id = :lead.OwnerId LIMIT 1];
                    Integer currentIndex = -1;
                    for (Integer i = 0; i < callAgentUsers.size(); i++) {
                        if (callAgentUsers[i].Id == currentOwner.Id) {
                            currentIndex = i;
                            break;
                        }
                    }
                    if (currentIndex >= 0) {
                        Integer nextIndex = currentIndex + 1;
                        if (nextIndex >= callAgentUsers.size()) {
                            nextIndex = 0;
                        }

                        lead.OwnerId = callAgentUsers[nextIndex].Id;
                    } else if (callAgentUsers.size() == 1) {
                        lead.OwnerId = callAgentUsers[0].Id;
                    }
                    
                    leadsToUpdate.add(lead);
                }
            }
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
}