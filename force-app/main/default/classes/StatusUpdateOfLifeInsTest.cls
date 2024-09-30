@isTest
public class StatusUpdateOfLifeInsTest {
    @isTest
    
    public static void updateStatusofLifeInsForBO(){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Backoffice'];
        User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standardusermy@testorg.com'
        );
        insert testUser;
        
        // Create test leads
        List<LifeInsurance__c> lifeInsList = new List<LifeInsurance__c>();
        for (Integer i = 0; i < 5; i++) {
            lifeInsList.add(new LifeInsurance__c(
                Name = 'TestFirstName' + i,
              //  LastName = 'TestLastName' + i,
                OwnerId = testUser.Id,
                Lead_Status__c = 'Open'
            ));
        }
        insert lifeInsList;
        
        for (Integer i = 2; i < 5; i++) {
            lifeInsList[i].Lead_Status__c = 'Send to BO: Submitted';
        }
        update lifeInsList;
        StatusUpdateOfLifeIns.updateStatusBO(lifeInsList);
    }
}