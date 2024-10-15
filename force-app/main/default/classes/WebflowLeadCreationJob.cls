public class WebflowLeadCreationJob implements Queueable {
    private String dialCode;
    private String email;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String postcode;

    // Constructor to initialize the required fields
    public WebflowLeadCreationJob(String dialCode, String email, String firstName, String lastName, String phoneNumber, String postcode) {
        this.dialCode = dialCode;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phoneNumber = phoneNumber;
        this.postcode = postcode;
    }

    // The execute method that will create the Lead
    public void execute(QueueableContext context) {
        try {
            System.debug('Creating Lead record from Webflow data...');

            // Create a new Lead record
            Lead newLead = new Lead();
            newLead.FirstName = firstName;
            newLead.LastName = lastName;
            newLead.Email = email;
            newLead.MobilePhone = dialCode + ' ' + phoneNumber; // Combine dial code and phone number
            newLead.PostalCode = postcode;
            newLead.Company = 'Webflow'; // // Hard Coded
            newLead.Date_of_Birth__c = Date.parse('31/12/2024'); // Hard Coded
            newLead.Source__c = 'Recommendation'; //Hard Coded

            
          
            // Insert the Lead record
            insert newLead;

            System.debug('Lead created successfully with ID: ' + newLead.Id);

        } catch (Exception e) {
            System.debug('Error creating Lead: ' + e.getMessage());
        }
    }
}