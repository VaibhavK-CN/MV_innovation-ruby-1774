public class SignWellPDFHandler {
    private static final String SIGNWELL_API_ENDPOINT = 'https://www.signwell.com/api/v1/documents/';
    private static final String SIGNWELL_API_KEY = 'YWNjZXNzOjVjMjVkNmU0NGUyMDVlYmExYjAzNDBiYzJlYzRiZGEx';  // Replace with your actual API key

    /**
     * Method to fetch the completed PDF from SignWell API and store it in Salesforce.
     * 
     * @param documentId The ID of the SignWell document.
     * @param leadId The ID of the Lead record to link the PDF to.
     * @return The ContentDocumentId of the saved PDF file.
     */
    @AuraEnabled
    public static String fetchAndStorePDF(String documentId, Id leadId) {
        // Step 1: Call the SignWell API to get the completed PDF
        String pdfUrl = SIGNWELL_API_ENDPOINT + documentId + '/completed_pdf/?url_only=false&audit_page=true';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(pdfUrl);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-Api-Key', SIGNWELL_API_KEY);

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
        } catch (Exception e) {
            System.debug('Error sending request to SignWell API: ' + e.getMessage());
            return null;
        }

        // Step 2: Check if the request was successful
        if (res.getStatusCode() == 200) {
            // Get the PDF content as Blob
            Blob pdfBlob = res.getBodyAsBlob();
            System.debug('PDF Content received successfully from SignWell.');

            // Step 3: Save the PDF as ContentVersion in Salesforce
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'SignWell Completed Document - ' + documentId;
            contentVersion.PathOnClient = 'SignWellDocument.pdf';  // Name of the file
            contentVersion.VersionData = pdfBlob;  // The PDF content as Blob
            contentVersion.IsMajorVersion = true;  // Mark as a major version
            insert contentVersion;

            // Step 4: Retrieve the ContentDocumentId from the inserted ContentVersion
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

            // Step 5: Create a ContentDocumentLink to link the file to the Lead record
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentDocumentId;  // ID of the file (ContentDocument)
            contentDocumentLink.LinkedEntityId = leadId;  // ID of the Lead record
            contentDocumentLink.ShareType = 'V';  // Viewer permission (can be changed based on requirements)
            insert contentDocumentLink;

            System.debug('PDF file successfully stored and linked to Lead record.');
            return contentDocumentId;  // Return the ContentDocumentId for reference
        } else {
            // Handle the error if the request was not successful
            System.debug('Failed to fetch PDF from SignWell API. Status Code: ' + res.getStatusCode());
            return null;
        }
    }
}