import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordUi } from 'lightning/uiRecordApi';

export default class DeviceInspectionRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName; // Provided automatically on record pages
    @track isEditing = false;

    // Fetch header-safe values (e.g., Name) without output-field styling
    @wire(getRecordUi, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    recordUi;

    get name() {
        const fields = this.recordUi?.data?.record?.fields;
        return fields?.Name?.value || '';
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
}
