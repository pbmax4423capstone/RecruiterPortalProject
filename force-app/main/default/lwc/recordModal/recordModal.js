import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// We'll dynamically determine the fields based on object type
export default class RecordModal extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api darkMode = false;
    @track isLoading = true;
    @track error = null;
    @track recordData;

    wiredRecordResult;

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecord(result) {
        this.wiredRecordResult = result;
        if (result.data) {
            this.recordData = result.data;
            this.isLoading = false;
            this.error = null;
        } else if (result.error) {
            this.error = result.error;
            this.isLoading = false;
        }
    }

    get modalClass() {
        return this.darkMode ? 'slds-modal slds-fade-in-open record-modal dark-mode' : 'slds-modal slds-fade-in-open record-modal';
    }

    get recordName() {
        if (!this.recordData) return '';
        const nameField = this.recordData.fields.Name || this.recordData.fields.Subject || this.recordData.fields.Title;
        return nameField ? nameField.value : this.recordId;
    }

    get objectIcon() {
        switch (this.objectApiName?.toLowerCase()) {
            case 'case':
                return 'standard:case';
            case 'contact':
                return 'standard:contact';
            case 'account':
                return 'standard:account';
            case 'opportunity':
                return 'standard:opportunity';
            case 'lead':
                return 'standard:lead';
            case 'task':
                return 'standard:task';
            default:
                return 'standard:record';
        }
    }

    get objectLabel() {
        return this.objectApiName || 'Record';
    }

    handleClose(event) {
        console.log('Record modal close event dispatched');
        
        // Prevent event bubbling if it exists
        if (event && event.stopPropagation) {
            event.stopPropagation();
        }
        if (event && event.preventDefault) {
            event.preventDefault();
        }
        
        const closeEvent = new CustomEvent('close', { 
            bubbles: true,
            composed: true 
        });
        this.dispatchEvent(closeEvent);
    }

    handleBackdropClick() {
        this.handleClose();
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    handleEdit() {
        // Navigate to edit page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName,
                actionName: 'edit'
            }
        });
        this.handleClose();
    }

    handleViewFullRecord() {
        // Navigate to full record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        });
        this.handleClose();
    }

    // Helper to get field value safely
    getFieldValue(fieldApiName) {
        if (!this.recordData || !this.recordData.fields) return '';
        const field = this.recordData.fields[fieldApiName];
        return field ? field.value : '';
    }

    // Helper to format date
    formatDate(dateValue) {
        if (!dateValue) return '';
        return new Date(dateValue).toLocaleString();
    }
}