import { LightningElement, api, track } from 'lwc';

export default class yellow_Zone extends LightningElement {
    @api selectedAppointments;  // This will be populated by the parent Green Zone
}