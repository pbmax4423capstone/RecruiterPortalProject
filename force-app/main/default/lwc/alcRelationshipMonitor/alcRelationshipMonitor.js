import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelationshipGaps from '@salesforce/apex/ALCRelationshipController.getRelationshipGaps';
import getCandidatesWithoutContacts from '@salesforce/apex/ALCRelationshipController.getCandidatesWithoutContacts';
import getRecentAuditLogs from '@salesforce/apex/ALCRelationshipController.getRecentAuditLogs';
import fixCandidateContact from '@salesforce/apex/ALCRelationshipController.fixCandidateContact';
import markLogResolved from '@salesforce/apex/ALCRelationshipController.markLogResolved';

const CANDIDATE_COLUMNS = [
    {
        label: 'Candidate Name',
        fieldName: 'candidateUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'candidateName' },
            target: '_blank'
        }
    },
    { label: 'First Name', fieldName: 'firstName', type: 'text' },
    { label: 'Last Name', fieldName: 'lastName', type: 'text' },
    { label: 'Email', fieldName: 'email', type: 'email' },
    {
        label: 'Related ALC',
        fieldName: 'alcUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'alcName' },
            target: '_blank'
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Create Contact', name: 'create_contact' }
            ]
        }
    }
];

const AUDIT_LOG_COLUMNS = [
    {
        label: 'Name',
        fieldName: 'logUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }
    },
    { label: 'Operation Type', fieldName: 'Operation_Type__c', type: 'text' },
    {
        label: 'Success',
        fieldName: 'Success__c',
        type: 'boolean',
        cellAttributes: {
            iconName: { fieldName: 'statusIcon' },
            iconVariant: { fieldName: 'statusVariant' }
        }
    },
    {
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'View Details', name: 'view_details' },
                { label: 'Mark Resolved', name: 'mark_resolved' }
            ]
        }
    }
];

export default class AlcRelationshipMonitor extends LightningElement {
    @track autoRefreshEnabled = true;
    @track isRefreshing = false;
    @track showResolveModal = false;
    @track showLogDetailModal = false;
    @track selectedLogId = null;
    @track selectedLog = null;
    @track resolutionNotes = '';
    @track isSaving = false;
    @track currentFilter = 'all';
    @track currentPage = 1;
    @track pageSize = 10;

    candidateColumns = CANDIDATE_COLUMNS;
    auditLogColumns = AUDIT_LOG_COLUMNS;

    refreshInterval = 300000; // 5 minutes
    intervalId = null;

    // Wire results for refreshApex
    wiredRelationshipGapsResult;
    wiredCandidatesResult;
    wiredAuditLogsResult;

    @track relationshipGaps = [];
    @track candidatesWithoutContacts = [];
    @track auditLogs = [];
    @track allAuditLogs = [];

    @wire(getRelationshipGaps)
    wiredRelationshipGaps(result) {
        this.wiredRelationshipGapsResult = result;
        if (result.data) {
            this.relationshipGaps = result.data.map(gap => ({
                ...gap,
                withoutContactClass: gap.withoutContact > 0 ? 'badge-error' : 'badge-success',
                withoutCandidateClass: gap.withoutCandidate > 0 ? 'badge-error' : 'badge-success',
                listViewUrl: this.buildListViewUrl(gap.recordType)
            }));
        } else if (result.error) {
            this.showToast('Error', 'Failed to load relationship gaps', 'error');
            console.error('Error loading relationship gaps:', result.error);
        }
    }

    @wire(getCandidatesWithoutContacts, { limitRows: 100 })
    wiredCandidates(result) {
        this.wiredCandidatesResult = result;
        if (result.data) {
            this.candidatesWithoutContacts = result.data.map(candidate => ({
                ...candidate,
                candidateUrl: `/${candidate.Id}`,
                candidateName: candidate.Name,
                firstName: candidate.First_Name__c,
                lastName: candidate.Last_Name__c,
                email: candidate.Email__c,
                alcUrl: candidate.alcId ? `/${candidate.alcId}` : null,
                alcName: candidate.alcName || 'N/A'
            }));
        } else if (result.error) {
            this.showToast('Error', 'Failed to load candidates', 'error');
            console.error('Error loading candidates:', result.error);
        }
    }

    @wire(getRecentAuditLogs, { limitRows: 200 })
    wiredAuditLogs(result) {
        this.wiredAuditLogsResult = result;
        if (result.data) {
            this.allAuditLogs = result.data.map(log => ({
                ...log,
                logUrl: `/${log.Id}`,
                statusIcon: log.Success__c ? 'utility:success' : 'utility:error',
                statusVariant: log.Success__c ? 'success' : 'error',
                statusText: log.Success__c ? 'Success' : 'Error'
            }));
            this.applyFilter();
        } else if (result.error) {
            this.showToast('Error', 'Failed to load audit logs', 'error');
            console.error('Error loading audit logs:', result.error);
        }
    }

    connectedCallback() {
        this.startAutoRefresh();
    }

    disconnectedCallback() {
        this.stopAutoRefresh();
    }

    startAutoRefresh() {
        if (this.autoRefreshEnabled && !this.intervalId) {
            this.intervalId = setInterval(() => {
                this.refreshAllData();
            }, this.refreshInterval);
        }
    }

    stopAutoRefresh() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }

    handleAutoRefreshToggle(event) {
        this.autoRefreshEnabled = event.target.checked;
        if (this.autoRefreshEnabled) {
            this.startAutoRefresh();
            this.showToast('Auto-refresh Enabled', 'Data will refresh every 5 minutes', 'success');
        } else {
            this.stopAutoRefresh();
            this.showToast('Auto-refresh Disabled', 'Manual refresh required', 'info');
        }
    }

    async handleRefresh() {
        await this.refreshAllData();
    }

    async refreshAllData() {
        this.isRefreshing = true;
        try {
            await Promise.all([
                refreshApex(this.wiredRelationshipGapsResult),
                refreshApex(this.wiredCandidatesResult),
                refreshApex(this.wiredAuditLogsResult)
            ]);
            this.showToast('Success', 'Data refreshed successfully', 'success');
        } catch (error) {
            this.showToast('Error', 'Failed to refresh data', 'error');
            console.error('Error refreshing data:', error);
        } finally {
            this.isRefreshing = false;
        }
    }

    async handleCandidateRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'create_contact') {
            await this.handleFixCandidate(row.Id);
        }
    }

    async handleFixCandidate(candidateId) {
        this.isRefreshing = true;
        try {
            const result = await fixCandidateContact({ candidateId });
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                await this.refreshAllData();
            } else {
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Failed to create contact: ' + this.reduceError(error), 'error');
            console.error('Error creating contact:', error);
        } finally {
            this.isRefreshing = false;
        }
    }

    handleAuditLogRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'mark_resolved') {
            this.selectedLogId = row.Id;
            this.selectedLog = row;
            this.showResolveModal = true;
            this.resolutionNotes = '';
        } else if (actionName === 'view_details') {
            this.selectedLogId = row.Id;
            this.selectedLog = row;
            this.showLogDetailModal = true;
        }
    }

    handleResolutionNotesChange(event) {
        this.resolutionNotes = event.target.value;
    }

    async handleSaveResolution() {
        if (!this.resolutionNotes) {
            this.showToast('Error', 'Please enter resolution notes', 'error');
            return;
        }

        this.isSaving = true;
        try {
            await markLogResolved({
                logId: this.selectedLogId,
                resolutionNotes: this.resolutionNotes
            });
            this.showToast('Success', 'Log marked as resolved', 'success');
            this.showResolveModal = false;
            this.resolutionNotes = '';
            this.selectedLogId = null;
            await refreshApex(this.wiredAuditLogsResult);
        } catch (error) {
            this.showToast('Error', 'Failed to mark log as resolved: ' + this.reduceError(error), 'error');
            console.error('Error marking log as resolved:', error);
        } finally {
            this.isSaving = false;
        }
    }

    handleCancelResolution() {
        this.showResolveModal = false;
        this.resolutionNotes = '';
        this.selectedLogId = null;
        this.selectedLog = null;
    }

    handleCloseLogDetail() {
        this.showLogDetailModal = false;
        this.selectedLogId = null;
        this.selectedLog = null;
    }

    handleFilterAll() {
        this.currentFilter = 'all';
        this.currentPage = 1;
        this.applyFilter();
    }

    handleFilterErrors() {
        this.currentFilter = 'errors';
        this.currentPage = 1;
        this.applyFilter();
    }

    handleFilterLast7Days() {
        this.currentFilter = 'last7';
        this.currentPage = 1;
        this.applyFilter();
    }

    handleFilterLast30Days() {
        this.currentFilter = 'last30';
        this.currentPage = 1;
        this.applyFilter();
    }

    applyFilter() {
        let filtered = [...this.allAuditLogs];

        if (this.currentFilter === 'errors') {
            filtered = filtered.filter(log => !log.Success__c);
        } else if (this.currentFilter === 'last7') {
            const sevenDaysAgo = new Date();
            sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
            filtered = filtered.filter(log => new Date(log.CreatedDate) >= sevenDaysAgo);
        } else if (this.currentFilter === 'last30') {
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
            filtered = filtered.filter(log => new Date(log.CreatedDate) >= thirtyDaysAgo);
        }

        this.auditLogs = filtered;
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    buildListViewUrl(recordType) {
        // Build a URL to the ALC list view filtered by record type
        const baseUrl = window.location.origin;
        return `${baseUrl}/lightning/o/ALC__c/list?filterName=Recent`;
    }

    get hasCandidatesWithoutContacts() {
        return this.candidatesWithoutContacts && this.candidatesWithoutContacts.length > 0;
    }

    get candidateCount() {
        return this.candidatesWithoutContacts ? this.candidatesWithoutContacts.length : 0;
    }

    get hasAuditLogs() {
        return this.filteredAuditLogs && this.filteredAuditLogs.length > 0;
    }

    get filteredAuditLogs() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.auditLogs.slice(start, end);
    }

    get totalPages() {
        return Math.ceil(this.auditLogs.length / this.pageSize);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage >= this.totalPages;
    }

    get allButtonVariant() {
        return this.currentFilter === 'all' ? 'brand' : 'neutral';
    }

    get errorsButtonVariant() {
        return this.currentFilter === 'errors' ? 'brand' : 'neutral';
    }

    get last7ButtonVariant() {
        return this.currentFilter === 'last7' ? 'brand' : 'neutral';
    }

    get last30ButtonVariant() {
        return this.currentFilter === 'last30' ? 'brand' : 'neutral';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    reduceError(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        } else if (typeof error === 'string') {
            return error;
        }
        return 'Unknown error';
    }
}
