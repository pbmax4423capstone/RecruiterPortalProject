import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivities from '@salesforce/apex/CandidateActivityController.getActivities';
import completeTask from '@salesforce/apex/CandidateActivityController.completeTask';

export default class CandidateActivityHistory extends NavigationMixin(LightningElement) {
    @api recordId;
    activities = [];
    error;
    wiredActivitiesResult;
    refreshInterval;
    sortedBy;
    sortDirection;

    columns = [
        { 
            label: 'Subject', 
            fieldName: 'Subject', 
            type: 'text',
            wrapText: true,
            sortable: true
        },
        { 
            label: 'Type', 
            fieldName: 'ActivityType', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Status', 
            fieldName: 'Status', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Priority', 
            fieldName: 'Priority', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Due Date', 
            fieldName: 'ActivityDate', 
            type: 'date',
            sortable: true
        },
        { 
            label: 'Assigned To', 
            fieldName: 'OwnerName', 
            type: 'text',
            sortable: true
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Complete', name: 'complete' }
                ]
            }
        }
    ];

    connectedCallback() {
        // Set up auto-refresh every 30 seconds
        this.refreshInterval = setInterval(() => {
            refreshApex(this.wiredActivitiesResult);
        }, 30000);
    }

    disconnectedCallback() {
        // Clear interval when component is destroyed
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }

    @wire(getActivities, { candidateId: '$recordId' })
    wiredActivities(result) {
        this.wiredActivitiesResult = result;
        if (result.data) {
            this.activities = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.activities = [];
        }
    }

    get hasActivities() {
        return this.activities && this.activities.length > 0;
    }

    get activityCount() {
        return this.activities ? this.activities.length : 0;
    }

    get openTasks() {
        if (!this.activities) return [];
        return this.activities.filter(activity => 
            activity.Status !== 'Completed' && activity.Status !== 'Closed'
        );
    }

    get completedActivities() {
        if (!this.activities) return [];
        return this.activities.filter(activity => 
            activity.Status === 'Completed' || activity.Status === 'Closed'
        );
    }

    get hasOpenTasks() {
        return this.openTasks.length > 0;
    }

    get hasCompletedActivities() {
        return this.completedActivities.length > 0;
    }

    get openTasksCount() {
        return this.openTasks.length;
    }

    get completedActivitiesCount() {
        return this.completedActivities.length;
    }

    handleNewTask() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: `WhatId=${this.recordId}`,
                nooverride: '1'
            }
        });
        // Refresh after a short delay to catch new tasks
        setTimeout(() => {
            refreshApex(this.wiredActivitiesResult);
        }, 2000);
    }

    handleNewCall() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Event',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: `WhatId=${this.recordId}`,
                nooverride: '1'
            }
        });
        // Refresh after a short delay to catch new calls
        setTimeout(() => {
            refreshApex(this.wiredActivitiesResult);
        }, 2000);
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortedBy = fieldName;
        this.sortDirection = sortDirection;
        this.sortData(fieldName, sortDirection);
    }

    sortData(fieldName, sortDirection) {
        let sortedData = [...this.activities];
        let isReverse = sortDirection === 'asc' ? 1 : -1;

        sortedData.sort((a, b) => {
            let aVal = a[fieldName] ? a[fieldName] : '';
            let bVal = b[fieldName] ? b[fieldName] : '';
            
            if (typeof aVal === 'string') {
                aVal = aVal.toLowerCase();
                bVal = bVal.toLowerCase();
            }
            
            return aVal > bVal ? isReverse : aVal < bVal ? -isReverse : 0;
        });

        this.activities = sortedData;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'view':
                this.handleViewRecord(row.Id, row.ActivityType);
                break;
            case 'complete':
                this.handleCompleteTask(row.Id, row.ActivityType);
                break;
        }
    }

    handleViewRecord(recordId, activityType) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: activityType === 'Task' ? 'Task' : 'Event',
                actionName: 'view'
            }
        });
    }

    handleCompleteTask(recordId, activityType) {
        // Only allow completing Tasks, not Events
        if (activityType !== 'Task') {
            this.showToast('Info', 'Only tasks can be marked as complete', 'info');
            return;
        }

        completeTask({ taskId: recordId })
            .then(() => {
                this.showToast('Success', 'Task marked as complete', 'success');
                // Refresh the data
                return refreshApex(this.wiredActivitiesResult);
            })
            .catch(error => {
                this.showToast('Error', 'Error completing task: ' + (error.body?.message || error.message), 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
