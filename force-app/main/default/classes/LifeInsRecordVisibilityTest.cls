@isTest
public class LifeInsRecordVisibilityTest {

    @isTest
    static void testUpdateLeadOwnerAsCallAgent() {
        LifeInsurance__c lifeIns1 = new LifeInsurance__c(Name = 'Test Life Ins 1', Notes__c = 'Sample Note');
        insert lifeIns1;

        Lead_Pool__c leadPool = new Lead_Pool__c(Name = 'Test Lead Pool', Life_Insurance__c = lifeIns1.Id, UserId__c = UserInfo.getUserId());
        insert leadPool;
        LifeInsRecordVisibility.UpdateLeadOwnerAsCallAgent(new List<LifeInsurance__c>{ lifeIns1 });
        LifeInsurance__c updatedLifeIns = [SELECT Id, OwnerId, Lead_Status__c FROM LifeInsurance__c WHERE Id = :lifeIns1.Id LIMIT 1];

      
    }

    @isTest
    static void testUpdateLeadOwnerAsCallAgentWithNoNotes() {
        LifeInsurance__c lifeIns2 = new LifeInsurance__c(Name = 'Test Life Ins 2');
        insert lifeIns2;

        Lead_Pool__c leadPool = new Lead_Pool__c(Name = 'Test Lead Pool', Life_Insurance__c = lifeIns2.Id, UserId__c = UserInfo.getUserId());
        insert leadPool;
        LifeInsRecordVisibility.UpdateLeadOwnerAsCallAgent(new List<LifeInsurance__c>{ lifeIns2 });
        LifeInsurance__c updatedLifeIns = [SELECT Id, OwnerId, Lead_Status__c FROM LifeInsurance__c WHERE Id = :lifeIns2.Id LIMIT 1];
    }
}