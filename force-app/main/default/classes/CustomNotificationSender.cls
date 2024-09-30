public without sharing class CustomNotificationSender {
    public static final String APP_ID = '02u07000000LTB8AAO';
    public static final String CONSULTATION_REQUEST_TITLE = 'Consultation Request';
    public static final String CONSULTATION_REQUEST_MESSAGE = 'If you are available in the next 5 minutes, please accept the consultation request.';
    public static final String LNL_CONSULTANT = 'LNL_Consultant_User';
    public static final String HEALTH_INSURANCE_CONSULTANT = 'Health_Insurance_Consultant_User';
    public static final String HEALTH_AND_LNL_CONSULTANT = 'Health_and_LNL_Consultant';
    public static Set<String> UserSet = new Set<String>();
    public static Map<String, String> userListMap = new Map<String, String>();
    public static Map<String, String> eventUserListMap = new Map<String, String>();
    public static List<Consultant_Request__c>  Consultant_Request_List = new List<Consultant_Request__c>();
    public static List<User> userListByLanguage;
    public static List<User> userListForNotification;
    // Create consulataion request for login user
    @AuraEnabled
    public static List<User> consulataionRequest(String language, String leadId) {
        system.debug('leadId:'+leadId);
        String groupId;
        String devloperName;
        String insuranceType;
        List<User> userList = new List<User>();
        Set<Id> userIds = new Set<Id>();
        List<String> userLanguageList = new List<String>();
        userLanguageList.add(language);
        String userlanguage = '(\'' + String.join(userLanguageList, '\', \'') + '\')';
        List<Lead> ldList = [SELECT Id, Name, Insurance_Type__c FROM Lead WHERE Id =: leadId LIMIT 1];
        if(ldList != null && !ldList.isEmpty()) {
            insuranceType = ldList[0].Insurance_Type__c;
        }
        if(insuranceType == 'Health Insurance') {
            devloperName = HEALTH_INSURANCE_CONSULTANT;
        }
        else if(insuranceType == 'LNL Insurance') {
            devloperName = LNL_CONSULTANT;
        }
        else if(insuranceType == 'Health Insurance and Life Insurance') {
            devloperName = HEALTH_AND_LNL_CONSULTANT;
        }
        system.debug(devloperName);
        // Public group
        List<Group> groups = [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName =: devloperName LIMIT 1];
        System.debug(groups);
        if(groups != null && !groups.isEmpty()) {
            groupId = groups[0].Id;
        }
        userIds = NestedGroupHelper.getUserIdsFromNestedGroups(groupId);
        System.debug(userIds);
        // Userlist by langauge
        if(language != '') {
            userListByLanguage = Database.query(
                'SELECT Id, Name, Language__c, ProfileId ' +
                'FROM User ' +
                'WHERE Language__c INCLUDES ' + userlanguage);
            System.debug(userListByLanguage);
        }
        if(userListByLanguage != null && !userListByLanguage.isEmpty()) {
            for (User user : userListByLanguage) {
                userListMap.put(user.Id,leadId);
            }
        }
        userListForNotification = [SELECT Id, Name, Language__c, Email, ProfileId FROM User WHERE Id IN :userIds];
        for (User user : userListForNotification) {
            if(userListMap.containsKey(user.Id)) {
                eventUserListMap.put(user.Id,leadId);
                userList.add(user);
            }
            String jsonString = JSON.serialize(eventUserListMap);
            system.debug('jsonString: '+jsonString);
            //publishEvent
            PlatformEventCtrl.publishEvent(CONSULTATION_REQUEST_TITLE,CONSULTATION_REQUEST_MESSAGE,jsonString);
            //notifyUsers(UserSet, APP_ID);
        }
        // Create consultation request record as per user list
        if(userList != null && !userList.isEmpty()) {
            for(User u : userList) {
                Consultant_Request__c cr = new Consultant_Request__c();
                cr.Lead__c = leadId;
                cr.Call_Agent__c = UserInfo.getUserId();
                cr.OwnerId = u.Id;
                Consultant_Request_List.add(cr);
            }
        }
        if(Consultant_Request_List != null && !Consultant_Request_List.isEmpty()) {
            insert Consultant_Request_List;
        }
        
        return userList;
    }
    /*public static void notifyUsers(Set<String> recipientsIds, String targetId) {

// Get the Id for our custom notification type
CustomNotificationType notificationType = [SELECT Id, DeveloperName 
FROM CustomNotificationType 
WHERE DeveloperName='Consultation_Request'];

// Create a new custom notification
Messaging.CustomNotification notification = new Messaging.CustomNotification();

// Set the contents for the notification
notification.setTitle('Consultation Request');
notification.setBody('If you are available in the next 5 minutes, please accept the consultation request.');

// Set the notification type and target
notification.setNotificationTypeId(notificationType.Id);
notification.setTargetId(targetId);

// Actually send the notification
try {
notification.send(recipientsIds);
}
catch (Exception e) {
System.debug('Problem sending notification: ' + e.getMessage());
}
}*/
}