import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getFiles from '@salesforce/apex/RecordNotesAttachmentsController.getFiles';
import getNotes from '@salesforce/apex/RecordNotesAttachmentsController.getNotes';

export default class RecordNotesAttachments extends NavigationMixin(LightningElement) {
    @api recordId;
    // objectApiName no longer required (removed related-list button)

    files = [];
    notes = [];
    wiredFilesResult;
    wiredNotesResult;

    fileColumns = [
        { label: 'Title', fieldName: 'title', type: 'text' },
        { label: 'Type', fieldName: 'fileType', type: 'text', initialWidth: 100 },
        { label: 'Size (KB)', fieldName: 'sizeKb', type: 'number', initialWidth: 110 },
        { label: 'Created By', fieldName: 'createdByName', type: 'text' },
        { label: 'Created', fieldName: 'createdDate', type: 'date' },
        { type: 'action', typeAttributes: { rowActions: [
            { label: 'Preview', name: 'preview' },
            { label: 'Download', name: 'download' }
        ] } }
    ];

    noteColumns = [
        { label: 'Title', fieldName: 'title', type: 'text' },
        { label: 'Created By', fieldName: 'createdByName', type: 'text' },
        { label: 'Created', fieldName: 'createdDate', type: 'date' },
        { type: 'action', typeAttributes: { rowActions: [
            { label: 'View', name: 'view' }
        ] } }
    ];

    @wire(getFiles, { recordId: '$recordId' })
    wiredFiles(value) {
        this.wiredFilesResult = value;
        const { data, error } = value;
        if (data) {
            this.files = (data || []).map(f => ({
                ...f,
                sizeKb: f.contentSize ? Math.round(f.contentSize / 1024) : 0
            }));
        } else if (error) {
            this.showError(error);
        }
    }

    @wire(getNotes, { recordId: '$recordId' })
    wiredNotes(value) {
        this.wiredNotesResult = value;
        const { data, error } = value;
        if (data) {
            this.notes = data;
        } else if (error) {
            this.showError(error);
        }
    }

    async handleUploadFinished() {
        try {
            await Promise.all([
                refreshApex(this.wiredFilesResult),
                refreshApex(this.wiredNotesResult)
            ]);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Upload Complete',
                message: 'Files uploaded successfully',
                variant: 'success'
            }));
        } catch (error) {
            this.showError(error);
        }
    }

    handleFileRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        if (action === 'preview') {
            this.navigateToRecord(row.contentDocumentId, 'ContentDocument');
        } else if (action === 'download') {
            const url = `/sfc/servlet.shepherd/version/download/${row.contentVersionId}`;
            window.open(url, '_blank');
        }
    }

    handleNoteRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        if (action === 'view') {
            this.navigateToRecord(row.noteId, 'ContentNote');
        }
    }

    navigateToRecord(recordId, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName,
                actionName: 'view'
            }
        });
    }

    showError(error) {
        const message = (error && (error.body && error.body.message)) || error.message || 'An error occurred';
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message,
            variant: 'error',
            mode: 'sticky'
        }));
    }
}
