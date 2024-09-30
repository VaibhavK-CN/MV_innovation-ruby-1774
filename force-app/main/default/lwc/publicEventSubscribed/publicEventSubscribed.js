import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isLoginUserCorrectUser from '@salesforce/apex/PublicEventSubscribedController.isLoginUserCorrectUser';
import publishEventForResponse from '@salesforce/apex/PlatformEventCtrl.publishEventForResponse';
import consultantResponse from '@salesforce/apex/LeadController.consultantResponse';



export default class publicEventSubscribed extends LightningElement {
    channelName = '/event/Consultation_Request__e';
    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;
    subscription = {};
    connectionState = 'Closed';
    leadRecordId
    isShowModal = true
    
    

    // Initializes the component
    connectedCallback() {
        this.handleSubscribe();
        // Set up a periodic ping to keep the connection alive
        this.setupPing();
        setTimeout(() => {
            this.isShowModal = false;
            this.sendDataToAura('false');
            this.handleNoResponse();
        }, 60000);
    }

    // Tracks changes to channelName text field
    handleChannelName(event) {
        this.channelName = event.target.value;
    }


    // Handles subscribe button click
    handleSubscribe() {
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, this.messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
            this.toggleSubscribeButton(true);
        }).catch(error => {
            console.error('Error subscribing to channel:', JSON.stringify(error));
            this.handleSubscribeError();
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {
        this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    // Handles errors during subscription
    handleSubscribeError() {
        // Handle the error and retry subscription after a delay
        setTimeout(() => {
            this.handleSubscribe();
        }, 5000); // Retry after 5 seconds (adjust as needed)
    }

    // Register error listener
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
            this.handleSubscribeError();
        });
    }

    // Toggle subscription button states
    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }

    // Message callback function
    messageCallback = (response) => {
        console.log('New message received : ', JSON.stringify(response));
        const userListJson = response.data.payload.User_List__c;

       if (userListJson) {
        try {
            // Parse the JSON object from the User_List__c field
            const userListObject = JSON.parse(userListJson);
            // Extract record Ids from the keys of the userListObject
            const recordIds = Object.keys(userListObject);
            this.leadRecordId =  Object.values(userListObject);
            console.log(this.leadRecordId[0]);
            
            console.log('leadRecordId::::'+this.leadRecordId);
            console.log('UserIds::::'+recordIds);
            


            // Call the Apex method with the list of record Ids
            this.callApexMethod(recordIds);
        } catch (error) {
            console.error('Error parsing User_List__c JSON:', error);
        }
    }

    }

 // Function to send data to Aura component
sendDataToAura(dataToSend) {
    // Create a custom event with the data
    const event = new CustomEvent('senddatatoaura', {
        detail: { "val": dataToSend }
    });

    // Dispatch the event to the parent Aura component
    this.dispatchEvent(event);
    
    // Log a message to verify the event is dispatched
    console.log('Event dispatched from LWC');
}
    
// call apex for user
callApexMethod(userIdList) {
    // Call the Apex method imperatively
    isLoginUserCorrectUser({ UserIdList: userIdList })
        .then(result => {
            if (result) {
                // Set the data for aura
                this.sendDataToAura('true');
                showToastMessage();
                
            }
        })
        .catch(error => {
            console.error('Error calling Apex method:', error);
            // Handle the error
        });
}


showToastMessage(){
        const toastEvent = new ShowToastEvent({
        title: 'Success!',
        message: 'Your Response Sent to System Successfully!!',
        variant: 'success'
    });
    this.dispatchEvent(toastEvent);
}

    // Set up periodic ping to keep connection alive
    setupPing() {
        setInterval(() => {
            if (this.connectionState === 'Connected') {
                // Use any event name that you are not actively using in your application
                subscribe('/event/PingEvent__e', -1, () => {});
            }
        }, 60000); // Ping every 60 seconds (adjust as needed)
    }

handleReject() {
    console.log('Rejected');
    this.callPublishEventForResponse(this.leadRecordId[0],'Rejected');
}

handleAccept() {
    this.callPublishEventForResponse(this.leadRecordId[0],'Accepted');
}
handleNoResponse() {
    this.callPublishEventForResponse(this.leadRecordId[0],'No Response');
}
callPublishEventForResponse(leadId,responseFromConsultant) {
    // Call the Apex method imperatively
    publishEventForResponse({leadId: leadId, response:responseFromConsultant})
    .then(result => {
            if (result) {
                const userId = result;
                console.log('Platform event response send for user::::',userId+'     response:::'+responseFromConsultant);
            
                this.sendDataToAura('false');
                

        }
        })
        .catch(error => {
            console.error('Error calling Apex method:', error);
            // Handle the error
        });
    }
}