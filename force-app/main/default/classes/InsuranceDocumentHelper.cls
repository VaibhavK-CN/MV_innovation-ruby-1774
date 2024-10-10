public class InsuranceDocumentHelper {
    @InvocableMethod
    public static void enqueueFetchPDFJob(List<List<Id>> insuranceDocumentIdsCollection) {
        for (List<Id> insuranceDocumentIds : insuranceDocumentIdsCollection) {
            List<Insurance_Documents__c> documents = [SELECT Id, Document_ld__c FROM Insurance_Documents__c WHERE Id IN :insuranceDocumentIds];
            for (Insurance_Documents__c doc : documents) {
                if (doc.Document_ld__c != null) {
                    enqueueJobAsync(doc.Document_ld__c);
                }
            }
        }
    }

    @future
    public static void enqueueJobAsync(String documentId) {
        System.enqueueJob(new SignWellFetchPDFJob(documentId));
    }
}