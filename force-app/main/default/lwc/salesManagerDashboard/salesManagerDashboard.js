import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';

export default class SalesManagerDashboard extends LightningElement {
    @track filterType = null;
    @track filterValue = null;
    @track filterLabel = '';
    @track darkMode = false;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                DARK_MODE_CHANNEL,
                (message) => this.handleDarkModeChange(message)
            );
        }
    }

    handleDarkModeChange(message) {
        this.darkMode = message.darkModeEnabled;
    }

    get containerClass() {
        return this.darkMode ? 'sales-manager-dashboard dark-mode' : 'sales-manager-dashboard';
    }

    /**
     * Handles card click events from Sales Manager Key Metrics component
     * Filters the Candidate Kanban based on the clicked metric
     * 
     * @param {CustomEvent} event - Event containing label and value of clicked card
     */
    handleMetricsCardClick(event) {
        const { label, value } = event.detail;
        
        console.log('Dashboard received card click:', { label, value });

        // Map metric labels to filter types
        const filterMapping = {
            'Total Candidates': { type: 'all', label: ' - All Candidates' },
            'Upcoming Interviews': { type: 'upcoming', label: ' - Upcoming Interviews' },
            'Active Pipeline': { type: 'active', label: ' - Active Pipeline' },
            'On Contract B': { type: 'contractB', label: ' - On Contract B' },
            'On Contract A': { type: 'contractA', label: ' - On Contract A' },
            'Hired This Month': { type: 'hired', label: ' - Hired This Month' },
            'Completed Interviews This Month': { type: 'completedInterviews', label: ' - Completed Interviews This Month' }
        };

        const filter = filterMapping[label];
        
        if (filter) {
            this.filterType = filter.type;
            this.filterValue = value;
            this.filterLabel = filter.label;
            
            console.log('Applied filter:', {
                type: this.filterType,
                value: this.filterValue,
                label: this.filterLabel
            });
        }
    }

    /**
     * Clears the current filter and shows all candidates
     */
    clearFilter() {
        this.filterType = null;
        this.filterValue = null;
        this.filterLabel = '';
        
        console.log('Filter cleared - showing all candidates');
    }

    /**
     * Returns true if a filter is currently applied
     */
    get isFiltered() {
        return this.filterType !== null;
    }
}
