import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCurrentUserLeadList from '@salesforce/apex/LeadListController.getCurrentUserLeadList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class NextLead extends NavigationMixin(LightningElement) {
    @api recordId;
    @track leadList = [];
    @track newLeadList = [];
    nextLeadId

    connectedCallback() {
        getCurrentUserLeadList({ recordId: this.recordId})
        .then(result => {
            if (result) {
                this.leadList = result;
            }
            console.log('leadList::', JSON.stringify(this.leadList.length));
            console.log('leadList::', JSON.stringify(this.leadList));
        });
        
    }
    nextLeadRecordId
    handleNextLeadClick(event) {
        for (let i = 0; i < this.leadList.length; i++) {
            if (this.leadList[i].Id === this.recordId) {
                this.nextLeadId = this.leadList[i + 1].Id;
                console.log('nextLeadId::', this.nextLeadId);
                break; 
            }
        }
        if(this.nextLeadId) {
            this.showMessage('Next lead opened successfully!','success');
            this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.nextLeadId,
                objectApiName: 'Lead',
                actionName: 'view'
            }
            });
        }
        
    }
    showMessage(message,variant)
    {
        const event = new ShowToastEvent({
            title: 'Record Save',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }
}