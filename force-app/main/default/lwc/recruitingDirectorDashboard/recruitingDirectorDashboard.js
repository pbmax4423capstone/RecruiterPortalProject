import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSalesManagerList from '@salesforce/apex/RecruitingDirectorController.getSalesManagerList';
import getMetricsForManager from '@salesforce/apex/RecruitingDirectorController.getMetricsForManager';
import getGlobalMetrics from '@salesforce/apex/RecruitingDirectorController.getGlobalMetrics';
import getCandidatesList from '@salesforce/apex/RecruitingDirectorController.getCandidatesList';
import getUpcomingInterviewsList from '@salesforce/apex/RecruitingDirectorController.getUpcomingInterviewsList';
import getActivePipelineList from '@salesforce/apex/RecruitingDirectorController.getActivePipelineList';
import getContractBList from '@salesforce/apex/RecruitingDirectorController.getContractBList';
import getContractAList from '@salesforce/apex/RecruitingDirectorController.getContractAList';
import getHiredList from '@salesforce/apex/RecruitingDirectorController.getHiredList';
import getCompletedInterviewsList from '@salesforce/apex/RecruitingDirectorController.getCompletedInterviewsList';
import exportToCsv from '@salesforce/apex/RecruitingDirectorController.exportToCsv';

export default class RecruitingDirectorDashboard extends NavigationMixin(LightningElement) {
    @track salesManagerOptions = [];
    @track selectedManager = 'All Sales Managers';  // Fixed: was 'All', should match dropdown value
    @track selectedDateRange = 'THIS_MONTH';
    @track metrics = {
        totalCandidates: 0,
        upcomingInterviews: 0,
        activePipeline: 0,
        onContractB: 0,
        onContractA: 0,
        hiredThisPeriod: 0,
        completedInterviewsThisPeriod: 0
    };
    @track isLoading = true;

    // Drill-down modal properties
    @track showDrillDownModal = false;
    @track drillDownTitle = '';
    @track drillDownData = [];
    @track drillDownColumns = [];
    @track isDrillDownLoading = false;
    @track currentDrillDownMetric = '';

    connectedCallback() {
        this.loadSalesManagerList();
    }

    // Load sales manager picker options
    loadSalesManagerList() {
        getSalesManagerList()
            .then(result => {
                console.log('Sales Manager List Result:', result);
                this.salesManagerOptions = result; // Result is already the array of options
                this.loadMetrics();
            })
            .catch(error => {
                console.error('Error loading sales managers:', error);
                this.showError('Error loading sales managers', error);
                this.isLoading = false;
            });
    }

    // Load metrics based on current filters
    loadMetrics() {
        this.isLoading = true;
        
        const isAllManagers = this.selectedManager === 'All Sales Managers';
        const metricsPromise = isAllManagers 
            ? getGlobalMetrics({ dateRange: this.selectedDateRange })
            : getMetricsForManager({ 
                managerName: this.selectedManager,  // Fixed: was 'salesManager', should be 'managerName'
                dateRange: this.selectedDateRange 
            });

        metricsPromise
            .then(result => {
                console.log('Metrics loaded for manager:', this.selectedManager, result);
                this.metrics = {
                    totalCandidates: result.totalCandidates || 0,
                    upcomingInterviews: result.upcomingInterviews || 0,
                    activePipeline: result.activePipeline || 0,
                    onContractB: result.onContractB || 0,
                    onContractA: result.onContractA || 0,
                    hiredThisPeriod: result.hiredThisPeriod || 0,
                    completedInterviewsThisPeriod: result.completedInterviewsThisPeriod || 0
                };
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading metrics:', error);
                this.showError('Error loading metrics', error);
                this.isLoading = false;
            });
    }

    // Handle manager selection change
    handleManagerChange(event) {
        this.selectedManager = event.detail.value;
        this.loadMetrics();
    }

    // Handle date range button clicks
    handleMonthClick() {
        this.selectedDateRange = 'THIS_MONTH';
        this.loadMetrics();
    }

    handleQuarterClick() {
        this.selectedDateRange = 'THIS_QUARTER';
        this.loadMetrics();
    }

    handleYearClick() {
        this.selectedDateRange = 'THIS_YEAR';
        this.loadMetrics();
    }

    // Button variant getters for active state
    get isMonth() {
        return this.selectedDateRange === 'THIS_MONTH' ? 'brand' : 'neutral';
    }

    get isQuarter() {
        return this.selectedDateRange === 'THIS_QUARTER' ? 'brand' : 'neutral';
    }

    get isYear() {
        return this.selectedDateRange === 'THIS_YEAR' ? 'brand' : 'neutral';
    }

    get hasDrillDownData() {
        return this.drillDownData && this.drillDownData.length > 0;
    }

    // Drill-down click handlers
    handleTotalCandidatesClick() {
        this.openDrillDown('Total Candidates', 'totalCandidates');
    }

    handleUpcomingInterviewsClick() {
        this.openDrillDown('Upcoming Interviews', 'upcomingInterviews');
    }

    handleActivePipelineClick() {
        this.openDrillDown('Active Pipeline', 'activePipeline');
    }

    handleContractBClick() {
        this.openDrillDown('Contract B', 'contractB');
    }

    handleContractAClick() {
        this.openDrillDown('Contract A', 'contractA');
    }

    handleHiredClick() {
        this.openDrillDown(`Hired (${this.selectedDateRange})`, 'hired');
    }

    handleCompletedInterviewsClick() {
        this.openDrillDown(`Completed Interviews (${this.selectedDateRange})`, 'completedInterviews');
    }

    // Open drill-down modal with data
    openDrillDown(title, metricType) {
        this.drillDownTitle = title;
        this.currentDrillDownMetric = metricType;
        this.showDrillDownModal = true;
        this.isDrillDownLoading = true;
        this.drillDownData = [];

        const salesManager = this.selectedManager;
        let dataPromise;

        switch(metricType) {
            case 'totalCandidates':
                dataPromise = getCandidatesList({ managerName: salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManagerName', type: 'text' },
                    { label: 'Stage', fieldName: 'status', type: 'text' }
                ];
                break;
            case 'upcomingInterviews':
                dataPromise = getUpcomingInterviewsList({ managerName: salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Interview Date', fieldName: 'interviewDate', type: 'date-local', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' } },
                    { label: 'Interviewer', fieldName: 'interviewer', type: 'text' },
                    { label: 'Status', fieldName: 'status', type: 'text' },
                    {
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                break;
            case 'activePipeline':
                dataPromise = getActivePipelineList({ managerName: salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManagerName', type: 'text' },
                    { label: 'Stage', fieldName: 'status', type: 'text' },
                    { label: 'Last Modified', fieldName: 'lastModified', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'contractB':
                dataPromise = getContractBList({ managerName: salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManagerName', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Contract Date', fieldName: 'contractEffective', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'contractA':
                dataPromise = getContractAList({ managerName: salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManagerName', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Contract Date', fieldName: 'contractEffective', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'hired':
                dataPromise = getHiredList({ managerName: salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManagerName', type: 'text' },
                    { label: 'Hire Date', fieldName: 'contractEffective', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'completedInterviews':
                dataPromise = getCompletedInterviewsList({ managerName: salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Completion Date', fieldName: 'dateCompleted', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } },
                    { label: 'Interviewer', fieldName: 'interviewer', type: 'text' },
                    { label: 'Type', fieldName: 'interviewType', type: 'text' },
                    {
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                break;
        }

        dataPromise
            .then(result => {
                this.drillDownData = result;
                this.isDrillDownLoading = false;
            })
            .catch(error => {
                this.showError('Error loading drill-down data', error);
                this.isDrillDownLoading = false;
            });
    }

    // Close drill-down modal
    closeDrillDownModal() {
        this.showDrillDownModal = false;
        this.drillDownData = [];
        this.currentDrillDownMetric = '';
    }

    /**
     * Handles row actions in the drill-down datatable
     * Navigates to the record detail page (Interview or Candidate)
     * 
     * @param {Event} event - Row action event from datatable
     */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'view' && row.id) {
            // Determine object type based on metric
            let objectApiName = 'Candidate__c';
            
            // For interview-related metrics, navigate to Interview__c
            if (this.currentDrillDownMetric === 'upcomingInterviews' || 
                this.currentDrillDownMetric === 'completedInterviews') {
                objectApiName = 'Interview__c';
            }
            
            // Navigate to record page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.id,
                    objectApiName: objectApiName,
                    actionName: 'view'
                }
            });
        }
    }

    // Handle CSV export
    handleExportCsv() {
        const salesManager = this.selectedManager;
        
        exportToCsv({ 
            metricType: this.currentDrillDownMetric,
            salesManager: salesManager,
            dateRange: this.selectedDateRange
        })
            .then(csvContent => {
                // Create blob and download
                const blob = new Blob([csvContent], { type: 'text/csv' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `${this.currentDrillDownMetric}_${new Date().toISOString().split('T')[0]}.csv`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
                
                this.showSuccess('CSV exported successfully');
            })
            .catch(error => {
                this.showError('Error exporting CSV', error);
            });
    }

    // Utility methods
    showSuccess(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        }));
    }

    showError(title, error) {
        let message = 'Unknown error';
        if (error && error.body && error.body.message) {
            message = error.body.message;
        } else if (error && error.message) {
            message = error.message;
        } else if (typeof error === 'string') {
            message = error;
        }
        
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error'
        }));
    }
}
