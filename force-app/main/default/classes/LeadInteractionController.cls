public with sharing class LeadInteractionController {

    // Method to get a list of Feedback records for a specific Lead
    @AuraEnabled(cacheable=true)
    public static List<String> getFeedbackList(Id leadId) {
        try {
            // Example predefined feedback options
            List<String> feedbackList = new List<String>{
                'Appointment Planned', 'Callback Required', 'Reassign', 'Unqualified', 'Blacklist', 'Feedback / Backoffice Tasks'
            };
            return feedbackList;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching feedback: ' + e.getMessage());
        }
    }

    // Method to get a list of Sub-feedback records for a specific Feedback type
    @AuraEnabled(cacheable=true)
    public static List<String> getSubFeedbackList(Id leadId, String feedbackType) {
        try {
            List<String> subFeedbackList = new List<String>();

            // Add sub-feedback based on the feedback type
            if (feedbackType == 'Appointment Planned') {
                subFeedbackList.add('Future Appointment Planned');
                subFeedbackList.add('Immediate Appointment Requested');
            } else if (feedbackType == 'Callback Required') {
                subFeedbackList.add('Callback Requested - No Time Specified');
                subFeedbackList.add('Callback Requested - Time Specified');
                subFeedbackList.add('Not Reached');
                subFeedbackList.add('Not Interested / Wrong Timing');
                subFeedbackList.add('Other');
            } else if (feedbackType == 'Reassign') {
                subFeedbackList.add('Wrong Language');
                subFeedbackList.add('Other');
            } else if (feedbackType == 'Unqualified') {
                subFeedbackList.add('Incorrect Information');
                subFeedbackList.add('Undergoing Medical Treatment');
                subFeedbackList.add('Multi-Year Contract');
                subFeedbackList.add('No interest / Reached follow-up limit');
                subFeedbackList.add('Other');
            } else if (feedbackType == 'Blacklist') {
                subFeedbackList.add('Aggressive, Inappropriate Behaviour, Complaint');
                subFeedbackList.add('Data Removal Request');
                subFeedbackList.add('Other');
            } else if (feedbackType == 'Feedback / Backoffice Tasks') {
                subFeedbackList.add('Complaint');
                subFeedbackList.add('Customer feedback');
                subFeedbackList.add('Backoffice task to do');
                subFeedbackList.add('Task for insurer');
                subFeedbackList.add('Other');
            }

            return subFeedbackList;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching sub-feedback: ' + e.getMessage());
        }
    }

    // Method to get the current user's profile name
     @AuraEnabled(cacheable=true)
    public static String getUserProfile() {
        try {
            // Get the current user's ProfileId using UserInfo.getProfileId()
            Id profileId = UserInfo.getProfileId();
            
            // Query the Profile object to get the Profile Name using the ProfileId
            Profile userProfile = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1];
            
            return userProfile.Name;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching user profile: ' + e.getMessage());
        }
    }

    // Method to create a new Lead Interaction Detail record with Comment field
    @AuraEnabled
    public static String createLeadInteractionDetail(
    Id leadId,
    DateTime preferredDateTime,
    String feedback,
    String subFeedback,
    String comment
    ) {
    try {
        // Insert the Lead Interaction Detail record
        Lead_Interaction_Detail__c newRecord = new Lead_Interaction_Detail__c(
            Lead__c = leadId,
            Preferred_Date_Time__c = preferredDateTime,
            Feedback__c = feedback,
            Sub_Feedback__c = subFeedback,
            Comment__c = comment // Save the comment
        );
        insert newRecord;



        return newRecord.Id;
    } catch (Exception e) {
        throw new AuraHandledException('Error: ' + e.getMessage());
    }
    }


    @AuraEnabled
    public static Boolean isInteracted(Id leadId) {
        // Query to find tasks associated with the lead
        List<Task> logs = [SELECT Id FROM Task WHERE WhoId = :leadId AND Status = 'Completed'];
        
        // Determine if there is interaction
        Boolean interacted = !logs.isEmpty();
        
        return interacted;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean shouldShowFeedbackComponent(Id leadId) {
    try {
        Lead lead = [SELECT Show_Feedback_Component__c FROM Lead WHERE Id = :leadId LIMIT 1];
        return lead.Show_Feedback_Component__c;
    } catch (Exception e) {
        throw new AuraHandledException('Error checking feedback visibility: ' + e.getMessage());
    }
    }

    @AuraEnabled
    public static void updateTaskStatusToClosed(Id leadId) {  //////////////////
        system.debug('LEAD ID: ' + leadId);
        List<Task> tasksToUpdate = [
                                        SELECT Id, Status
                                        FROM Task
                                        WHERE WhoId = :leadId AND Status = 'Completed'
                                    ];

        // Create a new list to hold tasks for update
        List<Task> tasksForUpdate = new List<Task>();
        system.debug('List of Query for tasks : ' + tasksForUpdate);

        if (!tasksToUpdate.isEmpty()) {
            system.debug('tasksToUpdate query is not empty');
            for(Task oldTask : tasksToUpdate) {
                // Create a new instance and set its Id and fields to be updated
                Task updatedTask = new Task();
                updatedTask.Id = oldTask.Id; // Reference the original task's Id
                updatedTask.Status = 'Closed'; // Update the field
                tasksForUpdate.add(updatedTask); // Add to the list
                system.debug('task updating for closed : ' + updatedTask);
            }
            // Perform the update operation
            update tasksForUpdate;
            system.debug('Task updated successfull');
        }

            
            }

}