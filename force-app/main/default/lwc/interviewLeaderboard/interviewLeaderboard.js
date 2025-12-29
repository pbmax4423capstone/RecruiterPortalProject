import { LightningElement, track } from 'lwc';
import getCurrentMonthLeaderboard from '@salesforce/apex/InterviewLeaderboardNewController.getCurrentMonthLeaderboard';
import getThisWeekInterviews from '@salesforce/apex/InterviewLeaderboardNewController.getThisWeekInterviews';
import getThisMonthInterviews from '@salesforce/apex/InterviewLeaderboardNewController.getThisMonthInterviews';
import getInterviewsByType from '@salesforce/apex/InterviewLeaderboardNewController.getInterviewsByType';

export default class InterviewLeaderboard extends LightningElement {
    @track leaderboardData = [];
    @track error;
    @track isLoading = true;
    @track showWeeklyModal = false;
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
        this.loadLeaderboard();
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
