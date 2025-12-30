import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import getRecentActivity from '@salesforce/apex/RecentActivityController.getRecentActivity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecentActivity extends LightningElement {
    @wire(MessageContext)
    messageContext;
    
    @api darkMode = false;
    @track activities = [];
    @track error;
    @track isLoading = true;
    @track lastRefreshed = '';
    subscription = null;

    get containerClass() {
        return this.darkMode ? 'activity-container dark-mode' : 'activity-container';
    }

    get activityCardClass() {
        return this.darkMode ? 'activity-card dark-mode' : 'activity-card';
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.loadActivities();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            DARK_MODE_CHANNEL,
            (message) => this.handleDarkModeChange(message)
        );
    }

    handleDarkModeChange(message) {
        this.darkMode = message.darkModeEnabled;
    }

    loadActivities() {
        this.isLoading = true;
        console.log('Loading recent activity...');
        getRecentActivity()
            .then(data => {
                console.log('Received data:', data);
                console.log('Number of activities:', data ? data.length : 0);
                this.activities = data.map(task => {
                    return {
                        ...task,
                        contactName: task.Who?.Name || '',
                        relatedToName: task.What?.Name || '',
                        formattedTime: task.CompletedDateTime ? 
                            new Date(task.CompletedDateTime).toLocaleTimeString('en-US', { 
                                hour: 'numeric', 
                                minute: '2-digit',
                                hour12: true 
                            }) : ''
                    };
                });
                this.error = undefined;
                this.isLoading = false;
                this.updateLastRefreshed();
            })
            .catch(error => {
                console.error('Error loading recent activity:', error);
                console.error('Error details:', JSON.stringify(error));
                this.error = error;
                this.activities = [];
                this.isLoading = false;
            });
    }

    updateLastRefreshed() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('en-US', { 
            hour: 'numeric', 
            minute: '2-digit',
            hour12: true 
        });
        const dateString = now.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric' 
        });
        this.lastRefreshed = `${dateString}, ${timeString}`;
    }

    handleRefresh() {
        this.loadActivities();
    }

    handleCardClick(event) {
        const taskId = event.currentTarget.dataset.id;
        if (taskId) {
            window.open(`/lightning/r/Task/${taskId}/view`, '_blank');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get hasData() {
        return this.activities && this.activities.length > 0;
    }
}