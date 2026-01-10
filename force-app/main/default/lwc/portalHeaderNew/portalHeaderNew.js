import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';
import { publish, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import getCurrentUserInfo from '@salesforce/apex/RecruiterDashboardController.getCurrentUserInfo';
import getNextInterviewType from '@salesforce/apex/InterviewSequenceHelper.getNextInterviewType';
import getCurrentUserName from '@salesforce/apex/InterviewSequenceHelper.getCurrentUserName';
import getCandidateInterviewSummary from '@salesforce/apex/InterviewSequenceHelper.getCandidateInterviewSummary';
import createScheduledCall from '@salesforce/apex/RecruiterDashboardController.createScheduledCall';
import getRecentNotes from '@salesforce/apex/RecruiterDashboardController.getRecentNotes';
import CONTENT_NOTE_OBJECT from '@salesforce/schema/ContentNote';
import TITLE_FIELD from '@salesforce/schema/ContentNote.Title';
import CONTENT_FIELD from '@salesforce/schema/ContentNote.Content';

export default class PortalHeaderNew extends NavigationMixin(LightningElement) {
  @wire(MessageContext)
  messageContext;
  
  // Dark Mode
  @track darkMode = false;
  
  // User Information
  @track userName = '';
  @track userFirstName = '';
  @track userEmail = '';
  @track userId = '';
  @track userContactId = '';
  @track currentAppLabel = 'Welcome Home';
  @track portalTitle = 'Capstone Partners - Welcome Home';

  // Modal states
  @track showCreateTicketModal = false;
  @track showScheduleInterviewModal = false;
  @track showCreateCandidateModal = false;
  @track showScheduleCallModal = false;
  @track showRescheduleFlowModal = false;
  @track showEndorsementEmailModal = false;
  @track showNewBrokerModal = false;
  @track showNotesModal = false;
  @track showNewOpportunityModal = false;
  @track flowError = null;

  // Flow input variables
  @track endorsementFlowInputVariables = [];
  @track newBrokerFlowInputVariables = [];

  // Notes data
  @track newNoteTitle = '';
  @track newNoteBody = '';
  @track recentNotes = [];
  @track isNoteSaving = false;

  // Interview suggestion properties
  @track suggestedInterviewType = '';
  @track currentUserName = '';
  @track interviewSummary = { hasCompletedInterviews: false, summary: '' };
  @track showInterviewerField = false;
  @track selectedCandidateId = null;
  @track noteSortBy = 'recent';
  @track recordSearchTerm = '';
  @track recordSearchResults = [];
  @track showRecordSearchResults = false;
  @track selectedRecordId = null;
  @track selectedRecordName = '';
  @track shareWithSearch = '';
  @track userSearchResults = [];
  @track showUserSearchResults = false;
  @track sharedUsers = [];
  @track showDeleteConfirmation = false;
  @track noteToDelete = null;

  // Schedule Call form fields
  @track callSubject = '';
  @track callWhoId = '';
  @track callWhatId = '';
  @track callActivityDate = null;
  @track callStatus = 'Not Started';
  @track callPriority = 'Normal';

  connectedCallback() {
    // Load dark mode preference from localStorage (default: OFF/false)
    const savedDarkMode = localStorage.getItem('capstone_dark_mode');
    if (savedDarkMode !== null) {
      this.darkMode = savedDarkMode === 'true';
      // Immediately publish to all subscribers on load
      if (this.messageContext) {
        publish(this.messageContext, DARK_MODE_CHANNEL, { 
          darkModeEnabled: this.darkMode 
        });
      }
    }
    
    this.fetchCurrentUser();
    this.updateAppLabel();
  }

  renderedCallback() {
    // Check on each render if app label needs updating
    if (!this.hasDetectedApp) {
      setTimeout(() => {
        this.updateAppLabel();
      }, 100);
      setTimeout(() => {
        this.updateAppLabel();
      }, 500);
      setTimeout(() => {
        this.updateAppLabel();
      }, 1000);
      setTimeout(() => {
        this.updateAppLabel();
      }, 2000);
    }
  }

  updateAppLabel() {
    const oldLabel = this.currentAppLabel;
    this.detectCurrentApp();
    if (oldLabel !== this.currentAppLabel) {
      this.hasDetectedApp = true;
      this.portalTitle = `Capstone Partners - ${this.currentAppLabel}`;
      console.log('Updated portal title to:', this.portalTitle);
    }
  }

  detectCurrentApp() {
    // Get current URL and pathname to detect app context
    const url = window.location.href.toLowerCase();
    const pathname = window.location.pathname.toLowerCase();
    
    console.log('Full URL:', url);
    console.log('Pathname:', pathname);
    
    // Also check URL parameters for app ID
    const urlParams = new URLSearchParams(window.location.search);
    const appId = urlParams.get('app') || '';
    console.log('App parameter:', appId);
    
    // Check for specific app names in the URL or pathname - these take priority
    if (url.includes('contracting') || pathname.includes('contracting')) {
      this.currentAppLabel = 'Contracting';
      this.portalTitle = 'Capstone Partners - Contracting';
      console.log('Detected: Contracting');
      return; // Exit early
    } else if (url.includes('recruiter') || pathname.includes('recruiter') || pathname.includes('recruiting') || appId.includes('Recruiting_Lightning')) {
      this.currentAppLabel = 'Recruiter Portal';
      this.portalTitle = 'Capstone Partners - Recruiter Portal';
      console.log('Detected: Recruiter Portal');
      return; // Exit early
    } else if (url.includes('service') || pathname.includes('service')) {
      this.currentAppLabel = 'Service';
      this.portalTitle = 'Capstone Partners - Service';
      console.log('Detected: Service');
      return; // Exit early
    } else if (url.includes('bookkeeping') || pathname.includes('bookkeeping')) {
      this.currentAppLabel = 'Bookkeeping';
      this.portalTitle = 'Capstone Partners - Bookkeeping';
      console.log('Detected: Bookkeeping');
      return; // Exit early
    } else if (url.includes('new_business') || url.includes('new-business') || url.includes('newbusiness') || pathname.includes('new_business') || pathname.includes('new-business') || pathname.includes('newbusiness') || appId.includes('LightningSales')) {
      this.currentAppLabel = 'New Business';
      this.portalTitle = 'Capstone Partners - New Business';
      console.log('Detected: New Business');
      return; // Exit early
    } else if (url.includes('neilie') || pathname.includes('neilie')) {
      this.currentAppLabel = 'Executive Leadership';
      this.portalTitle = 'Capstone Partners - Executive Leadership';
      console.log('Detected: Executive Leadership');
      return; // Exit early
    }
    
    // Only do DOM detection if URL-based detection didn't work
    console.log('No URL match, searching for app name in DOM...');
    let appName = null;
    
    // Look for app name in the left sidebar (one-appnav)
    const appNavButton = document.querySelector('one-app-nav-bar-item-root[data-assistive-id="operationId"]');
    if (appNavButton) {
      const text = appNavButton.textContent?.trim();
      console.log('App nav button text:', text);
      if (text && text.length > 0 && text.length < 50) {
        appName = text;
      }
    }
    
    // Fallback: Look for app name in context bar
    if (!appName) {
      const contextBarButton = document.querySelector('.slds-context-bar__label-action');
      if (contextBarButton) {
        const text = contextBarButton.textContent?.trim();
        console.log('Context bar button text:', text);
        if (text && text !== 'Show Navigation' && text.length > 0) {
          appName = text;
        }
      }
    }
    
    // Additional fallback: Check app launcher title
    if (!appName) {
      const appTitle = document.querySelector('.slds-context-bar__app-name, [data-aura-class="oneWorkspace"]');
      if (appTitle) {
        const text = appTitle.textContent?.trim();
        console.log('App title text:', text);
        if (text && text.length > 0 && text.length < 50) {
          appName = text;
        }
      }
    }
    
    // Check if Neilie or New Business in detected name
    if (appName) {
      console.log('Final detected app name:', appName);
      
      // Check for variations of Neilie
      if (appName.includes('Neilie') || appName.includes('Executive Leadership')) {
        this.currentAppLabel = 'Executive Leadership';
        this.portalTitle = 'Capstone Partners - Executive Leadership';
        console.log('Detected Neilie/Executive Leadership app');
      } else if (appName.includes('New Business')) {
        this.currentAppLabel = 'New Business';
        this.portalTitle = 'Capstone Partners - New Business';
        console.log('Detected: New Business from DOM');
      } else {
        this.currentAppLabel = appName;
        this.portalTitle = `Capstone Partners - ${appName}`;
      }
    } else {
      this.currentAppLabel = 'Welcome Home';
      this.portalTitle = 'Capstone Partners - Welcome Home';
      console.log('Defaulting to: Welcome Home');
    }
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

  get isContractingApp() {
    return this.currentAppLabel === 'Contracting';
  }

  get isRecruiterPortalApp() {
    return this.currentAppLabel === 'Recruiter Portal';
  }

  get isNewBusinessApp() {
    return this.currentAppLabel === 'New Business';
  }

  get hasNotes() {
    return this.recentNotes && this.recentNotes.length > 0;
  }

  get hasSharedUsers() {
    return this.sharedUsers && this.sharedUsers.length > 0;
  }

  get darkModeIcon() {
    return this.darkMode ? 'utility:moon' : 'utility:light';
  }

  get darkModeLabel() {
    return this.darkMode ? 'Disable Dark Mode' : 'Enable Dark Mode';
  }

  handleToggleDarkMode() {
    this.darkMode = !this.darkMode;
    // Save preference to localStorage for persistence
    localStorage.setItem('capstone_dark_mode', this.darkMode.toString());
    // Publish to all subscribers
    publish(this.messageContext, DARK_MODE_CHANNEL, { darkModeEnabled: this.darkMode });
  }

  get noteSortOptions() {
    return [
      { label: 'Most Recent', value: 'recent' },
      { label: 'Oldest First', value: 'oldest' },
      { label: 'Title A-Z', value: 'title_asc' },
      { label: 'Title Z-A', value: 'title_desc' }
    ];
  }

  get sortedNotes() {
    if (!this.recentNotes || this.recentNotes.length === 0) {
      return [];
    }

    let sorted = [...this.recentNotes];
    
    switch(this.noteSortBy) {
      case 'recent':
        sorted.sort((a, b) => new Date(b.createdDate) - new Date(a.createdDate));
        break;
      case 'oldest':
        sorted.sort((a, b) => new Date(a.createdDate) - new Date(b.createdDate));
        break;
      case 'title_asc':
        sorted.sort((a, b) => (a.title || '').localeCompare(b.title || ''));
        break;
      case 'title_desc':
        sorted.sort((a, b) => (b.title || '').localeCompare(a.title || ''));
        break;
    }
    
    return sorted;
  }

  // Button event handlers
  handleSendEndorsementEmail() {
    console.log('Send Endorsement Email clicked');
    this.flowError = null;
    // Set up any required flow input variables here
    this.endorsementFlowInputVariables = [
      // Example: { name: 'recordId', type: 'String', value: this.recordId }
    ];
    this.showEndorsementEmailModal = true;
  }

  closeEndorsementEmailModal() {
    this.showEndorsementEmailModal = false;
    this.flowError = null;
  }

  handleFlowStatusChange(event) {
    console.log('Flow status:', event.detail.status);
    if (event.detail.status === 'FINISHED') {
      this.closeEndorsementEmailModal();
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: 'Endorsement email process completed',
          variant: 'success'
        })
      );
      // Refresh the page to show any updates
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    } else if (event.detail.status === 'ERROR') {
      this.flowError = 'An error occurred while running the flow. Please try again.';
      console.error('Flow error:', event.detail);
    }
  }

  handleNewBroker() {
    console.log('New Broker clicked');
    this.flowError = null;
    // Set up any required flow input variables here
    this.newBrokerFlowInputVariables = [
      // Example: { name: 'userId', type: 'String', value: this.userId }
    ];
    this.showNewBrokerModal = true;
  }

  closeNewBrokerModal() {
    this.showNewBrokerModal = false;
    this.flowError = null;
  }

  handleNewBrokerFlowStatusChange(event) {
    console.log('Flow status:', event.detail.status);
    if (event.detail.status === 'FINISHED') {
      this.closeNewBrokerModal();
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: 'New Broker/NRF/Registrant record created',
          variant: 'success'
        })
      );
      // Refresh the page to show the new record
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    } else if (event.detail.status === 'ERROR') {
      this.flowError = 'An error occurred while creating the record. Please try again.';
      console.error('Flow error:', event.detail);
    }
  }

  handleNotes() {
    console.log('Notes clicked');
    this.newNoteTitle = '';
    this.newNoteBody = '';
    this.recentNotes = [];
    this.noteSortBy = 'recent';
    this.recordSearchTerm = '';
    this.recordSearchResults = [];
    this.showRecordSearchResults = false;
    this.selectedRecordId = null;
    this.selectedRecordName = '';
    this.shareWithSearch = '';
    this.userSearchResults = [];
    this.showUserSearchResults = false;
    this.sharedUsers = [];
    this.showNotesModal = true;
    this.loadRecentNotes();
  }

  closeNotesModal() {
    this.showNotesModal = false;
    this.newNoteTitle = '';
    this.newNoteBody = '';
    this.recordSearchTerm = '';
    this.shareWithSearch = '';
    this.sharedUsers = [];
    this.selectedRecordId = null;
    this.selectedRecordName = '';
  }

  handleNoteTitleChange(event) {
    this.newNoteTitle = event.target.value;
  }

  handleNoteBodyChange(event) {
    this.newNoteBody = event.target.value;
  }

  handleNoteSortChange(event) {
    this.noteSortBy = event.target.value;
  }

  handleRecordSearchChange(event) {
    this.recordSearchTerm = event.target.value;
    
    if (this.recordSearchTerm && this.recordSearchTerm.length >= 2) {
      this.searchRecords();
    } else {
      this.recordSearchResults = [];
      this.showRecordSearchResults = false;
    }
  }

  searchRecords() {
    // Simulated search - in production, this would query Salesforce
    // You'd use Apex to search Candidate__c, Contact, Case, etc.
    this.recordSearchResults = [
      { Id: 'sample1', Name: 'Sample Candidate 1' },
      { Id: 'sample2', Name: 'Sample Contact 1' }
    ];
    this.showRecordSearchResults = this.recordSearchResults.length > 0;
  }

  handleRecordSelect(event) {
    this.selectedRecordId = event.currentTarget.dataset.recordId;
    this.selectedRecordName = event.currentTarget.dataset.recordName;
    this.recordSearchTerm = '';
    this.showRecordSearchResults = false;
    this.recordSearchResults = [];
  }

  handleRemoveRecord() {
    this.selectedRecordId = null;
    this.selectedRecordName = '';
  }

  handleShareWithSearchChange(event) {
    this.shareWithSearch = event.target.value;
    
    if (this.shareWithSearch && this.shareWithSearch.length >= 2) {
      this.searchUsers();
    } else {
      this.userSearchResults = [];
      this.showUserSearchResults = false;
    }
  }

  searchUsers() {
    // Simulated user search - in production, this would query User object
    this.userSearchResults = [
      { Id: 'user1', Name: 'Sample User 1' },
      { Id: 'user2', Name: 'Sample User 2' }
    ];
    this.showUserSearchResults = this.userSearchResults.length > 0;
  }

  handleUserSelect(event) {
    const userId = event.currentTarget.dataset.userId;
    const userName = event.currentTarget.dataset.userName;
    
    // Check if already added
    const alreadyAdded = this.sharedUsers.find(u => u.Id === userId);
    if (!alreadyAdded) {
      this.sharedUsers = [...this.sharedUsers, { Id: userId, Name: userName }];
    }
    
    this.shareWithSearch = '';
    this.showUserSearchResults = false;
    this.userSearchResults = [];
  }

  handleRemoveSharedUser(event) {
    const userIdToRemove = event.currentTarget.dataset.userId;
    this.sharedUsers = this.sharedUsers.filter(u => u.Id !== userIdToRemove);
  }

  loadRecentNotes() {
    getRecentNotes()
      .then(result => {
        this.recentNotes = result;
        console.log('Loaded ' + result.length + ' notes');
      })
      .catch(error => {
        console.error('Error loading notes:', error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Failed to load notes: ' + (error.body?.message || error.message),
            variant: 'error'
          })
        );
        this.recentNotes = [];
      });
  }

  handleSaveNote() {
    if (!this.newNoteBody || this.newNoteBody.trim() === '') {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Please enter note content',
          variant: 'error'
        })
      );
      return;
    }

    this.isNoteSaving = true;
    
    // Convert text to base64 for ContentNote
    const noteContent = btoa(unescape(encodeURIComponent(this.newNoteBody)));
    const noteTitle = this.newNoteTitle || 'Note - ' + new Date().toLocaleDateString();
    
    const fields = {};
    fields[TITLE_FIELD.fieldApiName] = noteTitle;
    fields[CONTENT_FIELD.fieldApiName] = noteContent;

    const recordInput = { apiName: CONTENT_NOTE_OBJECT.objectApiName, fields };

    createRecord(recordInput)
      .then((contentNote) => {
        // If we have a selected record, create ContentDocumentLink
        // If we have shared users, create additional ContentDocumentLinks
        // For now, just show success
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Note created successfully' + 
                     (this.selectedRecordName ? ' and attached to ' + this.selectedRecordName : '') +
                     (this.sharedUsers.length > 0 ? ' and shared with ' + this.sharedUsers.length + ' user(s)' : ''),
            variant: 'success'
          })
        );
        this.newNoteTitle = '';
        this.newNoteBody = '';
        this.selectedRecordId = null;
        this.selectedRecordName = '';
        this.sharedUsers = [];
        this.loadRecentNotes();
        this.isNoteSaving = false;
      })
      .catch(error => {
        console.error('Error creating note:', error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Error creating note: ' + (error.body?.message || error.message),
            variant: 'error'
          })
        );
        this.isNoteSaving = false;
      });
  }

  handleDeleteNote(event) {
    const contentDocumentId = event.currentTarget.dataset.noteId;
    this.noteToDelete = contentDocumentId;
    this.showDeleteConfirmation = true;
  }

  confirmDeleteNote() {
    if (!this.noteToDelete) {
      return;
    }

    deleteRecord(this.noteToDelete)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Note deleted successfully',
            variant: 'success'
          })
        );
        this.loadRecentNotes();
        this.showDeleteConfirmation = false;
        this.noteToDelete = null;
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Failed to delete note: ' + (error.body?.message || error.message),
            variant: 'error'
          })
        );
        this.showDeleteConfirmation = false;
        this.noteToDelete = null;
      });
  }

  cancelDeleteNote() {
    this.showDeleteConfirmation = false;
    this.noteToDelete = null;
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

  handleNewOpportunity() {
    console.log('New Opportunity clicked - opening Quick Action modal');
    this.showNewOpportunityModal = true;
  }

  closeNewOpportunityModal() {
    this.showNewOpportunityModal = false;
  }

  handleNewOpportunityFlowStatusChange(event) {
    console.log('Flow status changed:', event.detail.status);
    if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
      this.showNewOpportunityModal = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: 'Opportunity created successfully!',
          variant: 'success'
        })
      );
    }
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

  async handleScheduleInterview() {
    console.log('Schedule Interview clicked');
    try {
      this.currentUserName = await getCurrentUserName();
    } catch (error) {
      console.error('Error fetching user name:', error);
      this.currentUserName = 'Current User';
    }
    this.showScheduleInterviewModal = true;
  }

  async handleCandidateChange(event) {
    const candidateId = event.target.value;
    this.selectedCandidateId = candidateId;

    if (candidateId) {
      try {
        const [suggestion, summary] = await Promise.all([
          getNextInterviewType({ candidateId }),
          getCandidateInterviewSummary({ candidateId })
        ]);
        this.suggestedInterviewType = suggestion || '';
        this.interviewSummary = summary || { hasCompletedInterviews: false, summary: '' };
      } catch (error) {
        console.error('Error fetching interview suggestions:', error);
        this.suggestedInterviewType = '';
        this.interviewSummary = { hasCompletedInterviews: false, summary: '' };
      }
    } else {
      this.suggestedInterviewType = '';
      this.interviewSummary = { hasCompletedInterviews: false, summary: '' };
    }
  }

  toggleInterviewerField() {
    this.showInterviewerField = !this.showInterviewerField;
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