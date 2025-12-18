import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getCaseWithRelatedData from '@salesforce/apex/CaseRecordModalController.getCaseWithRelatedData';
import updateCaseFields from '@salesforce/apex/CaseRecordModalController.updateCaseFields';
import assignCaseToCurrentUser from '@salesforce/apex/UnassignedCasesController.assignCaseToCurrentUser';
import reassignCase from '@salesforce/apex/CaseReassignController.reassignCase';

export default class CaseRecordModal extends LightningElement {
    @api caseId;
    @api darkMode = false;
    @api isUnassigned = false;
    @api isMockData = false;
    @track isLoading = true;
    @track isEditing = false;
    @track isSaving = false;
    @track error = null;
    @track editableFields = {};
    @track showCloseModal = false;

    wiredCaseResult;

    @wire(getCaseWithRelatedData, { caseId: '$caseId' })
    wiredCase(result) {
        this.wiredCaseResult = result;
        
        // If this is mock data, don't try to load from server
        if (this.isMockData) {
            this.loadMockCaseData();
            return;
        }
        
        if (result.data) {
            this.isLoading = false;
            this.error = null;
            this.initializeEditableFields(result.data);
        } else if (result.error) {
            this.error = result.error;
            this.isLoading = false;
        }
    }

    loadMockCaseData() {
        // Create mock case data based on caseId
        const mockData = this.getMockCaseData();
        this.isLoading = false;
        this.error = null;
        this.initializeEditableFields(mockData);
    }

    getMockCaseData() {
        const mockCases = {
            '5003000000D8cuI': {
                Id: '5003000000D8cuI',
                CaseNumber: '00012345',
                Subject: 'Network Connectivity Issue',
                Description: 'Customer experiencing intermittent network connectivity problems that require investigation and resolution.',
                Status: 'Working',
                Priority: 'High',
                Origin: 'Web',
                CreatedDate: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
                Owner: { Name: 'Pat Baker' },
                Contact: { Name: 'Kimberly Wilson' },
                Account: { Name: 'TechCorp Inc.' }
            },
            '5003000000D8cuJ': {
                Id: '5003000000D8cuJ',
                CaseNumber: '00012340',
                Subject: 'Password Reset Request',
                Description: 'User unable to access system after password expiration. Requires immediate password reset assistance.',
                Status: 'New',
                Priority: 'Medium',
                Origin: 'Email',
                CreatedDate: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(), // 1 day ago
                Owner: { Name: 'Donna Wilson' },
                Contact: { Name: 'John Smith' },
                Account: { Name: 'DataFlow Solutions' }
            }
        };
        
        return mockCases[this.caseId] || {
            Id: this.caseId,
            CaseNumber: '00099999',
            Subject: 'Demo Case',
            Description: 'This is a demonstration case with mock data for testing purposes.',
            Status: 'New',
            Priority: 'Medium',
            Origin: 'Web',
            CreatedDate: new Date().toISOString(),
            Owner: { Name: 'Demo User' },
            Contact: { Name: 'Demo Contact' },
            Account: { Name: 'Demo Account' }
        };
    }

    initializeEditableFields(caseData) {
        this.editableFields = {
            Subject: caseData.Subject || '',
            Description: caseData.Description || '',
            Status: caseData.Status || '',
            Priority: caseData.Priority || ''
        };
    }

    get caseRecord() {
        if (this.isMockData) {
            return this.getMockCaseData();
        }
        return this.wiredCaseResult?.data;
    }

    get modalClass() {
        return this.darkMode ? 'slds-modal slds-fade-in-open case-modal dark-mode' : 'slds-modal slds-fade-in-open case-modal';
    }

    get caseNumber() {
        return this.caseRecord?.CaseNumber;
    }

    get subject() {
        return this.caseRecord?.Subject || 'No Subject';
    }

    get description() {
        return this.caseRecord?.Description || 'No description provided';
    }

    get status() {
        return this.caseRecord?.Status;
    }

    get priority() {
        return this.caseRecord?.Priority;
    }

    get origin() {
        return this.caseRecord?.Origin;
    }

    get accountName() {
        return this.caseRecord?.Account?.Name || 'No Account';
    }

    get contactName() {
        return this.caseRecord?.Contact?.Name || 'No Contact';
    }

    get ownerName() {
        return this.caseRecord?.Owner?.Name || 'Unassigned';
    }

    get createdDate() {
        const date = this.caseRecord?.CreatedDate;
        return date ? new Date(date).toLocaleString() : '';
    }

    get lastModifiedDate() {
        const date = this.caseRecord?.LastModifiedDate;
        return date ? new Date(date).toLocaleString() : '';
    }

    get priorityClass() {
        const priority = this.priority;
        switch (priority) {
            case 'High':
                return 'slds-badge slds-theme_error';
            case 'Medium':
                return 'slds-badge slds-theme_warning';
            case 'Low':
                return 'slds-badge slds-theme_success';
            default:
                return 'slds-badge';
        }
    }

    get statusClass() {
        const status = this.status;
        switch (status) {
            case 'New':
                return 'slds-badge slds-theme_info';
            case 'Working':
                return 'slds-badge slds-theme_warning';
            case 'Escalated':
                return 'slds-badge slds-theme_error';
            case 'Closed':
                return 'slds-badge slds-theme_success';
            default:
                return 'slds-badge';
        }
    }

    get statusOptions() {
        return [
            { label: 'New', value: 'New' },
            { label: 'Working', value: 'Working' },
            { label: 'Escalated', value: 'Escalated' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    get priorityOptions() {
        return [
            { label: 'High', value: 'High' },
            { label: 'Medium', value: 'Medium' },
            { label: 'Low', value: 'Low' }
        ];
    }

    handleClose(event) {
        console.log('Case modal close event dispatched');
        
        // Prevent event bubbling if it exists
        if (event && event.stopPropagation) {
            event.stopPropagation();
        }
        if (event && event.preventDefault) {
            event.preventDefault();
        }
        
        // Close the modal by dispatching custom event
        const closeEvent = new CustomEvent('close', { 
            bubbles: true,
            composed: true 
        });
        this.dispatchEvent(closeEvent);
    }

    handleBackdropClick() {
        // Close modal when clicking on backdrop
        this.handleClose();
    }

    handleEdit() {
        this.isEditing = true;
    }

    handleCancelEdit() {
        this.isEditing = false;
        if (this.caseRecord) {
            this.initializeEditableFields(this.caseRecord);
        }
    }

    handleFieldChange(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.value;
        this.editableFields = {
            ...this.editableFields,
            [fieldName]: value
        };
    }

    async handleAcceptCase() {
        if (!this.isUnassigned) return;
        
        // Handle mock data gracefully
        if (this.isMockData) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Mock Data Demo',
                message: 'In production, this case would be assigned to you. This is demo data.',
                variant: 'info'
            }));
            return;
        }
        
        this.isSaving = true;
        try {
            await assignCaseToCurrentUser({ caseId: this.caseId });
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `Case ${this.caseNumber} has been assigned to you`,
                variant: 'success'
            }));

            // Refresh the case data
            await refreshApex(this.wiredCaseResult);
            
            // Notify parent component that case was accepted
            const acceptedEvent = new CustomEvent('caseaccepted', {
                detail: { caseId: this.caseId },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(acceptedEvent);
            
        } catch (error) {
            console.error('Error accepting case:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to assign case: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        } finally {
            this.isSaving = false;
        }
    }

    async handleReassignCase() {
        if (this.isUnassigned) return; // Don't reassign unassigned cases
        
        console.log('Attempting to reassign case. Case ID:', this.caseId);
        console.log('Case ID type:', typeof this.caseId);
        console.log('Case ID length:', this.caseId ? this.caseId.length : 0);
        
        this.isSaving = true;
        try {
            // Handle mock data gracefully - let the backend operation proceed and handle gracefully
            const result = await reassignCase({ caseId: this.caseId });
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: result,
                variant: 'success'
            }));

            // Refresh the case data
            await refreshApex(this.wiredCaseResult);
            
            // Notify parent component that case was reassigned
            const reassignedEvent = new CustomEvent('casereassigned', {
                detail: { caseId: this.caseId },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(reassignedEvent);
            
            // Close the modal after reassignment
            this.handleClose();
            
        } catch (error) {
            console.error('Error reassigning case:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to reassign case: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        } finally {
            this.isSaving = false;
        }
    }

    handleShowCloseModal() {
        this.showCloseModal = true;
    }

    handleCloseCaseModalCancel() {
        this.showCloseModal = false;
    }

    async handleCaseClosed(event) {
        this.showCloseModal = false;
        
        // Refresh the case data
        await refreshApex(this.wiredCaseResult);
        
        // Close the main case modal
        this.handleClose();
        
        // Notify parent that case was closed
        const closedEvent = new CustomEvent('caseclosed', {
            detail: event.detail,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(closedEvent);
    }

    async handleSave() {
        // Handle mock data gracefully
        if (this.isMockData) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Mock Data Demo',
                message: 'In production, case changes would be saved. This is demo data.',
                variant: 'success'
            }));
            this.isEditing = false;
            return;
        }
        
        this.isSaving = true;
        try {
            const updatedCase = await updateCaseFields({
                caseId: this.caseId,
                subject: this.editableFields.Subject,
                description: this.editableFields.Description,
                status: this.editableFields.Status,
                priority: this.editableFields.Priority
            });
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Case updated successfully',
                variant: 'success'
            }));

            this.isEditing = false;
            
            // Refresh the case data
            refreshApex(this.wiredCaseResult);
            
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to update case: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        } finally {
            this.isSaving = false;
        }
    }
}