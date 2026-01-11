import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import STAGE_NAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import RECORD_TYPE_ID from '@salesforce/schema/Opportunity.RecordTypeId';

export default class OpportunityStagePath extends LightningElement {
    @api recordId;

    currentStep;
    steps = [];
    error;

    // Get record for current stage and record type
    @wire(getRecord, { recordId: '$recordId', fields: [STAGE_NAME_FIELD, RECORD_TYPE_ID] })
    opportunity;

    // Object info for default record type when recordTypeId isn't available
    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    objectInfo;

    // Compute recordTypeId to use for picklist values
    get recordTypeId() {
        const fromRecord = getFieldValue(this.opportunity?.data, RECORD_TYPE_ID);
        const fromObject = this.objectInfo?.data?.defaultRecordTypeId;
        return fromRecord || fromObject;
    }

    // Pull StageName picklist values for the record type
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STAGE_NAME_FIELD })
    wiredStages({ data, error }) {
        if (data) {
            this.steps = (data.values || []).map(v => ({ label: v.label, value: v.value }));
            this.error = undefined;
            this.updateCurrentStep();
        } else if (error) {
            this.error = error;
        }
    }

    // Update current step when record changes
    renderedCallback() {
        this.updateCurrentStep();
    }

    updateCurrentStep() {
        const stage = getFieldValue(this.opportunity?.data, STAGE_NAME_FIELD);
        if (stage && this.steps && this.steps.length) {
            this.currentStep = this.steps.find(s => s.value === stage)?.value || this.steps[0].value;
        }
    }

    get isReady() {
        return this.steps && this.steps.length > 0 && this.currentStep;
    }

    get errorMessage() {
        return this.error?.body?.message || this.error?.message || 'Unable to load stages';
    }
}
