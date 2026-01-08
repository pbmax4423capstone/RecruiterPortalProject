import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSalesManagerList from '@salesforce/apex/RecruitingDirectorController.getSalesManagerList';
import getMetricsForManager from '@salesforce/apex/RecruitingDirectorController.getMetricsForManager';
import getGlobalMetrics from '@salesforce/apex/RecruitingDirectorController.getGlobalMetrics';
import getManagerComparison from '@salesforce/apex/RecruitingDirectorController.getManagerComparison';
import getCandidatesList from '@salesforce/apex/RecruitingDirectorController.getCandidatesList';
import getUpcomingInterviewsList from '@salesforce/apex/RecruitingDirectorController.getUpcomingInterviewsList';
import getActivePipelineList from '@salesforce/apex/RecruitingDirectorController.getActivePipelineList';
import getContractBList from '@salesforce/apex/RecruitingDirectorController.getContractBList';
import getContractAList from '@salesforce/apex/RecruitingDirectorController.getContractAList';
import getHiredList from '@salesforce/apex/RecruitingDirectorController.getHiredList';
import getCompletedInterviewsList from '@salesforce/apex/RecruitingDirectorController.getCompletedInterviewsList';
import exportToCsv from '@salesforce/apex/RecruitingDirectorController.exportToCsv';

export default class RecruitingDirectorDashboard extends LightningElement {
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
    @track chartData = null;
    @track selectedChartMetric = 'totalCandidates';
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
                this.loadChartData();
            })
            .catch(error => {
                console.error('Error loading metrics:', error);
                this.showError('Error loading metrics', error);
                this.isLoading = false;
            });
    }

    // Load chart data for manager comparison
    loadChartData() {
        getManagerComparison({ 
            metricType: this.selectedChartMetric,
            dateRange: this.selectedDateRange 
        })
            .then(result => {
                const labels = result.managers || [];
                const values = result.values || [];
                
                // Find max value for percentage calculation
                const maxValue = Math.max(...values, 1);
                
                // Generate chart data with bar widths
                this.chartData = labels.map((label, index) => {
                    const value = values[index] || 0;
                    const percentage = (value / maxValue) * 100;
                    return {
                        label: label,
                        value: value,
                        barStyle: `width: ${percentage}%`
                    };
                });
                
                this.isLoading = false;
            })
            .catch(error => {
                this.showError('Error loading chart data', error);
                this.isLoading = false;
            });
    }

    // Get chart label based on selected metric
    getChartLabel() {
        return this.selectedChartMetric === 'totalCandidates' 
            ? 'Total Candidates' 
            : 'Active Pipeline';
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

    // Handle chart metric selection
    handleChartMetricTotalCandidates() {
        this.selectedChartMetric = 'totalCandidates';
        this.loadChartData();
    }

    handleChartMetricActivePipeline() {
        this.selectedChartMetric = 'activePipeline';
        this.loadChartData();
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

    get isChartTotalCandidates() {
        return this.selectedChartMetric === 'totalCandidates' ? 'brand' : 'neutral';
    }

    get isChartActivePipeline() {
        return this.selectedChartMetric === 'activePipeline' ? 'brand' : 'neutral';
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

        const salesManager = this.selectedManager === 'All' ? null : this.selectedManager;
        let dataPromise;

        switch(metricType) {
            case 'totalCandidates':
                dataPromise = getCandidatesList({ salesManager });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' }
                ];
                break;
            case 'upcomingInterviews':
                dataPromise = getUpcomingInterviewsList({ salesManager });
                this.drillDownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Interview Date', fieldName: 'interviewDate', type: 'date-local', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' } },
                    { label: 'Interviewer', fieldName: 'interviewer', type: 'text' },
                    { label: 'Status', fieldName: 'status', type: 'text' }
                ];
                break;
            case 'activePipeline':
                dataPromise = getActivePipelineList({ salesManager });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Last Modified', fieldName: 'lastModified', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'contractB':
                dataPromise = getContractBList({ salesManager });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Contract Date', fieldName: 'contractDate', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'contractA':
                dataPromise = getContractAList({ salesManager });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Contract Date', fieldName: 'contractDate', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'hired':
                dataPromise = getHiredList({ salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } },
                    { label: 'Sales Manager', fieldName: 'salesManager', type: 'text' },
                    { label: 'Hire Date', fieldName: 'hireDate', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } }
                ];
                break;
            case 'completedInterviews':
                dataPromise = getCompletedInterviewsList({ salesManager, dateRange: this.selectedDateRange });
                this.drillDownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Completion Date', fieldName: 'completionDate', type: 'date', typeAttributes: { month: 'short', day: 'numeric', year: 'numeric' } },
                    { label: 'Interviewer', fieldName: 'interviewer', type: 'text' },
                    { label: 'Status', fieldName: 'status', type: 'text' }
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

    // Handle CSV export
    handleExportCsv() {
        const salesManager = this.selectedManager === 'All' ? null : this.selectedManager;
        
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
