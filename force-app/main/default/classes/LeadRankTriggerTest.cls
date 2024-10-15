@isTest
public class LeadRankTriggerTest {
    @isTest
    static void testLeadRankTrigger() {
        // Step 1: Create test leads with Date_of_Birth__c as Date
        List<Lead> testLeads = new List<Lead>{
            new Lead(LastName='Test1', Status='Super Hot', Date_of_Birth__c=Date.newInstance(2015, 5, 10)),
            new Lead(LastName='Test2', Status='Hot', Date_of_Birth__c=Date.newInstance(2020, 2, 12)),
            new Lead(LastName='Test3', Status='Warm', Date_of_Birth__c=Date.newInstance(2021, 3, 24)),
            new Lead(LastName='Test4', Status='Cold', Date_of_Birth__c=Date.newInstance(2015, 7, 5))
        };

        // Step 2: Insert test leads
        Test.startTest();
        insert testLeads; // This will fire the trigger
        Test.stopTest();

        // Step 3: Query updated leads to check Lead_Score__c
        List<Lead> updatedLeads = [SELECT Id, Date_of_Birth__c, Lead_Score__c FROM Lead WHERE Id IN :testLeads];

        // Step 4: Verify that Lead_Score__c has been assigned
        System.assertEquals(4, updatedLeads.size(), 'There should be 4 leads updated.');
        for (Lead updatedLead : updatedLeads) {
            System.assert(updatedLead.Lead_Score__c != null, 'Lead score should be updated.');
        }
    }
}