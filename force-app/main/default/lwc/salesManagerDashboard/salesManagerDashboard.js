import { LightningElement, track } from 'lwc';

export default class SalesManagerDashboard extends LightningElement {
    @track filterType = null;
    @track filterValue = null;
    @track filterLabel = '';

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
            'Hired This Month': { type: 'hired', label: ' - Hired This Month' },
            'Interview Rate': { type: 'presentations', label: ' - Presentation Meetings' }
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
