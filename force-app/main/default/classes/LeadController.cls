public class LeadController {
    /***Lead****/
    // Create a new Application Family Member records           
    @AuraEnabled
    public static List<ApplicationFamilyMember__c> saveFamilyMember(Id leadId, String payload) {
        List<ApplicationFamilyMember__c> familyMembers = new List<ApplicationFamilyMember__c>();
        List<ApplicationFamilyMember__c> listNeedToBeInsert = new List<ApplicationFamilyMember__c>();
        Lead lea = [SELECT Id, Age__c, Start_of_Insurance__c, AgePopulate__c, Accident__c, Insurance_Company_KVG__c,
                    Monthly_Premium_netto_KVG__c, Model_of_insurance_Application_Form__c, 
                    Deductible_Application_Form__c, Insurance_Company_VVG__c, Start_of_Insurance_VVG__c, 
                    Products__c, Monthly_Premium_netto_VVG__c, Name_of_Bank__c, 
                    The_customer_cancels_his_insurance_contr__c, The_customer_authorizes_the_intermediary__c, 
                    Cancelation_Date_KVG__c, Cancelation_Date_VVG__c, Cancel_KVG__c, Cancel_VVG__c, 
                    Recommendation__c, Follow_Up_Appointment__c, Houshold_Liability__c, Legal__c, Pillar__c,
                    Car_Insurance__c, Building_Insurance__c, Travel_Insurance__c, Google_Review__c
                    FROM Lead WHERE Id =:leadId];
        if (lea != null) { 
            List<FamilyMember> data =  (List<FamilyMember>) System.JSON.deserialize(payload, List<FamilyMember>.class);
            System.debug('data: '+data);
            for(FamilyMember fm : data) {
                ApplicationFamilyMember__c newFamilyMember = new ApplicationFamilyMember__c();
                newFamilyMember.Lead__c = leadId;
                newFamilyMember.Name = fm.name;
                newFamilyMember.Relationship__c = fm.relationship;
                newFamilyMember.Email__c = fm.email;
                newFamilyMember.Date_Of_Birth__c = fm.dob;
                newFamilyMember.Accident__c = lea.Accident__c;
                newFamilyMember.AgePopulate__c = lea.AgePopulate__c;
                newFamilyMember.Building_Insurance__c = lea.Building_Insurance__c;
                newFamilyMember.Cancelation_Date_KVG__c = lea.Cancelation_Date_KVG__c;
                newFamilyMember.Cancelation_Date_VVG__c = lea.Cancelation_Date_VVG__c;
                newFamilyMember.Cancel_KVG__c = lea.Cancel_KVG__c;
                newFamilyMember.Cancel_VVG__c = lea.Cancel_VVG__c;
                newFamilyMember.Car_Insurance__c = lea.Car_Insurance__c;
                newFamilyMember.Deductible__c = lea.Deductible_Application_Form__c;
                newFamilyMember.Follow_Up_Appointment__c = lea.Follow_Up_Appointment__c;
                newFamilyMember.Google_Review__c = lea.Google_Review__c;
                newFamilyMember.HousholdLiability__c = lea.Houshold_Liability__c;
                newFamilyMember.Insurance_Company_K__c = lea.Insurance_Company_KVG__c;
                newFamilyMember.Insurance_Company__c = lea.Insurance_Company_VVG__c;
                newFamilyMember.Legal__c = lea.Legal__c;
                newFamilyMember.Model_of_insurance__c = lea.Model_of_insurance_Application_Form__c;
                newFamilyMember.Monthly_Premium_netto_1__c = lea.Monthly_Premium_netto_KVG__c;
                newFamilyMember.Monthly_Premium_netto__c = lea.Monthly_Premium_netto_VVG__c;
                newFamilyMember.Name_of_Bank__c = lea.Name_of_Bank__c;
                newFamilyMember.Pillar__c = lea.Pillar__c;
                newFamilyMember.Products__c = lea.Products__c;
                newFamilyMember.Recommendation__c = lea.Recommendation__c;
                newFamilyMember.Start_of_Insurance_1__c = lea.Start_of_Insurance__c;
                newFamilyMember.Start_of_Insurance__c = lea.Start_of_Insurance_VVG__c;
                newFamilyMember.The_customer_authorizes_the_intermediary__c = lea.The_customer_authorizes_the_intermediary__c;
                newFamilyMember.The_customer_cancels_his_insurance_contr__c = lea.The_customer_cancels_his_insurance_contr__c;
                newFamilyMember.Travel_Insurance__c = lea.Travel_Insurance__c;
                listNeedToBeInsert.add(newFamilyMember);
            }
        }
        try {
            insert listNeedToBeInsert;
            familyMembers = [SELECT Id, Name, Lead__c, Relationship__c, CreatedDate
                             FROM ApplicationFamilyMember__c WHERE Lead__c = :leadId ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            System.debug('Error inserting Application Family Member record: ' + e.getMessage());
        }
        return familyMembers;
    }
    // Related List of Application Family Member
    @AuraEnabled( cacheable = true )
    public static List<ApplicationFamilyMember__c> getRelatedFamilyMembers(Id leadId) {
        List<ApplicationFamilyMember__c> familyMembers = new List<ApplicationFamilyMember__c>();
        familyMembers = [SELECT Id, Name, Lead__c, Relationship__c, CreatedDate
                         FROM ApplicationFamilyMember__c WHERE Lead__c = :leadId ORDER BY CreatedDate DESC];
        return familyMembers;
    }
    /***Life Insurance****/
    // Create a new Application Family Member records 
    @AuraEnabled
    public static List<ApplicationFamilyMember__c> saveFamilyMemberForLifeInsurance(Id recordId, String payload) {
        List<ApplicationFamilyMember__c> familyMembers = new List<ApplicationFamilyMember__c>();
        system.debug(recordId);
        system.debug(payload);
        List<ApplicationFamilyMember__c> listNeedToBeInsert = new List<ApplicationFamilyMember__c>();
        LifeInsurance__c lea = [SELECT Id, Age__c, AgePopulate__c, Accident__c, Insurance_Company_KVG__c,
                                Monthly_Premium_netto_KVG__c, Model_of_insurance_Application_Form__c, 
                                Deductible_Application_Form__c, Insurance_Company_VVG__c, Start_of_Insurance_VVG__c, 
                                Products__c, Monthly_Premium_netto_VVG__c, Name_of_Bank__c, 
                                The_customer_cancels_his_insurance_contr__c, The_customer_authorizes_the_intermediary__c, 
                                Cancelation_Date_KVG__c, Cancelation_Date_VVG__c, HousholdLiability__c, Cancel_KVG__c, Cancel_VVG__c, 
                                Recommendation__c, Follow_Up_Appointment__c, Legal__c, Pillar__c,
                                Car_Insurance__c, Building_Insurance__c,Start_of_Insurance_KVG__c,Travel_Insurance__c, Google_Review__c
                                FROM LifeInsurance__c WHERE Id =:recordId];
        if (lea != null) { 
            List<FamilyMember> data =  (List<FamilyMember>) System.JSON.deserialize(payload, List<FamilyMember>.class);
            System.debug('data: '+data);
            for(FamilyMember fm : data) {
                ApplicationFamilyMember__c newFamilyMember = new ApplicationFamilyMember__c();
                newFamilyMember.Life_Insurance__c = recordId;
                newFamilyMember.Name = fm.name;
                newFamilyMember.Relationship__c = fm.relationship;
                newFamilyMember.Email__c = fm.email;
                newFamilyMember.Date_Of_Birth__c = fm.dob;
                newFamilyMember.Accident__c = lea.Accident__c;
                newFamilyMember.AgePopulate__c = lea.AgePopulate__c;
                newFamilyMember.Building_Insurance__c = lea.Building_Insurance__c;
                newFamilyMember.Cancelation_Date_KVG__c = lea.Cancelation_Date_KVG__c;
                newFamilyMember.Cancelation_Date_VVG__c = lea.Cancelation_Date_VVG__c;
                newFamilyMember.Cancel_KVG__c = lea.Cancel_KVG__c;
                newFamilyMember.Cancel_VVG__c = lea.Cancel_VVG__c;
                newFamilyMember.Car_Insurance__c = lea.Car_Insurance__c;
                newFamilyMember.Deductible__c = lea.Deductible_Application_Form__c;
                newFamilyMember.Follow_Up_Appointment__c = lea.Follow_Up_Appointment__c;
                newFamilyMember.Google_Review__c = lea.Google_Review__c;
                newFamilyMember.HousholdLiability__c = lea.HousholdLiability__c;
                newFamilyMember.Insurance_Company_K__c = lea.Insurance_Company_KVG__c;
                newFamilyMember.Insurance_Company__c = lea.Insurance_Company_VVG__c;
                newFamilyMember.Legal__c = lea.Legal__c;
                newFamilyMember.Model_of_insurance__c = lea.Model_of_insurance_Application_Form__c;
                newFamilyMember.Monthly_Premium_netto_1__c = lea.Monthly_Premium_netto_KVG__c;
                newFamilyMember.Monthly_Premium_netto__c = lea.Monthly_Premium_netto_VVG__c;
                newFamilyMember.Name_of_Bank__c = lea.Name_of_Bank__c;
                newFamilyMember.Pillar__c = lea.Pillar__c;
                newFamilyMember.Products__c = lea.Products__c;
                newFamilyMember.Recommendation__c = lea.Recommendation__c;
                newFamilyMember.Start_of_Insurance_1__c = lea.Start_of_Insurance_KVG__c ;
                newFamilyMember.Start_of_Insurance__c = lea.Start_of_Insurance_VVG__c;
                newFamilyMember.The_customer_authorizes_the_intermediary__c = lea.The_customer_authorizes_the_intermediary__c;
                newFamilyMember.The_customer_cancels_his_insurance_contr__c = lea.The_customer_cancels_his_insurance_contr__c;
                newFamilyMember.Travel_Insurance__c = lea.Travel_Insurance__c;
                listNeedToBeInsert.add(newFamilyMember);
            }
        }
        try {
            insert listNeedToBeInsert;
            
            familyMembers = [SELECT Id, Name, Life_Insurance__c, Relationship__c, CreatedDate
                             FROM ApplicationFamilyMember__c WHERE Life_Insurance__c = :recordId ORDER BY CreatedDate DESC];
            
        } catch (Exception e) {
            System.debug('Error inserting Application Family Member record: ' + e.getMessage());
        }
        return familyMembers;
    }
    // Life Insurance Related List of Application Family Member
    @AuraEnabled( cacheable = true )
    public static List<ApplicationFamilyMember__c> getRelatedFamilyMembersForLifeInsurance(Id leadId) {
        system.debug('getRelatedFamilyMembersFotLifeInsurance '+leadId);
        List<ApplicationFamilyMember__c> familyMembers = new List<ApplicationFamilyMember__c>();
        familyMembers = [SELECT Id, Name, Life_Insurance__c, Relationship__c, CreatedDate
                         FROM ApplicationFamilyMember__c WHERE Life_Insurance__c = :leadId ORDER BY CreatedDate DESC];
        return familyMembers;
    }
    
    /****Consultant Response****/
    // Update consultant request after consultant response received
    @AuraEnabled
    public static void consultantResponse(String leadId, String response) {
        system.debug('leadId: '+leadId);
        system.debug('response: '+response);
        system.debug('USER: '+UserInfo.getUserId());
        try {
            List<Consultant_Request__c> crRecordList = new List<Consultant_Request__c>();
            String userId = UserInfo.getUserId();
            List<Consultant_Request__c> crList = [SELECT Id, NAme, Lead__c, Consultant_Response__c, OwnerId, CreatedDate 
                                                  FROM  Consultant_Request__c 
                                                  WHERE Lead__c =: leadId AND OwnerId =: userId ORDER BY CreatedDate DESC LIMIT 1];
            for(Consultant_Request__c cr : crList) {
                Consultant_Request__c c = new Consultant_Request__c();
                c.Id = cr.Id;
                c.Consultant_Response__c = response;
                crRecordList.add(c);
            }
            update crRecordList;
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    // Get Lead Record List
    @AuraEnabled
    public static List<Lead> getLeadRecords() {
        List<Lead> leadList = [SELECT Id, Name, Status, Langauge_Prefered__c FROM Lead];
        system.debug(leadList);
        
        return leadList;
        
    }
    // Get Lead Record 
    @AuraEnabled
    public static Lead getLeadRecord(Id leadId) {
        system.debug(leadId);
        Lead leadRecord = [SELECT Id, Name, Langauge_Prefered__c FROM Lead WHERE Id =: leadId];
        system.debug(leadRecord);
        
        return leadRecord;
        
    }
    // Lead related documents
    @AuraEnabled( cacheable = true )
    public static List<Insurance_Documents__c> getRelatedDocuments(Id leadId) {
        List<Insurance_Documents__c> leadRelatedDocuments = new List<Insurance_Documents__c>();
        leadRelatedDocuments = [SELECT Id, Name, Lead__c, Document_Name__c, Status__c, Document_ld__c, Document_link__c, CreatedDate
                         FROM Insurance_Documents__c WHERE Lead__c = :leadId ORDER BY CreatedDate DESC];
        return leadRelatedDocuments;
    }
    
    class FamilyMember{
        public Integer autoNumber;	
        public String name;
        public String relationship;
        public String email;
        public Date dob;
    }
}