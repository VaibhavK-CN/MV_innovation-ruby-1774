trigger TaskTrigger on Task (after insert) {
    List<Task_Log__e> eventsToPublish = new List<Task_Log__e>();

    System.debug('Task Trigger started.');

    for (Task task : Trigger.new) {
        System.debug('Processing task: ' + task);
        System.debug('Task WhoId: ' + task.WhoId);
        System.debug('Task Status: ' + task.Status);

        if (task.WhoId != null && task.Status == 'Completed') {
            Task_Log__e eventRecord = new Task_Log__e(
                WhoID__c = task.WhoId,
                Task_Status__c = task.Status,
                Subject__c = task.Subject
            );

            System.debug('Event record created: ' + eventRecord);

            eventsToPublish.add(eventRecord);
        }
    }

    if (!eventsToPublish.isEmpty()) {
        try {
            EventBus.publish(eventsToPublish);
            System.debug('Events published successfully.');
        } catch (Exception e) {
            System.debug('Error publishing events: ' + e.getMessage());
        }
    }

    /*
    if (!leadIdsToUpdate.isEmpty()) {
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead lead : [SELECT Id, Show_Feedback_Component__c FROM Lead WHERE Id IN :leadIdsToUpdate]) {
            lead.Show_Feedback_Component__c = true;
            leadsToUpdate.add(lead);
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
    */
}