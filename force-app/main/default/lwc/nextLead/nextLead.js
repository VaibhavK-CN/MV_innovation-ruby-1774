import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import FEEDBACK_FIELD from '@salesforce/schema/Lead.Feedback__c';
import SUB_FEEDBACK_FIELD from '@salesforce/schema/Lead.Latest_Sub_Feedback__c';
import findNextAssignedLead from '@salesforce/apex/LeadAssignmentHelper.findNextAssignedLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LeadRefreshComponent extends NavigationMixin(LightningElement) {
    @api recordId; // Current Lead record ID
    @track isLoading = false; // Track the spinner state
    @track loadingMessage = 'Searching for a new Lead for You'; // Custom loading message
    initialLoadDone = false; // Flag to prevent execution during initial load

    // Fields to monitor for changes
    fieldsToMonitor = [FEEDBACK_FIELD, SUB_FEEDBACK_FIELD];
    previousFeedback = null;
    previousSubFeedback = null;

    // Wire the record data and monitor changes
    @wire(getRecord, { recordId: '$recordId', fields: [FEEDBACK_FIELD, SUB_FEEDBACK_FIELD] })
    wiredLead({ error, data }) {
        if (data) {
            const feedback = data.fields.Feedback__c.value;
            const subFeedback = data.fields.Latest_Sub_Feedback__c.value;

            // Skip processing during initial load
            if (!this.initialLoadDone) {
                this.previousFeedback = feedback;
                this.previousSubFeedback = subFeedback;
                this.initialLoadDone = true;
                return;
            }

            // Trigger updates only if fields have changed
            if (this.hasFieldChanged(feedback, subFeedback)) {
                this.handleLeadUpdate(feedback, subFeedback);
            }

            // Update previous field values
            this.previousFeedback = feedback;
            this.previousSubFeedback = subFeedback;
        } else if (error) {
            console.error('Error fetching Lead record:', error);
        }
    }

    // Check if fields have changed
    hasFieldChanged(feedback, subFeedback) {
        return (this.previousFeedback !== feedback || this.previousSubFeedback !== subFeedback);
    }

    // Handle lead updates synchronously
    handleLeadUpdate(feedback, subFeedback) {
        this.isLoading = true; // Show the spinner
        this.showToast('Processing', 'Updating lead record...', 'info');

        // Refresh the record page
        this.refreshLeadRecordPage();

        // Find and navigate to the next assigned lead
        this.findAndNavigateToNextLead();
    }

    // Refresh the record page
    refreshLeadRecordPage() {
        getRecordNotifyChange([{ recordId: this.recordId }]);
        this.showToast('Success', 'Lead record updated.', 'success');
    }

    // Apex call to find the next assigned lead
    async findAndNavigateToNextLead() {
        try {
            const nextLeadId = await findNextAssignedLead({ currentLeadId: this.recordId });
            if (nextLeadId) {
                this.navigateToNextLead(nextLeadId);
                this.showToast('Success', 'Navigating to the next assigned lead.', 'success');
            } else {
                this.showToast('Info', 'No next lead found.', 'info');
            }
        } catch (error) {
            console.error('Error finding next assigned lead:', error);
            this.showToast('Error', 'Failed to find next lead.', 'error');
        } finally {
            this.isLoading = false; // Hide the spinner
        }
    }

    // Navigate to the next lead detail page
    navigateToNextLead(nextLeadId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: nextLeadId,
                objectApiName: 'Lead',
                actionName: 'view'
            }
        });
    }

    // Show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}