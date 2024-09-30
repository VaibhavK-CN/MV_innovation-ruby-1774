public class OneLeadAtTimeClass {
    
    public static void UpdateLeadOwnerAsCallAgent(List<Lead> leadListNew) {
        Try{
            System.debug('leadListNew '+leadListNew);
            List<Lead> leadListToBeUpdated = New List<Lead>();
            SET<Id> leadPoolIds = New SET<Id>();
            SET<Id> LeadIds = New SET<Id>();
            for(Lead lea:leadListNew){
                LeadIds.add(lea.Id);
            }
            List<Lead_Pool__c> leadPoolList =[SELECT Id, Name, LeadId__c, UserId__c, LeadId__r.Name,LeadId__r.Owner.Profile.Name, UserId__r.Name,UserId__r.Profile.Name FROM Lead_Pool__c];
            System.debug('leadPoolList '+leadPoolList);
            Lead valueOfLeadNew;
            Lead newLeadProfileName;
            Map<Id, Lead> mapFromListNewLead = new Map<Id, Lead>(leadListNew);
            System.debug('leadPoolList '+leadPoolList);
            for(Lead_Pool__c Lpool:leadPoolList){
                // Map<Id, Lead> mapFromListNewLead = new Map<Id, Lead>(leadListNew);
                System.debug('Lpool outside loop '+Lpool);
                System.debug('Lpool.UserId__r.Profile.Name '+Lpool.UserId__c);
                Lead leNew = mapFromListNewLead.get(Lpool.LeadId__c);
                system.debug('leNew '+leNew);
                if (leNew != null) {
                    valueOfLeadNew = leNew;
                }
                
            }
            // system.debug('leNew map from list'+valueOfLeadNew);
            System.debug('newLeadProfileName '+newLeadProfileName);
            // System.debug('leNew.Owner.Profile.Name '+valueOfLeadNew.OwnerId);
            
            //  System.debug('leNew.Notes__c '+valueOfLeadNew.Notes__c);
            if(valueOfLeadNew != null){
                for(Lead_Pool__c Lpool:leadPoolList){
                    if(valueOfLeadNew.OwnerId == Lpool.UserId__c && valueOfLeadNew.Notes__c!=null){
                        System.debug('Lpool inside loop '+Lpool);
                        leadPoolIds.add(Lpool.LeadId__c);
                    }          
                }
            }
            
            System.debug('leadPoolIds '+leadPoolIds);
            
            List<Lead>leadList = [SELECT Id,Name,OwnerId,Notes__c FROM Lead Where Id IN:leadPoolIds AND Notes__c = Null LIMIT 1];
            System.debug('leadList '+leadList);
            Map<Id, Lead> mapFromList = new Map<Id, Lead>(leadList);  
            Map<Id, Lead_Pool__c> mapFromLPList = new Map<Id, Lead_Pool__c>(leadPoolList); 
            
            for(Lead_Pool__c Lp:mapFromLPList.values()){
                Lead Le = mapFromList.get(Lp.LeadId__c);
                System.debug('map of lead pool get lead id '+Lp);
                System.debug('get lead id from lead pool '+Le);
                if(le != null){
                    le.OwnerId = Lp.UserId__c; 
                    le.Status = 'Distributed';
                    leadListToBeUpdated.add(le);
                    System.debug('leadListToBeUpdated '+leadListToBeUpdated);
                }  
            } 
            
            if(leadListToBeUpdated.size()>0){
                update leadListToBeUpdated;
                System.debug('leadListToBeUpdated '+leadListToBeUpdated);
            }
        }
        catch (Exception e) {
            // Handle the exception (e.g., log the error, send an email notification, etc.)
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
}