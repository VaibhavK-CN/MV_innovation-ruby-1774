import { LightningElement,api,wire,track } from 'lwc';
import AGE from '@salesforce/schema/Lead.Age__c';
import START_OF_INSURANCE from '@salesforce/schema/Lead.Start_of_Insurance__c';
import AGE_POPULATE from '@salesforce/schema/Lead.AgePopulate__c';
import ACCIDENT from '@salesforce/schema/Lead.Accident__c';
import INSURANCE_COMPANY_K from '@salesforce/schema/Lead.Insurance_Company_KVG__c';
import MONTHLY_PREMINUM_NETTO from '@salesforce/schema/Lead.Monthly_Premium_netto_KVG__c';
import MODAL_OF_INSU from '@salesforce/schema/Lead.Model_of_insurance_Application_Form__c';
import DEDUCTIBLE from '@salesforce/schema/Lead.Deductible_Application_Form__c';

import INSURANCE_COMPANY from '@salesforce/schema/Lead.Insurance_Company_VVG__c';
import START_OF_INSURANC from '@salesforce/schema/Lead.Start_of_Insurance_VVG__c';
import PRODUCTS from '@salesforce/schema/Lead.Products__c';
import MONTHLY_PREMINUM from '@salesforce/schema/Lead.Monthly_Premium_netto_VVG__c';

import NAME_OF_BANK from '@salesforce/schema/Lead.Name_of_Bank__c';

import THE_CUSTOMER_CANCELS from '@salesforce/schema/Lead.The_customer_cancels_his_insurance_contr__c';
import THE_CUSTOMER_AUTHORIZE from '@salesforce/schema/Lead.The_customer_authorizes_the_intermediary__c';

import CANCELATION_DATE_KVG from '@salesforce/schema/Lead.Cancelation_Date_KVG__c';
import CANCELATION_DATE_VVG from '@salesforce/schema/Lead.Cancelation_Date_VVG__c';
import CANCEL_KVG from '@salesforce/schema/Lead.Cancel_KVG__c';
import CANCEL_VVG from '@salesforce/schema/Lead.Cancel_VVG__c';

import RECOMMENDATION from '@salesforce/schema/Lead.Recommendation__c';
import FOLLOWUP_APPOINTMENT from '@salesforce/schema/Lead.Follow_Up_Appointment__c';
import HOUSEHOLD_LIABILITY from '@salesforce/schema/Lead.Houshold_Liability__c';
import LEGAL from '@salesforce/schema/Lead.Legal__c';
import PILLAR from '@salesforce/schema/Lead.Pillar__c';
import CAR_INSURANCE from '@salesforce/schema/Lead.Car_Insurance__c';
import BUILDING_INSURANCE from '@salesforce/schema/Lead.Building_Insurance__c';
import TRAVEL_INSURANCE from '@salesforce/schema/Lead.Travel_Insurance__c';
import GOOGLE_REVIEW from '@salesforce/schema/Lead.Google_Review__c';

import CANCELATION_FORM_LINK from '@salesforce/schema/Lead.Cancellation_Form_Link__c';
import CANCELATION_REASON from '@salesforce/schema/Lead.Cancelation_Reason__c';
import WISH_TO_CANCEL from '@salesforce/schema/Lead.Wish_to_Cancel__c';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ApplicationFormHealthInsurance extends LightningElement {
    @api recordId;
    objectName = 'Lead';

    kvgForApplicationForm = [AGE,START_OF_INSURANCE,AGE_POPULATE,ACCIDENT,INSURANCE_COMPANY_K,MONTHLY_PREMINUM_NETTO,MODAL_OF_INSU,DEDUCTIBLE]
    vvgForApplicatioForm = [INSURANCE_COMPANY,START_OF_INSURANC,PRODUCTS,MONTHLY_PREMINUM]
    bank = [NAME_OF_BANK]
    consultationProtocol = [THE_CUSTOMER_CANCELS,THE_CUSTOMER_AUTHORIZE]
    cancellation = [CANCELATION_DATE_KVG,CANCELATION_DATE_VVG,CANCEL_KVG,CANCEL_VVG]
    aftercare = [RECOMMENDATION,FOLLOWUP_APPOINTMENT,HOUSEHOLD_LIABILITY,LEGAL,PILLAR,CAR_INSURANCE,BUILDING_INSURANCE,TRAVEL_INSURANCE,GOOGLE_REVIEW]
    sectionFields = [CANCELATION_FORM_LINK,CANCELATION_REASON,WISH_TO_CANCEL]

    handleSubmit(event) {
        this.showMessage('Record Saved Successfully','success');
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