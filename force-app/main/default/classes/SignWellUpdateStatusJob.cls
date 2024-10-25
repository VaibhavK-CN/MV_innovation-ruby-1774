public class SignWellUpdateStatusJob implements Queueable, Database.AllowsCallouts {
    private String documentId;
    private String documentStatus;
    private List<Map<String, String>> fieldsData; // List of field API IDs and values

    // Constructor to initialize the document ID, status, and fields data
    public SignWellUpdateStatusJob(String documentId, String documentStatus, List<Map<String, String>> fieldsData) {
        this.documentId = documentId;
        this.documentStatus = documentStatus;
        this.fieldsData = fieldsData;
    }

    // The execute method to update the document status and Lead fields
    public void execute(QueueableContext context) {
        try {
            System.debug('Updating document status for documentId: ' + documentId);

            // Query the Insurance_Documents__c record based on documentId
            List<Insurance_Documents__c> docs = [SELECT Id, Lead__c, Status__c FROM Insurance_Documents__c WHERE Document_ld__c = :documentId LIMIT 1];
            
            if (docs.size() > 0) {
                Insurance_Documents__c doc = docs[0];
                doc.Status__c = documentStatus;
                update doc;
                System.debug('Document status updated in Salesforce for document ID: ' + documentId);
                
                // Fetch the related Lead record
                Lead leadRecord = [SELECT Id, FirstName, LastName, Email, Phone,City,Street, PostalCode FROM Lead WHERE Id = :doc.Lead__c LIMIT 1];
                Boolean leadUpdated = false;
                
                // Map the SignWell fields to Lead fields
                for (Map<String, String> field : fieldsData) {
                    String apiId = field.get('api_id');
                    String value = field.get('value');
                    
                    // Map fields based on API IDs
                    if (apiId == 'PH_FName') {
                        leadRecord.FirstName = value;
                        leadUpdated = true;
                    } else if (apiId == 'PH_LName') {
                        leadRecord.LastName = value;
                        leadUpdated = true;
                    } else if (apiId == 'PH_Email') {
                        leadRecord.Email = value;
                        leadUpdated = true;
                    } else if (apiId == 'PH_Phone') {
                        leadRecord.Phone = value;
                        leadUpdated = true;
                    } else if (apiId == 'PH_ZipCode') {
                        leadRecord.PostalCode = value;
                        leadUpdated = true;
                    } else if (apiId == 'PH_City') {
                        leadRecord.City = value;
                        leadUpdated = true;
                    } else if (apiId == 'PH_Street') {
                        leadRecord.Street = value;
                        leadUpdated = true;
                    }
                }

                // Update Lead record if any fields were updated
                if (leadUpdated) {
                    update leadRecord;
                    System.debug('Lead record updated with new field values.');
                } else {
                    System.debug('No updates were made to the Lead record.');
                }

            } else {
                System.debug('No document found with ID: ' + documentId);
            }
        } catch (Exception e) {
            System.debug('Error updating document status or Lead record: ' + e.getMessage());
        }
    }
}