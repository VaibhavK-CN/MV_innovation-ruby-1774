/*******************************************************************************************************************************************
* CREATED BY : ASAWARI KUMBHALKAR  CREATED DATE : 04.03.24
* 
* Description : This class is use to update owner of lead when event assignee updates
*********************************************************************************************************************************************
*/
public class ChaneLeadOwnerUpdateAsinee {
    public static void updateLeadOwner(List<Event> evList){
        Map<Id,Lead> leadMap = New Map<Id,Lead>([SELECT Id,Name,OwnerId,Owner.Name FROM Lead]);
        List<Lead> leadList = New List<Lead>();
        for(Event ev:evList){
            Lead le = leadMap.get(ev.WhoId);
            System.debug(le);
            if(le != null){
                le.OwnerId = ev.OwnerId;
                leadList.add(le);
            }
        }
        Update leadList;
        System.debug('leadList '+leadList);
    }
}