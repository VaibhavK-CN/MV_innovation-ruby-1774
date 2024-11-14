import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import SelectedAppointmentsChannel from '@salesforce/messageChannel/SelectedAppointmentsChannel__c';
import getAvailableAppointments from '@salesforce/apex/GreenZoneController.getAvailableAppointments';

const COLUMNS = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Appointment Date & Time', fieldName: 'dateTime', type: 'date', typeAttributes: {
        year: "numeric",
        month: "short",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
    }},
    { label: 'Lead', fieldName: 'lead' },
    { type: 'button', typeAttributes: { label: 'Select', name: 'select', variant: 'brand' }}
];
const PAGE_SIZE = 5;

export default class Greenzone extends LightningElement {
    @track appointments = [];
    @track pagedAppointments = [];
    @track selectedAppointments = [];  // Array to hold selected appointments
    columns = COLUMNS;

    currentPage = 1;

    @wire(MessageContext)
    messageContext;

    @wire(getAvailableAppointments)
    wiredAppointments({ error, data }) {
        if (data) {
            this.appointments = data.map(appointment => ({
                id: appointment.Id,
                name: appointment.Name,
                dateTime: appointment.Appointment_Date_Time__c,
                lead: appointment.Lead__c
            }));
            this.updatePagedAppointments();
        } else if (error) {
            console.error('Error fetching appointments: ', error);
        }
    }

    handleRowAction(event) {
        const selectedAppointment = event.detail.row;
        const isAlreadySelected = this.selectedAppointments.some(app => app.id === selectedAppointment.id);
        
        if (!isAlreadySelected) {
            this.selectedAppointments = [...this.selectedAppointments, selectedAppointment];
            this.sendSelectedToYellowZone();  // Update Yellow Zone after each selection
        }
    }

    updatePagedAppointments() {
        const startIdx = (this.currentPage - 1) * PAGE_SIZE;
        const endIdx = startIdx + PAGE_SIZE;
        this.pagedAppointments = this.appointments.slice(startIdx, endIdx);
    }

    nextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
            this.updatePagedAppointments();
        }
    }

    previousPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
            this.updatePagedAppointments();
        }
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage >= Math.ceil(this.appointments.length / PAGE_SIZE);
    }

    // Publishes the selected appointments to the message channel
    sendSelectedToYellowZone() {
        const payload = { selectedAppointments: this.selectedAppointments };
        publish(this.messageContext, SelectedAppointmentsChannel, payload);
    }
}