@isTest
public class LeadNotesUpdateTest {
    @isTest
    public static void updateAssineeOfEvent(){
        List<Event> evList = New List<Event>();
        User testUser = new User(
            FirstName = 'Besard',
            LastName = 'Berisha',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuserEv@example.com',
            CommunityNickname = 'tuser123',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Call Agent' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;
        Lead le = New Lead();
        le.LastName = 'Test ln';
        le.MobilePhone = '6787656789';
        le.Date_of_Birth__c = system.today();
        
        insert le;
        
        Event ev = New Event();
        ev.OwnerId = testUser.id;
        ev.DurationInMinutes = 0;
        ev.WhoId = le.id;
        ev.ActivityDateTime = system.today();
        ev.Subject = 'Test Event';
        ev.StartDateTime = system.today();
        ev.EndDateTime = system.today();
        evList.add(ev);
        insert evList;
        LeadNotesUpdate.assigneeUpdate(evList);
        ChaneLeadOwnerUpdateAsinee.updateLeadOwner(evList);
    }

}