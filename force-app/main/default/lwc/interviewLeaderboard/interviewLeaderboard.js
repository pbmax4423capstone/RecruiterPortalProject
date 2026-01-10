import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import DASHBOARD_FILTER_CHANNEL from '@salesforce/messageChannel/DashboardFilterChannel__c';
import getCurrentMonthLeaderboard from '@salesforce/apex/InterviewLeaderboardNewController.getCurrentMonthLeaderboard';
import getThisWeekInterviews from '@salesforce/apex/InterviewLeaderboardNewController.getThisWeekInterviews';
import getThisMonthInterviews from '@salesforce/apex/InterviewLeaderboardNewController.getThisMonthInterviews';
import getInterviewsByType from '@salesforce/apex/InterviewLeaderboardNewController.getInterviewsByType';

export default class InterviewLeaderboard extends LightningElement {
    @wire(MessageContext)
    messageContext;
    
    @api darkMode = false;
    @api embedded = false; // True when embedded in unified dashboard
    @track leaderboardData = [];
    @track error;
    @track isLoading = true;
    @track showWeeklyModal = false;
    subscription = null;

    get containerClass() {
        return this.darkMode ? 'leaderboard-container dark-mode' : 'leaderboard-container';
    }

    get componentWrapperClass() {
        return this.darkMode ? 'interview-leaderboard-wrapper dark-mode' : 'interview-leaderboard-wrapper';
    }

    get leaderboardRowClass() {
        return this.darkMode ? 'leaderboard-row dark-mode' : 'leaderboard-row';
    }

    get modalClass() {
        return this.darkMode ? 'slds-modal slds-fade-in-open dark-mode' : 'slds-modal slds-fade-in-open';
    }
    @track weeklyInterviews = [];
    @track isLoadingWeekly = false;
    @track showMonthlyModal = false;
    @track monthlyInterviews = [];
    @track isLoadingMonthly = false;
    @track showTypeModal = false;
    @track typeInterviews = [];
    @track isLoadingType = false;
    @track currentModalTitle = '';

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.loadLeaderboard();
    }

    subscribeToMessageChannel() {
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
        
        // Interview leaderboard doesn't filter by Sales Manager or Date Range
        // but responds to refresh requests
        if (message.refreshRequested) {
            this.refreshData();
        }
    }

    // Public API method for parent to trigger refresh
    @api
    async refreshData() {
        try {
            await this.loadLeaderboard();
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

    loadLeaderboard() {
        this.isLoading = true;
        getCurrentMonthLeaderboard()
            .then(data => {
                this.leaderboardData = data.map((entry, index) => {
                    return {
                        ...entry,
                        rank: index + 1
                    };
                });
                this.error = undefined;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.leaderboardData = [];
                this.isLoading = false;
                console.error('Error loading leaderboard:', error);
            });
    }

    handleRefresh() {
        this.loadLeaderboard();
    }

    get hasData() {
        return this.leaderboardData && this.leaderboardData.length > 0;
    }

    get noDataMessage() {
        return 'No interview data available for this month';
    }

    // Calculate totals across all users
    get totalInterviewsThisWeek() {
        return this.leaderboardData.reduce((sum, entry) => sum + (entry.interviewsThisWeek || 0), 0);
    }

    get totalInterviewsThisMonth() {
        return this.leaderboardData.reduce((sum, entry) => sum + (entry.totalInterviews || 0), 0);
    }

    get totalCiFirst() {
        return this.leaderboardData.reduce((sum, entry) => sum + (entry.ciFirstCount || 0), 0);
    }

    get totalAlignSecond() {
        return this.leaderboardData.reduce((sum, entry) => sum + (entry.alignSecondCount || 0), 0);
    }

    get totalPlanThird() {
        return this.leaderboardData.reduce((sum, entry) => sum + (entry.planThirdCount || 0), 0);
    }

    get totalPresentFourth() {
        return this.leaderboardData.reduce((sum, entry) => sum + (entry.presentFourthCount || 0), 0);
    }

    get totalOptionalFifth() {
        return this.leaderboardData.reduce((sum, entry) => sum + (entry.optionalFifthCount || 0), 0);
    }

    // Get top performers for each category
    get ciFirstLeaders() {
        return this.leaderboardData
            .filter(entry => entry.ciFirstCount > 0)
            .sort((a, b) => b.ciFirstCount - a.ciFirstCount)
            .slice(0, 5);
    }

    get alignSecondLeaders() {
        return this.leaderboardData
            .filter(entry => entry.alignSecondCount > 0)
            .sort((a, b) => b.alignSecondCount - a.alignSecondCount)
            .slice(0, 5);
    }

    get planThirdLeaders() {
        return this.leaderboardData
            .filter(entry => entry.planThirdCount > 0)
            .sort((a, b) => b.planThirdCount - a.planThirdCount)
            .slice(0, 5);
    }

    get presentFourthLeaders() {
        return this.leaderboardData
            .filter(entry => entry.presentFourthCount > 0)
            .sort((a, b) => b.presentFourthCount - a.presentFourthCount)
            .slice(0, 5);
    }

    get optionalFifthLeaders() {
        return this.leaderboardData
            .filter(entry => entry.optionalFifthCount > 0)
            .sort((a, b) => b.optionalFifthCount - a.optionalFifthCount)
            .slice(0, 5);
    }

    // Weekly modal handlers
    openWeeklyModal() {
        this.showWeeklyModal = true;
        this.isLoadingWeekly = true;
        
        getThisWeekInterviews()
            .then(data => {
                this.weeklyInterviews = data;
                this.isLoadingWeekly = false;
            })
            .catch(error => {
                console.error('Error loading weekly interviews:', error);
                this.isLoadingWeekly = false;
            });
    }

    closeWeeklyModal() {
        this.showWeeklyModal = false;
        this.weeklyInterviews = [];
    }

    // Monthly modal handlers
    openMonthlyModal() {
        this.showMonthlyModal = true;
        this.isLoadingMonthly = true;
        
        getThisMonthInterviews()
            .then(data => {
                this.monthlyInterviews = data;
                this.isLoadingMonthly = false;
            })
            .catch(error => {
                console.error('Error loading monthly interviews:', error);
                this.isLoadingMonthly = false;
            });
    }

    closeMonthlyModal() {
        this.showMonthlyModal = false;
        this.monthlyInterviews = [];
    }

    // Type-specific modal handlers
    handleCiFirstClick() {
        this.openTypeModal('Ci-First');
    }

    handleAlignSecondClick() {
        this.openTypeModal('Align-2nd');
    }

    handlePlanThirdClick() {
        this.openTypeModal('Plan-3rd');
    }

    handlePresentFourthClick() {
        this.openTypeModal('Present-4th');
    }

    handleOptionalFifthClick() {
        this.openTypeModal('Optional-5th');
    }

    openTypeModal(interviewType) {
        this.currentModalTitle = interviewType;
        this.showTypeModal = true;
        this.isLoadingType = true;
        
        getInterviewsByType({ interviewType: interviewType })
            .then(data => {
                this.typeInterviews = data;
                this.isLoadingType = false;
            })
            .catch(error => {
                console.error('Error loading interviews by type:', error);
                this.isLoadingType = false;
            });
    }

    closeTypeModal() {
        this.showTypeModal = false;
        this.typeInterviews = [];
        this.currentModalTitle = '';
    }

    get typeModalCount() {
        return this.typeInterviews.length;
    }
}
