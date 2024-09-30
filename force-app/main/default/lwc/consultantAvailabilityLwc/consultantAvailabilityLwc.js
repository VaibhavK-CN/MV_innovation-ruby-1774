import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getLeadRecord from '@salesforce/apex/LeadController.getLeadRecord';
import consulataionRequest from '@salesforce/apex/CustomNotificationSender.consulataionRequest';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';



export default class ConsultantAvailabilityLwc extends LightningElement {
    @api recordId;
    languageOptions;
    @track selectedLanguage;
    consultantUser;
     selectedConsultantUsers = [];

    channelName = '/event/Consultant_Response__e';
    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;
    subscription = {};
    connectionState = 'Closed';
    
    acceptedUser = [];
    acceptedUserList ;

    @track showNotification = false;
    @track notificationMessage;
    fields = ['Consultation_Response__c','LastModifiedById','SystemModstamp',]; // Specify the fields you want to monitor
// for  platform event subscription
    // Initializes the component

    subscribePlatformEvent() {
        console.log('event Subscription::::')
        this.handleSubscribe();
        // Set up a periodic ping to keep the connection alive
        this.setupPing();
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


    // Tracks changes to channelName text field
    handleChannelName(event) {
        this.channelName = event.target.value;
    }


    // Handles subscribe button click
    handleSubscribe() {
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, this.messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request for response sent to::::::::::::: ', JSON.stringify(response.channel));
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
        const userDetailId = response.data.payload.User_Detail__c;

       if (userDetailId) {
        try {
            console.log('userDetailId::::'+userDetailId);
            this.handleClickHere(userDetailId);
         } catch (error) {
            console.error('Error parsing User_List__c JSON:', error);
        }
    }

    }

    connectedCallback() {
        this.subscribePlatformEvent();
        // Get Lead Record
        getLeadRecord({ leadId: this.recordId })
            .then(result => {
                if (result) {
                    this.selectedLanguage = result.Langauge_Prefered__c;
                }
            })
            .catch(error => {
                console.log('Error is : ' + error);
                this.error = error;
            });
    }
    
    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (data) {
            // Handle the updated record data
            console.log('Updated Record Data:', data);
            console.log('field Data:::',data.fields);
            // You can access specific fields using data.fields.Field1__c.value, data.fields.Field2__c.value, etc.
        } else if (error) {
            // Handle error
            console.error('Error loading record', error);
        }
    }
    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfo;

    // Language picklist
    @wire(getPicklistValuesByRecordType, { objectApiName: LEAD_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    picklistHandler({ data, error }) {
        if (data) {
            this.languageOptions = this.picklistGenerator(data.picklistFieldValues.Langauge_Prefered__c);
        }
        if (error) {
            console.error(error);
        }
    }

    picklistGenerator(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }));
    }

    // handle Language picklist value change
    handleValueChange(event) {
        this.selectedLanguage = event.target.value;
    }

    // handle Check Availability Click 
    handleCheckAvailabilityClick() {
        this.showNotificationComponent();

// subscribe platform event on button click 
     //   this.subscribePlatformEvent();



        //publishEvent();
        // Get Lead Record
        consulataionRequest({ language: this.selectedLanguage, leadId: this.recordId })
            .then(result => {
                if (result) {
                    console.log(JSON.stringify(result));
                    this.consultantUser = result;
                    this.showMessage('Consultation request sent successfully.', 'success');
                }
            })
            .catch(error => {
                console.log('Error is : ' + JSON.stringify(error));
                this.error = error;
            });
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: 'Consultation Request',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event); 
    }

    showNotificationComponent() {
        this.showNotification = true;
    }
    
handleClickHere(user) {
    console.log('user:::', user);

    // Check if the user is in the consultantUser array
    const isUserInConsultantList = this.consultantUser && this.consultantUser.some(consultant => consultant.Id === user);

    if (isUserInConsultantList) {
        console.log('User is in the consultantUser list');
        // Your logic for when the user is in the consultantUser list
        this.selectedConsultantUsers = [...this.selectedConsultantUsers, ...this.consultantUser.filter(consultant => consultant.Id === user)];

    } else {
        console.log('User is NOT in the consultantUser list');
        // Your logic for when the user is NOT in the consultantUser list
    }
}




}