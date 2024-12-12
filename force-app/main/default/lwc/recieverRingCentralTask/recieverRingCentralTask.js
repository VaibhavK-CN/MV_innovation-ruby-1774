import { LightningElement, api } from 'lwc';
import { subscribe, onError, unsubscribe } from 'lightning/empApi';

export default class ReceiverRingCentralTask extends LightningElement {
    @api recordId; // Record ID to filter events
    subscription = null;
    channelName = '/event/Task_Log__e'; // Platform Event API name

    connectedCallback() {
        console.log('Connected Callback triggered');
        this.registerPlatformEventListener();
    }

    disconnectedCallback() {
        console.log('Disconnected Callback triggered');
        this.unregisterPlatformEventListener();
    }

    registerPlatformEventListener() {
        console.log('Subscribing to platform event:', this.channelName);
        subscribe(this.channelName, -1, message => {
            console.log('Platform event received:', message);

            if (message?.data?.payload?.WhoID__c === this.recordId) {
                console.log('Filtered event for recordId:', this.recordId, message.data.payload);
                // Add your logic here
            } else {
                console.log('Event does not match recordId:', this.recordId);
            }
        })
        .then(response => {
            this.subscription = response;
            console.log('Subscribed to platform event:', response);
        })
        .catch(error => {
            console.error('Error subscribing to platform event:', error);
        });

        // Handle subscription errors
        onError(error => {
            console.error('Platform event error:', error);
        });
    }

    unregisterPlatformEventListener() {
        if (this.subscription) {
            console.log('Unsubscribing from platform event:', this.channelName);
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from platform event:', response);
                this.subscription = null;
            }).catch(error => {
                console.error('Error unsubscribing from platform event:', error);
            });
        }
    }
}
