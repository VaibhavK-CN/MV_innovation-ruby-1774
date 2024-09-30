public class NestedGroupHelper {

    // Method to retrieve user IDs from nested groups
    public static Set<Id> getUserIdsFromNestedGroups(Id groupId) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> processedGroups = new Set<Id>();
        
        // Call recursive method to collect user IDs
        collectUserIdsFromNestedGroups(groupId, userIds, processedGroups);        
        return userIds;
    }

    // Recursive method to collect user IDs from nested groups
    private static void collectUserIdsFromNestedGroups(Id groupId, Set<Id> userIds, Set<Id> processedGroups) {
        // Check if the group has already been processed to avoid infinite loops
        if (processedGroups.contains(groupId)) {
            return;
        }
        
        // Add the group to the set of processed groups
        processedGroups.add(groupId);

        // Query group members
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :groupId];

        for (GroupMember member : groupMembers) {
            // Check if the member is a user
            if (member.UserOrGroupId.getSObjectType() == User.sObjectType) {
                userIds.add((Id)member.UserOrGroupId);
            }
            // Check if the member is a group and call the method recursively
            else if (member.UserOrGroupId.getSObjectType() == Group.sObjectType) {
                collectUserIdsFromNestedGroups((Id)member.UserOrGroupId, userIds, processedGroups);
            }
        }
    }
}