import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

// Case fields
import ID_FIELD from '@salesforce/schema/Case.Id';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import REASON_FIELD from '@salesforce/schema/Case.Reason';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';

export default class CloseCaseModal extends LightningElement {
    @api caseId;
    @api caseNumber;
    @api darkMode = false;
    @api isMockData = false;
    
    @track closeReason = '';
    @track closureNotes = '';
    @track isLoading = false;
    @track error = null;

    // Close reason options
    get reasonOptions() {
        return [
            { label: 'Resolved', value: 'Resolved' },
            { label: 'Duplicate', value: 'Duplicate' },
            { label: 'Not an Issue', value: 'Not an Issue' },
            { label: 'Cannot Reproduce', value: 'Cannot Reproduce' },
            { label: 'User Error', value: 'User Error' },
            { label: 'Workaround Provided', value: 'Workaround Provided' },
            { label: 'Fixed in Update', value: 'Fixed in Update' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get modalClass() {
        return this.darkMode ? 'slds-modal slds-fade-in-open close-case-modal dark-mode' : 'slds-modal slds-fade-in-open close-case-modal';
    }

    get isCloseDisabled() {
        return !this.closeReason || this.isLoading;
    }

    handleReasonChange(event) {
        this.closeReason = event.detail.value;
    }

    handleNotesChange(event) {
        this.closureNotes = event.target.value;
    }

    handleCancel() {
        const cancelEvent = new CustomEvent('cancel');
        this.dispatchEvent(cancelEvent);
    }

    handleBackdropClick() {
        this.handleCancel();
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    async handleCloseCase() {
        if (!this.closeReason) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select a close reason.',
                variant: 'error'
            }));
            return;
        }

        // Handle mock data gracefully
        if (this.isMockData) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Mock Data Demo',
                message: `Demo: Case ${this.caseNumber || this.caseId} would be closed with reason "${this.closeReason}". In production, this would update the actual case.`,
                variant: 'success'
            }));

            // Dispatch close event with mock data
            const closeEvent = new CustomEvent('caseclosed', {
                detail: { 
                    caseId: this.caseId,
                    reason: this.closeReason,
                    notes: this.closureNotes
                }
            });
            this.dispatchEvent(closeEvent);
            return;
        }

        this.isLoading = true;
        this.error = null;

        try {
            // Prepare the case update - only update essential fields
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.caseId;
            fields[STATUS_FIELD.fieldApiName] = 'Closed';
            
            // Only set reason if we have one and it's a valid Case field
            if (this.closeReason) {
                // Note: Some orgs may not have a Reason field on Case, so we'll handle this carefully
                try {
                    fields[REASON_FIELD.fieldApiName] = this.closeReason;
                } catch (reasonError) {
                    console.warn('Reason field may not be available on Case object');
                }
            }

            const recordInput = { fields };
            await updateRecord(recordInput);

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `Case ${this.caseNumber || this.caseId} has been closed successfully.`,
                variant: 'success'
            }));

            // Dispatch close event with case details
            const closeEvent = new CustomEvent('caseclosed', {
                detail: { 
                    caseId: this.caseId,
                    reason: this.closeReason,
                    notes: this.closureNotes
                }
            });
            this.dispatchEvent(closeEvent);

        } catch (error) {
            console.error('Error closing case:', error);
            this.error = error;
            
            let errorMessage = 'Failed to close case';
            if (error && error.body && error.body.message) {
                errorMessage += ': ' + error.body.message;
            } else if (error && error.message) {
                errorMessage += ': ' + error.message;
            } else if (typeof error === 'string') {
                errorMessage += ': ' + error;
            } else {
                errorMessage += '. Please try again or contact your administrator.';
            }
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }
}