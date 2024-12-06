import { LightningElement, api, track, wire } from 'lwc';
import createLeadInteractionDetail from '@salesforce/apex/LeadInteractionController.createLeadInteractionDetail';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi'; 
import findNextAssignedLead from '@salesforce/apex/LeadAssignmentHelper.findNextAssignedLead';   
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFeedbackList from '@salesforce/apex/LeadInteractionController.getFeedbackList';
import getSubFeedbackList from '@salesforce/apex/LeadInteractionController.getSubFeedbackList';
import getUserProfile from '@salesforce/apex/LeadInteractionController.getUserProfile';

export default class LeadInteractionDetailsCreate extends NavigationMixin(LightningElement) {
    @api recordId;

    @track isLoading = false; // Track the spinner state
    @track loadingMessage = 'Searching for a new Lead for You'; // Custom loading message
    initialLoadDone = false; // Flag to prevent execution during initial load

    successMessage = '';
    errorMessage = '';
    comment = '';
    @track preferredDateTime = '';
    @track selectedFeedback = '';
    @track selectedSubFeedback = '';
    @track feedbackList = [];
    @track subFeedbackList = [];
    @track isFeedbackListVisible = false;
    @track isSubFeedbackListVisible = false;
    @track isDateTimePopupVisible = false;

    // Wire the feedback list from Apex
    @wire(getFeedbackList, { leadId: '$recordId' })
    wiredFeedbackList({ error, data }) {
        if (data) {
            this.feedbackList = data;
        } else if (error) {
            this.errorMessage = `Error fetching feedback: ${error.body.message}`;
        }
    }

    // Wire the current user's profile
    @wire(getUserProfile)
    wiredUserProfile({ error, data }) {
        if (data) {
            this.isAppointmentSetterUser = data === 'Appointment Setter';
            this.isConsultantUser = data === 'Consultant Health Insurance';
        } else if (error) {
            this.errorMessage = `Error fetching user profile: ${error.body.message}`;
        }
    }

    handleCommentChange(event) {
        this.comment = event.target.value;
    }

    handleShowFeedbackList() {
        this.isFeedbackListVisible = !this.isFeedbackListVisible;
        if (this.isFeedbackListVisible) {
            this.fetchFeedbackList();
        }
        this.isSubFeedbackListVisible = false;
    }

    handleFeedbackClick(event) {
        this.selectedFeedback = event.target.textContent;
        const feedbackButtons = this.template.querySelectorAll('.feedback-list-button');
        feedbackButtons.forEach(button => {
            button.classList.remove('selected');
        });
        event.target.classList.add('selected');
        this.isSubFeedbackListVisible = false;
        if (this.selectedFeedback === 'Appointment Planned') {
            this.isDateTimePopupVisible = true;
        }else {
            this.isDateTimePopupVisible = false;
        }
        getSubFeedbackList({ leadId: this.recordId, feedbackType: this.selectedFeedback })
            .then((result) => {
                this.subFeedbackList = result;
                this.isSubFeedbackListVisible = this.subFeedbackList.length > 0;
            })
            .catch((error) => {
                this.errorMessage = `Error fetching sub-feedback: ${error.body.message}`;
                this.isSubFeedbackListVisible = false;
            });
    }

    handleDateTimeChange(event) {
        this.preferredDateTime = event.target.value;
    }

    handleSubFeedbackClick(event) {
        this.selectedSubFeedback = event.target.textContent;
        const subFeedbackButtons = this.template.querySelectorAll('.sub-feedback-list-button');
        subFeedbackButtons.forEach(button => {
            button.classList.remove('selected');
        });
        event.target.classList.add('selected');
        if (this.selectedSubFeedback === 'Callback Requested - No Time Specified' || 
        this.selectedSubFeedback === 'Callback Requested - Time Specified' ||
        this.selectedSubFeedback === 'Future Appointment Planned' ||
        this.selectedSubFeedback === 'Immediate Appointment Requested') {
        this.isDateTimePopupVisible = true; // Show the preferred date-time field
        } else {
        this.isDateTimePopupVisible = false; // Hide the preferred date-time field
        }
    }

    handleAppointmentSetterChange(event) {
        this.appointmentSetterUser = event.target.checked;
    }

    handleConsultantUserChange(event) {
        this.consultantUser = event.target.checked;
    }

    handleSave() {
        if (!this.comment) {
            this.errorMessage = 'Comment is required.';
            this.successMessage = '';
            return;
        }

        if (this.isDateTimePopupVisible && !this.preferredDateTime) {
            this.errorMessage = 'Preferred Date and Time is required.';
            this.successMessage = '';
            return;
        }

        let preferredDateTimeValue = null;
        if (this.preferredDateTime) {
            const date = new Date(this.preferredDateTime);
            if (!isNaN(date.getTime())) {
                preferredDateTimeValue = date.toISOString();
            } else {
                this.errorMessage = 'Invalid date-time format.';
                this.successMessage = '';
                return;
            }
        }

        createLeadInteractionDetail({
            leadId: this.recordId,
            feedback: this.selectedFeedback,
            subFeedback: this.selectedSubFeedback,
            comment: this.comment,
            preferredDateTime: preferredDateTimeValue
        })
            .then(result => {
                console.log('Save->');
                this.successMessage = `Lead Interaction Detail created with ID: ${result}`;
                this.showToast('Success', 'Lead Interaction Detail created.', 'success');
                this.errorMessage = '';
                console.log('leadID --> '+this.recordId);
            })
            .catch(error => {
                this.errorMessage = `Error: ${error.body.message}`;
                this.successMessage = '';
                
            });
            this.refreshLeadRecordPage();
            this.findAndNavigateToNextLead();
    }

    // Refresh the record page
    refreshLeadRecordPage() {
        // console.log('Refresh Method called!');
        getRecordNotifyChange([{ recordId: this.recordId }]);
        this.showToast('Success', 'Lead record updated.', 'success');
    }

    // Apex call to find the next assigned lead
    async findAndNavigateToNextLead() {
        console.log('findAndNavigateToNextLead started.');
        this.isLoading = true; // Show the spinner at the start
    
        try {
            // Fetch nextLeadId using await
            const nextLeadId = await findNextAssignedLead({ currentLeadId: this.recordId });
            console.log('Fetched nextLeadId:', nextLeadId);
    
            if (nextLeadId) {
                console.log('Valid nextLeadId received. Preparing to navigate...');
    
                // Add a delay before navigating to ensure data is fully ready
                setTimeout(() => {
                    console.log('Navigating to Lead ID:', nextLeadId);
                    this.navigateToNextLead(nextLeadId);
                    this.showToast('Success', 'Navigated to the next lead.', 'success');
                }, 2000); // Delay of 2 seconds
            } else {
                console.log('No valid nextLeadId received.');
                this.showToast('Error', 'No next lead found.', 'error');
            }
        } catch (error) {
            console.error('Error finding next assigned lead:', error.message);
            this.showToast('Error', 'Failed to find next lead.', 'error');
        } finally {
            this.isLoading = false; // Hide the spinner after processing
            console.log('findAndNavigateToNextLead completed.');
        }
    }
    
    navigateToNextLead(nextLeadId) {
        console.log('Navigating to Lead with ID:', nextLeadId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: nextLeadId,
                objectApiName: 'Lead',
                actionName: 'view',
            },
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

    handleCancel() {
        this.selectedFeedback = '';
        this.selectedSubFeedback = '';
        this.comment = '';
        this.preferredDateTime = '';
        this.isFeedbackListVisible = false;
        this.isSubFeedbackListVisible = false;
        this.isDateTimePopupVisible = false;
        this.errorMessage = '';
        this.successMessage = '';
    }

    fetchFeedbackList() {
        getFeedbackList({ leadId: this.recordId })
            .then((result) => {
                this.feedbackList = result;
            })
            .catch((error) => {
                this.errorMessage = `Error fetching feedback: ${error.body.message}`;
            });
    }
}