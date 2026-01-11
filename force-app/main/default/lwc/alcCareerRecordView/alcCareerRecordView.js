import { LightningElement, api, wire, track } from 'lwc';
import getALCData from '@salesforce/apex/ALCRecordViewController.getALCData';
import getContactSnapshot from '@salesforce/apex/ALCRecordViewController.getContactSnapshot';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

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
import CONTRACT_EXPIRATION from '@salesforce/schema/ALC__c.Contract_B_Expiration_Date__c';
import MMID from '@salesforce/schema/ALC__c.MMID__c';
import DOB from '@salesforce/schema/ALC__c.DOB__c';
import HOME_ADDRESS from '@salesforce/schema/ALC__c.Home_Address__c';
import LIFE_INSURANCE_LICENSED from '@salesforce/schema/ALC__c.Life_Insurance_Licensed__c';
import REGISTERED from '@salesforce/schema/ALC__c.Registered__c';
import NOTES from '@salesforce/schema/ALC__c.Notes__c';
import NEXT_MEETING from '@salesforce/schema/ALC__c.Next_Meeting_Date__c';
import CANDIDATE from '@salesforce/schema/ALC__c.Candidate__c';
import CONTACT from '@salesforce/schema/ALC__c.Contact__c';

// Contact fields via UI API for reliable rendering
import CONTACT_FIRSTNAME from '@salesforce/schema/Contact.FirstName';
import CONTACT_LASTNAME from '@salesforce/schema/Contact.LastName';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';
import CONTACT_MOBILE from '@salesforce/schema/Contact.MobilePhone';
import CONTACT_HOMEPHONE from '@salesforce/schema/Contact.HomePhone';
import CONTACT_PERSONALEMAIL from '@salesforce/schema/Contact.Personal_Email__c';
import CONTACT_MAILINGSTREET from '@salesforce/schema/Contact.MailingStreet';
import CONTACT_MAILINGCITY from '@salesforce/schema/Contact.MailingCity';
import CONTACT_MAILINGSTATE from '@salesforce/schema/Contact.MailingState';
import CONTACT_MAILINGPOSTAL from '@salesforce/schema/Contact.MailingPostalCode';
// Candidate contact linkage for fallback
import CANDIDATE_CONTACT from '@salesforce/schema/Candidate__c.Contact__c';

const FIELDS = [
    FIRST_NAME, LAST_NAME, STAGE, POSITION, SALES_MANAGER, OFFICE, MOBILE,
    PERSONAL_EMAIL, START_DATE, CONTRACT_EFFECTIVE, CONTRACT_TYPE, CONTRACT_EXPIRATION, MMID,
    DOB, HOME_ADDRESS, LIFE_INSURANCE_LICENSED, REGISTERED, NOTES, NEXT_MEETING,
    CANDIDATE, CONTACT
];

export default class AlcCareerRecordView extends NavigationMixin(LightningElement) {
        @track alcData;
        @track contactData;
    @track contactRecord;
    @track contactId;
    @track contactSnapshot;
    @track candidateRecord;
    @track candidateContactId;

    @wire(getRecord, { recordId: '$contactId', fields: [
        CONTACT_FIRSTNAME,
        CONTACT_LASTNAME,
        CONTACT_EMAIL,
        CONTACT_MOBILE,
        CONTACT_HOMEPHONE,
        CONTACT_PERSONALEMAIL,
        CONTACT_MAILINGSTREET,
        CONTACT_MAILINGCITY,
        CONTACT_MAILINGSTATE,
        CONTACT_MAILINGPOSTAL
    ] })
    wiredContactRecord(result) {
        this.contactRecord = result;
        // Debug: log wire result
        // eslint-disable-next-line no-console
        console.log('Contact wire result:', result);
    }

    // Wire candidate record to resolve Contact when ALC lacks direct Contact__c
    @wire(getRecord, { recordId: '$candidateId', fields: [CANDIDATE_CONTACT] })
    wiredCandidateRecord(result) {
        this.candidateRecord = result;
        if (result && result.data) {
            const cid = getFieldValue(result.data, CANDIDATE_CONTACT);
            this.candidateContactId = cid;
            // If no direct contactId is set, use candidate contact id to drive Contact wires
            if (cid && !this.contactId) {
                this.contactId = cid;
                // eslint-disable-next-line no-console
                console.log('Using candidate Contact for wires:', cid);
            }
        } else {
            this.candidateContactId = undefined;
        }
    }

    @wire(getContactSnapshot, { contactId: '$effectiveContactId' })
    wiredContactSnapshot({ data, error }) {
        if (data) {
            this.contactSnapshot = data;
        } else {
            this.contactSnapshot = null;
            if (error) {
                // eslint-disable-next-line no-console
                console.warn('Contact snapshot error:', error);
            }
        }
    }

    get contactDataId() {
        return this.contactData ? this.contactData.Id : '';
    }

        wiredALCResult;
        @wire(getALCData, { alcId: '$recordId' })
        wiredALC(result) {
            this.wiredALCResult = result;
            const { error, data } = result;
            if (data) {
                this.alcData = data;
                this.contactData = data.Contact__r || null;
                // Ensure contactId is set for UI API wire
                if (data.Contact__c) {
                    this.contactId = data.Contact__c;
                }
            } else if (error) {
                this.alcData = null;
                this.contactData = null;
            }
        }

        // Populate hero header and card fields
        get fullName() {
            const fn = getFieldValue(this.alcRecord?.data, FIRST_NAME) || '';
            const ln = getFieldValue(this.alcRecord?.data, LAST_NAME) || '';
            const name = `${fn} ${ln}`.trim();
            return name || '';
        }
        get position() {
            return getFieldValue(this.alcRecord?.data, POSITION);
        }
        get salesManager() {
            return getFieldValue(this.alcRecord?.data, SALES_MANAGER);
        }

        get contactName() {
            // Prefer UI API wire, fallback to Contact__r
            // First preference: Apex snapshot (deterministic)
            if (this.contactSnapshot) {
                const fn = this.contactSnapshot.firstName || '';
                const ln = this.contactSnapshot.lastName || '';
                if (fn || ln) return `${fn} ${ln}`.trim();
            }
            if (this.contactRecord?.data) {
                const fn = getFieldValue(this.contactRecord.data, CONTACT_FIRSTNAME) || '';
                const ln = getFieldValue(this.contactRecord.data, CONTACT_LASTNAME) || '';
                if (fn || ln) return `${fn} ${ln}`.trim();
            }
            if (this.contactData && (this.contactData.FirstName || this.contactData.LastName)) {
                return `${this.contactData.FirstName || ''} ${this.contactData.LastName || ''}`.trim();
            }
            if (this.alcData?.Contact__r && (this.alcData.Contact__r.FirstName || this.alcData.Contact__r.LastName)) {
                const fn = this.alcData.Contact__r.FirstName || '';
                const ln = this.alcData.Contact__r.LastName || '';
                return `${fn} ${ln}`.trim();
            }
            return '';
        }
        get contactEmail() {
            if (this.contactSnapshot && this.contactSnapshot.email) {
                return this.contactSnapshot.email;
            }
            if (this.contactRecord?.data) {
                const email = getFieldValue(this.contactRecord.data, CONTACT_EMAIL);
                if (email) return email;
            }
            if (this.contactData && this.contactData.Email) return this.contactData.Email;
            if (this.alcData?.Contact__r && this.alcData.Contact__r.Email) return this.alcData.Contact__r.Email;
            return '';
        }
        get contactPhone() {
            if (this.contactSnapshot) {
                const mobile = this.contactSnapshot.mobilePhone;
                const home = this.contactSnapshot.homePhone;
                if (mobile) return mobile;
                if (home) return home;
            }
            if (this.contactRecord?.data) {
                const mobile = getFieldValue(this.contactRecord.data, CONTACT_MOBILE);
                const home = getFieldValue(this.contactRecord.data, CONTACT_HOMEPHONE);
                if (mobile) return mobile;
                if (home) return home;
            }
            if (this.contactData) {
                if (this.contactData.MobilePhone) return this.contactData.MobilePhone;
                if (this.contactData.HomePhone) return this.contactData.HomePhone;
            }
            if (this.alcData?.Contact__r) {
                const c = this.alcData.Contact__r;
                if (c.MobilePhone) return c.MobilePhone;
                if (c.HomePhone) return c.HomePhone;
            }
            return '';
        }
        get contactAddress() {
            if (this.contactSnapshot) {
                const c = this.contactSnapshot;
                const v = [c.mailingStreet, c.mailingCity, c.mailingState, c.mailingPostalCode]
                    .filter(Boolean)
                    .join(', ');
                if (v) return v;
            }
            if (this.contactRecord?.data) {
                const street = getFieldValue(this.contactRecord.data, CONTACT_MAILINGSTREET);
                const city = getFieldValue(this.contactRecord.data, CONTACT_MAILINGCITY);
                const state = getFieldValue(this.contactRecord.data, CONTACT_MAILINGSTATE);
                const postal = getFieldValue(this.contactRecord.data, CONTACT_MAILINGPOSTAL);
                const v = [street, city, state, postal].filter(Boolean).join(', ');
                if (v) return v;
            }
            if (this.contactData) {
                const c = this.contactData;
                const v = [c.MailingStreet, c.MailingCity, c.MailingState, c.MailingPostalCode].filter(Boolean).join(', ');
                if (v) return v;
            }
            if (this.alcData?.Contact__r) {
                const c = this.alcData.Contact__r;
                const v = [c.MailingStreet, c.MailingCity, c.MailingState, c.MailingPostalCode].filter(Boolean).join(', ');
                if (v) return v;
            }
            return '';
        }
        get contactEmailLink() {
            return this.contactEmail ? `mailto:${this.contactEmail}` : null;
        }
        get contactPhoneLink() {
            return this.contactPhone ? `tel:${this.contactPhone}` : null;
        }
        get contactIdFromRecord() {
            // Always update contactId for wire
            const id = this.alcRecord?.data ? getFieldValue(this.alcRecord.data, CONTACT) : undefined;
            if (id && this.contactId !== id) {
                // Debug: log when contactId is set
                // eslint-disable-next-line no-console
                console.log('Setting contactId for wire:', id);
                this.contactId = id;
            }
            return id;
        }

        get relatedCandidateIdFromData() {
            return this.alcData ? this.alcData.Related_Candidate__c : undefined;
        }

        get effectiveCandidateId() {
            return this.candidateId || this.relatedCandidateIdFromData || '';
        }

        get effectiveContactId() {
            // Consider all sources to avoid false negatives in template gating
            return this.contactDataId || this.contactId || this.contactIdFromRecord || this.candidateContactId || '';
        }
    @api recordId;
    @track isEditMode = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    alcRecord;

    // Inline edit toggle UI, matching candidateRecordView
    get editModeLabel() {
        return this.isEditMode ? 'View' : 'Edit Inline';
    }
    get editModeVariant() {
        return this.isEditMode ? 'neutral' : 'brand-outline';
    }
    get editModeIcon() {
        return this.isEditMode ? 'utility:preview' : 'utility:edit';
    }
    get stage() {
        return getFieldValue(this.alcRecord.data, STAGE);
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

    get contractExpiration() {
        return getFieldValue(this.alcRecord.data, CONTRACT_EXPIRATION);
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
        // Accept true, 'true', 'Yes', 'yes', 'Y', 1
        const val = this.lifeInsuranceLicensed;
        return val === true || val === 'true' || val === 'Yes' || val === 'yes' || val === 'Y' || val === 1;
    }

    get isRegistered() {
        // Accept true, 'true', 'Yes', 'yes', 'Y', 1
        const val = this.registered;
        return val === true || val === 'true' || val === 'Yes' || val === 'yes' || val === 'Y' || val === 1;
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

    get licenseBadgeClass() {
        return `license-badge ${this.hasLicense ? 'badge-green' : 'badge-red'}`;
    }

    get registeredBadgeClass() {
        return `license-badge ${this.isRegistered ? 'badge-green' : 'badge-red'}`;
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

    navigateToContact() {
        const contactId = this.effectiveContactId;
        if (contactId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: contactId,
                    actionName: 'view'
                }
            });
        }
    }

    handleToggleEditMode() {
        this.isEditMode = !this.isEditMode;
        // Refresh backing data so inline edit shows latest
        if (this.wiredALCResult) {
            refreshApex(this.wiredALCResult);
        }
    }

    handleEdit() {
        // Deprecated: standard edit. Use inline toggle instead.
        this.isEditMode = true;
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

        // handleStartContracting removed: now handled by candidateRecordView only

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

    // Inline edit child event handlers
    handleEditSuccess() {
        // Safely exit edit mode and refresh data
        this.isEditMode = false;
        if (this.wiredALCResult) {
            refreshApex(this.wiredALCResult);
        }
    }

    handleEditError(event) {
        // Keep UX responsive even if child surfaces errors
        // Optionally log for diagnostics
        // eslint-disable-next-line no-console
        console.error('alcCareerRecordView received editerror:', event?.detail);
    }
}