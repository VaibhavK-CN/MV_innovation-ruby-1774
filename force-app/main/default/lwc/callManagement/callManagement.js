import { LightningElement,track,wire } from 'lwc';
import {getPicklistValuesByRecordType, getObjectInfo} from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import getLeadRecords from '@salesforce/apex/LeadController.getLeadRecords';
const columns = [{
    label: 'Name',
    fieldName: 'Name'
},
{
    label: 'Lead Status',
    fieldName: 'Status'

},
{
    label: 'Language preference',
    fieldName: 'Langauge_Prefered__c',
}
]

export default class CallManagement extends LightningElement {
    saveDraftValues = [];
    @track draftValues = [];
    wiredRecords;
    error;
    columns = columns;
    languageOptions
    selectedLanguage='';
    
    pageSizeOptions = [25, 50, 75, 100]; //Page size options
    records = []; //All records available in the data table
    columns = columns; //columns information available in the data table
    totalContacted = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplay = []; //Records to be displayed on the page
    totalRecords = 0;

    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    /*@wire( getLeadRecords )  
    wiredAccount( value ) {
        this.wiredRecords = value;
        const { data, error } = value;
        if ( data ) {
            this.appointmentRecord = data;
            this.error = undefined;

        } else if ( error ) {

            this.error = error;
            this.appointmentRecord = undefined;

        }
    }*/
    @wire(getObjectInfo, {objectApiName:LEAD_OBJECT})
    objectInfo

    @wire(getPicklistValuesByRecordType, {objectApiName:LEAD_OBJECT, 
        recordTypeId:'$objectInfo.data.defaultRecordTypeId'})
        picklistHandler({data, error}){
            if(data){
                console.log(data)
                this.languageOptions = this.picklistGenerator(data.picklistFieldValues.Langauge_Prefered__c)
                console.log('languageOptions: '+JSON.stringify(this.languageOptions))
            }
            if(error){
                console.error(error)
            }
        }

    picklistGenerator(data){
        return data.values.map(item=>({"label":item.label, "value":item.value}))
    }
        
    connectedCallback() {
        getLeadRecords()
        .then((result) => {
            if (result != null) {
                
                this.records = result;
                //console.log('##Records--> ' + JSON.stringify(this.records));
                this.totalRecords = this.records.length;
                this.pageSize = this.pageSizeOptions[0];
                this.paginationHelper(); 
            }
        })
        .catch((error) => {
            console.log('error while fetch Records. ' + JSON.stringify(error));
        });
    }
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        alert(this.pageSize)
        this.paginationHelper();
    }

    async handleSave( event ) {
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        console.log('##recordInputs'+JSON.stringify(recordInputs));
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'
                })
            );
            this.saveDraftValues = [];
            return this.refresh();
        }).catch(error => {
            /*this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An Error Occured!!',
                    variant: 'error'
                })
            );*/
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }

    // This function is used to refresh the table once data updated
    /*async refresh() {
        await refreshApex(this.wiredRecords);
    }*/
    lookupRecord(event){
        alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
    }
    // picklist value change handler
    handleValueChange(event) {
        this.selectedLanguage = event.target.value
        alert(this.selectedLanguage)
    }
    handleCheckAvailabilityClick() {
        alert('Testt...')
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page
            for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
                if (i === this.totalRecords) {
                    break;
                }
                    this.recordsToDisplay.push(this.records[i]);     
            }    
    }
}