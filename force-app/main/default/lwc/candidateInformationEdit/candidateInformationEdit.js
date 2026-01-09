import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getPageLayoutFields from '@salesforce/apex/CandidateLayoutController.getPageLayoutFields';
import CANDIDATE_OBJECT from '@salesforce/schema/Candidate__c';
import TYPE_FIELD from '@salesforce/schema/Candidate__c.Type__c';
import CONTACT_FIELD from '@salesforce/schema/Candidate__c.Contact__c';
import CONTACT_NAME_FIELD from '@salesforce/schema/Candidate__c.Contact__r.Name';
import NAME_FIELD from '@salesforce/schema/Candidate__c.Name';
import OWNER_FIELD from '@salesforce/schema/Candidate__c.OwnerId';
import FIRST_NAME_FIELD from '@salesforce/schema/Candidate__c.First_Name__c';
import MOBILE_FIELD from '@salesforce/schema/Candidate__c.Mobile__c';
import NICKNAME_FIELD from '@salesforce/schema/Candidate__c.Nickname__c';
import PERSONAL_EMAIL_FIELD from '@salesforce/schema/Candidate__c.personal_email__c';
import MIDDLE_NAME_FIELD from '@salesforce/schema/Candidate__c.Middle_Name_or_Initial__c';
import HIGHEST_LEVEL_FIELD from '@salesforce/schema/Candidate__c.Highest_Level_Achieved__c';
import LAST_NAME_FIELD from '@salesforce/schema/Candidate__c.Last_Name__c';
import MDE200_FIELD from '@salesforce/schema/Candidate__c.MDE200__c';
import AGENCY_FIELD from '@salesforce/schema/Candidate__c.Agency__c';
import MS10_FIELD from '@salesforce/schema/Candidate__c.MS_10__c';
import STATUS_FIELD from '@salesforce/schema/Candidate__c.Status__c';
import CAREER_PRESENTATION_FIELD from '@salesforce/schema/Candidate__c.Career_Presentation_ppt__c';
import TARGET_MARKET_FIELD from '@salesforce/schema/Candidate__c.Target_Market__c';
import NEXT_STEP_FIELD from '@salesforce/schema/Candidate__c.Next_Step__c';
import SALES_MANAGER_FIELD from '@salesforce/schema/Candidate__c.Sales_Manager__c';
import NEXT_MEETING_DATE_FIELD from '@salesforce/schema/Candidate__c.Next_Meeting_Date__c';
import RECRUITING_SOURCE_FIELD from '@salesforce/schema/Candidate__c.Recruiting_Source__c';
import STUDYING_LIFE_HEALTH_FIELD from '@salesforce/schema/Candidate__c.Studying_for_Life_Health__c';
import RECRUITING_SUB_SOURCE_FIELD from '@salesforce/schema/Candidate__c.Recruiting_Sub_Source__c';
import REGISTERED_FIELD from '@salesforce/schema/Candidate__c.Registered__c';
import GENDER_FIELD from '@salesforce/schema/Candidate__c.Gender__c';
import INSURANCE_LICENSED_FIELD from '@salesforce/schema/Candidate__c.Insurance_Licensed__c';
import RECRUITER_FIELD from '@salesforce/schema/Candidate__c.RecruiterPicklist__c';
import DATE_OF_BIRTH_FIELD from '@salesforce/schema/Candidate__c.Date_of_Birth__c';
import OFFICE_LOCATION_FIELD from '@salesforce/schema/Candidate__c.Office_Location_Picklist__c';
import RELATIONSHIPS_FIELD from '@salesforce/schema/Candidate__c.RELATIONSHIPS__c';
import WEBSITE_FIELD from '@salesforce/schema/Candidate__c.Website__c';
import SUFFIX_FIELD from '@salesforce/schema/Candidate__c.Suffix__c';
import DEVICE_INSPECTION_FIELD from '@salesforce/schema/Candidate__c.Device_Inspection__c';
import DEVICE_INSPECTION_STATUS_FIELD from '@salesforce/schema/Candidate__c.Device_Inspection_Status__c';

export default class CandidateInformationEdit extends NavigationMixin(LightningElement) {
    @api recordId;
    @track editingField = null;
    @track showAllFields = false;
    @track allFields = [];
    objectInfo;
    darkModeMediaQuery;
    darkModeListener;

    // Wire to get Contact information
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CONTACT_FIELD, CONTACT_NAME_FIELD]
    })
    candidate;

    // Wire to get object metadata for all fields
    @wire(getObjectInfo, { objectApiName: CANDIDATE_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.objectInfo = data;
            this.loadAllFields();
        } else if (error) {
            console.error('Error loading object info:', error);
        }
    }

    objectApiName = CANDIDATE_OBJECT;

    // Field references
    typeField = TYPE_FIELD;
    contactField = CONTACT_FIELD;
    nameField = NAME_FIELD;
    ownerField = OWNER_FIELD;
    firstNameField = FIRST_NAME_FIELD;
    mobileField = MOBILE_FIELD;
    nicknameField = NICKNAME_FIELD;
    personalEmailField = PERSONAL_EMAIL_FIELD;
    middleNameField = MIDDLE_NAME_FIELD;
    highestLevelField = HIGHEST_LEVEL_FIELD;
    lastNameField = LAST_NAME_FIELD;
    mde200Field = MDE200_FIELD;
    agencyField = AGENCY_FIELD;
    ms10Field = MS10_FIELD;
    statusField = STATUS_FIELD;
    careerPresentationField = CAREER_PRESENTATION_FIELD;
    targetMarketField = TARGET_MARKET_FIELD;
    nextStepField = NEXT_STEP_FIELD;
    salesManagerField = SALES_MANAGER_FIELD;
    nextMeetingDateField = NEXT_MEETING_DATE_FIELD;
    recruitingSourceField = RECRUITING_SOURCE_FIELD;
    studyingLifeHealthField = STUDYING_LIFE_HEALTH_FIELD;
    recruitingSubSourceField = RECRUITING_SUB_SOURCE_FIELD;
    registeredField = REGISTERED_FIELD;
    genderField = GENDER_FIELD;
    insuranceLicensedField = INSURANCE_LICENSED_FIELD;
    recruiterField = RECRUITER_FIELD;
    dateOfBirthField = DATE_OF_BIRTH_FIELD;
    officeLocationField = OFFICE_LOCATION_FIELD;
    relationshipsField = RELATIONSHIPS_FIELD;
    websiteField = WEBSITE_FIELD;
    suffixField = SUFFIX_FIELD;
    deviceInspectionField = DEVICE_INSPECTION_FIELD;
    deviceInspectionStatusField = DEVICE_INSPECTION_STATUS_FIELD;

    connectedCallback() {
        // Set up dark mode detection
        this.darkModeMediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
        this.darkModeListener = () => this.updateDarkModeClass();
        this.darkModeMediaQuery.addEventListener('change', this.darkModeListener);
        this.updateDarkModeClass();
    }

    disconnectedCallback() {
        // Clean up dark mode listener
        if (this.darkModeMediaQuery && this.darkModeListener) {
            this.darkModeMediaQuery.removeEventListener('change', this.darkModeListener);
        }
    }

    updateDarkModeClass() {
        const infoCard = this.template.querySelector('.info-card');
        if (infoCard) {
            if (this.darkModeMediaQuery.matches) {
                infoCard.classList.add('dark-mode');
            } else {
                infoCard.classList.remove('dark-mode');
            }
        }
    }

    // Contact getters
    get contactId() {
        return getFieldValue(this.candidate.data, CONTACT_FIELD);
    }

    get contactName() {
        return getFieldValue(this.candidate.data, CONTACT_NAME_FIELD);
    }

    get contactDisplayValue() {
        return this.contactName || 'No Contact';
    }

    get toggleButtonLabel() {
        return this.showAllFields ? 'Show Standard Fields' : 'Show All Fields';
    }

    get toggleButtonVariant() {
        return this.showAllFields ? 'neutral' : 'brand-outline';
    }

    get displayedFields() {
        return this.showAllFields ? this.allFields : [];
    }

    loadAllFields() {
        if (!this.recordId || !this.objectInfo) return;

        getPageLayoutFields({ recordId: this.recordId })
            .then(result => {
                this.allFields = result.allFields || [];
            })
            .catch(error => {
                console.error('Error fetching all fields:', error);
                // Fallback to object metadata
                if (this.objectInfo) {
                    const fields = this.objectInfo.fields;
                    this.allFields = Object.keys(fields)
                        .filter(fieldName => {
                            const field = fields[fieldName];
                            return field.updateable && !field.calculated;
                        })
                        .sort((a, b) => {
                            const labelA = fields[a].label.toUpperCase();
                            const labelB = fields[b].label.toUpperCase();
                            return labelA < labelB ? -1 : labelA > labelB ? 1 : 0;
                        });
                }
            });
    }

    handleToggleAllFields() {
        this.showAllFields = !this.showAllFields;
    }

    isFieldEditable(fieldApiName) {
        // Fields with automation that should not be editable
        const automationProtectedFields = [
            'Highest_Level_Achieved__c',
            'Target_Market__c',
            'Next_Meeting_Date__c'
        ];
        
        if (automationProtectedFields.includes(fieldApiName)) {
            return false;
        }
        
        if (!this.objectInfo || !this.objectInfo.fields) return true;
        const field = this.objectInfo.fields[fieldApiName];
        if (!field) return true;
        return field.updateable && !field.calculated;
    }

    handleFieldClick(event) {
        const fieldName = event.currentTarget.dataset.field;
        
        // Check if field is editable before allowing edit mode
        if (!this.isFieldEditable(fieldName)) {
            this.showToast('Info', 'This field has automation attached and cannot be edited', 'info');
            return;
        }
        
        this.editingField = fieldName;
    }

    handleFieldBlur() {
        this.saveField();
    }

    handleKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            this.saveField();
        }
    }

    saveField() {
        const editForm = this.template.querySelector('lightning-record-edit-form');
        if (editForm) {
            editForm.submit();
        }
    }

    handleSuccess() {
        this.editingField = null;
        this.showToast('Success', 'Record updated successfully', 'success');
        
        // Notify LDS that the record has changed to refresh all components
        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    handleError(event) {
        this.editingField = null;
        const message = event.detail.message || 'An error occurred while saving';
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    // Navigate to Contact record
    navigateToContact() {
        if (this.contactId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.contactId,
                    actionName: 'view'
                }
            });
        }
    }

    // Getters for editing state
    get isEditingType() { return this.editingField === 'Type__c'; }
    get isEditingName() { return this.editingField === 'Name'; }
    get isEditingOwner() { return this.editingField === 'OwnerId'; }
    get isEditingFirstName() { return this.editingField === 'First_Name__c'; }
    get isEditingMobile() { return this.editingField === 'Mobile__c'; }
    get isEditingNickname() { return this.editingField === 'Nickname__c'; }
    get isEditingPersonalEmail() { return this.editingField === 'personal_email__c'; }
    get isEditingMiddleName() { return this.editingField === 'Middle_Name_or_Initial__c'; }
    get isEditingHighestLevel() { return this.editingField === 'Highest_Level_Achieved__c'; }
    get isEditingLastName() { return this.editingField === 'Last_Name__c'; }
    get isEditingMDE200() { return this.editingField === 'MDE200__c'; }
    get isEditingAgency() { return this.editingField === 'Agency__c'; }
    get isEditingMS10() { return this.editingField === 'MS_10__c'; }
    get isEditingStatus() { return this.editingField === 'Status__c'; }
    get isEditingCareerPresentation() { return this.editingField === 'Career_Presentation_ppt__c'; }
    get isEditingTargetMarket() { return this.editingField === 'Target_Market__c'; }
    get isEditingNextStep() { return this.editingField === 'Next_Step__c'; }
    get isEditingSalesManager() { return this.editingField === 'Sales_Manager__c'; }
    get isEditingNextMeetingDate() { return this.editingField === 'Next_Meeting_Date__c'; }
    get isEditingRecruitingSource() { return this.editingField === 'Recruiting_Source__c'; }
    get isEditingStudyingLifeHealth() { return this.editingField === 'Studying_for_Life_Health__c'; }
    get isEditingRecruitingSubSource() { return this.editingField === 'Recruiting_Sub_Source__c'; }
    get isEditingRegistered() { return this.editingField === 'Registered__c'; }
    get isEditingGender() { return this.editingField === 'Gender__c'; }
    get isEditingInsuranceLicensed() { return this.editingField === 'Insurance_Licensed__c'; }
    get isEditingRecruiter() { return this.editingField === 'RecruiterPicklist__c'; }
    get isEditingDateOfBirth() { return this.editingField === 'Date_of_Birth__c'; }
    get isEditingOfficeLocation() { return this.editingField === 'Office_Location_Picklist__c'; }
    get isEditingRelationships() { return this.editingField === 'RELATIONSHIPS__c'; }
    get isEditingWebsite() { return this.editingField === 'Website__c'; }
    get isEditingSuffix() { return this.editingField === 'Suffix__c'; }
    get isEditingDeviceInspection() { return this.editingField === 'Device_Inspection__c'; }
    get isEditingDeviceInspectionStatus() { return this.editingField === 'Device_Inspection_Status__c'; }
    get isEditingContact() { return this.editingField === 'Contact__c'; }
}