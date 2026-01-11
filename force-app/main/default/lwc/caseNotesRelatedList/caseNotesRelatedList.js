import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getNotes from '@salesforce/apex/CandidateNotesController.getNotes';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseNotesRelatedList extends LightningElement {
    @api recordId;
    notes = [];
    error;
    wiredNotesResult;
    refreshInterval;

    // Modal state
    @track isModalOpen = false;
    @track newNoteTitle = '';
    @track newNoteBody = '';
    @track saving = false;

    connectedCallback() {
        // Auto-refresh every 5 seconds
        this.refreshInterval = setInterval(() => {
            if (this.wiredNotesResult) {
                refreshApex(this.wiredNotesResult);
            }
        }, 5000);
    }

    disconnectedCallback() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }

    @wire(getNotes, { recordId: '$recordId' })
    wiredNotes(result) {
        this.wiredNotesResult = result;
        if (result.data) {
            this.notes = result.data || [];
            this.error = undefined;
        } else if (result.error) {
            // Keep UX simple; show message block
            // eslint-disable-next-line no-console
            console.error('Error loading notes:', result.error);
            this.error = result.error;
            this.notes = [];
        }
    }

    get hasNotes() {
        return Array.isArray(this.notes) && this.notes.length > 0;
    }

    get noteCount() {
        return this.notes ? this.notes.length : 0;
    }

    get errorMessage() {
        if (!this.error) return '';
        if (this.error.body && this.error.body.message) {
            return this.error.body.message;
        }
        if (this.error.message) {
            return this.error.message;
        }
        return 'Unknown error occurred';
    }

    // Open modal
    handleNewNote() {
        this.isModalOpen = true;
        this.newNoteTitle = '';
        this.newNoteBody = '';
        this.error = undefined;
    }

    // Close modal
    closeModal() {
        if (this.saving) return;
        this.isModalOpen = false;
    }

    // Prevent modal container clicks from closing
    stopPropagation(event) {
        event.stopPropagation();
    }

    handleTitleChange(event) {
        this.newNoteTitle = event.target.value;
    }

    handleBodyChange(event) {
        this.newNoteBody = event.target.value;
    }

    async saveNote() {
        if (this.saving) return;

        // Basic validation
        const title = (this.newNoteTitle || '').trim();
        const body = (this.newNoteBody || '').trim();
        if (!title || !body) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing information',
                    message: 'Please provide both a title and note content.',
                    variant: 'warning'
                })
            );
            return;
        }

        this.saving = true;
        try {
            // 1) Create ContentNote
            const noteInput = {
                apiName: 'ContentNote',
                fields: {
                    Title: title,
                    Content: body
                }
            };
            const noteResult = await createRecord(noteInput);
            const noteId = noteResult?.id;

            // 2) Link note to Case via ContentDocumentLink
            // In most orgs, ContentNote Id can be used as ContentDocumentId
            // If your org requires mapping, we can add a tiny Apex helper later.
            const linkInput = {
                apiName: 'ContentDocumentLink',
                fields: {
                    LinkedEntityId: this.recordId,
                    ContentDocumentId: noteId,
                    ShareType: 'V',
                    Visibility: 'AllUsers'
                }
            };
            await createRecord(linkInput);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Note created',
                    message: 'Your note has been added to this case.',
                    variant: 'success'
                })
            );

            // Refresh list and close
            if (this.wiredNotesResult) {
                await refreshApex(this.wiredNotesResult);
            }
            this.isModalOpen = false;
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error('Error creating note/link:', e);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating note',
                    message: e?.body?.message || e?.message || 'Unknown error',
                    variant: 'error'
                })
            );
        } finally {
            this.saving = false;
        }
    }
}
