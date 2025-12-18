import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

// Import Candidate fields - Basic Info
import NAME from '@salesforce/schema/Candidate__c.Name';
import TYPE from '@salesforce/schema/Candidate__c.Type__c';
import FIRST_NAME from '@salesforce/schema/Candidate__c.First_Name__c';
import NICKNAME from '@salesforce/schema/Candidate__c.Nickname__c';
import MIDDLE_NAME from '@salesforce/schema/Candidate__c.Middle_Name_or_Initial__c';
import LAST_NAME from '@salesforce/schema/Candidate__c.Last_Name__c';
import SUFFIX from '@salesforce/schema/Candidate__c.Suffix__c';

// Contact & Status
import STATUS from '@salesforce/schema/Candidate__c.Status__c';
import EMAIL from '@salesforce/schema/Candidate__c.Email__c';
import PHONE from '@salesforce/schema/Candidate__c.Phone__c';
import CONTACT from '@salesforce/schema/Candidate__c.Contact__c';

// Career & Position
import POSITION from '@salesforce/schema/Candidate__c.Position__c';
import SALES_MANAGER from '@salesforce/schema/Candidate__c.Sales_Manager__c';
import RECRUITER from '@salesforce/schema/Candidate__c.RecruiterPicklist__c';
import OFFICE_LOCATION from '@salesforce/schema/Candidate__c.Office_Location_Picklist__c';
import HIGHEST_LEVEL from '@salesforce/schema/Candidate__c.Highest_Level_Achieved__c';
import AGENCY from '@salesforce/schema/Candidate__c.Agency__c';
import TARGET_MARKET from '@salesforce/schema/Candidate__c.Target_Market__c';
import RECRUITING_SOURCE from '@salesforce/schema/Candidate__c.Recruiting_Source__c';
import RECRUITING_SUB_SOURCE from '@salesforce/schema/Candidate__c.Recruiting_Sub_Source__c';
import GENDER from '@salesforce/schema/Candidate__c.Gender__c';
import WEBSITE from '@salesforce/schema/Candidate__c.Website__c';

// Career Progress & Contracting
import MDE200 from '@salesforce/schema/Candidate__c.MDE200__c';
import MS10 from '@salesforce/schema/Candidate__c.MS_10__c';
import CAREER_PRESENTATION from '@salesforce/schema/Candidate__c.Career_Presentation_ppt__c';
import NEXT_STEP from '@salesforce/schema/Candidate__c.Next_Step__c';
import NEXT_MEETING_DATE from '@salesforce/schema/Candidate__c.Next_Meeting_Date__c';
import STUDYING_FOR_LIFE_HEALTH from '@salesforce/schema/Candidate__c.Studying_for_Life_Health__c';
import REGISTERED from '@salesforce/schema/Candidate__c.Registered__c';
import INSURANCE_LICENSED from '@salesforce/schema/Candidate__c.Insurance_Licensed__c';
import DATE_OF_BIRTH from '@salesforce/schema/Candidate__c.Date_of_Birth__c';
import RELATIONSHIPS from '@salesforce/schema/Candidate__c.Relationships__c';
import OFFER_ACCEPTED from '@salesforce/schema/Candidate__c.Offer_Accepted__c';

// Device Inspection
import DEVICE_INSPECTION from '@salesforce/schema/Candidate__c.Device_Inspection__c';
import DEVICE_INSPECTION_STATUS from '@salesforce/schema/Candidate__c.Device_Inspection_Status__c';

// Notes
import SUMMARY from '@salesforce/schema/Candidate__c.Candidate_Summary__c';
import ALL_NOTES from '@salesforce/schema/Candidate__c.All_Notes__c';

const FIELDS = [
    NAME, TYPE, FIRST_NAME, NICKNAME, MIDDLE_NAME, LAST_NAME, SUFFIX,
    STATUS, EMAIL, PHONE, CONTACT, POSITION, SALES_MANAGER, RECRUITER,
    OFFICE_LOCATION, HIGHEST_LEVEL, AGENCY, TARGET_MARKET, RECRUITING_SOURCE,
    RECRUITING_SUB_SOURCE, GENDER, WEBSITE, MDE200, MS10, CAREER_PRESENTATION,
    NEXT_STEP, NEXT_MEETING_DATE, STUDYING_FOR_LIFE_HEALTH,
    REGISTERED, INSURANCE_LICENSED, DATE_OF_BIRTH, RELATIONSHIPS, OFFER_ACCEPTED,
    DEVICE_INSPECTION, DEVICE_INSPECTION_STATUS, SUMMARY, ALL_NOTES
];

export default class CandidateRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track activeTab = 'candidate';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    candidateRecord;

    // Tab Handlers
    handleTabChange(event) {
        this.activeTab = event.target.value;
    }

    get isCandidateTab() {
        return this.activeTab === 'candidate';
    }

    get isContractingTab() {
        return this.activeTab === 'contracting';
    }

    // Basic Info Getters
    get candidateName() {
        return getFieldValue(this.candidateRecord.data, NAME) || 'Candidate';
    }

    get position() {
        return getFieldValue(this.candidateRecord.data, POSITION) || 'Insurance Agent';
    }

    get office() {
        return getFieldValue(this.candidateRecord.data, OFFICE_LOCATION);
    }

    get status() {
        return getFieldValue(this.candidateRecord.data, STATUS);
    }

    // Contact Info Getters
    get email() {
        return getFieldValue(this.candidateRecord.data, EMAIL);
    }

    get emailLink() {
        const email = this.email;
        return email ? `mailto:${email}` : null;
    }

    get phone() {
        return getFieldValue(this.candidateRecord.data, PHONE);
    }

    get phoneLink() {
        const phone = this.phone;
        return phone ? `tel:${phone}` : null;
    }

    get contactId() {
        return getFieldValue(this.candidateRecord.data, CONTACT);
    }

    // Information Tab Field Getters
    get type() {
        return getFieldValue(this.candidateRecord.data, TYPE);
    }

    get firstName() {
        return getFieldValue(this.candidateRecord.data, FIRST_NAME);
    }

    get nickname() {
        return getFieldValue(this.candidateRecord.data, NICKNAME);
    }

    get middleName() {
        return getFieldValue(this.candidateRecord.data, MIDDLE_NAME);
    }

    get lastName() {
        return getFieldValue(this.candidateRecord.data, LAST_NAME);
    }

    get suffix() {
        return getFieldValue(this.candidateRecord.data, SUFFIX);
    }

    get agency() {
        return getFieldValue(this.candidateRecord.data, AGENCY);
    }

    get targetMarket() {
        return getFieldValue(this.candidateRecord.data, TARGET_MARKET);
    }

    get salesManager() {
        return getFieldValue(this.candidateRecord.data, SALES_MANAGER);
    }

    get recruiter() {
        return getFieldValue(this.candidateRecord.data, RECRUITER);
    }

    get recruitingSource() {
        return getFieldValue(this.candidateRecord.data, RECRUITING_SOURCE);
    }

    get recruitingSubSource() {
        return getFieldValue(this.candidateRecord.data, RECRUITING_SUB_SOURCE);
    }

    get gender() {
        return getFieldValue(this.candidateRecord.data, GENDER);
    }

    get website() {
        return getFieldValue(this.candidateRecord.data, WEBSITE);
    }

    get highestLevel() {
        return getFieldValue(this.candidateRecord.data, HIGHEST_LEVEL);
    }

    // Contracting Tab Field Getters
    get mde200() {
        return getFieldValue(this.candidateRecord.data, MDE200);
    }

    get ms10() {
        return getFieldValue(this.candidateRecord.data, MS10);
    }

    get careerPresentation() {
        return getFieldValue(this.candidateRecord.data, CAREER_PRESENTATION);
    }

    get nextStep() {
        return getFieldValue(this.candidateRecord.data, NEXT_STEP);
    }

    get nextMeetingDate() {
        return getFieldValue(this.candidateRecord.data, NEXT_MEETING_DATE);
    }

    get studyingForLifeHealth() {
        return getFieldValue(this.candidateRecord.data, STUDYING_FOR_LIFE_HEALTH);
    }

    get registered() {
        return getFieldValue(this.candidateRecord.data, REGISTERED);
    }

    get insuranceLicensed() {
        return getFieldValue(this.candidateRecord.data, INSURANCE_LICENSED);
    }

    get dateOfBirth() {
        return getFieldValue(this.candidateRecord.data, DATE_OF_BIRTH);
    }

    get relationships() {
        return getFieldValue(this.candidateRecord.data, RELATIONSHIPS);
    }

    get offerAccepted() {
        return getFieldValue(this.candidateRecord.data, OFFER_ACCEPTED);
    }

    // Device Inspection
    get deviceInspection() {
        return getFieldValue(this.candidateRecord.data, DEVICE_INSPECTION);
    }

    get deviceInspectionStatus() {
        return getFieldValue(this.candidateRecord.data, DEVICE_INSPECTION_STATUS);
    }

    get hasDeviceInspectionResult() {
        const status = this.deviceInspectionStatus;
        return status === 'Passed' || status === 'Failed';
    }

    get isDeviceInspectionPassed() {
        return this.deviceInspectionStatus === 'Passed';
    }

    get isDeviceInspectionFailed() {
        return this.deviceInspectionStatus === 'Failed';
    }

    get deviceInspectionBadgeClass() {
        if (this.isDeviceInspectionPassed) {
            return 'device-inspection-badge passed';
        } else if (this.isDeviceInspectionFailed) {
            return 'device-inspection-badge failed';
        }
        return 'device-inspection-badge';
    }

    // Notes
    get summary() {
        return getFieldValue(this.candidateRecord.data, SUMMARY);
    }

    get allNotes() {
        return getFieldValue(this.candidateRecord.data, ALL_NOTES);
    }

    // Action Button Handlers
    handleEdit() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Candidate__c',
                actionName: 'edit'
            }
        });
    }

    handleCreateInterview() {
        // Launch Create Interview quick action
        const defaultValues = encodeDefaultFieldValues({
            Candidate__c: this.recordId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Interview__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                useRecordTypeCheck: 1
            }
        });
    }

    handleStartContracting() {
        // Navigate to Start Contracting for Candidate flow
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/flow/Start_Contracting_for_Candidate?recordId=${this.recordId}`
            }
        });
    }

    handleDelete() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Candidate__c',
                actionName: 'delete'
            }
        });
    }

    navigateToContact() {
        if (this.contactId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.contactId,
                    objectApiName: 'Contact',
                    actionName: 'view'
                }
            });
        }
    }

    handleCreateNote() {
        // Trigger the related list's New button action
        // Use NavigationMixin to open new note in current context
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ContentNote',
                actionName: 'new'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
}
