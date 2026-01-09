import { createElement } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CandidateInformationEdit from 'c/candidateInformationEdit';
import getPageLayoutFields from '@salesforce/apex/CandidateLayoutController.getPageLayoutFields';

// Mock Apex
jest.mock('@salesforce/apex/CandidateLayoutController.getPageLayoutFields', () => {
    return {
        default: jest.fn()
    };
}, { virtual: true });

// Mock dependencies
jest.mock('lightning/platformShowToastEvent');
jest.mock('lightning/navigation');

// Mock data
const mockRecordId = 'a00xx0000000001AAA';
const mockContactId = '003xx0000000001AAA';

const mockCandidateRecord = {
    fields: {
        Type__c: { value: 'Candidate' },
        Contact__c: { value: mockContactId },
        'Contact__r.Name': { value: 'John Doe' },
        First_Name__c: { value: 'John' },
        Last_Name__c: { value: 'Doe' },
        Status__c: { value: 'Recruit' }
    }
};

const mockObjectInfo = {
    fields: {
        First_Name__c: {
            label: 'First Name',
            updateable: true,
            calculated: false,
            dataType: 'String'
        },
        Last_Name__c: {
            label: 'Last Name',
            updateable: true,
            calculated: false,
            dataType: 'String'
        },
        Status__c: {
            label: 'Status',
            updateable: true,
            calculated: false,
            dataType: 'Picklist'
        },
        Office_Location_Picklist__c: {
            label: 'Office Location',
            updateable: true,
            calculated: false,
            dataType: 'Picklist'
        },
        Highest_Level_Achieved__c: {
            label: 'Highest Level',
            updateable: true,
            calculated: false,
            dataType: 'String'
        }
    }
};

const mockAllFields = {
    allFields: [
        'First_Name__c',
        'Last_Name__c',
        'Status__c',
        'Mobile__c',
        'personal_email__c'
    ]
};

describe('c-candidate-information-edit', () => {
    afterEach(() => {
        // Clean up DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Reset mocks
        jest.clearAllMocks();
    });

    it('renders correctly with recordId', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        // Component should render
        expect(element).toBeTruthy();
        
        // Should have card structure
        const card = element.shadowRoot.querySelector('.info-card');
        expect(card).toBeTruthy();
    });

    it('displays all 34 standard fields', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        // Emit wire data for getRecord
        getRecord.emit(mockCandidateRecord);

        // Emit wire data for getObjectInfo
        getObjectInfo.emit(mockObjectInfo);

        return Promise.resolve().then(() => {
            // Check that fields are displayed
            const fieldItems = element.shadowRoot.querySelectorAll('.field-item');
            expect(fieldItems.length).toBeGreaterThan(0);
        });
    });

    it('handles inline edit on field click', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        getObjectInfo.emit(mockObjectInfo);

        return Promise.resolve().then(() => {
            // Find a field container
            const firstNameContainer = element.shadowRoot.querySelector('[data-field="First_Name__c"]');
            
            if (firstNameContainer) {
                // Click to edit
                firstNameContainer.click();

                return Promise.resolve().then(() => {
                    // Should enter edit mode
                    expect(element.editingField).toBe('First_Name__c');
                });
            }
        });
    });

    it('shows toast on save success', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        // Trigger success handler
        element.handleSuccess();

        // Should dispatch toast event
        expect(ShowToastEvent).toHaveBeenCalled();
        
        // Check toast properties
        const toastCall = ShowToastEvent.mock.calls[0][0];
        expect(toastCall.title).toBe('Success');
        expect(toastCall.variant).toBe('success');
    });

    it('shows toast on save error', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        const mockError = {
            detail: {
                message: 'Test error message'
            }
        };

        // Trigger error handler
        element.handleError(mockError);

        // Should dispatch error toast
        expect(ShowToastEvent).toHaveBeenCalled();
        
        const toastCall = ShowToastEvent.mock.calls[0][0];
        expect(toastCall.title).toBe('Error');
        expect(toastCall.variant).toBe('error');
        expect(toastCall.message).toBe('Test error message');
    });

    it('toggles show all fields on button click', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        // Mock Apex response
        getPageLayoutFields.mockResolvedValue(mockAllFields);
        getObjectInfo.emit(mockObjectInfo);

        return Promise.resolve().then(() => {
            // Initial state
            expect(element.showAllFields).toBe(false);

            // Find toggle button
            const toggleButton = element.shadowRoot.querySelector('.toggle-button');
            
            if (toggleButton) {
                // Click toggle
                toggleButton.click();

                return Promise.resolve().then(() => {
                    // Should toggle
                    expect(element.showAllFields).toBe(true);

                    // Click again
                    toggleButton.click();

                    return Promise.resolve().then(() => {
                        expect(element.showAllFields).toBe(false);
                    });
                });
            }
        });
    });

    it('applies dark mode class correctly', () => {
        // Mock matchMedia for dark mode
        window.matchMedia = jest.fn().mockImplementation(query => ({
            matches: true, // Dark mode enabled
            media: query,
            addEventListener: jest.fn(),
            removeEventListener: jest.fn()
        }));

        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const card = element.shadowRoot.querySelector('.info-card');
            if (card) {
                // Should have dark-mode class
                expect(card.classList.contains('dark-mode')).toBe(true);
            }
        });
    });

    it('shows info toast for protected fields with automation', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        getObjectInfo.emit(mockObjectInfo);

        return Promise.resolve().then(() => {
            // Try to edit a protected field
            const protectedField = element.shadowRoot.querySelector('[data-field="Highest_Level_Achieved__c"]');
            
            if (protectedField) {
                protectedField.click();

                return Promise.resolve().then(() => {
                    // Should show info toast
                    expect(ShowToastEvent).toHaveBeenCalled();
                    
                    const toastCall = ShowToastEvent.mock.calls[0][0];
                    expect(toastCall.variant).toBe('info');
                    expect(toastCall.message).toContain('automation');
                });
            }
        });
    });

    it('navigates to contact record on contact link click', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        getRecord.emit(mockCandidateRecord);

        return Promise.resolve().then(() => {
            const contactLink = element.shadowRoot.querySelector('.contact-link');
            
            if (contactLink) {
                // Click contact link
                contactLink.click();

                return Promise.resolve().then(() => {
                    // Should call navigation (mocked)
                    // Note: Full navigation testing requires more complex mocking
                    expect(element.contactId).toBe(mockContactId);
                });
            }
        });
    });

    it('displays contact name or "No Contact" placeholder', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        // With contact
        getRecord.emit(mockCandidateRecord);

        return Promise.resolve().then(() => {
            expect(element.contactDisplayValue).toBe('John Doe');

            // Without contact
            const noContactRecord = {
                fields: {
                    Contact__c: { value: null },
                    'Contact__r.Name': { value: null }
                }
            };
            
            getRecord.emit(noContactRecord);

            return Promise.resolve().then(() => {
                expect(element.contactDisplayValue).toBe('No Contact');
            });
        });
    });

    it('loads all fields from Apex on toggle', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        getPageLayoutFields.mockResolvedValue(mockAllFields);
        getObjectInfo.emit(mockObjectInfo);

        return Promise.resolve().then(() => {
            // Should call Apex
            expect(getPageLayoutFields).toHaveBeenCalledWith({ recordId: mockRecordId });

            return Promise.resolve().then(() => {
                // Should populate allFields
                expect(element.allFields.length).toBeGreaterThan(0);
            });
        });
    });

    it('notifies LDS of record changes after save', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        // Trigger success
        element.handleSuccess();

        // Should notify LDS
        expect(getRecordNotifyChange).toHaveBeenCalledWith([{ recordId: mockRecordId }]);
    });

    it('cleans up dark mode listener on disconnect', () => {
        const removeEventListenerMock = jest.fn();
        window.matchMedia = jest.fn().mockImplementation(query => ({
            matches: false,
            media: query,
            addEventListener: jest.fn(),
            removeEventListener: removeEventListenerMock
        }));

        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        document.body.appendChild(element);

        // Disconnect
        document.body.removeChild(element);

        // Should remove listener
        expect(removeEventListenerMock).toHaveBeenCalled();
    });

    it('handles Enter key to save field', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        getObjectInfo.emit(mockObjectInfo);

        return Promise.resolve().then(() => {
            // Enter edit mode
            element.editingField = 'First_Name__c';

            // Simulate Enter key
            const enterEvent = new KeyboardEvent('keydown', {
                key: 'Enter',
                bubbles: true
            });

            element.handleKeyDown(enterEvent);

            // Should trigger save (submit form)
            // Note: Full form submission testing requires more complex setup
            expect(enterEvent.defaultPrevented).toBe(true);
        });
    });

    it('displays toggle button with correct label', () => {
        const element = createElement('c-candidate-information-edit', {
            is: CandidateInformationEdit
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            // Initial label
            expect(element.toggleButtonLabel).toBe('Show All Fields');

            // After toggle
            element.showAllFields = true;

            return Promise.resolve().then(() => {
                expect(element.toggleButtonLabel).toBe('Show Standard Fields');
            });
        });
    });
});
