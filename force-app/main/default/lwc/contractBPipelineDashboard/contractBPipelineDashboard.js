import { LightningElement, wire, track } from 'lwc';
import getContractBPipelineData from '@salesforce/apex/ContractBDashboardController.getContractBPipelineData';
import getInterviewStatsByPeriod from '@salesforce/apex/ContractBDashboardController.getInterviewStatsByPeriod';
import getRecruitingMetrics from '@salesforce/apex/ContractBDashboardController.getRecruitingMetrics';
import getContractAProgressData from '@salesforce/apex/ContractBDashboardController.getContractAProgressData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContractBPipelineDashboard extends NavigationMixin(LightningElement) {
    // Pipeline Data
    @track pipelineData = [];
    @track atRiskCandidates = [];
    @track summary = {};
    
    // Contract A Data
    @track contractAData = [];
    @track contractASummary = {};
    
    // Interview Stats
    @track interviewStats = {};
    @track interviewPeriod = 'currentMonth';
    
    // Recruiting Metrics
    @track recruitingMetrics = {};
    @track monthlyRecruiting = [];
    @track terminationReasons = [];
    @track ytdTotals = {};
    
    // UI State
    isLoading = true;
    error;
    
    // Period toggle options
    periodOptions = [
        { label: 'Current Month', value: 'currentMonth' },
        { label: 'Year to Date', value: 'yearToDate' }
    ];
    
    connectedCallback() {
        this.loadAllData();
    }
    
    async loadAllData() {
        this.isLoading = true;
        try {
            await Promise.all([
                this.loadPipelineData(),
                this.loadInterviewStats(),
                this.loadRecruitingMetrics(),
                this.loadContractAData()
            ]);
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }
    
    async loadPipelineData() {
        try {
            const result = await getContractBPipelineData();
            if (result) {
                this.pipelineData = result.pipeline || [];
                this.atRiskCandidates = result.atRiskCandidates || [];
                this.summary = result.summary || {};
            }
        } catch (error) {
            console.error('Error loading pipeline data:', error);
        }
    }
    
    async loadContractAData() {
        try {
            const result = await getContractAProgressData();
            if (result) {
                this.contractAData = result.contractAData || [];
                this.contractASummary = result.summary || {};
            }
        } catch (error) {
            console.error('Error loading Contract A data:', error);
        }
    }
    
    async loadInterviewStats() {
        try {
            const result = await getInterviewStatsByPeriod({ period: this.interviewPeriod });
            if (result) {
                this.interviewStats = result;
            }
        } catch (error) {
            console.error('Error loading interview stats:', error);
        }
    }
    
    async loadRecruitingMetrics() {
        try {
            const result = await getRecruitingMetrics();
            if (result) {
                this.recruitingMetrics = result;
                this.monthlyRecruiting = result.monthlyRecruiting || [];
                this.terminationReasons = result.terminationReasons || [];
                this.ytdTotals = result.ytdTotals || {};
            }
        } catch (error) {
            console.error('Error loading recruiting metrics:', error);
        }
    }
    
    handlePeriodChange(event) {
        this.interviewPeriod = event.detail.value;
        this.loadInterviewStats();
    }
    
    handleRefresh() {
        this.loadAllData();
    }
    
    navigateToCandidate(event) {
        const candidateId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: candidateId,
                objectApiName: 'Candidate__c',
                actionName: 'view'
            }
        });
    }
    
    handleError(error) {
        this.error = error;
        console.error('Dashboard error:', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'An error occurred loading dashboard data',
                variant: 'error'
            })
        );
    }
    
    // Computed properties
    get hasAtRiskCandidates() {
        return this.atRiskCandidates && this.atRiskCandidates.length > 0;
    }
    
    get hasPipelineData() {
        return this.pipelineData && this.pipelineData.length > 0;
    }
    
    get hasContractAData() {
        return this.contractAData && this.contractAData.length > 0;
    }
    
    get qualifiedContractAData() {
        // Qualified = progress bar >= 100% OR status starts with "Met"
        return this.formattedContractAData.filter(agent => 
            agent.wladlProgress >= 100 || 
            (agent.qualStatus && agent.qualStatus.startsWith('Met'))
        );
    }
    
    get notQualifiedContractAData() {
        // Not qualified = progress bar < 100% AND status does NOT start with "Met"
        return this.formattedContractAData.filter(agent => 
            agent.wladlProgress < 100 && 
            (!agent.qualStatus || !agent.qualStatus.startsWith('Met'))
        );
    }
    
    get hasQualifiedData() {
        return this.qualifiedContractAData && this.qualifiedContractAData.length > 0;
    }
    
    get hasNotQualifiedData() {
        return this.notQualifiedContractAData && this.notQualifiedContractAData.length > 0;
    }
    
    get qualifiedCount() {
        return this.qualifiedContractAData ? this.qualifiedContractAData.length : 0;
    }
    
    get notQualifiedCount() {
        return this.notQualifiedContractAData ? this.notQualifiedContractAData.length : 0;
    }
    
    get hasMonthlyData() {
        return this.monthlyRecruiting && this.monthlyRecruiting.length > 0;
    }
    
    get formattedPipelineData() {
        return this.pipelineData.map(cand => ({
            ...cand,
            fycFormatted: this.formatCurrency(cand.totalFYC),
            progressClass: this.getProgressClass(cand.statusIndicator),
            fycProgressStyle: `width: ${Math.min(cand.fycProgress || 0, 100)}%`,
            submissionsProgressStyle: `width: ${Math.min((cand.submissionsProgress || 0) * 20, 100)}%`,
            isAtRisk: cand.statusIndicator === 'At Risk' || cand.statusIndicator === 'Critical'
        }));
    }
    
    get formattedContractAData() {
        return this.contractAData.map(agent => ({
            ...agent,
            ytdFYCFormatted: this.formatCurrency(agent.ytdFYC),
            ytdWLADLFormatted: this.formatCurrency(agent.ytdWLADL),
            wladlMinFormatted: this.formatCurrency(agent.wladlMinimum),
            progressStyle: `width: ${Math.min(agent.wladlProgress || 0, 100)}%`,
            progressClass: this.getQualStatusClass(agent.qualStatus),
            statusBadgeClass: this.getStatusBadgeClass(agent.qualStatus),
            hasOneInFive: agent.oneInFive === '1 in 5'
        }));
    }
    
    getQualStatusClass(status) {
        switch (status) {
            case 'Met WLADL':
            case 'Met GDC Equivalent':
            case 'Met Both':
                return 'progress-met';
            case 'Not On Target':
                return 'progress-not-on-target';
            case 'N/A':
                return 'progress-na';
            default:
                return 'progress-default';
        }
    }
    
    getStatusBadgeClass(status) {
        switch (status) {
            case 'Met WLADL':
            case 'Met GDC Equivalent':
            case 'Met Both':
                return 'slds-badge slds-theme_success';
            case 'Not On Target':
                return 'slds-badge slds-theme_warning';
            case 'N/A':
                return 'slds-badge slds-theme_inverse';
            default:
                return 'slds-badge';
        }
    }
    
    get contractATotalFYCFormatted() {
        return this.formatCurrency(this.contractASummary.totalYTDFYC);
    }
    
    get contractAAvgFYCFormatted() {
        return this.formatCurrency(this.contractASummary.avgYTDFYC);
    }
    
    get contractATotalWLADLFormatted() {
        return this.formatCurrency(this.contractASummary.totalYTDWLADL);
    }
    
    formatCurrency(value) {
        if (value == null) return '$0';
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(value);
    }
    
    getProgressClass(status) {
        switch (status) {
            case 'On Track':
                return 'progress-on-track';
            case 'At Risk':
                return 'progress-at-risk';
            case 'Critical':
                return 'progress-critical';
            case 'Complete':
                return 'progress-complete';
            default:
                return 'progress-default';
        }
    }
    
    get totalFYCFormatted() {
        return this.formatCurrency(this.summary.totalFYC);
    }
    
    get avgFYCFormatted() {
        return this.formatCurrency(this.summary.avgFYC);
    }
    
    get transitionRateFormatted() {
        return `${this.ytdTotals.transitionRate || 0}%`;
    }
    
    get terminationRateFormatted() {
        return `${this.ytdTotals.terminationRate || 0}%`;
    }
}
