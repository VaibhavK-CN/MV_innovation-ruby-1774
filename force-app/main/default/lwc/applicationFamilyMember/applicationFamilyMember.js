import { LightningElement,api,wire,track } from 'lwc';
import submitFrom from '@salesforce/apex/LeadController.saveFamilyMember';
import getRelatedFamilyMembers from '@salesforce/apex/LeadController.getRelatedFamilyMembers';
import getFamilyMembers from '@salesforce/apex/LeadController.getFamilyMembers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ApplicationFamilyMember extends NavigationMixin(LightningElement) {
    @api recordId;
    wiredRecords
    memRecordId

    count = 1;
    @track iterator = [{ 'autoNumber': 1, 'name': '','relationship': '','email': '','dob': '' }];

    @wire(getRelatedFamilyMembers,{leadId:'$recordId'})
    wiredAccount({error,data}) {
        if(data) {
            this.wiredRecords = data;
            this.error = undefined
        }
        else if (error) {
            this.wiredRecords = undefined;
            this.error = error
        }
        
    }    
    handleSave () {
       submitFrom({ leadId: this.recordId, payload: JSON.stringify(this.iterator) })
       .then(result => {
           // ***Toast Event***      
           this.showMessage('Success!','Record created successfully.','success');
             this.iterator = [{ 'autoNumber': 1, 'name': '','relationship': '','email': '','dob': '' }];
             this.wiredRecords = null
             this.wiredRecords =  result;
       })
       .catch(error => {
                this.showMessage('Failed to Insert record',error.body.message,'error');
                console.log("error", JSON.stringify(this.error));
       });
   }
   onRemove(event) {
       let index = event.target.dataset.index;
        this.iterator.splice(index, 1);
        this.count = index
   }
   onAdd() {
     this.count++;
       this.iterator.push({
           autoNumber:this.count,
           'name': '',
           'relationship': '' ,
           'email': '',
           'dob': '' 
       });
   }

   nameChange(event) {
       this.iterator[event.target.dataset.index].name = event.target.value; 
   }
   relationChange(event) {
       this.iterator[event.target.dataset.index].relationship = event.target.value; 
   }
   emailChange(event) {
    this.iterator[event.target.dataset.index].email = event.target.value; 
    }
    dobChange(event) {
    this.iterator[event.target.dataset.index].dob = event.target.value; 
    }
   handleCancel() {
    this.count = 1;
    this.iterator = [{ 'autoNumber': 1, 'name': '','relationship': '','email': '','dob': '' }];
   }
   handleMemberClick(event) {
        this.memRecordId = event.currentTarget.dataset.recordId;
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.memRecordId,
                objectApiName: 'ApplicationFamilyMember__c',
                actionName: 'view'
            }
        });
    }
    showMessage(title,message,variant)
    {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

}