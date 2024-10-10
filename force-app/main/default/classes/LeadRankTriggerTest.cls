@isTest
public class LeadRankTriggerTest {
    @isTest
    static void testLeadRankTrigger() {
        // Step 1: Create test leads without Age__c if it's a formula field
        List<Lead> testLeads = new List<Lead>{
            new Lead(LastName='Test1', Status='Super Hot', Lead_Score__c=null),
            new Lead(LastName='Test2', Status='Hot', Lead_Score__c=null),
            new Lead(LastName='Test3', Status='Warm', Lead_Score__c=null),
            new Lead(LastName='Test4', Status='Cold', Lead_Score__c=null)
        };

        // Step 2: Insert test leads
        Test.startTest();
        insert testLeads; // This will fire the trigger
        Test.stopTest();

        // Step 3: Query updated leads to check Lead_Score__c
        List<Lead> updatedLeads = [SELECT Id, Lead_Score__c FROM Lead WHERE Id IN :testLeads];

        // Step 4: Verify that Lead_Score__c has been assigned
        System.assertEquals(4, updatedLeads.size(), 'There should be 4 leads updated.');
        for (Lead updatedLead : updatedLeads) {
            System.assert(updatedLead.Lead_Score__c != null, 'Lead score should be updated.');
        }
    }
}