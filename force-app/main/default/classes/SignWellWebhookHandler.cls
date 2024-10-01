@RestResource(urlMapping='/signwell/webhook')
global with sharing class SignWellWebhookHandler {

    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        

        // Capture the body of the incoming request (SignWell's webhook data)
        String requestBody = req.requestBody.toString();
        System.debug('SignWell Webhook Request: ' + requestBody);

        // Parse the JSON payload (you'll need to map this to the expected structure from SignWell)
        Map<String, Object> webhookData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        // Example of capturing a specific event like document completion
        if (webhookData.containsKey('type')) {
            String eventType = (String) webhookData.get('type');

            if (eventType == 'document_viewed') {
                String documentId = (String) webhookData.get('document_id');
                String status = (String) webhookData.get('status');

                System.debug('Document Completed - ID & status : ' + documentId + status);
                

                // Find or update records in Salesforce related to the document
                updateDocumentStatus(documentId, status);
            }
        }

        // Respond to SignWell with a success message
        res.responseBody = Blob.valueOf('Webhook received successfully');
        system.debug(res.responseBody);
        res.statusCode = 200;
    }

    // Helper method to update the document status in Salesforce
    private static void updateDocumentStatus(String documentId, String status) {
        // Assuming Insurance_Documents__c has a field to store SignWell's document ID
        List<Insurance_Documents__c> docs = [SELECT Id, Status__c FROM Insurance_Documents__c WHERE Document_ld__c = :documentId];

        if (docs.size() > 0) {
            Insurance_Documents__c doc = docs[0];
            doc.Status__c = status;
            update doc;
            System.debug('Document Status Updated in Salesforce');
        } else {
            System.debug('Document not found');
        }
    } 
}