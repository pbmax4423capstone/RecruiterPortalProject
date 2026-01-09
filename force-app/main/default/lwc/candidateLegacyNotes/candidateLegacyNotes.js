import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NOTES_FIELD from '@salesforce/schema/Candidate__c.Notes__c';

export default class CandidateLegacyNotes extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [NOTES_FIELD] })
    candidate;

    get legacyNotes() {
        if (this.candidate && this.candidate.data) {
            return getFieldValue(this.candidate.data, NOTES_FIELD);
        }
        return null;
    }

    get hasLegacyNotes() {
        const notes = this.legacyNotes;
        return notes && notes.trim && notes.trim().length > 0;
    }

    get isLoading() {
        return !this.candidate || (!this.candidate.data && !this.candidate.error);
    }

    get hasError() {
        return this.candidate && this.candidate.error;
    }
}