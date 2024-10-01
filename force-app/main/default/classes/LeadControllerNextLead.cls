public class LeadControllerNextLead {
    @AuraEnabled
    public static List<Lead> getCurrentUserLeadList(String recordId) {
        System.debug('recordId:: '+recordId);
        String currentUser = UserInfo.getUserId(); 
        System.debug('currentUser::'+currentUser);
        List<Lead> leadList = [SELECT Id, Name, OwnerId, CreatedDate, Status
                               FROM Lead 
                               WHERE OwnerId =: currentUser ORDER BY CreatedDate DESC LIMIT 5];
        
        return leadList;
    }
}