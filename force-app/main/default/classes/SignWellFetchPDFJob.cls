public class SignWellFetchPDFJob implements Queueable, Database.AllowsCallouts {
    private String documentId;

    public SignWellFetchPDFJob(String documentId) {
        this.documentId = documentId;
    }

    public void execute(QueueableContext context) {
        try {
            System.debug('Fetching PDF for documentId: ' + documentId);

            String SIGNWELL_API_ENDPOINT = 'https://www.signwell.com/api/v1/documents/' + documentId + '/completed_pdf/?url_only=false&audit_page=true';
            String SIGNWELL_API_KEY = 'YWNjZXNzOjVjMjVkNmU0NGUyMDVlYmExYjAzNDBiYzJlYzRiZGEx';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(SIGNWELL_API_ENDPOINT);
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json');
            req.setHeader('X-Api-Key', SIGNWELL_API_KEY);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Blob pdfBlob = res.getBodyAsBlob();
                System.debug('PDF content received from SignWell.');

                // Save the PDF as ContentVersion in Salesforce
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'SignWell Completed Document - ' + documentId;
                contentVersion.PathOnClient = 'SignWellDocument.pdf';
                contentVersion.VersionData = pdfBlob;
                contentVersion.IsMajorVersion = true;

                // Fetch the related Insurance_Documents__c record
                Insurance_Documents__c insuranceDoc = [SELECT Id FROM Insurance_Documents__c WHERE Document_ld__c = :documentId LIMIT 1];

                if (insuranceDoc != null) {
                    // Link the ContentVersion to the Insurance Document record instead of private library
                    contentVersion.FirstPublishLocationId = insuranceDoc.Id;
                    insert contentVersion;

                    System.debug('ContentVersion inserted with ID: ' + contentVersion.Id);

                    Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

                    // Create a ContentDocumentLink to link the file to the Insurance_Documents__c record
                    ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                    contentDocumentLink.ContentDocumentId = contentDocumentId;
                    contentDocumentLink.LinkedEntityId = insuranceDoc.Id;  // Link to the Insurance Document record
                    contentDocumentLink.ShareType = 'V';  // Viewer permission
                    insert contentDocumentLink;

                    System.debug('PDF linked to Insurance_Documents__c record.');
                } else {
                    System.debug('No Insurance_Documents__c record found for document ID: ' + documentId);
                }
            } else {
                System.debug('Failed to fetch PDF from SignWell API. Status Code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error fetching and storing PDF: ' + e.getMessage());
        }
    }
}