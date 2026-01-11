import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, deleteRecord } from 'lightning/uiRecordApi';
import { getRecordUi } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import SUBJECT from '@salesforce/schema/Case.Subject';
import STATUS from '@salesforce/schema/Case.Status';
import PRIORITY from '@salesforce/schema/Case.Priority';

const FIELDS = [CASE_NUMBER, SUBJECT, STATUS, PRIORITY];

export default class CaseRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isEditing = false;
    @track commActiveTab = 'compose';
    @track emailsTabLabel = 'Emails';
    @track composeTabLabel = 'Compose';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    caseRecord;

    @wire(getRecordUi, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    caseUi;

    get caseNumber() {
        return getFieldValue(this.caseRecord?.data, CASE_NUMBER) || '';
    }
    get subject() {
        return getFieldValue(this.caseRecord?.data, SUBJECT) || '';
    }
    get status() {
        return getFieldValue(this.caseRecord?.data, STATUS) || '';
    }
    get priority() {
        return getFieldValue(this.caseRecord?.data, PRIORITY) || '';
    }
    get ownerName() {
        const f = this.caseUi?.data?.record?.fields;
        return f?.OwnerId?.displayValue || f?.OwnerId?.value || '';
    }

    get isClosed() {
        const s = this.status ? String(this.status).toLowerCase() : '';
        return s === 'closed' || s === 'closed - complete' || s === 'closed - resolved';
    }

    toggleEdit() {
        this.isEditing = !this.isEditing;
    }

    handleEditSuccess() {
        this.isEditing = false;
        this.dispatchEvent(new ShowToastEvent({ title: 'Saved', message: 'Case updated', variant: 'success' }));
    }
    handleEditError() {
        // lightning-messages displays details
    }

    // Communication tab helpers
    handleCommTabSelect(event) {
        this.commActiveTab = event.detail.value;
    }
    showEmailsTab() {
        this.commActiveTab = 'emails';
    }

    handleEmailCount(event) {
        const count = event?.detail || 0;
        this.emailsTabLabel = count > 0 ? `Emails (${count})` : 'Emails';
    }

    handleEmailSent() {
        // after send, switch to Emails and ask the panel to refresh
        this.commActiveTab = 'emails';
        // Refresh child panel if present
        const panel = this.template.querySelector('c-case-email-panel');
        if (panel && panel.refresh) {
            panel.refresh();
        }
    }

    handleReply(event) {
        // event.detail: { to, subject, body }
        this.commActiveTab = 'compose';
        // Give DOM a tick to render compose tab content
        setTimeout(() => {
            const compose = this.template.querySelector('c-case-email-compose');
            if (compose && compose.prefillReply) {
                compose.prefillReply(event.detail);
            }
        }, 0);
    }

    openEmailComposer() {
        if (!this.recordId) return;
        // Attempt to open the standard Email quick action on Case
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: { apiName: 'Case.Email' }
        });
    }

    openEmailsRelated() {
        if (!this.recordId) return;
        // Navigate to Emails related list (Enhanced Email must be enabled)
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                relationshipApiName: 'EmailMessages',
                actionName: 'view'
            }
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
            this.dispatchEvent(new ShowToastEvent({ title: 'Deleted', message: 'Case deleted', variant: 'success' }));
            this[NavigationMixin.Navigate]({ type: 'standard__objectPage', attributes: { objectApiName: 'Case', actionName: 'home' } });
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Delete failed', message: e?.body?.message || 'Unable to delete', variant: 'error', mode: 'sticky' }));
        }
    }
}
