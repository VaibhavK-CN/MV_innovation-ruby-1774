import { LightningElement,api,wire,track } from 'lwc';
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

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NeedAnalysis extends LightningElement {
    @api recordId;
    objectName = 'Lead';
    kvgForNeedAnalysisForm = [DEDUCTIBLE_NEED_ANALYSIS,MODEL_OF_INSURANCE,EMPLOYEMENT_STATUS]
    benefitDeductible = [LUMP_SUM_PAYMENT]
    hospitalizationInsurance = [ACCESS_SUPPORT_FROM_SPECIALIST,SECOND_OPINION_BY_EXPERT,ACCESS_TO_REOWNED_CLINIC,ACCESS_TO_LATEST_TECHNOLOGY,FAST_TRACKING,HOSPITALIZATION_ABROAD]
    outpatient_insurance = [TRANSPORTATION_RESCUE,CANCELLATION_COST,COMPLEMENTORY_MEDICINE,NON_MANDATORY_DRUGS,CHECK_UP_PREVENTION,GYNECOLOGY_NO_DEDUCTIBLE,MATERNITY_WITH_WAITING,FITNESS_NO_DEDUCTIBLE,SPORTS_CLUBS_NO_DEDUCTIBLE,GLASSES_LENSES,LASER_EYE_SURGERY]
    dentalInsurance = [DENTAL_TREATMENT,BRACES_NO_DEDUCTIBLE]
    other = [PREMIUM_EXCEPTION,CAPITAL_INSURANCE,LEGAL_PROTECTION]
    preminum = [CURRENT_PREMINUM,PREMIUM_BUDGET]

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