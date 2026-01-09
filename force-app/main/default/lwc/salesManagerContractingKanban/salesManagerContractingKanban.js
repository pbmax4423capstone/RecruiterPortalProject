import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getALCDataForSalesManager from '@salesforce/apex/CandidatesInContractingController.getALCDataForSalesManager';
import getCurrentUserSalesManagerName from '@salesforce/apex/CandidatesInContractingController.getCurrentUserSalesManagerName';
import getSalesManagerOptions from '@salesforce/apex/CandidatesInContractingController.getSalesManagerOptions';
import canViewAllSalesManagers from '@salesforce/apex/CandidatesInContractingController.canViewAllSalesManagers';
import updateCandidateStage from '@salesforce/apex/CandidatesInContractingController.updateCandidateStage';

const STORAGE_KEY_SALES_MANAGER = 'smContractingKanban_salesManagerFilter';

export default class SalesManagerContractingKanban extends NavigationMixin(LightningElement) {
    stageColumns = [];
    salesManagerFilters = [];
    selectedSalesManager = 'All Sales Managers'; // Default to avoid "Loading..."
    currentUserName = '';
    showSalesManagerDropdown = false;
    error;
    isLoading = true;
    wiredResult;
    draggedCandidateId;
    draggedAlcId;
    draggedFromStage;
    _canViewAllLoaded = false;
    _currentUserLoaded = false;

    connectedCallback() {
        // Don't load from localStorage here - let the wires determine the correct value
        // based on user permissions
    }

    @wire(canViewAllSalesManagers)
    wiredCanViewAll({ error, data }) {
        if (data !== undefined) {
            this.showSalesManagerDropdown = data;
            this._canViewAllLoaded = true;
            
            // If they CAN view all, use localStorage or default to "All Sales Managers"
            if (data) {
                const storedManager = localStorage.getItem(STORAGE_KEY_SALES_MANAGER);
                if (storedManager && storedManager !== 'undefined' && storedManager !== 'null') {
                    this.selectedSalesManager = storedManager;
                } else {
                    this.selectedSalesManager = 'All Sales Managers';
                }
            }
            // If they CANNOT view all, wait for currentUserName wire to set it
        } else if (error) {
            console.error('Error checking view permissions:', error);
            this.showSalesManagerDropdown = false;
            this._canViewAllLoaded = true;
        }
    }

    @wire(getCurrentUserSalesManagerName)
    wiredCurrentUser({ error, data }) {
        if (data) {
            this.currentUserName = data;
            this._currentUserLoaded = true;
            
            // If user CANNOT view all managers, FORCE their name (ignore localStorage)
            if (!this.showSalesManagerDropdown) {
                this.selectedSalesManager = data;
                localStorage.setItem(STORAGE_KEY_SALES_MANAGER, data);
            }
        } else if (error) {
            console.error('Error getting current user:', error);
            this._currentUserLoaded = true;
        }
    }

    @wire(getSalesManagerOptions)
    wiredSalesManagers({ error, data }) {
        if (data) {
            // Build Sales Manager filter buttons/options
            this.salesManagerFilters = data.map(manager => ({
                value: manager,
                label: manager,
                variant: manager === this.selectedSalesManager ? 'brand' : 'neutral',
                title: `Filter by ${manager}`
            }));
        } else if (error) {
            console.error('Error loading sales manager options:', error);
        }
    }

    @wire(getALCDataForSalesManager, { salesManagerFilter: '$selectedSalesManager' })
    wiredALCData(result) {
        this.wiredResult = result;
        const { error, data } = result;
        this.isLoading = false;
        
        if (data) {
            this.error = undefined;
            this.buildStageColumns(data);
        } else if (error) {
            this.error = error;
            this.stageColumns = [];
            this.errorMessage = this.reduceErrors(error).join(', ');
            console.error('Error loading ALC data:', error);
        }
    }

    buildStageColumns(data) {
        const { alcsByStage, stageConfigs } = data;
        
        // Flatten all candidates from alcsByStage map into a single array
        const allCandidates = [];
        if (alcsByStage) {
            Object.keys(alcsByStage).forEach(stageKey => {
                const candidateList = alcsByStage[stageKey];
                if (Array.isArray(candidateList)) {
                    candidateList.forEach(candidate => {
                        allCandidates.push({...candidate});
                    });
                }
            });
        }

        // Get Career stage configs only
        const careerConfigs = stageConfigs['Career'] || [];
        const configs = Array.isArray(careerConfigs) ? careerConfigs.map(c => ({...c})) : [];
        
        // Build stage columns for Career record type
        this.stageColumns = configs
            .sort((a, b) => a.sortOrder - b.sortOrder)
            .map(config => {
                const stageCandidates = allCandidates.filter(
                    c => c.alcStage === config.stageApiValue
                );
                
                return {
                    stageApiValue: config.stageApiValue,
                    stageDisplayLabel: config.stageDisplayLabel,
                    stageKey: `Career_${config.stageApiValue}`.replace(/[\s\W]/g, '_'),
                    columnColor: config.columnColor,
                    headerStyle: `background-color: ${config.columnColor}; padding: 12px; border-radius: 4px;`,
                    candidates: stageCandidates,
                    count: stageCandidates.length,
                    formattedCount: this.formatCount(stageCandidates.length),
                    isEmpty: stageCandidates.length === 0
                };
            });
    }

    formatCount(count) {
        return count.toLocaleString();
    }

    handleSalesManagerFilterChange(event) {
        const manager = event.target.dataset.manager;
        this.selectedSalesManager = manager;
        localStorage.setItem(STORAGE_KEY_SALES_MANAGER, manager);
        
        // Update button variants
        this.salesManagerFilters = this.salesManagerFilters.map(filter => ({
            ...filter,
            variant: filter.value === manager ? 'brand' : 'neutral'
        }));
        
        this.isLoading = true;
    }

    get selectedSalesManagerLabel() {
        if (!this.selectedSalesManager) {
            return this._currentUserLoaded || this._canViewAllLoaded ? 'All Sales Managers' : 'Loading...';
        }
        return this.selectedSalesManager;
    }

    get hasData() {
        return this.stageColumns && this.stageColumns.length > 0;
    }

    get totalCandidates() {
        if (!this.stageColumns) return 0;
        return this.stageColumns.reduce((total, col) => total + col.count, 0);
    }

    get formattedTotal() {
        return this.formatCount(this.totalCandidates);
    }

    get cardTitle() {
        return `Career Contracting Kanban (${this.formattedTotal})`;
    }

    handleDragStart(event) {
        this.draggedCandidateId = event.currentTarget.dataset.candidateId;
        this.draggedAlcId = event.currentTarget.dataset.alcId;
        this.draggedFromStage = event.currentTarget.dataset.stage;
        event.dataTransfer.effectAllowed = 'move';
    }

    handleCardDoubleClick(event) {
        const alcId = event.currentTarget.dataset.alcId;
        if (alcId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: alcId,
                    objectApiName: 'ALC__c',
                    actionName: 'view'
                }
            });
        }
    }

    handleDragOver(event) {
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';
    }

    handleDrop(event) {
        event.preventDefault();
        const newStage = event.currentTarget.dataset.stage;
        
        if (newStage && newStage !== this.draggedFromStage) {
            this.updateStage(this.draggedAlcId, newStage);
        }
    }

    async updateStage(alcId, newStage) {
        this.isLoading = true;
        try {
            await updateCandidateStage({ alcId: alcId, newStage: newStage });
            this.showToast('Success', `Candidate moved to ${newStage}`, 'success');
            await refreshApex(this.wiredResult);
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Failed to update stage', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleRefresh() {
        this.isLoading = true;
        try {
            await refreshApex(this.wiredResult);
            this.showToast('Success', 'Data refreshed successfully', 'success');
        } catch (error) {
            this.showToast('Error', 'Failed to refresh data', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return (
            errors
                .filter(error => !!error)
                .map(error => {
                    if (Array.isArray(error.body)) {
                        return error.body.map(e => e.message);
                    } else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    } else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    return 'Unknown error';
                })
                .reduce((prev, curr) => prev.concat(curr), [])
                .filter((message, index, self) => self.indexOf(message) === index)
        );
    }

    get errorMessage() {
        return this._errorMessage || 'Unknown error occurred';
    }

    set errorMessage(value) {
        this._errorMessage = value;
    }
}
