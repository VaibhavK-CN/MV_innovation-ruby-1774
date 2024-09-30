trigger EventTriggerSharingLead on Event (Before Insert,After Update,before Update,After Insert) {
   // LeadNotesUpdate.updateLead(Trigger.new);
    if(trigger.isBefore && Trigger.isInsert){
        LeadNotesUpdate.assigneeUpdate(Trigger.New);
    }
    
   /* if(Trigger.isBefore){
        LeadNotesUpdate.updateDueDate(Trigger.new,Trigger.oldMap);
    }*/
    
     if(Trigger.isAfter){
         if(Trigger.isInsert || Trigger.isUpdate){
             ChaneLeadOwnerUpdateAsinee.updateLeadOwner(Trigger.New);
         }
       
    }
    
}