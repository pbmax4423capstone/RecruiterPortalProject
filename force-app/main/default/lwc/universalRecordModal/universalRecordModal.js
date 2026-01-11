import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class UniversalRecordModal extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fields; // Array of field API names
    @api modalTitle = 'Record Details';
    @api showModal = false;

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    record;

    get recordFields() {
        if (!this.record.data || !this.fields) return [];
        return this.fields.map(field => ({
            apiName: field,
            value: this.record.data.fields[field]?.value || ''
        }));
    }

    handleClose() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}
