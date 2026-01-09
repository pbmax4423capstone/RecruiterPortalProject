import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getUnlinkedALCs from '@salesforce/apex/ALCBackfillWizardController.getUnlinkedALCs';
import getMatchingContacts from '@salesforce/apex/ALCBackfillWizardController.getMatchingContacts';
import processBackfillBatch from '@salesforce/apex/ALCBackfillWizardController.processBackfillBatch';

const COLUMNS = [
    { label: 'ALC Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'First Name', fieldName: 'First_Name__c', type: 'text', sortable: true },
    { label: 'Last Name', fieldName: 'Last_Name__c', type: 'text', sortable: true },
    { label: 'Email', fieldName: 'Email__c', type: 'email', sortable: true },
    { label: 'Phone', fieldName: 'Phone__c', type: 'phone', sortable: true },
    { label: 'Record Type', fieldName: 'RecordTypeName', type: 'text', sortable: true },
    { 
        label: 'Has Contact', 
        fieldName: 'HasContact', 
        type: 'boolean',
        cellAttributes: { iconName: { fieldName: 'contactIcon' }, iconPosition: 'left' }
    },
    { 
        label: 'Has Candidate', 
        fieldName: 'HasCandidate', 
        type: 'boolean',
        cellAttributes: { iconName: { fieldName: 'candidateIcon' }, iconPosition: 'left' }
    }
];

export default class AlcRelationshipBackfillWizard extends LightningElement {
    columns = COLUMNS;
    
    @track activeTab = 'All';
    @track unlinkedAlcs = [];
    @track filteredAlcs = [];
    @track selectedRecords = [];
    @track matchResults = {};
    @track currentAlc = null;
    @track matchOptions = [];
    @track selectedContactId = null;
    @track showMatchModal = false;
    @track loadingMatches = false;
    @track processing = false;
    @track showResults = false;
    @track results = {
        contactsCreated: 0,
        candidatesCreated: 0,
        alcsUpdated: 0,
        errors: 0,
        details: [],
        errorMessages: []
    };
    @track progressValue = 0;
    @track progressMessage = '';
    @track batchDecisions = [];
    
    wiredAlcsResult;

    // Wire to get unlinked ALCs
    @wire(getUnlinkedALCs)
    wiredUnlinkedALCs(result) {
        this.wiredAlcsResult = result;
        if (result.data) {
            this.unlinkedAlcs = result.data.map(alc => ({
                ...alc,
                RecordTypeName: alc.RecordType?.Name || 'Unknown',
                HasContact: !!alc.Contact__c,
                HasCandidate: !!alc.Candidate__c,
                contactIcon: alc.Contact__c ? 'utility:success' : 'utility:close',
                candidateIcon: alc.Candidate__c ? 'utility:success' : 'utility:close'
            }));
            this.filterAlcsByTab();
        } else if (result.error) {
            this.showToast('Error', 'Failed to load unlinked ALCs: ' + this.getErrorMessage(result.error), 'error');
            this.unlinkedAlcs = [];
            this.filteredAlcs = [];
        }
    }

    // Computed properties
    get hasUnlinkedAlcs() {
        return this.filteredAlcs && this.filteredAlcs.length > 0;
    }

    get disableFindMatches() {
        return this.processing || this.selectedRecords.length === 0;
    }

    get disableProcessButton() {
        return this.processing || this.batchDecisions.length === 0;
    }

    get confirmDisabled() {
        return this.loadingMatches || !this.selectedContactId;
    }

    get hasMatches() {
        return this.matchOptions && this.matchOptions.length > 1; // More than just "Create New"
    }

    get matchCount() {
        return this.matchOptions ? this.matchOptions.length - 1 : 0; // Exclude "Create New" option
    }

    get hasResultDetails() {
        return this.results.details && this.results.details.length > 0;
    }

    get hasErrorMessages() {
        return this.results.errorMessages && this.results.errorMessages.length > 0;
    }

    get allTabLabel() {
        const count = this.getCountForTab('All');
        return `All (${count})`;
    }

    get careerTabLabel() {
        const count = this.getCountForTab('Career');
        return `Career (${count})`;
    }

    get brokerTabLabel() {
        const count = this.getCountForTab('Broker');
        return `Broker (${count})`;
    }

    get nrfTabLabel() {
        const count = this.getCountForTab('NRF');
        return `NRF (${count})`;
    }

    get registrationTabLabel() {
        const count = this.getCountForTab('Registration');
        return `Registration (${count})`;
    }

    getCountForTab(tabValue) {
        if (!this.unlinkedAlcs) return 0;
        if (tabValue === 'All') return this.unlinkedAlcs.length;
        return this.unlinkedAlcs.filter(alc => alc.RecordTypeName === tabValue).length;
    }

    // Handle tab change
    handleTabChange(event) {
        this.activeTab = event.target.value;
        this.filterAlcsByTab();
        this.selectedRecords = [];
        this.batchDecisions = [];
    }

    filterAlcsByTab() {
        if (this.activeTab === 'All') {
            this.filteredAlcs = [...this.unlinkedAlcs];
        } else {
            this.filteredAlcs = this.unlinkedAlcs.filter(
                alc => alc.RecordTypeName === this.activeTab
            );
        }
    }

    // Handle row selection
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRecords = selectedRows.map(row => ({
            Id: row.Id,
            Name: row.Name,
            First_Name__c: row.First_Name__c,
            Last_Name__c: row.Last_Name__c,
            Email__c: row.Email__c,
            Phone__c: row.Phone__c,
            RecordTypeName: row.RecordTypeName,
            Contact__c: row.Contact__c,
            Candidate__c: row.Candidate__c
        }));
    }

    // Show matches modal
    async handleShowMatches() {
        if (this.selectedRecords.length === 0) {
            this.showToast('Warning', 'Please select at least one ALC record.', 'warning');
            return;
        }

        // Start with first selected record
        this.currentAlc = this.selectedRecords[0];
        this.showMatchModal = true;
        this.loadingMatches = true;
        this.selectedContactId = 'CREATE_NEW';

        try {
            const matches = await getMatchingContacts({ alcId: this.currentAlc.Id });
            this.buildMatchOptions(matches);
        } catch (error) {
            this.showToast('Error', 'Failed to find matches: ' + this.getErrorMessage(error), 'error');
            this.closeModal();
        } finally {
            this.loadingMatches = false;
        }
    }

    buildMatchOptions(matches) {
        const options = [];
        
        if (matches && matches.length > 0) {
            matches.forEach(match => {
                const similarityPercent = Math.round(match.similarity * 100);
                const label = `${match.FirstName} ${match.LastName} - ${match.Email || 'No Email'} (${similarityPercent}% match)`;
                
                options.push({
                    label: label,
                    value: match.Id,
                    similarity: match.similarity
                });
            });
        }

        // Always add "Create New Contact" option
        options.push({
            label: '➕ Create New Contact',
            value: 'CREATE_NEW',
            similarity: 0
        });

        this.matchOptions = options;
    }

    // Handle match selection in modal
    handleMatchSelection(event) {
        this.selectedContactId = event.detail.value;
    }

    // Confirm match and move to next or close
    handleConfirmMatch() {
        if (!this.selectedContactId) {
            this.showToast('Warning', 'Please select a contact or choose to create new.', 'warning');
            return;
        }

        // Store decision
        this.batchDecisions.push({
            alcId: this.currentAlc.Id,
            alcName: this.currentAlc.Name,
            contactId: this.selectedContactId === 'CREATE_NEW' ? null : this.selectedContactId,
            createNew: this.selectedContactId === 'CREATE_NEW'
        });

        // Find next unprocessed ALC
        const processedIds = this.batchDecisions.map(d => d.alcId);
        const nextAlc = this.selectedRecords.find(alc => !processedIds.includes(alc.Id));

        if (nextAlc) {
            // Move to next ALC
            this.loadNextAlc(nextAlc);
        } else {
            // All done, close modal
            this.closeModal();
            this.showToast('Success', `${this.batchDecisions.length} decisions recorded. Click "Process Selected" to apply changes.`, 'success');
        }
    }

    async loadNextAlc(alc) {
        this.currentAlc = alc;
        this.loadingMatches = true;
        this.selectedContactId = 'CREATE_NEW';

        try {
            const matches = await getMatchingContacts({ alcId: alc.Id });
            this.buildMatchOptions(matches);
        } catch (error) {
            this.showToast('Error', 'Failed to find matches: ' + this.getErrorMessage(error), 'error');
            this.closeModal();
        } finally {
            this.loadingMatches = false;
        }
    }

    closeModal() {
        this.showMatchModal = false;
        this.currentAlc = null;
        this.matchOptions = [];
        this.selectedContactId = null;
        this.loadingMatches = false;
    }

    // Process batch
    async handleProcessBatch() {
        if (this.batchDecisions.length === 0) {
            this.showToast('Warning', 'No decisions to process. Please use "Find Matches" first.', 'warning');
            return;
        }

        this.processing = true;
        this.showResults = false;
        this.progressValue = 0;
        this.progressMessage = 'Processing batch...';

        try {
            // Call Apex method
            const result = await processBackfillBatch({ decisions: this.batchDecisions });
            
            this.results = {
                contactsCreated: result.contactsCreated || 0,
                candidatesCreated: result.candidatesCreated || 0,
                alcsUpdated: result.alcsUpdated || 0,
                errors: result.errors || 0,
                details: result.details || [],
                errorMessages: result.errorMessages || []
            };

            this.progressValue = 100;
            this.progressMessage = 'Processing complete!';
            this.showResults = true;

            // Show toast
            if (result.errors === 0) {
                this.showToast('Success', `Successfully processed ${result.alcsUpdated} ALCs!`, 'success');
            } else {
                this.showToast('Warning', `Processed with ${result.errors} errors. See details below.`, 'warning');
            }

            // Refresh data
            await refreshApex(this.wiredAlcsResult);
            
            // Reset selections
            this.selectedRecords = [];
            this.batchDecisions = [];

        } catch (error) {
            this.showToast('Error', 'Batch processing failed: ' + this.getErrorMessage(error), 'error');
            this.results = {
                contactsCreated: 0,
                candidatesCreated: 0,
                alcsUpdated: 0,
                errors: 1,
                details: [],
                errorMessages: [this.getErrorMessage(error)]
            };
            this.showResults = true;
        } finally {
            this.processing = false;
        }
    }

    // Export results as CSV
    handleExportResults() {
        if (!this.showResults) {
            this.showToast('Warning', 'No results to export.', 'warning');
            return;
        }

        const csvRows = [];
        csvRows.push(['Metric', 'Count'].join(','));
        csvRows.push(['Contacts Created', this.results.contactsCreated].join(','));
        csvRows.push(['Candidates Created', this.results.candidatesCreated].join(','));
        csvRows.push(['ALCs Updated', this.results.alcsUpdated].join(','));
        csvRows.push(['Errors', this.results.errors].join(','));
        csvRows.push([]);
        
        if (this.hasResultDetails) {
            csvRows.push(['Details']);
            this.results.details.forEach(detail => {
                csvRows.push([detail]);
            });
            csvRows.push([]);
        }

        if (this.hasErrorMessages) {
            csvRows.push(['Error Messages']);
            this.results.errorMessages.forEach(error => {
                csvRows.push([error]);
            });
        }

        const csvContent = csvRows.join('\n');
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        
        link.setAttribute('href', url);
        link.setAttribute('download', `alc-backfill-results-${timestamp}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        this.showToast('Success', 'Results exported successfully!', 'success');
    }

    // Utility methods
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    getErrorMessage(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        } else if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        }
        return 'Unknown error occurred';
    }
}
