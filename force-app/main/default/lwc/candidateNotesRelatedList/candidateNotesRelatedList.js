import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getNotes from '@salesforce/apex/CandidateNotesController.getNotes';

export default class CandidateNotesRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    notes = [];
    error;
    wiredNotesResult;
    refreshInterval;

    connectedCallback() {
        // Auto-refresh every 5 seconds
        this.refreshInterval = setInterval(() => {
            if (this.wiredNotesResult) {
                refreshApex(this.wiredNotesResult);
            }
        }, 5000);
    }

    disconnectedCallback() {
        // Clear interval when component is destroyed
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
        // Extract detailed error message
        if (this.error.body && this.error.body.message) {
            return this.error.body.message;
        }
        if (this.error.message) {
            return this.error.message;
        }
        return 'Unknown error occurred';
    }

    handleNewNote() {
        // Navigate to create new note related to this candidate
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ContentNote',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: `ParentId=${this.recordId}`
            }
        });
    }
}