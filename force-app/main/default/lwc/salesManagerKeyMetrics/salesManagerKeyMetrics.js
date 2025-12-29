import { LightningElement, wire, track } from 'lwc';
import getMetrics from '@salesforce/apex/SummaryCardMetricsController.getMetrics';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SalesManagerKeyMetrics extends LightningElement {
    // Reactive properties for metrics
    @track totalCandidates = 0;
    @track upcomingInterviews = 0;
    @track activePipeline = 0;
    @track onContractB = 0;
    @track hiredThisMonth = 0;
    @track interviewRate = 0;
    
    @track isLoading = true;
    @track error;
    
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
            this.hiredThisMonth = data.hiredThisMonth || 0;
            this.interviewRate = data.interviewRate || 0;
            
            this.isLoading = false;
            this.error = undefined;
            
            console.log('Metrics loaded:', data);
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
    
    // Computed properties for display
    get interviewRateDisplay() {
        return this.interviewRate + '%';
    }
    
    /**
     * Handles click events on summary cards
     * Fires custom event for parent component to filter pipeline table
     * 
     * @param {Event} event - Click event from card
     */
    handleCardClick(event) {
        const label = event.currentTarget.dataset.label;
        const value = event.currentTarget.dataset.value;
        
        // Console logging for debugging
        console.log('Summary card clicked:', {
            label: label,
            value: value,
            timestamp: new Date().toISOString()
        });
        
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
}
