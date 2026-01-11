
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe } from 'lightning/empApi';
import getALCData from '@salesforce/apex/ALCRecordViewController.getALCData';
import getNotes from '@salesforce/apex/ALCRecordViewController.getNotes';
import getActivities from '@salesforce/apex/ALCRecordViewController.getActivities';
import ID_FIELD from '@salesforce/schema/ALC__c.Id';

export default class AlcRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track activeTab = 'alc';
    @track notes = [];
    @track activities = [];
    @track alcData;
    @track error;
    @track isLoading = true;
    @track showCreateContractModal = false;
    @track isEditMode = false;
    refreshInterval;
    subscription = null;
    channelName = '/data/ALC__ChangeEvent';

    @wire(getRecord, { recordId: '$recordId', fields: [ID_FIELD] })
    wiredRecord({ data }) {
        if (data) {
            this.loadAlcData();
        }
    }

    connectedCallback() {
        this.loadAlcData();
        this.subscribeToCdc();
        // Auto-refresh notes/activities every 60s (Salesforce LWC best practice: use setTimeout recursion)
        const refresh = () => {
            this.loadNotes();
            this.loadActivities();
            this.refreshInterval = setTimeout(refresh, 60000);
        };
        this.refreshInterval = setTimeout(refresh, 60000);
    }

    disconnectedCallback() {
        this.unsubscribeFromCdc();
        if (this.refreshInterval) {
            clearTimeout(this.refreshInterval);
        }
    }

    loadAlcData() {
        this.isLoading = true;
        getALCData({ alcId: this.recordId })
            .then(result => {
                this.alcData = result;
                this.isLoading = false;
            })
            .catch(e => {
                this.error = e;
                this.isLoading = false;
            });
        this.loadNotes();
        this.loadActivities();
    }

    loadNotes() {
        getNotes({ alcId: this.recordId })
            .then(result => {
                this.notes = result;
            })
            .catch(() => {
                this.notes = [];
            });
    }

    loadActivities() {
        getActivities({ alcId: this.recordId })
            .then(result => {
                this.activities = result;
            })
            .catch(() => {
                this.activities = [];
            });
    }

    subscribeToCdc() {
        subscribe(this.channelName, -1, () => {
            this.loadAlcData();
        });
    }

    unsubscribeFromCdc() {
        unsubscribe(this.channelName, () => {});
    }

    handleCreateContract() {
        this.showCreateContractModal = true;
    }

    handleCloseModal() {
        this.showCreateContractModal = false;
    }

    handleTabChange(event) {
        this.activeTab = event.target.name;
    }

    toggleEditMode() {
        this.isEditMode = !this.isEditMode;
    }
    
    // Navigation to Candidate record if linked
    navigateToCandidate() {
        if (!this.alcData || !this.alcData.Related_Candidate__c) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.alcData.Related_Candidate__c,
                objectApiName: 'Candidate__c',
                actionName: 'view'
            }
        });
    }
    
    get hasCandidateLink() {
        return !!(this.alcData && this.alcData.Related_Candidate__c);
    }

    get editModeLabel() {
        return this.isEditMode ? 'View' : 'Edit Inline';
    }
    get editModeVariant() {
        return this.isEditMode ? 'neutral' : 'brand-outline';
    }
    get editModeIcon() {
        return this.isEditMode ? 'utility:preview' : 'utility:edit';
    }

    // Removed dynamic class and variant getters for tab buttons to ensure strict LWC template compliance

    get alcName() {
        return this.alcData ? this.alcData.Name : '';
    }
    get contractType() {
        return this.alcData ? this.alcData.Contract_Type__c : '';
    }
    get office() {
        return this.alcData ? this.alcData.Office__c : '';
    }
    get effectiveDate() {
        return this.alcData ? this.alcData.Contract_Effective__c : '';
    }
    get expirationDate() {
        return this.alcData ? this.alcData.Contract_B_Expiration_Date__c : '';
    }
    // No Status__c field on ALC__c, so return blank or computed value if needed
    get status() {
        return '';
    }

    // Contact-linked fields
    get contactFirstName() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.FirstName : '';
    }
    get contactLastName() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.LastName : '';
    }
    get contactEmail() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.Email : '';
    }
    get contactMobile() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.MobilePhone : '';
    }
    get contactHomePhone() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.HomePhone : '';
    }
    get contactMailingStreet() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.MailingStreet : '';
    }
    get contactMailingCity() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.MailingCity : '';
    }
    get contactMailingState() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.MailingState : '';
    }
    get contactMailingPostalCode() {
        return this.alcData && this.alcData.Contact__r ? this.alcData.Contact__r.MailingPostalCode : '';
    }

    // Licensing badges
    get isLifeLicensed() {
        return this.alcData ? this.alcData.Life_Insurance_Licensed__c : false;
    }
    get isRegistered() {
        return this.alcData ? this.alcData.Registered__c : false;
    }

    handleALCSuccess() {
        this.isEditMode = false;
        this.loadAlcData();
    }
    handleContactSuccess() {
        this.isEditMode = false;
        this.loadAlcData();
    }
    handleError() {
        // Silent for now; could show toast
    }

    get isAlcTab() {
        return this.activeTab === 'alc';
    }
    get isNotesTab() {
        return this.activeTab === 'notes';
    }
    get isActivitiesTab() {
        return this.activeTab === 'activities';
    }
}
