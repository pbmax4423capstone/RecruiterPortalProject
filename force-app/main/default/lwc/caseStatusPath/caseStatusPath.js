import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import RECORD_TYPE_ID from '@salesforce/schema/Case.RecordTypeId';

export default class CaseStatusPath extends LightningElement {
    @api recordId;

    currentStep;
    steps = [];
    error;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD, RECORD_TYPE_ID] })
    caseRecord;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    get recordTypeId() {
        const fromRecord = getFieldValue(this.caseRecord?.data, RECORD_TYPE_ID);
        const fromObject = this.objectInfo?.data?.defaultRecordTypeId;
        return fromRecord || fromObject;
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STATUS_FIELD })
    wiredStatus({ data, error }) {
        if (data) {
            this.steps = (data.values || []).map(v => ({ label: v.label, value: v.value }));
            this.error = undefined;
            this.updateCurrentStep();
        } else if (error) {
            this.error = error;
        }
    }

    renderedCallback() {
        this.updateCurrentStep();
    }

    updateCurrentStep() {
        const status = getFieldValue(this.caseRecord?.data, STATUS_FIELD);
        if (status && this.steps && this.steps.length) {
            this.currentStep = this.steps.find(s => s.value === status)?.value || this.steps[0].value;
        }
    }

    get isReady() {
        return this.steps && this.steps.length > 0 && this.currentStep;
    }

    get errorMessage() {
        return this.error?.body?.message || this.error?.message || 'Unable to load status';
    }
}
