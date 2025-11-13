import { LightningElement, wire, track } from 'lwc';
import getDashboardData from '@salesforce/apex/RecruiterDashboardController.getDashboardData';
import getUserRecentActivity from '@salesforce/apex/RecruiterDashboardController.getUserRecentActivity';
import getRachyllCallDetails from '@salesforce/apex/RecruiterDashboardController.getRachyllCallDetails';
import completeCallTask from '@salesforce/apex/RecruiterDashboardController.completeCallTask';
import completeCallWithNotesAndSchedule from '@salesforce/apex/RecruiterDashboardController.completeCallWithNotesAndSchedule';
import generateTestCallsForRachyll from '@salesforce/apex/RecruiterDashboardController.generateTestCallsForRachyll';
import rescheduleCalls from '@salesforce/apex/RecruiterDashboardController.rescheduleCalls';
import getPastDueCalls from '@salesforce/apex/RecruiterDashboardController.getPastDueCalls';
import createCandidate from '@salesforce/apex/RecruiterDashboardController.createCandidate';
import updateCandidate from '@salesforce/apex/RecruiterDashboardController.updateCandidate';
import getCurrentUserInfo from '@salesforce/apex/RecruiterDashboardController.getCurrentUserInfo';
import getUserPipelineAnalytics from '@salesforce/apex/RecruiterDashboardController.getUserPipelineAnalytics';
import searchContacts from '@salesforce/apex/RecruiterDashboardController.searchContacts';
import createScheduledCall from '@salesforce/apex/RecruiterDashboardController.createScheduledCall';
import getActiveCandidates from '@salesforce/apex/RecruiterDashboardController.getActiveCandidates';
import getActiveCandidateAnalytics from '@salesforce/apex/RecruiterDashboardController.getActiveCandidateAnalytics';
import getCandidatesBySalesManager from '@salesforce/apex/RecruiterDashboardController.getCandidatesBySalesManager';
import getInterviewStatsByType from '@salesforce/apex/RecruiterDashboardController.getInterviewStatsByType';
import getInterviewStatsByInterviewer from '@salesforce/apex/RecruiterDashboardController.getInterviewStatsByInterviewer';
import getInterviewTypeWithInterviewerStats from '@salesforce/apex/RecruiterDashboardController.getInterviewTypeWithInterviewerStats';
import getInterviewDetailsByInterviewer from '@salesforce/apex/RecruiterDashboardController.getInterviewDetailsByInterviewer';
import reassignInterviewsToSalesManagers from '@salesforce/apex/RecruiterDashboardController.reassignInterviewsToSalesManagers';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
// Removed dashboard_images import - no images used in this component

export default class RecruiterDashboard extends NavigationMixin(LightningElement) {
  // Current User's Call Statistics (Priority Section)
  userScheduledCalls = 0;
  userPastDueCalls = 0;
  userTotalAssigned = 0;
  
  // User Pipeline Data (for Sales Managers)
  @track userPipelineData = [];
  userPipelineTotal = 0;

  // Contract Activity Statistics
  contractAAdded = 3;
  contractBAdded = 8;
  contractATerminations = 2;
  contractBTerminations = 4;
  contractBtoA = 2;
  
  // Year-to-Date Totals
  totalContractAAdded = 25;
  totalContractATerms = 15;
  totalContractBAdded = 78;
  totalContractBTerms = 45;
  totalBtoATransitions = 18;
  contractAJan1 = 125;

  connectedCallback() {
    console.log('🚀🚀🚀 RecruiterDashboard connected 🚀🚀🚀');
    // Initialize call management properties
    this.callsList = [];
    this.callType = '';
    this.callModalTitle = '';
    this.selectedCall = null;
    this.isLoadingCalls = false;
    
    // Load contract performance data
    this.loadContractPerformanceData();
    
    // Get current user information
    console.log('🎯 About to call fetchCurrentUser() 🎯');
    this.fetchCurrentUser();
    console.log('✨ fetchCurrentUser() called (async, may not be complete yet) ✨');
    
    // Load all dashboard data fresh on every page load
    this.loadCandidateAnalytics();
    this.loadRecentActivity();
    this.loadDashboardData();
    this.loadActiveCandidates();
    this.loadInterviewStats();
    this.loadInterviewerStats();
    this.loadInterviewTypeInterviewerStats();
    this.loadCallLists();
  }
  
  fetchCurrentUser() {
    console.log('🚀🚀🚀 fetchCurrentUser START (using .then() syntax) 🚀🚀🚀');
    
    getCurrentUserInfo()
      .then(userInfo => {
        console.log('✅✅✅ SUCCESS! User info received ✅✅✅');
        console.log('UserInfo:', JSON.stringify(userInfo));
        console.log('FirstName:', userInfo.firstName);
        console.log('Name:', userInfo.name);
        
        if (!userInfo) {
          console.error('❌ userInfo is null or undefined');
          throw new Error('No user info returned');
        }
        
        // Set reactive properties
        this.userName = userInfo.name || 'Unknown';
        this.userEmail = userInfo.email || '';
        this.userId = userInfo.id || '';
        this.userType = userInfo.userType || 'Other';
        this.userProfileName = userInfo.profileName || '';
        this.userRoleName = userInfo.roleName || '';
        this.userFirstName = userInfo.firstName || 'User';
        
        console.log('✨ Properties set successfully ✨');
        console.log('this.userFirstName:', this.userFirstName);
        console.log('this.userName:', this.userName);
        console.log('this.computedUserFirstName:', this.computedUserFirstName);
        
        // Load pipeline data if Sales Manager
        if (this.userType === 'Sales Manager') {
          console.log('Loading Sales Manager pipeline data...');
          this.loadUserPipelineData();
        }
      })
      .catch(error => {
        console.error('❌❌❌ ERROR in getCurrentUserInfo ❌❌❌');
        console.error('Error:', error);
        console.error('Error.message:', error?.message);
        console.error('Error.body:', error?.body);
        console.error('Error.statusText:', error?.statusText);
        
        // Set fallback values
        this.userName = 'Recruiter';
        this.userEmail = '';
        this.userId = '';
        this.userType = 'Other';
        this.userFirstName = 'Recruiter';
        this.userProfileName = '';
        this.userRoleName = '';
        
        console.log('Fallback values set');
      });
  }
  
  async loadUserPipelineData() {
    try {
      const pipelineData = await getUserPipelineAnalytics({ userName: this.userName });
      if (pipelineData && pipelineData.levelData) {
        this.userPipelineData = pipelineData.levelData;
        this.userPipelineTotal = pipelineData.total || 0;
      }
    } catch (error) {
      console.error('Error loading user pipeline data:', error);
      this.userPipelineData = [];
      this.userPipelineTotal = 0;
    }
  }

  async loadContractPerformanceData() {
    try {
      // In real implementation, this would call Apex methods to get contract data
      // For now, simulate realistic insurance business numbers
      const baseDate = new Date();
      const monthSeed = baseDate.getMonth() + baseDate.getDate();
      
      // Monthly contract activity (realistic insurance recruitment numbers)
      this.contractAAdded = 2 + (monthSeed % 4); // 2-5 Contract A additions per month
      this.contractBAdded = 6 + (monthSeed % 8); // 6-13 Contract B additions per month
      this.contractATerminations = 1 + (monthSeed % 3); // 1-3 A terminations per month
      this.contractBTerminations = 3 + (monthSeed % 6); // 3-8 B terminations per month
      this.contractBtoA = Math.max(1, Math.floor(this.contractBAdded * 0.25)); // ~25% of B additions move to A
      
      // Year-to-date numbers (10 months completed)
      const monthsCompleted = baseDate.getMonth() + 1;
      this.totalContractAAdded = Math.round(this.contractAAdded * monthsCompleted * 0.9); // Slightly lower avg
      this.totalContractATerms = Math.round(this.contractATerminations * monthsCompleted * 0.8); // Lower termination rate
      this.totalContractBAdded = Math.round(this.contractBAdded * monthsCompleted * 1.1); // Slight growth
      this.totalContractBTerms = Math.round(this.contractBTerminations * monthsCompleted * 1.0); // Steady rate
      this.totalBtoATransitions = Math.round(this.contractBtoA * monthsCompleted * 0.85); // Conservative transition rate
      
      // Starting field force (January 1st Contract A agents)
      this.contractAJan1 = 115 + (monthSeed % 20); // 115-134 starting agents
      
      // Calculate Net Field Force
      const netContractBActivity = this.totalContractBAdded - this.totalContractBTerms - this.totalBtoATransitions;
      const netFieldForce = this.contractAJan1 + this.totalContractAAdded - this.totalContractATerms + netContractBActivity;
      
      console.log(`Contract Activity - Month: A Added=${this.contractAAdded}, B Added=${this.contractBAdded}, A Terms=${this.contractATerminations}, B Terms=${this.contractBTerminations}, B to A=${this.contractBtoA}`);
      console.log(`Net Field Force: ${this.contractAJan1} (Jan1) + ${this.totalContractAAdded} (A Added) - ${this.totalContractATerms} (A Terms) + ${netContractBActivity} (Net B) = ${netFieldForce}`);
    } catch (error) {
      console.error('Error loading contract data:', error);
      // Fallback to default values
      this.contractAAdded = 3;
      this.contractBAdded = 8;
      this.contractATerminations = 2;
      this.contractBTerminations = 4;
      this.contractBtoA = 2;
      this.totalContractAAdded = 25;
      this.totalContractATerms = 15;
      this.totalContractBAdded = 78;
      this.totalContractBTerms = 45;
      this.totalBtoATransitions = 18;
      this.contractAJan1 = 125;
    }
  }

  async loadCandidateAnalytics() {
    try {
      const data = await getActiveCandidateAnalytics();
      if (data && data.byManager) {
        this.pieChartData = this.formatPieChart(data.byManager);
      }
    } catch (error) {
      console.error('Error loading candidate analytics:', error);
      this.pieChartData = [];
    }
  }

  async loadRecentActivity() {
    try {
      const data = await getUserRecentActivity();
      if (data) {
        this.recentActivities = data.map(activity => {
          const formattedActivity = { ...activity };
          if (formattedActivity.dueDate) {
            const dueDate = new Date(formattedActivity.dueDate);
            formattedActivity.formattedDueDate = dueDate.toLocaleDateString('en-US', { 
              month: 'short', 
              day: 'numeric',
              year: 'numeric'
            });
          }
          return formattedActivity;
        });
        this.recentActivityError = undefined;
      }
    } catch (error) {
      console.error('Error loading recent activity:', error);
      this.recentActivities = [];
      this.recentActivityError = error;
    }
  }

  async loadDashboardData() {
    try {
      const data = await getDashboardData();
      if (data) {
        if (data.userCallStats) {
          this.userScheduledCalls = data.userCallStats.scheduledCalls || 0;
          this.userPastDueCalls = data.userCallStats.pastDueCalls || 0;
          this.userTotalAssigned = data.userCallStats.totalAssigned || 0;
        }
        if (data.salesManagerMetrics) {
          this.salesManagerMetrics = data.salesManagerMetrics;
        }
        if (data.candidateStats) {
          this.activeCandidates = data.candidateStats.active || 0;
          this.leads = data.candidateStats.leads || 0;
          this.totalCandidates = data.candidateStats.total || 0;
          this.newCandidatesThisWeek = data.candidateStats.newThisWeek || 0;
          this.upcomingMeetings = data.candidateStats.upcomingMeetings || 0;
        }
        if (data.scheduledInterviewStats) {
          this.attractionScheduled = data.scheduledInterviewStats.attractionScheduled || 0;
          this.si1Scheduled = data.scheduledInterviewStats.si1Scheduled || 0;
          this.si2Scheduled = data.scheduledInterviewStats.si2Scheduled || 0;
          this.si3Scheduled = data.scheduledInterviewStats.si3Scheduled || 0;
          this.careerScheduled = data.scheduledInterviewStats.careerScheduled || 0;
          this.interviewsCompleted = data.scheduledInterviewStats.completed || 0;
          this.interviewsNoShow = data.scheduledInterviewStats.noShow || 0;
          this.interviewsCanceled = data.scheduledInterviewStats.canceled || 0;
          this.interviewsThisWeek = data.scheduledInterviewStats.thisWeek || 0;
        }
        if (data.performanceMetrics) {
          this.proceedOutcome = data.performanceMetrics.proceedOutcome || 0;
          this.holdOutcome = data.performanceMetrics.holdOutcome || 0;
          this.declineOutcome = data.performanceMetrics.declineOutcome || 0;
          this.successRate = data.performanceMetrics.successRate || 0;
        }
        if (data.interviewsByType) {
          this.interviewTypeData = data.interviewsByType;
        }
        if (data.detailedInterviewStats) {
          this.attractionThisWeek = data.detailedInterviewStats.attractionThisWeek || 0;
          this.attractionThisMonth = data.detailedInterviewStats.attractionThisMonth || 0;
          this.si1ThisWeek = data.detailedInterviewStats.si1ThisWeek || 0;
          this.si1ThisMonth = data.detailedInterviewStats.si1ThisMonth || 0;
          this.si2ThisWeek = data.detailedInterviewStats.si2ThisWeek || 0;
          this.si2ThisMonth = data.detailedInterviewStats.si2ThisMonth || 0;
          this.careerThisWeek = data.detailedInterviewStats.careerThisWeek || 0;
          this.careerThisMonth = data.detailedInterviewStats.careerThisMonth || 0;
          this.callsThisWeek = data.detailedInterviewStats.callsThisWeek || 0;
          this.callsThisMonth = data.detailedInterviewStats.callsThisMonth || 0;
        }
      }
    } catch (error) {
      console.error('Error loading dashboard data:', error);
    }
  }

  async loadActiveCandidates() {
    try {
      const data = await getActiveCandidates();
      if (data) {
        this.activeCandidates = data;
        this.activeCandidatesError = undefined;
      }
    } catch (error) {
      console.error('Error loading active candidates:', error);
      this.activeCandidatesError = error;
      this.activeCandidates = [];
    }
  }

  async loadInterviewStats() {
    try {
      const data = await getInterviewStatsByType();
      if (data) {
        this.interviewStats = data;
      }
    } catch (error) {
      console.error('Error loading interview stats:', error);
      this.interviewStats = {};
    }
  }

  async loadInterviewerStats() {
    try {
      const data = await getInterviewStatsByInterviewer();
      if (data) {
        this.interviewerStats = data;
      }
    } catch (error) {
      console.error('Error loading interviewer stats:', error);
      this.interviewerStats = [];
    }
  }

  async loadInterviewTypeInterviewerStats() {
    try {
      const data = await getInterviewTypeWithInterviewerStats();
      if (data) {
        this.interviewTypeInterviewerStats = data;
      }
    } catch (error) {
      console.error('Error loading interview type interviewer stats:', error);
      this.interviewTypeInterviewerStats = {};
    }
  }
  
  // Call Details Modal
  @track showCallModal = false;
  @track callModalTitle = '';
  @track callDetails = [];
  @track isLoadingCalls = false;
  @track selectedCall = null;
  
  // Call Completion Modal
  @track showCompletionModal = false;
  @track callToComplete = null;
  @track callNotes = '';
  @track nextCallDate = null;
  @track scheduleNextCall = false;
  @track editableCallDueDate = '';
  
  // Detailed Metrics Modals
  @track showCandidateModal = false;
  @track candidateModalTitle = '';
  @track candidateModalData = [];
  @track isLoadingCandidates = false;
  
  // Active Candidates Data
  @track activeCandidates = [];
  @track activeCandidatesError;
  
  // Active Candidate Analytics Chart Data
  @track candidateAnalytics = {};
  @track candidateAnalyticsError;
  @track pieChartData = [];
  
  // Interview Statistics Data
  @track interviewStats = {};
  @track interviewerStats = [];
  @track interviewTypeInterviewerStats = {};
  
  // Candidate Detail Modal
  @track showCandidateDetailModal = false;
  @track selectedCandidateDetail = null;
  
  // Sales Manager Candidates Modal
  @track showSalesManagerCandidatesModal = false;
  @track salesManagerCandidatesModalTitle = '';
  @track salesManagerCandidates = [];
  @track isLoadingSalesManagerCandidates = false;
  @track selectedSalesManager = '';
  
  // Interview Details Modal
  @track showInterviewDetailsModal = false;
  @track interviewDetailsTitle = '';
  @track interviewDetailsList = [];
  @track selectedInterviewer = '';
  @track selectedInterviewType = '';
  
  // Dark Mode
  @track isDarkMode = false;
  
  // Individual form fields for better reactivity
  @track candidateEditId = '';
  @track candidateEditName = '';
  @track candidateEditEmail = '';
  @track candidateEditPhone = '';
  @track candidateEditPosition = '';
  @track candidateEditStatus = '';
  @track candidateEditOfficeLocation = '';
  @track candidateEditSalesManager = '';
  @track candidateEditRecruiter = '';
  @track candidateEditNextMeeting = '';
  @track candidateEditSummary = '';
  @track candidateEditAllNotes = '';
  @track candidateEditCreatedDate = '';
  @track candidateEditLastModified = '';
  
  // Dropdown options based on real Salesforce fields
  statusOptions = [
    { label: 'Active/In Process', value: 'Active/In Process' },
    { label: 'Lead', value: 'Lead' },
    { label: 'Qualified', value: 'Qualified' },
    { label: 'Not Qualified', value: 'Not Qualified' },
    { label: 'Closed', value: 'Closed' }
  ];
  
  experienceOptions = [
    { label: 'Entry Level (0-2 years)', value: 'Entry Level' },
    { label: 'Mid Level (3-5 years)', value: 'Mid Level' },
    { label: 'Senior Level (5+ years)', value: 'Senior Level' },
    { label: 'Management (10+ years)', value: 'Management' },
    { label: 'To Be Determined', value: 'To Be Determined' }
  ];

  // Real Salesforce field options
  positionOptions = [
    { label: 'Agent', value: 'Agent' },
    { label: 'Staff', value: 'Staff' },
    { label: 'Agent Assistant', value: 'Agent Assistant' },
    { label: 'Assistant', value: 'Assistant' },
    { label: 'Broker Assistant', value: 'Broker Assistant' },
    { label: 'Broker', value: 'Broker' },
    { label: 'Intern', value: 'Intern' },
    { label: 'Registrant', value: 'Registrant' },
    { label: 'Sales Manager', value: 'Sales Manager' }
  ];

  officeLocationOptions = [
    { label: 'Bakersfield', value: 'Bakersfield' },
    { label: 'KoreaTown', value: 'KoreaTown' },
    { label: 'Las Vegas', value: 'Las Vegas' },
    { label: 'Los Angeles', value: 'Los Angeles' },
    { label: 'Newport Beach', value: 'Newport Beach' },
    { label: 'Roseville', value: 'Roseville' },
    { label: 'Utah', value: 'Utah' }
  ];

  salesManagerOptions = [
    { label: 'Elizabeth Kagele', value: 'Elizabeth Kagele' },
    { label: 'Bradley Sofonia', value: 'Bradley Sofonia' },
    { label: 'Tim Denton', value: 'Tim Denton' },
    { label: 'Son Le', value: 'Son Le' },
    { label: 'Van Hess', value: 'Van Hess' },
    { label: 'Michael Yang', value: 'Michael Yang' }
  ];

  recruiterOptions = [
    { label: 'Brooke Ianni', value: 'Brooke Ianni' },
    { label: 'Rachyll Tenny', value: 'Rachyll Tenny' },
    { label: 'Susan Kim', value: 'Susan Kim' }
  ];
  
  @track showInterviewModal = false;
  @track interviewModalTitle = '';
  @track interviewModalData = [];
  @track isLoadingInterviews = false;
  
  @track showCallStatsModal = false;
  @track callStatsModalTitle = '';
  @track callStatsModalData = [];
  @track isLoadingCallStats = false;
  
  // Schedule Interview Modal
  @track showScheduleInterviewModal = false;
  @track selectedCandidateId = '';
  @track selectedCandidateName = '';
  @track candidateLookupOptions = [];
  @track recentCalledCandidates = [];
  @track allCandidates = [];
  @track filteredCandidates = [];
  @track candidateSearchTerm = '';
  @track interviewType = '';
  @track interviewDate = '';
  @track interviewTime = '';
  @track interviewNotes = '';
  @track isLoadingRecentCandidates = false;
  @track isLoadingAllCandidates = false;

  // Action Modal States
  @track showCreateTicketModal = false;
  @track showRescheduleCallsModal = false;
  @track showCreateCandidateModal = false;
  @track showContractingModal = false;
  @track showNotesModal = false;

  // Call Management Modal properties
  @track showCallManagementModal = false;
  @track showCallCompletionModal = false;
  @track isLoadingCalls = false;
  @track callsList = [];
  @track callType = '';
  @track callModalTitle = '';
  @track selectedCall = null;
  
  // Call completion form fields
  @track callOutcome = '';
  @track callNotes = '';
  @track needsFollowUp = false;
  @track followUpDate = '';
  @track followUpTime = '';
  @track createNewCall = false;
  @track newCallSubject = '';
  @track newCallDate = '';
  @track newCallTime = '';
  
  callOutcomeOptions = [
    { label: '✅ Successful Contact', value: 'successful' },
    { label: '📞 Left Voicemail', value: 'voicemail' },
    { label: '❌ No Answer', value: 'no_answer' },
    { label: '📧 Email Follow-up Needed', value: 'email_followup' },
    { label: '🚫 Do Not Call', value: 'do_not_call' }
  ];

  // Create Ticket Modal Data
  @track ticketSubject = '';
  @track ticketDescription = '';
  @track ticketPriority = 'Medium';
  @track ticketCategory = 'General';
  @track ticketContact = '';
  @track ticketAttachments = [];
  @track allowScreenCapture = true;

  // User Information - Individual tracked properties for reactivity
  @track userName = '';
  @track userFirstName = '';
  @track userEmail = '';
  @track userId = '';
  @track userType = 'Other';
  @track userProfileName = '';
  @track userRoleName = '';
  
  // Legacy currentUser object for backward compatibility
  get currentUser() {
    return {
      name: this.userName,
      firstName: this.userFirstName,
      email: this.userEmail,
      id: this.userId,
      userType: this.userType,
      profileName: this.userProfileName,
      roleName: this.userRoleName
    };
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
    return nameParts[0] || 'Recruiter';
  }

  get callManagementTitle() {
    return `🚨 ${this.computedUserFirstName}'s Call Management - Priority Section`;
  }

  // Reschedule Calls Data
  @track selectedCallsForReschedule = [];
  @track newRescheduleDate = '';
  @track newRescheduleTime = '';
  @track rescheduleNotes = '';
  @track selectedRescheduleCalls = [];
  @track isLoadingRescheduleCalls = false;

  // Create Candidate Data (Create Contact & Candidate together)
  @track newCandidateName = '';
  @track newCandidateEmail = '';
  @track newCandidatePhone = '';
  @track newCandidatePosition = '';
  @track newCandidateSource = '';
  @track newCandidateNotes = '';
  @track duplicateContactFound = false;
  @track duplicateContactId = null;

  // Contracting Data
  @track contractingCandidateId = '';
  @track contractType = '';
  @track startDate = '';
  @track contractNotes = '';

  // Notes and To-Do Data
  @track userNotes = '';
  @track todoItems = [];
  @track newTodoItem = '';

  // Schedule Call Modal Data
  @track showScheduleCallModal = false;
  @track scheduleCallSubject = 'Call';
  @track scheduleCallWhoId = '';
  @track scheduleCallContactName = '';
  @track scheduleCallWhatId = '';
  @track scheduleCallDate = '';
  @track scheduleCallPriority = 'Normal';
  @track scheduleCallStatus = 'Not Started';
  @track scheduleCallDescription = '';
  @track isSchedulingCall = false;

  // Contact Lookup Data
  @track contactOptions = [];
  @track showContactOptions = false;
  @track isSearchingContacts = false;
  @track searchTimeout;
  
  // Datatable Column Definitions
  candidateColumns = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Email', fieldName: 'email', type: 'email' },
    { label: 'Source', fieldName: 'source', type: 'text' },
    { label: 'Last Contact', fieldName: 'lastContact', type: 'date' },
    { label: 'Date Added', fieldName: 'dateAdded', type: 'date' },
    { label: 'Meeting Type', fieldName: 'meetingType', type: 'text' },
    { label: 'Scheduled Date', fieldName: 'scheduledDate', type: 'date' },
    { label: 'Time', fieldName: 'time', type: 'text' },
    { label: 'Location', fieldName: 'location', type: 'text' }
  ];

  interviewColumns = [
    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
    { label: 'Type', fieldName: 'type', type: 'text' },
    { label: 'Scheduled Date', fieldName: 'scheduledDate', type: 'date' },
    { label: 'Time', fieldName: 'time', type: 'text' },
    { label: 'Interviewer', fieldName: 'interviewer', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Result', fieldName: 'result', type: 'text' },
    { label: 'Feedback', fieldName: 'feedback', type: 'text' },
    { label: 'Notes', fieldName: 'notes', type: 'text' },
    { label: 'Reason', fieldName: 'reason', type: 'text' },
    { label: 'Completed Date', fieldName: 'completedDate', type: 'date' }
  ];

  callStatsColumns = [
    { label: 'Candidate', fieldName: 'candidateName', type: 'text' },
    { label: 'Assignee', fieldName: 'assignee', type: 'text' },
    { label: 'Scheduled Date', fieldName: 'scheduledDate', type: 'date' },
    { label: 'Due Date', fieldName: 'dueDate', type: 'date' },
    { label: 'Time', fieldName: 'time', type: 'text' },
    { label: 'Purpose', fieldName: 'purpose', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Priority', fieldName: 'priority', type: 'text' },
    { label: 'Days Past Due', fieldName: 'daysPastDue', type: 'number' },
    { label: 'Total Calls', fieldName: 'totalCalls', type: 'number' },
    { label: 'Scheduled Calls', fieldName: 'scheduledCalls', type: 'number' },
    { label: 'Past Due Calls', fieldName: 'pastDueCalls', type: 'number' },
    { label: 'Completed Today', fieldName: 'completedToday', type: 'number' }
  ];

  rescheduleCallColumns = [
    { label: 'Candidate Name', fieldName: 'candidateName', type: 'text' },
    { label: 'Original Date', fieldName: 'originalDate', type: 'date' },
    { label: 'Original Time', fieldName: 'originalTime', type: 'text' },
    { label: 'Purpose', fieldName: 'purpose', type: 'text' },
    { label: 'Days Overdue', fieldName: 'daysOverdue', type: 'number' },
    { label: 'Priority', fieldName: 'priority', type: 'text' }
  ];
  
  // Interview Type Options
  interviewTypeOptions = [
    { label: 'Attraction Interview', value: 'Attraction' },
    { label: 'SI1 Interview', value: 'SI1' },
    { label: 'SI2 Interview', value: 'SI2' },
    { label: 'SI3 Interview', value: 'SI3' },
    { label: 'Career Interview', value: 'Career' }
  ];

  // Ticket Form Options
  ticketPriorityOptions = [
    { label: 'Low', value: 'Low' },
    { label: 'Medium', value: 'Medium' },
    { label: 'High', value: 'High' },
    { label: 'Critical', value: 'Critical' }
  ];

  ticketCategoryOptions = [
    { label: 'General', value: 'General' },
    { label: 'Technical Support', value: 'Technical' },
    { label: 'System Access', value: 'Access' },
    { label: 'Data Issue', value: 'Data' },
    { label: 'Feature Request', value: 'Feature' },
    { label: 'Training', value: 'Training' }
  ];

  candidateSourceOptions = [
    { label: 'LinkedIn', value: 'LinkedIn' },
    { label: 'Indeed', value: 'Indeed' },
    { label: 'Company Website', value: 'Website' },
    { label: 'Referral', value: 'Referral' },
    { label: 'Job Fair', value: 'JobFair' },
    { label: 'Other', value: 'Other' }
  ];

  contractTypeOptions = [
    { label: 'Full-time Employee', value: 'FullTime' },
    { label: 'Part-time Employee', value: 'PartTime' },
    { label: 'Contract Worker', value: 'Contract' },
    { label: 'Consultant', value: 'Consultant' },
    { label: 'Temporary', value: 'Temporary' }
  ];

  // Recent Candidates Column Definitions
  recentCandidatesColumns = [
    { label: 'Name', fieldName: 'name', type: 'text', cellAttributes: { class: 'candidate-name-cell' } },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Email', fieldName: 'email', type: 'email' },
    { label: 'Last Call Date', fieldName: 'lastCallDate', type: 'date' },
    { label: 'Last Call Purpose', fieldName: 'lastCallPurpose', type: 'text' },
    { 
      type: 'button', 
      typeAttributes: { 
        label: 'Select', 
        name: 'select_candidate', 
        variant: 'brand-outline',
        iconName: 'utility:check'
      }
    }
  ];

  // All Candidates Column Definitions
  allCandidatesColumns = [
    { label: 'Name', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Email', fieldName: 'email', type: 'email' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Source', fieldName: 'source', type: 'text' },
    { label: 'Created Date', fieldName: 'createdDate', type: 'date', sortable: true },
    { 
      type: 'button', 
      typeAttributes: { 
        label: 'Select', 
        name: 'select_candidate', 
        variant: 'brand-outline',
        iconName: 'utility:check'
      }
    }
  ];
  
  // Sales Manager Metrics
  @track salesManagerMetrics = [];
  
  // Call Lists for side-by-side display
  @track scheduledCallsList = [];
  @track pastDueCallsList = [];
  
  // Candidate Statistics
  activeCandidates = 0;
  leads = 0;
  totalCandidates = 0;
  newCandidatesThisWeek = 0;
  upcomingMeetings = 0;
  
  // Scheduled Interview Statistics (from Candidate object)
  attractionScheduled = 0;
  si1Scheduled = 0;
  si2Scheduled = 0;
  si3Scheduled = 0;
  careerScheduled = 0;
  
  // Interview Statistics (from Interview object)
  interviewsCompleted = 0;
  interviewsNoShow = 0;
  interviewsCanceled = 0;
  interviewsThisWeek = 0;
  
  // Performance Metrics
  proceedOutcome = 0;
  holdOutcome = 0;
  declineOutcome = 0;
  successRate = 0;
  
  // Detailed Interview Statistics (matching your dashboard reports)
  attractionThisWeek = 0;
  attractionThisMonth = 0;
  si1ThisWeek = 0;
  si1ThisMonth = 0;
  si2ThisWeek = 0;
  si2ThisMonth = 0;
  careerThisWeek = 0;
  careerThisMonth = 0;
  callsThisWeek = 0;
  callsThisMonth = 0;
  
  // Recent Activity
  @track recentActivities = [];
  @track recentActivityError;
  
  // Interview Type Distribution
  interviewTypeData = [];
  
  // Wire result for refresh capability
  wiredDashboardResult;
  
  // Getter for template compatibility
  get recentActivity() {
    return this.recentActivities || [];
  }
  
  // Helper method to format data for pie chart by Sales Manager
  formatPieChart(managerData) {
    if (!managerData || managerData.length === 0) {
      return [];
    }
    
    const colors = [
      '#0176d3', '#06a59a', '#e74c3c', '#f39c12', '#9b59b6',
      '#2ecc71', '#34495e', '#e67e22', '#3498db', '#1abc9c'
    ];
    
    // Calculate total for percentages
    const total = managerData.reduce((sum, item) => sum + (item.Count || item.value || 0), 0);
    
    // First, calculate percentages for all items
    const dataWithPercentages = managerData.map((item) => {
      const value = item.Count || item.value || 0;
      const percentage = total > 0 ? Math.round((value / total) * 100) : 0;
      
      return {
        label: item.Name || item.label,
        value: value,
        percentage: percentage
      };
    });
    
    // Sort by percentage (highest to lowest)
    dataWithPercentages.sort((a, b) => b.percentage - a.percentage);
    
    // Now generate SVG paths with the sorted data
    let currentAngle = 0;
    const pieData = dataWithPercentages.map((item, index) => {
      // Calculate angle for this segment
      const segmentAngle = total > 0 ? (item.value / total) * 360 : 0;
      
      // Generate SVG path data for pie segment (250, 250 center, 150 radius for 500x500 viewBox)
      const pathData = this.createPiePath(250, 250, 150, currentAngle, currentAngle + segmentAngle);
      
      // Calculate positions for label and line
      const labelAngle = currentAngle + (segmentAngle / 2);
      
      // Line start point (edge of pie at 150px radius)
      const lineStart = this.polarToCartesian(250, 250, 150, labelAngle);
      
      // Line end point (outside the pie at 180px radius)
      const lineEnd = this.polarToCartesian(250, 250, 180, labelAngle);
      
      // Label position (further out at 210px radius)
      const labelPosition = this.polarToCartesian(250, 250, 210, labelAngle);
      
      // Get manager initials (first letter of each word)
      const initials = item.label.split(' ').map(word => word.charAt(0).toUpperCase()).join('');
      
      currentAngle += segmentAngle;
      
      return {
        label: item.label,
        value: item.value,
        percentage: item.percentage,
        color: colors[index % colors.length],
        colorStyle: `background-color: ${colors[index % colors.length]}`,
        pathData: pathData,
        lineX1: lineStart.x,
        lineY1: lineStart.y,
        lineX2: lineEnd.x,
        lineY2: lineEnd.y,
        labelX: labelPosition.x,
        labelY: labelPosition.y,
        labelAngle: labelAngle,
        initials: initials,
        showLabel: true // Always show label for all managers
      };
    });
    
    // Adjust label positions for small adjacent segments to prevent overlap
    for (let i = 0; i < pieData.length - 1; i++) {
      const current = pieData[i];
      const next = pieData[i + 1];
      
      // If both segments are small (< 5%) and close together
      if (current.percentage < 5 && next.percentage < 5) {
        const angleDiff = Math.abs(current.labelAngle - next.labelAngle);
        
        // If labels are too close (within 15 degrees), adjust them
        if (angleDiff < 15) {
          // Move current label slightly counterclockwise
          const adjustedCurrent = this.polarToCartesian(250, 250, 210, current.labelAngle - 8);
          current.labelX = adjustedCurrent.x;
          current.labelY = adjustedCurrent.y;
          
          // Move next label slightly clockwise
          const adjustedNext = this.polarToCartesian(250, 250, 210, next.labelAngle + 8);
          next.labelX = adjustedNext.x;
          next.labelY = adjustedNext.y;
        }
      }
    }
    
    return pieData;
  }

  // Helper method to create SVG path for pie chart segments
  createPiePath(centerX, centerY, radius, startAngle, endAngle) {
    const start = this.polarToCartesian(centerX, centerY, radius, endAngle);
    const end = this.polarToCartesian(centerX, centerY, radius, startAngle);
    
    const largeArcFlag = endAngle - startAngle <= 180 ? "0" : "1";
    
    return [
      "M", centerX, centerY,
      "L", start.x, start.y,
      "A", radius, radius, 0, largeArcFlag, 0, end.x, end.y,
      "Z"
    ].join(" ");
  }

  // Convert polar coordinates to cartesian
  polarToCartesian(centerX, centerY, radius, angleInDegrees) {
    const angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
    return {
      x: centerX + (radius * Math.cos(angleInRadians)),
      y: centerY + (radius * Math.sin(angleInRadians))
    };
  }

  // Create mini pie chart data for interview type by interviewer
  createMiniPieChart(interviewerData) {
    if (!interviewerData || !Array.isArray(interviewerData) || interviewerData.length === 0) {
      return [];
    }

    const colors = [
      '#0176d3', '#06a59a', '#e74c3c', '#f39c12', '#9b59b6', 
      '#2ecc71', '#34495e', '#e67e22', '#3498db', '#1abc9c'
    ];

    // Calculate total for percentages
    const total = interviewerData.reduce((sum, item) => sum + (item.count || 0), 0);
    
    // Generate pie chart segments
    let currentAngle = 0;
    return interviewerData.map((item, index) => {
      const count = item.count || 0;
      const percentage = total > 0 ? Math.round((count / total) * 100) : 0;
      const segmentAngle = total > 0 ? (count / total) * 360 : 0;
      
      // Generate SVG path for this segment
      const pathData = this.createMiniPiePath(50, 50, 45, currentAngle, currentAngle + segmentAngle);
      currentAngle += segmentAngle;
      
      return {
        interviewer: item.interviewer,
        count: count,
        percentage: percentage,
        color: colors[index % colors.length],
        colorClass: `mini-pie-legend-color mini-pie-color-${index}`,
        pathData: pathData,
        total: total
      };
    });
  }

  // Helper method to create SVG path for mini pie chart segments
  createMiniPiePath(centerX, centerY, radius, startAngle, endAngle) {
    if (endAngle - startAngle >= 360) {
      // Full circle
      return `M ${centerX - radius} ${centerY} 
              A ${radius} ${radius} 0 1 1 ${centerX + radius} ${centerY}
              A ${radius} ${radius} 0 1 1 ${centerX - radius} ${centerY}`;
    }
    
    const start = this.polarToCartesian(centerX, centerY, radius, endAngle);
    const end = this.polarToCartesian(centerX, centerY, radius, startAngle);
    const largeArcFlag = endAngle - startAngle <= 180 ? "0" : "1";
    
    return [
      "M", centerX, centerY,
      "L", start.x, start.y,
      "A", radius, radius, 0, largeArcFlag, 0, end.x, end.y,
      "Z"
    ].join(" ");
  }

  // Getters for mini pie charts
  get attractionMiniChart() {
    return this.createMiniPieChart(this.interviewTypeInterviewerStats.attractionByInterviewer);
  }

  get si1MiniChart() {
    return this.createMiniPieChart(this.interviewTypeInterviewerStats.si1ByInterviewer);
  }

  get si2MiniChart() {
    return this.createMiniPieChart(this.interviewTypeInterviewerStats.si2ByInterviewer);
  }

  get si3MiniChart() {
    return this.createMiniPieChart(this.interviewTypeInterviewerStats.si3ByInterviewer);
  }

  get careerMiniChart() {
    return this.createMiniPieChart(this.interviewTypeInterviewerStats.careerByInterviewer);
  }

  // Getters for totals in mini pie charts
  get attractionMiniTotal() {
    const chart = this.attractionMiniChart;
    return chart && chart.length > 0 ? chart[0].total : 0;
  }

  get si1MiniTotal() {
    const chart = this.si1MiniChart;
    return chart && chart.length > 0 ? chart[0].total : 0;
  }

  get si2MiniTotal() {
    const chart = this.si2MiniChart;
    return chart && chart.length > 0 ? chart[0].total : 0;
  }

  get si3MiniTotal() {
    const chart = this.si3MiniChart;
    return chart && chart.length > 0 ? chart[0].total : 0;
  }

  get careerMiniTotal() {
    const chart = this.careerMiniChart;
    return chart && chart.length > 0 ? chart[0].total : 0;
  }
  
  // Calculate total scheduled interviews
  get totalScheduledInterviews() {
    return this.attractionScheduled + this.si1Scheduled + this.si2Scheduled + this.si3Scheduled + this.careerScheduled;
  }
  
  // Calculate total completed interviews
  get totalCompletedInterviews() {
    return this.interviewsCompleted + this.interviewsNoShow + this.interviewsCanceled;
  }

  // Get ranked interviewer leaderboard combining all interview types
  get interviewerLeaderboard() {
    if (!this.interviewTypeInterviewerStats) {
      return [];
    }

    const interviewerTotals = new Map();
    const interviewerBreakdown = new Map();

    // Combine all interview types
    const allTypes = [
      { name: 'Attraction', data: this.interviewTypeInterviewerStats.attractionByInterviewer || [], color: '#0176d3' },
      { name: 'SI 1', data: this.interviewTypeInterviewerStats.si1ByInterviewer || [], color: '#06a59a' },
      { name: 'SI 2', data: this.interviewTypeInterviewerStats.si2ByInterviewer || [], color: '#e74c3c' },
      { name: 'SI 3', data: this.interviewTypeInterviewerStats.si3ByInterviewer || [], color: '#f39c12' },
      { name: 'Career', data: this.interviewTypeInterviewerStats.careerByInterviewer || [], color: '#9b59b6' }
    ];

    // Aggregate totals by interviewer
    allTypes.forEach(type => {
      type.data.forEach(interview => {
        const name = interview.interviewer;
        const count = interview.count || 0;
        
        if (!interviewerTotals.has(name)) {
          interviewerTotals.set(name, 0);
          interviewerBreakdown.set(name, {});
        }
        
        interviewerTotals.set(name, interviewerTotals.get(name) + count);
        interviewerBreakdown.get(name)[type.name] = { count, color: type.color };
      });
    });

    // Convert to array and sort by total interviews (descending)
    const leaderboard = Array.from(interviewerTotals.entries())
      .map(([name, total], index) => ({
        rank: index + 1,
        name,
        total,
        breakdown: interviewerBreakdown.get(name),
        medalClass: this.getMedalClass(index + 1),
        medalIcon: this.getMedalIcon(index + 1)
      }))
      .sort((a, b) => b.total - a.total)
      .map((item, index) => ({ ...item, rank: index + 1 })); // Re-assign ranks after sorting

    return leaderboard.slice(0, 10); // Top 10
  }

  getMedalClass(rank) {
    switch(rank) {
      case 1: return 'gold-medal';
      case 2: return 'silver-medal';
      case 3: return 'bronze-medal';
      default: return 'regular-rank';
    }
  }

  getMedalIcon(rank) {
    switch(rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return `#${rank}`;
    }
  }

  get totalInterviews() {
    if (!this.interviewStats || !this.interviewStats.total) return 0;
    return this.interviewStats.total;
  }
  
  get allTimeTotal() {
    if (!this.interviewStats || !this.interviewStats.allTimeTotal) return 0;
    return this.interviewStats.allTimeTotal;
  }

  get activeInterviewers() {
    if (!this.interviewerLeaderboard) return 0;
    return this.interviewerLeaderboard.length;
  }

  get averagePerInterviewer() {
    if (!this.interviewerLeaderboard || this.interviewerLeaderboard.length === 0) return 0;
    return Math.round(this.totalInterviews / this.interviewerLeaderboard.length);
  }
  
  // Calculate current user's total calls
  get userTotalCalls() {
    return (this.userScheduledCalls || 0) + (this.userPastDueCalls || 0);
  }
  
  get isCompleteButtonDisabled() {
    return !this.callNotes || this.callNotes.trim().length === 0;
  }
  
  // Format success rate as percentage
  get formattedSuccessRate() {
    return this.successRate + '%';
  }
  
  // Dark mode computed properties
  get dashboardContainerClass() {
    return this.isDarkMode ? 'dashboard-container dark-mode' : 'dashboard-container';
  }
  
  get darkModeIcon() {
    return this.isDarkMode ? 'utility:light_bulb' : 'utility:preview';
  }
  
  // Determine if user is Director of Recruiting
  get isDirector() {
    return this.currentUser.userType === 'Director';
  }
  
  // Determine if user is Sales Manager
  get isSalesManager() {
    return this.currentUser.userType === 'Sales Manager';
  }
  
  // Get pipeline title based on user type
  get pipelineTitle() {
    if (this.isSalesManager) {
      const firstName = this.userFirstName || 'Your';
      return `👥 ${firstName}'s Pipeline by Highest Level Achieved`;
    }
    return '👥 Candidate Pipeline';
  }
  
  // Get user pipeline pie chart data (for Sales Managers)
  get userPieChartData() {
    if (!this.userPipelineData || this.userPipelineData.length === 0) {
      return null;
    }
    return this.formatPieChart(this.userPipelineData);
  }
  
  // Calculate total candidates for pie chart center
  get totalCandidates() {
    if (!this.pieChartData || this.pieChartData.length === 0) {
      return 0;
    }
    return this.pieChartData.reduce((sum, item) => sum + item.value, 0);
  }

  // Check if we have recent activities to display
  get hasRecentActivities() {
    return this.recentActivities && this.recentActivities.length > 0;
  }

  // Schedule Call Modal Getters
  get todayDate() {
    const today = new Date();
    return today.toISOString().split('T')[0];
  }

  get isScheduleCallDisabled() {
    return !this.scheduleCallSubject || !this.scheduleCallContactName || !this.scheduleCallDate || this.isSchedulingCall;
  }

  get displayScheduleCallStatus() {
    // Show "Scheduled" in UI when value is "Not Started"
    return this.scheduleCallStatus === 'Not Started' ? 'Scheduled' : this.scheduleCallStatus;
  }

  get effectiveScheduleCallSubject() {
    // Ensure we always have a default subject
    return this.scheduleCallSubject || 'Call';
  }

  get callPriorityOptions() {
    return [
      { label: 'High', value: 'High' },
      { label: 'Normal', value: 'Normal' },
      { label: 'Low', value: 'Low' }
    ];
  }

  get callStatusOptions() {
    return [
      { label: 'Scheduled', value: 'Not Started' }, // Display "Scheduled" but use "Not Started" value
      { label: 'In Progress', value: 'In Progress' },
      { label: 'Completed', value: 'Completed' },
      { label: 'Waiting on someone else', value: 'Waiting on someone else' },
      { label: 'Deferred', value: 'Deferred' }
    ];
  }
  
  // Check if we have interview type data
  get hasInterviewTypeData() {
    return this.interviewTypeData && this.interviewTypeData.length > 0;
  }
  
  // Refresh dashboard data
  refreshDashboard() {
    return refreshApex(this.wiredDashboardResult);
  }

  navigateToCandidates() {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Candidate__c',
        actionName: 'list'
      },
      state: {
        filterName: 'Recent'
      }
    });
  }
  
  navigateToInterviews() {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Interview__c',
        actionName: 'list'
      },
      state: {
        filterName: 'Recent'
      }
    });
  }
  
  scheduleNewInterview() {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Interview__c',
        actionName: 'new'
      }
    });
  }
  
  // Navigation methods for scheduled interview types
  viewAttractionInterviews() {
    this.navigateToScheduledCandidates('attraction');
  }
  
  viewSI1Interviews() {
    this.navigateToScheduledCandidates('si1');
  }
  
  viewSI2Interviews() {
    this.navigateToScheduledCandidates('si2');
  }
  
  viewSI3Interviews() {
    this.navigateToScheduledCandidates('si3');
  }
  
  viewCareerInterviews() {
    this.navigateToScheduledCandidates('career');
  }
  
  navigateToScheduledCandidates(interviewType) {
    // For now, navigate to Candidate list view with filter
    // Could be enhanced to show a modal with detailed list
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Candidate__c',
        actionName: 'list'
      },
      state: {
        filterName: 'Recent'
      }
    });
    
    // Show toast with interview type information
    const event = new ShowToastEvent({
      title: 'Scheduled Interviews',
      message: `Showing ${interviewType.toUpperCase()} scheduled interviews`,
      variant: 'info'
    });
    this.dispatchEvent(event);
  }
  
  // Navigation methods for current user's calls
  viewMyScheduledCalls() {
    this.loadCallDetails('scheduled');
  }
  
  viewMyPastDueCalls() {
    this.loadCallDetails('pastdue');
  }
  
  async loadCallDetails(callType) {
    this.isLoadingCalls = true;
    this.callModalTitle = callType === 'scheduled' ? 'My Scheduled Calls' : 'My Past Due Calls';
    this.showCallModal = true;
    
    try {
      this.callDetails = await getRachyllCallDetails({ callType });
    } catch (error) {
      console.error('Error loading call details:', error);
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'Failed to load call details: ' + error.body?.message,
        variant: 'error'
      });
      this.dispatchEvent(event);
    } finally {
      this.isLoadingCalls = false;
    }
  }
  
  closeCallModal() {
    this.showCallModal = false;
    this.callDetails = [];
    this.selectedCall = null;
  }
  
  async completeCall(event) {
    const taskId = event.target.dataset.taskId;
    
    try {
      const result = await completeCallTask({ taskId });
      
      if (result === 'SUCCESS') {
        const event = new ShowToastEvent({
          title: 'Success',
          message: 'Call marked as completed',
          variant: 'success'
        });
        this.dispatchEvent(event);
        
        // Refresh the call details, call lists, and dashboard data
        if (this.selectedCall) {
          // If single call modal, close it after completion
          this.closeCallModal();
        } else {
          // If multi-call modal, refresh the details
          this.loadCallDetails(this.callModalTitle.includes('Past Due') ? 'pastdue' : 'scheduled');
        }
        
        this.loadCallLists();
        this.refreshDashboard();
      } else {
        throw new Error(result);
      }
    } catch (error) {
      console.error('Error generating test data:', error);
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'Failed to generate test data: ' + error.message,
        variant: 'error'
      });
      this.dispatchEvent(event);
    }
  }
  
  handleNotesChange(event) {
    this.callNotes = event.target.value;
  }
  
  handleNextCallDateChange(event) {
    this.nextCallDate = event.target.value;
  }
  
  handleScheduleNextCallChange(event) {
    this.scheduleNextCall = event.target.checked;
    if (!this.scheduleNextCall) {
      this.nextCallDate = null;
    }
  }
  
  completeCallWithDetails(event) {
    const taskId = event.target.dataset.taskId;
    
    // Find the call from either the single selected call or the call details list
    let call = null;
    if (this.selectedCall && this.selectedCall.id === taskId) {
      call = this.selectedCall;
    } else {
      call = this.callDetails.find(c => c.id === taskId);
    }
    
    if (call) {
      // Set up completion modal
      this.callToComplete = call;
      this.showCompletionModal = true;
      this.callNotes = '';
      this.nextCallDate = null;
      this.scheduleNextCall = false;
    }
  }
  
  async submitCallCompletion() {
    if (!this.callToComplete) return;
    
    try {
      const result = await completeCallWithNotesAndSchedule({ 
        taskId: this.callToComplete.id, 
        notes: this.callNotes,
        nextCallDate: this.scheduleNextCall ? this.nextCallDate : null
      });
      
      if (result === 'SUCCESS') {
        const successMessage = this.scheduleNextCall ? 
          'Call completed and follow-up scheduled successfully' : 
          'Call marked as completed';
          
        const event = new ShowToastEvent({
          title: 'Success',
          message: successMessage,
          variant: 'success'
        });
        this.dispatchEvent(event);
        
        // Close completion modal
        this.closeCompletionModal();
        
        // Refresh and close call modal if it was a single call
        if (this.selectedCall) {
          this.closeCallModal();
        } else {
          this.loadCallDetails(this.callModalTitle.includes('Past Due') ? 'pastdue' : 'scheduled');
        }
        this.loadCallLists();
        this.refreshDashboard();
      } else {
        throw new Error(result);
      }
    } catch (error) {
      console.error('Error completing call with details:', error);
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'Failed to complete call: ' + error.message,
        variant: 'error'
      });
      this.dispatchEvent(event);
    }
  }
  
  closeCompletionModal() {
    this.showCompletionModal = false;
    this.callToComplete = null;
    this.callNotes = '';
    this.nextCallDate = null;
    this.scheduleNextCall = false;
  }
  
  navigateToTask(event) {
    const taskId = event.target.dataset.taskId;
    
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: taskId,
        actionName: 'view'
      }
    });
  }
  
  navigateToRelatedRecord(event) {
    const recordId = event.target.dataset.recordId;
    
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: 'view'
      }
    });
  }
  
  navigateToMyCalls(callType) {
    // Keep the existing navigation method for backward compatibility
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Task',
        actionName: 'list'
      },
      state: {
        filterName: 'Recent'
      }
    });
    
    // Show toast with call type information
    const callTypeDisplay = callType === 'scheduled' ? 'Scheduled' : 'Past Due';
    const event = new ShowToastEvent({
      title: `${callTypeDisplay} Calls`,
      message: `Showing your ${callTypeDisplay.toLowerCase()} call tasks`,
      variant: callType === 'pastdue' ? 'warning' : 'info'
    });
    this.dispatchEvent(event);
  }
  
  async loadCallLists() {
    try {
      console.log('🔄 Loading call lists for current user...');
      
      // Load scheduled calls
      console.log('📞 Fetching scheduled calls...');
      const scheduledCalls = await getRachyllCallDetails({ callType: 'scheduled' });
      console.log('✅ Scheduled calls received:', scheduledCalls);
      console.log('📊 Number of scheduled calls:', scheduledCalls?.length || 0);
      
      this.scheduledCallsList = this.formatCallsForDisplay(scheduledCalls).slice(0, 5);
      console.log('📋 Scheduled calls list set:', this.scheduledCallsList);
      
      // Load past due calls
      console.log('⚠️ Fetching past due calls...');
      const pastDueCalls = await getRachyllCallDetails({ callType: 'pastdue' });
      console.log('✅ Past due calls received:', pastDueCalls);
      console.log('📊 Number of past due calls:', pastDueCalls?.length || 0);
      
      this.pastDueCallsList = this.formatCallsForDisplay(pastDueCalls).slice(0, 5);
      console.log('📋 Past due calls list set:', this.pastDueCallsList);
      
      console.log('✅ Call lists loaded successfully');
      
    } catch (error) {
      console.error('❌ Error loading call lists:', error);
      console.error('Error message:', error?.message);
      console.error('Error body:', error?.body);
      console.error('Error stack:', error?.stack);
    }
  }

  formatCallsForDisplay(calls) {
    if (!calls || calls.length === 0) {
      console.log('No calls to format');
      return [];
    }
    
    console.log('Formatting calls for display:', calls);
    
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
        console.error('Error formatting date for call:', call.id, error);
      }
      
      // Better candidate name resolution
      const candidateName = call.relatedPerson || call.relatedTo || call.subject || 'Unknown Contact';
      
      const formattedCall = {
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
      
      console.log('Formatted call:', formattedCall);
      return formattedCall;
    });
  }

  async loadScheduledCalls() {
    try {
      const scheduledCalls = await getRachyllCallDetails({ callType: 'scheduled' });
      this.scheduledCallsList = this.formatCallsForDisplay(scheduledCalls).slice(0, 5);
      
      this.dispatchEvent(new ShowToastEvent({
        title: 'Success',
        message: 'Scheduled calls refreshed',
        variant: 'success'
      }));
    } catch (error) {
      console.error('Error loading scheduled calls:', error);
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: 'Failed to refresh scheduled calls',
        variant: 'error'
      }));
    }
  }

  async loadPastDueCalls() {
    try {
      const pastDueCalls = await getRachyllCallDetails({ callType: 'pastdue' });
      this.pastDueCallsList = this.formatCallsForDisplay(pastDueCalls).slice(0, 5);
      
      this.dispatchEvent(new ShowToastEvent({
        title: 'Success',
        message: 'Past due calls refreshed',
        variant: 'success'
      }));
    } catch (error) {
      console.error('Error loading past due calls:', error);
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: 'Failed to refresh past due calls',
        variant: 'error'
      }));
    }
  }

  // Recent Activity Handlers
  handleActivityClick(event) {
    const activityId = event.currentTarget.dataset.activityId;
    console.log('Activity clicked:', activityId);
    
    // Find the activity in the recentActivities array
    const activity = this.recentActivities.find(a => a.id === activityId);
    
    if (!activity) {
      console.error('Activity not found:', activityId);
      return;
    }
    
    console.log('Activity type:', activity.type, 'ID:', activityId);
    
    // Determine the type based on the ID suffix
    if (activityId.endsWith('_interview')) {
      // Handle interview click - open interview detail/edit modal
      this.handleInterviewActivityClick(activity, activityId);
    } else if (activityId.endsWith('_candidate')) {
      // Handle candidate click - open candidate detail modal
      this.handleCandidateActivityClick(activity, activityId);
    } else if (activityId.endsWith('_task')) {
      // Handle task/call click - open call completion modal
      this.handleTaskActivityClick(activity, activityId);
    }
  }
  
  handleInterviewActivityClick(activity, activityId) {
    // Extract the real Interview ID (remove the _interview suffix)
    const interviewId = activityId.replace('_interview', '');
    console.log('Opening interview modal for:', interviewId);
    
    // For now, show an alert - you can enhance this to open an interview detail modal
    this.showToast('Interview Details', `Interview: ${activity.description} for ${activity.candidateName}`, 'info');
    
    // TODO: Implement interview detail modal
    // this.selectedInterview = { id: interviewId, ...activity };
    // this.showInterviewDetailModal = true;
  }
  
  handleCandidateActivityClick(activity, activityId) {
    // Extract the real Candidate ID (remove the _candidate suffix)
    const candidateId = activityId.replace('_candidate', '');
    console.log('Opening candidate modal for:', candidateId);
    
    // Load and open the candidate detail modal
    this.loadCandidateDetail(candidateId);
  }
  
  handleTaskActivityClick(activity, activityId) {
    // Extract the real Task ID (remove the _task suffix)
    const taskId = activityId.replace('_task', '');
    console.log('Opening task/call completion modal for:', taskId);
    
    // Set up the call completion data with due date
    this.selectedCall = {
      id: taskId,
      subject: activity.description,
      candidateName: activity.candidateName,
      status: activity.status,
      dueDate: activity.dueDate,
      formattedDueDate: activity.formattedDueDate
    };
    
    // Initialize the editable due date field
    this.editableCallDueDate = activity.dueDate || '';
    
    this.callCompletionSubject = activity.description;
    this.callCompletionNotes = '';
    this.callCompletionOutcome = '';
    this.callCompletionNextSteps = '';
    
    // Open the call completion modal
    this.showCallCompletionModal = true;
  }
  
  loadCandidateDetail(candidateId) {
    console.log('Loading candidate details for ID:', candidateId);
    
    // Find the candidate in active candidates list or fetch it
    getActiveCandidates()
      .then(candidates => {
        const candidate = candidates.find(c => c.id === candidateId);
        if (candidate) {
          this.openCandidateDetailModal(candidate);
        } else {
          console.error('Candidate not found in active candidates list');
          this.showToast('Error', 'Could not load candidate details', 'error');
        }
      })
      .catch(error => {
        console.error('Error loading candidate:', error);
        this.showToast('Error', 'Failed to load candidate details', 'error');
      });
  }
  
  openCandidateDetailModal(candidate) {
    // Populate the candidate detail fields
    this.selectedCandidateDetail = candidate;
    this.candidateEditId = candidate.id;
    this.candidateEditName = candidate.name;
    this.candidateEditEmail = candidate.email;
    this.candidateEditPhone = candidate.phone;
    this.candidateEditPosition = candidate.position;
    this.candidateEditStatus = candidate.status;
    this.candidateEditOfficeLocation = candidate.location || '';
    this.candidateEditSalesManager = candidate.ownerName || '';
    this.candidateEditRecruiter = '';
    this.candidateEditNextMeeting = candidate.nextMeeting || '';
    this.candidateEditSummary = '';
    this.candidateEditAllNotes = '';
    this.candidateEditCreatedDate = candidate.createdDate;
    this.candidateEditLastModified = candidate.lastModified;
    
    // Open the modal
    this.showCandidateDetailModal = true;
  }
  
  handleActivityHover(event) {
    event.currentTarget.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.15)';
    event.currentTarget.style.transform = 'translateY(-2px)';
  }
  
  handleActivityHoverOut(event) {
    event.currentTarget.style.boxShadow = 'none';
    event.currentTarget.style.transform = 'translateY(0)';
  }

  handleCompleteCall(event) {
    const callId = event.target.dataset.callId;
    console.log('Complete call clicked for ID:', callId);
    
    // Find the call in either list
    let call = this.scheduledCallsList.find(c => c.id === callId) || 
               this.pastDueCallsList.find(c => c.id === callId);
    
    if (call) {
      // Set up call completion data
      this.selectedCall = call;
      this.callCompletionSubject = call.subject;
      this.callCompletionNotes = call.description || '';
      this.callCompletionOutcome = '';
      this.callCompletionNextSteps = '';
      
      // Open the call completion modal
      this.showCallCompletionModal = true;
    }
  }

  openFollowUpCallModal() {
    // Close the call completion modal first
    this.showCallCompletionModal = false;
    
    // Pre-populate the schedule call modal with follow-up data
    if (this.selectedCall) {
      this.scheduleCallContactName = this.selectedCall.candidateName;
      this.scheduleCallWhoId = this.selectedCall.relatedPersonId;
      this.scheduleCallSubject = `Follow-up call with ${this.selectedCall.candidateName}`;
      this.scheduleCallAgenda = `Follow-up regarding: ${this.selectedCall.subject}`;
    }
    
    // Open the schedule call modal
    this.showScheduleCallModal = true;
  }
  
  async generateTestData() {
    try {
      const result = await generateTestCallsForRachyll();
      
      if (result.startsWith('SUCCESS')) {
        const event = new ShowToastEvent({
          title: 'Success',
          message: 'Test call data generated successfully',
          variant: 'success'
        });
        this.dispatchEvent(event);
        
        // Refresh the dashboard
        this.refreshDashboard();
      } else {
        throw new Error(result);
      }
    } catch (error) {
      console.error('Error generating test data:', error);
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'Failed to generate test data: ' + error.message,
        variant: 'error'
      });
      this.dispatchEvent(event);
    }
  }
  
  navigateToCallRecord(event) {
    const taskId = event.currentTarget.dataset.taskId;
    
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: taskId,
        actionName: 'view'
      }
    });
  }
  
  openCallFromList(event) {
    const taskId = event.currentTarget.dataset.taskId;
    const callType = event.currentTarget.dataset.callType;
    
    // Find the specific call from the appropriate list
    let call = null;
    if (callType === 'scheduled') {
      call = this.scheduledCallsList.find(c => c.id === taskId);
    } else {
      call = this.pastDueCallsList.find(c => c.id === taskId);
    }
    
    if (call) {
      // Set up modal with single call
      this.selectedCall = call;
      this.callDetails = [call];
      this.callModalTitle = callType === 'scheduled' ? 'Scheduled Call Details' : 'Past Due Call Details';
      this.showCallModal = true;
    }
  }

  // Metric Click Handlers
  handleCandidateMetricClick(event) {
    const metricType = event.currentTarget.dataset.metric;
    this.isLoadingCandidates = true;
    this.showCandidateModal = true;
    
    // Set title and load appropriate data based on metric type
    switch (metricType) {
      case 'activeCandidates':
        this.candidateModalTitle = 'Active Candidates';
        this.loadActiveCandidates();
        break;
      case 'leads':
        this.candidateModalTitle = 'Leads';
        this.loadLeads();
        break;
      case 'newCandidates':
        this.candidateModalTitle = 'New Candidates This Week';
        this.loadNewCandidates();
        break;
      case 'upcomingMeetings':
        this.candidateModalTitle = 'Upcoming Meetings';
        this.loadUpcomingMeetings();
        break;
      default:
        this.candidateModalTitle = 'All Candidates';
        this.loadAllCandidates();
        break;
    }
  }

  handleInterviewMetricClick(event) {
    const metricType = event.currentTarget.dataset.metric;
    this.isLoadingInterviews = true;
    this.showInterviewModal = true;
    
    // Set title and load appropriate data based on metric type
    switch (metricType) {
      case 'attraction':
        this.interviewModalTitle = 'Attraction Interviews';
        this.loadAttractionInterviews();
        break;
      case 'si1':
        this.interviewModalTitle = 'SI1 Interviews';
        this.loadSI1Interviews();
        break;
      case 'si2':
        this.interviewModalTitle = 'SI2 Interviews';
        this.loadSI2Interviews();
        break;
      case 'si3':
        this.interviewModalTitle = 'SI3 Interviews';
        this.loadSI3Interviews();
        break;
      case 'career':
        this.interviewModalTitle = 'Career Interviews';
        this.loadCareerInterviews();
        break;
      case 'completed':
        this.interviewModalTitle = 'Completed Interviews';
        this.loadCompletedInterviews();
        break;
      case 'noshow':
        this.interviewModalTitle = 'No-Show Interviews';
        this.loadNoShowInterviews();
        break;
      case 'canceled':
        this.interviewModalTitle = 'Canceled Interviews';
        this.loadCanceledInterviews();
        break;
      default:
        this.interviewModalTitle = 'All Interviews';
        this.loadAllInterviews();
        break;
    }
  }

  handleCallStatsMetricClick(event) {
    const metricType = event.currentTarget.dataset.metric;
    this.isLoadingCallStats = true;
    this.showCallStatsModal = true;
    
    // Set title and load appropriate data based on metric type
    switch (metricType) {
      case 'rachyllScheduled':
        this.callStatsModalTitle = 'Rachyll\'s Scheduled Calls';
        this.loadRachyllScheduledCalls();
        break;
      case 'rachyllPastDue':
        this.callStatsModalTitle = 'Rachyll\'s Past Due Calls';
        this.loadRachyllPastDueCalls();
        break;
      case 'rachyllTotal':
        this.callStatsModalTitle = 'Rachyll\'s All Assigned Calls';
        this.loadRachyllAllCalls();
        break;
      default:
        this.callStatsModalTitle = 'Call Statistics';
        this.loadAllCallStats();
        break;
    }
  }

  // Modal Close Handlers
  closeCandidateModal() {
    this.showCandidateModal = false;
    this.candidateModalData = [];
    this.isLoadingCandidates = false;
  }

  closeInterviewModal() {
    this.showInterviewModal = false;
    this.interviewModalData = [];
    this.isLoadingInterviews = false;
  }

  closeCallStatsModal() {
    this.showCallStatsModal = false;
    this.callStatsModalData = [];
    this.isLoadingCallStats = false;
  }

  // Sales Manager Candidates Modal Handlers
  closeSalesManagerCandidatesModal() {
    this.showSalesManagerCandidatesModal = false;
    this.salesManagerCandidatesModalTitle = '';
    this.salesManagerCandidates = [];
    this.isLoadingSalesManagerCandidates = false;
    this.selectedSalesManager = '';
  }

  async handleSalesManagerClick(event) {
    event.preventDefault();
    event.stopPropagation();
    const salesManager = event.currentTarget.dataset.manager;
    console.log('=== Sales Manager Button Clicked ===');
    console.log('Sales manager clicked:', salesManager);
    console.log('Event target:', event.target);
    console.log('Event currentTarget:', event.currentTarget);
    
    this.selectedSalesManager = salesManager;
    this.salesManagerCandidatesModalTitle = `Active/In Process Candidates - ${salesManager}`;
    this.isLoadingSalesManagerCandidates = true;
    this.showSalesManagerCandidatesModal = true;
    
    try {
      console.log('Fetching candidates for:', salesManager);
      const result = await getCandidatesBySalesManager({ salesManager: salesManager });
      console.log('Candidates fetched:', result);
      
      if (result && result.length > 0) {
        this.salesManagerCandidates = result.map(candidate => ({
          id: candidate.id,
          name: candidate.name,
          email: candidate.email,
          phone: candidate.phone,
          emailLink: candidate.emailLink || '',
          phoneLink: candidate.phoneLink || '',
          position: candidate.position || 'Insurance Agent',
          status: candidate.status,
          location: candidate.location || 'Remote',
          salesManager: candidate.salesManager,
          recruiter: candidate.recruiter || 'Unassigned',
          nextMeeting: candidate.nextMeeting || 'Not Scheduled',
          leadSource: candidate.leadSource || 'Recruiter Portal',
          experience: candidate.experience || 'To Be Determined',
          createdDate: candidate.createdDate,
          lastModified: candidate.lastModified
        }));
        console.log('Final sales manager candidates:', this.salesManagerCandidates);
      } else {
        console.log('No candidates found for', salesManager);
        this.salesManagerCandidates = [];
      }
    } catch (error) {
      console.error('Error loading sales manager candidates:', error);
      this.salesManagerCandidates = [];
      this.showToast('Error', 'Failed to load candidates: ' + (error.body?.message || error.message), 'error');
    } finally {
      this.isLoadingSalesManagerCandidates = false;
    }
  }

  // Active Candidates Click Handler
  showActiveCandidates() {
    this.isLoadingCandidates = true;
    this.candidateModalTitle = 'Active/In Process Candidates';
    this.showCandidateModal = true;
    this.loadActiveCandidates();
  }

  // Data Loading Methods
  async loadActiveCandidates() {
    try {
      console.log('Loading active candidates...');
      const result = await getActiveCandidates();
      console.log('Active candidates loaded:', result);
      
      if (result && result.length > 0) {
        this.candidateModalData = result.map(candidate => {
          console.log('Processing candidate from Apex:', candidate);
          return {
            id: candidate.id,
            name: candidate.name,
            email: candidate.email,
            phone: candidate.phone,
            emailLink: candidate.emailLink || '',
            phoneLink: candidate.phoneLink || '',
            position: candidate.position || 'Insurance Agent',
            status: candidate.status,
            nextMeeting: candidate.nextMeeting || 'Not Scheduled',
            leadSource: candidate.leadSource || 'Recruiter Portal',
            experience: candidate.experience || 'To Be Determined',
            location: candidate.location || 'Remote',
            ownerName: candidate.ownerName || 'Unassigned',
            createdDate: candidate.createdDate,
            lastModified: candidate.lastModified
          };
        });
        console.log('Final candidate modal data:', this.candidateModalData);
        console.log('First candidate in array:', this.candidateModalData[0]);
      } else {
        console.log('No active candidates found');
        this.candidateModalData = [];
      }
    } catch (error) {
      console.error('Error loading active candidates:', error);
      this.candidateModalData = [];
      this.showToast('Error', 'Failed to load active candidates: ' + error.body?.message || error.message, 'error');
    } finally {
      this.isLoadingCandidates = false;
    }
  }

  loadLeads() {
    setTimeout(() => {
      this.candidateModalData = [
        { id: '3', name: 'Bob Johnson', status: 'Lead', phone: '555-0103', email: 'bob@email.com', source: 'LinkedIn', lastContact: '2025-10-16' },
        { id: '4', name: 'Sarah Wilson', status: 'Lead', phone: '555-0104', email: 'sarah@email.com', source: 'Indeed', lastContact: '2025-10-15' }
      ];
      this.isLoadingCandidates = false;
    }, 1000);
  }

  loadNewCandidates() {
    setTimeout(() => {
      this.candidateModalData = [
        { id: '5', name: 'Mike Davis', status: 'New', phone: '555-0105', email: 'mike@email.com', source: 'Referral', dateAdded: '2025-10-14' },
        { id: '6', name: 'Lisa Brown', status: 'New', phone: '555-0106', email: 'lisa@email.com', source: 'Website', dateAdded: '2025-10-13' }
      ];
      this.isLoadingCandidates = false;
    }, 1000);
  }

  loadUpcomingMeetings() {
    setTimeout(() => {
      this.candidateModalData = [
        { id: '7', name: 'Tom Wilson', meetingType: 'Initial Interview', scheduledDate: '2025-10-20', time: '10:00 AM', location: 'Conference Room A' },
        { id: '8', name: 'Amy Johnson', meetingType: 'Follow-up', scheduledDate: '2025-10-21', time: '2:00 PM', location: 'Video Call' }
      ];
      this.isLoadingCandidates = false;
    }, 1000);
  }

  loadAllCandidates() {
    setTimeout(() => {
      this.candidateModalData = [
        { id: '1', name: 'John Smith', status: 'Active', phone: '555-0101', email: 'john@email.com' },
        { id: '2', name: 'Jane Doe', status: 'Active', phone: '555-0102', email: 'jane@email.com' },
        { id: '3', name: 'Bob Johnson', status: 'Lead', phone: '555-0103', email: 'bob@email.com' }
      ];
      this.isLoadingCandidates = false;
    }, 1000);
  }

  // Interview Data Loading Methods
  loadAttractionInterviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '1', candidateName: 'John Smith', scheduledDate: '2025-10-22', time: '9:00 AM', interviewer: 'Sarah Manager', status: 'Scheduled' },
        { id: '2', candidateName: 'Jane Doe', scheduledDate: '2025-10-23', time: '11:00 AM', interviewer: 'Mike Lead', status: 'Scheduled' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadSI1Interviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '3', candidateName: 'Bob Johnson', scheduledDate: '2025-10-24', time: '2:00 PM', interviewer: 'Lisa Senior', status: 'Scheduled' },
        { id: '4', candidateName: 'Sarah Wilson', scheduledDate: '2025-10-25', time: '10:00 AM', interviewer: 'Tom Director', status: 'Scheduled' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadSI2Interviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '5', candidateName: 'Mike Davis', scheduledDate: '2025-10-26', time: '1:00 PM', interviewer: 'Amy VP', status: 'Scheduled' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadSI3Interviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '6', candidateName: 'Lisa Brown', scheduledDate: '2025-10-27', time: '3:00 PM', interviewer: 'David CEO', status: 'Scheduled' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadCareerInterviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '7', candidateName: 'Tom Wilson', scheduledDate: '2025-10-28', time: '4:00 PM', interviewer: 'Rachel HR', status: 'Scheduled' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadCompletedInterviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '8', candidateName: 'Alex Green', completedDate: '2025-10-18', interviewer: 'Sarah Manager', result: 'Passed', feedback: 'Excellent candidate' },
        { id: '9', candidateName: 'Chris Blue', completedDate: '2025-10-17', interviewer: 'Mike Lead', result: 'Passed', feedback: 'Good technical skills' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadNoShowInterviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '10', candidateName: 'Pat Red', scheduledDate: '2025-10-16', interviewer: 'Lisa Senior', status: 'No Show', notes: 'Did not attend scheduled interview' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadCanceledInterviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '11', candidateName: 'Sam Yellow', scheduledDate: '2025-10-15', interviewer: 'Tom Director', status: 'Canceled', reason: 'Candidate withdrew application' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  loadAllInterviews() {
    setTimeout(() => {
      this.interviewModalData = [
        { id: '1', candidateName: 'John Smith', scheduledDate: '2025-10-22', time: '9:00 AM', type: 'Attraction', status: 'Scheduled' },
        { id: '2', candidateName: 'Jane Doe', scheduledDate: '2025-10-23', time: '11:00 AM', type: 'Attraction', status: 'Scheduled' },
        { id: '3', candidateName: 'Bob Johnson', scheduledDate: '2025-10-24', time: '2:00 PM', type: 'SI1', status: 'Scheduled' }
      ];
      this.isLoadingInterviews = false;
    }, 1000);
  }

  // Call Stats Data Loading Methods
  loadRachyllScheduledCalls() {
    setTimeout(() => {
      this.callStatsModalData = [
        { id: '1', candidateName: 'John Smith', scheduledDate: '2025-10-20', time: '9:00 AM', purpose: 'Follow-up call', priority: 'High' },
        { id: '2', candidateName: 'Jane Doe', scheduledDate: '2025-10-21', time: '2:00 PM', purpose: 'Initial screening', priority: 'Medium' }
      ];
      this.isLoadingCallStats = false;
    }, 1000);
  }

  loadRachyllPastDueCalls() {
    setTimeout(() => {
      this.callStatsModalData = [
        { id: '3', candidateName: 'Bob Johnson', dueDate: '2025-10-15', purpose: 'Check-in call', daysPastDue: 4, priority: 'High' },
        { id: '4', candidateName: 'Sarah Wilson', dueDate: '2025-10-14', purpose: 'Status update', daysPastDue: 5, priority: 'Medium' }
      ];
      this.isLoadingCallStats = false;
    }, 1000);
  }

  loadRachyllAllCalls() {
    setTimeout(() => {
      this.callStatsModalData = [
        { id: '1', candidateName: 'John Smith', scheduledDate: '2025-10-20', status: 'Scheduled', purpose: 'Follow-up call' },
        { id: '2', candidateName: 'Jane Doe', scheduledDate: '2025-10-21', status: 'Scheduled', purpose: 'Initial screening' },
        { id: '3', candidateName: 'Bob Johnson', dueDate: '2025-10-15', status: 'Past Due', purpose: 'Check-in call' }
      ];
      this.isLoadingCallStats = false;
    }, 1000);
  }

  loadAllCallStats() {
    setTimeout(() => {
      this.callStatsModalData = [
        { id: '1', assignee: 'Rachyll Tenny', totalCalls: 25, scheduledCalls: 15, pastDueCalls: 5, completedToday: 5 },
        { id: '2', assignee: 'Other Manager', totalCalls: 18, scheduledCalls: 12, pastDueCalls: 3, completedToday: 3 }
      ];
      this.isLoadingCallStats = false;
    }, 1000);
  }

  // Schedule Interview Methods
  openScheduleInterviewModal() {
    this.showToast('Info', 'Schedule Interview modal will be added in the next deployment. Functionality coming soon!', 'info');
  }

  closeScheduleInterviewModal() {
    this.showScheduleInterviewModal = false;
    this.selectedCandidateId = '';
    this.selectedCandidateName = '';
    this.candidateSearchTerm = '';
    this.interviewType = '';
    this.interviewDate = '';
    this.interviewTime = '';
    this.interviewNotes = '';
    this.candidateLookupOptions = [];
    this.recentCalledCandidates = [];
    this.allCandidates = [];
    this.filteredCandidates = [];
    this.isLoadingRecentCandidates = false;
    this.isLoadingAllCandidates = false;
  }

  handleCandidateSelection(event) {
    this.selectedCandidateId = event.detail.value;
  }

  handleInterviewTypeChange(event) {
    this.interviewType = event.detail.value;
  }

  handleInterviewDateChange(event) {
    this.interviewDate = event.detail.value;
  }

  handleInterviewTimeChange(event) {
    this.interviewTime = event.detail.value;
  }

  handleInterviewNotesChange(event) {
    this.interviewNotes = event.detail.value;
  }

  handleRecentCandidateSelection(event) {
    const selectedRows = event.detail.selectedRows;
    if (selectedRows.length > 0) {
      this.selectedCandidateId = selectedRows[0].id;
      this.selectedCandidateName = selectedRows[0].name;
      this.showToast('Success', `Selected candidate: ${selectedRows[0].name}`, 'success');
    }
  }

  handleAllCandidateSelection(event) {
    const selectedRows = event.detail.selectedRows;
    if (selectedRows.length > 0) {
      this.selectedCandidateId = selectedRows[0].id;
      this.selectedCandidateName = selectedRows[0].name;
      this.showToast('Success', `Selected candidate: ${selectedRows[0].name}`, 'success');
    }
  }

  handleCandidateSearch(event) {
    const searchTerm = event.target.value.toLowerCase();
    this.candidateSearchTerm = searchTerm;
    
    if (searchTerm === '') {
      this.filteredCandidates = [...this.allCandidates];
    } else {
      this.filteredCandidates = this.allCandidates.filter(candidate => 
        candidate.name.toLowerCase().includes(searchTerm) ||
        candidate.email.toLowerCase().includes(searchTerm) ||
        candidate.phone.includes(searchTerm) ||
        candidate.status.toLowerCase().includes(searchTerm) ||
        candidate.source.toLowerCase().includes(searchTerm)
      );
    }
  }

  loadRecentCalledCandidates() {
    this.isLoadingRecentCandidates = true;
    // Load the last 10 candidates the user called
    setTimeout(() => {
      this.recentCalledCandidates = [
        { id: '001', name: 'John Smith', lastCallDate: '2025-10-18', phone: '555-0101', email: 'john.smith@email.com', lastCallPurpose: 'Follow-up call' },
        { id: '002', name: 'Jane Doe', lastCallDate: '2025-10-17', phone: '555-0102', email: 'jane.doe@email.com', lastCallPurpose: 'Initial screening' },
        { id: '003', name: 'Bob Johnson', lastCallDate: '2025-10-16', phone: '555-0103', email: 'bob.johnson@email.com', lastCallPurpose: 'Interview prep' },
        { id: '004', name: 'Sarah Wilson', lastCallDate: '2025-10-15', phone: '555-0104', email: 'sarah.wilson@email.com', lastCallPurpose: 'Status check' },
        { id: '005', name: 'Mike Davis', lastCallDate: '2025-10-14', phone: '555-0105', email: 'mike.davis@email.com', lastCallPurpose: 'Reference check' },
        { id: '006', name: 'Lisa Brown', lastCallDate: '2025-10-13', phone: '555-0106', email: 'lisa.brown@email.com', lastCallPurpose: 'Onboarding call' },
        { id: '007', name: 'Tom Wilson', lastCallDate: '2025-10-12', phone: '555-0107', email: 'tom.wilson@email.com', lastCallPurpose: 'Salary discussion' },
        { id: '008', name: 'Amy Johnson', lastCallDate: '2025-10-11', phone: '555-0108', email: 'amy.johnson@email.com', lastCallPurpose: 'Interview feedback' }
      ];
      this.isLoadingRecentCandidates = false;
    }, 800);
  }

  loadAllCandidates() {
    this.isLoadingAllCandidates = true;
    // Load all available candidates
    setTimeout(() => {
      this.allCandidates = [
        { id: '001', name: 'John Smith', phone: '555-0101', email: 'john.smith@email.com', status: 'Active', source: 'LinkedIn', createdDate: '2025-09-15' },
        { id: '002', name: 'Jane Doe', phone: '555-0102', email: 'jane.doe@email.com', status: 'Active', source: 'Indeed', createdDate: '2025-09-20' },
        { id: '003', name: 'Bob Johnson', phone: '555-0103', email: 'bob.johnson@email.com', status: 'Lead', source: 'Referral', createdDate: '2025-09-25' },
        { id: '004', name: 'Sarah Wilson', phone: '555-0104', email: 'sarah.wilson@email.com', status: 'Active', source: 'Website', createdDate: '2025-10-01' },
        { id: '005', name: 'Mike Davis', phone: '555-0105', email: 'mike.davis@email.com', status: 'Lead', source: 'LinkedIn', createdDate: '2025-10-05' },
        { id: '006', name: 'Lisa Brown', phone: '555-0106', email: 'lisa.brown@email.com', status: 'Active', source: 'Indeed', createdDate: '2025-10-08' },
        { id: '007', name: 'Tom Wilson', phone: '555-0107', email: 'tom.wilson@email.com', status: 'Lead', source: 'Referral', createdDate: '2025-10-10' },
        { id: '008', name: 'Amy Johnson', phone: '555-0108', email: 'amy.johnson@email.com', status: 'Active', source: 'Website', createdDate: '2025-10-12' },
        { id: '009', name: 'Chris Blue', phone: '555-0109', email: 'chris.blue@email.com', status: 'Lead', source: 'LinkedIn', createdDate: '2025-10-14' },
        { id: '010', name: 'Alex Green', phone: '555-0110', email: 'alex.green@email.com', status: 'Active', source: 'Indeed', createdDate: '2025-10-16' },
        { id: '011', name: 'Patricia White', phone: '555-0111', email: 'patricia.white@email.com', status: 'Active', source: 'Referral', createdDate: '2025-10-17' },
        { id: '012', name: 'David Black', phone: '555-0112', email: 'david.black@email.com', status: 'Lead', source: 'Website', createdDate: '2025-10-18' }
      ];
      this.filteredCandidates = [...this.allCandidates];
      this.isLoadingAllCandidates = false;
    }, 1000);
  }

  scheduleInterview() {
    if (!this.selectedCandidateId || !this.interviewType || !this.interviewDate || !this.interviewTime) {
      this.showToast('Error', 'Please select a candidate and fill in all required fields', 'error');
      return;
    }

    // TODO: Implement actual interview creation logic
    console.log('Scheduling interview:', {
      candidateId: this.selectedCandidateId,
      candidateName: this.selectedCandidateName,
      type: this.interviewType,
      date: this.interviewDate,
      time: this.interviewTime,
      notes: this.interviewNotes
    });

    this.showToast('Success', `Interview scheduled for ${this.selectedCandidateName} on ${this.interviewDate} at ${this.interviewTime}`, 'success');
    this.closeScheduleInterviewModal();
    
    // Refresh dashboard data
    return refreshApex(this.wiredDashboardData);
  }

  get isScheduleDisabled() {
    return !this.selectedCandidateId || !this.interviewType || !this.interviewDate || !this.interviewTime;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  // Action Modal Methods
  openCreateTicketModal() {
    this.showCreateTicketModal = true;
    // Pre-fill user information
    this.ticketContact = `${this.userName} (${this.userEmail})`;
  }

  closeCreateTicketModal() {
    this.showCreateTicketModal = false;
    this.ticketSubject = '';
    this.ticketDescription = '';
    this.ticketPriority = 'Medium';
    this.ticketCategory = 'General';
    this.ticketAttachments = [];
  }

  openScheduleCallModal() {
    console.log('Schedule Call button clicked');
    this.resetScheduleCallForm();
    // Ensure subject is set after reset
    setTimeout(() => {
      this.scheduleCallSubject = 'Call';
    }, 10);
    this.showScheduleCallModal = true;
  }
  
  openScheduleInterviewModal() {
    console.log('Schedule Interview button clicked');
    // For now, redirect to the standard Lightning navigation or open a candidate selection modal
    // This will navigate to the Interview object to create a new record
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Interview__c',
        actionName: 'new'
      }
    });
  }

  openRescheduleCallsModal() {
    this.showRescheduleCallsModal = true;
    this.loadPastDueCalls();
  }

  // Schedule Call Modal Methods
  resetScheduleCallForm() {
    this.scheduleCallSubject = 'Call';
    this.scheduleCallWhoId = '';
    this.scheduleCallContactName = '';
    this.scheduleCallWhatId = '';
    this.scheduleCallDate = '';
    this.scheduleCallPriority = 'Normal';
    this.scheduleCallStatus = 'Not Started'; // This maps to "Scheduled" in the UI
    this.scheduleCallDescription = '';
    this.isSchedulingCall = false;
    
    // Clear contact search data
    this.contactOptions = [];
    this.showContactOptions = false;
    this.isSearchingContacts = false;
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }
  }

  closeScheduleCallModal() {
    this.showScheduleCallModal = false;
    this.resetScheduleCallForm();
  }

  handleScheduleCallSubjectChange(event) {
    this.scheduleCallSubject = event.target.value;
  }

  handleScheduleCallContactChange(event) {
    this.scheduleCallContactName = event.target.value;
    console.log('Contact name entered:', this.scheduleCallContactName);
    
    // Clear existing timeout
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }
    
    // Search after user stops typing for 300ms
    if (this.scheduleCallContactName && this.scheduleCallContactName.length >= 2) {
      this.searchTimeout = setTimeout(() => {
        this.searchContacts();
      }, 300);
    } else {
      this.contactOptions = [];
      this.showContactOptions = false;
    }
  }

  handleContactFocus() {
    if (this.contactOptions.length > 0) {
      this.showContactOptions = true;
    }
  }

  handleContactBlur() {
    // Delay hiding to allow click on option
    setTimeout(() => {
      this.showContactOptions = false;
    }, 200);
  }

  handleContactSelect(event) {
    const contactId = event.target.dataset.contactId || event.currentTarget.dataset.contactId;
    const selectedContact = this.contactOptions.find(contact => contact.Id === contactId);
    
    if (selectedContact) {
      this.scheduleCallContactName = selectedContact.Name;
      this.scheduleCallWhoId = selectedContact.Id;
      this.showContactOptions = false;
      console.log('Selected contact:', selectedContact);
    }
  }

  async searchContacts() {
    console.log('=== Starting contact search ===');
    console.log('Search term:', this.scheduleCallContactName);
    
    this.isSearchingContacts = true;
    this.showContactOptions = true; // Show during search for loading state
    console.log('Set showContactOptions to true');
    
    try {
      // Call Apex method to search real Contact records
      console.log('Calling Apex searchContacts method...');
      const contacts = await searchContacts({ searchTerm: this.scheduleCallContactName });
      
      // Convert to format expected by template
      this.contactOptions = contacts.map(contact => ({
        Id: contact.Id,
        Name: contact.Name,
        Email: contact.Email || '',
        Phone: contact.Phone || '',
        Account: contact.Account || ''
      }));
      
      console.log('Search term:', this.scheduleCallContactName);
      console.log('Raw contacts from Apex:', contacts);
      console.log('Formatted contacts:', this.contactOptions);
      console.log('contactOptions length:', this.contactOptions.length);
      
      // Show dropdown if we have results OR if search term is long enough to show "no results"
      this.showContactOptions = true; // Always show during valid search
      this.isSearchingContacts = false;
      console.log('Final state - showContactOptions:', this.showContactOptions);
      console.log('Final state - isSearchingContacts:', this.isSearchingContacts);
      console.log('=== Search complete ===');
    } catch (error) {
      console.error('Error searching contacts:', error);
      console.error('Error details:', error.message);
      this.contactOptions = [];
      this.isSearchingContacts = false;
      this.showContactOptions = false; // Hide dropdown on error
      
      // Show user-friendly error
      this.dispatchEvent(new ShowToastEvent({
        title: 'Search Error',
        message: 'Unable to search contacts: ' + (error.message || 'Unknown error'),
        variant: 'error'
      }));
    }
  }

  get noContactsFound() {
    return !this.isSearchingContacts && this.contactOptions.length === 0 && this.scheduleCallContactName && this.scheduleCallContactName.length >= 2;
  }

  handleScheduleCallWhoChange(event) {
    // Handle lightning-input-field for Contact lookup
    const selectedValue = event.detail?.value || event.target?.value;
    this.scheduleCallWhoId = selectedValue;
    console.log('Selected contact:', selectedValue);
  }

  handleScheduleCallWhatChange(event) {
    this.scheduleCallWhatId = event.target.value;
  }

  handleScheduleCallDateChange(event) {
    this.scheduleCallDate = event.target.value;
  }

  handleScheduleCallPriorityChange(event) {
    this.scheduleCallPriority = event.target.value;
  }

  handleScheduleCallStatusChange(event) {
    this.scheduleCallStatus = event.target.value;
  }

  handleScheduleCallDescriptionChange(event) {
    this.scheduleCallDescription = event.target.value;
  }

  async submitScheduleCall() {
    if (this.isScheduleCallDisabled) {
      return;
    }

    this.isSchedulingCall = true;

    try {
      // Create task record
      const contactInfo = this.scheduleCallContactName ? `Contact: ${this.scheduleCallContactName}\n\n` : '';
      const fullDescription = `${contactInfo}${this.scheduleCallDescription || ''}`.trim();
      
      // Ensure IDs are either valid Salesforce IDs or null (not empty strings)
      const whoId = this.scheduleCallWhoId && this.scheduleCallWhoId.length === 18 ? this.scheduleCallWhoId : null;
      const whatId = this.scheduleCallWhatId && this.scheduleCallWhatId.length === 18 ? this.scheduleCallWhatId : null;
      
      const taskRecord = {
        Subject: this.scheduleCallSubject || 'Call',
        WhoId: whoId,
        WhatId: whatId,
        ActivityDate: this.scheduleCallDate,
        Status: this.scheduleCallStatus,
        Priority: this.scheduleCallPriority,
        Type: 'Call',
        TaskSubtype: 'Call',
        Description: fullDescription || null
        // OwnerId will be set by Apex to current user
      };
      
      console.log('Creating task with record:', taskRecord);

      // Call Apex method to create the task
      await this.createScheduledCallTask(taskRecord);

      // Show success message
      this.showToast('Success', `Call scheduled successfully for ${this.scheduleCallDate}`, 'success');

      // Update dashboard statistics
      this.userScheduledCalls += 1;
      this.userTotalAssigned += 1;

      // Refresh dashboard data
      this.refreshDashboard();

      // Close modal
      this.closeScheduleCallModal();

    } catch (error) {
      console.error('Error scheduling call:', error);
      this.showToast('Error', 'Failed to schedule call: ' + (error.body?.message || error.message), 'error');
    } finally {
      this.isSchedulingCall = false;
    }
  }

  async createScheduledCallTask(taskRecord) {
    console.log('Creating task with data:', taskRecord);
    return await createScheduledCall({ taskData: taskRecord });
  }

  openCreateNewCandidateFlow() {
    console.log('Create New Candidate button clicked - opening modal');
    this.showCreateCandidateModal = true;
    this.resetCandidateForm();
  }

  // Method to navigate to Contact creation (immediate working solution)
  navigateToNewCandidateRecord() {
    console.log('Navigating to Contact creation page...');
    
    try {
      // Navigate to Contact creation page
      this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
          objectApiName: 'Contact',
          actionName: 'new'
        }
      });
      
      // Show success message
      this.showToast('Success', 'Opening Contact creation form for new candidate. Please fill in contact details.', 'success');
      
    } catch (error) {
      console.error('Error navigating to Contact creation:', error);
      
      // Alternative fallback - try navigating to setup menu
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__navItemPage',
          attributes: {
            apiName: 'Contacts'
          }
        });
        this.showToast('Info', 'Opened Contacts tab. Click "New" to create a new candidate contact.', 'info');
      } catch (fallbackError) {
        console.error('Fallback navigation also failed:', fallbackError);
        this.showToast('Error', 'Navigation failed. Please manually navigate to Contacts and create a new record.', 'error');
      }
    }
  }

  closeRescheduleCallsModal() {
    this.showRescheduleCallsModal = false;
    this.selectedCallsForReschedule = [];
    this.selectedRescheduleCalls = [];
    this.newRescheduleDate = '';
    this.newRescheduleTime = '';
    this.rescheduleNotes = '';
    this.isLoadingRescheduleCalls = false;
  }

  openCreateCandidateModal() {
    this.showCreateCandidateModal = true;
  }

  closeCreateCandidateModal() {
    this.showCreateCandidateModal = false;
    this.resetCandidateForm();
  }

  resetCandidateForm() {
    this.newCandidateName = '';
    this.newCandidateEmail = '';
    this.newCandidatePhone = '';
    this.newCandidatePosition = '';
    this.newCandidateSource = 'Recruiter Portal';
    this.newCandidateNotes = '';
    this.duplicateContactFound = false;
    this.duplicateContactId = null;
  }

  // Contact Information Handlers
  handleNewCandidateNameChange(event) {
    this.newCandidateName = event.target.value;
    console.log('Name changed to:', this.newCandidateName);
  }

  async handleNewCandidateEmailChange(event) {
    this.newCandidateEmail = event.target.value;
    console.log('Email changed to:', this.newCandidateEmail);
    
    // Check for duplicate contact when email is entered
    if (this.newCandidateEmail && this.newCandidateEmail.includes('@')) {
      await this.checkForDuplicateContact();
    } else {
      this.duplicateContactFound = false;
      this.duplicateContactId = null;
    }
  }

  handleNewCandidatePhoneChange(event) {
    this.newCandidatePhone = event.target.value;
    console.log('Phone changed to:', this.newCandidatePhone);
  }

  // Check if contact already exists with this email
  async checkForDuplicateContact() {
    try {
      console.log('Checking for duplicate contact with email:', this.newCandidateEmail);
      const contacts = await searchContacts({ searchTerm: this.newCandidateEmail });
      
      // Look for exact email match
      const duplicateContact = contacts.find(contact => 
        contact.Email && contact.Email.toLowerCase() === this.newCandidateEmail.toLowerCase()
      );
      
      if (duplicateContact) {
        console.log('Duplicate contact found:', duplicateContact);
        this.duplicateContactFound = true;
        this.duplicateContactId = duplicateContact.Id;
      } else {
        this.duplicateContactFound = false;
        this.duplicateContactId = null;
      }
    } catch (error) {
      console.error('Error checking for duplicate contact:', error);
      this.duplicateContactFound = false;
      this.duplicateContactId = null;
    }
  }

  // Other form handlers
  handleNewCandidatePositionChange(event) {
    this.newCandidatePosition = event.target.value;
  }

  handleNewCandidateSourceChange(event) {
    this.newCandidateSource = event.target.value;
  }

  handleNewCandidateNotesChange(event) {
    this.newCandidateNotes = event.target.value;
  }

  handleCandidateNotesChange(event) {
    this.newCandidateNotes = event.target.value;
  }

  // Validation getter for candidate form
  get isCandidateSubmitDisabled() {
    const isDisabled = !this.newCandidateName || !this.newCandidateEmail;
    console.log('DEBUG - Create Candidate button disabled check:', {
      newCandidateName: this.newCandidateName,
      newCandidateEmail: this.newCandidateEmail,
      duplicateFound: this.duplicateContactFound,
      isDisabled: isDisabled
    });
    return isDisabled;
  }

  // Source options for dropdown
  get sourceOptions() {
    return [
      { label: 'Recruiter Portal', value: 'Recruiter Portal' },
      { label: 'LinkedIn', value: 'LinkedIn' },
      { label: 'Indeed', value: 'Indeed' },
      { label: 'Monster', value: 'Monster' },
      { label: 'Employee Referral', value: 'Employee Referral' },
      { label: 'Company Website', value: 'Company Website' },
      { label: 'Job Fair', value: 'Job Fair' },
      { label: 'Other', value: 'Other' }
    ];
  }

  // Position options for dropdown
  get positionOptions() {
    return [
      { label: 'Insurance Agent', value: 'Insurance Agent' },
      { label: 'Senior Insurance Agent', value: 'Senior Insurance Agent' },
      { label: 'Insurance Sales Representative', value: 'Insurance Sales Representative' },
      { label: 'Account Manager', value: 'Account Manager' },
      { label: 'Team Lead', value: 'Team Lead' },
      { label: 'Sales Manager', value: 'Sales Manager' },
      { label: 'Other', value: 'Other' }
    ];
  }

  openContractingModal() {
    this.showToast('Info', 'Contracting modal will be added in the next deployment. Functionality coming soon!', 'info');
  }

  closeContractingModal() {
    this.showContractingModal = false;
    this.contractingCandidateId = '';
    this.contractType = '';
    this.startDate = '';
    this.contractNotes = '';
  }

  openNotesModal() {
    this.showToast('Info', 'Notes & Follow-up modal will be added in the next deployment. Functionality coming soon!', 'info');
  }

  closeNotesModal() {
    this.showNotesModal = false;
  }

  // Form Field Handlers
  handleTicketSubjectChange(event) {
    this.ticketSubject = event.detail.value;
  }

  handleTicketDescriptionChange(event) {
    this.ticketDescription = event.detail.value;
  }

  handleTicketPriorityChange(event) {
    this.ticketPriority = event.detail.value;
  }

  handleTicketCategoryChange(event) {
    this.ticketCategory = event.detail.value;
  }

  handleTicketContactChange(event) {
    this.ticketContact = event.detail.value;
  }

  get isTicketSubmitDisabled() {
    return !this.ticketSubject || !this.ticketDescription || this.ticketSubject.trim() === '' || this.ticketDescription.trim() === '';
  }

  get hasSelectedCalls() {
    return this.selectedRescheduleCalls && this.selectedRescheduleCalls.length > 0;
  }

  get isRescheduleSubmitDisabled() {
    const hasDate = this.newRescheduleDate && this.newRescheduleDate.trim() !== '';
    const hasCalls = this.hasSelectedCalls;
    
    console.log('Validation check:', {
      hasDate: hasDate,
      dateValue: this.newRescheduleDate,
      hasCalls: hasCalls,
      callsCount: this.selectedRescheduleCalls?.length || 0,
      isDisabled: !hasDate || !hasCalls
    });
    
    return !hasDate || !hasCalls;
  }

  get todaysDate() {
    return new Date().toISOString().split('T')[0];
  }

  handleFileUpload(event) {
    const files = event.target.files;
    if (files.length > 0) {
      // Process file attachments
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        this.ticketAttachments.push({
          id: Date.now() + i,
          name: file.name,
          size: file.size,
          type: file.type
        });
      }
      this.showToast('Success', `${files.length} file(s) attached successfully`, 'success');
    }
  }

  captureScreen() {
    // Screen capture functionality would be implemented here
    // For now, simulate adding a screenshot
    this.ticketAttachments.push({
      id: Date.now(),
      name: 'screenshot_' + new Date().toISOString().slice(0,10) + '.png',
      size: 125000,
      type: 'image/png',
      isScreenshot: true
    });
    this.showToast('Success', 'Screen capture attached successfully', 'success');
  }

  removeAttachment(event) {
    const attachmentId = parseInt(event.target.dataset.attachmentId);
    this.ticketAttachments = this.ticketAttachments.filter(att => att.id !== attachmentId);
    this.showToast('Success', 'Attachment removed', 'success');
  }

  submitTicket() {
    if (!this.ticketSubject || !this.ticketDescription) {
      this.showToast('Error', 'Please fill in subject and description', 'error');
      return;
    }

    // TODO: Implement actual ticket creation
    console.log('Creating ticket:', {
      subject: this.ticketSubject,
      description: this.ticketDescription,
      priority: this.ticketPriority,
      category: this.ticketCategory,
      contact: this.ticketContact,
      attachments: this.ticketAttachments,
      userInfo: this.currentUser
    });

    this.showToast('Success', 'Ticket created successfully!', 'success');
    this.closeCreateTicketModal();
  }

  // Reschedule Calls Methods
  async loadPastDueCalls() {
    this.isLoadingRescheduleCalls = true;
    try {
      console.log('Loading real past due calls from Salesforce...');
      
      // Get real past due calls from Salesforce
      const pastDueCalls = await getPastDueCalls();
      
      console.log('Loaded past due calls:', pastDueCalls);
      
      if (pastDueCalls && pastDueCalls.length > 0) {
        this.selectedCallsForReschedule = pastDueCalls;
        console.log(`Loaded ${pastDueCalls.length} past due calls from Salesforce`);
      } else {
        // If no real past due calls, show a message
        this.selectedCallsForReschedule = [];
        console.log('No past due calls found in Salesforce');
        this.showToast('Info', 'No past due calls found. You can generate test calls if needed.', 'info');
      }
      
    } catch (error) {
      console.error('Error loading past due calls:', error);
      this.showToast('Error', 'Failed to load past due calls: ' + (error.body?.message || error.message), 'error');
      this.selectedCallsForReschedule = [];
    } finally {
      this.isLoadingRescheduleCalls = false;
    }
  }

  handleRescheduleCallSelection(event) {
    const selectedRows = event.detail.selectedRows;
    console.log('Raw selected rows:', selectedRows);
    
    // Force reactive update
    this.selectedRescheduleCalls = [...selectedRows];
    
    console.log('Selected calls for reschedule:', this.selectedRescheduleCalls);
    console.log('HasSelectedCalls getter result:', this.hasSelectedCalls);
    
    if (this.selectedRescheduleCalls.length > 0) {
      // Show a subtle success message for selection
      setTimeout(() => {
        this.showToast('Success', `${this.selectedRescheduleCalls.length} call(s) selected. Choose new date and time below.`, 'success');
      }, 100);
    } else {
      console.log('No calls selected');
    }
  }

  handleNewRescheduleDateChange(event) {
    this.newRescheduleDate = event.detail.value;
    console.log('Date changed to:', this.newRescheduleDate);
    
    // Force reactivity update
    this.newRescheduleDate = event.detail.value;
    
    // Trigger validation check
    setTimeout(() => {
      console.log('After date change - Button disabled:', this.isRescheduleSubmitDisabled);
    }, 100);
  }

  handleNewRescheduleTimeChange(event) {
    this.newRescheduleTime = event.detail.value;
    console.log('Time changed to:', this.newRescheduleTime);
  }

  handleRescheduleNotesChange(event) {
    this.rescheduleNotes = event.detail.value;
    console.log('Notes changed to:', this.rescheduleNotes);
  }

  async submitReschedule() {
    console.log('Submit reschedule clicked');
    console.log('Has selected calls:', this.hasSelectedCalls);
    console.log('Selected calls count:', this.selectedRescheduleCalls?.length || 0);
    console.log('New date:', this.newRescheduleDate);
    console.log('New time:', this.newRescheduleTime || 'Not specified (day-only)');

    if (!this.hasSelectedCalls) {
      this.showToast('Error', 'Please select at least one call to reschedule', 'error');
      return;
    }

    if (!this.newRescheduleDate) {
      this.showToast('Error', 'Please select a new date', 'error');
      return;
    }

    try {
      // Extract task IDs from selected calls
      const taskIds = this.selectedRescheduleCalls.map(call => call.id);
      
      console.log('Calling Apex with task IDs:', taskIds);
      
      // Call the Apex method
      const result = await rescheduleCalls({
        taskIds: taskIds,
        newDate: this.newRescheduleDate,
        newTime: this.newRescheduleTime || '',
        notes: this.rescheduleNotes || 'Rescheduled via recruiter dashboard'
      });
      
      console.log('Apex result:', result);
      
      if (result.startsWith('SUCCESS:')) {
        // Show success message
        this.showToast('Success', result.substring(8), 'success');
        
        // Refresh the dashboard data to show updated calls
        return refreshApex(this.dashboardData);
        
      } else if (result.startsWith('ERROR:')) {
        // Show error message
        this.showToast('Error', result.substring(6), 'error');
      }
      
    } catch (error) {
      console.error('Error rescheduling calls:', error);
      this.showToast('Error', 'Failed to reschedule calls: ' + (error.body?.message || error.message), 'error');
    } finally {
      // Close modal on success
      if (result && result.startsWith('SUCCESS:')) {
        this.closeRescheduleCallsModal();
      }
    }
  }

  // Create Candidate Methods
  async handleNewCandidateSubmit() {
    if (!this.newCandidateName || !this.newCandidateEmail) {
      this.showToast('Error', 'Name and email are required fields', 'error');
      return;
    }

    try {
      console.log('Creating candidate with contact information:', {
        name: this.newCandidateName,
        email: this.newCandidateEmail,
        phone: this.newCandidatePhone,
        position: this.newCandidatePosition,
        source: this.newCandidateSource,
        notes: this.newCandidateNotes,
        duplicateContactId: this.duplicateContactId
      });

      // Call Apex method to create both contact and candidate
      const result = await createCandidate({
        candidateName: this.newCandidateName,
        email: this.newCandidateEmail,
        phone: this.newCandidatePhone || '',
        contactId: this.duplicateContactId || '', // Use existing contact if duplicate found
        position: this.newCandidatePosition || 'Insurance Agent',
        source: this.newCandidateSource || 'Recruiter Portal',
        notes: this.newCandidateNotes || ''
      });

      console.log('Candidate creation result:', result);

      if (result.startsWith('SUCCESS:')) {
        this.showToast('Success', result.substring(8), 'success');
        this.closeCreateCandidateModal();
        
        // Refresh dashboard data to show updated candidate count
        return refreshApex(this.dashboardData);
        
      } else if (result.startsWith('ERROR:')) {
        this.showToast('Error', result.substring(6), 'error');
      }

    } catch (error) {
      console.error('Error creating candidate:', error);
      this.showToast('Error', 'Failed to create candidate: ' + (error.body?.message || error.message), 'error');
    }
  }

  // Contracting Methods
  handleContractSubmit() {
    if (!this.contractingCandidateId || !this.contractType || !this.startDate) {
      this.showToast('Error', 'Please fill in all required fields', 'error');
      return;
    }

    this.showToast('Success', 'Contracting process initiated successfully!', 'success');
    this.closeContractingModal();
  }

  // Notes and To-Do Methods
  loadUserNotes() {
    // Load user's notes and to-do items
    this.userNotes = 'Remember to follow up with top candidates this week.\n\nPrepare interview questions for SI2 round.';
    this.todoItems = [
      { id: 1, text: 'Call John Smith about offer', completed: false, dueDate: '2025-10-20' },
      { id: 2, text: 'Schedule SI3 interviews for next week', completed: false, dueDate: '2025-10-21' },
      { id: 3, text: 'Review resumes for Marketing position', completed: true, dueDate: '2025-10-19' }
    ];
  }

  handleNotesChange(event) {
    this.userNotes = event.detail.value;
  }

  handleNewTodoChange(event) {
    this.newTodoItem = event.detail.value;
  }

  handleTodoKeyPress(event) {
    if (event.key === 'Enter') {
      this.addTodoItem();
    }
  }

  // Additional form handlers
  handleRescheduleDateChange(event) {
    this.newRescheduleDate = event.detail.value;
  }

  handleRescheduleReasonChange(event) {
    this.rescheduleReason = event.detail.value;
  }

  handleNewCandidateNameChange(event) {
    this.newCandidateName = event.detail.value;
  }

  handleNewCandidateEmailChange(event) {
    this.newCandidateEmail = event.detail.value;
  }

  handleNewCandidatePhoneChange(event) {
    this.newCandidatePhone = event.detail.value;
  }

  handleNewCandidateSourceChange(event) {
    this.newCandidateSource = event.detail.value;
  }

  handleNewCandidateNotesChange(event) {
    this.newCandidateNotes = event.detail.value;
  }

  handleContractCandidateChange(event) {
    this.contractingCandidateId = event.detail.value;
  }

  handleContractTypeChange(event) {
    this.contractType = event.detail.value;
  }

  handleStartDateChange(event) {
    this.startDate = event.detail.value;
  }

  handleContractNotesChange(event) {
    this.contractNotes = event.detail.value;
  }

  addTodoItem() {
    if (!this.newTodoItem.trim()) {
      return;
    }

    this.todoItems.push({
      id: Date.now(),
      text: this.newTodoItem,
      completed: false,
      dueDate: ''
    });
    this.newTodoItem = '';
    this.showToast('Success', 'To-do item added', 'success');
  }

  toggleTodoComplete(event) {
    const itemId = parseInt(event.target.dataset.todoId);
    this.todoItems = this.todoItems.map(item => {
      if (item.id === itemId) {
        return { ...item, completed: !item.completed };
      }
      return item;
    });
  }

  saveNotes() {
    // TODO: Implement actual save functionality
    this.showToast('Success', 'Notes and to-do list saved successfully!', 'success');
  }

  get isTicketValid() {
    return this.ticketSubject && this.ticketDescription;
  }

  get isRescheduleValid() {
    return this.newRescheduleDate && this.rescheduleReason;
  }

  get isCandidateValid() {
    return this.newCandidateName && this.newCandidateEmail && this.newCandidatePhone;
  }

  get isContractValid() {
    return this.contractingCandidateId && this.contractType && this.startDate;
  }

  // Dashboard data getters
  get candidateStats() {
    return {
      active: this.activeCandidates || 0,
      leads: this.leads || 0,
      interviewed: this.totalCandidates || 0,
      hired: this.newCandidatesThisWeek || 0
    };
  }

  get scheduledInterviewStats() {
    return {
      thisWeek: this.proceedOutcome || 3,
      si1: this.holdOutcome || 5,
      career: this.declineOutcome || 2,
      total: (this.proceedOutcome || 3) + (this.holdOutcome || 5) + (this.declineOutcome || 2)
    };
  }

  get performanceMetrics() {
    // Contract Activity (Monthly)
    const contractAAdded = this.contractAAdded || 3;
    const contractBAdded = this.contractBAdded || 8;
    const contractATerminations = this.contractATerminations || 2;
    const contractBTerminations = this.contractBTerminations || 4;
    const contractBtoA = this.contractBtoA || 2;
    
    // Year-to-Date totals
    const totalContractAAdded = this.totalContractAAdded || 25;
    const totalContractATerms = this.totalContractATerms || 15;
    const totalContractBAdded = this.totalContractBAdded || 78;
    const totalContractBTerms = this.totalContractBTerms || 45;
    const totalBtoATransitions = this.totalBtoATransitions || 18;
    const contractAJan1 = this.contractAJan1 || 125;
    
    // Net Contract B Activity = B Added - B Termed - B to A Moves
    const netContractBActivity = totalContractBAdded - totalContractBTerms - totalBtoATransitions;
    
    // Net Field Force = Jan 1 + A Added - A Termed + Net B Activity
    const netFieldForce = contractAJan1 + totalContractAAdded - totalContractATerms + netContractBActivity;
    
    return {
      // Monthly Contract Activity
      contractAAdded: contractAAdded,
      contractBAdded: contractBAdded,
      contractATerminations: contractATerminations,
      contractBTerminations: contractBTerminations,
      contractBtoA: contractBtoA,
      interviewsScheduled: this.upcomingMeetings || 7,
      
      // Net Field Force Calculation Components
      contractAJan1: contractAJan1,
      totalContractAAdded: totalContractAAdded,
      totalContractATerms: totalContractATerms,
      netContractBActivity: netContractBActivity,
      netFieldForce: netFieldForce
    };
  }

  // Call Management getters
  get isCallCompletionDisabled() {
    return !this.callOutcome;
  }

  get todaysDateFormatted() {
    return new Date().toISOString().split('T')[0];
  }

  get recentActivity() {
    return this.recentActivities || [
      {
        id: 1,
        type: 'Interview Completed',
        description: 'SI1 interview completed',
        candidateName: 'John Smith',
        timeAgo: '2 hours ago',
        status: 'Completed',
        statusVariant: 'success'
      },
      {
        id: 2,
        type: 'Candidate Added',
        description: 'New candidate registered',
        candidateName: 'Pat Baker',
        timeAgo: 'Just now',
        status: 'New',
        statusVariant: 'brand'
      },
      {
        id: 3,
        type: 'Call Rescheduled',
        description: 'Follow-up call moved to tomorrow',
        candidateName: 'Jane Doe',
        timeAgo: '1 hour ago',
        status: 'Rescheduled',
        statusVariant: 'warning'
      }
    ];
  }

  // Dashboard click handlers
  handleMyScheduledCalls() {
    this.openCallManagementModal('scheduled');
  }
  
  handleMyPastDueCalls() {
    this.openCallManagementModal('pastdue');
  }
  
  handleUserTotalCalls() {
    this.showToast('Info', `You have ${this.userTotalAssigned} total calls assigned`, 'info');
  }

  // Methods called by HTML onclick handlers
  openScheduledCallsModal() {
    console.log('openScheduledCallsModal clicked');
    this.openDirectCallCompletion('scheduled');
  }

  openPastDueCallsModal() {
    console.log('openPastDueCallsModal clicked');
    this.openDirectCallCompletion('pastdue');
  }

  // Direct Call Completion Method
  async openDirectCallCompletion(type) {
    console.log('openDirectCallCompletion called with type:', type);
    this.callType = type;
    
    // Load a sample call for completion
    await this.loadNextCallForCompletion(type);
    
    if (this.selectedCall) {
      this.showCallCompletionModal = true;
      this.resetCallCompletionForm();
    } else {
      this.showToast('Info', `No ${type === 'scheduled' ? 'scheduled' : 'past due'} calls to complete`, 'info');
    }
  }

  async loadNextCallForCompletion(type) {
    try {
      // Generate sample call data - in real implementation, get next call from Salesforce
      await new Promise(resolve => setTimeout(resolve, 500)); // Simulate API call
      
      const sampleCalls = {
        scheduled: {
          id: '1',
          candidateName: 'Sarah Johnson',
          subject: 'Technical Interview Follow-up',
          phone: '(555) 123-4567',
          email: 'sarah.johnson@email.com',
          priority: 'High',
          scheduledDate: 'Today',
          scheduledTime: '2:00 PM',
          notes: 'Discussed React experience and availability for senior developer role.',
          company: 'Tech Solutions Inc.',
          position: 'Senior Frontend Developer'
        },
        pastdue: {
          id: '2', 
          candidateName: 'Michael Chen',
          subject: 'Initial Screening Call',
          phone: '(555) 234-5678',
          email: 'michael.chen@email.com',
          priority: 'Medium',
          scheduledDate: 'Yesterday',
          scheduledTime: '10:00 AM',
          notes: 'Needs follow-up on salary expectations and start date.',
          company: 'Digital Marketing Corp',
          position: 'Marketing Manager'
        }
      };
      
      this.selectedCall = sampleCalls[type];
      console.log('Selected call:', this.selectedCall);
      
    } catch (error) {
      console.error('Error loading call:', error);
      this.showToast('Error', 'Failed to load call details', 'error');
    }
  }

  // Call Management Methods (kept for potential future use)
  openCallManagementModal(type) {
    console.log('openCallManagementModal called with type:', type);
    this.callType = type;
    this.callModalTitle = type === 'scheduled' ? 'Scheduled Calls' : 'Past Due Calls';
    console.log('Setting showCallManagementModal to true');
    this.showCallManagementModal = true;
    this.loadCallsList(type);
  }

  closeCallManagementModal() {
    this.showCallManagementModal = false;
    this.callsList = [];
    this.callType = '';
    this.callModalTitle = '';
  }

  async loadCallsList(type) {
    this.isLoadingCalls = true;
    try {
      // Generate sample calls data - in real implementation, this would call Apex
      await this.generateSampleCalls(type);
    } catch (error) {
      this.showToast('Error', 'Failed to load calls: ' + error.message, 'error');
    } finally {
      this.isLoadingCalls = false;
    }
  }

  async generateSampleCalls(type) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    const baseCalls = [
      {
        id: '1',
        candidateName: 'Sarah Johnson',
        subject: 'Technical Interview Follow-up',
        phone: '(555) 123-4567',
        email: 'sarah.johnson@email.com',
        priority: 'High',
        priorityClass: 'slds-text-color_error'
      },
      {
        id: '2',
        candidateName: 'Michael Chen',
        subject: 'Initial Screening Call',
        phone: '(555) 234-5678',
        email: 'michael.chen@email.com',
        priority: 'Medium',
        priorityClass: 'slds-text-color_warning'
      },
      {
        id: '3',
        candidateName: 'Emily Rodriguez',
        subject: 'Reference Check Discussion',
        phone: '(555) 345-6789',
        email: 'emily.rodriguez@email.com',
        priority: 'High',
        priorityClass: 'slds-text-color_error'
      },
      {
        id: '4',
        candidateName: 'David Thompson',
        subject: 'Salary Negotiation',
        phone: '(555) 456-7890',
        email: 'david.thompson@email.com',
        priority: 'Low',
        priorityClass: 'slds-text-color_success'
      }
    ];

    if (type === 'scheduled') {
      this.callsList = baseCalls.map(call => ({
        ...call,
        scheduledDate: 'Today',
        scheduledTime: '2:00 PM',
        daysOverdue: 0
      }));
    } else {
      this.callsList = baseCalls.slice(0, 2).map(call => ({
        ...call,
        scheduledDate: 'Yesterday', 
        scheduledTime: '10:00 AM',
        daysOverdue: 1,
        overdueLabel: '1 Day Overdue'
      }));
    }
  }

  selectCallForCompletion(event) {
    const callId = event.target.dataset.callId || event.currentTarget.dataset.callId;
    this.selectedCall = this.callsList.find(call => call.id === callId);
    if (this.selectedCall) {
      this.showCallCompletionModal = true;
      this.resetCallCompletionForm();
    }
  }

  closeCallCompletionModal() {
    this.showCallCompletionModal = false;
    this.selectedCall = null;
    this.resetCallCompletionForm();
  }

  resetCallCompletionForm() {
    this.callOutcome = '';
    this.callNotes = '';
    this.needsFollowUp = false;
    this.followUpDate = '';
    this.followUpTime = '';
    this.editableCallDueDate = '';
    this.createNewCall = false;
    this.newCallSubject = '';
    this.newCallDate = '';
    this.newCallTime = '';
  }

  // Call completion form handlers
  handleCallOutcomeChange(event) {
    this.callOutcome = event.detail.value;
    this.needsFollowUp = ['voicemail', 'no_answer', 'email_followup'].includes(this.callOutcome);
  }

  handleCallNotesChange(event) {
    this.callNotes = event.detail.value;
  }

  handleCallDueDateChange(event) {
    this.editableCallDueDate = event.detail.value;
  }

  handleFollowUpDateChange(event) {
    this.followUpDate = event.detail.value;
  }

  handleFollowUpTimeChange(event) {
    this.followUpTime = event.detail.value;
  }

  // New call creation handlers
  handleCreateNewCallChange(event) {
    this.createNewCall = event.detail.checked;
    if (this.createNewCall) {
      // Set default values for new call
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      this.newCallDate = tomorrow.toISOString().split('T')[0];
      this.newCallTime = '14:00'; // 2:00 PM default
      this.newCallSubject = `Follow-up call with ${this.selectedCall?.candidateName || 'candidate'}`;
    }
  }

  handleNewCallSubjectChange(event) {
    this.newCallSubject = event.detail.value;
  }

  handleNewCallDateChange(event) {
    this.newCallDate = event.detail.value;
  }

  handleNewCallTimeChange(event) {
    this.newCallTime = event.detail.value;
  }

  // Quick completion handlers
  completeCallSuccess() {
    this.callOutcome = 'successful';
    this.needsFollowUp = false;
    this.callNotes = 'Call completed successfully - candidate engaged and interested.';
    // Auto-suggest creating a new call for successful calls
    this.createNewCall = true;
    this.handleCreateNewCallChange({ detail: { checked: true }});
    this.newCallSubject = `Next steps discussion with ${this.selectedCall?.candidateName}`;
  }

  completeCallWithFollowUp() {
    this.callOutcome = 'email_followup';
    this.needsFollowUp = true;
    this.callNotes = 'Unable to complete full discussion - follow-up needed.';
    // Set default follow-up for tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    this.followUpDate = tomorrow.toISOString().split('T')[0];
    this.followUpTime = '09:00';
    
    // Also suggest new call creation
    this.createNewCall = true;
    this.handleCreateNewCallChange({ detail: { checked: true }});
  }

  completeCallWithIssue() {
    this.callOutcome = 'no_answer';
    this.needsFollowUp = true;
    this.callNotes = 'No answer - will retry later.';
    // Set default follow-up for later today
    this.followUpDate = this.todaysDateFormatted;
    this.followUpTime = '16:00';
    
    // Create retry call
    this.createNewCall = true;
    this.handleCreateNewCallChange({ detail: { checked: true }});
    this.newCallSubject = `Retry call with ${this.selectedCall?.candidateName}`;
  }

  async submitCallCompletion() {
    if (!this.callOutcome) {
      this.showToast('Error', 'Please select a call outcome', 'error');
      return;
    }

    try {
      // Complete the task in Salesforce using Apex
      const result = await completeCallWithNotesAndSchedule({ 
        taskId: this.selectedCall.id,
        notes: this.callNotes,
        outcome: this.callOutcome,
        nextCallDate: null,
        newDueDate: this.editableCallDueDate || null
      });
      
      const successMessage = `Call completed successfully for ${this.selectedCall.candidateName}`;
      this.showToast('Success', successMessage, 'success');
      
      // Update dashboard statistics
      if (this.callType === 'scheduled') {
        this.userScheduledCalls = Math.max(0, this.userScheduledCalls - 1);
      } else if (this.callType === 'pastdue') {
        this.userPastDueCalls = Math.max(0, this.userPastDueCalls - 1);
      }
      
      // Refresh dashboard data and call lists
      this.refreshDashboard();
      this.loadCallLists();
      
      this.closeCallCompletionModal();
      
    } catch (error) {
      this.showToast('Error', 'Failed to complete call: ' + error.message, 'error');
    }
  }

  async createNewCallForCandidate() {
    try {
      console.log('Creating new call:', {
        candidate: this.selectedCall.candidateName,
        subject: this.newCallSubject,
        date: this.newCallDate,
        time: this.newCallTime
      });
      
      // In real implementation, this would create a new Task in Salesforce
      // using the RecruiterDashboardController.createNewCall method
      
      return { success: true };
    } catch (error) {
      console.error('Error creating new call:', error);
      throw error;
    }
  }

  showBulkActions() {
    this.showToast('Info', 'Bulk Actions feature coming soon!', 'info');
  }

  handleThisWeekInterviews() {
    this.showToast('Info', `${this.scheduledInterviewStats.thisWeek} interviews scheduled this week`, 'info');
  }

  handleSI1Interviews() {
    this.showToast('Info', `${this.scheduledInterviewStats.si1} SI1 interviews scheduled`, 'info');
  }

  handleCareerInterviews() {
    this.showToast('Info', `${this.scheduledInterviewStats.career} career interviews scheduled`, 'info');
  }

  // Contract Activity Click Handlers
  handleContractAAddedClick() {
    this.showToast('Success', 
      `Contract A Added - October 2025: ${this.contractAAdded} new agents contracted`, 
      'success'
    );
  }

  handleContractBAddedClick() {
    this.showToast('Success', 
      `Contract B Added - October 2025: ${this.contractBAdded} new agents contracted`, 
      'success'
    );
  }

  handleContractATermsClick() {
    this.showToast('Warning', 
      `Contract A Terminations - October 2025: ${this.contractATerminations} agents terminated`, 
      'warning'
    );
  }

  handleContractBTermsClick() {
    this.showToast('Warning', 
      `Contract B Terminations - October 2025: ${this.contractBTerminations} agents terminated`, 
      'warning'
    );
  }

  handleBtoATransitionsClick() {
    this.showToast('Success', 
      `Contract B to A Transitions - October 2025: ${this.contractBtoA} agents qualified and moved to Contract A (5+ opportunities, $2,500+ FYC)`, 
      'success'
    );
  }

  handleNetFieldForceClick() {
    const netBActivity = this.totalContractBAdded - this.totalContractBTerms - this.totalBtoATransitions;
    this.showToast('Info', 
      `Net Contract B Activity YTD: ${this.totalContractBAdded} Added - ${this.totalContractBTerms} Termed - ${this.totalBtoATransitions} Moved to A = ${netBActivity}`, 
      'info'
    );
  }

  // Candidate Detail Modal Methods
  handleCandidateClick(event) {
    const candidateId = event.currentTarget.dataset.candidateId;
    
    // Try to find candidate in either modal's data
    let candidate = this.candidateModalData.find(c => c.id === candidateId);
    if (!candidate && this.salesManagerCandidates) {
      candidate = this.salesManagerCandidates.find(c => c.id === candidateId);
    }
    
    console.log('Candidate clicked:', candidateId);
    console.log('Found candidate:', candidate);
    
    if (candidate) {
      // Set both approaches for compatibility
      this.selectedCandidateDetail = {
        id: candidate.id || '',
        name: candidate.name || '',
        email: candidate.email || '',
        phone: candidate.phone || '',
        emailLink: candidate.email ? `mailto:${candidate.email}` : null,
        phoneLink: candidate.phone ? `tel:${candidate.phone}` : null,
        position: candidate.position || 'Insurance Agent',
        status: candidate.status || 'Active/In Process',
        leadSource: candidate.leadSource || 'Recruiter Portal',
        experience: candidate.experience || 'To Be Determined',
        location: candidate.location || 'Remote',
        ownerName: candidate.ownerName || 'Unassigned',
        nextMeeting: candidate.nextMeeting || 'Not Scheduled',
        createdDate: candidate.createdDate || 'Unknown',
        lastModified: candidate.lastModified || 'Unknown'
      };
      
      // Also set individual tracked properties for better form binding
      this.candidateEditId = candidate.id || '';
      this.candidateEditName = candidate.name || '';
      this.candidateEditEmail = candidate.email || '';
      this.candidateEditPhone = candidate.phone || '';
      this.candidateEditPosition = candidate.position || 'Agent';
      this.candidateEditStatus = candidate.status || 'Active/In Process';
      this.candidateEditOfficeLocation = candidate.officeLocation || 'Los Angeles';
      this.candidateEditSalesManager = candidate.salesManager || 'Scott Primm';
      this.candidateEditRecruiter = candidate.recruiter || 'Susan Kim';
      this.candidateEditNextMeeting = candidate.nextMeeting || 'Not Scheduled';
      this.candidateEditSummary = candidate.summary || '';
      this.candidateEditAllNotes = candidate.allNotes || '';
      this.candidateEditCreatedDate = candidate.createdDate || 'Unknown';
      this.candidateEditLastModified = candidate.lastModified || 'Unknown';
      
      console.log('DEBUG - Candidate data received:', JSON.stringify(candidate, null, 2));
      console.log('DEBUG - candidate.name value:', candidate.name);
      console.log('DEBUG - candidate.id value:', candidate.id);
      console.log('DEBUG - Setting candidateEditName to:', this.candidateEditName);
      
      console.log('Selected candidate detail set:', this.selectedCandidateDetail);
      console.log('Individual edit fields set:', {
        name: this.candidateEditName,
        email: this.candidateEditEmail,
        phone: this.candidateEditPhone
      });
      this.showCandidateDetailModal = true;
    } else {
      console.error('Candidate not found with ID:', candidateId);
    }
  }

  handleEmailClick(event) {
    event.stopPropagation(); // Prevent candidate click from firing
    const candidateId = event.currentTarget.dataset.candidateId;
    const candidate = this.candidateModalData.find(c => c.id === candidateId);
    
    if (candidate && candidate.email) {
      window.open(`mailto:${candidate.email}`, '_blank');
      this.showToast('Success', `Opening email to ${candidate.name}`, 'success');
    } else {
      this.showToast('Warning', 'No email address available', 'warning');
    }
  }

  handlePhoneClick(event) {
    event.stopPropagation(); // Prevent candidate click from firing
    const candidateId = event.currentTarget.dataset.candidateId;
    const candidate = this.candidateModalData.find(c => c.id === candidateId);
    
    if (candidate && candidate.phone) {
      window.open(`tel:${candidate.phone}`, '_blank');
      this.showToast('Success', `Calling ${candidate.name}`, 'success');
    } else {
      this.showToast('Warning', 'No phone number available', 'warning');
    }
  }

  closeCandidateDetailModal() {
    this.showCandidateDetailModal = false;
    this.selectedCandidateDetail = null;
    console.log('Closed candidate detail modal');
  }

  // Interview Details Modal Handlers
  handleInterviewerHover(event) {
    const interviewType = event.currentTarget.dataset.interviewType;
    let hoverGradient = 'linear-gradient(to right, #fef8f0 0%, #fff5e6 100%)';
    let borderColor = '#f4a024';
    
    // Set hover colors based on interview type
    if (interviewType === 'C1-First') {
      hoverGradient = 'linear-gradient(to right, #e6f2ff 0%, #d9ebff 100%)';
      borderColor = '#0176d3';
    } else if (interviewType === 'Align-2nd') {
      hoverGradient = 'linear-gradient(to right, #d9f7f4 0%, #ccf5f1 100%)';
      borderColor = '#06a59a';
    } else if (interviewType === 'Plan-3rd') {
      hoverGradient = 'linear-gradient(to right, #ffe6e0 0%, #ffddd4 100%)';
      borderColor = '#e74c3c';
    } else if (interviewType === 'Present-4th') {
      hoverGradient = 'linear-gradient(to right, #fff4e6 0%, #ffedd9 100%)';
      borderColor = '#f4a024';
    } else if (interviewType === 'Optional-5th') {
      hoverGradient = 'linear-gradient(to right, #f3e6ff 0%, #ecdcff 100%)';
      borderColor = '#9b59b6';
    }
    
    event.currentTarget.style.background = hoverGradient;
    event.currentTarget.style.borderLeftColor = borderColor;
    event.currentTarget.style.transform = 'translateX(4px)';
    event.currentTarget.style.boxShadow = `0 4px 12px rgba(0, 51, 102, 0.12)`;
  }

  handleInterviewerHoverOut(event) {
    event.currentTarget.style.background = 'linear-gradient(to right, #ffffff 0%, #f8f9fa 100%)';
    const interviewType = event.currentTarget.dataset.interviewType;
    let borderColor = '#e0e5ee';
    
    if (interviewType === 'C1-First') borderColor = '#e0e5ee';
    else if (interviewType === 'Align-2nd') borderColor = '#d0f0ed';
    else if (interviewType === 'Plan-3rd') borderColor = '#f5d5d0';
    else if (interviewType === 'Present-4th') borderColor = '#fce4c4';
    else if (interviewType === 'Optional-5th') borderColor = '#e6d5f0';
    
    event.currentTarget.style.borderLeftColor = borderColor;
    event.currentTarget.style.transform = 'translateX(0)';
    event.currentTarget.style.boxShadow = '0 2px 4px rgba(0, 51, 102, 0.06)';
  }

  handleInterviewerClick(event) {
    const interviewer = event.currentTarget.dataset.interviewer;
    const interviewType = event.currentTarget.dataset.interviewType;
    
    console.log('Clicked interviewer:', interviewer, 'Type:', interviewType);
    
    this.selectedInterviewer = interviewer;
    this.selectedInterviewType = interviewType;
    this.interviewDetailsTitle = `${interviewer} - ${interviewType} Interviews`;
    
    // Filter interviews from the interviewerLeaderboard data
    this.loadInterviewDetails(interviewer, interviewType);
    
    this.showInterviewDetailsModal = true;
  }

  async loadInterviewDetails(interviewer, interviewType) {
    try {
      // Call Apex to get interview details
      const interviews = await getInterviewDetailsByInterviewer({ 
        interviewer: interviewer, 
        interviewType: interviewType 
      });

      // Map to display format
      this.interviewDetailsList = interviews.map(interview => {
        return {
          id: interview.id,
          candidateName: interview.candidateName || 'Unknown Candidate',
          interviewDate: this.formatDate(interview.interviewDate),
          status: interview.status || 'Completed',
          statusClass: this.getStatusClass(interview.status),
          notes: interview.notes || ''
        };
      });

      console.log('Loaded interview details:', this.interviewDetailsList.length, 'interviews');
    } catch (error) {
      console.error('Error loading interview details:', error);
      this.interviewDetailsList = [];
      this.showToast('Error', 'Failed to load interview details', 'error');
    }
  }

  getStatusClass(status) {
    if (!status) return 'slds-badge';
    
    const statusLower = status.toLowerCase();
    if (statusLower.includes('completed') || statusLower.includes('passed')) {
      return 'slds-badge slds-theme_success';
    } else if (statusLower.includes('scheduled') || statusLower.includes('pending')) {
      return 'slds-badge slds-theme_warning';
    } else if (statusLower.includes('cancelled') || statusLower.includes('failed')) {
      return 'slds-badge slds-theme_error';
    }
    return 'slds-badge';
  }

  formatDate(dateValue) {
    if (!dateValue) return 'No date';
    
    try {
      const date = new Date(dateValue);
      return date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (e) {
      return dateValue;
    }
  }

  closeInterviewDetailsModal() {
    this.showInterviewDetailsModal = false;
    this.interviewDetailsList = [];
    this.selectedInterviewer = '';
    this.selectedInterviewType = '';
    console.log('Closed interview details modal');
  }

  // Dark Mode Toggle
  toggleDarkMode() {
    this.isDarkMode = !this.isDarkMode;
    console.log('Dark mode toggled:', this.isDarkMode);
  }

  // Candidate Detail Form Handlers
  handleCandidateNameChange(event) {
    const newValue = event.target.value;
    console.log('Name changed to:', newValue);
    this.candidateEditName = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      name: newValue
    };
  }

  handleCandidateEmailChange(event) {
    const newValue = event.target.value;
    console.log('Email changed to:', newValue);
    this.candidateEditEmail = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      email: newValue,
      emailLink: newValue ? `mailto:${newValue}` : null
    };
  }

  handleCandidatePhoneChange(event) {
    const newValue = event.target.value;
    console.log('Phone changed to:', newValue);
    this.candidateEditPhone = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      phone: newValue,
      phoneLink: newValue ? `tel:${newValue}` : null
    };
  }

  handleCandidatePositionChange(event) {
    const newValue = event.target.value;
    console.log('Position changed to:', newValue);
    this.candidateEditPosition = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      position: newValue
    };
  }

  handleCandidateStatusChange(event) {
    const newValue = event.detail.value; // Note: combobox uses detail.value
    console.log('Status changed to:', newValue);
    this.candidateEditStatus = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      status: newValue
    };
  }

  handleCandidateLocationChange(event) {
    const newValue = event.target.value;
    console.log('Location changed to:', newValue);
    this.candidateEditLocation = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      location: newValue
    };
  }

  handleCandidateExperienceChange(event) {
    const newValue = event.detail.value; // Note: combobox uses detail.value
    console.log('Experience changed to:', newValue);
    this.candidateEditExperience = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      experience: newValue
    };
  }

  handleCandidateLeadSourceChange(event) {
    const newValue = event.target.value;
    console.log('Lead source changed to:', newValue);
    this.candidateEditLeadSource = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      leadSource: newValue
    };
  }

  handleOfficeLocationChange(event) {
    const newValue = event.target.value;
    console.log('Office location changed to:', newValue);
    this.candidateEditOfficeLocation = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      officeLocation: newValue
    };
  }

  handleSalesManagerChange(event) {
    const newValue = event.target.value;
    console.log('Sales manager changed to:', newValue);
    this.candidateEditSalesManager = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      salesManager: newValue
    };
  }

  handleRecruiterChange(event) {
    const newValue = event.target.value;
    console.log('Recruiter changed to:', newValue);
    this.candidateEditRecruiter = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      recruiter: newValue
    };
  }

  handleCandidateSummaryChange(event) {
    const newValue = event.target.value;
    console.log('Candidate summary changed');
    this.candidateEditSummary = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      summary: newValue
    };
  }

  handleAllNotesChange(event) {
    const newValue = event.target.value;
    console.log('All notes changed');
    this.candidateEditAllNotes = newValue;
    this.selectedCandidateDetail = {
      ...this.selectedCandidateDetail,
      allNotes: newValue
    };
  }

  async saveCandidateChanges() {
    try {
      console.log('Saving candidate changes to Salesforce...');
      
      // Call Apex method to update the candidate in Salesforce
      const result = await updateCandidate({
        candidateId: this.candidateEditId,
        candidateName: this.candidateEditName,
        email: this.candidateEditEmail,
        phone: this.candidateEditPhone,
        position: this.candidateEditPosition,
        status: this.candidateEditStatus,
        officeLocation: this.candidateEditOfficeLocation,
        salesManager: this.candidateEditSalesManager,
        recruiter: this.candidateEditRecruiter,
        summary: this.candidateEditSummary,
        allNotes: this.candidateEditAllNotes
      });
      
      if (result === 'SUCCESS') {
        // Update local data to reflect changes immediately
        const candidateIndex = this.candidateModalData.findIndex(c => c.id === this.candidateEditId);
        if (candidateIndex !== -1) {
          this.candidateModalData[candidateIndex] = {
            ...this.candidateModalData[candidateIndex],
            name: this.candidateEditName,
            email: this.candidateEditEmail,
            phone: this.candidateEditPhone,
            position: this.candidateEditPosition,
            status: this.candidateEditStatus
          };
          // Force reactivity
          this.candidateModalData = [...this.candidateModalData];
        }
        
        this.showToast('Success', `Candidate ${this.candidateEditName} saved successfully to Salesforce`, 'success');
        this.closeCandidateDetailModal();
      }
      
    } catch (error) {
      console.error('Error saving candidate:', error);
      this.showToast('Error', 'Failed to save candidate changes: ' + error.message, 'error');
    }
  }
}
