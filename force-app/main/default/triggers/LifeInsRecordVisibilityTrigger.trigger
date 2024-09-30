trigger LifeInsRecordVisibilityTrigger on LifeInsurance__c (after update,before Update) {
    System.debug('Trigger is fired for Life Insurance');
    
    if(Trigger.isAfter && Trigger.isUpdate){
        LifeInsRecordVisibility.UpdateLeadOwnerAsCallAgent(Trigger.new);
        // CommissionCalculationCntrl.totalCommissionCalculateForLegalProIns(Trigger.New);
    }
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        if(!PreventRecursion.isFirst){
            PreventRecursion.isFirst = true;
            StatusUpdateOfLifeIns.updateStatusBO(Trigger.new);
            StatusUpdateOfLifeIns.updateNoteswithFeedback(Trigger.new);
            //CommissionCalculationCntrl.totalCommissionCalculateForLegalProIns(Trigger.New);
            
            List<String> valList = new List<String>();
            for(LifeInsurance__c camp : Trigger.new) {
                if(camp.Commission_Legal_Protection__c!=null){
                    List<String> RateList = camp.Rate__c.split(';');
                    List<String> productNameList = camp.Products__c.split(';');
                    
                    List<String> commissionList = camp.Commission_Legal_Protection__c.split(';');
                    Integer count = 0;
                    for(String pnl : productNameList) {
                        valList.add(pnl+'['+RateList[count]+'] - '+commissionList[count]);
                        count++;
                    }
                    System.debug('Values: '+valList);
                    String commissionValues = String.join(valList, ',\n');
                    camp.Commission__c = commissionValues;
                }
            }
        }
    }
    
    
}