public class SignWellDocumentFetcher {

    @AuraEnabled
    public static String fetchSignWellData(String type) {
        // Initialize a variable to hold the metadata name
        String metadataName;
        
        // Determine which API to call based on the type (documents or templates)
        if (type == 'documents') {
            metadataName = 'SignWellGetDocumentApi';  // Metadata name for fetching documents
        } else if (type == 'templates') {
            metadataName = 'SignWellGetTemplateApi';  // Metadata name for fetching templates
        } else {
            return 'Error: Invalid type specified. Use "documents" or "templates".';
        }

        // Retrieve metadata for the SignWell API based on the type
        IntegrationMetadata__mdt metadata = [SELECT Endpoint__c, Header__c, Method__c 
                                             FROM IntegrationMetadata__mdt 
                                             WHERE DeveloperName = :metadataName LIMIT 1];

        if (metadata != null) {
            try {
                // Construct the HTTP request
                HttpRequest req = new HttpRequest();
                req.setEndpoint(metadata.Endpoint__c);
                req.setMethod(metadata.Method__c);

                // Set headers from metadata
                Map<String, Object> headersMap = (Map<String, Object>) JSON.deserializeUntyped(metadata.Header__c);
                for (String key : headersMap.keySet()) {
                    req.setHeader(key, String.valueOf(headersMap.get(key)));
                }

                // Send the request
                Http http = new Http();
                HttpResponse res = http.send(req);

                // Check the response status and return the document or template list if successful
                if (res.getStatusCode() == 200) {
                    if (type == 'documents') {
                        System.debug('Signwell Document IDs: ' + res.getBody());
                    } else if (type == 'templates') {
                        System.debug('Signwell Template IDs: ' + res.getBody());
                    }
                    return res.getBody();  // Return the document or template list as a JSON string
                    
                } else {
                    System.debug('Failed to fetch ' + type + ' from SignWell. Status: ' + res.getStatusCode());
                    return 'Error: Unable to fetch ' + type + '. Status: ' + res.getStatusCode();
                }
            } catch (Exception e) {
                System.debug('Exception while fetching ' + type + ' from SignWell: ' + e.getMessage());
                return 'Error: Exception occurred - ' + e.getMessage();
            }
        } else {
            return 'Error: No metadata found for SignWell ' + type + ' API.';
        }
    }
}