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
                    System.debug('Webflow Payload Data: ' + payloadData);
                    Map<String, Object> formData = (Map<String, Object>) payloadData.get('data');
                    System.debug('Webflow formData Data: ' + formData);
            
                    // Check for required fields and assign them to variables
                    String dialCode = (String) formData.get('Dial code');
                    String email = (String) formData.get('E Mail');
                    String firstName = (String) formData.get('First Name');
                    String lastName = (String) formData.get('Last Name');
                    String phoneNumber = (String) formData.get('Phone Number');
                    String postcode = (String) formData.get('Postcode');
                   String preferredTime = (String) formData.get('Preferred Contact Time 2');
                    system.debug('preferredTime :' + preferredTime);
                    
            
                    // Check if essential fields are present
                    if (firstName != null && email != null && lastName != null) {
                        System.debug('Webflow Form submitted by: ' + firstName + ' ' + lastName + ' with email: ' + email);
            
                        // Enqueue the WebflowLeadCreationJob to create a Lead with the fields
                        System.enqueueJob(new WebflowLeadCreationJob(dialCode, email, firstName, lastName, phoneNumber, postcode, preferredTime));
                    } else {
                        System.debug('Required fields are missing in the Webflow payload.');
                    }
                } else {
                    System.debug('Invalid Webflow payload format.');
                }
            }



    // Method to handle SignWell payload
    // Method to handle SignWell payload
private static void handleSignWellPayload(Map<String, Object> webhookData) {
    System.debug('Processing SignWell payload...');

    // Extract the document ID and status from the payload
    Map<String, Object> documentData = (Map<String, Object>) ((Map<String, Object>) webhookData.get('data')).get('object');
    String documentId = (String) documentData.get('id');
    String documentStatus = (String) documentData.get('status'); // E.g., "Sent", "Completed", etc.

    System.debug('SignWell Document ID: ' + documentId);
    System.debug('SignWell Document Status: ' + documentStatus);
    
    // Extract the "fields" from the payload
    List<Map<String, String>> fieldsData = new List<Map<String, String>>();
    if (documentData.containsKey('fields')) {
        List<Object> fields = (List<Object>) documentData.get('fields');
        
        for (Object fieldGroup : fields) {
            List<Object> fieldList = (List<Object>) fieldGroup;
            for (Object fieldObj : fieldList) {
                Map<String, Object> field = (Map<String, Object>) fieldObj;
                
                // Store each field's API ID and value
                String apiId = (String) field.get('api_id');
                String value = (String) field.get('value');
                
                // Add the API ID and value as a map to the list
                fieldsData.add(new Map<String, String>{'api_id' => apiId, 'value' => value});
                
                System.debug('Field API ID: ' + apiId + ', Field Value: ' + value);
            }
        }
    } else {
        System.debug('No fields found in the SignWell payload.');
    }

    // Enqueue the Queueable job to update the document status and lead fields
    System.enqueueJob(new SignWellUpdateStatusJob(documentId, documentStatus, fieldsData));
}

}