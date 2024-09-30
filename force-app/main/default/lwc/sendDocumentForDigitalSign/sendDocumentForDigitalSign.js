import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getOptionsMetadata from '@salesforce/apex/OptionsMetadataController.getOptionsMetadata';
import sendDocumentForDigitalSign from '@salesforce/apex/SignWellApi.sendDocumentForDigitalSign';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class SendDocumentForDigitalSign extends LightningElement {
    @api recordId;
    options = [];
    selectedOption;
    isModalShow = true
    isShowSpinner = false

    @wire(getOptionsMetadata)
    wiredOptions({ error, data }) {
        if (data) {
            console.log('data: ', data)
            this.options = data.map(option => ({
                label: option.label,
                value: option.value,
                language : option.language
            }));
        } else if (error) {
            console.error('Error retrieving options:', error);
        }
    }

    closeModal() {
        // Close the modal
        this.dispatchEvent(new CustomEvent('close'));
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleOptionChange(event) {
        this.selectedOption = event.target.value;
        // Handle the selected option value here
        console.log('Selected Option: ', this.selectedOption);
    }

    callSendDocumentForDigitalSign() {
        this.isShowSpinner = true
        sendDocumentForDigitalSign({parameter: this.selectedOption, leadId: this.recordId })
            .then(result => {
                this.isShowSpinner = false;
                this.showSuccessToast();
                this.closeAction();
                console.log('Success: ', result);
            })
            .catch(error => {
                // Handle error response
                console.log('Error: ', error);
            });
    }
    handleCancel() {
        this.isModalShow = false;
    }

    handleSend() {
        this.callSendDocumentForDigitalSign();
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success!',
            message: 'Document Sent for Signature Successfully.',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
}