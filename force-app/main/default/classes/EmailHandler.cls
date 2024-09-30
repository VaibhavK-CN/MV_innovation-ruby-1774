global class EmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        System.debug('received::::');
        // Check if the recipient email belongs to a Back Office user
        String recipientEmail = email.toAddresses != null && !email.toAddresses.isEmpty() ? email.toAddresses[0] : null;
       System.debug('Check:::'+isBackOfficeUser(recipientEmail));
        if (!isBackOfficeUser(recipientEmail)) {
            // Check 
            System.debug('Email:::'+email);
            EmailBodyKeyWordDetection.processApprovalRejection(email);
            // Forward the email to the Email Service
           // forwardEmail(email, 'e.awishkark@deaninfotech.com');
        }
        
        // Return result
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.message = 'Email processed successfully';
        return result;
    }
    
    private Boolean isBackOfficeUser(String email) {
        List<User> backOfficeUsers = [SELECT Id FROM User WHERE Profile.Name = 'Back Office' AND Email = :email LIMIT 1];
        
        // Check if any user records were found
        return !backOfficeUsers.isEmpty();
    }
    
    private void forwardEmail(Messaging.InboundEmail email, String destinationAddress) {
        // Create a new Email Message record
        Messaging.SingleEmailMessage forwardMessage = new Messaging.SingleEmailMessage();
        
        // Set the sender email address
        forwardMessage.setOrgWideEmailAddressId(UserInfo.getOrganizationId());
        
        // Set the recipient email address
        forwardMessage.setToAddresses(new String[]{destinationAddress});
        
        // Set the email subject
        forwardMessage.setSubject(email.subject);
        
        // Set the email body
        String forwardedBody = 'Forwarded Email:\n\n' + email.plainTextBody;
        forwardMessage.setPlainTextBody(forwardedBody);
        
        // Optionally, set the email HTML body
        // forwardMessage.setHtmlBody(email.htmlBody);
        
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{forwardMessage});
    }
}