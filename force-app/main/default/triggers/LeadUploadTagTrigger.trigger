trigger LeadUploadTagTrigger on Lead (before insert, before update) {
    // Query for Users in the Appointment Setter and System Administrator profiles
    List<User> appointmentSetters = [SELECT Id FROM User WHERE Profile.Name = 'Appointment Setter' LIMIT 1];
    List<User> systemAdmins = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

    Id appointmentSetterId = appointmentSetters.isEmpty() ? null : appointmentSetters[0].Id;
    Id systemAdminId = systemAdmins.isEmpty() ? null : systemAdmins[0].Id;

    for (Lead lead : Trigger.new) {
        // Check the Upload Tag value and assign accordingly
        if (lead.Upload_Tag__c == 'New') {
            // Assign to Appointment Setter
            if (appointmentSetterId != null) {
                lead.OwnerId = appointmentSetterId;
            } else {
                // Handle case where no Appointment Setter is found
                // (Optional: log a message or set a default owner)
            }
        } else {
            // Assign to System Administrator
            if (systemAdminId != null) {
                lead.OwnerId = systemAdminId;
            } else {
                // Handle case where no System Admin is found
                // (Optional: log a message or set a default owner)
            }
        }
    }
}