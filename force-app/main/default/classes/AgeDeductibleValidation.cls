public class AgeDeductibleValidation {
    public static void  addErrorOverAge(List<Lead> leadList){
        for (Lead le : leadList) {
            Integer age = (Date.today().year() - le.Date_of_Birth__c.year());
            system.debug('age '+age);
            if (age > 18 && le.AgePopulate__c == false ) {
                le.addError('Please check the Age Populate checkbox as true to save the record and fill deductible as age is gretter than 18');
            }
            if (age <= 18 && le.AgePopulate__c == True ) {
                le.addError('Please do not check the Age Populate checkbox as true to save the record and fill deductible as age is less than 18');
            }
        }
    }
  /*  public static void updateAge(List<Lead>leadList){
        for (Lead le : leadList) {
            Integer age = (Date.today().year() - le.Date_of_Birth__c.year());
            system.debug('age '+age);
            if (age > 18) {
                le.AgePopulate__c = True;
            }
            if (age < 18 && le.AgePopulate__c == True ) {
               le.AgePopulate__c = False;
            }
        }
    } */   
}