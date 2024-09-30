public class OneLeadWhenLeadPoolCreated {
    public static void whenLeadPoolCreated(List<Lead_Pool__c> leadPoolList){
        System.debug('leadPoolList '+leadPoolList);
        SET<Id> leadIds = New SET<Id>();
        SET<Id> LpOwnerIds = New SET<Id>();
        List<Lead> leadToUpdated = New List<Lead>();
        for(Lead_Pool__c lePool: leadPoolList){
            leadIds.add(lePool.LeadId__c);
            System.debug('leadIds '+leadIds);
            System.debug('lePool '+lePool);
            LpOwnerIds.add(lePool.UserId__c);
            System.debug('LpOwnerIds'+LpOwnerIds);
        }
        
        List<Lead> leadList = [SELECT Id,Name,OwnerId,Owner.Profile.Name,Notes__c FROM Lead WHERE OwnerId IN:LpOwnerIds AND Notes__c =null];
  
        system.debug('leadList '+leadList);
        if(leadList.isEmpty()){
            Map<Id,Lead> leadMapList = new Map<Id,Lead>([SELECT Id,Name,Notes__c,OwnerId,Owner.Profile.Name FROM Lead WHERE Id IN: leadIds AND Owner.Profile.Name = 'System Administrator' AND Notes__c = Null LIMIT 1]);
            System.debug('leadMapList '+leadMapList);
            if(!leadMapList.isEmpty()){
                for(Lead_Pool__c lePool: leadPoolList){
                    Lead le = leadMapList.get(lePool.LeadId__c);
                    le.OwnerId = lePool.UserId__c;
                    le.Status = 'Distributed';
                    leadToUpdated.add(le);
                    System.debug('leadToUpdated '+leadToUpdated);
                }
            }
        }
        if(!leadToUpdated.isEmpty()){
            update leadToUpdated;
        }
    }
    
    public static void whenLeadPoolCreatedForLifeIns(List<Lead_Pool__c> leadPoolList){
        System.debug('leadPoolList '+leadPoolList);
        SET<Id> LifeInsId = New SET<Id>();
        SET<Id> LpOwnerIds = New SET<Id>();
        List<LifeInsurance__c> lifeInsToUpdated = New List<LifeInsurance__c>();
        for(Lead_Pool__c lePool: leadPoolList){
            LifeInsId.add(lePool.Life_Insurance__c);
            System.debug('LifeInsId '+LifeInsId);
            System.debug('lePool '+lePool);
            LpOwnerIds.add(lePool.UserId__c);
            System.debug('LpOwnerIds'+LpOwnerIds);
        }
        
        List<LifeInsurance__c> lifeInsList = [SELECT Id,Name,OwnerId,Owner.Profile.Name,Notes__c FROM LifeInsurance__c WHERE OwnerId IN:LpOwnerIds AND Notes__c =null];
  
        system.debug('lifeInsList '+lifeInsList);
        if(lifeInsList.isEmpty()){
            Map<Id,LifeInsurance__c> lifeInsMapList = new Map<Id,LifeInsurance__c>([SELECT Id,Name,Notes__c,OwnerId,Owner.Profile.Name FROM LifeInsurance__c WHERE Id IN: LifeInsId AND Owner.Profile.Name = 'System Administrator' AND Notes__c = Null LIMIT 1]);
            System.debug('lifeInsMapList '+lifeInsMapList);
            if(!lifeInsMapList.isEmpty()){
                for(Lead_Pool__c lePool: leadPoolList){
                    LifeInsurance__c le = lifeInsMapList.get(lePool.Life_Insurance__c);
                    le.OwnerId = lePool.UserId__c;
                    le.Lead_Status__c = 'Distributed';
                    lifeInsToUpdated.add(le);
                    System.debug('lifeInsToUpdated '+lifeInsToUpdated);
                }
            }
        }
        try{
        if(!lifeInsToUpdated.isEmpty()){
            update lifeInsToUpdated;
        }
        }
        catch(DmlException e){
            system.debug('Error of Life Insurance leadPool Creation'+e);
        }
    }
}