import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getOptionsMetadata from '@salesforce/apex/OptionsMetadataController.getOptionsMetadata';
import sendDocumentForDigitalSign from '@salesforce/apex/SignWellApi.sendDocumentForDigitalSign';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

// Define the fields you want to monitor (like Preferred_Language__c)
import PREFERRED_LANGUAGE_FIELD from '@salesforce/schema/Lead.Langauge_Prefered__c';

export default class SendDocumentForDigitalSign extends LightningElement {
    @api recordId;  // Lead record ID

    options = [];  // Holds document options
    selectedOption;  // Holds the selected template ID
    isModalShow = true;  // Controls modal visibility
    isShowSpinner = false;  // Controls the loading spinner
    wiredOptionsResult;  // To store wired options for refresh

    // Monitor the Lead's Preferred_Language__c field
    @wire(getRecord, { recordId: '$recordId', fields: [PREFERRED_LANGUAGE_FIELD] })
    leadRecord;

    // Fetch options metadata based on Lead's preferred language and store wired result for refresh
    @wire(getOptionsMetadata, { leadId: '$recordId' })
    wiredOptions(result) {
        this.wiredOptionsResult = result;  // Save the result for refreshing

        if (result.data) {
            // Map the returned data to options array
            this.options = result.data.map(option => ({
                label: option.label,
                value: option.value,
                language: option.language
            }));
        } else if (result.error) {
            console.error('Error retrieving options:', result.error);
        }
    }

    // Close the modal when user cancels or completes the action
    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    // Close the action screen (if the component is used in a Quick Action)
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Handle option change when the user selects a document
    handleOptionChange(event) {
        this.selectedOption = event.target.value;
        console.log('Selected Option (Template ID): ', this.selectedOption);  // Log the selected template ID
    }

    // Call Apex to send document for digital signing
    callSendDocumentForDigitalSign() {
        this.isShowSpinner = true;  // Show loading spinner while processing

        sendDocumentForDigitalSign({
            parameter: this.selectedOption,  // Send the selected template ID
            leadId: this.recordId  // Send the current Lead record ID
        })
            .then(result => {
                this.isShowSpinner = false;  // Hide spinner after processing
                this.showSuccessToast();  // Show success toast
                this.closeAction();  // Close the modal
                console.log('Success: ', result);  // Log the success result
            })
            .catch(error => {
                this.isShowSpinner = false;  // Hide spinner if an error occurs
                console.error('Error: ', error);  // Log the error
            });
    }

    // Handle cancel action by hiding the modal
    handleCancel() {
        this.isModalShow = false;
    }

    // Handle send button click to initiate the document signing process
    handleSend() {
        this.callSendDocumentForDigitalSign();
    }

    // Show a success toast message when the document is successfully sent
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success!',
            message: 'Document Sent for Signature Successfully.',
            variant: 'success',
        });
        this.dispatchEvent(evt);  // Dispatch the toast event
    }

    // Refresh the component when the Lead's Preferred Language changes
    renderedCallback() {
        // If the Preferred Language field changes, refresh the Apex options
        if (this.leadRecord.data) {
            refreshApex(this.wiredOptionsResult);  // Refresh options based on new Preferred Language
        }
    }
}