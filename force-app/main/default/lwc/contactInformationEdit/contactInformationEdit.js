import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactInformationEdit extends LightningElement {
    @api recordId;
    objectApiName = 'Contact';
    @track showAllFields = false;

    get toggleButtonLabel() {
        return this.showAllFields ? 'Hide All Fields' : 'Show All Fields';
    }

    get toggleButtonVariant() {
        return this.showAllFields ? 'neutral' : 'brand-outline';
    }

    handleToggleAllFields() {
        this.showAllFields = !this.showAllFields;
    }

    handleSuccess() {
        try {
            this.dispatchEvent(new CustomEvent('editsuccess'));
            try {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Contact updated',
                        message: 'Your changes have been saved.',
                        variant: 'success'
                    })
                );
            } catch (toastErr) {
                console.warn('ShowToastEvent failed (continuing):', toastErr);
            }
        } catch (err) {
            console.error('contactInformationEdit handleSuccess error (swallowed):', err);
        }
    }

    handleError(event) {
        try {
            const detail = event?.detail;
            const messages = [];
            const outputErrors = detail?.output?.errors || [];
            const fieldErrors = detail?.output?.fieldErrors || {};

            outputErrors.forEach((e) => {
                if (e?.message) messages.push(e.message);
            });
            Object.keys(fieldErrors).forEach((field) => {
                const errs = fieldErrors[field] || [];
                errs.forEach((e) => {
                    if (e?.message) messages.push(`${field}: ${e.message}`);
                });
            });

            const fallbackMsg = detail?.message || 'An error occurred while saving.';
            const message = messages.length ? messages.join('\n') : fallbackMsg;

            console.error('contactInformationEdit save error:', detail);
            try {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Save failed',
                        message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            } catch (toastErr) {
                console.warn('ShowToastEvent failed (continuing):', toastErr);
            }

            this.dispatchEvent(
                new CustomEvent('editerror', {
                    detail: { message, raw: detail }
                })
            );
        } catch (err) {
            console.error('contactInformationEdit handleError processing failed (swallowed):', err);
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('editcancel'));
    }

    handleSubmit() {
        // Placeholder for future interception; keep no-throw.
    }

    displayedFields = [
        'FirstName',
        'LastName',
        'Email',
        'MobilePhone',
        'HomePhone',
        'Personal_Email__c',
        'MailingStreet',
        'MailingCity',
        'MailingState',
        'MailingPostalCode'
    ];
}
