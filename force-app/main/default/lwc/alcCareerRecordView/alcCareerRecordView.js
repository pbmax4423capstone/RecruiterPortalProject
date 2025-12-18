import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

// Import fields
import FIRST_NAME from '@salesforce/schema/ALC__c.First_Name__c';
import LAST_NAME from '@salesforce/schema/ALC__c.Last_Name__c';
import STAGE from '@salesforce/schema/ALC__c.Stage__c';
import POSITION from '@salesforce/schema/ALC__c.Position__c';
import SALES_MANAGER from '@salesforce/schema/ALC__c.Sales_Manager__c';
import OFFICE from '@salesforce/schema/ALC__c.Office__c';
import MOBILE from '@salesforce/schema/ALC__c.Mobile__c';
import PERSONAL_EMAIL from '@salesforce/schema/ALC__c.Personal_Email_Address__c';
import START_DATE from '@salesforce/schema/ALC__c.Start_date__c';
import CONTRACT_EFFECTIVE from '@salesforce/schema/ALC__c.Contract_Effective__c';
import CONTRACT_TYPE from '@salesforce/schema/ALC__c.Contract_Type__c';
import MMID from '@salesforce/schema/ALC__c.MMID__c';
import DOB from '@salesforce/schema/ALC__c.DOB__c';
import HOME_ADDRESS from '@salesforce/schema/ALC__c.Home_Address__c';
import LIFE_INSURANCE_LICENSED from '@salesforce/schema/ALC__c.Life_Insurance_Licensed__c';
import REGISTERED from '@salesforce/schema/ALC__c.Registered__c';
import NOTES from '@salesforce/schema/ALC__c.Notes__c';
import NEXT_MEETING from '@salesforce/schema/ALC__c.Next_Meeting_Date__c';
import CANDIDATE from '@salesforce/schema/ALC__c.Candidate__c';

const FIELDS = [
    FIRST_NAME, LAST_NAME, STAGE, POSITION, SALES_MANAGER, OFFICE, MOBILE,
    PERSONAL_EMAIL, START_DATE, CONTRACT_EFFECTIVE, CONTRACT_TYPE, MMID,
    DOB, HOME_ADDRESS, LIFE_INSURANCE_LICENSED, REGISTERED, NOTES, NEXT_MEETING, CANDIDATE
];

export default class AlcCareerRecordView extends NavigationMixin(LightningElement) {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    alcRecord;

    get fullName() {
        const firstName = getFieldValue(this.alcRecord.data, FIRST_NAME) || '';
        const lastName = getFieldValue(this.alcRecord.data, LAST_NAME) || '';
        return `${firstName} ${lastName}`.trim() || 'ALC Record';
    }

    get stage() {
        return getFieldValue(this.alcRecord.data, STAGE);
    }

    get position() {
        return getFieldValue(this.alcRecord.data, POSITION);
    }

    get salesManager() {
        return getFieldValue(this.alcRecord.data, SALES_MANAGER);
    }

    get office() {
        return getFieldValue(this.alcRecord.data, OFFICE);
    }

    get mobile() {
        return getFieldValue(this.alcRecord.data, MOBILE);
    }

    get email() {
        return getFieldValue(this.alcRecord.data, PERSONAL_EMAIL);
    }

    get startDate() {
        return getFieldValue(this.alcRecord.data, START_DATE);
    }

    get contractEffective() {
        return getFieldValue(this.alcRecord.data, CONTRACT_EFFECTIVE);
    }

    get contractType() {
        return getFieldValue(this.alcRecord.data, CONTRACT_TYPE);
    }

    get mmid() {
        return getFieldValue(this.alcRecord.data, MMID);
    }

    get dob() {
        return getFieldValue(this.alcRecord.data, DOB);
    }

    get homeAddress() {
        return getFieldValue(this.alcRecord.data, HOME_ADDRESS);
    }

    get lifeInsuranceLicensed() {
        return getFieldValue(this.alcRecord.data, LIFE_INSURANCE_LICENSED);
    }

    get registered() {
        return getFieldValue(this.alcRecord.data, REGISTERED);
    }

    get notes() {
        return getFieldValue(this.alcRecord.data, NOTES);
    }

    get nextMeeting() {
        return getFieldValue(this.alcRecord.data, NEXT_MEETING);
    }

    get candidateId() {
        return getFieldValue(this.alcRecord.data, CANDIDATE);
    }

    get stageColor() {
        const stage = this.stage;
        if (!stage) return '#6c757d';
        
        const stageColors = {
            'Initial Form Sent': '#0070d2',
            'MM ONX sent': '#3b8ad9',
            'In Background': '#f59e0b',
            'Receive NRF Info': '#10b981',
            'Registered': '#22c55e',
            'Contracted': '#059669'
        };
        
        return stageColors[stage] || '#6c757d';
    }

    get stageBadgeClass() {
        return `status-badge status-${this.stage?.toLowerCase().replace(/\s+/g, '-') || 'default'}`;
    }

    get hasLicense() {
        return this.lifeInsuranceLicensed === true || this.lifeInsuranceLicensed === 'true';
    }

    get isRegistered() {
        return this.registered === true || this.registered === 'true';
    }

    get phoneLink() {
        return this.mobile ? `tel:${this.mobile}` : '#';
    }

    get emailLink() {
        return this.email ? `mailto:${this.email}` : '#';
    }

    get licenseIcon() {
        return this.hasLicense ? 'utility:success' : 'utility:close';
    }

    get registeredIcon() {
        return this.isRegistered ? 'utility:success' : 'utility:close';
    }

    navigateToCandidate() {
        if (this.candidateId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.candidateId,
                    actionName: 'view'
                }
            });
        }
    }

    handleEdit() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'ALC__c',
                actionName: 'edit'
            }
        });
    }

    handleCreateTicket() {
        // Launch Create a Ticket Flow
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName: 'ALC__c.Create_a_Ticket'
            }
        });
    }

    handleStartContracting() {
        // Launch Start Contracting for Candidate Flow
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName: 'ALC__c.Start_Contracting_for_Candidate'
            }
        });
    }

    handleChangeRecordType() {
        // Launch Change Record Type quick action
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'ALC__c',
                actionName: 'view'
            },
            state: {
                recordTypeId: null,
                nooverride: '1'
            }
        });
    }

    handleDelete() {
        // Navigate to delete action
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'ALC__c',
                actionName: 'delete'
            }
        });
    }
}
