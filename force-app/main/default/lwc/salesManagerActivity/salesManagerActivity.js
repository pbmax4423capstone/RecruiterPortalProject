import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import DASHBOARD_FILTER_CHANNEL from '@salesforce/messageChannel/DashboardFilterChannel__c';
import getSalesManagerActivity from '@salesforce/apex/SalesManagerActivityController.getSalesManagerActivity';
import getInterviewDetails from '@salesforce/apex/SalesManagerActivityController.getInterviewDetails';
import getCandidatesInContracting from '@salesforce/apex/SalesManagerActivityController.getCandidatesInContracting';
import getCandidatesOnboarding from '@salesforce/apex/SalesManagerActivityController.getCandidatesOnboarding';

const COLUMNS = [
    { label: 'Sales Manager', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Last Login', fieldName: 'lastLoginDate', type: 'date', sortable: true, 
      typeAttributes: { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' } },
    { label: 'Days Since Login', fieldName: 'daysSinceLogin', type: 'number', sortable: true },
    { label: 'Login Status', fieldName: 'loginStatus', type: 'text', sortable: true }
];

export default class SalesManagerActivity extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    messageContext;
    
    @api darkMode = false;
    @api embedded = false;
    @track activityData = [];
    @track isLoading = true;
    @track showModal = false;
    @track isLoadingModal = false;
    @track modalTitle = '';
    @track modalData = [];
    @track modalColumns = [];
    @track summaryMetrics = {
        totalCandidatesAdded: 0,
        totalInterviewsScheduled: 0,
        totalInterviewsCompleted: 0,
        totalInContracting: 0,
        totalOnboarding: 0
    };
    
    columns = COLUMNS;
    currentSalesManagerFilter = 'All Sales Managers';
    currentDateRangeFilter = 'THIS_MONTH';
    currentManagerName = '';
    darkModeSubscription = null;
    filterSubscription = null;

    connectedCallback() {
        this.subscribeToMessageChannels();
        this.loadData();
    }

    disconnectedCallback() {
        this.unsubscribeFromMessageChannels();
    }

    subscribeToMessageChannels() {
        // Subscribe to dark mode changes
        this.darkModeSubscription = subscribe(
            this.messageContext,
            DARK_MODE_CHANNEL,
            (message) => this.handleDarkModeChange(message)
        );
        
        // Subscribe to dashboard filter changes
        this.filterSubscription = subscribe(
            this.messageContext,
            DASHBOARD_FILTER_CHANNEL,
            (message) => this.handleFilterChange(message)
        );
    }

    unsubscribeFromMessageChannels() {
        if (this.darkModeSubscription) {
            this.darkModeSubscription = null;
        }
        if (this.filterSubscription) {
            this.filterSubscription = null;
        }
    }

    handleDarkModeChange(message) {
        this.darkMode = message.darkModeEnabled;
    }

    handleFilterChange(message) {
        let filtersChanged = false;
        
        if (message.salesManagerFilter && message.salesManagerFilter !== this.currentSalesManagerFilter) {
            this.currentSalesManagerFilter = message.salesManagerFilter;
            filtersChanged = true;
        }
        
        if (message.dateRangeFilter && message.dateRangeFilter !== this.currentDateRangeFilter) {
            this.currentDateRangeFilter = message.dateRangeFilter;
            filtersChanged = true;
        }
        
        if (filtersChanged || message.refreshRequested) {
            this.loadData();
        }
    }

    async loadData() {
        this.isLoading = true;
        
        try {
            const activityResult = await getSalesManagerActivity({
                dateRange: this.currentDateRangeFilter,
                salesManagerFilter: this.currentSalesManagerFilter
            });
            
            this.activityData = activityResult;
            
            // Calculate summary metrics
            this.calculateSummaryMetrics();
            
        } catch (error) {
            this.showError('Error loading sales manager activity', error);
            console.error('Error loading data:', error);
        } finally {
            this.isLoading = false;
        }
    }
    
    calculateSummaryMetrics() {
        let totalCandidatesAdded = 0;
        let totalInterviewsScheduled = 0;
        let totalInterviewsCompleted = 0;
        let totalInContracting = 0;
        let totalOnboarding = 0;
        
        this.activityData.forEach(manager => {
            totalCandidatesAdded += manager.candidatesAdded || 0;
            totalInterviewsScheduled += manager.interviewsScheduled || 0;
            totalInterviewsCompleted += manager.interviewsCompleted || 0;
            totalInContracting += manager.candidatesInContracting || 0;
            totalOnboarding += manager.candidatesOnboarding || 0;
        });
        
        this.summaryMetrics = {
            totalCandidatesAdded,
            totalInterviewsScheduled,
            totalInterviewsCompleted,
            totalInContracting,
            totalOnboarding
        };
    }

    handleCardClick(event) {
        const cardType = event.currentTarget.dataset.cardType;
        
        if (cardType === 'candidatesAdded') {
            this.openCandidatesAddedModal();
        } else if (cardType === 'interviewsScheduled') {
            this.openAllInterviewsModal('scheduled');
        } else if (cardType === 'interviewsCompleted') {
            this.openAllInterviewsModal('completed');
        } else if (cardType === 'inContracting') {
            this.openAllContractingModal();
        } else if (cardType === 'onboarding') {
            this.openAllOnboardingModal();
        }
    }
    
    openCandidatesAddedModal() {
        this.modalTitle = `Candidates Added - ${this.dateRangeLabel}`;
        
        this.modalColumns = [
            { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
            { label: 'Candidates Added', fieldName: 'count', type: 'number' }
        ];
        
        const data = this.activityData
            .filter(manager => manager.candidatesAdded > 0)
            .map(manager => ({
                salesManager: manager.name,
                count: manager.candidatesAdded
            }));
        
        this.modalData = data;
        this.showModal = true;
    }

    async openAllInterviewsModal(type) {
        this.modalTitle = type === 'scheduled' 
            ? `All Interviews Scheduled - ${this.dateRangeLabel}`
            : `All Interviews Completed - ${this.dateRangeLabel}`;
        
        this.modalColumns = [
            { label: 'Interview', fieldName: 'name', type: 'text' },
            { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
            { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
            { label: 'Scheduled Date', fieldName: 'scheduledDate', type: 'date',
              typeAttributes: { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' } },
            { label: 'Type', fieldName: 'type', type: 'text' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            { label: 'Outcome', fieldName: 'outcome', type: 'text' },
            { label: 'View', type: 'action', typeAttributes: { rowActions: [
                { label: 'View Interview', name: 'view_interview' },
                { label: 'View Candidate', name: 'view_candidate' }
            ]}}
        ];
        
        this.showModal = true;
        this.isLoadingModal = true;
        
        try {
            const interviews = await getInterviewDetails({
                salesManager: 'All Sales Managers',
                dateRange: this.currentDateRangeFilter,
                interviewType: type
            });
            
            // Add sales manager name to each interview
            this.modalData = interviews.map(interview => ({
                ...interview,
                salesManager: this.getSalesManagerForInterview(interview)
            }));
        } catch (error) {
            this.showError('Error loading interview details', error);
        } finally {
            this.isLoadingModal = false;
        }
    }
    
    getSalesManagerForInterview(interview) {
        // Find the sales manager from activityData based on the interview
        // For now, return a placeholder - in production, this would come from the Interview record
        return interview.salesManager || 'N/A';
    }

    async openAllContractingModal() {
        this.modalTitle = `All Candidates in Contracting`;
        
        this.modalColumns = [
            { label: 'Name', fieldName: 'name', type: 'text' },
            { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
            { label: 'Email', fieldName: 'email', type: 'email' },
            { label: 'Phone', fieldName: 'phone', type: 'phone' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            { label: 'Stage', fieldName: 'stage', type: 'text' },
            { label: 'ALC Stage', fieldName: 'alcStage', type: 'text' },
            { label: 'View', type: 'action', typeAttributes: { rowActions: [
                { label: 'View Candidate', name: 'view_candidate' },
                { label: 'View ALC', name: 'view_alc' }
            ]}}
        ];
        
        this.showModal = true;
        this.isLoadingModal = true;
        
        try {
            const candidates = await getCandidatesInContracting({
                salesManager: this.currentSalesManagerFilter
            });
            
            this.modalData = candidates;
        } catch (error) {
            this.showError('Error loading contracting candidates', error);
        } finally {
            this.isLoadingModal = false;
        }
    }

    async openAllOnboardingModal() {
        this.modalTitle = 'All Candidates Currently Onboarding';
        
        this.modalColumns = [
            { label: 'Name', fieldName: 'name', type: 'text' },
            { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
            { label: 'Email', fieldName: 'email', type: 'email' },
            { label: 'Phone', fieldName: 'phone', type: 'phone' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            { label: 'ALC', fieldName: 'alcStatus', type: 'text' },
            { label: 'Agents Staff Status', fieldName: 'agentStaffStatus', type: 'text' },
            { label: 'View', type: 'action', typeAttributes: { rowActions: [
                { label: 'View Candidate', name: 'view_candidate' },
                { label: 'View ALC', name: 'view_alc' }
            ]}}
        ];
        
        this.showModal = true;
        this.isLoadingModal = true;
        
        try {
            const candidates = await getCandidatesOnboarding({
                salesManager: this.currentSalesManagerFilter,
                dateRange: this.currentDateRangeFilter
            });
            
            this.modalData = candidates;
        } catch (error) {
            this.showError('Error loading onboarding candidates', error);
        } finally {
            this.isLoadingModal = false;
        }
    }

    handleCellClick(event) {
        const fieldName = event.detail.fieldName;
        const row = event.detail.row;
        this.currentManagerName = row.name;
        
        // Only handle clicks on clickable cells
        if (fieldName === 'interviewsScheduled') {
            this.openInterviewModal('scheduled');
        } else if (fieldName === 'interviewsCompleted') {
            this.openInterviewModal('completed');
        } else if (fieldName === 'candidatesInContracting') {
            this.openContractingModal();
        } else if (fieldName === 'candidatesOnboarding') {
            this.openOnboardingModal();
        }
    }

    async openInterviewModal(type) {
        this.modalTitle = type === 'scheduled' 
            ? `Interviews Scheduled - ${this.currentManagerName}`
            : `Interviews Completed - ${this.currentManagerName}`;
        
        this.modalColumns = [
            { label: 'Interview', fieldName: 'name', type: 'text' },
            { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
            { label: 'Scheduled Date', fieldName: 'scheduledDate', type: 'date',
              typeAttributes: { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' } },
            { label: 'Type', fieldName: 'type', type: 'text' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            { label: 'Outcome', fieldName: 'outcome', type: 'text' },
            { label: 'View', type: 'action', typeAttributes: { rowActions: [
                { label: 'View Interview', name: 'view_interview' },
                { label: 'View Candidate', name: 'view_candidate' }
            ]}}
        ];
        
        this.showModal = true;
        this.isLoadingModal = true;
        
        try {
            const interviews = await getInterviewDetails({
                salesManager: this.currentManagerName,
                dateRange: this.currentDateRangeFilter,
                interviewType: type
            });
            
            this.modalData = interviews;
        } catch (error) {
            this.showError('Error loading interview details', error);
        } finally {
            this.isLoadingModal = false;
        }
    }

    async openContractingModal() {
        this.modalTitle = `Candidates in Contracting - ${this.currentManagerName}`;
        
        this.modalColumns = [
            { label: 'Name', fieldName: 'name', type: 'text' },
            { label: 'Email', fieldName: 'email', type: 'email' },
            { label: 'Phone', fieldName: 'phone', type: 'phone' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            { label: 'Stage', fieldName: 'stage', type: 'text' },
            { label: 'ALC Stage', fieldName: 'alcStage', type: 'text' },
            { label: 'View', type: 'action', typeAttributes: { rowActions: [
                { label: 'View Candidate', name: 'view_candidate' },
                { label: 'View ALC', name: 'view_alc' }
            ]}}
        ];
        
        this.showModal = true;
        this.isLoadingModal = true;
        
        try {
            const candidates = await getCandidatesInContracting({
                salesManager: this.currentManagerName
            });
            
            this.modalData = candidates;
        } catch (error) {
            this.showError('Error loading contracting candidates', error);
        } finally {
            this.isLoadingModal = false;
        }
    }

    async openOnboardingModal() {
        this.modalTitle = `Candidates Onboarding - ${this.currentManagerName}`;
        
        this.modalColumns = [
            { label: 'Name', fieldName: 'name', type: 'text' },
            { label: 'Email', fieldName: 'email', type: 'email' },
            { label: 'Phone', fieldName: 'phone', type: 'phone' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            { label: 'ALC Stage', fieldName: 'alcStage', type: 'text' },
            { label: 'View', type: 'action', typeAttributes: { rowActions: [
                { label: 'View Candidate', name: 'view_candidate' },
                { label: 'View ALC', name: 'view_alc' }
            ]}}
        ];
        
        this.showModal = true;
        this.isLoadingModal = true;
        
        try {
            const candidates = await getCandidatesOnboarding({
                salesManager: this.currentManagerName
            });
            
            this.modalData = candidates;
        } catch (error) {
            this.showError('Error loading onboarding candidates', error);
        } finally {
            this.isLoadingModal = false;
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        if (action.name === 'view_interview') {
            this.navigateToRecord(row.id);
        } else if (action.name === 'view_candidate') {
            this.navigateToRecord(row.candidateId || row.id);
        } else if (action.name === 'view_alc') {
            this.navigateToRecord(row.alcId);
        }
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    closeModal() {
        this.showModal = false;
        this.modalData = [];
        this.modalColumns = [];
        this.currentManagerName = '';
    }

    @api
    async refreshData() {
        return this.loadData();
    }

    get containerClass() {
        return this.darkMode ? 'activity-container dark-mode' : 'activity-container';
    }

    get dateRangeLabel() {
        switch (this.currentDateRangeFilter) {
            case 'THIS_QUARTER':
                return 'This Quarter';
            case 'THIS_YEAR':
                return 'This Year';
            default:
                return 'This Month';
        }
    }

    showError(title, error) {
        const event = new ShowToastEvent({
            title: title,
            message: error.body ? error.body.message : error.message,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }
}
