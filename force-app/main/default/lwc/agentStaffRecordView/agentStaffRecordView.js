import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordUi } from 'lightning/uiRecordApi';

export default class AgentStaffRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName; // Provided automatically on record pages
    @track isEditing = false;

    // Generic record UI for header and related lookups
    @wire(getRecordUi, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    recordUi;

    get name() {
        const fields = this.recordUi?.data?.record?.fields;
        return fields?.Name?.value || '';
    }
    get status() {
        const fields = this.recordUi?.data?.record?.fields;
        return fields?.Status__c?.value || '';
    }
    get candidateId() {
        const fields = this.recordUi?.data?.record?.fields;
        return fields?.Candidate__c?.value || null;
    }
    get alcId() {
        const fields = this.recordUi?.data?.record?.fields;
        return fields?.ALC__c?.value || null;
    }

    toggleEdit() { this.isEditing = !this.isEditing; }
    handleEditSuccess(event) {
        try {
            this.isEditing = false;
            const recId = event?.detail?.id || this.recordId;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Saved',
                    message: `Record ${recId} saved successfully`,
                    variant: 'success'
                })
            );
        } catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({ title: 'Saved', message: 'Save completed', variant: 'success' })
            );
        }
    }
    handleEditError(event) {
        let message = 'An error occurred while saving.';
        try {
            message = event?.detail?.message || message;
        } catch (e) {}
        this.dispatchEvent(
            new ShowToastEvent({ title: 'Error', message, variant: 'error', mode: 'sticky' })
        );
    }

    navigateToRecord() {
        if (!this.recordId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: this.recordId, actionName: 'view' }
        });
    }

    navigateToCandidate() {
        if (!this.candidateId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: this.candidateId, actionName: 'view' }
        });
    }

    navigateToAlc() {
        if (!this.alcId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: this.alcId, actionName: 'view' }
        });
    }
}
