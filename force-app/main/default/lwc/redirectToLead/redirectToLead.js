import { LightningElement, track, wire } from 'lwc';
import getHighestPriorityLead from '@salesforce/apex/PriorityLeadController.getHighestPriorityLead';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RedirectToLead extends NavigationMixin(LightningElement) {
    @track isLoading = true;

    @wire(getHighestPriorityLead)
    wiredLead({ error, data }) {
        this.isLoading = false;

        if (data) {
            this.navigateToRecord(data.Id);
        } else if (error) {
            this.showErrorToast(error.body.message);
        }
    }

    navigateToRecord(leadId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: leadId,
                objectApiName: 'Lead',
                actionName: 'view'
            }
        });
    }

    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
}