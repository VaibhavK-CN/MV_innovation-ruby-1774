// leadUpdateFormController.js
({
    init: function(component, event, helper) {
        // Set the leadId attribute based on the URL parameter or any other method you prefer
        component.set("v.leadId", "yourLeadIdHere");
    },

    saveLead: function(component, event, helper) {
        var leadId = component.get("v.leadId");
        var name = component.get("v.name");
        var email = component.get("v.email");
        var dob = component.get("v.dob");
        var phone = component.get("v.phone");
        var cancellationReason = component.get("v.cancellationReason");

        // Call the Apex method to update the lead
        var action = component.get("c.updateLead");
        action.setParams({
            "leadId": leadId,
            "name": name,
            "email": email,
            "dob": dob,
            "phone": phone,
            "cancellationReason": cancellationReason
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success, e.g., show a confirmation message
            } else {
                // Handle errors
                console.error(response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})