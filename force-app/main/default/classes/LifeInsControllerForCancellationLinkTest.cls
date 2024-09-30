@isTest
public class LifeInsControllerForCancellationLinkTest {

    @isTest
    static void testSaveLifeInsWithMatchingRecord() {
        LifeInsurance__c testLifeInsurance = new LifeInsurance__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Date_of_Birth__c = Date.newInstance(1990, 1, 1),
            Email__c = 'john.doe@example.com'
        );
        insert testLifeInsurance;
        LifeInsControllerForCancellationLink controller = new LifeInsControllerForCancellationLink();
        controller.LifeInsuranceObj = new LifeInsurance__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Date_of_Birth__c = Date.newInstance(1990, 1, 1),
            Email__c = 'john.doe@example.com',
            Cancellation_Reason__c = 'Some Reason'
        );
        Test.startTest();
        PageReference result = controller.saveLifeIns();
        Test.stopTest();
    }

    @isTest
    static void testSaveLifeInsWithNoMatchingRecord() {
        LifeInsControllerForCancellationLink controller = new LifeInsControllerForCancellationLink();
        controller.LifeInsuranceObj = new LifeInsurance__c(
            First_Name__c = 'Nonexistent',
            Last_Name__c = 'Person',
            Date_of_Birth__c = Date.newInstance(2000, 1, 1),
            Email__c = 'nonexistent.person@example.com',
            Cancellation_Reason__c = 'Some Reason'
        );
        Test.startTest();
        PageReference result = controller.saveLifeIns();
        Test.stopTest();
    }
}