import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AlcInformationEdit extends LightningElement {
    @api recordId;
    objectApiName = 'ALC__c';
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

    handleSuccess(event) {
        try {
            // bubble up so parent can refresh and exit edit mode
            this.dispatchEvent(new CustomEvent('editsuccess'));

            // Optional: inspect returned fields for diagnostics
            // const savedFields = event?.detail?.fields;

            try {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ALC updated',
                        message: 'Your changes have been saved.',
                        variant: 'success'
                    })
                );
            } catch (toastErr) {
                // eslint-disable-next-line no-console
                console.warn('ShowToastEvent failed (continuing):', toastErr);
            }
        } catch (err) {
            // Swallow to avoid Aura generic Script error
            // eslint-disable-next-line no-console
            console.error('handleSuccess error (swallowed):', err);
        }
    }

    handleError(event) {
        try {
            // Surface detailed errors to help diagnose save issues
            const detail = event?.detail;
            const messages = [];

            // Collect record-edit-form errors if available
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

            // Log for debugging and show toast
            // eslint-disable-next-line no-console
            console.error('alcInformationEdit save error:', detail);

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
                // eslint-disable-next-line no-console
                console.warn('ShowToastEvent failed (continuing):', toastErr);
            }

            // Bubble up so parent can optionally react
            this.dispatchEvent(
                new CustomEvent('editerror', {
                    detail: { message, raw: detail }
                })
            );
        } catch (err) {
            // Avoid cross-origin script errors
            // eslint-disable-next-line no-console
            console.error('handleError processing failed (swallowed):', err);
        }
    }

    handleSubmit() {
        // Intentionally minimal: allows future interception if needed.
        // No-throw to keep Aura boundary quiet.
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('editcancel'));
    }

    // Fields to show in the all-fields section
    displayedFields = [
        'Agency__c',
        'First_Name__c',
        'Last_Name__c',
        'Registered__c',
        'Life_Insurance_Licensed__c',
        'Office__c',
        'Position__c',
        'Contract_Type__c',
        'Assistant_Employed_by__c',
        'LADL_Sales_Experience__c',
        'A360__c',
        'Contact__c',
        'Contract_Effective__c',
        'Contract_B_Expiration_Date__c',
        'DOB__c',
        'Prior_NWM__c',
        'CM_Code__c',
        'Manager__c',
        'Career_Corp_MMID__c',
        'MMID__c',
        'Sales_Manager__c',
        'Personal_Email_Address__c',
        'Mobile__c',
        'Start_date__c',
        'Stage__c',
        'Tags__c',
        'Employed_at_Insurance_Brokerage_in_las__c',
        'Kaplan_Exam_Request__c',
        'Next_Meeting_Date__c',
        'Related_Candidate__c'
    ];
}
