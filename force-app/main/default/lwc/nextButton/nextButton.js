import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCurrentUserLeadList from '@salesforce/apex/LeadControllerNextLead.getCurrentUserLeadList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NextLead extends NavigationMixin(LightningElement) {
    @api recordId;
    @track leadList = [];
    @track isLoading = true; // For loading state
    nextLeadId;

    // Define priority mapping
    statusPriority = {
        'Super Hot': 1,
        'Warm': 2,
        'Cold': 3
    };

    connectedCallback() {
        this.fetchLeadList();
    }

    fetchLeadList() {
        getCurrentUserLeadList({ recordId: this.recordId })
            .then(result => {
                this.leadList = result || []; // Handle empty result
                this.isLoading = false; // Stop loading
                console.log('leadList::', JSON.stringify(this.leadList.length));
                console.log('leadList::', JSON.stringify(this.leadList));
            })
            .catch(error => {
                this.isLoading = false; // Stop loading on error
                this.showMessage('Error fetching lead list', 'error');
                console.error(error);
            });
    }

    handleNextLeadClick() {
        let foundCurrentLead = false;
        let nextLeadCandidates = [];

        // Iterate through the lead list to find the current lead and potential next leads
        for (const lead of this.leadList) {
            if (foundCurrentLead && lead.Status in this.statusPriority) {
                nextLeadCandidates.push(lead);
            }

            if (lead.Id === this.recordId) {
                foundCurrentLead = true;
            }
        }

        // Sort the candidates based on priority
        nextLeadCandidates.sort((a, b) => {
            const priorityA = this.statusPriority[a.Status] || Infinity;
            const priorityB = this.statusPriority[b.Status] || Infinity;
            return priorityA - priorityB;
        });

        // Get the highest priority lead if available
        if (nextLeadCandidates.length > 0) {
            this.nextLeadId = nextLeadCandidates[0].Id;
            this.showMessage('Next lead opened successfully!', 'success');
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.nextLeadId,
                    objectApiName: 'Lead',
                    actionName: 'view'
                }
            });
        } else {
            this.showMessage('No next lead found with the defined status priorities.', 'error');
        }
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: 'Notification',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }
}