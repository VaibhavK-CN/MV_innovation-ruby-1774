public class LifeInsControllerForCancellationLink {
    public LifeInsurance__c LifeInsuranceObj { get; set; }
    public String LifeInsuranceNameToMatch { get; set; }
    public String successMessage { get; set; }
    public String errorMessage { get; set; }

    public LifeInsControllerForCancellationLink() {
        // Initialize LifeInsurance__cObj or perform other setup logic
        LifeInsuranceObj = new LifeInsurance__c();
        LifeInsuranceNameToMatch = '';
        successMessage = '';
        errorMessage = '';
    }

    public PageReference saveLifeIns() {
        // Check if the First Name and Last Name match any LifeInsurance__c records
        List<LifeInsurance__c> matchingLifeInsurance = [SELECT Id, Email__c, Date_of_Birth__c FROM LifeInsurance__c WHERE First_Name__c = :LifeInsuranceObj.First_Name__c AND Last_Name__c = :LifeInsuranceObj.Last_Name__c AND Date_of_Birth__c = :LifeInsuranceObj.Date_of_Birth__c AND Email__c = :LifeInsuranceObj.Email__c LIMIT 1];

        if (matchingLifeInsurance.size() > 0) {
            // Update the matching LifeInsurance__c record
            LifeInsurance__c matchingLifeInsurance1 = matchingLifeInsurance[0];
            matchingLifeInsurance1.Cancellation_Reason__c = LifeInsuranceObj.Cancellation_Reason__c;
            matchingLifeInsurance1.Wish_to_Cancel__c = true;
            update matchingLifeInsurance1;

            // Add a success message
            this.successMessage = 'Your applications cancellation is being processed.';
            // Redirect to a success page or modify as needed
            // PageReference successPage = new PageReference('/apex/LifeInsurance__cControllerForCancellationLinkVF?id=');
           //  successPage.setRedirect(true);
            return null;
        } else {
            this.errorMessage = 'No matching LifeInsurance__c found.';
            // Display an error message if no matching LifeInsurance__c is found
            return null;
        }
    }
}