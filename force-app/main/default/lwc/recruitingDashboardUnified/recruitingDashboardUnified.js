import { LightningElement, wire, track, api } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import DASHBOARD_FILTER_CHANNEL from '@salesforce/messageChannel/DashboardFilterChannel__c';
import getDashboardConfig from '@salesforce/apex/UnifiedDashboardController.getDashboardConfig';
import getSalesManagerOptions from '@salesforce/apex/UnifiedDashboardController.getSalesManagerOptions';

const STORAGE_KEY_ACTIVE_TAB = 'unifiedDashboard_activeTab';
const STORAGE_KEY_SHOW_RECRUITING_METRICS = 'unifiedDashboard_showRecruitingMetrics';
const STORAGE_KEY_SALES_MANAGER = 'unifiedDashboard_salesManagerFilter';
const STORAGE_KEY_DATE_RANGE = 'unifiedDashboard_dateRangeFilter';

export default class RecruitingDashboardUnified extends LightningElement {
    @wire(MessageContext)
    messageContext;
    
    @api darkMode = false;
    @track activeTabValue = 'directorMetrics';
    @track salesManagerOptions = [];
    @track selectedSalesManager = 'All Sales Managers';
    @track selectedDateRange = 'THIS_MONTH';
    @track isRefreshing = false;
    @track loadedTabs = new Set();
    
    // Dashboard config from Apex
    userName = '';
    isDirector = false;
    isRachyllTenny = false;
    showRecruitingMetricsTab = false;
    showToggleButton = false;
    
    darkModeSubscription = null;
    configLoaded = false;

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.loadFromLocalStorage();
        this.loadSalesManagerOptions();
    }

    // Subscribe to dark mode changes
    subscribeToMessageChannel() {
        this.darkModeSubscription = subscribe(
            this.messageContext,
            DARK_MODE_CHANNEL,
            (message) => this.handleDarkModeChange(message)
        );
    }

    handleDarkModeChange(message) {
        this.darkMode = message.darkModeEnabled;
    }

    // Load preferences from localStorage
    loadFromLocalStorage() {
        const savedTab = localStorage.getItem(STORAGE_KEY_ACTIVE_TAB);
        const savedShowRecruiting = localStorage.getItem(STORAGE_KEY_SHOW_RECRUITING_METRICS);
        const savedSalesManager = localStorage.getItem(STORAGE_KEY_SALES_MANAGER);
        const savedDateRange = localStorage.getItem(STORAGE_KEY_DATE_RANGE);
        
        if (savedTab) {
            this.activeTabValue = savedTab;
        }
        
        if (savedShowRecruiting !== null) {
            // Will be applied after config loads
            this.showRecruitingMetricsTab = savedShowRecruiting === 'true';
        }
        
        if (savedSalesManager) {
            this.selectedSalesManager = savedSalesManager;
        }
        
        if (savedDateRange) {
            this.selectedDateRange = savedDateRange;
        }
    }

    // Wire dashboard config
    @wire(getDashboardConfig)
    wiredConfig({ error, data }) {
        if (data) {
            this.userName = data.userName;
            this.isDirector = data.isDirector;
            this.isRachyllTenny = data.isRachyllTenny;
            
            // Only Directors can see toggle button
            this.showToggleButton = this.isDirector;
            
            // Check localStorage for recruiting metrics visibility
            const savedShowRecruiting = localStorage.getItem(STORAGE_KEY_SHOW_RECRUITING_METRICS);
            
            if (savedShowRecruiting !== null) {
                // Use saved preference
                this.showRecruitingMetricsTab = savedShowRecruiting === 'true';
            } else {
                // Default: Show if user is Rachyll or Director
                this.showRecruitingMetricsTab = data.showRecruitingMetrics;
                // Save default preference
                localStorage.setItem(STORAGE_KEY_SHOW_RECRUITING_METRICS, 
                                   this.showRecruitingMetricsTab.toString());
            }
            
            this.configLoaded = true;
            
        } else if (error) {
            this.showError('Error loading dashboard configuration', error);
        }
    }

    // Wire Sales Manager options
    @wire(getSalesManagerOptions)
    wiredSalesManagerOptions({ error, data }) {
        if (data) {
            this.salesManagerOptions = data.map(option => ({
                label: option,
                value: option,
                variant: option === this.selectedSalesManager ? 'brand' : 'neutral'
            }));
        } else if (error) {
            this.showError('Error loading Sales Manager options', error);
        }
    }

    loadSalesManagerOptions() {
        // Options loaded via @wire
    }

    // Handle tab activation
    handleTabChange(event) {
        const newTab = event.target.value;
        this.activeTabValue = newTab;
        localStorage.setItem(STORAGE_KEY_ACTIVE_TAB, newTab);
        
        // Lazy load tab data if not already loaded
        if (!this.loadedTabs.has(newTab)) {
            this.loadTabData(newTab);
        }
    }

    // Load data for a specific tab (lazy loading)
    loadTabData(tabName) {
        // Get the child component and call its refreshData method
        const component = this.getTabComponent(tabName);
        
        if (component && component.refreshData) {
            component.refreshData()
                .then(() => {
                    this.loadedTabs.add(tabName);
                })
                .catch(error => {
                    console.error('Error loading tab data:', error);
                });
        } else {
            // Mark as loaded even if no refresh method
            this.loadedTabs.add(tabName);
        }
    }

    // Get reference to child component based on tab name
    getTabComponent(tabName) {
        let selector;
        
        switch (tabName) {
            case 'recruitingMetrics':
                selector = 'c-scheduled-calls-modal';
                break;
            case 'directorMetrics':
                selector = 'c-recruiting-director-dashboard';
                break;
            case 'candidatePipeline':
                selector = 'c-candidate-kanban';
                break;
            case 'careerContracting':
                selector = 'c-sales-manager-contracting-kanban';
                break;
            case 'interviewLeaderboard':
                selector = 'c-interview-leaderboard';
                break;
            case 'salesManagerActivity':
                selector = 'c-sales-manager-activity';
                break;
            default:
                return null;
        }
        
        return this.template.querySelector(selector);
    }

    // Handle global refresh button
    async handleRefreshAll() {
        this.isRefreshing = true;
        
        try {
            // Get all visible child components and refresh them
            const refreshPromises = [];
            const activeComponent = this.getTabComponent(this.activeTabValue);
            
            if (activeComponent && activeComponent.refreshData) {
                refreshPromises.push(activeComponent.refreshData());
            }
            
            // Publish filter change with refresh flag
            this.publishFilterChange(true);
            
            await Promise.all(refreshPromises);
            
            this.showSuccess('Dashboard refreshed successfully');
        } catch (error) {
            this.showError('Error refreshing dashboard', error);
        } finally {
            this.isRefreshing = false;
        }
    }

    // Handle Sales Manager button click
    handleSalesManagerClick(event) {
        const clickedValue = event.target.dataset.value;
        this.selectedSalesManager = clickedValue;
        localStorage.setItem(STORAGE_KEY_SALES_MANAGER, this.selectedSalesManager);
        
        // Update button variants
        this.salesManagerOptions = this.salesManagerOptions.map(option => ({
            ...option,
            variant: option.value === clickedValue ? 'brand' : 'neutral'
        }));
        
        // Auto-refresh on filter change
        this.publishFilterChange(true);
    }

    // Handle date range button click
    handleDateRangeClick(event) {
        const range = event.target.dataset.range;
        this.selectedDateRange = range;
        localStorage.setItem(STORAGE_KEY_DATE_RANGE, range);
        
        // Auto-refresh on filter change
        this.publishFilterChange(true);
    }

    // Publish filter changes via LMS
    publishFilterChange(refreshRequested = false) {
        const message = {
            salesManagerFilter: this.selectedSalesManager,
            dateRangeFilter: this.selectedDateRange,
            refreshRequested: refreshRequested
        };
        
        publish(this.messageContext, DASHBOARD_FILTER_CHANNEL, message);
    }

    // Handle toggle recruiting metrics tab visibility
    handleToggleRecruitingMetrics() {
        this.showRecruitingMetricsTab = !this.showRecruitingMetricsTab;
        localStorage.setItem(STORAGE_KEY_SHOW_RECRUITING_METRICS, 
                           this.showRecruitingMetricsTab.toString());
        
        // If hiding and currently on recruiting metrics tab, switch to director metrics
        if (!this.showRecruitingMetricsTab && this.activeTabValue === 'recruitingMetrics') {
            this.activeTabValue = 'directorMetrics';
            localStorage.setItem(STORAGE_KEY_ACTIVE_TAB, this.activeTabValue);
        }
    }

    // Computed properties
    get containerClass() {
        return this.darkMode ? 'unified-dashboard dark-mode' : 'unified-dashboard';
    }

    get headerClass() {
        return this.darkMode ? 'dashboard-header dark-mode' : 'dashboard-header';
    }

    get refreshButtonDisabled() {
        return this.isRefreshing;
    }

    get refreshButtonLabel() {
        return this.isRefreshing ? 'Refreshing...' : 'Refresh All';
    }

    get toggleMetricsIcon() {
        return this.showRecruitingMetricsTab ? 'utility:hide' : 'utility:display_text';
    }

    get toggleMetricsLabel() {
        return this.showRecruitingMetricsTab ? 'Hide Recruiting Metrics' : 'Show Recruiting Metrics';
    }

    get isMonthSelected() {
        return this.selectedDateRange === 'THIS_MONTH' ? 'brand' : 'neutral';
    }

    get isQuarterSelected() {
        return this.selectedDateRange === 'THIS_QUARTER' ? 'brand' : 'neutral';
    }

    get isYearSelected() {
        return this.selectedDateRange === 'THIS_YEAR' ? 'brand' : 'neutral';
    }

    // Utility methods
    showSuccess(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        }));
    }

    showError(title, error) {
        let message = 'Unknown error';
        if (error && error.body && error.body.message) {
            message = error.body.message;
        } else if (error && error.message) {
            message = error.message;
        } else if (typeof error === 'string') {
            message = error;
        }
        
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error'
        }));
    }
}
