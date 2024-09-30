public class SendemailNeedAnalysisPdf {
    @invocablemethod(label='Send Email Need_Analysis' description='send email')
    public static void Sendemail(list<Id> localId){
        //Documentation__c inv = [Select Id, name,Supplier_Mail__c From Documentation__c Where Id=:localId[0]];
        Lead inv = [Select Id, name,Email From Lead Where Id=:localId[0]];
        system.debug('let me check'+inv);
        PageReference pdf = Page.GeneratePdfVFPage;// Replace PdfOfInvoice with your Page which render as PDF.
        pdf.getParameters().put('id', localId[0]);
        // Blob b = pdf.getContentAsPDF();
        Blob b;
        if (Test.IsRunningTest()){b=Blob.valueOf('UNIT.TEST');}else{b = pdf.getContentAsPDF();}
        // Create Attachment Object to attach with Email
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(inv.Name+'.pdf');
        efa.setBody(b);
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // Sets the paramaters of the email
        email.setSubject('PDF of Invoice - '+inv.Name);
        email.setToAddresses( new List<String>{inv.Email} );
        //email.setbccAddresses( new list<string>{'admin@gmail.com'} );
        email.sethtmlBody('Hi '+inv.Name+',<br/><br/> '
                          +'Please find the attached Invoice.'
                          +'<br/><br/>'+'Thanks,'+'<br/>'
                          +UserInfo.getName()+'<br/>'
                          +UserInfo.getOrganizationName());
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }catch(System.Exception e){
            
        }
    }
}