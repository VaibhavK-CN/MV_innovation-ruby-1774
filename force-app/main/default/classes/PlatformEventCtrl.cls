public class PlatformEventCtrl {
    @AuraEnabled
    public static void publishEvent(String title, String Message, String userList){
        Consultation_Request__e event = new Consultation_Request__e();
        event.Title__c = title;
        event.Message__c = Message;
        event.User_List__c = userList;
        //system.debug('event:'+event);
        EventBus.publish(event);
    }
    @AuraEnabled
    public static string publishEventForResponse(String leadId, String response){
        List<Consultant_Request__c> crRecordList = new List<Consultant_Request__c>();
        system.debug('leadId: '+leadId);
        system.debug('response: '+response);
        //System.debug('publishEventForResponse::: start');
        String logInUser = UserInfo.getUserId();
        system.debug(logInUser);
        
        try {
            List<Consultant_Request__c> crList = [SELECT Id, Name, Lead__c, Consultant_Response__c, OwnerId, CreatedDate 
                                                  FROM  Consultant_Request__c 
                                                  WHERE Lead__c =: leadId AND OwnerId =: logInUser ORDER BY CreatedDate DESC LIMIT 1];
            system.debug(crList);
            for(Consultant_Request__c cr : crList) {
                Consultant_Request__c c = new Consultant_Request__c();
                c.Id = cr.Id;
                if(cr.Consultant_Response__c != 'Accepted' && cr.Consultant_Response__c != 'Rejected' && response == 'No Response') {
                    c.Consultant_Response__c = response;
                	crRecordList.add(c);
                }
                if(response == 'Rejected' || response == 'Accepted') {
                    c.Consultant_Response__c = response;
                	crRecordList.add(c);
                }
                
            }
            if(crRecordList.size() > 0) {
            	update crRecordList;
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
        //Event Publish
        Consultant_Response__e event = new Consultant_Response__e();
        event.User_Detail__c = logInUser;
        if(response == 'Accepted') {
            EventBus.publish(event);
        }
        System.debug('publishEventForResponse::: stopped');
        
        return logInUser;
    }
}