trigger LeadUploadTagTrigger on Lead (before insert, before update) {
    // Query for active Users in the Appointment Setter and System Administrator profiles
    List<User> appointmentSetters = [
        SELECT Id FROM User 
        WHERE Profile.Name = 'Appointment Setter' AND IsActive = true
    ];
    
    List<User> systemAdmins = [
        SELECT Id FROM User 
        WHERE Profile.Name = 'System Administrator' AND IsActive = true 
        LIMIT 1
    ];

    Id systemAdminId = systemAdmins.isEmpty() ? null : systemAdmins[0].Id;

    // Track the index for round-robin assignment
    Integer appointmentSetterIndex = 0;

    for (Lead lead : Trigger.new) {
        // Check the Upload Tag value and assign accordingly
        if (lead.Upload_Tag__c == 'New') {
            // Assign to Appointment Setter
            if (!appointmentSetters.isEmpty()) {
                lead.OwnerId = appointmentSetters[appointmentSetterIndex].Id;

                // Update the index for next assignment (wrap around if needed)
                appointmentSetterIndex++;
                if (appointmentSetterIndex >= appointmentSetters.size()) {
                    appointmentSetterIndex = 0; // Reset to the first Appointment Setter
                }
            } else {
                // Handle case where no active Appointment Setter is found
                // (Optional: log a message or set a default owner)
            }
        } else {
            // Assign to System Administrator
            if (systemAdminId != null) {
                lead.OwnerId = systemAdminId;
            } else {
                // Handle case where no active System Admin is found
                // (Optional: log a message or set a default owner)
            }
        }
    }
}