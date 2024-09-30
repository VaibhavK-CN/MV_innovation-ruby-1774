// Apex class to handle dynamic integration
public class DynamicIntegrationHandler {
    @AuraEnabled
    public static String makeDynamicCallout(String integrationName, Map<String, String> parameters) {
        // Retrieve metadata record based on integrationName
        IntegrationMetadata__mdt metadata = getMetadata(integrationName);
        
        if (metadata != null) {
            // Construct HTTP request dynamically
            HttpRequest req = new HttpRequest();
            req.setEndpoint(metadata.Endpoint__c);
            req.setMethod(metadata.Method__c);
            
            // Parse the JSON string into a Map<String, Object>
            Map<String, Object> headersMap = (Map<String, Object>)JSON.deserializeUntyped(metadata.Header__c);
            
            // Convert the values to strings and store them in a Map<String, String>
            Map<String, String> headers = new Map<String, String>();
            for (String key : headersMap.keySet()) {
                headers.put(key, String.valueOf(headersMap.get(key)));
            }
            // Set headers on the request
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
            
            System.debug('headers:::'+headers);
            
            
            // Add parameters to the request body or URL query params
            if (metadata.Method__c == 'POST' || metadata.Method__c == 'PUT') {
                System.debug('parameters'+parameters);
                req.setBody(parameters.get('requestBody'));
            } else if (metadata.Method__c == 'GET' || metadata.Method__c == 'DELETE') {
                // Add query parameters to the URL
            }
            System.debug('req:::::'+req);
            // Make HTTP callout
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Handle response
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                return res.getbody();
            } else {
                System.debug('Other code::::'+res.getStatusCode());
                return '';
                // Error handling
            }
        }
        return '';
    }
    // Document Status
    @AuraEnabled
    public static List<Insurance_Documents__c> getDocumentStatus(String integrationName, List<String> parameters) {
        //System.debug(parameters);
        List<Insurance_Documents__c> idcList = new  List<Insurance_Documents__c>();
        Set<String> docIdSet = new Set<String>();
        IntegrationMetadata__mdt metadata = getMetadata(integrationName);
        if (metadata != null) {
            // Construct HTTP request dynamically
            for(String s : parameters) {
                docIdSet.add(s);
                HttpRequest req = new HttpRequest();
                String endpoint = metadata.Endpoint__c+s;
                system.debug(endpoint);
                req.setEndpoint(endpoint);
                req.setMethod(metadata.Method__c);
                // Parse the JSON string into a Map<String, Object>
                Map<String, Object> headersMap = (Map<String, Object>)JSON.deserializeUntyped(metadata.Header__c);
                
                // Convert the values to strings and store them in a Map<String, String>
                Map<String, String> headers = new Map<String, String>();
                for (String key : headersMap.keySet()) {
                    headers.put(key, String.valueOf(headersMap.get(key)));
                }
                // Set headers on the request
                for (String key : headers.keySet()) {
                    req.setHeader(key, headers.get(key));
                }
                Http http = new Http();
                HttpResponse res = http.send(req);
                // Handle response
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    String result = res.getbody();
                    DocumentStausWrapper data =  (DocumentStausWrapper) System.JSON.deserialize(result, DocumentStausWrapper.class);
                    Insurance_Documents__c idc = [SELECT Id, Document_ld__c, Status__c FROM Insurance_Documents__c WHERE Document_ld__c =: data.id];
                    Insurance_Documents__c idoc = new Insurance_Documents__c();
                    idoc.Id = idc.Id;
                    idoc.Status__c = data.status;
                    idcList.add(idoc);
                    
                } else {
                    System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
                }
            }
            system.debug(idcList);
            if(idcList.size() > 0) {
                update idcList;
            }
            List<Insurance_Documents__c> insList = [SELECT Id, Name, Document_ld__c, Document_Name__c, Document_link__c, Status__c 
                                                    FROM Insurance_Documents__c WHERE Document_ld__c IN:docIdSet ORDER BY CreatedDate DESC];
            return insList;
        }
        return null;
    }
    private static IntegrationMetadata__mdt getMetadata(String integrationName) {
        // Query metadata record based on integration name
        return [SELECT Id, Endpoint__c, Method__c,Header__c FROM IntegrationMetadata__mdt WHERE DeveloperName = :integrationName LIMIT 1];
    }
    public class DocumentStausWrapper {
        public String id;
        public String status;
    }
}