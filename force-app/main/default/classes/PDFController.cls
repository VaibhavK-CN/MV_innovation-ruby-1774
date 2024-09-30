public class PDFController {
    public Lead record { get; private set; }
    public Boolean showLump_sum_payment_after_24_hours { get; private set; }
    public Boolean showAccess_and_support_from_specialists { get; private set; }
    public Boolean showSecond_opinion_by_experts { get; private set; }
    public Boolean showAccess_to_renowned_clinics { get; private set; }
    public Boolean showAccess_to_the_latest_technologies { get; private set; }
    public Boolean showFast_tracking { get; private set; }
    public Boolean showHospitalization_abroad { get; private set; }
    public Boolean showTransportation_Rescue_domestic_foreign { get; private set; }
    
    public PDFController(ApexPages.StandardController controller) {
        record = (Lead)controller.getRecord();
        // Determine which fields to show based on the checkbox status
        showLump_sum_payment_after_24_hours = record.Lump_sum_payment_after_24_hours__c;
        
        showAccess_and_support_from_specialists = record.Lump_sum_payment_after_24_hours__c;
        showSecond_opinion_by_experts = record.Second_opinion_by_experts__c;
        showAccess_to_renowned_clinics = record.Access_to_renowned_clinics__c;
        showAccess_to_the_latest_technologies = record.Access_to_the_latest_technologies__c;
        showFast_tracking = record.Fast_tracking__c;
        showHospitalization_abroad = record.Hospitalization_abroad__c;
        showTransportation_Rescue_domestic_foreign = record.Transportation_Rescue_domestic_foreign__c;
        
        
    }
}