import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { refreshApex } from '@salesforce/apex';

import EM_SUBJECT from '@salesforce/schema/EmailMessage.Subject';
import EM_FROM from '@salesforce/schema/EmailMessage.FromAddress';
import EM_TO from '@salesforce/schema/EmailMessage.ToAddress';
import EM_DATE from '@salesforce/schema/EmailMessage.MessageDate';
import EM_HTML from '@salesforce/schema/EmailMessage.HtmlBody';
import EM_TEXT from '@salesforce/schema/EmailMessage.TextBody';

const PREVIEW_FIELDS = [EM_SUBJECT, EM_FROM, EM_TO, EM_DATE, EM_HTML, EM_TEXT];

export default class CaseEmailPanel extends NavigationMixin(LightningElement) {
    @api recordId; // Case Id

    @track rows = [];
    @track sortedBy = 'MessageDate';
    @track sortedDirection = 'desc';
    @track selected = null;
    selectedEmailId;
    listWireResultPrimary;
    listWireResultSecondary;
    dataSource = null; // 'Emails' or 'EmailMessages'
    primaryLoaded = false;
    secondaryLoaded = false;

    columns = [
        { label: 'Subject', fieldName: 'Subject', type: 'text', sortable: true },
        { label: 'From', fieldName: 'FromAddress', type: 'email', sortable: true },
        { label: 'Date', fieldName: 'MessageDate', type: 'date', sortable: true },
        {
            type: 'action', typeAttributes: { rowActions: [
                { label: 'Preview', name: 'preview' },
                { label: 'Open', name: 'open' }
            ]}
        }
    ];

    // Primary attempt: 'Emails' related list
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Emails',
        fields: ['EmailMessage.Id','EmailMessage.Subject','EmailMessage.FromAddress','EmailMessage.ToAddress','EmailMessage.MessageDate'],
        sortBy: ['EmailMessage.MessageDate DESC'],
        pageSize: 50
    })
    listWirePrimary(result) {
        this.primaryLoaded = true;
        this.listWireResultPrimary = result;
        this.handleListResult(result, 'Emails');
        this.maybeFallback();
    }

    // Fallback attempt: 'EmailMessages' related list
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'EmailMessages',
        fields: ['EmailMessage.Id','EmailMessage.Subject','EmailMessage.FromAddress','EmailMessage.ToAddress','EmailMessage.MessageDate'],
        sortBy: ['EmailMessage.MessageDate DESC'],
        pageSize: 50
    })
    listWireSecondary(result) {
        this.secondaryLoaded = true;
        this.listWireResultSecondary = result;
        // Only adopt if we don't already have rows
        if (!this.rows || this.rows.length === 0) {
            this.handleListResult(result, 'EmailMessages');
        }
        this.maybeFallback();
    }

    handleListResult(result, source) {
        const { data } = result;
        if (data) {
            const records = data.records || [];
            const mapped = records.map(r => ({
                Id: r.id,
                Subject: r.fields?.Subject?.value,
                FromAddress: r.fields?.FromAddress?.value,
                ToAddress: r.fields?.ToAddress?.value,
                MessageDate: r.fields?.MessageDate?.value
            }));
            if (mapped.length > 0) {
                this.rows = mapped;
                this.dataSource = source;
                this.selectedEmailId = mapped[0].Id;
            }
        }
    }

    maybeFallback() {
        // No-op fallback; if both related lists are empty, panel remains empty.
        // This typically indicates Enhanced Email is disabled or no Emails exist for this Case.
    }

    @wire(getRecord, { recordId: '$selectedEmailId', fields: PREVIEW_FIELDS })
    emailWire({ data }) {
        if (data) {
            const f = data.fields || {};
            this.selected = {
                Id: this.selectedEmailId,
                Subject: f.Subject?.value,
                FromAddress: f.FromAddress?.value,
                ToAddress: f.ToAddress?.value,
                MessageDate: f.MessageDate?.value,
                HtmlBody: f.HtmlBody?.value,
                TextBody: f.TextBody?.value
            };
        } else {
            this.selected = null;
        }
    }

    refresh = () => {
        if (this.dataSource === 'Emails' && this.listWireResultPrimary) {
            refreshApex(this.listWireResultPrimary);
        } else if (this.dataSource === 'EmailMessages' && this.listWireResultSecondary) {
            refreshApex(this.listWireResultSecondary);
        } else {
            if (this.listWireResultPrimary) refreshApex(this.listWireResultPrimary);
            if (this.listWireResultSecondary) refreshApex(this.listWireResultSecondary);
        }
    };

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        if (action === 'preview') {
            this.selectedEmailId = row.Id;
        } else if (action === 'open') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: row.Id, actionName: 'view', objectApiName: 'EmailMessage' }
            });
        }
    }

    handleRowSelect(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows && selectedRows[0]) {
            this.selectedEmailId = selectedRows[0].Id;
        }
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        const clone = [...this.rows];
        clone.sort((a,b) => {
            const av = a[fieldName];
            const bv = b[fieldName];
            if (av === bv) return 0;
            if (av > bv) return sortDirection === 'asc' ? 1 : -1;
            return sortDirection === 'asc' ? -1 : 1;
        });
        this.rows = clone;
    }

    reply() {
        const s = this.selected;
        if (!s) return;
        const payload = {
            to: s.FromAddress,
            subject: s.Subject,
            body: s.HtmlBody || s.TextBody || ''
        };
        this.dispatchEvent(new CustomEvent('reply', { detail: payload, bubbles: true, composed: true }));
    }

    set rows(val) {
        this._rows = val;
        const count = Array.isArray(val) ? val.length : 0;
        this.dispatchEvent(new CustomEvent('emailcount', { detail: count, bubbles: true, composed: true }));
    }
    get rows() { return this._rows || []; }

    // Removed Apex fallback to avoid dependency on missing controller
}
