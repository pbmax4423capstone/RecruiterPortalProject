import { LightningElement, track } from 'lwc';
import getRecentActivity from '@salesforce/apex/RecentActivityController.getRecentActivity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecentActivity extends LightningElement {
    @track activities = [];
    @track error;
    @track isLoading = true;
    @track lastRefreshed = '';

    columns = [
        { 
            label: 'Related To', 
            fieldName: 'relatedName', 
            type: 'text'
        },
        { 
            label: 'Subject', 
            fieldName: 'Subject', 
            type: 'text'
        },
        { 
            label: 'Date', 
            fieldName: 'ActivityDate', 
            type: 'date-local'
        },
        { 
            label: 'Status', 
            fieldName: 'Status', 
            type: 'text'
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' }
                ]
            }
        }
    ];

    connectedCallback() {
        this.loadActivities();
    }

    loadActivities() {
        this.isLoading = true;
        console.log('Loading recent activity...');
        getRecentActivity()
            .then(data => {
                console.log('Received data:', data);
                console.log('Number of activities:', data ? data.length : 0);
                this.activities = data.map(task => {
                    return {
                        ...task,
                        relatedName: task.What?.Name || task.Who?.Name || 'N/A'
                    };
                });
                this.error = undefined;
                this.isLoading = false;
                this.updateLastRefreshed();
            })
            .catch(error => {
                console.error('Error loading recent activity:', error);
                console.error('Error details:', JSON.stringify(error));
                this.error = error;
                this.activities = [];
                this.isLoading = false;
            });
    }

    updateLastRefreshed() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('en-US', { 
            hour: 'numeric', 
            minute: '2-digit',
            hour12: true 
        });
        const dateString = now.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric' 
        });
        this.lastRefreshed = `${dateString}, ${timeString}`;
    }

    handleRefresh() {
        this.loadActivities();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'view') {
            this.viewTask(row);
        }
    }

    handleCellClick(event) {
        const taskId = event.detail.row.Id;
        if (taskId) {
            window.open(`/lightning/r/Task/${taskId}/view`, '_blank');
        }
    }

    viewTask(row) {
        window.open(`/lightning/r/Task/${row.Id}/view`, '_blank');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get hasData() {
        return this.activities && this.activities.length > 0;
    }
}
