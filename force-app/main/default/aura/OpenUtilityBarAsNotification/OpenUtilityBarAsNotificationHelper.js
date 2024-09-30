({
    // opening utility
    openUtilityPopUp: function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function (response) {
            if (typeof response !== 'undefined') {
                utilityAPI.openUtility();
            }
        });
    },
        // Closing  utility

        closeUtilityPopUp: function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function (response) {
            if (typeof response !== 'undefined') {
                utilityAPI.minimizeUtility();
            }
        });
    }
})