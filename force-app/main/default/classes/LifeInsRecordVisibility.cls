public class LifeInsRecordVisibility {
    public static void UpdateLeadOwnerAsCallAgent(List<LifeInsurance__c> LifeInsListNew) {
        Try{
            System.debug('LifeInsListNew '+LifeInsListNew);
            List<LifeInsurance__c> LifeInsListToBeUpdated = New List<LifeInsurance__c>();
            SET<Id> leadPoolIds = New SET<Id>();
            SET<Id> LifeInsIds = New SET<Id>();
            
            for(LifeInsurance__c lea:LifeInsListNew){
                LifeInsIds.add(lea.Id);
            }
            List<Lead_Pool__c> leadPoolList =[SELECT Id, Name, Life_Insurance__c, UserId__c, Life_Insurance__r.Name,Life_Insurance__r.Owner.Profile.Name, UserId__r.Name,UserId__r.Profile.Name FROM Lead_Pool__c];
            System.debug('leadPoolList '+leadPoolList);
            LifeInsurance__c valueOfLifeInsNew;
            LifeInsurance__c newLifeInsProfileName;
            Map<Id, LifeInsurance__c> mapFromListNewLIfeIns = new Map<Id, LifeInsurance__c>(LifeInsListNew);
            System.debug('leadPoolList '+leadPoolList);
            for(Lead_Pool__c Lpool:leadPoolList){
                // Map<Id, Lead> mapFromListNewLIfeIns = new Map<Id, Lead>(LifeInsListNew);
                System.debug('Lpool outside loop '+Lpool);
                System.debug('map of life Ins '+mapFromListNewLIfeIns);
                System.debug('Lpool.UserId__r.Profile.Name '+Lpool.UserId__c);
                LifeInsurance__c leNew = mapFromListNewLIfeIns.get(Lpool.Life_Insurance__c);
                system.debug('leNew '+leNew);
                if (leNew != null) {
                    valueOfLifeInsNew = leNew;
                }
                
            }
            // system.debug('leNew map from list'+valueOfLifeInsNew);
            System.debug('newLifeInsProfileName '+newLifeInsProfileName);
            // System.debug('leNew.Owner.Profile.Name '+valueOfLifeInsNew.OwnerId);
            
            //  System.debug('leNew.Notes__c '+valueOfLifeInsNew.Notes__c);
            if(valueOfLifeInsNew != null){
                for(Lead_Pool__c Lpool:leadPoolList){
                    if(valueOfLifeInsNew.OwnerId == Lpool.UserId__c && valueOfLifeInsNew.Notes__c!=null){
                        System.debug('Lpool inside loop '+Lpool);
                        leadPoolIds.add(Lpool.Life_Insurance__c);
                    }          
                }
            }
            
            System.debug('leadPoolIds '+leadPoolIds);
            
            List<LifeInsurance__c>lifeInsList = [SELECT Id,Name,OwnerId,Notes__c FROM LifeInsurance__c Where Id IN:leadPoolIds AND Notes__c = Null LIMIT 1];
            System.debug('lifeInsList '+lifeInsList);
            Map<Id, LifeInsurance__c> mapFromList = new Map<Id, LifeInsurance__c>(lifeInsList);  
            Map<Id, Lead_Pool__c> mapFromLPList = new Map<Id, Lead_Pool__c>(leadPoolList); 
            
            for(Lead_Pool__c Lp:mapFromLPList.values()){
                LifeInsurance__c Le = mapFromList.get(Lp.Life_Insurance__c);
                System.debug('map of lead pool get lead id '+Lp);
                System.debug('get lead id from lead pool '+Le);
                if(le != null){
                    le.OwnerId = Lp.UserId__c; 
                    le.Lead_Status__c = 'Distributed';
                    LifeInsListToBeUpdated.add(le);
                    System.debug('LifeInsListToBeUpdated '+LifeInsListToBeUpdated);
                }  
            } 
            
            if(LifeInsListToBeUpdated.size()>0){
                update LifeInsListToBeUpdated;
                System.debug('LifeInsListToBeUpdated '+LifeInsListToBeUpdated);
            }
        }
        catch (Exception e) {
            // Handle the exception (e.g., log the error, send an email notification, etc.)
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
    
}