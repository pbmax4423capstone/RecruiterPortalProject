import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCurrentUserInfo from '@salesforce/apex/RecruiterDashboardController.getCurrentUserInfo';
import createScheduledCall from '@salesforce/apex/RecruiterDashboardController.createScheduledCall';

export default class RecruiterPortalHeader extends NavigationMixin(LightningElement) {
  // User Information
  @track userName = '';
  @track userFirstName = '';
  @track userEmail = '';
  @track userId = '';
  @track userContactId = '';

  // Modal states
  @track showCreateTicketModal = false;
  @track showScheduleInterviewModal = false;
  @track showCreateCandidateModal = false;
  @track showScheduleCallModal = false;
  @track showRescheduleFlowModal = false;
  @track showRescheduleFlowModal = false;

  // Schedule Call form fields
  @track callSubject = '';
  @track callWhoId = '';
  @track callWhatId = '';
  @track callActivityDate = null;
  @track callStatus = 'Not Started';
  @track callPriority = 'Normal';

  connectedCallback() {
    this.fetchCurrentUser();
  }

  fetchCurrentUser() {
    getCurrentUserInfo()
      .then(userInfo => {
        if (!userInfo) {
          console.error('No user info returned');
          return;
        }
        
        // Set reactive properties
        this.userName = userInfo.name || 'Unknown';
        this.userEmail = userInfo.email || '';
        this.userId = userInfo.id || '';
        this.userContactId = userInfo.contactId || '';
        this.userFirstName = userInfo.firstName || 'User';
        
        console.log('User info loaded:', this.userFirstName);
        console.log('User ContactId:', this.userContactId);
      })
      .catch(error => {
        console.error('Error fetching user info:', error);
        this.userFirstName = 'User';
      });
  }

  // Computed properties for header
  get timeBasedGreeting() {
    const now = new Date();
    const hour = now.getHours();
    
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  get computedUserFirstName() {
    // Use firstName from backend if available
    if (this.userFirstName) {
      return this.userFirstName;
    }
    if (!this.userName) {
      return 'Recruiter';
    }
    // Extract first name from full name as fallback
    const nameParts = this.userName.trim().split(' ');
    return nameParts[0];
  }

  get statusOptions() {
    return [
      { label: 'Not Started', value: 'Not Started' },
      { label: 'In Progress', value: 'In Progress' },
      { label: 'Completed', value: 'Completed' },
      { label: 'Waiting on someone else', value: 'Waiting on someone else' },
      { label: 'Deferred', value: 'Deferred' }
    ];
  }

  get priorityOptions() {
    return [
      { label: 'High', value: 'High' },
      { label: 'Normal', value: 'Normal' },
      { label: 'Low', value: 'Low' }
    ];
  }

  // Button event handlers
  handleCreateTicket() {
    console.log('Create Ticket clicked');
    this.showCreateTicketModal = true;
  }

  closeCreateTicketModal() {
    this.showCreateTicketModal = false;
  }

  handleTicketSuccess(event) {
    const caseId = event.detail.id;
    console.log('Case created successfully with ID:', caseId);
    this.showCreateTicketModal = false;
    
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: 'Case created successfully with ID: ' + caseId,
        variant: 'success'
      })
    );
  }

  handleTicketError(event) {
    console.error('Error creating case:', event.detail);
    const errorMessage = event.detail?.detail || event.detail?.message || 'Unknown error';
    
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Error Creating Case',
        message: errorMessage,
        variant: 'error',
        mode: 'sticky'
      })
    );
  }

  handleScheduleCall() {
    console.log('Schedule Call clicked - opening modal');
    this.showScheduleCallModal = true;
  }

  closeScheduleCallModal() {
    this.showScheduleCallModal = false;
    // Reset form
    this.callSubject = '';
    this.callWhoId = '';
    this.callWhatId = '';
    this.callActivityDate = null;
    this.callStatus = 'Not Started';
    this.callPriority = 'Normal';
  }

  // Reschedule Calls Handlers
  handleRescheduleCalls() {
    console.log('Opening Reschedule Calls flow');
    this.showRescheduleFlowModal = true;
  }

  closeRescheduleFlowModal() {
    this.showRescheduleFlowModal = false;
  }

  handleRescheduleFlowStatusChange(event) {
    console.log('Flow status:', event.detail.status);
    if (event.detail.status === 'FINISHED') {
      this.showRescheduleFlowModal = false;
      this.showToast('Success', 'Tasks rescheduled successfully', 'success');
    }
  }

  handleCallSubjectChange(event) {
    this.callSubject = event.target.value;
  }

  handleCallWhoIdChange(event) {
    console.log('WhoId changed:', event.detail);
    const recordId = event.detail.recordId;
    this.callWhoId = recordId;
  }

  handleCallWhatIdChange(event) {
    console.log('WhatId changed:', event.detail);
    const recordId = event.detail.recordId;
    this.callWhatId = recordId;
  }

  handleCallActivityDateChange(event) {
    this.callActivityDate = event.target.value;
  }

  handleCallStatusChange(event) {
    this.callStatus = event.target.value;
  }

  handleCallPriorityChange(event) {
    this.callPriority = event.target.value;
  }

  handleScheduleCallSubmit() {
    if (!this.callSubject || !this.callActivityDate) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Please fill in Subject and Due Date',
          variant: 'error'
        })
      );
      return;
    }

    const taskData = {
      Subject: this.callSubject,
      ActivityDate: this.callActivityDate,
      Status: this.callStatus,
      Priority: this.callPriority,
      TaskSubtype: 'Call',
      Type: 'Call'
    };
    
    if (this.callWhoId) {
      taskData.WhoId = this.callWhoId;
      console.log('Adding WhoId to taskData:', this.callWhoId);
    }
    if (this.callWhatId) {
      taskData.WhatId = this.callWhatId;
      console.log('Adding WhatId to taskData:', this.callWhatId);
    }

    console.log('Sending taskData to Apex:', JSON.stringify(taskData));
    createScheduledCall({ taskData: taskData })
      .then(result => {
        console.log('Task created:', result);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Call scheduled successfully!',
            variant: 'success'
          })
        );
        this.closeScheduleCallModal();
      })
      .catch(error => {
        console.error('Error creating task:', error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: error.body?.message || 'Error scheduling call',
            variant: 'error',
            mode: 'sticky'
          })
        );
      });
  }

  handleCreateCandidate() {
    console.log('Create Candidate clicked - opening Quick Action modal');
    this.showCreateCandidateModal = true;
  }

  closeCreateCandidateModal() {
    this.showCreateCandidateModal = false;
  }

  handleCreateCandidateFlowStatusChange(event) {
    console.log('Flow status changed:', event.detail.status);
    if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
      this.showCreateCandidateModal = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: 'Candidate created successfully!',
          variant: 'success'
        })
      );
    }
  }

  handleScheduleInterview() {
    console.log('Schedule Interview clicked');
    this.showScheduleInterviewModal = true;
  }

  closeScheduleInterviewModal() {
    this.showScheduleInterviewModal = false;
  }

  handleInterviewSuccess(event) {
    const interviewId = event.detail.id;
    console.log('Interview scheduled successfully with ID:', interviewId);
    this.showScheduleInterviewModal = false;
    
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: 'Interview scheduled successfully!',
        variant: 'success'
      })
    );
  }

  handleInterviewError(event) {
    console.error('Error scheduling interview:', event.detail);
    const errorMessage = event.detail?.detail || event.detail?.message || 'Unknown error';
    
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Error Scheduling Interview',
        message: errorMessage,
        variant: 'error',
        mode: 'sticky'
      })
    );
  }
}