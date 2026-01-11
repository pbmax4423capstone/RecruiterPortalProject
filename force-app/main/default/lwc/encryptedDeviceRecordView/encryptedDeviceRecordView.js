import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordUi } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

export default class EncryptedDeviceRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName; // provided automatically on record pages
    @track isEditing = false;

    @wire(getRecordUi, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    recordUi;

    get name() {
        return this.recordUi?.data?.record?.fields?.Name?.value || '';
    }

    toggleEdit() {
        this.isEditing = !this.isEditing;
    }

    handleEditSuccess() {
        this.isEditing = false;
        this.dispatchEvent(new ShowToastEvent({ title: 'Saved', message: 'Record updated', variant: 'success' }));
    }

    handleEditError(event) {
        const message = event?.detail?.message || 'Save failed';
        this.dispatchEvent(new ShowToastEvent({ title: 'Error', message, variant: 'error', mode: 'sticky' }));
    }

    navigateToEdit() {
        if (!this.recordId) return;
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: this.recordId, actionName: 'edit' } });
    }
    navigateToClone() {
        if (!this.recordId) return;
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: this.recordId, actionName: 'clone' } });
    }
    async deleteCurrent() {
        try {
            await deleteRecord(this.recordId);
            this.dispatchEvent(new ShowToastEvent({ title: 'Deleted', message: 'Record deleted', variant: 'success' }));
            this[NavigationMixin.Navigate]({ type: 'standard__objectPage', attributes: { objectApiName: this.objectApiName || 'Record', actionName: 'home' } });
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Delete failed', message: e?.body?.message || 'Unable to delete', variant: 'error', mode: 'sticky' }));
        }
    }
}
