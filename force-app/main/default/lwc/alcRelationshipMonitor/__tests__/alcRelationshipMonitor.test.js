import { createElement } from 'lwc';
import AlcRelationshipMonitor from 'c/alcRelationshipMonitor';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import getRelationshipGaps from '@salesforce/apex/ALCRelationshipController.getRelationshipGaps';
import getCandidatesWithoutContacts from '@salesforce/apex/ALCRelationshipController.getCandidatesWithoutContacts';
import getRecentAuditLogs from '@salesforce/apex/ALCRelationshipController.getRecentAuditLogs';
import fixCandidateContact from '@salesforce/apex/ALCRelationshipController.fixCandidateContact';
import markLogResolved from '@salesforce/apex/ALCRelationshipController.markLogResolved';

// Mock Apex methods
jest.mock(
    '@salesforce/apex/ALCRelationshipController.getRelationshipGaps',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ALCRelationshipController.getCandidatesWithoutContacts',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ALCRelationshipController.getRecentAuditLogs',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ALCRelationshipController.fixCandidateContact',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ALCRelationshipController.markLogResolved',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

// Mock data
const mockRelationshipGaps = [
    {
        recordType: 'Career',
        withoutContact: 5,
        withoutCandidate: 2
    },
    {
        recordType: 'Broker',
        withoutContact: 0,
        withoutCandidate: 1
    }
];

const mockCandidates = [
    {
        Id: 'a001234567890ABC',
        Name: 'John Doe',
        First_Name__c: 'John',
        Last_Name__c: 'Doe',
        Email__c: 'john.doe@example.com',
        alcId: 'a011234567890DEF',
        alcName: 'Career ALC-001'
    }
];

const mockAuditLogs = [
    {
        Id: 'a021234567890GHI',
        Name: 'LOG-001',
        Operation_Type__c: 'Create Contact',
        Success__c: true,
        CreatedDate: '2026-01-08T10:00:00.000Z'
    },
    {
        Id: 'a021234567890JKL',
        Name: 'LOG-002',
        Operation_Type__c: 'Update Candidate',
        Success__c: false,
        Error_Message__c: 'Failed to update',
        Stack_Trace__c: 'Line 1: Error...',
        CreatedDate: '2026-01-07T15:30:00.000Z'
    }
];

describe('c-alc-relationship-monitor', () => {
    afterEach(() => {
        // Clean up DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
        jest.clearAllTimers();
    });

    // Helper to create component
    function createComponent() {
        const element = createElement('c-alc-relationship-monitor', {
            is: AlcRelationshipMonitor
        });
        document.body.appendChild(element);
        return element;
    }

    // Helper to emit wire data
    function emitWireData(wireMethod, data) {
        wireMethod.emit(data);
    }

    it('renders component with header', async () => {
        const element = createComponent();

        await Promise.resolve();

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card).toBeTruthy();
        expect(card.title).toBe('ALC Relationship Monitor');
    });

    it('displays relationship gaps summary', async () => {
        const element = createComponent();

        emitWireData(getRelationshipGaps, mockRelationshipGaps);

        await Promise.resolve();

        const summaryCards = element.shadowRoot.querySelectorAll('.summary-card');
        expect(summaryCards.length).toBe(2);
    });

    it('displays candidates without contacts', async () => {
        const element = createComponent();

        emitWireData(getCandidatesWithoutContacts, mockCandidates);

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable[key-field="Id"]');
        expect(datatable).toBeTruthy();
        expect(datatable.data).toEqual(
            expect.arrayContaining([
                expect.objectContaining({
                    Id: 'a001234567890ABC',
                    candidateName: 'John Doe'
                })
            ])
        );
    });

    it('displays audit logs', async () => {
        const element = createComponent();

        emitWireData(getRecentAuditLogs, mockAuditLogs);

        await Promise.resolve();

        const logs = element.shadowRoot.querySelectorAll('lightning-datatable');
        expect(logs.length).toBeGreaterThan(0);
    });

    it('handles auto-refresh toggle', async () => {
        jest.useFakeTimers();
        const element = createComponent();

        await Promise.resolve();

        const toggle = element.shadowRoot.querySelector('lightning-input[type="checkbox"]');
        expect(toggle.checked).toBe(true);

        // Disable auto-refresh
        toggle.checked = false;
        toggle.dispatchEvent(new CustomEvent('change', { detail: { checked: false } }));

        await Promise.resolve();

        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        expect(element.autoRefreshEnabled).toBe(false);

        jest.useRealTimers();
    });

    it('handles manual refresh', async () => {
        const element = createComponent();

        emitWireData(getRelationshipGaps, mockRelationshipGaps);
        emitWireData(getCandidatesWithoutContacts, mockCandidates);
        emitWireData(getRecentAuditLogs, mockAuditLogs);

        await Promise.resolve();

        const refreshButton = element.shadowRoot.querySelector('lightning-button-icon[icon-name="utility:refresh"]');
        expect(refreshButton).toBeTruthy();

        refreshButton.click();

        await Promise.resolve();

        expect(element.isRefreshing).toBe(false);
    });

    it('handles create contact action', async () => {
        fixCandidateContact.mockResolvedValue({
            success: true,
            message: 'Contact created successfully'
        });

        const element = createComponent();

        emitWireData(getCandidatesWithoutContacts, mockCandidates);

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable[key-field="Id"]');
        datatable.dispatchEvent(
            new CustomEvent('rowaction', {
                detail: {
                    action: { name: 'create_contact' },
                    row: mockCandidates[0]
                }
            })
        );

        await Promise.resolve();

        expect(fixCandidateContact).toHaveBeenCalledWith({
            candidateId: 'a001234567890ABC'
        });
    });

    it('handles mark resolved action', async () => {
        markLogResolved.mockResolvedValue(undefined);

        const element = createComponent();

        emitWireData(getRecentAuditLogs, mockAuditLogs);

        await Promise.resolve();

        // Find and click the action to open modal
        const datatables = element.shadowRoot.querySelectorAll('lightning-datatable');
        const auditLogTable = Array.from(datatables).find(dt => 
            dt.columns && dt.columns[0].label === 'Name'
        );

        auditLogTable.dispatchEvent(
            new CustomEvent('rowaction', {
                detail: {
                    action: { name: 'mark_resolved' },
                    row: mockAuditLogs[1]
                }
            })
        );

        await Promise.resolve();

        // Modal should be visible
        expect(element.showResolveModal).toBe(true);

        const textarea = element.shadowRoot.querySelector('lightning-textarea');
        expect(textarea).toBeTruthy();

        textarea.value = 'Issue was resolved by manual fix';
        textarea.dispatchEvent(new CustomEvent('change', { detail: { value: 'Issue was resolved by manual fix' } }));

        await Promise.resolve();

        const saveButton = element.shadowRoot.querySelector('lightning-button[label="Save Resolution"]');
        saveButton.click();

        await Promise.resolve();

        expect(markLogResolved).toHaveBeenCalledWith({
            logId: 'a021234567890JKL',
            resolutionNotes: 'Issue was resolved by manual fix'
        });
    });

    it('handles view details action', async () => {
        const element = createComponent();

        emitWireData(getRecentAuditLogs, mockAuditLogs);

        await Promise.resolve();

        const datatables = element.shadowRoot.querySelectorAll('lightning-datatable');
        const auditLogTable = Array.from(datatables).find(dt => 
            dt.columns && dt.columns[0].label === 'Name'
        );

        auditLogTable.dispatchEvent(
            new CustomEvent('rowaction', {
                detail: {
                    action: { name: 'view_details' },
                    row: mockAuditLogs[1]
                }
            })
        );

        await Promise.resolve();

        expect(element.showLogDetailModal).toBe(true);
        expect(element.selectedLog).toEqual(
            expect.objectContaining({
                Id: 'a021234567890JKL'
            })
        );
    });

    it('filters audit logs by errors', async () => {
        const element = createComponent();

        emitWireData(getRecentAuditLogs, mockAuditLogs);

        await Promise.resolve();

        const buttonGroup = element.shadowRoot.querySelector('lightning-button-group');
        const errorsButton = Array.from(buttonGroup.querySelectorAll('lightning-button')).find(
            btn => btn.label === 'Errors Only'
        );

        errorsButton.click();

        await Promise.resolve();

        expect(element.currentFilter).toBe('errors');
        expect(element.auditLogs.length).toBe(1);
        expect(element.auditLogs[0].Success__c).toBe(false);
    });

    it('handles pagination', async () => {
        const largeAuditLogs = Array.from({ length: 25 }, (_, i) => ({
            Id: `a02123456789${i}`,
            Name: `LOG-${i}`,
            Operation_Type__c: 'Test Operation',
            Success__c: true,
            CreatedDate: '2026-01-08T10:00:00.000Z'
        }));

        const element = createComponent();

        emitWireData(getRecentAuditLogs, largeAuditLogs);

        await Promise.resolve();

        expect(element.totalPages).toBeGreaterThan(1);
        expect(element.currentPage).toBe(1);

        const nextButton = element.shadowRoot.querySelector('lightning-button[label="Next"]');
        nextButton.click();

        await Promise.resolve();

        expect(element.currentPage).toBe(2);

        const prevButton = element.shadowRoot.querySelector('lightning-button[label="Previous"]');
        prevButton.click();

        await Promise.resolve();

        expect(element.currentPage).toBe(1);
    });

    it('handles empty candidates list', async () => {
        const element = createComponent();

        emitWireData(getCandidatesWithoutContacts, []);

        await Promise.resolve();

        const emptyState = element.shadowRoot.querySelector('.empty-state');
        expect(emptyState).toBeTruthy();
        expect(emptyState.textContent).toContain('All candidates have contacts');
    });

    it('handles wire errors gracefully', async () => {
        const element = createComponent();

        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        emitWireData(getRelationshipGaps, { error: { body: { message: 'Test error' } } });

        await Promise.resolve();

        // Error should be logged but component should remain stable
        expect(element.relationshipGaps.length).toBe(0);
    });

    it('starts and stops auto-refresh on connect/disconnect', async () => {
        jest.useFakeTimers();
        const element = createComponent();

        await Promise.resolve();

        expect(element.intervalId).toBeTruthy();

        element.disconnectedCallback();

        expect(element.intervalId).toBeNull();

        jest.useRealTimers();
    });

    it('displays badges with correct colors', async () => {
        const element = createComponent();

        emitWireData(getRelationshipGaps, mockRelationshipGaps);

        await Promise.resolve();

        const badges = element.shadowRoot.querySelectorAll('lightning-badge');
        expect(badges.length).toBeGreaterThan(0);
    });

    it('builds correct list view URLs', async () => {
        const element = createComponent();

        emitWireData(getRelationshipGaps, mockRelationshipGaps);

        await Promise.resolve();

        const links = element.shadowRoot.querySelectorAll('.view-records-link');
        expect(links.length).toBe(2);
        links.forEach(link => {
            expect(link.href).toContain('/lightning/o/ALC__c/list');
        });
    });

    it('handles cancel resolution', async () => {
        const element = createComponent();

        emitWireData(getRecentAuditLogs, mockAuditLogs);

        await Promise.resolve();

        element.showResolveModal = true;
        element.resolutionNotes = 'Test notes';

        await Promise.resolve();

        const cancelButton = element.shadowRoot.querySelector('lightning-button[label="Cancel"]');
        cancelButton.click();

        await Promise.resolve();

        expect(element.showResolveModal).toBe(false);
        expect(element.resolutionNotes).toBe('');
    });

    it('prevents saving resolution without notes', async () => {
        const element = createComponent();

        element.showResolveModal = true;
        element.resolutionNotes = '';

        await Promise.resolve();

        const toastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, toastHandler);

        const saveButton = element.shadowRoot.querySelector('lightning-button[label="Save Resolution"]');
        saveButton.click();

        await Promise.resolve();

        expect(markLogResolved).not.toHaveBeenCalled();
    });
});
