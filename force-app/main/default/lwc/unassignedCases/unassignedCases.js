import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getUnassignedCases from '@salesforce/apex/UnassignedCasesController.getUnassignedCases';
import assignCaseToCurrentUser from '@salesforce/apex/UnassignedCasesController.assignCaseToCurrentUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class UnassignedCases extends NavigationMixin(LightningElement) {
    @api darkMode = false;
    @track cases = [];
    @track isLoading = true;
    @track error = null;
    @track selectedCaseId = null;
    @track showCompactView = false;
    @track showCaseModal = false;
    
    wiredCasesResult;

    @wire(getUnassignedCases)
    wiredCases(result) {
        this.wiredCasesResult = result;
        if (result.data) {
            this.cases = result.data.map(caseRecord => ({
                ...caseRecord,
                priorityClass: this.getPriorityClass(caseRecord.Priority),
                statusClass: this.getStatusClass(caseRecord.Status),
                timeAgo: this.getTimeAgo(caseRecord.CreatedDate),
                hasSubject: !!caseRecord.Subject,
                truncatedSubject: this.truncateText(caseRecord.Subject, 60)
            }));
            this.isLoading = false;
            this.error = null;
        } else if (result.error) {
            this.error = result.error;
            this.isLoading = false;
            this.cases = [];
        }
    }

    get hasCases() {
        return this.cases && this.cases.length > 0;
    }

    get containerClass() {
        return this.darkMode ? 'unassigned-cases-container dark-mode' : 'unassigned-cases-container';
    }

    get totalCases() {
        return this.cases ? this.cases.length : 0;
    }

    get viewToggleIcon() {
        return this.showCompactView ? 'utility:expand_alt' : 'utility:contract_alt';
    }

    get viewToggleLabel() {
        return this.showCompactView ? 'Expanded View' : 'Compact View';
    }

    getPriorityClass(priority) {
        switch (priority?.toLowerCase()) {
            case 'high':
                return 'priority-high';
            case 'medium':
                return 'priority-medium';
            case 'low':
                return 'priority-low';
            default:
                return 'priority-default';
        }
    }

    getStatusClass(status) {
        switch (status?.toLowerCase()) {
            case 'new':
                return 'status-new';
            case 'working':
                return 'status-working';
            case 'escalated':
                return 'status-escalated';
            default:
                return 'status-default';
        }
    }

    getTimeAgo(createdDate) {
        if (!createdDate) return 'Unknown';
        
        const now = new Date();
        const created = new Date(createdDate);
        const diffInMinutes = Math.floor((now - created) / (1000 * 60));
        
        if (diffInMinutes < 1) return 'Just now';
        if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
        
        const diffInHours = Math.floor(diffInMinutes / 60);
        if (diffInHours < 24) return `${diffInHours}h ago`;
        
        const diffInDays = Math.floor(diffInHours / 24);
        return `${diffInDays}d ago`;
    }

    truncateText(text, maxLength) {
        if (!text || text.length <= maxLength) return text;
        return text.substring(0, maxLength) + '...';
    }

    toggleView() {
        this.showCompactView = !this.showCompactView;
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wiredCasesResult);
    }

    handleCaseClick(event) {
        // Open the case in modal instead of navigating
        event.stopPropagation();
        const caseId = event.currentTarget.dataset.caseId;
        this.selectedCaseId = caseId;
        this.showCaseModal = true;
    }

    handleViewCase(event) {
        event.stopPropagation();
        const caseId = event.currentTarget.dataset.caseId;
        this.selectedCaseId = caseId;
        this.showCaseModal = true;
    }

    handleAcceptCase(event) {
        event.stopPropagation();
        const caseId = event.currentTarget.dataset.caseId;
        this.selectedCaseId = caseId;
        this.showCaseModal = true;
    }

    handleCloseModal() {
        this.showCaseModal = false;
        this.selectedCaseId = null;
    }

    handleCaseAcceptedFromModal(event) {
        // Case was accepted from the modal, refresh the list
        this.handleRefresh();
        this.handleCloseModal();
        
        // Dispatch event to parent component to refresh My Open Cases
        this.dispatchEvent(new CustomEvent('caseacceptedfromlist', {
            detail: { caseId: event.detail.caseId },
            bubbles: true,
            composed: true
        }));
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Case has been assigned to you',
                variant: 'success'
            })
        );
    }

    async handleAssignToMeDirectly(event) {
        // This is for direct assignment without opening modal (if needed)
        event.stopPropagation();
        const caseId = event.currentTarget.dataset.caseId;
        
        try {
            this.selectedCaseId = caseId;
            await assignCaseToCurrentUser({ caseId: caseId });
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case has been assigned to you',
                    variant: 'success'
                })
            );
            
            // Refresh the list
            this.handleRefresh();
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Error assigning case',
                    variant: 'error'
                })
            );
        } finally {
            this.selectedCaseId = null;
        }
    }

    handleViewAll() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: 'Unassigned_Cases'
            }
        });
    }
}