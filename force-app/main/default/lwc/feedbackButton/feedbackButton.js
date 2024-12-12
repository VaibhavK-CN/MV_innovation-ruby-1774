import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, onError, unsubscribe } from 'lightning/empApi';

import createLeadInteractionDetail from '@salesforce/apex/LeadInteractionController.createLeadInteractionDetail';
import updateTaskStatusToClosed from '@salesforce/apex/LeadInteractionController.updateTaskStatusToClosed';
import isInteracted from '@salesforce/apex/LeadInteractionController.isInteracted';
import findNextAssignedLead from '@salesforce/apex/LeadAssignmentHelper.findNextAssignedLead';   
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFeedbackList from '@salesforce/apex/LeadInteractionController.getFeedbackList';
import getSubFeedbackList from '@salesforce/apex/LeadInteractionController.getSubFeedbackList';
import getUserProfile from '@salesforce/apex/LeadInteractionController.getUserProfile';


export default class LeadInteractionDetailsCreate extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showComponent = false; // Show or hide component based on task existence
    subscription = null;
    channelName = '/event/Task_Log__e'; // Platform Event API name
    @track isLoading = false; // Track the spinner state
    @track loadingMessage = 'Searching for a new Lead for You'; // Custom loading message
    initialLoadDone ; // Flag to prevent execution during initial load
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

    constructor(){
        super();
        this.initialLoadDone=true;
        console.log('constructor called');

    }
   
    connectedCallback() {
        console.log('connnected call back,,,,,,,,,,,,,,,,,,,,,!!!!!!');
        if (this.initialLoadDone) {
            this.checkIfInteracted(); // Call the method only if the flag is true
        }
         this.registerPlatformEventListener();
        
        
    }
    renderedCallback(){
        if(this.initialLoadDone){
            this.initialLoadDone = false;
        }
    console.log('renderedCallback')   ;
    }
    

    disconnectedCallback() {
        console.log('Disconnected Callback triggered');
        this.unregisterPlatformEventListener();
        this.showComponent = false;
    }

    // Check if there is a completed task
    checkIfInteracted() {
        isInteracted({ leadId: this.recordId })
             .then(result => {
                 this.showComponent = result;
                 
                 console.log('isInteracted found to be true', result);
                  
              })
              .catch(error => {
                  console.error('Error checking task interaction:', error);
              });
      }

    // // Subscribe to the platform event

    registerPlatformEventListener() {
        console.log('Subscribing to platform event:', this.channelName);
        subscribe(this.channelName, -1, message => {
            console.log('Platform event received:', message);
            

            if (message?.data?.payload?.WhoID__c === this.recordId) {
                console.log('Filtered event for recordId:', this.recordId, message.data.payload);
                // Add your logic here
              
                setTimeout(() => {
                    this.checkIfInteracted();
                }, 2000); // 2000ms = 2 seconds
            } else {
                console.log('Event does not match recordId:', this.recordId);
                setTimeout(() => {
                    this.checkIfInteracted();
                }, 2000); // 2000ms = 2 seconds
            }
        })
        .then(response => {
            this.subscription = response;
            console.log('Subscribed to platform event:', response);
        })
        .catch(error => {
            console.error('Error subscribing to platform event:', error);
        });

        // Handle subscription errors
        onError(error => {
            console.error('Platform event error:', JSON.stringify(error));
        });
    }

    unregisterPlatformEventListener() {
        if (this.subscription) {
            console.log('Unsubscribing from platform event:', this.channelName);
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from platform event:', response);
                this.subscription = null;
            }).catch(error => {
                console.error('Error unsubscribing from platform event:', error);
            });
        }
    }



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

    /*/handleSave() {
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
    }*/

    /*handleSave() {
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
        }*/

        /*createLeadInteractionDetail({
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
            this.findAndNavigateToNextLead();*/

    /*createLeadInteractionDetail({
        leadId: this.recordId,
        feedback: this.selectedFeedback,
        subFeedback: this.selectedSubFeedback,
        comment: this.comment,
        preferredDateTime: preferredDateTimeValue
    })
        .then(result => {
            this.successMessage = `Lead Interaction Detail created with ID: ${result}`;
            this.showToast('Success', 'Lead Interaction Detail created.', 'success');
            this.errorMessage = '';

            // Hide the component
            this.showComponent = false;
        })
        .catch(error => {
            this.errorMessage = `Error: ${error.body.message}`;
            this.successMessage = '';
        });
    }*/

        handleSave() {
            // Safeguard: Check if the save process is already in progress
            if (this.isLoading) {
                console.warn('Save process already in progress. Aborting duplicate save attempt.');
                return;
            }
            updateTaskStatusToClosed({leadId: this.recordId});
            // Validate required fields
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
                    console.log('preferredDateTimeValue:', preferredDateTimeValue);
                } else {
                    this.errorMessage = 'Invalid date-time format.';
                    this.successMessage = '';
                    return;
                }
            }
        
            // Indicate that the save process has started
            this.isLoading = true;
        
            createLeadInteractionDetail({
                leadId: this.recordId,
                feedback: this.selectedFeedback,
                subFeedback: this.selectedSubFeedback,
                comment: this.comment,
                preferredDateTime: preferredDateTimeValue
            })
                .then((result) => {
                    this.successMessage = `Lead Interaction Detail created with ID: ${result}`;
                    this.showToast('Success', 'Lead Interaction Detail created.', 'success');
                    this.errorMessage = '';
        
                    // Update the associated Task status to 'Closed'
                  
        
                    // Hide the component
                    this.showComponent = false;
        
                    // Refresh the Lead record
                    this.refreshLeadRecordPage();
        
                    // Navigate to the next lead
                    this.findAndNavigateToNextLead();
                })
                .catch((error) => {
                    console.error('Error creating Lead Interaction Detail:', error);
                    this.errorMessage = `Error: ${error.body ? error.body.message : error}`;
                    this.successMessage = '';
                })
                .finally(() => {
                    // Indicate that the save process has ended
                    this.unregisterPlatformEventListener();
                    this.isLoading = false;
                });
        }
        
    /*updateTaskStatusToClosed() 
{
    const taskId = this.getAssociatedTaskId(); // Logic to fetch the associated Task ID

    if (taskId) {
        updateTaskStatusToClosed({ taskId: taskId })
            .then(() => {
                console.log('Task status updated to Closed', this.taskId);
                this.showToast('Success', 'Task status updated to Closed.', 'success');
            })
            .catch(error => {
                console.error('Error updating task status:', error);

                // Log detailed error for debugging
                if (error.body) {
                    console.error('Error body message:', error.body.message);
                }

                this.showToast('Error', 'Failed to update task status. ' + (error.body ? error.body.message : ''), 'error');
            });
    } else {
        console.warn('No Task ID found to update.');
        this.showToast('Error', 'No associated Task ID found.', 'error');
    }
}*/

    // Fetch Associated Task ID
    /*getAssociatedTaskId() 
    {
        // Replace this placeholder with actual logic to fetch the Task ID
        return 'someTaskId'; // Example placeholder ID
    }*/

    // Show Toast Message
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }



    // Refresh the record page
    refreshLeadRecordPage() {
        // console.log('Refresh Method called!');
       // getRecordNotifyChange([{ recordId: this.recordId }]);
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
        //this.errorMessage = '';
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