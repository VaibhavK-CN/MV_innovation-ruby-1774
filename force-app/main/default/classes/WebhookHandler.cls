@RestResource(urlMapping='/signwell/webhook')
global with sharing class WebhookHandler {

    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Parse the incoming JSON payload
            String requestBody = req.requestBody.toString();
            Map<String, Object> webhookData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            System.debug('Received webhook data: ' + webhookData);

            // Check if the payload is from Webflow
            if (webhookData.containsKey('triggerType') && webhookData.get('triggerType') == 'form_submission') {
                handleWebflowPayload(webhookData);
            }
            // Check if the payload is from SignWell
            else if (webhookData.containsKey('data') && ((Map<String, Object>) webhookData.get('data')).containsKey('object')) {
                handleSignWellPayload(webhookData);
            } else {
                System.debug('Unrecognized webhook source or payload format.');
            }

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

    // Method to handle Webflow form submission payload
            private static void handleWebflowPayload(Map<String, Object> webhookData) {
                System.debug('Processing Webflow payload...');
            
                if (webhookData.containsKey('payload')) {
                    Map<String, Object> payloadData = (Map<String, Object>) webhookData.get('payload');
                    Map<String, Object> formData = (Map<String, Object>) payloadData.get('data');
            
                    // Check for required fields and assign them to variables
                    String dialCode = (String) formData.get('Dial code');
                    String email = (String) formData.get('E Mail');
                    String firstName = (String) formData.get('First Name');
                    String lastName = (String) formData.get('Last Name');
                    String phoneNumber = (String) formData.get('Phone Number');
                    String postcode = (String) formData.get('Postcode');
            
                    // Check if essential fields are present
                    if (firstName != null && email != null && lastName != null) {
                        System.debug('Webflow Form submitted by: ' + firstName + ' ' + lastName + ' with email: ' + email);
            
                        // Enqueue the WebflowLeadCreationJob to create a Lead with the fields
                        System.enqueueJob(new WebflowLeadCreationJob(dialCode, email, firstName, lastName, phoneNumber, postcode));
                    } else {
                        System.debug('Required fields are missing in the Webflow payload.');
                    }
                } else {
                    System.debug('Invalid Webflow payload format.');
                }
            }



    // Method to handle SignWell payload
    private static void handleSignWellPayload(Map<String, Object> webhookData) {
        System.debug('Processing SignWell payload...');

        // Extract the document ID and status from the payload
        Map<String, Object> documentData = (Map<String, Object>) ((Map<String, Object>) webhookData.get('data')).get('object');
        String documentId = (String) documentData.get('id');
        String documentStatus = (String) documentData.get('status'); // E.g., "Sent", "Completed", etc.

        System.debug('SignWell Document ID: ' + documentId);
        System.debug('SignWell Document Status: ' + documentStatus);
        
        // Extract and debug the "fields" from the payload
    if (documentData.containsKey('fields')) {
        List<Object> fields = (List<Object>) documentData.get('fields');
        
        for (Object fieldGroup : fields) {
            List<Object> fieldList = (List<Object>) fieldGroup;
            
            for (Object fieldObj : fieldList) {
                Map<String, Object> field = (Map<String, Object>) fieldObj;
                
                // Debug each field's properties
                System.debug('Field API ID: ' + field.get('api_id'));
                System.debug('Field Page: ' + field.get('page'));
                System.debug('Field Required: ' + field.get('required'));
                System.debug('Field Type: ' + field.get('type'));
                System.debug('Field Value: ' + field.get('value'));
                System.debug('Field Width: ' + field.get('width'));
                System.debug('Field Height: ' + field.get('height'));
                System.debug('Field X Position: ' + field.get('x'));
                System.debug('Field Y Position: ' + field.get('y'));
                System.debug('Field Recipient ID: ' + field.get('recipient_id'));
            }
        }
    } else {
        System.debug('No fields found in the SignWell payload.');
    }

        // Enqueue the first Queueable job to update the document status (as needed)
        System.enqueueJob(new SignWellUpdateStatusJob(documentId, documentStatus));
    }
}