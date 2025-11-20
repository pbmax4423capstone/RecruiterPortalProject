import { LightningElement, track } from 'lwc';
import getScheduledCalls from '@salesforce/apex/ScheduledCallsController.getScheduledCalls';
import deleteTask from '@salesforce/apex/ScheduledCallsController.deleteTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ScheduledCalls extends LightningElement {
    @track calls = [];
    @track error;
    @track isLoading = true;
    @track lastRefreshed = '';

    columns = [
        { 
            label: 'Candidate Name', 
            fieldName: 'relatedName', 
            type: 'text'
        },
        { 
            label: 'Subject', 
            fieldName: 'Subject', 
            type: 'text'
        },
        { 
            label: 'Due Date', 
            fieldName: 'ActivityDate', 
            type: 'date-local'
        },
        { 
            label: 'Owner', 
            fieldName: 'ownerName', 
            type: 'text'
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
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    connectedCallback() {
        this.loadCalls();
    }

    loadCalls() {
        this.isLoading = true;
        console.log('Loading scheduled calls...');
        getScheduledCalls()
            .then(data => {
                console.log('Received data:', data);
                console.log('Number of tasks:', data ? data.length : 0);
                this.calls = data.map(task => {
                    return {
                        ...task,
                        relatedName: task.What?.Name || task.Who?.Name || 'N/A',
                        ownerName: task.Owner?.Name || 'N/A'
                    };
                });
                this.error = undefined;
                this.isLoading = false;
                this.updateLastRefreshed();
            })
            .catch(error => {
                console.error('Error loading scheduled calls:', error);
                console.error('Error details:', JSON.stringify(error));
                this.error = error;
                this.calls = [];
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
        this.loadCalls();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        switch (actionName) {
            case 'edit':
                this.editTask(row);
                break;
            case 'delete':
                this.deleteTask(row);
                break;
        }
    }

    handleCellClick(event) {
        const taskId = event.detail.row.Id;
        if (taskId) {
            window.open(`/lightning/r/Task/${taskId}/view`, '_blank');
        }
    }

    editTask(row) {
        // Navigate to task edit page
        window.open(`/lightning/r/Task/${row.Id}/edit`, '_blank');
    }

    deleteTask(row) {
        if (confirm(`Are you sure you want to delete this task: ${row.Subject}?`)) {
            this.isLoading = true;
            deleteTask({ taskId: row.Id })
                .then(() => {
                    this.showToast('Success', 'Task deleted successfully', 'success');
                    this.loadCalls();
                })
                .catch(error => {
                    this.showToast('Error', 'Error deleting task: ' + error.body.message, 'error');
                    this.isLoading = false;
                });
        }
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
        return this.calls && this.calls.length > 0;
    }

    get noDataMessage() {
        return 'No scheduled calls for today.';
    }
}
