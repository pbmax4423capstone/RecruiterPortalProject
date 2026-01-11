import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getForCase from '@salesforce/apex/EncryptedDeviceController.getForCase';

export default class EncryptedDevicesForCase extends NavigationMixin(LightningElement) {
    @api recordId; // Case Id
    devices = [];
    error;
    isLoading = true;
    @track selectedRecordId;
    @track showModal = false;
    // Keep fields simple to ensure UI API resolution
    modalFields = ['Name', 'CreatedDate', 'LastModifiedDate'];

    @wire(getForCase, { caseId: '$recordId', limitSize: 50 })
    wiredDevices({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.devices = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.devices = [];
        }
    }

    get hasDevices() {
        return Array.isArray(this.devices) && this.devices.length > 0;
    }

    handleView(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        // Open modal instead of navigating away from portal
        this.selectedRecordId = id;
        this.showModal = true;
    }

    handleModalClose() {
        this.showModal = false;
        this.selectedRecordId = undefined;
    }
}
