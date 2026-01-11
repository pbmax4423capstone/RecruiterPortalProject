import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

// Contact fields for UI
import CONTACT_FIRSTNAME from '@salesforce/schema/Contact.FirstName';
import CONTACT_LASTNAME from '@salesforce/schema/Contact.LastName';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';
import CONTACT_MOBILE from '@salesforce/schema/Contact.MobilePhone';
import CONTACT_PERSONALEMAIL from '@salesforce/schema/Contact.Personal_Email__c';

const CONTACT_FIELDS = [
    CONTACT_FIRSTNAME,
    CONTACT_LASTNAME,
    CONTACT_EMAIL,
    CONTACT_MOBILE,
    CONTACT_PERSONALEMAIL,
    // Omit HomePhone and Mailing* to avoid FLS wire errors
];

export default class ContactRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isEditing = false;

    @wire(getRecord, { recordId: '$recordId', fields: CONTACT_FIELDS })
    contactRecord;


    get fullName() {
        const fn = getFieldValue(this.contactRecord?.data, CONTACT_FIRSTNAME) || '';
        const ln = getFieldValue(this.contactRecord?.data, CONTACT_LASTNAME) || '';
        return `${fn} ${ln}`.trim();
    }

    get contactEmail() {
        return getFieldValue(this.contactRecord?.data, CONTACT_EMAIL) || '';
    }
    get contactPhone() {
        const mobile = getFieldValue(this.contactRecord?.data, CONTACT_MOBILE);
        return mobile || '';
    }
    get contactAddress() {
        // Address omitted from wire for FLS safety; return blank.
        return '';
    }

    get contactEmailLink() {
        return this.contactEmail ? `mailto:${this.contactEmail}` : null;
    }
    get contactPhoneLink() {
        return this.contactPhone ? `tel:${this.contactPhone}` : null;
    }

    // Read-only view; no inline edit handlers needed
    toggleEditMode() {
        this.isEditing = !this.isEditing;
    }

    handleEditSuccess() {
        // Refresh UI API wire to reflect latest values and close editor
        if (this.contactRecord) {
            refreshApex(this.contactRecord);
        }
        this.isEditing = false;
    }

    handleEditError() {
        // Keep editor open; child component shows toast/messages
    }

    navigateToContact() {
        if (this.recordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                }
            });
        }
    }
}
