public class LeadControllerForCancellationLink {
    public Lead leadObj { get; set; }
    public String leadNameToMatch { get; set; }
    public String successMessage { get; set; }
    public String errorMessage { get; set; }
    
    public LeadControllerForCancellationLink() {
        // Initialize leadObj or perform other setup logic
        leadObj = new Lead();
        // leadObj.Wish_to_Cancel__c = True;
        leadNameToMatch = '';
        successMessage = '';
        errorMessage = '';
        
    }
    
    public PageReference saveLead() {
        // Check if the First Name and Last Name match any lead records
        List<Lead> matchingLeads = [SELECT Id, FirstName, LastName,Email,Date_of_Birth__c FROM Lead WHERE FirstName = :leadObj.FirstName AND LastName = :leadObj.LastName AND Date_of_Birth__c =:leadObj.Date_of_Birth__c AND Email =:leadObj.Email LIMIT 1];
        
        if (matchingLeads.size() > 0) {
            // Update the matching lead record
            Lead matchingLead = matchingLeads[0];
            // matchingLead.Email = leadObj.Email;
            matchingLead.Cancelation_Reason__c = leadObj.Cancelation_Reason__c;
            matchingLead.Wish_to_Cancel__c = True;
            //  matchingLead.Date_of_Birth__c = leadObj.Date_of_Birth__c;
            update matchingLead;
            
            // Add a success message
            this.successMessage = 'Your applications cancellation is being processed.';
            // Redirect to a success page or modify as needed
            PageReference successPage = new PageReference('/apex/LeadControllerForCancellationLinkVF?');
            successPage.setRedirect(true);
            return null;
        } else {
            this.errorMessage = 'No matching lead found.';
            // Display an error message if no matching lead is found
            return null;
        }
    }
}