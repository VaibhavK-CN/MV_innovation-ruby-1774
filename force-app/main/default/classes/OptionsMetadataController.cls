public with sharing class OptionsMetadataController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getOptionsMetadata() {
        List<Map<String, String>> optionsList = new List<Map<String, String>>();
        for (Options_Metadata__mdt metadata : [SELECT Template_Name__c, Template_Id__c, Language__c FROM Options_Metadata__mdt]) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', metadata.Template_Name__c);
            option.put('value', metadata.Template_Id__c);
            option.put('language', metadata.Language__c );
            optionsList.add(option);
        }
        System.debug(optionsList);
        return optionsList;
    }
}