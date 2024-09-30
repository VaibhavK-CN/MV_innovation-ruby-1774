public class LeadNotesUpdate {
   /* 
    public static void updateLead(List<Event> eventList){
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Event ev : eventList){
            leadIds.add(ev.WhoId);
        }
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, Name, Notes__c FROM Lead WHERE Id IN :leadIds]);
        
        for (Event ev : eventList){
            Lead le = leadMap.get(ev.WhoId);
            if (le != null) {
                le.Notes__c = ev.Notes__c;
                leadsToUpdate.add(le);
            }
        }
        
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
            system.debug('leadsToUpdate '+leadsToUpdate);
        }
    }
    
    public static void updateDueDate(List<Event> newEvents, Map<Id, Event> oldEventMap) {
        List<Event> eventListTobeUpdated = New List<Event>();
        for (Event evt : newEvents) {
            if (Trigger.isInsert || (Trigger.isUpdate && evt.EndDateTime != oldEventMap.get(evt.Id).EndDateTime)) {
                evt.Due_Date__c = evt.EndDateTime;
            }
        }
    }
    */
    public static void assigneeUpdate(List<Event> evList){
        List<User> userList = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name = 'Call Agent'];
        
        Map<Id, Profile> profMap = new Map<Id, Profile>();
        
        for (User user : userList) {
            profMap.put(user.Id, user.Profile);
        }
        
        List<User> us = [SELECT Id, Name, Profile.Name FROM User WHERE Name = 'Besard Berisha'];
        
        for (Event ev : evList) {
            if (profMap.containsKey(ev.OwnerId) && profMap.get(ev.OwnerId).Name == 'Call Agent') {
                // Assign the event to the admin (replace 'adminUserId' with the actual User Id of the admin)
                if(ev.Schdeule_for_consultant__c == True){
                ev.OwnerId = us[0].id;
                system.debug('event owner id after update '+ev.OwnerId);
            }
        }
    }
       // update evList;
    }
}