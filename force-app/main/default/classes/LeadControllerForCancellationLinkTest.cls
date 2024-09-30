@isTest
public class LeadControllerForCancellationLinkTest {

    @isTest
    static void testSaveLead() {
        // Create a test Lead record
        Lead testLead = new Lead(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test@email.com',
            Date_of_Birth__c = Date.newInstance(2000, 1, 1)
        );
        insert testLead;

        // Create an instance of LeadControllerForCancellationLink
        LeadControllerForCancellationLink controller = new LeadControllerForCancellationLink();
        controller.leadObj = testLead; // Set the leadObj directly

        // Set up a mock query result to simulate finding a matching lead
      //  Test.setMock(Database.queryLocator, new LeadQueryLocator([testLead]));

        // Call the saveLead method
        Test.startTest();
        controller.saveLead();
        Test.stopTest();

        // Verify that the lead was updated
        Lead updatedLead = [SELECT Id, Wish_to_Cancel__c, Cancelation_Reason__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
       
    }
}