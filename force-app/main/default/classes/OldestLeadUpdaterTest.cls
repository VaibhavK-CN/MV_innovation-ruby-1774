@isTest
public class OldestLeadUpdaterTest {

    @isTest
    static void testLeadUpdaterAndTrigger() {
        // Create a test user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser@testorg.com'
        );
        insert testUser;

        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                OwnerId = testUser.Id,
                Status = 'Open'
            ));
        }
        insert testLeads;

        // Update a lead to 'Cancelled' status
        testLeads[0].Status = 'Cancelled';
        update testLeads[0];

        // Update a lead to 'Converted' status
        testLeads[1].Status = 'Converted';
        update testLeads[1];

        // Update other leads
        for (Integer i = 2; i < 5; i++) {
            testLeads[i].Status = 'Open';
        }
        update testLeads;

        // Verify that Assigned__c is true for the oldest lead and false for others
        List<Lead> updatedLeads = [SELECT Id, Assigned__c FROM Lead WHERE Id IN :testLeads];
        System.assertEquals(true, updatedLeads[0].Assigned__c);
        for (Integer i = 1; i < updatedLeads.size(); i++) {
            System.assertEquals(false, updatedLeads[i].Assigned__c);
        }
    }
}