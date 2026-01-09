import { createElement } from 'lwc';
import AlcRelationshipBackfillWizard from 'c/alcRelationshipBackfillWizard';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import getUnlinkedALCs from '@salesforce/apex/ALCBackfillWizardController.getUnlinkedALCs';
import getMatchingContacts from '@salesforce/apex/ALCBackfillWizardController.getMatchingContacts';
import processBackfillBatch from '@salesforce/apex/ALCBackfillWizardController.processBackfillBatch';

// Mock Apex methods
jest.mock(
    '@salesforce/apex/ALCBackfillWizardController.getUnlinkedALCs',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ALCBackfillWizardController.getMatchingContacts',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ALCBackfillWizardController.processBackfillBatch',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

// Mock data
const MOCK_UNLINKED_ALCS = [
    {
        Id: 'a001',
        Name: 'ALC-001',
        First_Name__c: 'John',
        Last_Name__c: 'Doe',
        Email__c: 'john.doe@example.com',
        Phone__c: '555-1234',
        Contact__c: null,
        Candidate__c: null,
        RecordType: { Name: 'Career' }
    },
    {
        Id: 'a002',
        Name: 'ALC-002',
        First_Name__c: 'Jane',
        Last_Name__c: 'Smith',
        Email__c: 'jane.smith@example.com',
        Phone__c: '555-5678',
        Contact__c: null,
        Candidate__c: null,
        RecordType: { Name: 'Broker' }
    }
];

const MOCK_MATCHING_CONTACTS = [
    {
        Id: 'c001',
        FirstName: 'John',
        LastName: 'Doe',
        Email: 'john.doe@example.com',
        similarity: 0.95
    },
    {
        Id: 'c002',
        FirstName: 'Jonathan',
        LastName: 'Doe',
        Email: 'j.doe@example.com',
        similarity: 0.75
    }
];

const MOCK_PROCESS_RESULT = {
    contactsCreated: 1,
    candidatesCreated: 1,
    alcsUpdated: 2,
    errors: 0,
    details: ['Successfully processed 2 ALCs'],
    errorMessages: []
};

describe('c-alc-relationship-backfill-wizard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    // Helper function to wait for promises
    async function flushPromises() {
        return new Promise((resolve) => setTimeout(resolve, 0));
    }

    it('renders component with title', () => {
        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card).not.toBeNull();
        expect(card.title).toBe('ALC Relationship Backfill Wizard');
    });

    it('displays tabs for record types', () => {
        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        const tabs = element.shadowRoot.querySelectorAll('lightning-tab');
        expect(tabs.length).toBe(5);
        expect(tabs[0].label).toContain('All');
        expect(tabs[1].label).toContain('Career');
        expect(tabs[2].label).toContain('Broker');
        expect(tabs[3].label).toContain('NRF');
        expect(tabs[4].label).toContain('Registration');
    });

    it('loads and displays unlinked ALCs', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        const dataTable = element.shadowRoot.querySelector('lightning-datatable');
        expect(dataTable).not.toBeNull();
        expect(dataTable.data.length).toBe(2);
    });

    it('filters ALCs by tab selection', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        // Select Career tab
        const tabset = element.shadowRoot.querySelector('lightning-tabset');
        tabset.dispatchEvent(new CustomEvent('select', {
            detail: { value: 'Career' }
        }));

        await flushPromises();

        const dataTable = element.shadowRoot.querySelector('lightning-datatable');
        expect(dataTable.data.length).toBe(1);
        expect(dataTable.data[0].RecordTypeName).toBe('Career');
    });

    it('handles row selection', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        const dataTable = element.shadowRoot.querySelector('lightning-datatable');
        dataTable.dispatchEvent(new CustomEvent('rowselection', {
            detail: {
                selectedRows: [MOCK_UNLINKED_ALCS[0]]
            }
        }));

        await flushPromises();

        // Verify Find Matches button is enabled
        const findMatchesBtn = element.shadowRoot.querySelector('lightning-button[label="Find Matches"]');
        expect(findMatchesBtn.disabled).toBe(false);
    });

    it('opens modal and loads matching contacts', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);
        getMatchingContacts.mockResolvedValue(MOCK_MATCHING_CONTACTS);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        // Select a row
        const dataTable = element.shadowRoot.querySelector('lightning-datatable');
        dataTable.dispatchEvent(new CustomEvent('rowselection', {
            detail: {
                selectedRows: [MOCK_UNLINKED_ALCS[0]]
            }
        }));

        await flushPromises();

        // Click Find Matches
        const findMatchesBtn = element.shadowRoot.querySelector('lightning-button[label="Find Matches"]');
        findMatchesBtn.click();

        await flushPromises();

        // Verify modal is open
        const modal = element.shadowRoot.querySelector('.slds-modal');
        expect(modal).not.toBeNull();

        // Verify radio group has options
        const radioGroup = element.shadowRoot.querySelector('lightning-radio-group');
        expect(radioGroup).not.toBeNull();
        expect(radioGroup.options.length).toBe(3); // 2 matches + Create New
    });

    it('closes modal when cancel is clicked', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);
        getMatchingContacts.mockResolvedValue(MOCK_MATCHING_CONTACTS);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        // Select and open modal
        const dataTable = element.shadowRoot.querySelector('lightning-datatable');
        dataTable.dispatchEvent(new CustomEvent('rowselection', {
            detail: { selectedRows: [MOCK_UNLINKED_ALCS[0]] }
        }));

        await flushPromises();

        const findMatchesBtn = element.shadowRoot.querySelector('lightning-button[label="Find Matches"]');
        findMatchesBtn.click();

        await flushPromises();

        // Click Cancel
        const cancelBtn = element.shadowRoot.querySelector('.slds-modal__footer lightning-button[label="Cancel"]');
        cancelBtn.click();

        await flushPromises();

        // Verify modal is closed
        const modal = element.shadowRoot.querySelector('.slds-modal');
        expect(modal).toBeNull();
    });

    it('processes batch successfully', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);
        processBackfillBatch.mockResolvedValue(MOCK_PROCESS_RESULT);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        // Set batch decisions manually (simulating user workflow)
        element.batchDecisions = [
            { alcId: 'a001', contactId: 'c001', createNew: false },
            { alcId: 'a002', contactId: null, createNew: true }
        ];

        // Mock toast event listener
        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        // Click Process Selected
        const processBtn = element.shadowRoot.querySelector('lightning-button[label="Process Selected"]');
        processBtn.click();

        await flushPromises();

        // Verify results are displayed
        const resultsCard = element.shadowRoot.querySelector('.results-card');
        expect(resultsCard).not.toBeNull();

        // Verify toast was shown
        expect(toastHandler).toHaveBeenCalled();
    });

    it('handles error when loading unlinked ALCs', async () => {
        getUnlinkedALCs.mockRejectedValue({ body: { message: 'Test error' } });

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });

        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        document.body.appendChild(element);

        await flushPromises();

        // Verify error toast was shown
        expect(toastHandler).toHaveBeenCalled();
        expect(toastHandler.mock.calls[0][0].detail.variant).toBe('error');
    });

    it('exports results as CSV', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        // Set results manually
        element.showResults = true;
        element.results = MOCK_PROCESS_RESULT;

        await flushPromises();

        // Mock createElement and click
        const mockLink = { 
            setAttribute: jest.fn(), 
            click: jest.fn(),
            style: {}
        };
        jest.spyOn(document, 'createElement').mockReturnValue(mockLink);
        jest.spyOn(document.body, 'appendChild').mockImplementation(() => {});
        jest.spyOn(document.body, 'removeChild').mockImplementation(() => {});

        const exportBtn = element.shadowRoot.querySelector('lightning-button[label="Export Results as CSV"]');
        exportBtn.click();

        await flushPromises();

        // Verify link was created and clicked
        expect(mockLink.click).toHaveBeenCalled();
    });

    it('disables buttons during processing', async () => {
        getUnlinkedALCs.mockResolvedValue(MOCK_UNLINKED_ALCS);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        // Set processing state
        element.processing = true;

        await flushPromises();

        const findMatchesBtn = element.shadowRoot.querySelector('lightning-button[label="Find Matches"]');
        const processBtn = element.shadowRoot.querySelector('lightning-button[label="Process Selected"]');

        expect(findMatchesBtn.disabled).toBe(true);
        expect(processBtn.disabled).toBe(true);
    });

    it('displays no data message when no unlinked ALCs', async () => {
        getUnlinkedALCs.mockResolvedValue([]);

        const element = createElement('c-alc-relationship-backfill-wizard', {
            is: AlcRelationshipBackfillWizard
        });
        document.body.appendChild(element);

        await flushPromises();

        const noDataMsg = element.shadowRoot.querySelector('.slds-text-heading_medium');
        expect(noDataMsg).not.toBeNull();
        expect(noDataMsg.textContent).toBe('All ALCs Have Relationships!');
    });
});
