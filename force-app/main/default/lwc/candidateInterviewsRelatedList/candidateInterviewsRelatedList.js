import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInterviews from '@salesforce/apex/CandidateRecordViewController.getInterviews';
import getNextInterviewType from '@salesforce/apex/InterviewSequenceHelper.getNextInterviewType';
import getCurrentUserName from '@salesforce/apex/InterviewSequenceHelper.getCurrentUserName';
import getCandidateInterviewSummary from '@salesforce/apex/InterviewSequenceHelper.getCandidateInterviewSummary';

export default class CandidateInterviewsRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    interviews = [];
    error;
    wiredInterviewsResult;
    @track showCreateInterviewModal = false;
    @track suggestedInterviewType = '';
    @track currentUserName = '';
    @track interviewSummary = null;
    @track showInterviewerField = false;

    columns = [
        {
            label: 'Interview Name',
            fieldName: 'Name',
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'Name' },
                name: 'view_details',
                variant: 'base'
            }
        },
        { 
            label: 'Type', 
            fieldName: 'Type__c', 
            type: 'text'
        },
        { 
            label: 'Status', 
            fieldName: 'Status__c', 
            type: 'text'
        },
        { 
            label: 'Scheduled', 
            fieldName: 'Scheduled_Time__c', 
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        },
        { 
            label: 'Completed', 
            fieldName: 'Completed_Date__c', 
            type: 'date'
        },
        { 
            label: 'Outcome', 
            fieldName: 'Outcome__c', 
            type: 'text'
        },
        { 
            label: 'Interviewer', 
            fieldName: 'Interviewer__c', 
            type: 'text'
        }
    ];

    @wire(getInterviews, { candidateId: '$recordId' })
    wiredInterviews(result) {
        this.wiredInterviewsResult = result;
        if (result.data) {
            this.interviews = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.interviews = [];
        }
    }

    get hasInterviews() {
        return this.interviews && this.interviews.length > 0;
    }

    get interviewCount() {
        return this.interviews ? this.interviews.length : 0;
    }

    async handleCreateInterview() {
        // Open modal and fetch interview suggestions
        this.showCreateInterviewModal = true;
        this.showInterviewerField = false;
        
        console.log('handleCreateInterview called for candidateId:', this.recordId);
        
        // Fetch suggested interview type and summary
        try {
            console.log('Calling getNextInterviewType...');
            const suggestedType = await getNextInterviewType({ candidateId: this.recordId });
            console.log('getNextInterviewType returned:', suggestedType);
            
            console.log('Calling getCurrentUserName...');
            const userName = await getCurrentUserName();
            console.log('getCurrentUserName returned:', userName);
            
            console.log('Calling getCandidateInterviewSummary...');
            const summary = await getCandidateInterviewSummary({ candidateId: this.recordId });
            console.log('getCandidateInterviewSummary returned:', JSON.stringify(summary));
            
            this.suggestedInterviewType = suggestedType;
            this.currentUserName = userName;
            this.interviewSummary = summary;
            
            console.log('Successfully set all values');
        } catch (error) {
            console.error('Error fetching interview suggestions:', JSON.stringify(error));
            console.error('Error message:', error.body ? error.body.message : error.message);
            console.error('Error stack:', error.body ? error.body.stackTrace : error.stack);
            // Set defaults on error
            this.suggestedInterviewType = 'Ci-First';
            this.currentUserName = 'Current User';
            this.interviewSummary = null;
        }
    }

    closeCreateInterviewModal() {
        this.showCreateInterviewModal = false;
        this.showInterviewerField = false;
        this.suggestedInterviewType = '';
        this.currentUserName = '';
        this.interviewSummary = null;
    }
    
    toggleInterviewerField() {
        this.showInterviewerField = !this.showInterviewerField;
    }

    handleInterviewSuccess(event) {
        const interviewId = event.detail.id;
        console.log('Interview created successfully with ID:', interviewId);
        this.showCreateInterviewModal = false;
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Interview created successfully!',
                variant: 'success'
            })
        );
        
        // Refresh the interviews list
        refreshApex(this.wiredInterviewsResult);
    }

    handleInterviewError(event) {
        console.error('Error creating interview:', JSON.stringify(event.detail));
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Error creating interview. Please try again.',
                variant: 'error'
            })
        );
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'view_details') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    objectApiName: 'Interview__c',
                    actionName: 'view'
                }
            });
        }
    }
}
