import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import DASHBOARD_FILTER_CHANNEL from '@salesforce/messageChannel/DashboardFilterChannel__c';
import getCurrentUserCallDetails from '@salesforce/apex/RecruiterDashboardController.getCurrentUserCallDetails';
import getTaskDetails from '@salesforce/apex/RecruiterDashboardController.getTaskDetails';
import updateTaskRecord from '@salesforce/apex/RecruiterDashboardController.updateTaskRecord';
import createScheduledCall from '@salesforce/apex/RecruiterDashboardController.createScheduledCall';

export default class ScheduledCallsModal extends LightningElement {
  @wire(MessageContext)
  messageContext;
  
  @track scheduledCalls = [];
  @track pastDueCalls = [];
  @track isLoading = false;
  @track showRecordModal = false;
  @track selectedTaskId = null;
  @track taskRecord = null;
  @api isOpen = false; // Legacy property for backward compatibility
  @api embedded = false; // True when embedded in unified dashboard
  @api darkMode = false;
  @track showFollowUpModal = false;
  salesManagerFilter = 'All Sales Managers';
  dateRangeFilter = 'THIS_MONTH';
  @track followUpSubject = '';
  @track followUpDate = null;
  @track selectedCallResults = [];
  subscription = null;

  statusOptions = [
    { label: 'Not Started', value: 'Not Started' },
    { label: 'In Progress', value: 'In Progress' },
    { label: 'Completed', value: 'Completed' },
    { label: 'Waiting on someone else', value: 'Waiting on someone else' },
    { label: 'Deferred', value: 'Deferred' }
  ];

  priorityOptions = [
    { label: 'High', value: 'High' },
    { label: 'Normal', value: 'Normal' },
    { label: 'Low', value: 'Low' }
  ];

  @track callResultOptions = [
    { label: 'Left Voicemail', value: 'Left Voicemail', checked: false },
    { label: 'No Answer', value: 'No Answer', checked: false },
    { label: 'Busy', value: 'Busy', checked: false },
    { label: 'Wrong Number', value: 'Wrong Number', checked: false },
    { label: 'Not Interested', value: 'Not Interested', checked: false },
    { label: 'Interested - Follow Up', value: 'Interested - Follow Up', checked: false },
    { label: 'Meeting Scheduled', value: 'Meeting Scheduled', checked: false }
  ];
  // Computed properties for counts
  get scheduledCallsCount() {
    return this.scheduledCalls.length;
  }

  get pastDueCallsCount() {
    return this.pastDueCalls.length;
  }

  get hasScheduledCalls() {
    return this.scheduledCalls.length > 0;
  }

  get hasPastDueCalls() {
    return this.pastDueCalls.length > 0;
  }

  get hasContactOrRelated() {
    return this.taskRecord && (this.taskRecord.Who || this.taskRecord.What);
  }

  get modalClass() {
    return this.darkMode ? 'slds-modal slds-fade-in-open slds-modal_large dark-mode' : 'slds-modal slds-fade-in-open slds-modal_large';
  }

  get containerClass() {
    return this.darkMode ? 'calls-component-container dark-mode' : 'calls-component-container';
  }

  // Load calls when component renders
  connectedCallback() {
    this.subscribeToMessageChannels();
    
    // Only auto-load if not embedded (standalone mode)
    if (!this.embedded) {
      this.loadAllCalls();
    }
  }

  subscribeToMessageChannels() {
    // Subscribe to dark mode
    subscribe(
      this.messageContext,
      DARK_MODE_CHANNEL,
      (message) => this.handleDarkModeChange(message)
    );
    
    // Subscribe to filter changes (for embedded mode)
    subscribe(
      this.messageContext,
      DASHBOARD_FILTER_CHANNEL,
      (message) => this.handleFilterChange(message)
    );
  }

  handleDarkModeChange(message) {
    this.darkMode = message.darkModeEnabled;
  }

  handleFilterChange(message) {
    if (!this.embedded) return;
    
    this.salesManagerFilter = message.salesManagerFilter || 'All Sales Managers';
    this.dateRangeFilter = message.dateRangeFilter || 'THIS_MONTH';
    
    if (message.refreshRequested) {
      this.refreshData();
    }
  }

  // Public API method for parent to trigger refresh
  @api
  async refreshData() {
    try {
      await this.loadAllCalls();
      // Dispatch event to notify parent that refresh is complete
      this.dispatchEvent(new CustomEvent('refreshcomplete', {
        detail: { success: true }
      }));
      return Promise.resolve();
    } catch (error) {
      this.dispatchEvent(new CustomEvent('refreshcomplete', {
        detail: { success: false, error: error }
      }));
      return Promise.reject(error);
    }
  }

  // Handle call card click to open record modal
  async handleCallClick(event) {
    event.stopPropagation();
    const taskId = event.currentTarget.dataset.taskId;
    if (taskId) {
      this.selectedTaskId = taskId;
      this.showRecordModal = true;
      try {
        this.taskRecord = await getTaskDetails({ taskId: taskId });
        
        // Initialize checkbox states based on existing CallDisposition
        if (this.taskRecord.CallDisposition) {
          const existingResults = this.taskRecord.CallDisposition.split(';').map(r => r.trim());
          this.selectedCallResults = existingResults;
          this.callResultOptions = this.callResultOptions.map(option => ({
            ...option,
            checked: existingResults.includes(option.value)
          }));
        } else {
          // Reset all checkboxes
          this.selectedCallResults = [];
          this.callResultOptions = this.callResultOptions.map(option => ({
            ...option,
            checked: false
          }));
        }
      } catch (error) {
        this.showToast('Error', 'Failed to load task details', 'error');
        this.closeRecordModal();
      }
    }
  }

  // Close record modal
  closeRecordModal() {
    this.showRecordModal = false;
    this.selectedTaskId = null;
    this.taskRecord = null;
  }

  // Handle field changes
  handleFieldChange(event) {
    const field = event.target.name;
    const value = event.target.value || event.detail.value;
    this.taskRecord = { ...this.taskRecord, [field]: value };
  }

  // Handle call result checkbox changes
  handleCallResultChange(event) {
    const value = event.target.value;
    const checked = event.target.checked;
    
    this.callResultOptions = this.callResultOptions.map(option => {
      if (option.value === value) {
        return { ...option, checked: checked };
      }
      return option;
    });

    // Update selected results array
    if (checked) {
      this.selectedCallResults = [...this.selectedCallResults, value];
    } else {
      this.selectedCallResults = this.selectedCallResults.filter(r => r !== value);
    }

    // Update task record with comma-separated values
    this.taskRecord = { 
      ...this.taskRecord, 
      CallDisposition: this.selectedCallResults.join('; ') 
    };
  }

  // Handle Schedule Follow Up button click
  handleScheduleFollowUp() {
    // Set default subject
    const contactName = this.taskRecord?.Who?.Name || '';
    this.followUpSubject = `Follow up with ${contactName}`.trim();
    this.followUpDate = null;
    this.showFollowUpModal = true;
  }

  // Close follow up modal
  closeFollowUpModal() {
    this.showFollowUpModal = false;
    this.followUpSubject = '';
    this.followUpDate = null;
  }

  // Handle follow up field changes
  handleFollowUpFieldChange(event) {
    const field = event.target.name;
    const value = event.target.value;
    if (field === 'followUpSubject') {
      this.followUpSubject = value;
    } else if (field === 'followUpDate') {
      this.followUpDate = value;
    }
  }

  // Handle save task
  async handleSaveTask() {
    try {
      await updateTaskRecord({ 
        taskId: this.selectedTaskId,
        subject: this.taskRecord.Subject,
        status: this.taskRecord.Status,
        activityDate: this.taskRecord.ActivityDate,
        priority: this.taskRecord.Priority,
        description: this.taskRecord.Description,
        callDisposition: this.taskRecord.CallDisposition
      });
      this.showToast('Success', 'Call updated successfully', 'success');
      this.closeRecordModal();
      this.loadAllCalls();
    } catch (error) {
      this.showToast('Error', 'Failed to save task: ' + (error.body?.message || error.message), 'error');
    }
  }

  // Handle save follow up call
  async handleSaveFollowUp() {
    if (!this.followUpSubject || !this.followUpDate) {
      this.showToast('Error', 'Please fill in Subject and Due Date', 'error');
      return;
    }

    const taskData = {
      Subject: this.followUpSubject,
      ActivityDate: this.followUpDate,
      Status: 'Not Started',
      Priority: 'Normal',
      TaskSubtype: 'Call',
      Type: 'Call'
    };
    
    // Add WhoId if exists
    if (this.taskRecord?.WhoId) {
      taskData.WhoId = this.taskRecord.WhoId;
    }
    // Add WhatId if exists
    if (this.taskRecord?.WhatId) {
      taskData.WhatId = this.taskRecord.WhatId;
    }

    try {
      await createScheduledCall({ taskData: taskData });
      this.showToast('Success', 'Follow up call scheduled successfully!', 'success');
      this.closeFollowUpModal();
      this.loadAllCalls();
    } catch (error) {
      this.showToast('Error', 'Failed to schedule follow up: ' + (error.body?.message || error.message), 'error');
    }
  }

  // Public method for external components to close modal
  closeModal() {
    this.showRecordModal = false;
    this.selectedTaskId = null;
    // Dispatch event to notify parent component
    this.dispatchEvent(new CustomEvent('close'));
  }

  // Load both scheduled and past due calls
  async loadAllCalls() {
    this.isLoading = true;
    
    try {
      // Fetch scheduled and past due calls in parallel
      const [scheduledData, pastDueData] = await Promise.all([
        getCurrentUserCallDetails({ callType: 'scheduled' }),
        getCurrentUserCallDetails({ callType: 'pastdue' })
      ]);

      this.scheduledCalls = this.formatCallsForDisplay(scheduledData);
      this.pastDueCalls = this.formatCallsForDisplay(pastDueData);
      
    } catch (error) {
      this.showToast('Error', 'Failed to load calls: ' + (error.body?.message || error.message), 'error');
    } finally {
      this.isLoading = false;
    }
  }

  // Format calls for display
  formatCallsForDisplay(calls) {
    if (!calls || calls.length === 0) {
      return [];
    }

    return calls.map(call => {
      let formattedDate = 'No date';
      let formattedTime = '';

      try {
        if (call.dueDate) {
          const dueDate = new Date(call.dueDate);
          formattedDate = dueDate.toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
          });
          formattedTime = dueDate.toLocaleTimeString('en-US', {
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
          });
        }
      } catch (error) {
        // Date formatting failed, continue with empty values
      }

      // Better candidate name resolution
      const candidateName = call.relatedPerson || call.relatedTo || call.subject || 'Unknown Contact';

      return {
        id: call.id,
        candidateName: candidateName,
        subject: call.subject,
        formattedDate: formattedDate,
        formattedTime: formattedTime,
        dueDate: call.dueDate,
        status: call.status,
        description: call.description,
        relatedTo: call.relatedTo,
        relatedToId: call.relatedToId,
        relatedPerson: call.relatedPerson,
        relatedPersonId: call.relatedPersonId,
        daysOverdue: call.daysOverdue || 0
      };
    });
  }

  // Helper method to show toast messages
  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }
}