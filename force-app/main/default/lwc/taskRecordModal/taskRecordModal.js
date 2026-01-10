import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

// Task fields
import ID_FIELD from '@salesforce/schema/Task.Id';
import SUBJECT_FIELD from '@salesforce/schema/Task.Subject';
import STATUS_FIELD from '@salesforce/schema/Task.Status';
import PRIORITY_FIELD from '@salesforce/schema/Task.Priority';
import DESCRIPTION_FIELD from '@salesforce/schema/Task.Description';
import ACTIVITY_DATE_FIELD from '@salesforce/schema/Task.ActivityDate';
import OWNER_ID_FIELD from '@salesforce/schema/Task.OwnerId';

const TASK_FIELDS = [
    SUBJECT_FIELD,
    STATUS_FIELD, 
    PRIORITY_FIELD,
    DESCRIPTION_FIELD,
    ACTIVITY_DATE_FIELD,
    OWNER_ID_FIELD
];

export default class TaskRecordModal extends NavigationMixin(LightningElement) {
    @api taskId;
    @api taskData; // For mock task data
    @api darkMode = false;
    @track isLoading = false;
    @track error = null;
    @track isEditing = false;

    wiredTaskResult;

    @wire(getRecord, { recordId: '$taskId', fields: TASK_FIELDS })
    wiredTask(result) {
        this.wiredTaskResult = result;
        if (result.data) {
            this.error = null;
        } else if (result.error) {
            this.error = result.error;
        }
    }

    get modalClass() {
        return this.darkMode ? 'slds-modal slds-fade-in-open task-modal dark-mode' : 'slds-modal slds-fade-in-open task-modal';
    }

    get task() {
        if (this.taskData) {
            // Mock task data
            return this.taskData;
        }
        return this.wiredTaskResult?.data;
    }

    get taskSubject() {
        if (this.taskData) return this.taskData.subject;
        return getFieldValue(this.task, SUBJECT_FIELD) || 'Task';
    }

    get taskStatus() {
        if (this.taskData) return this.taskData.status || 'Not Started';
        return getFieldValue(this.task, STATUS_FIELD) || 'Not Started';
    }

    get taskPriority() {
        if (this.taskData) return this.taskData.priority;
        return getFieldValue(this.task, PRIORITY_FIELD) || 'Normal';
    }

    get taskDescription() {
        if (this.taskData) return this.taskData.description || 'No description available';
        return getFieldValue(this.task, DESCRIPTION_FIELD) || 'No description available';
    }

    get taskDueDate() {
        if (this.taskData) return this.taskData.dueDate;
        const activityDate = getFieldValue(this.task, ACTIVITY_DATE_FIELD);
        return activityDate ? new Date(activityDate).toLocaleDateString() : 'No due date';
    }

    get priorityClass() {
        const priority = this.taskPriority?.toLowerCase();
        switch (priority) {
            case 'high': return 'priority-badge high';
            case 'medium': return 'priority-badge medium';
            case 'low': return 'priority-badge low';
            default: return 'priority-badge normal';
        }
    }

    get statusClass() {
        const status = this.taskStatus?.toLowerCase().replace(/\s+/g, '-');
        return `status-badge ${status}`;
    }

    handleClose(event) {
        
        // Prevent event bubbling if it exists
        if (event && event.stopPropagation) {
            event.stopPropagation();
        }
        if (event && event.preventDefault) {
            event.preventDefault();
        }
        
        // Dispatch close event to parent
        const closeEvent = new CustomEvent('close', { 
            bubbles: true,
            composed: true 
        });
        this.dispatchEvent(closeEvent);
    }

    handleBackdropClick() {
        this.handleClose();
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    handleEdit() {
        if (this.taskData) {
            // Mock task - show editable form instead of closing
            this.dispatchEvent(new ShowToastEvent({
                title: 'Edit Task',
                message: 'Task editing functionality would be available here in production.',
                variant: 'info'
            }));
            // Don't close the modal for mock tasks
        } else {
            // Real task - navigate to edit
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.taskId,
                    objectApiName: 'Task',
                    actionName: 'edit'
                }
            });
            this.handleClose();
        }
    }

    async handleComplete() {
        if (this.taskData) {
            // Mock task - show success message
            this.dispatchEvent(new ShowToastEvent({
                title: 'Task Completed',
                message: `Task "${this.taskSubject}" has been marked as completed.`,
                variant: 'success'
            }));
            
            // Dispatch event to parent to refresh task list
            const completeEvent = new CustomEvent('taskcompleted', {
                detail: { taskId: this.taskData.id }
            });
            this.dispatchEvent(completeEvent);
            
            this.handleClose();
            return;
        }

        // Real task - update status
        this.isLoading = true;
        try {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.taskId;
            fields[STATUS_FIELD.fieldApiName] = 'Completed';

            const recordInput = { fields };
            await updateRecord(recordInput);

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Task has been completed successfully!',
                variant: 'success'
            }));

            // Refresh the task data
            await refreshApex(this.wiredTaskResult);
            
            // Dispatch completion event
            const completeEvent = new CustomEvent('taskcompleted', {
                detail: { taskId: this.taskId }
            });
            this.dispatchEvent(completeEvent);
            
            this.handleClose();

        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to complete task: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }
}