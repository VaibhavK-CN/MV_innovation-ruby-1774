public class LeadOwnerUdpateLeadPool {
    public static void updateLeadOwnerQueueLeadPool(List<Lead> leadList){
        List<queuesobject> groupList = new List<queuesobject>();
        ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='Lead Pool' LIMIT 1].Queue.Id;
        
        for(Lead le:leadList){
            if(le.Status != null && le.Status == 'Cancelled'){
                le.OwnerId = queueId;
                System.Debug('Owner Id'+le.OwnerId);
                
            }
        }
        
    }
    
}