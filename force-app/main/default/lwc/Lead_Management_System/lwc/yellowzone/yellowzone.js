import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import SelectedAppointmentsChannel from '@salesforce/messageChannel/SelectedAppointmentsChannel__c';

const COLUMNS = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Appointment Date & Time', fieldName: 'dateTime', type: 'date', typeAttributes: {
        year: "numeric",
        month: "short",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
    }},
    { label: 'Lead', fieldName: 'lead' }
];

export default class Yellowzone extends LightningElement {
    @track selectedAppointments = [];  // Tracks selected appointments sent from Green Zone
    columns = COLUMNS;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    // Subscribe to the message channel when the component is initialized
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                SelectedAppointmentsChannel,
                (message) => {
                    this.handleMessage(message);
                }
            );
        }
    }

    // Handles incoming messages and updates selectedAppointments
    handleMessage(message) {
        this.selectedAppointments = message.selectedAppointments || [];
    }
}