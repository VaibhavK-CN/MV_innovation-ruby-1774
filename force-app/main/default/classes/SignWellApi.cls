public class SignWellApi {
    Private static final String INTEGRATION_NAME  = 'SignWellApi';
    Private static final String DOCUMENT_STATUS  = 'SignWellGetDocumentApi';

    // Call Dynamic Integration Handler
    @AuraEnabled
    public static String sendDocumentForDigitalSign(String parameter, String leadId){
        System.debug('parameter::::'+parameter);
        System.debug('leadId::::'+leadId);
        Lead l = [SELECT Id, Email FROM Lead WHERE Id =: leadId];
        
        Map<String,String> paramters  = new Map<String,String>();
        String requestBody = '{"test_mode":true,"draft":false,"with_signature_page":false,"reminders":true,"apply_signing_order":false,"embedded_signing":false,"embedded_signing_notifications":false,"text_tags":false,"allow_decline":true,"allow_reassign":true,"template_id":"' + parameter + '","recipients":[{"send_email":false,"send_email_delay":0,"id":"4","email":"'+l.Email+'","placeholder_name":"client"}]}';
        paramters.put('requestBody',requestBody);
        String result;
        result = DynamicIntegrationHandler.makeDynamicCallout(INTEGRATION_NAME,paramters);
        System.debug('result:::::'+result);
        // DOcument create in org
        SignWellApiWrapper data =  (SignWellApiWrapper) System.JSON.deserialize(result, SignWellApiWrapper.class);
        Insurance_Documents__c idocs = new Insurance_Documents__c();
        idocs.Lead__c = leadId;
        idocs.Document_ld__c = data.id;
        idocs.Document_Name__c = data.Name;
     	idocs.Document_link__c = data.recipients[0].signing_url;
        idocs.Email__c = data.recipients[0].email;
        if(data.recipients[0].status == 'created') {
            idocs.Status__c = 'Sent';
        }
        insert idocs;  
        
        return result;
    }
    // Get current status of documents
    @AuraEnabled
    public static List<Insurance_Documents__c> getDocumentsStatus(List<Insurance_Documents__c> parameter, String leadId) {
        List<String> DocIdList = new List<String>();
        for(Insurance_Documents__c idoc : parameter) {
            if(idoc.Document_ld__c != null && idoc.Document_ld__c != '') {
                DocIdList.add(idoc.Document_ld__c);
            }
        }
        
        List<Insurance_Documents__c>  result = DynamicIntegrationHandler.getDocumentStatus(DOCUMENT_STATUS, DocIdList);
        System.debug('result::: '+result);        
		
        return result;
    }
    
    public class SignWellApiWrapper{
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