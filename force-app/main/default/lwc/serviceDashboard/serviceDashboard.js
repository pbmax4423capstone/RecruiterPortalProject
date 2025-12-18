import { LightningElement, track, api } from 'lwc';

export default class ServiceDashboard extends LightningElement {
    @api darkMode = false;
    @track isLoading = true;

    // Dashboard metrics
    @track dashboardMetrics = {
        openCases: 47,
        caseAge: 37.6,
        a360Tickets: 11.8,
        casesCreatedMTD: 102
    };

    // Chart data for different visualizations
    @track priorityData = {
        labels: ['High', 'Medium', 'Low'],
        datasets: [{
            data: [15, 20, 12],
            backgroundColor: ['#d73527', '#ff9500', '#06a59a'],
            borderWidth: 0
        }]
    };

    @track statusData = {
        labels: ['Escalated to MassMutual', 'In Progress', 'Merged', 'New', 'Sent Email', 'Other'],
        datasets: [{
            data: [8, 12, 5, 15, 4, 3],
            backgroundColor: ['#1f4e79', '#0176d3', '#06a59a', '#00a79d', '#ffc500', '#fe9339'],
            borderWidth: 0
        }]
    };

    @track typeData = {
        labels: ['Access', 'A360', 'Technology', 'Salesforce', 'Other', 'Onboarding'],
        datasets: [{
            data: [9, 5, 7, 6, 8, 4],
            backgroundColor: ['#0176d3', '#1f4e79', '#06a59a', '#00a79d', '#ffc500', '#d73527'],
            borderWidth: 0
        }]
    };

    @track agentCaseData = {
        labels: ['Daniela Flores', 'Donna DeLuca', 'Pat Baker', 'Sara Signorelli', 'Unassigned'],
        datasets: [{
            label: 'Open Cases',
            data: [2, 14, 8, 8, 6],
            backgroundColor: ['#0176d3', '#0176d3', '#0176d3', '#0176d3', '#0176d3'],
            borderWidth: 0
        }]
    };

    @track topCasesByAge = [
        { name: 'Daniela Flores', age: 121, color: '#d73527' },
        { name: 'Sara Signorelli', age: 94, color: '#d73527' },
        { name: 'Donna DeLuca', age: 15, color: '#06a59a' },
        { name: 'Pat Baker', age: 13, color: '#06a59a' },
        { name: 'Unassigned', age: 0, color: '#06a59a' }
    ];

    @track topAgentsByAge = [
        { name: 'Sara Signorelli', age: 169, color: '#d73527' },
        { name: 'Daniela Flores', age: 121, color: '#d73527' },
        { name: 'Donna DeLuca', age: 94, color: '#ffc500' },
        { name: 'Pat Baker', age: 25, color: '#ffc500' },
        { name: 'Unassigned', age: 0, color: '#06a59a' }
    ];

    connectedCallback() {
        // Simulate data loading
        setTimeout(() => {
            this.isLoading = false;
        }, 500);
    }

    get dashboardClass() {
        return this.darkMode ? 'service-dashboard dark-mode' : 'service-dashboard';
    }

    get metricCardClass() {
        return this.darkMode ? 'slds-box metric-card dark-mode' : 'slds-box metric-card';
    }

    get chartContainerClass() {
        return this.darkMode ? 'slds-box chart-container dark-mode' : 'slds-box chart-container';
    }

    get tableClass() {
        return this.darkMode ? 'slds-table slds-table_cell-buffer slds-table_bordered dark-mode' : 'slds-table slds-table_cell-buffer slds-table_bordered';
    }

    // Chart configuration getters
    get priorityChartConfig() {
        return {
            type: 'doughnut',
            data: this.priorityData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: this.darkMode ? '#ffffff' : '#3e3e3c',
                            usePointStyle: true,
                            padding: 20
                        }
                    }
                },
                cutout: '60%'
            }
        };
    }

    get statusChartConfig() {
        return {
            type: 'doughnut',
            data: this.statusData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: this.darkMode ? '#ffffff' : '#3e3e3c',
                            usePointStyle: true,
                            padding: 20
                        }
                    }
                },
                cutout: '60%'
            }
        };
    }

    get typeChartConfig() {
        return {
            type: 'doughnut',
            data: this.typeData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: this.darkMode ? '#ffffff' : '#3e3e3c',
                            usePointStyle: true,
                            padding: 20
                        }
                    }
                },
                cutout: '60%'
            }
        };
    }

    get agentChartConfig() {
        return {
            type: 'bar',
            data: this.agentCaseData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: 'y',
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        beginAtZero: true,
                        ticks: {
                            color: this.darkMode ? '#ffffff' : '#3e3e3c'
                        },
                        grid: {
                            color: this.darkMode ? '#444444' : '#dddbda'
                        }
                    },
                    y: {
                        ticks: {
                            color: this.darkMode ? '#ffffff' : '#3e3e3c'
                        },
                        grid: {
                            color: this.darkMode ? '#444444' : '#dddbda'
                        }
                    }
                }
            }
        };
    }

    // Utility methods
    getAgeBarWidth(age, maxAge = 169) {
        return (age / maxAge) * 100;
    }

    formatNumber(num) {
        return num.toLocaleString();
    }

    // Event handlers for report links
    handleViewReport(event) {
        const reportType = event.target.dataset.report;
        console.log('Viewing report:', reportType);
        // In production, this would navigate to the actual report
    }
}