import { LightningElement, api, track, wire } from 'lwc';
import createLeadInteractionDetail from '@salesforce/apex/LeadInteractionController.createLeadInteractionDetail';
import getFeedbackList from '@salesforce/apex/LeadInteractionController.getFeedbackList';
import getSubFeedbackList from '@salesforce/apex/LeadInteractionController.getSubFeedbackList';
import getUserProfile from '@salesforce/apex/LeadInteractionController.getUserProfile';

export default class LeadInteractionDetailsCreate extends LightningElement {
    @api recordId;
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

    // Track the state of the checkboxes
    @track appointmentSetterUser = false;
    @track consultantUser = false;

    // Track visibility of checkboxes based on user profile
    @track isAppointmentSetterUser = false;
    @track isConsultantUser = false;

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
        if (this.selectedFeedback === 'Appointment Planned' || this.selectedFeedback === 'Callback Required') {
            this.isDateTimePopupVisible = true;
        } else {
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

        if (this.isAppointmentSetterUser && !this.appointmentSetterUser) {
            this.errorMessage = 'Appointment Setter User must be selected.';
            this.successMessage = '';
            return;
        }

        if (this.isConsultantUser && !this.consultantUser) {
            this.errorMessage = 'Consultant User must be selected.';
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
                this.successMessage = `Lead Interaction Detail created with ID: ${result}`;
                this.errorMessage = '';
            })
            .catch(error => {
                this.errorMessage = `Error: ${error.body.message}`;
                this.successMessage = '';
            });
    }

    handleCancel() {
        this.selectedFeedback = '';
        this.selectedSubFeedback = '';
        this.comment = '';
        this.preferredDateTime = '';
        this.isFeedbackListVisible = false;
        this.isSubFeedbackListVisible = false;
        this.isDateTimePopupVisible = false;
        this.appointmentSetterUser = false;
        this.consultantUser = false;
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