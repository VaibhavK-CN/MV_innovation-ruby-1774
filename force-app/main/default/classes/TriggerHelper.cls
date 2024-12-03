public class TriggerHelper {
    private static Boolean isTriggerActive = true; // Prevent recursive triggers

    // Method to check and control recursion
    public static Boolean isTriggerAllowed() {
        if (isTriggerActive) {
            isTriggerActive = false;
            return true;
        }
        return false;
    }

    // Method to reset recursion control
    public static void resetTrigger() {
        isTriggerActive = true;
    }
}