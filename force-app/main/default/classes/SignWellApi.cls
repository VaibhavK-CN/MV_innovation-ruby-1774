public class SignWellApi {
    Private static final String INTEGRATION_NAME  = 'SignWellApi';
    Private static final String DOCUMENT_STATUS  = 'SignWellGetDocumentApi';

    // Call Dynamic Integration Handler
    @AuraEnabled
    public static String sendDocumentForDigitalSign(String parameter, String leadId) {
        System.debug('parameter::::' + parameter);
        System.debug('leadId::::' + leadId);
        
        // Fetch Lead record
        Lead l = [SELECT Id, Email, FirstName, LastName, Date_of_Birth__c FROM Lead WHERE Id = :leadId];

        // Prepare template fields based on the parameter
        List<Map<String, String>> templateFields = new List<Map<String, String>>();

        // Conditional logic based on 'parameter'
        if (parameter == '08dfae7a-a345-41f9-a3fe-b5953efbecfe' || parameter == '60e115b6-fac2-4a7d-b15b-93b5352ffc12'){ //Article 45 English & German
            // For Article 45 Template, we need FirstName 
            templateFields.add(new Map<String, String>{'api_id' => 'PH_FName', 'value' => l.FirstName});
           // templateFields.add(new Map<String, String>{'api_id' => 'PH_LName', 'value' => l.LastName});
        } else if (parameter == 'template_id_2') {
            // For Template 2, we need Date of Birth
            templateFields.add(new Map<String, String>{'api_id' => 'PH_DOB', 'value' => l.Date_of_Birth__c != null ? l.Date_of_Birth__c.format() : ''});
        } else if (parameter == 'template_id_3') {
            // For Template 3, we need FirstName and a custom value
            templateFields.add(new Map<String, String>{'api_id' => 'PH_FName', 'value' => l.FirstName});
            templateFields.add(new Map<String, String>{'api_id' => 'PH_Custom', 'value' => 'Custom Value'});
        } else {
            // Default template fields if no specific template matches
            templateFields.add(new Map<String, String>{'api_id' => 'PH_DefaultField', 'value' => 'Default Value'});
        }

        // Construct the request body
        Map<String, String> parameters = new Map<String, String>();
        String requestBody = '{"test_mode":false,"draft":false,"with_signature_page":false,"reminders":true,"apply_signing_order":false,"embedded_signing":false,"embedded_signing_notifications":false,"text_tags":false,"allow_decline":true,"allow_reassign":true,"template_id":"' 
                    + parameter 
                    + '","template_fields":' 
                    + JSON.serialize(templateFields) 
                    + ',"recipients":[{"send_email":false,"send_email_delay":0,"id":"4","email":"' 
                    + l.Email 
                    + '","placeholder_name":"client"}]}';

        parameters.put('requestBody', requestBody);
        String result = DynamicIntegrationHandler.makeDynamicCallout(INTEGRATION_NAME, parameters);
        System.debug('result:::::' + result);

        // Document creation in Salesforce
        SignWellApiWrapper data = (SignWellApiWrapper) System.JSON.deserialize(result, SignWellApiWrapper.class);
        Insurance_Documents__c idocs = new Insurance_Documents__c();
        idocs.Lead__c = leadId;
        idocs.Document_ld__c = data.id;
        idocs.Document_Name__c = data.name;
        idocs.Document_link__c = data.recipients[0].signing_url;
        idocs.Email__c = data.recipients[0].email;
        if (data.recipients[0].status == 'created') {
            idocs.Status__c = 'Sent';
        }
        insert idocs;

        return result;
    }

    // Get current status of documents
    @AuraEnabled
    public static List<Insurance_Documents__c> getDocumentsStatus(List<Insurance_Documents__c> parameter, String leadId) {
        List<String> DocIdList = new List<String>();
        for (Insurance_Documents__c idoc : parameter) {
            if (idoc.Document_ld__c != null && idoc.Document_ld__c != '') {
                DocIdList.add(idoc.Document_ld__c);
            }
        }
        
        List<Insurance_Documents__c> result = DynamicIntegrationHandler.getDocumentStatus(DOCUMENT_STATUS, DocIdList);
        System.debug('result::: ' + result);

        return result;
    }

    // Wrapper for parsing the response from SignWell API
    public class SignWellApiWrapper {
        public String id;
        public String name;
        public cls_recipients[] recipients;
    }

    class cls_recipients {
        public String email;
        public String status;
        public String signing_url;
    }
}