@isTest
public class OneLeadAtTimeClassTest {
    @isTest
    static void testUpdateLeadOwnerAsCallAgent() {
        // Test data setup
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                LastName = 'Test Lead ' + i,
                Notes__c = 'Had a call with XYZ customer',
                OwnerId = '00507000005ELO9AAO'
                
            ));
        }
        insert testLeads;
        
        List<Lead_Pool__c> testLeadPools = new List<Lead_Pool__c>();
        for (Lead testLead : testLeads) {
            testLeadPools.add(new Lead_Pool__c(
                LeadId__c = testLead.Id,
                UserId__c = UserInfo.getUserId()
            ));
        }
        insert testLeadPools;
        testLeads[0].notes__c = '';
        update testLeads;
        Test.startTest();
        OneLeadAtTimeClass.UpdateLeadOwnerAsCallAgent(testLeads);
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, OwnerId, Status FROM Lead WHERE Id IN :testLeads];
        
    }
    @isTest
    static void testLeadPoolCreation() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Notes__c = null
        );
        insert testLead;
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testusernew@example.com',
            CommunityNickname = 'tuser123',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;
        
        Lead_Pool__c testLeadPool = new Lead_Pool__c(
            LeadId__c = testLead.Id,
            UserId__c = testUser.Id
        );
        insert testLeadPool;
        OneLeadWhenLeadPoolCreated.whenLeadPoolCreated(new List<Lead_Pool__c>{ testLeadPool });
        Lead updatedLead = [SELECT Id, OwnerId, Status FROM Lead WHERE Id = :testLead.Id LIMIT 1];
    }
}