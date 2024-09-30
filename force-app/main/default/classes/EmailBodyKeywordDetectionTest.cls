@isTest
public class EmailBodyKeywordDetectionTest {

    @isTest
    static void testApprovalKeyword() {
        Messaging.InboundEmail email = createTestEmail('Sample body with Approved keyword');
        Test.startTest();
        EmailBodyKeywordDetection.processApprovalRejection(email);
        Test.stopTest();
    }

    @isTest
    static void testRejectionKeyword() {
        Messaging.InboundEmail email = createTestEmail('Sample body with Rejected keyword');
        Test.startTest();
        EmailBodyKeywordDetection.processApprovalRejection(email);
        Test.stopTest();
    }

    @isTest
    static void testUnknownKeyword() {
        Messaging.InboundEmail email = createTestEmail('Sample body with Unknown keyword');
        Test.startTest();
        EmailBodyKeywordDetection.processApprovalRejection(email);
        Test.stopTest();
    }

    private static Messaging.InboundEmail createTestEmail(String body) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = body;
        email.subject = 'Test Subject';
        return email;
    }
}