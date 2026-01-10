import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMetrics from '@salesforce/apex/SummaryCardMetricsController.getMetrics';
import getCandidatesList from '@salesforce/apex/SummaryCardMetricsController.getCandidatesList';
import getUpcomingInterviewsList from '@salesforce/apex/SummaryCardMetricsController.getUpcomingInterviewsList';
import getActivePipelineList from '@salesforce/apex/SummaryCardMetricsController.getActivePipelineList';
import getOnContractBList from '@salesforce/apex/SummaryCardMetricsController.getOnContractBList';
import getOnContractAList from '@salesforce/apex/SummaryCardMetricsController.getOnContractAList';
import getHiredThisMonthList from '@salesforce/apex/SummaryCardMetricsController.getHiredThisMonthList';
import getCompletedInterviewsList from '@salesforce/apex/SummaryCardMetricsController.getCompletedInterviewsList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SalesManagerKeyMetrics extends NavigationMixin(LightningElement) {
    // Reactive properties for metrics
    @track totalCandidates = 0;
    @track upcomingInterviews = 0;
    @track activePipeline = 0;
    @track onContractB = 0;
    @track onContractA = 0;
    @track hiredThisMonth = 0;
    @track completedInterviewsThisMonth = 0;
    
    @track isLoading = true;
    @track error;
    
    // Modal state properties
    @track showDrilldownModal = false;
    @track drilldownTitle = '';
    @track drilldownRecords = [];
    @track drilldownColumns = [];
    @track isLoadingRecords = false;
    
    /**
     * Wire service to fetch real metrics from Apex
     * Automatically refreshes when data changes
     */
    @wire(getMetrics)
    wiredMetrics({ data, error }) {
        if (data) {
            // Process and bind data to template
            this.totalCandidates = data.totalCandidates || 0;
            this.upcomingInterviews = data.upcomingInterviews || 0;
            this.activePipeline = data.activePipeline || 0;
            this.onContractB = data.onContractB || 0;
            this.onContractA = data.onContractA || 0;
            this.hiredThisMonth = data.hiredThisMonth || 0;
            this.completedInterviewsThisMonth = data.completedInterviewsThisMonth || 0;
            
            this.isLoading = false;
            this.error = undefined;
        } else if (error) {
            console.error('Error fetching metrics:', error);
            this.error = error;
            this.isLoading = false;
            
            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading metrics',
                    message: error.body?.message || 'Unable to load dashboard metrics',
                    variant: 'error'
                })
            );
        }
    }
    
    /**
     * Handles click events on summary cards
     * Opens drill-down modal with detailed records
     * Also fires event for parent component integration
     * 
     * @param {Event} event - Click event from card
     */
    handleCardClick(event) {
        const label = event.currentTarget.dataset.label;
        const value = event.currentTarget.dataset.value;
        
        // Open drill-down modal
        this.openDrilldown(label);
        
        // Fire custom event for parent component integration
        // Parent dashboard component can subscribe to this event
        // to filter the Pipeline Details table
        const cardClickEvent = new CustomEvent('cardclick', {
            detail: {
                label: label,
                value: parseInt(value, 10)
            },
            bubbles: true,
            composed: true
        });
        
        this.dispatchEvent(cardClickEvent);
    }
    
    /**
     * Opens the drill-down modal for a specific metric
     * Fetches detailed records and configures columns
     * 
     * @param {String} metricLabel - Label of the clicked metric card
     */
    openDrilldown(metricLabel) {
        this.drilldownTitle = metricLabel;
        this.showDrilldownModal = true;
        this.isLoadingRecords = true;
        this.drilldownRecords = [];
        
        // Configure columns and fetch data based on metric type
        switch(metricLabel) {
            case 'Total Candidates':
                this.drilldownColumns = [
                    { label: 'Name', fieldName: 'name', type: 'text' },
                    { label: 'Sales Manager', fieldName: 'salesManagerName', type: 'text' },
                    { label: 'Status', fieldName: 'status', type: 'text' },
                    { label: 'Highest Level', fieldName: 'highestLevel', type: 'text' },
                    { label: 'Email', fieldName: 'email', type: 'email' },
                    { label: 'Phone', fieldName: 'phone', type: 'phone' },
                    { label: 'Office Location', fieldName: 'officeLocation', type: 'text' },
                    { 
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                getCandidatesList()
                    .then(data => {
                        this.drilldownRecords = data;
                        this.isLoadingRecords = false;
                    })
                    .catch(error => this.handleDrilldownError(error));
                break;
                
            case 'Upcoming Interviews':
                this.drilldownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Interview Type', fieldName: 'interviewType', type: 'text' },
                    { label: 'Scheduled Date', fieldName: 'scheduledDate', type: 'date-local', typeAttributes: { month: 'numeric', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' } },
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
                getUpcomingInterviewsList()
                    .then(data => {
                        this.drilldownRecords = data;
                        this.isLoadingRecords = false;
                    })
                    .catch(error => this.handleDrilldownError(error));
                break;
                
            case 'Active Pipeline':
                this.drilldownColumns = [
                    { label: 'Sales Manager', fieldName: 'salesManagerName', type: 'text' },
                    { label: 'Name', fieldName: 'name', type: 'text' },
                    { label: 'Status', fieldName: 'status', type: 'text' },
                    { label: 'Highest Level', fieldName: 'highestLevel', type: 'text' },
                    { label: 'Next Meeting', fieldName: 'nextMeeting', type: 'date' },
                    { label: 'Email', fieldName: 'email', type: 'email' },
                    { label: 'Phone', fieldName: 'phone', type: 'phone' },
                    { 
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                getActivePipelineList()
                    .then(data => {
                        this.drilldownRecords = data;
                        this.isLoadingRecords = false;
                    })
                    .catch(error => this.handleDrilldownError(error));
                break;
                
            case 'On Contract B':
                this.drilldownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Contract Type', fieldName: 'contractType', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Effective Date', fieldName: 'effectiveDate', type: 'date' },
                    { label: 'Expiration Date', fieldName: 'expirationDate', type: 'date' },
                    { 
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                getOnContractBList()
                    .then(data => {
                        this.drilldownRecords = data;
                        this.isLoadingRecords = false;
                    })
                    .catch(error => this.handleDrilldownError(error));
                break;
                
            case 'On Contract A':
                this.drilldownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Contract Type', fieldName: 'contractType', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Effective Date', fieldName: 'effectiveDate', type: 'date' },
                    { 
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                getOnContractAList()
                    .then(data => {
                        this.drilldownRecords = data;
                        this.isLoadingRecords = false;
                    })
                    .catch(error => this.handleDrilldownError(error));
                break;
                
            case 'Hired This Month':
                this.drilldownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Contract Type', fieldName: 'contractType', type: 'text' },
                    { label: 'Stage', fieldName: 'stage', type: 'text' },
                    { label: 'Hire Date', fieldName: 'hireDate', type: 'date' },
                    { label: 'Effective Date', fieldName: 'effectiveDate', type: 'date' },
                    { 
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                getHiredThisMonthList()
                    .then(data => {
                        this.drilldownRecords = data;
                        this.isLoadingRecords = false;
                    })
                    .catch(error => this.handleDrilldownError(error));
                break;
                
            case 'Completed Interviews This Month':
                this.drilldownColumns = [
                    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
                    { label: 'Interview Type', fieldName: 'interviewType', type: 'text' },
                    { label: 'Completed Date', fieldName: 'completedDate', type: 'date' },
                    { label: 'Outcome', fieldName: 'outcome', type: 'text' },
                    { label: 'Interviewer', fieldName: 'interviewer', type: 'text' },
                    { 
                        type: 'button',
                        typeAttributes: {
                            label: 'View',
                            name: 'view',
                            variant: 'base'
                        }
                    }
                ];
                getCompletedInterviewsList()
                    .then(data => {
                        this.drilldownRecords = data;
                        this.isLoadingRecords = false;
                    })
                    .catch(error => this.handleDrilldownError(error));
                break;
                
            default:
                this.isLoadingRecords = false;
        }
    }
    
    /**
     * Handles errors when fetching drill-down data
     * 
     * @param {Object} error - Error object from Apex call
     */
    handleDrilldownError(error) {
        console.error('Error loading drill-down data:', error);
        this.isLoadingRecords = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading records',
                message: error.body?.message || 'Unable to load detailed records',
                variant: 'error'
            })
        );
    }
    
    /**
     * Closes the drill-down modal and resets state
     */
    closeDrilldown() {
        this.showDrilldownModal = false;
        this.drilldownTitle = '';
        this.drilldownRecords = [];
        this.drilldownColumns = [];
        this.isLoadingRecords = false;
    }
    
    /**
     * Handles row actions in the drill-down datatable
     * Navigates to the record detail page
     * 
     * @param {Event} event - Row action event from datatable
     */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'view' && row.id) {
            // Navigate to record page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.id,
                    objectApiName: this.getObjectApiName(row),
                    actionName: 'view'
                }
            });
        }
    }
    
    /**
     * Determines the object API name based on the record ID prefix
     * 
     * @param {Object} row - Record row from datatable
     * @return {String} Object API name
     */
    getObjectApiName(row) {
        // If it has candidateId, it's an Interview or ALC record
        if (row.candidateId) {
            // Check if it has interviewType (Interview) or contractType (ALC)
            if (row.interviewType) {
                return 'Interview__c';
            } else if (row.contractType) {
                return 'ALC__c';
            }
        }
        // Default to Candidate
        return 'Candidate__c';
    }
    
    /**
     * Getter for record count display in modal header
     */
    get recordCount() {
        return this.drilldownRecords ? this.drilldownRecords.length : 0;
    }
    
    /**
     * Getter to show empty state when no records found
     */
    get hasNoRecords() {
        return !this.isLoadingRecords && this.recordCount === 0;
    }
}
