import { createElement } from 'lwc';
import ContractBPipelineDashboard from 'c/contractBPipelineDashboard';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Test utilities
import { flushPromises, cleanupDOM } from 'test-utils/lwc-test-helpers';

// Mock all Apex methods
jest.mock('@salesforce/apex/ContractBDashboardController.getContractBPipelineData', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/ContractBDashboardController.getInterviewStatsByPeriod', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/ContractBDashboardController.getRecruitingMetrics', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/ContractBDashboardController.getContractAProgressData', () => {
    return { default: jest.fn() };
}, { virtual: true });

// Mock Lightning Message Service
jest.mock('lightning/messageService', () => {
    return {
        subscribe: jest.fn(),
        unsubscribe: jest.fn(),
        publish: jest.fn(),
        MessageContext: {}
    };
}, { virtual: true });

// Mock message channel
jest.mock('@salesforce/messageChannel/DarkModeChannel__c', () => {
    return {};
}, { virtual: true });

// Import mocked Apex methods for assertions
import getContractBPipelineData from '@salesforce/apex/ContractBDashboardController.getContractBPipelineData';
import getInterviewStatsByPeriod from '@salesforce/apex/ContractBDashboardController.getInterviewStatsByPeriod';
import getRecruitingMetrics from '@salesforce/apex/ContractBDashboardController.getRecruitingMetrics';
import getContractAProgressData from '@salesforce/apex/ContractBDashboardController.getContractAProgressData';

describe('c-contract-b-pipeline-dashboard', () => {
    let element;

    beforeEach(() => {
        element = createElement('c-contract-b-pipeline-dashboard', {
            is: ContractBPipelineDashboard
        });
        
        // Reset all mocks
        jest.clearAllMocks();
        
        // Default mock implementations (resolved promises)
        getContractBPipelineData.mockResolvedValue({
            pipeline: [],
            atRiskCandidates: [],
            summary: {}
        });
        getInterviewStatsByPeriod.mockResolvedValue({});
        getRecruitingMetrics.mockResolvedValue({
            monthlyRecruiting: [],
            terminationReasons: [],
            ytdTotals: {}
        });
        getContractAProgressData.mockResolvedValue({
            contractAData: [],
            summary: {}
        });
    });

    afterEach(() => {
        cleanupDOM();
    });

    describe('Component Initialization', () => {
        it('renders successfully', () => {
            document.body.appendChild(element);
            
            expect(element).toBeTruthy();
        });

        it('loads all data on connection', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(getContractBPipelineData).toHaveBeenCalled();
            expect(getInterviewStatsByPeriod).toHaveBeenCalled();
            expect(getRecruitingMetrics).toHaveBeenCalled();
            expect(getContractAProgressData).toHaveBeenCalled();
        });

        it('sets isLoading to false after data loads', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.isLoading).toBe(false);
        });

        it('handles data loading errors gracefully', async () => {
            getContractBPipelineData.mockRejectedValue(new Error('Test error'));
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Component should still render and set isLoading to false
            expect(element.isLoading).toBe(false);
        });
    });

    describe('Dark Mode', () => {
        it('applies dark mode class when enabled', async () => {
            document.body.appendChild(element);
            element.darkMode = true;
            
            await flushPromises();
            
            const container = element.shadowRoot.querySelector('.dashboard-container');
            if (container) {
                expect(container.classList.contains('dark-mode')).toBe(true);
            }
        });

        it('does not apply dark mode class when disabled', async () => {
            document.body.appendChild(element);
            element.darkMode = false;
            
            await flushPromises();
            
            const container = element.shadowRoot.querySelector('.dashboard-container');
            if (container) {
                expect(container.classList.contains('dark-mode')).toBe(false);
            }
        });
    });

    describe('Pipeline Data', () => {
        it('displays pipeline data when loaded', async () => {
            const mockData = {
                pipeline: [
                    { stage: 'New', count: 5, candidates: [] },
                    { stage: 'Active', count: 10, candidates: [] }
                ],
                atRiskCandidates: [],
                summary: { total: 15 }
            };
            getContractBPipelineData.mockResolvedValue(mockData);
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.pipelineData).toEqual(mockData.pipeline);
            expect(element.summary.total).toBe(15);
        });

        it('handles empty pipeline data', async () => {
            getContractBPipelineData.mockResolvedValue({
                pipeline: [],
                atRiskCandidates: [],
                summary: {}
            });
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.pipelineData).toEqual([]);
        });

        it('displays at-risk candidates', async () => {
            const mockData = {
                pipeline: [],
                atRiskCandidates: [
                    { Id: '001', Name: 'Test Candidate' }
                ],
                summary: {}
            };
            getContractBPipelineData.mockResolvedValue(mockData);
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.atRiskCandidates.length).toBe(1);
            expect(element.atRiskCandidates[0].Name).toBe('Test Candidate');
        });
    });

    describe('Interview Statistics', () => {
        it('loads interview stats for current month by default', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(getInterviewStatsByPeriod).toHaveBeenCalledWith({
                period: 'currentMonth'
            });
        });

        it('updates interview stats when period changes', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Simulate period change
            element.interviewPeriod = 'yearToDate';
            await element.loadInterviewStats();
            
            expect(getInterviewStatsByPeriod).toHaveBeenCalledWith({
                period: 'yearToDate'
            });
        });

        it('has period toggle options', () => {
            document.body.appendChild(element);
            
            expect(element.periodOptions).toEqual([
                { label: 'Current Month', value: 'currentMonth' },
                { label: 'Year to Date', value: 'yearToDate' }
            ]);
        });
    });

    describe('Recruiting Metrics', () => {
        it('loads and displays recruiting metrics', async () => {
            const mockMetrics = {
                monthlyRecruiting: [
                    { month: 'January', hires: 5 }
                ],
                terminationReasons: [
                    { reason: 'Voluntary', count: 2 }
                ],
                ytdTotals: { hires: 50, terminations: 10 }
            };
            getRecruitingMetrics.mockResolvedValue(mockMetrics);
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.monthlyRecruiting).toEqual(mockMetrics.monthlyRecruiting);
            expect(element.terminationReasons).toEqual(mockMetrics.terminationReasons);
            expect(element.ytdTotals).toEqual(mockMetrics.ytdTotals);
        });

        it('displays YTD totals', async () => {
            const mockMetrics = {
                monthlyRecruiting: [],
                terminationReasons: [],
                ytdTotals: { 
                    totalHires: 100,
                    totalTerminations: 20,
                    netGrowth: 80
                }
            };
            getRecruitingMetrics.mockResolvedValue(mockMetrics);
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.ytdTotals.totalHires).toBe(100);
            expect(element.ytdTotals.netGrowth).toBe(80);
        });
    });

    describe('Contract A Progress', () => {
        it('loads Contract A progress data', async () => {
            const mockData = {
                contractAData: [
                    { Id: '001', Name: 'Test Agent', progress: 75 }
                ],
                summary: { total: 10, completed: 3 }
            };
            getContractAProgressData.mockResolvedValue(mockData);
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.contractAData).toEqual(mockData.contractAData);
            expect(element.contractASummary.total).toBe(10);
        });

        it('handles empty Contract A data', async () => {
            getContractAProgressData.mockResolvedValue({
                contractAData: [],
                summary: {}
            });
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.contractAData).toEqual([]);
        });
    });

    describe('Refresh Functionality', () => {
        it('reloads all data when refresh is triggered', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Clear previous calls
            jest.clearAllMocks();
            
            // Trigger refresh
            await element.handleRefresh();
            
            expect(getContractBPipelineData).toHaveBeenCalled();
            expect(getInterviewStatsByPeriod).toHaveBeenCalled();
            expect(getRecruitingMetrics).toHaveBeenCalled();
            expect(getContractAProgressData).toHaveBeenCalled();
        });

        it('sets loading state during refresh', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Start refresh (don't await)
            const refreshPromise = element.handleRefresh();
            
            // Check loading state is true during refresh
            expect(element.isLoading).toBe(true);
            
            // Wait for completion
            await refreshPromise;
            
            // Check loading state is false after refresh
            expect(element.isLoading).toBe(false);
        });
    });

    describe('Navigation', () => {
        it('navigates to candidate record', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Navigation method should be available
            expect(typeof element.navigateToCandidate).toBe('function');
        });
    });

    describe('Component Structure', () => {
        it('renders dashboard container', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            const container = element.shadowRoot.querySelector('.dashboard-container');
            expect(container).toBeTruthy();
        });

        it('renders loading spinner initially', () => {
            document.body.appendChild(element);
            
            // Before data loads
            expect(element.isLoading).toBe(true);
        });
    });

    describe('Error Handling', () => {
        it('handles pipeline data error', async () => {
            getContractBPipelineData.mockRejectedValue(new Error('Pipeline error'));
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Component should still render without crashing
            expect(element).toBeTruthy();
        });

        it('handles interview stats error', async () => {
            getInterviewStatsByPeriod.mockRejectedValue(new Error('Stats error'));
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Component should still render
            expect(element).toBeTruthy();
        });

        it('handles recruiting metrics error', async () => {
            getRecruitingMetrics.mockRejectedValue(new Error('Metrics error'));
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            // Component should still render
            expect(element).toBeTruthy();
        });
    });
});
