public class LeadAssignmentController {

    public LeadAssignmentController(ApexPages.StandardController controller) {
    }

    public String selectedProfileId { get; set; } // Stores selected Profile ID
    public Id selectedUserId { get; set; } // Stores selected User ID

    public List<SelectOption> getProfileOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('Call Agent', 'Advisor')];

        for (Profile profile : profiles) {
            options.add(new SelectOption(profile.Id, profile.Name));
        }
        return options;
    }

    public List<SelectOption> getUserOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if (selectedProfileId != null) {
            List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = :selectedProfileId AND IsActive = TRUE];
            for (User user : users) {
                options.add(new SelectOption(user.Id, user.Name));
            }
        }
        return options;
    }

    public PageReference assignLead() {
        if (selectedUserId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a user.'));
            return null; // Stay on the same page if no user is selected
        }

        Lead lead = [SELECT OwnerId FROM Lead WHERE Id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        lead.OwnerId = selectedUserId; // Assign to the selected user
        update lead;

        PageReference leadDetailPage = new PageReference('/' + lead.Id);
        leadDetailPage.setRedirect(true);
        return leadDetailPage; 
    }
}