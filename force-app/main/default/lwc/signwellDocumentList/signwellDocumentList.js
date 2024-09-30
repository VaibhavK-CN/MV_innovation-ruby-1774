import { LightningElement,api,wire } from 'lwc';
import getRelatedDocuments from '@salesforce/apex/LeadController.getRelatedDocuments';
import getDocumentsStatus from '@salesforce/apex/SignWellApi.getDocumentsStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class SignwellDocumentList extends LightningElement {
    @api recordId
    documents
    docsIdList = []
    isShowSpinner = false

    @wire(getRelatedDocuments,{leadId:'$recordId'})
    wiredAccount({error,data}) {
        if(data) {
            console.log('DATA:',JSON.stringify(data));
            this.documents = data;
            console.log('docsIdList0: '+this.docsIdList);
            this.error = undefined
        }
        else if (error) {
            this.documents = undefined;
            this.error = error
        }
    }
    handleRefreshClick() {
        this.isShowSpinner = true
        getDocumentsStatus({parameter: this.documents, leadId: this.recordId})
        .then(result => {
                // Handle success response
                this.documents = result;
                 this.isShowSpinner = false
                 this.showSuccessToast();

            })
            .catch(error => {
                // Handle error response
                console.log('Error: ', error);
            });
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success!',
            message: 'Documents  status refresh successfully.',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
}