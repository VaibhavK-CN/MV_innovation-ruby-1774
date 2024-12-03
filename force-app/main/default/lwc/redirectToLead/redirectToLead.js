import { LightningElement, track, wire } from 'lwc';
import getHighestPriorityLead from '@salesforce/apex/PriorityLeadController.getHighestPriorityLead';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RedirectToLead extends NavigationMixin(LightningElement) {
    @track isLoading = true;

    // Wire the Apex method to get the highest priority lead (best aggregate score lead)
    @wire(getHighestPriorityLead)
    wiredLead({ error, data }) {
        this.isLoading = false;

        if (data) {
            // Navigate to the lead record page if the lead is found
            this.navigateToRecord(data.Id);
        } else if (error) {
            // Show an error toast if there's an issue
            this.showErrorToast(error.body.message);
        }
    }

    // Navigate to the Lead record page using the NavigationMixin
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

    // Show an error message in a toast notification
    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
}