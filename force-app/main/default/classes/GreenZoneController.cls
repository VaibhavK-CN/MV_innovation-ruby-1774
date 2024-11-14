public with sharing class GreenZoneController {
    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> getAvailableAppointments() {
        try {
            // Query appointments with relevant fields
            return [SELECT Id, Name, Appointment_Date_Time__c, Lead__c FROM Appointment__c];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching appointments: ' + e.getMessage());
        }
    }
}