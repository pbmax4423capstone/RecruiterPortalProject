import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordUi } from 'lightning/uiRecordApi';

// Opportunity fields
import OPPORTUNITY_NAME from '@salesforce/schema/Opportunity.Name';
import OPPORTUNITY_STAGE from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPORTUNITY_CLOSEDATE from '@salesforce/schema/Opportunity.CloseDate';

const FIELDS = [
    OPPORTUNITY_NAME,
    OPPORTUNITY_STAGE,
    OPPORTUNITY_AMOUNT,
    OPPORTUNITY_CLOSEDATE
];

export default class OpportunityRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isEditing = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunity;

    // UI metadata for display values (e.g., lookup names)
    @wire(getRecordUi, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    opportunityUi;

    get name() {
        return getFieldValue(this.opportunity?.data, OPPORTUNITY_NAME) || '';
    }
    get stage() {
        return getFieldValue(this.opportunity?.data, OPPORTUNITY_STAGE) || '';
    }
    get amount() {
        const val = getFieldValue(this.opportunity?.data, OPPORTUNITY_AMOUNT);
        return typeof val === 'number' ? val : null;
    }
    get closeDate() {
        return getFieldValue(this.opportunity?.data, OPPORTUNITY_CLOSEDATE) || '';
    }

    // Display values from UI API (fallback to raw if not available)
    get agencyDisplay() {
        const f = this.opportunityUi?.data?.record?.fields;
        return f?.Agency__c?.displayValue || f?.Agency__c?.value || '';
    }
    get solicitingAgentDisplay() {
        const f = this.opportunityUi?.data?.record?.fields;
        return f?.Soliciting_Agent__c?.displayValue || f?.Soliciting_Agent__c?.value || '';
    }
    get forecastCategoryDisplay() {
        const f = this.opportunityUi?.data?.record?.fields;
        return f?.ForecastCategory?.displayValue || f?.ForecastCategory?.value || '';
    }

    toggleEdit() {
        this.isEditing = !this.isEditing;
    }

    handleEditSuccess() {
        refreshApex(this.opportunity);
        this.isEditing = false;
    }
    handleEditError() {
        // Child form shows messages
    }

    navigateToRecord() {
        if (!this.recordId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: this.recordId, actionName: 'view' }
        });
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
            this.dispatchEvent(new ShowToastEvent({ title: 'Deleted', message: 'Opportunity deleted', variant: 'success' }));
            // Navigate to home list
            this[NavigationMixin.Navigate]({ type: 'standard__objectPage', attributes: { objectApiName: 'Opportunity', actionName: 'home' } });
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Delete failed', message: e?.body?.message || 'Unable to delete', variant: 'error', mode: 'sticky' }));
        }
    }

    openNotesFiles() {
        if (!this.recordId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                relationshipApiName: 'CombinedAttachments',
                actionName: 'view'
            }
        });
    }
}
