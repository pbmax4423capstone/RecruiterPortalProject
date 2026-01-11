import { LightningElement, api, track, wire } from 'lwc';
import search from '@salesforce/apex/KnowledgeSearchController.search';
import suggestByCase from '@salesforce/apex/KnowledgeSearchController.suggestByCase';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

const CASE_FIELDS = ['Case.Description'];

export default class KnowledgeSearchCard extends NavigationMixin(LightningElement) {
    @api recordId; // Case Id for context
    @track articles = [];
    @track searchText = '';
    @track isLoading = false;
    caseDescription = '';

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    wiredCase({ data }) {
        if (data) {
            this.caseDescription = data.fields?.Description?.value || '';
        }
    }

    connectedCallback() {
        this.loadSuggestions();
    }

    async loadSuggestions() {
        if (!this.recordId) return;
        this.isLoading = true;
        try {
            const res = await suggestByCase({ caseId: this.recordId, limitSize: 10 });
            this.articles = res || [];
        } catch (e) {
            // swallow errors from suggestion fetch
            this.articles = [];
        } finally {
            this.isLoading = false;
        }
    }

    handleSearchChange(event) {
        this.searchText = event.target.value;
    }

    handleKeyup(event) {
        if (event.key === 'Enter') {
            this.runSearch();
        }
    }

    async runSearch() {
        this.isLoading = true;
        try {
            const res = await search({ query: this.searchText, limitSize: 10, language: null });
            this.articles = res || [];
        } catch (e) {
            this.articles = [];
        } finally {
            this.isLoading = false;
        }
    }

    async useDescription() {
        if (!this.caseDescription) {
            return;
        }
        this.searchText = this.caseDescription;
        await this.runSearch();
    }

    navigateToArticle(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Knowledge__kav',
                actionName: 'view'
            }
        });
    }
}
