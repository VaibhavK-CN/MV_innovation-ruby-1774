import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NotificationComponent extends LightningElement {
    // handleAccept() {
    //     this.dispatchEvent(new CustomEvent('userresponse', { detail: 'Yes' }));
    //     this.showMessage('Consultation Request Accepted.','success');
    // }
    // handleReject() {
    //     this.dispatchEvent(new CustomEvent('userresponse', { detail: 'No' }));
    //     this.showMessage('Consultation Request Rejected.','error');

    // }
    // showMessage(message,variant)
    // {
    //     const event = new ShowToastEvent({
    //         title: 'Consultation Request',
    //         variant: variant,
    //         mode: 'dismissable',
    //         message: message
    //     });
    //     this.dispatchEvent(event);
    // }
}