@RestResource(urlMapping='/signwell/webhook')
global with sharing class SignWellWebhookHandler {

    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Parse the incoming JSON payload
            String requestBody = req.requestBody.toString();
            Map<String, Object> webhookData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            System.debug('Received webhook data: ' + webhookData);

            // Extract the document ID and status from the payload
            Map<String, Object> documentData = (Map<String, Object>) ((Map<String, Object>) webhookData.get('data')).get('object');
            String documentId = (String) documentData.get('id');
            String documentStatus = (String) documentData.get('status'); // E.g., "Sent", "Completed", etc.

            System.debug('Document ID: ' + documentId);
            System.debug('Document Status: ' + documentStatus);

            // Enqueue the first Queueable job to update the document status
            System.enqueueJob(new SignWellUpdateStatusJob(documentId, documentStatus));

            // Send a 200 OK response to acknowledge the webhook
            res.responseBody = Blob.valueOf('Webhook received and processing started');
            res.statusCode = 200;

        } catch (Exception e) {
            System.debug('Error processing webhook: ' + e.getMessage());

            // Send a 500 Internal Server Error response if something goes wrong
            res.responseBody = Blob.valueOf('Error processing webhook');
            res.statusCode = 500;
        }
    }
}