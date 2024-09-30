public class StatusUpdateOfLifeIns {
    public static void updateStatusBO(List<LifeInsurance__c>lifeInsList){
        Set<Id> userIds = new Set<Id>();
        List<LifeInsurance__c> lifeInsListToBeUpdated = New List<LifeInsurance__c>();
        Map<Id,User> userMap = New Map<Id,User>([SELECT Id,Name,Profile.Name FROM User WHERE Profile.Name ='Backoffice']);
        if(!lifeInsList.isEmpty()){
        for(LifeInsurance__c lifeIns:lifeInsList){
         //   System.debug('Owner.Profile.Name '+Owner.Profile.Name);
         User us = userMap.get(lifeIns.OwnerId);
            if(us!=null){
            if(lifeIns.OwnerId == us.Id &&  lifeIns.Lead_Status__c !=null){
                lifeIns.Lead_Status__c = 'Send to BO: Submitted';
              //  lifeInsListToBeUpdated.add(lifeIns);
              System.debug('lifeInsListToBeUpdated '+lifeInsListToBeUpdated);
            }     
        }
        }
    }
      //  update lifeInsListToBeUpdated;
    }
    public static void updateNoteswithFeedback(List<LifeInsurance__c>lifeInsList){
        for(LifeInsurance__c LifeIns:lifeInsList){
            if(LifeIns.Feedback__c!=null){
                LifeIns.Notes__c = LifeIns.Feedback__c;
            }
        }
    }

}