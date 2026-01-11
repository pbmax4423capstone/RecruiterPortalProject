import { LightningElement, api, track, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseCommentsPanel extends LightningElement {
    @api recordId; // Case Id

    @track rows = [];
    @track sortedBy = 'CreatedDate';
    @track sortedDirection = 'desc';
    @track isModalOpen = false;
    listWireResult;
    isDictating = false;
    dictationSupported = false;
    recognition;

    columns = [
        { label: 'User', fieldName: 'UserName', type: 'text' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true },
        { label: 'Comment', fieldName: 'CommentBody', type: 'text' }
    ];

    get rowsEmpty() {
        return !this.rows || this.rows.length === 0;
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'CaseComments',
        fields: [
            'CaseComment.Id',
            'CaseComment.CommentBody',
            'CaseComment.CreatedDate',
            'CaseComment.CreatedBy.Name'
        ],
        sortBy: ['CaseComment.CreatedDate DESC'],
        pageSize: 50
    })
    wiredList(result) {
        this.listWireResult = result;
        const { data, error } = result;
        if (data) {
            const recs = data.records || [];
            this.rows = recs.map(r => ({
                Id: r.id,
                CommentBody: r.fields?.CommentBody?.value,
                CreatedDate: r.fields?.CreatedDate?.value,
                UserName: r.fields?.CreatedBy?.displayValue || r.fields?.CreatedBy?.value
            }));
        } else if (error) {
            this.rows = [];
        }
    }

    connectedCallback() {
        const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (SR) {
            this.dictationSupported = true;
            this.recognition = new SR();
            this.recognition.lang = 'en-US';
            this.recognition.interimResults = false;
            this.recognition.continuous = false;
            this.recognition.onresult = (event) => {
                let transcript = '';
                for (let i = event.resultIndex; i < event.results.length; i++) {
                    if (event.results[i].isFinal) {
                        transcript += event.results[i][0].transcript;
                    }
                }
                if (transcript) {
                    const field = this.template.querySelector('lightning-input-field[field-name="CommentBody"]');
                    if (field) {
                        const existing = field.value || '';
                        field.value = existing ? `${existing}\n${transcript.trim()}` : transcript.trim();
                    }
                }
            };
            this.recognition.onend = () => { this.isDictating = false; };
        }
    }

    disconnectedCallback() {
        if (this.recognition && this.isDictating) {
            try { this.recognition.stop(); } catch (e) { /* noop */ }
        }
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        const sorted = [...this.rows].sort((a,b) => {
            const av = a[fieldName];
            const bv = b[fieldName];
            if (av === bv) return 0;
            if (av > bv) return sortDirection === 'asc' ? 1 : -1;
            return sortDirection === 'asc' ? -1 : 1;
        });
        this.rows = sorted;
    }

    openNewModal = () => { this.isModalOpen = true; };
    closeModal = () => { this.isModalOpen = false; };

    toggleDictation() {
        if (!this.dictationSupported) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Not supported', message: 'Speech recognition is not supported in this browser.', variant: 'warning' }));
            return;
        }
        if (!this.isDictating) {
            this.isDictating = true;
            try { this.recognition.start(); } catch (e) { /* ignore */ }
        } else {
            this.isDictating = false;
            try { this.recognition.stop(); } catch (e) { /* noop */ }
        }
    }

    handleSubmit(event) {
        // Ensure ParentId is set to the Case
        event.preventDefault();
        const fields = { ...event.detail.fields, ParentId: this.recordId };
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    async handleSuccess() {
        this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: 'Comment added', variant: 'success' }));
        this.isModalOpen = false;
        if (this.listWireResult) {
            await refreshApex(this.listWireResult);
        }
    }

    handleError(event) {
        const msg = event?.detail?.message || 'Unable to save comment';
        this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: msg, variant: 'error', mode: 'sticky' }));
    }
}
