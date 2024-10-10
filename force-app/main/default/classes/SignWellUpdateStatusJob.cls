public class SignWellUpdateStatusJob implements Queueable, Database.AllowsCallouts {
    private String documentId;
    private String documentStatus;

    // Constructor to initialize the document ID and status
    public SignWellUpdateStatusJob(String documentId, String documentStatus) {
        this.documentId = documentId;
        this.documentStatus = documentStatus;
    }

    // The execute method to update the document status
    public void execute(QueueableContext context) {
        try {
            System.debug('Updating document status for documentId: ' + documentId);

            // Query the Insurance_Documents__c record based on documentId
            List<Insurance_Documents__c> docs = [SELECT Id, Status__c FROM Insurance_Documents__c WHERE Document_ld__c = :documentId LIMIT 1];
            if (docs.size() > 0) {
                Insurance_Documents__c doc = docs[0];
                doc.Status__c = documentStatus;
                update doc;
                System.debug('Document status updated in Salesforce for document ID: ' + documentId);

             

            } else {
                System.debug('No document found with ID: ' + documentId);
            }
        } catch (Exception e) {
            System.debug('Error updating document status: ' + e.getMessage());
        }
    }
}