import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getNextLead from '@salesforce/apex/LeadControllerNextLead.getNextLead';

let count = 0;

export default class NextLeadButton extends NavigationMixin(LightningElement) {
    @track lead;    // Store the fetched lead details
    @track error;   // Store any error messages

    // Method to handle button click
    handleNextLead() {
        getNextLead()
            .then(result => {
                console.log('result:', result);
                let data = null;

                if (result != null && count < result.length) {
                    data = result[count];
                    count++;
                }

                if (data) {
                    this.lead = data; // Update lead with the fetched result
                    this.error = undefined; // Clear any previous error
                    this.navigateToLeadRecord(this.lead.Id); // Navigate to the lead record
                } else {
                    this.error = 'No more leads available.'; // Set error if no more leads
                    this.lead = undefined; // Clear the lead data
                }
            })
            .catch(error => {
                this.error = error.body.message; // Capture the error message
                this.lead = undefined; // Clear the lead data
            });
    }

    // Method to navigate to the lead record
    navigateToLeadRecord(leadId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: leadId,
                objectApiName: 'Lead',
                actionName: 'view'
            }
        });
    }
}