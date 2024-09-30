import { LightningElement,api,wire,track } from 'lwc';
import getForm from '@salesforce/apex/FieldSetController.getForm';
import LEAD_OBJECT from '@salesforce/schema/Lead'
import ADDRESS_FIELD from '@salesforce/schema/Lead.Address';

import CURRENT_HEALTH_INS from '@salesforce/schema/Lead.Current_Health_Insurance__c';
import INSURED_UNTIL from '@salesforce/schema/Lead.Insured_Until__c';
import TOTAL_PREMIUM from '@salesforce/schema/Lead.Total_Premium__c';
import INSURED_SINCE from '@salesforce/schema/Lead.Insured_Since__c';
import PRE_BESIC_HEALTH_INS from '@salesforce/schema/Lead.Premium_for_Basic_Health_Insurance__c';

import HEALTH_CONDITION from '@salesforce/schema/Lead.Health_Condition__c';

import NO_OF_PERSON_IN_HOS from '@salesforce/schema/Lead.Number_of_Persons_in_Household__c';

import FEEDBACK from '@salesforce/schema/Lead.Feedback__c';

import LEAD_STATUS from '@salesforce/schema/Lead.Status';
import LEAD_SOURCE from '@salesforce/schema/Lead.LeadSource';
import DESCRIPTION from '@salesforce/schema/Lead.Description';
import LEAD_OWNER from '@salesforce/schema/Lead.OwnerId';

import HOSPITALIZATION_INSURANCE from '@salesforce/schema/Lead.Hospitalization_insurance__c';
import OUTPATIENT_INSURANCE from '@salesforce/schema/Lead.Outpatient_insurance__c';
import PREMINUM_EXCEPTION from '@salesforce/schema/Lead.Premium_exemption_in_the_event_of_unempl__c';

import DEDUCTIBLE_NEED_ANALYSIS from '@salesforce/schema/Lead.Deductible_Need_Analysis__c';
import MODEL_OF_INSURANCE from '@salesforce/schema/Lead.Model_of_insurance_need_analysis__c';
import EMPLOYEMENT_STATUS from '@salesforce/schema/Lead.EEmployment_status__c';

import LUMP_SUM_PAYMENT from '@salesforce/schema/Lead.Lump_sum_payment_after_24_hours__c';

import ACCESS_SUPPORT_FROM_SPECIALIST from '@salesforce/schema/Lead.Access_and_support_from_specialists__c';
import SECOND_OPINION_BY_EXPERT from '@salesforce/schema/Lead.Second_opinion_by_experts__c';
import ACCESS_TO_REOWNED_CLINIC from '@salesforce/schema/Lead.Access_to_renowned_clinics__c';
import ACCESS_TO_LATEST_TECHNOLOGY from '@salesforce/schema/Lead.Access_to_the_latest_technologies__c';
import FAST_TRACKING from '@salesforce/schema/Lead.Fast_tracking__c';
import HOSPITALIZATION_ABROAD from '@salesforce/schema/Lead.Hospitalization_abroad__c';

import TRANSPORTATION_RESCUE from '@salesforce/schema/Lead.Transportation_Rescue_domestic_foreign__c';
import CANCELLATION_COST from '@salesforce/schema/Lead.Cancellation_costs__c';
import COMPLEMENTORY_MEDICINE from '@salesforce/schema/Lead.Complementary_medicine_massages_homeopat__c';
import NON_MANDATORY_DRUGS from '@salesforce/schema/Lead.Non_mandatory_drugs__c';
import CHECK_UP_PREVENTION from '@salesforce/schema/Lead.Check_up_prevention_no_deductible__c';
import GYNECOLOGY_NO_DEDUCTIBLE from '@salesforce/schema/Lead.Gynecology_no_deductible__c';
import MATERNITY_WITH_WAITING from '@salesforce/schema/Lead.Maternity_with_waiting_period_no_deduct__c';
import FITNESS_NO_DEDUCTIBLE from '@salesforce/schema/Lead.Fitness_no_deductible__c';
import SPORTS_CLUBS_NO_DEDUCTIBLE from '@salesforce/schema/Lead.Sports_clubs_no_deductible__c';
import GLASSES_LENSES from '@salesforce/schema/Lead.Glasses_lenses_no_deductible__c';
import LASER_EYE_SURGERY from '@salesforce/schema/Lead.Laser_eye_surgery_no_deductible__c';

import DENTAL_TREATMENT from '@salesforce/schema/Lead.Dental_treatment_with_deductible__c';
import BRACES_NO_DEDUCTIBLE from '@salesforce/schema/Lead.Braces_No_Deductible__c';

import PREMIUM_EXCEPTION from '@salesforce/schema/Lead.Premium_exemption_in_the_event_of_unempl__c';
import CAPITAL_INSURANCE from '@salesforce/schema/Lead.Capital_insurance_death_disability__c';
import LEGAL_PROTECTION from '@salesforce/schema/Lead.Legal_protection_private_transport_and__c';

import CURRENT_PREMINUM from '@salesforce/schema/Lead.Current_premium__c';
import PREMIUM_BUDGET from '@salesforce/schema/Lead.Premium_budget__c';

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

import COMPANY from '@salesforce/schema/Lead.Company';
import PRODUCT from '@salesforce/schema/Lead.Products__c';
import SOURCE from '@salesforce/schema/Lead.Source__c';
import VVG_FEE from '@salesforce/schema/Lead.VVG_Fee__c';

import PERCENTAGE from '@salesforce/schema/Lead.Percentage__c';
import COMMISSION from '@salesforce/schema/Lead.Commission__c';

import CALLBAK_LATER_DATE from '@salesforce/schema/Lead.Call_back_later_date__c';
import CONTRACT_EXPIRED_YEAR from '@salesforce/schema/Lead.Contract_Expired_year__c';
import FURTHER_DESCRIPTION from '@salesforce/schema/Lead.Further_Description__c';


import CREATED_BY from '@salesforce/schema/Lead.CreatedById';
import LAST_MODIFIED_BY from '@salesforce/schema/Lead.LastModifiedById';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadRecordDetailPage extends LightningElement {
    @api objectName;
    @api recordId;
    @api fieldSet;
    @track fields;
    @track currentProfile

    isShowLeadView = true
    isShowLeadEdit = false
    isCallAgent = false
    isCallAgentAndLnlConsultant = false
    isAddress = false
    insuranceTypeLifeInsurance = false
    isShowSystemInfo = false

    mapMarkers = [{
            location: {
                City: '',
                Country: '',
                PostalCode: '',
                State: '',
                Street: '',
            }
        }]; 
      

    addressFields = [ADDRESS_FIELD]
    insuranceDetailFields = [CURRENT_HEALTH_INS,INSURED_UNTIL,TOTAL_PREMIUM,INSURED_SINCE,PRE_BESIC_HEALTH_INS]
    healthCondition = [HEALTH_CONDITION]
    household = [NO_OF_PERSON_IN_HOS]
    feedback = [FEEDBACK,CALLBAK_LATER_DATE,CONTRACT_EXPIRED_YEAR,FURTHER_DESCRIPTION]
    additionalInformation = [LEAD_STATUS,LEAD_SOURCE,DESCRIPTION,LEAD_OWNER]
    descriptionInformation = [HOSPITALIZATION_INSURANCE,OUTPATIENT_INSURANCE,PREMINUM_EXCEPTION]
    kvgForNeedAnalysisForm = [DEDUCTIBLE_NEED_ANALYSIS,MODEL_OF_INSURANCE,EMPLOYEMENT_STATUS]
    benefitDeductible = [LUMP_SUM_PAYMENT]
    hospitalizationInsurance = [ACCESS_SUPPORT_FROM_SPECIALIST,SECOND_OPINION_BY_EXPERT,ACCESS_TO_REOWNED_CLINIC,ACCESS_TO_LATEST_TECHNOLOGY,FAST_TRACKING,HOSPITALIZATION_ABROAD]
    outpatient_insurance = [TRANSPORTATION_RESCUE,CANCELLATION_COST,COMPLEMENTORY_MEDICINE,NON_MANDATORY_DRUGS,CHECK_UP_PREVENTION,GYNECOLOGY_NO_DEDUCTIBLE,MATERNITY_WITH_WAITING,FITNESS_NO_DEDUCTIBLE,SPORTS_CLUBS_NO_DEDUCTIBLE,GLASSES_LENSES,LASER_EYE_SURGERY]
    dentalInsurance = [DENTAL_TREATMENT,BRACES_NO_DEDUCTIBLE]
    other = [PREMIUM_EXCEPTION,CAPITAL_INSURANCE,LEGAL_PROTECTION]
    preminum = [CURRENT_PREMINUM,PREMIUM_BUDGET]
    kvgForApplicationForm = [AGE,START_OF_INSURANCE,AGE_POPULATE,ACCIDENT,INSURANCE_COMPANY_K,MONTHLY_PREMINUM_NETTO,MODAL_OF_INSU,DEDUCTIBLE]
    vvgForApplicatioForm = [INSURANCE_COMPANY,START_OF_INSURANC,PRODUCTS,MONTHLY_PREMINUM]
    bank = [NAME_OF_BANK]
    consultationProtocol = [THE_CUSTOMER_CANCELS,THE_CUSTOMER_AUTHORIZE]
    cancellation = [CANCELATION_DATE_KVG,CANCELATION_DATE_VVG,CANCEL_KVG,CANCEL_VVG]
    aftercare = [RECOMMENDATION,FOLLOWUP_APPOINTMENT,HOUSEHOLD_LIABILITY,LEGAL,PILLAR,CAR_INSURANCE,BUILDING_INSURANCE,TRAVEL_INSURANCE,GOOGLE_REVIEW]
    commissionDetails = [COMPANY,PRODUCT,SOURCE,VVG_FEE,PERCENTAGE,COMMISSION]
   
    connectedCallback() {
        getForm({ recordId: this.recordId,objectName:this.objectName, fieldSetName:this.fieldSet})
        .then(result => {
            if (result) {
                this.fields = result.Fields;
                this.currentProfile = result.userDetail.ProfileId
                this.mapMarkers[0].location.City = result.leadDetail.City;
                this.mapMarkers[0].location.Country = result.leadDetail.Country;
                this.mapMarkers[0].location.PostalCode = result.leadDetail.PostalCode;
                this.mapMarkers[0].location.Street = result.leadDetail.Street;
                this.mapMarkers[0].location.State = result.leadDetail.City;
                if(result.leadDetail.Insurance_Type__c == 'LNL Insurance')   {
                    this.insuranceTypeLifeInsurance = true
                }
                console.log('insuranceType::',this.insuranceTypeLifeInsurance);
                if(this.mapMarkers[0] != '') {
                    this.isAddress = true;
                }

                if(this.currentProfile == '00e5r000000N8ZOAA0') {
                    this.isCallAgent = true
                }
                if(this.currentProfile == '00e07000000u3TIAAY' || this.currentProfile == '00e5r000000N8ZJAA0') {
                    this.isShowSystemInfo = true
                }
                this.error = undefined;
            }
        }) .catch(error => {
            console.log(error);
            this.error = error;
        }); 
    } 
    validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);
    }
    handleEdit(e) {
        this.isShowLeadView = false
        this.isShowLeadEdit = true
    }
    handleCancel(e) {
        this.isShowLeadView = true
        this.isShowLeadEdit = false        
    }
    saveClick(e)
    {
        e.preventDefault();
        const inputFields = e.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(inputFields);
        this.isShowLeadView = true
        this.isShowLeadEdit = false  
        this.showMessage('Record Saved Successfully','success');
        
    }
    handleSubmit(e) {
         this.showMessage('Record Saved Successfully','success');
    }
    handleSuccess(e)
    {
        this.showMessage('Record Saved Successfully','success');
    }
    handleError(e)
    {
        this.template.querySelector('[data-id="message"]').setError(e.detail.detail);
        e.preventDefault();
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