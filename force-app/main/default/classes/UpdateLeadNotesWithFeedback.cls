public class UpdateLeadNotesWithFeedback {
    public static void updateNotes(List<Lead> leadList){
        System.debug('leadList update notes '+leadList);
        for(Lead le:leadList){
            if(le.Feedback__c !=null){
                le.Notes__c = le.Feedback__c;
                system.debug(le);
            }
            if(le.Feedback__c!=null && le.Feedback__c=='Distributed'){
                le.Status = 'Distributed';
            }
        }
		
    }
}