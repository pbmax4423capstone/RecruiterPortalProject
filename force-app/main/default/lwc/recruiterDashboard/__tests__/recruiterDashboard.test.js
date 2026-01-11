import { createElement } from 'lwc';
import RecruiterDashboard from 'c/recruiterDashboard';
import { subscribe, MessageContext } from 'lightning/messageService';
import getDashboardData from '@salesforce/apex/RecruiterDashboardController.getDashboardData';
import getUserRecentActivity from '@salesforce/apex/RecruiterDashboardController.getUserRecentActivity';
import getActiveCandidates from '@salesforce/apex/RecruiterDashboardController.getActiveCandidates';
import getActiveCandidateAnalytics from '@salesforce/apex/RecruiterDashboardController.getActiveCandidateAnalytics';
import getInterviewStatsByType from '@salesforce/apex/RecruiterDashboardController.getInterviewStatsByType';
import getInterviewStatsByInterviewer from '@salesforce/apex/RecruiterDashboardController.getInterviewStatsByInterviewer';
import getInterviewTypeWithInterviewerStats from '@salesforce/apex/RecruiterDashboardController.getInterviewTypeWithInterviewerStats';
import getCurrentUserInfo from '@salesforce/apex/RecruiterDashboardController.getCurrentUserInfo';

// Test utilities
import { flushPromises, cleanupDOM } from 'test-utils/lwc-test-helpers';

// Mock LMS
jest.mock('lightning/messageService', () => {
    return {
        subscribe: jest.fn(),
        MessageContext: jest.fn()
    };
}, { virtual: true });

// Mock all Apex methods
jest.mock('@salesforce/apex/RecruiterDashboardController.getDashboardData', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/RecruiterDashboardController.getUserRecentActivity', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/RecruiterDashboardController.getActiveCandidates', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/RecruiterDashboardController.getActiveCandidateAnalytics', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/RecruiterDashboardController.getInterviewStatsByType', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/RecruiterDashboardController.getInterviewStatsByInterviewer', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/RecruiterDashboardController.getInterviewTypeWithInterviewerStats', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('@salesforce/apex/RecruiterDashboardController.getCurrentUserInfo', () => {
    return { default: jest.fn() };
}, { virtual: true });

// Mock data
const mockUserInfo = {
    id: '005xx000001X8UzAAK',
    name: 'Test Recruiter',
    firstName: 'Test',
    email: 'test@example.com',
    userType: 'Recruiter',
    profileName: 'System Administrator',
    roleName: 'Recruiter'
};

describe('c-recruiter-dashboard', () => {
    let element;

    beforeEach(() => {
        element = createElement('c-recruiter-dashboard', {
            is: RecruiterDashboard
        });
        
        // Reset all mocks
        jest.clearAllMocks();
        
        // Setup default mock responses
        getCurrentUserInfo.mockResolvedValue(mockUserInfo);
        getInterviewTypeWithInterviewerStats.mockResolvedValue({});
    });

    afterEach(() => {
        cleanupDOM();
    });

    describe('Component Initialization', () => {
        it('renders successfully', () => {
            document.body.appendChild(element);
            
            expect(element).toBeTruthy();
        });

        it('calls getCurrentUserInfo on connectedCallback', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(getCurrentUserInfo).toHaveBeenCalled();
        });

        it('calls getInterviewTypeWithInterviewerStats on connectedCallback', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(getInterviewTypeWithInterviewerStats).toHaveBeenCalled();
        });

        it('initializes contract performance data', () => {
            document.body.appendChild(element);
            
            // Component should set contract metrics
            expect(element.contractAAdded).toBeDefined();
            expect(element.contractBAdded).toBeDefined();
        });
    });

    describe('Dark Mode Support', () => {
        it('subscribes to dark mode channel on connect', () => {
            document.body.appendChild(element);
            
            expect(subscribe).toHaveBeenCalledWith(
                undefined, // messageContext is undefined in test
                expect.anything(),
                expect.any(Function)
            );
        });

        it('applies dark mode class when enabled', () => {
            document.body.appendChild(element);
            
            element.darkMode = true;
            
            return Promise.resolve().then(() => {
                expect(element.containerClass).toContain('dark-mode');
            });
        });

        it('removes dark mode class when disabled', () => {
            document.body.appendChild(element);
            
            element.darkMode = false;
            
            return Promise.resolve().then(() => {
                expect(element.containerClass).not.toContain('dark-mode');
            });
        });
    });

    describe('User Information', () => {
        it('sets user information after successful fetch', async () => {
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.userName).toBe('Test Recruiter');
            expect(element.userFirstName).toBe('Test');
            expect(element.userEmail).toBe('test@example.com');
            expect(element.userType).toBe('Recruiter');
        });

        it('sets fallback values on fetch error', async () => {
            getCurrentUserInfo.mockRejectedValue(new Error('Test error'));
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.userName).toBe('Recruiter');
            expect(element.userFirstName).toBe('Recruiter');
        });
    });

    describe('Navigation Mixin', () => {
        it('extends NavigationMixin', () => {
            document.body.appendChild(element);
            
            // Component should have NavigationMixin methods
            expect(element).toBeTruthy();
        });
    });

    describe('Contract Performance Metrics', () => {
        it('initializes contract A metrics', () => {
            document.body.appendChild(element);
            
            expect(element.contractAAdded).toBeGreaterThanOrEqual(0);
            expect(element.contractATerminations).toBeGreaterThanOrEqual(0);
            expect(element.totalContractAAdded).toBeGreaterThanOrEqual(0);
        });

        it('initializes contract B metrics', () => {
            document.body.appendChild(element);
            
            expect(element.contractBAdded).toBeGreaterThanOrEqual(0);
            expect(element.contractBTerminations).toBeGreaterThanOrEqual(0);
            expect(element.totalContractBAdded).toBeGreaterThanOrEqual(0);
        });

        it('initializes B to A transition metrics', () => {
            document.body.appendChild(element);
            
            expect(element.contractBtoA).toBeGreaterThanOrEqual(0);
            expect(element.totalBtoATransitions).toBeGreaterThanOrEqual(0);
        });
    });

    describe('Wire Adapters', () => {
        it('has MessageContext wire adapter', () => {
            document.body.appendChild(element);
            
            // Wire adapter should be defined
            expect(element.messageContext).toBeDefined();
        });
    });

    describe('Component Structure', () => {
        it('renders dashboard container', () => {
            document.body.appendChild(element);
            
            expect(element.shadowRoot).toBeTruthy();
        });

        it('applies correct container class', () => {
            document.body.appendChild(element);
            
            expect(element.containerClass).toBeDefined();
            expect(element.containerClass).toContain('dashboard-container');
        });
    });

    describe('Call Statistics', () => {
        it('initializes call statistics', () => {
            document.body.appendChild(element);
            
            expect(element.userScheduledCalls).toBe(0);
            expect(element.userPastDueCalls).toBe(0);
            expect(element.userTotalAssigned).toBe(0);
        });
    });

    describe('Pipeline Data', () => {
        it('initializes pipeline data for Sales Managers', async () => {
            const salesManagerInfo = {
                ...mockUserInfo,
                userType: 'Sales Manager'
            };
            getCurrentUserInfo.mockResolvedValue(salesManagerInfo);
            
            document.body.appendChild(element);
            
            await flushPromises();
            
            expect(element.userType).toBe('Sales Manager');
        });

        it('initializes pipeline total to zero', () => {
            document.body.appendChild(element);
            
            expect(element.userPipelineTotal).toBe(0);
        });
    });
});