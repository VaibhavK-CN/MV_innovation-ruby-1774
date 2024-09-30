public without sharing class PublicEventSubscribedController {
    public static List<Lead> leadRecordList = new List<Lead>();
    public static String leadRecordId;
    @AuraEnabled
    public static boolean isLoginUserCorrectUser(List<String> UserIdList){
        System.debug('UserId:::'+UserIdList);
        
        String LoginUserId = UserInfo.getUserId();
        // Add condition according to login user
        Boolean isLoginUserCorrectUser =  UserIdList.contains(LoginUserId);
        return isLoginUserCorrectUser;
    }
    // User response
    @AuraEnabled
    public static string clickedUsDetails(List<Id> leadId, String userResponse){
        String LoginUserId = UserInfo.getUserId();
        leadRecordId = leadId[0];
        List<Lead> LeadList = [SELECT Id, Consultation_Response__c FROM Lead WHERE Id =: leadRecordId];
        system.debug(LeadList);
        for(Lead l : LeadList) {
            if(userResponse =='Accepted') {
                l.Consultation_Response__c = 'Accepted';
            }
            else if(userResponse == 'Rejected') {
                l.Consultation_Response__c = 'Rejected';
            }
            leadRecordList.add(l);
        }
        update leadRecordList;
        List<Consultant_Request__c> conRequestList = [SELECT Id, Lead__C, Request_Accepted__c 
                                                      FROM Consultant_Request__c WHERE Lead__c =: leadRecordId AND OwnerId=: LoginUserId];
		System.debug(conRequestList);
        return LoginUserId;
    }
}