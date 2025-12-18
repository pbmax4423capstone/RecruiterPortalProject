import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getUserName from '@salesforce/apex/ServiceHomeVibeController.getUserName';
import getMyOpenCases from '@salesforce/apex/MyOpenCasesController.getMyOpenCases';
import refreshMyOpenCases from '@salesforce/apex/MyOpenCasesController.refreshMyOpenCases';

export default class ServiceHomeVibe extends NavigationMixin(LightningElement) {
  @track darkMode = false;
  @track greetingMessage = '';
  @track themeLabel = 'Enable Dark Mode';
  @track themeIcon = 'utility:brightness';
  @track userName = '';
  @track upcomingTasks = [];
  @track pastDueTasks = [];
  @track showCreateTicketModal = false;
  @track showAddAgentModal = false;
  @track showDeviceInspectionModal = false;
  @track showEncryptDeviceModal = false;
  @track showDeviceOffboardingModal = false;
  @track recentItems = [];
  @track myOpenCases = [];
  @track showRecordModal = false;
  @track selectedRecordId = null;
  @track selectedObjectApiName = null;
  @track showCaseModal = false;
  @track selectedCaseId = null;
  @track showTaskModal = false;
  @track selectedTaskData = null;
  @track selectedCaseIsUnassigned = false;
  @track selectedCaseIsMockData = false;
  @track selectedRecordIsMockData = false;
  
  wiredMyOpenCasesResult;

  @wire(getMyOpenCases)
  wiredMyOpenCases(result) {
    this.wiredMyOpenCasesResult = result;
    if (result.data) {
      console.log('Wire service returned', result.data.length, 'cases');
      this.myOpenCases = result.data.map(caseRecord => ({
        ...caseRecord,
        PriorityClass: this.getPriorityClass(caseRecord.Priority),
        CreatedDate: this.formatDate(caseRecord.CreatedDate),
        Account: caseRecord.Account || { Name: 'No Account' }
      }));
      console.log('Processed myOpenCases:', this.myOpenCases);
    } else if (result.error) {
      console.error('Error loading open cases:', result.error);
      this.myOpenCases = [];
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: 'Failed to load your open cases: ' + (result.error.body?.message || result.error.message),
        variant: 'error'
      }));
    }
  }

  get containerClass() {
    return this.darkMode ? 'dark-theme' : 'light-theme';
  }

  get unassignedCasesClass() {
    return this.darkMode ? 'unassigned-cases-dark' : 'unassigned-cases-light';
  }

  connectedCallback() {
    this.fetchUserName();
    this.loadTasks();
    this.loadRecentItems();
    // Remove loadMyOpenCases() call since we're now using wire service
  }

  getPriorityClass(priority) {
    switch (priority) {
      case 'High':
        return 'slds-badge slds-theme_error';
      case 'Medium':
        return 'slds-badge slds-theme_warning';
      case 'Low':
        return 'slds-badge slds-theme_success';
      default:
        return 'slds-badge';
    }
  }

  formatDate(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now - date);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 1) return '1 day ago';
    if (diffDays < 7) return `${diffDays} days ago`;
    if (diffDays < 30) return `${Math.ceil(diffDays / 7)} weeks ago`;
    return date.toLocaleDateString();
  }

  async fetchUserName() {
    try {
      const name = await getUserName();
      this.userName = name || 'Agent';
      this.setGreeting();
    } catch (error) {
      // Fallback if Apex fails or not yet deployed
      // eslint-disable-next-line no-console
      console.error('Error fetching user name:', error);
      this.userName = 'Agent';
      this.setGreeting();
    }
  }

  setGreeting() {
    const now = new Date();
    const hour = now.getHours();
    let greeting = 'Hello';

    if (hour < 12) greeting = 'Good morning';
    else if (hour < 18) greeting = 'Good afternoon';
    else greeting = 'Good evening';

    this.greetingMessage = `${greeting}, ${this.userName} 👋`;
  }

  toggleTheme() {
    this.darkMode = !this.darkMode;
    if (this.darkMode) {
      this.themeLabel = 'Disable Dark Mode';
      this.themeIcon = 'utility:moon';
    } else {
      this.themeLabel = 'Enable Dark Mode';
      this.themeIcon = 'utility:brightness';
    }
  }

  loadTasks() {
    // Mock task data - in real implementation, this would come from Apex/SOQL
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    const nextWeek = new Date(today);
    nextWeek.setDate(today.getDate() + 7);
    const pastWeek = new Date(today);
    pastWeek.setDate(today.getDate() - 7);

    this.upcomingTasks = [
      {
        id: 'task001',
        subject: 'Follow up on Case #12345',
        dueDate: tomorrow.toLocaleDateString(),
        priority: 'High'
      },
      {
        id: 'task002',
        subject: 'Review security protocols',
        dueDate: nextWeek.toLocaleDateString(),
        priority: 'Medium'
      },
      {
        id: 'task003',
        subject: 'Team meeting preparation',
        dueDate: tomorrow.toLocaleDateString(),
        priority: 'Low'
      }
    ];

    this.pastDueTasks = [
      {
        id: 'task004',
        subject: 'Complete device audit',
        dueDate: pastWeek.toLocaleDateString(),
        priority: 'High'
      },
      {
        id: 'task005',
        subject: 'Update documentation',
        dueDate: pastWeek.toLocaleDateString(),
        priority: 'Medium'
      }
    ];
  }

  loadRecentItems() {
    // Mock recent items data with realistic Salesforce IDs
    // Note: In production, these would come from actual Recent Items API
    this.recentItems = [
      {
        Id: '5003000000D8cuI', // Mock but valid Salesforce Case ID format
        Name: 'Case #12345: Network Connectivity Issue',
        Type: 'Case',
        IconName: 'standard:case',
        LastViewedDate: '2 hours ago',
        Description: 'Customer experiencing intermittent network connectivity problems',
        isMockData: true
      },
      {
        Id: 'task001',
        Name: 'Follow up on Case #12345',
        Type: 'Task',
        IconName: 'standard:task',
        LastViewedDate: '3 hours ago',
        Description: 'High priority follow-up task',
        isMockData: true
      },
      {
        Id: 'contact001', 
        Name: 'John Smith',
        Type: 'Contact',
        IconName: 'standard:contact',
        LastViewedDate: '4 hours ago',
        Description: 'Senior IT Manager at TechCorp Inc.',
        isMockData: true
      },
      {
        Id: 'account001',
        Name: 'TechCorp Inc.',
        Type: 'Account',
        IconName: 'standard:account',
        LastViewedDate: '1 day ago',
        Description: 'Enterprise customer - 500+ employees',
        isMockData: true
      },
      {
        Id: '5003000000D8cuJ', // Mock but valid Salesforce Case ID format
        Name: 'Case #12340: Password Reset Request',
        Type: 'Case', 
        IconName: 'standard:case',
        LastViewedDate: '1 day ago',
        Description: 'User unable to access system after password expiration',
        isMockData: true
      },
      {
        Id: 'task002',
        Name: 'Review security protocols',
        Type: 'Task',
        IconName: 'standard:task',
        LastViewedDate: '1 day ago',
        Description: 'Medium priority security review task',
        isMockData: true
      },
      {
        Id: 'opportunity001',
        Name: 'Software Upgrade - Q4 2025',
        Type: 'Opportunity',
        IconName: 'standard:opportunity',
        LastViewedDate: '2 days ago',
        Description: 'Enterprise software upgrade opportunity worth $50K',
        isMockData: true
      },
      {
        Id: 'lead001',
        Name: 'Sarah Johnson - DataFlow Solutions',
        Type: 'Lead',
        IconName: 'standard:lead',
        LastViewedDate: '3 days ago',
        Description: 'Interested in cloud migration services',
        isMockData: true
      }
    ];
  }

  handleRecentItemClick(event) {
    const itemId = event.currentTarget.dataset.id;
    const item = this.recentItems.find(item => item.Id === itemId);
    
    if (item) {
      // Check if it's a Case record
      if (item.Type === 'Case' || item.IconName === 'standard:case') {
        // Open case in case modal (works for both real and mock data)
        this.selectedCaseId = itemId;
        this.selectedCaseIsUnassigned = false; // Recent items cases are typically assigned
        this.selectedCaseIsMockData = item.isMockData || false; // Pass mock data flag
        this.showCaseModal = true;
      } else if (item.Type === 'Task' || item.IconName === 'standard:task') {
        // Open task in task modal (works for both real and mock data)
        const taskData = {
          id: itemId,
          subject: item.Name,
          status: 'Not Started',
          priority: 'Medium',
          dueDate: 'No due date',
          description: item.Description,
          isMockData: item.isMockData || false
        };
        this.selectedTaskData = taskData;
        this.showTaskModal = true;
      } else {
        // Open record types in generic modal (works for both real and mock data)
        this.selectedRecordId = itemId;
        this.selectedObjectApiName = this.getObjectApiName(item);
        this.selectedRecordIsMockData = item.isMockData || false; // Pass mock data flag
        this.showRecordModal = true;
      }
    }
  }

  getObjectApiName(item) {
    // Determine object API name from item properties
    if (item.Type === 'Case' || item.IconName === 'standard:case') {
      return 'Case';
    } else if (item.Type === 'Contact' || item.IconName === 'standard:contact') {
      return 'Contact';
    } else if (item.Type === 'Account' || item.IconName === 'standard:account') {
      return 'Account';
    } else if (item.Type === 'Opportunity' || item.IconName === 'standard:opportunity') {
      return 'Opportunity';
    } else if (item.Type === 'Lead' || item.IconName === 'standard:lead') {
      return 'Lead';
    } else if (item.Type === 'Task' || item.IconName === 'standard:task') {
      return 'Task';
    }
    
    // Default fallback - try to extract from Type or guess from IconName
    return item.Type || 'Case';
  }

  async refreshMyOpenCases() {
    console.log('Refreshing My Open Cases...');
    try {
      // Use the non-cacheable refresh method
      const refreshedCases = await refreshMyOpenCases();
      console.log('Refreshed cases:', refreshedCases);
      
      this.myOpenCases = refreshedCases.map(caseRecord => ({
        ...caseRecord,
        PriorityClass: this.getPriorityClass(caseRecord.Priority),
        CreatedDate: this.formatDate(caseRecord.CreatedDate),
        Account: caseRecord.Account || { Name: 'No Account' }
      }));
      
      console.log('Updated myOpenCases:', this.myOpenCases);
      
      // Also refresh the wire service for future loads
      await refreshApex(this.wiredMyOpenCasesResult);
    } catch (error) {
      console.error('Error refreshing open cases:', error);
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: 'Failed to refresh your open cases: ' + (error.body?.message || error.message),
        variant: 'error'
      }));
    }
  }

  handleCaseClick(event) {
    const caseId = event.currentTarget.dataset.id;
    // Open case in the full case record modal for better functionality
    this.selectedCaseId = caseId;
    this.selectedCaseIsUnassigned = false; // Cases from My Open Cases are assigned
    this.showCaseModal = true;
  }

  handleUpdateCase(event) {
    const caseId = event.currentTarget.dataset.id;
    // Open case in modal for editing
    this.selectedRecordId = caseId;
    this.selectedObjectApiName = 'Case';
    this.showRecordModal = true;
  }

  handleCloseModal(event) {
    console.log('Closing modal... Event:', event);
    
    // Prevent event bubbling if it exists
    if (event && event.stopPropagation) {
      event.stopPropagation();
    }
    if (event && event.preventDefault) {
      event.preventDefault();
    }

    // Close all modals and reset data
    this.showRecordModal = false;
    this.selectedRecordId = null;
    this.selectedObjectApiName = null;
    this.selectedRecordIsMockData = false;
    this.showCaseModal = false;
    this.selectedCaseId = null;
    this.selectedCaseIsMockData = false;
    this.showTaskModal = false;
    this.selectedTaskData = null;
    this.selectedCaseIsUnassigned = false;
    
    console.log('Modal closed successfully');
  }

  handleTaskCompleted(event) {
    const taskId = event.detail.taskId;
    console.log('Task completed:', taskId);
    
    // Remove task from lists
    this.upcomingTasks = this.upcomingTasks.filter(task => task.id !== taskId);
    this.pastDueTasks = this.pastDueTasks.filter(task => task.id !== taskId);
    
    this.dispatchEvent(new ShowToastEvent({
      title: 'Success',
      message: 'Task has been completed and removed from your task list.',
      variant: 'success'
    }));
  }

  handleTaskClick(event) {
    const taskId = event.currentTarget.dataset.id;
    const task = [...this.upcomingTasks, ...this.pastDueTasks].find(t => t.id === taskId);
    
    if (task) {
      // Open task in modal with enhanced task data
      this.selectedTaskData = {
        ...task,
        status: task.status || 'Not Started',
        description: this.getTaskDescription(task)
      };
      this.showTaskModal = true;
    }
  }

  getTaskDescription(task) {
    const descriptions = {
      'task001': 'Follow up with customer regarding Case #12345. Ensure all network connectivity issues have been resolved and document the resolution.',
      'task002': 'Conduct comprehensive review of current security protocols and update documentation based on latest compliance requirements.',
      'task003': 'Prepare agenda and materials for upcoming team meeting. Review open cases and assign priorities for the week.',
      'task004': 'Complete audit of all devices in the network. Document any security vulnerabilities and create remediation plan.',
      'task005': 'Update all technical documentation to reflect recent system changes and new procedures implemented this quarter.'
    };
    return descriptions[task.id] || `Task: ${task.subject}`;
  }

  handleCaseAcceptedFromUnassigned() {
    // Refresh My Open Cases when a case is accepted from unassigned cases
    this.refreshMyOpenCases();
  }

  handleCaseReassigned() {
    // Refresh My Open Cases when a case is reassigned to another user
    this.refreshMyOpenCases();
    this.dispatchEvent(new ShowToastEvent({
      title: 'Case Reassigned',
      message: 'The case has been removed from your cases list.',
      variant: 'info'
    }));
  }

  handleCaseClosed(event) {
    // Refresh My Open Cases when a case is closed
    this.refreshMyOpenCases();
    this.dispatchEvent(new ShowToastEvent({
      title: 'Case Closed',
      message: `Case has been closed successfully. Reason: ${event.detail.reason}`,
      variant: 'success'
    }));
  }

  // Button Handler Methods
  handleCreateTicket() {
    // Show modal with embedded flow
    this.showCreateTicketModal = true;
  }

  handleCloseCreateTicketModal() {
    this.showCreateTicketModal = false;
  }

  handleFlowFinish(event) {
    // Only close modal and show success when flow actually finishes (not on load)
    if (event.detail.status === 'FINISHED') {
      this.handleCloseCreateTicketModal();
      this.showToast('Success', 'Ticket created successfully!', 'success');
    }
  }

  handleAddAgent() {
    // Show modal with embedded agent onboarding flow
    this.showAddAgentModal = true;
  }

  handleCloseAddAgentModal() {
    this.showAddAgentModal = false;
  }

  handleAddAgentFlowFinish(event) {
    // Only close modal and show success when flow actually finishes
    if (event.detail.status === 'FINISHED') {
      this.showAddAgentModal = false;
      this.showToast('Success', 'Agent onboarded successfully!', 'success');
    }
  }

  handleDeviceInspection() {
    // Show modal with embedded device inspection flow
    this.showDeviceInspectionModal = true;
  }

  handleCloseDeviceInspectionModal() {
    this.showDeviceInspectionModal = false;
  }

  handleDeviceInspectionFlowFinish(event) {
    // Only close modal and show success when flow actually finishes
    if (event.detail.status === 'FINISHED') {
      this.showDeviceInspectionModal = false;
      this.showToast('Success', 'Device inspection record created successfully!', 'success');
    }
  }

  handleEncryptDevice() {
    // Show modal with embedded device encryption flow
    this.showEncryptDeviceModal = true;
  }

  handleCloseEncryptDeviceModal() {
    this.showEncryptDeviceModal = false;
  }

  handleEncryptDeviceFlowFinish(event) {
    // Only close modal and show success when flow actually finishes
    if (event.detail.status === 'FINISHED') {
      this.showEncryptDeviceModal = false;
      this.showToast('Success', 'Device encryption completed successfully!', 'success');
    }
  }

  handleDeviceOffboarding() {
    // Show modal with embedded device offboarding flow
    this.showDeviceOffboardingModal = true;
  }

  handleCloseDeviceOffboardingModal() {
    this.showDeviceOffboardingModal = false;
  }

  handleDeviceOffboardingFlowFinish(event) {
    // Only close modal and show success when flow actually finishes
    if (event.detail.status === 'FINISHED') {
      this.showDeviceOffboardingModal = false;
      this.showToast('Success', 'Device offboarding completed successfully!', 'success');
    }
  }

  handleMacros() {
    // Navigate to macros
    this[NavigationMixin.Navigate]({
      type: 'standard__navItemPage',
      attributes: {
        apiName: 'Macros'
      }
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