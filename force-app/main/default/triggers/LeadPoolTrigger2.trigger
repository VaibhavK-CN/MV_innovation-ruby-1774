trigger LeadPoolTrigger2 on Lead (after update, Before Insert, Before Update) {
    System.debug('Trigger is fired');
    if(Trigger.isAfter && Trigger.isUpdate){
            OneLeadAtTimeClass.UpdateLeadOwnerAsCallAgent(Trigger.new); 
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            UpdateLeadNotesWithFeedback.updateNotes(trigger.new);
            CommissionCalculationCntrl.commissionCalculate(Trigger.new);
            AgeDeductibleValidation.addErrorOverAge(Trigger.new);
        }
            if(Trigger.isUpdate){
            UpdateLeadNotesWithFeedback.updateNotes(trigger.new);
            CommissionCalculationCntrl.commissionCalculate(Trigger.new);
           // AgeDeductibleValidation.updateAge(Trigger.new);
        }
    }
}