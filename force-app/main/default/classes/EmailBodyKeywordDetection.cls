public class EmailBodyKeywordDetection {
    
    public static void processApprovalRejection(Messaging.InboundEmail email) {
        System.debug('EmailBodyKeywordDetection received::::');
        String plainEmailBody = email.plainTextBody;
        String emailBody = plainEmailBody.toLowerCase();
        String applicationId = extractApplicationId(plainEmailBody);
        System.debug('applicationId:::'+applicationId);
        
        Map<String, String> keywordActions = new Map<String, String>{
            'lead approved' => 'handleLeadApproval',
                'lead rejected' => 'handleLeadRejection',
                'lifeinsurance approved' => 'handleLifeInsuranceApproval',
                'lifeinsurance rejected' => 'handleLifeInsuranceRejection'
                
                
                // Add more keywords and associated actions as needed
                };
                    
                    for (String keyword : keywordActions.keySet()) {
                        if (emailBody.contains(keyword)) {
                            executeAction(keywordActions.get(keyword),applicationId, email.subject);
                            return;
                        }
                    }
        
        System.debug('Unable to find keyword::::');
    }
    
    private static void executeAction(String methodName,String applicationId, String subject) {
        switch on methodName {
            when 'handleLeadApproval' {
                handleLeadApproval(subject,applicationId);
            }
            when 'handleLeadRejection' {
                handleLeadRejection(subject,applicationId);
            }
            when 'handleLifeInsuranceApproval' {
                handleLifeInsuranceApproval(subject,applicationId);
            }
            when 'handleLifeInsuranceRejection' {
                handleLifeInsuranceRejection(subject,applicationId);
            }
            // Add more cases for additional methods
            when else {
                System.debug('Invalid method name: ' + methodName);
            }
        }
    }
    
    private static String extractApplicationId(String emailBody) {
        // Implement logic to extract ApplicationId from email body
        // Assuming that ApplicationId is in the format "ApplicationId:" followed by the actual ID in double quotes
        String applicationIdLabel = 'ApplicationId:"';
        Integer startIndex = emailBody.indexOf(applicationIdLabel);
        System.debug('startIndex:::'+startIndex);
        if (startIndex != -1) {
            // Finding the end of the double-quoted string
            Integer endIndex = emailBody.indexOf('"', startIndex + applicationIdLabel.length());
            if (endIndex != -1) {
                return emailBody.substring(startIndex + applicationIdLabel.length(), endIndex);
            }
        }
        return null;
    }
    
    // handle approval logic
    private static void handleLeadApproval(String subject, String applicationId) {
        try{
            System.debug('handleLeadApproval Subject:::: ' + subject);
            lead leadRecord = [Select Id,name from lead where Id =: applicationId limit 1];
            leadRecord.Insurance_Company_Status__c = 'Approved';
            update leadRecord;
            System.debug('leadRecord:::'+leadRecord);
        } catch (Exception e) {
            System.debug('Error processing approval/rejection: ' + e.getMessage());
        }
    }
    // handle rejected logic
    private static void handleLeadRejection(String subject, String applicationId) {
        try{
            System.debug('handleLeadRejection Subject' + subject);
            lead leadRecord = [Select Id,name from lead where Id =: applicationId limit 1];
            leadRecord.Insurance_Company_Status__c = 'Rejected';
            update leadRecord;
            System.debug('leadRecord:::'+leadRecord);
        } catch (Exception e) {
            System.debug('Error processing approval/rejection: ' + e.getMessage());
        }
    }
    
    // handle approval logic
    private static void handleLifeInsuranceApproval(String subject, String applicationId) {
        try{
            System.debug('handleLifeInsuranceApproval Subject' + subject);
            LifeInsurance__c LifeInsuranceRecord = [Select Id,name from LifeInsurance__c where Id =: applicationId limit 1];
            LifeInsuranceRecord.Insurance_Company_Status__c = 'Approved';
            update LifeInsuranceRecord;
            System.debug('LifeInsuranceRecord:::'+LifeInsuranceRecord);
        } catch (Exception e) {
            System.debug('Error processing approval/rejection: ' + e.getMessage());
        }
    }
    // handle rejected logic
    private static void handleLifeInsuranceRejection(String subject, String applicationId) {
        try{
            
            System.debug('handleLifeInsuranceRejection Subject' + subject);
            LifeInsurance__c LifeInsuranceRecord = [Select Id,name from LifeInsurance__c where Id =: applicationId limit 1];
            LifeInsuranceRecord.Insurance_Company_Status__c = 'Rejected';
            update LifeInsuranceRecord;
            System.debug('LifeInsuranceRecord:::'+LifeInsuranceRecord);
        } catch (Exception e) {
            System.debug('Error processing approval/rejection: ' + e.getMessage());
        }
    }
    
    
}