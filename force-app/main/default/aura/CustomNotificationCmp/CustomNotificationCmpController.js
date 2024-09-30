// Your Aura Helper Code

({
    // Your other helper logic...
    
    getNotificationTitle: function(component) {
        console.log('I am from getNotificationTitle:::');
        
        // Get a reference to the forceCommunity:notifications component
        var notificationComponent = component.find("notificationComponent");
        if (notificationComponent) {
            // Access the list of notifications
            var notifications = notificationComponent.get("v.notifications");
            
            // Assuming each notification has a 'title' property
            if (notifications && notifications.length > 0) {
                var firstNotificationTitle = notifications[0].title;
                console.log("Notification Title: " + firstNotificationTitle);
            }
        }
    },
    
    // Your Aura Controller Code
    
    
    onInit: function(component, event, helper) {
        // Call the method when the component is initialized
        helper.manipulateBodyContent(component);
    }
    
    // Your other controller logic...
    
    
    // Your other helper logic...
})