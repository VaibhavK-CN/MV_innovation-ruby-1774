trigger SetLeadPriority on Lead (before insert, before update) {
    for (Lead lead : Trigger.new) {
        if (lead.Status == 'Super Hot') {
            lead.Priority__c = 1;  // Assuming Priority__c is the custom field for Priority
        } else if (lead.Status == 'Hot') {
            lead.Priority__c = 2;
        } else if (lead.Status == 'Warm') {
            lead.Priority__c = 3;
        } else if (lead.Status == 'Cold') {
            lead.Priority__c = 4;
        } else {
            lead.Priority__c = null;  // Or some default value if needed
        }
    }
}