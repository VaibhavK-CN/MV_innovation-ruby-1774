public with sharing class OptionsMetadataController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getOptionsMetadata(Id leadId) {
        // Fetch the Lead's preferred language
        Lead leadRecord = [SELECT Langauge_Prefered__c FROM Lead WHERE Id = :leadId LIMIT 1];
        String preferredLanguage = leadRecord.Langauge_Prefered__c;

        // Prepare the result list
        List<Map<String, String>> optionsList = new List<Map<String, String>>();

        // Fetch all options metadata
        for (Options_Metadata__mdt metadata : [
            SELECT Template_Name__c, Template_Id__c, Language__c 
            FROM Options_Metadata__mdt
        ]) {
            // Only include the option with matching language and group by Template Name
            if (metadata.Language__c == preferredLanguage) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', metadata.Template_Name__c);
                option.put('value', metadata.Template_Id__c);  // Correct template ID for the language
                optionsList.add(option);
            }
        }

        // Return the final list
        return optionsList;
    }
}