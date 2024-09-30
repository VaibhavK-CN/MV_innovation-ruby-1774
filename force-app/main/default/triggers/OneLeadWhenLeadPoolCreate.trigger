trigger OneLeadWhenLeadPoolCreate on Lead_Pool__c (After insert) {
	
    OneLeadWhenLeadPoolCreated.whenLeadPoolCreated(Trigger.New);
    OneLeadWhenLeadPoolCreated.whenLeadPoolCreatedForLifeIns(Trigger.new);
}