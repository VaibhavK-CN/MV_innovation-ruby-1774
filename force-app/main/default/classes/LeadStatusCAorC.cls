public class LeadStatusCAorC {
    public static void myMth(List<Lead> leadList,Map<Id, Lead> oldValuesMap){
        System.debug('leadList '+leadList);
        for(Lead le:leadList){ 
            // For VC Life Insurance
            if (le.VC_Life_Insurance_User__c != null &&
                (oldValuesMap.get(le.Id) == null ||
                 !le.VC_Life_Insurance_User__c.equals(oldValuesMap.get(le.Id).VC_Life_Insurance_User__c))) {
                                                            le.OwnerId = le.VC_Life_Insurance_User__c; 
                                                            System.debug('OwnerId '+le.OwnerId);
                                                            
                                                        }
            //For call Agent
            if (le.Call_Agent_User__c != null &&
                (oldValuesMap.get(le.Id) == null ||
                 !le.Call_Agent_User__c.equals(oldValuesMap.get(le.Id).Call_Agent_User__c))) {
                                                     le.OwnerId = le.Call_Agent_User__c; 
                                                     le.Status = 'Distributed';
                                                     System.debug('OwnerId '+le.OwnerId);
                                                     System.debug('Status '+le.Status);
                                                     
                                                 }
            // For backoffice
            if (le.Backoffice__c != null &&
                (oldValuesMap.get(le.Id) == null ||
                 !le.Backoffice__c.equals(oldValuesMap.get(le.Id).Backoffice__c))) {
                                                le.OwnerId = le.Backoffice__c; 
                                                System.debug('OwnerId '+le.OwnerId);
                     							le.Status = 'Send to BO: Submitted';
                                                
                                            }
            // For 
            if (le.Consultant_Health_Insurance_User__c != null &&
                (oldValuesMap.get(le.Id) == null ||
                 !le.Consultant_Health_Insurance_User__c.equals(oldValuesMap.get(le.Id).Consultant_Health_Insurance_User__c))) {
                                                                      le.OwnerId = le.Consultant_Health_Insurance_User__c; 
                                                                      System.debug('OwnerId '+le.OwnerId);
                                                                      le.Status = 'Distributed';
                                                                      System.debug('Status '+le.Status);
                                                                      
                                                                  }
        }
    }
    
}