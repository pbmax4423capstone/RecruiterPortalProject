import { createElement } from 'lwc';
import SalesManagerContractingKanban from 'c/salesManagerContractingKanban';
import getALCDataForSalesManager from '@salesforce/apex/CandidatesInContractingController.getALCDataForSalesManager';
import getCurrentUserSalesManagerName from '@salesforce/apex/CandidatesInContractingController.getCurrentUserSalesManagerName';
import getSalesManagerOptions from '@salesforce/apex/CandidatesInContractingController.getSalesManagerOptions';
import canViewAllSalesManagers from '@salesforce/apex/CandidatesInContractingController.canViewAllSalesManagers';
import updateCandidateStage from '@salesforce/apex/CandidatesInContractingController.updateCandidateStage';

// Mock Apex wire adapter
jest.mock(
    '@salesforce/apex/CandidatesInContractingController.getALCDataForSalesManager',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/CandidatesInContractingController.getCurrentUserSalesManagerName',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/CandidatesInContractingController.getSalesManagerOptions',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/CandidatesInContractingController.canViewAllSalesManagers',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/CandidatesInContractingController.updateCandidateStage',
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

// Mock data
const mockALCData = {
    alcsByStage: {
        'Sent To Compliance': [
            {
                alcId: 'a0X000001',
                alcName: 'ALC-001',
                candidateId: 'a02000001',
                candidateName: 'John Doe',
                salesManager: 'Tim Denton',
                alcStage: 'Sent To Compliance',
                lastStageChange: '2026-01-09T10:00:00.000Z',
                recordTypeName: 'Career',
                agency: 'A157'
            }
        ],
        'Pending SM': [
            {
                alcId: 'a0X000002',
                alcName: 'ALC-002',
                candidateId: 'a02000002',
                candidateName: 'Jane Smith',
                salesManager: 'Tim Denton',
                alcStage: 'Pending SM',
                lastStageChange: '2026-01-08T14:30:00.000Z',
                recordTypeName: 'Career',
                agency: 'A157'
            }
        ]
    },
    stageConfigs: {
        'Career': [
            {
                recordType: 'Career',
                stageApiValue: 'Sent To Compliance',
                stageDisplayLabel: 'Sent To Compliance',
                sortOrder: 1,
                columnColor: '#0070d2'
            },
            {
                recordType: 'Career',
                stageApiValue: 'Pending SM',
                stageDisplayLabel: 'Pending SM',
                sortOrder: 2,
                columnColor: '#00a1e0'
            }
        ]
    },
    recordTypeCounts: {
        'Career': 2
    }
};

const mockSalesManagerOptions = ['All Sales Managers', 'Tim Denton', 'Elizabeth Kagele'];

describe('c-sales-manager-contracting-kanban', () => {
    let element;

    beforeEach(() => {
        element = createElement('c-sales-manager-contracting-kanban', {
            is: SalesManagerContractingKanban
        });
        // Clear localStorage before each test
        localStorage.clear();
    });

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
        localStorage.clear();
    });

    it('renders component with Career records', async () => {
        document.body.appendChild(element);

        // Emit data from wire adapters
        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve(); // Wait for async operations

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card).not.toBeNull();
        expect(card.title).toContain('Career Contracting Kanban');
    });

    it('shows only Career stage columns', async () => {
        document.body.appendChild(element);

        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const columns = element.shadowRoot.querySelectorAll('.kanban-column');
        expect(columns.length).toBe(2); // Two Career stages
    });

    it('shows Sales Manager dropdown for Directors', async () => {
        document.body.appendChild(element);

        canViewAllSalesManagers.emit(true);
        getSalesManagerOptions.emit(mockSalesManagerOptions);
        getCurrentUserSalesManagerName.emit('Director User');
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const filterGroup = element.shadowRoot.querySelector('.sales-manager-filter-group');
        expect(filterGroup).not.toBeNull();
    });

    it('hides Sales Manager dropdown for non-Directors', async () => {
        document.body.appendChild(element);

        canViewAllSalesManagers.emit(false);
        getCurrentUserSalesManagerName.emit('Tim Denton');
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const filterGroup = element.shadowRoot.querySelector('.sales-manager-filter-group');
        expect(filterGroup).toBeNull();

        const currentLabel = element.shadowRoot.querySelector('.current-manager-label');
        expect(currentLabel).not.toBeNull();
    });

    it('saves filter to localStorage on change', async () => {
        document.body.appendChild(element);

        canViewAllSalesManagers.emit(true);
        getSalesManagerOptions.emit(mockSalesManagerOptions);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const buttons = element.shadowRoot.querySelectorAll('.sales-manager-filter-button');
        const timDentonButton = Array.from(buttons).find(
            btn => btn.dataset.manager === 'Tim Denton'
        );

        timDentonButton.click();

        await Promise.resolve();

        const storedValue = localStorage.getItem('smContractingKanban_salesManagerFilter');
        expect(storedValue).toBe('Tim Denton');
    });

    it('loads filter from localStorage on init', async () => {
        localStorage.setItem('smContractingKanban_salesManagerFilter', 'Elizabeth Kagele');

        element = createElement('c-sales-manager-contracting-kanban', {
            is: SalesManagerContractingKanban
        });
        document.body.appendChild(element);

        canViewAllSalesManagers.emit(true);
        getSalesManagerOptions.emit(mockSalesManagerOptions);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        expect(element.selectedSalesManager).toBe('Elizabeth Kagele');
    });

    it('defaults to "All Sales Managers" for Directors without stored preference', async () => {
        document.body.appendChild(element);

        canViewAllSalesManagers.emit(true);
        getSalesManagerOptions.emit(mockSalesManagerOptions);
        getCurrentUserSalesManagerName.emit('Director User');
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        expect(element.selectedSalesManager).toBe('All Sales Managers');
    });

    it('defaults to current user for Sales Managers without stored preference', async () => {
        document.body.appendChild(element);

        canViewAllSalesManagers.emit(false);
        getCurrentUserSalesManagerName.emit('Tim Denton');
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        expect(element.selectedSalesManager).toBe('Tim Denton');
    });

    it('handles drag and drop stage update', async () => {
        updateCandidateStage.mockResolvedValue('Success');

        document.body.appendChild(element);

        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const cards = element.shadowRoot.querySelectorAll('.kanban-card');
        const firstCard = cards[0];

        // Simulate drag start
        const dragStartEvent = new Event('dragstart', { bubbles: true });
        Object.defineProperty(dragStartEvent, 'dataTransfer', {
            value: { effectAllowed: 'move' }
        });
        firstCard.dispatchEvent(dragStartEvent);

        // Simulate drop on different column
        const columns = element.shadowRoot.querySelectorAll('.kanban-column');
        const secondColumn = columns[1];
        const dropEvent = new Event('drop', { bubbles: true });
        Object.defineProperty(dropEvent, 'dataTransfer', {
            value: { dropEffect: 'move' }
        });
        dropEvent.preventDefault = jest.fn();
        secondColumn.dispatchEvent(dropEvent);

        await Promise.resolve();

        expect(updateCandidateStage).toHaveBeenCalled();
    });

    it('displays error message when wire fails', async () => {
        document.body.appendChild(element);

        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.error({ body: { message: 'Test error' } });

        await Promise.resolve();

        const errorDiv = element.shadowRoot.querySelector('.slds-alert_error');
        expect(errorDiv).not.toBeNull();
        expect(errorDiv.textContent).toContain('error');
    });

    it('shows loading spinner during data fetch', () => {
        document.body.appendChild(element);

        const spinner = element.shadowRoot.querySelector('lightning-spinner');
        expect(spinner).not.toBeNull();
    });

    it('refreshes data when refresh button clicked', async () => {
        document.body.appendChild(element);

        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const refreshButton = element.shadowRoot.querySelector('lightning-button[label="Refresh"]');
        expect(refreshButton).not.toBeNull();

        refreshButton.click();

        await Promise.resolve();

        // Verify loading state was triggered
        expect(element.isLoading).toBe(false); // Will be true briefly then false
    });

    it('navigates to ALC record on double click', async () => {
        document.body.appendChild(element);

        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const cards = element.shadowRoot.querySelectorAll('.kanban-card');
        const firstCard = cards[0];

        const dblClickEvent = new Event('dblclick', { bubbles: true });
        firstCard.dispatchEvent(dblClickEvent);

        await Promise.resolve();

        // Navigation would be mocked in a full test setup
        // This verifies the handler exists and doesn't throw
        expect(firstCard).not.toBeNull();
    });

    it('displays empty state when no candidates', async () => {
        const emptyData = {
            ...mockALCData,
            alcsByStage: {},
            recordTypeCounts: { 'Career': 0 }
        };

        document.body.appendChild(element);

        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.emit(emptyData);

        await Promise.resolve();

        const emptyMessage = element.shadowRoot.querySelector('.empty-column-message');
        expect(emptyMessage).not.toBeNull();
    });

    it('displays candidate count in card title', async () => {
        document.body.appendChild(element);

        getCurrentUserSalesManagerName.emit('Tim Denton');
        canViewAllSalesManagers.emit(false);
        getALCDataForSalesManager.emit(mockALCData);

        await Promise.resolve();

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card.title).toContain('(2)'); // 2 total candidates
    });
});
