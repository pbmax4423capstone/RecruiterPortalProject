import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import getScheduledCalls from '@salesforce/apex/ScheduledCallsController.getScheduledCalls';
import deleteTask from '@salesforce/apex/ScheduledCallsController.deleteTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ScheduledCalls extends NavigationMixin(LightningElement) {
    @track scheduledCalls = [];
    @track pastDueCalls = [];
    @track error;
    @track isLoading = true;
    @track lastRefreshed = '';
    @track showEditModal = false;
    @track editTaskId = null;
    @track editTaskClientName = null;
    @track showReschedule = false;
    @track rescheduleDate = null;
    @track rescheduleTime = null;

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
                    { label: 'View Details', name: 'view' },
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
        // Force refresh - queries only Call tasks with TaskSubtype = 'Call'
        this.isLoading = true;
        console.log('🔄 [ScheduledCalls] Loading calls for current user...');
        console.log('🔄 [ScheduledCalls] Calling ScheduledCallsController.getScheduledCalls()');
        getScheduledCalls()
            .then(data => {
                console.log('✅ [ScheduledCalls] Received data from controller:', data);
                console.log('✅ [ScheduledCalls] Scheduled:', data.scheduled?.length || 0, 'Past Due:', data.pastDue?.length || 0);
                
                // Map scheduled calls
                this.scheduledCalls = (data.scheduled || []).map(task => {
                    return {
                        ...task,
                        relatedName: task.What?.Name || task.Who?.Name || 'N/A',
                        ownerName: task.Owner?.Name || 'N/A'
                    };
                });
                
                // Map past due calls
                this.pastDueCalls = (data.pastDue || []).map(task => {
                    return {
                        ...task,
                        relatedName: task.What?.Name || task.Who?.Name || 'N/A',
                        ownerName: task.Owner?.Name || 'N/A'
                    };
                });
                
                console.log('Scheduled calls:', this.scheduledCalls.length);
                console.log('Past due calls:', this.pastDueCalls.length);
                
                this.error = undefined;
                this.isLoading = false;
                this.updateLastRefreshed();
            })
            .catch(error => {
                console.error('Error loading scheduled calls:', error);
                console.error('Error details:', JSON.stringify(error));
                this.error = error;
                this.scheduledCalls = [];
                this.pastDueCalls = [];
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
            case 'view':
                this.viewDetails(row);
                break;
        }
    }

    viewDetails(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Task',
                actionName: 'view'
            }
        });
    }

    deleteTask(row) {
        this.editTaskId = row.Id;
        this.editTaskClientName = row.relatedName;
        this.showEditModal = true;
    }

    closeEditModal() {
        this.showEditModal = false;
        this.editTaskId = null;
        this.editTaskClientName = null;
        this.showReschedule = false;
        this.rescheduleDate = null;
        this.rescheduleTime = null;
    }

    handleCompleteCall() {
        this.isLoading = true;
        const fields = {};
        fields.Id = this.editTaskId;
        fields.Status = 'Completed';
        fields.IsClosed = true;
        
        updateRecord({ fields })
            .then(() => {
                this.showToast('Success', 'Call marked as complete', 'success');
                this.closeEditModal();
                this.loadCalls();
            })
            .catch(error => {
                this.showToast('Error', 'Error completing call: ' + (error.body?.message || error.message), 'error');
                this.isLoading = false;
            });
    }

    handleShowReschedule() {
        this.showReschedule = true;
    }

    handleCancelReschedule() {
        this.showReschedule = false;
        this.rescheduleDate = null;
        this.rescheduleTime = null;
    }

    handleRescheduleDateChange(event) {
        this.rescheduleDate = event.target.value;
    }

    handleRescheduleTimeChange(event) {
        this.rescheduleTime = event.target.value;
    }

    handleSaveReschedule() {
        if (!this.rescheduleDate) {
            this.showToast('Error', 'Please select a date', 'error');
            return;
        }

        this.isLoading = true;
        const fields = {};
        fields.Id = this.editTaskId;
        fields.ActivityDate = this.rescheduleDate;
        
        updateRecord({ fields })
            .then(() => {
                this.showToast('Success', 'Call rescheduled successfully', 'success');
                this.closeEditModal();
                this.loadCalls();
            })
            .catch(error => {
                this.showToast('Error', 'Error rescheduling call: ' + (error.body?.message || error.message), 'error');
                this.isLoading = false;
            });
    }

    handleEditSuccess() {
        this.showToast('Success', 'Task updated successfully', 'success');
        this.closeEditModal();
        this.loadCalls();
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

    get hasScheduledCalls() {
        return this.scheduledCalls && this.scheduledCalls.length > 0;
    }

    get hasPastDueCalls() {
        return this.pastDueCalls && this.pastDueCalls.length > 0;
    }

    get scheduledCount() {
        return this.scheduledCalls ? this.scheduledCalls.length : 0;
    }

    get pastDueCount() {
        return this.pastDueCalls ? this.pastDueCalls.length : 0;
    }
}