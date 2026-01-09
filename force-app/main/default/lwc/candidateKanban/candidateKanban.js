import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';
import getKanbanData from '@salesforce/apex/CandidateKanbanController.getKanbanData';
import updateCandidateStage from '@salesforce/apex/CandidateKanbanController.updateCandidateStage';
import canViewAllCandidates from '@salesforce/apex/CandidateKanbanController.canViewAllCandidates';
import getCurrentUserName from '@salesforce/apex/CandidateKanbanController.getCurrentUserName';
import getSalesManagerOptions from '@salesforce/apex/CandidateKanbanController.getSalesManagerOptions';

const STORAGE_KEY_SALES_MANAGER = 'candidateKanban_salesManagerFilter';

export default class CandidateKanban extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    messageContext;
    
    @api darkMode = false;
    @track stagesWithCandidates = [];
    @track isLoading = true;
    @track error;
    
    wiredKanbanResult;
    draggedCandidateId;
    draggedFromStage;
    subscription = null;
    
    // Sales Manager filtering
    salesManagerFilters = [];
    selectedSalesManager = 'All Sales Managers'; // Always default to this initially
    currentUserName = '';
    showSalesManagerDropdown = false;
    _canViewAllLoaded = false;
    _currentUserLoaded = false;
    refreshInterval;

    connectedCallback() {
        this.subscribeToMessageChannel();
        // Auto-refresh every 30 seconds
        this.refreshInterval = setInterval(() => {
            this.handleRefresh();
        }, 30000);
    }

    disconnectedCallback() {
        // Clear the interval when component is destroyed
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            DARK_MODE_CHANNEL,
            (message) => this.handleDarkModeChange(message)
        );
    }

    @wire(canViewAllCandidates)
    wiredCanViewAll({ error, data }) {
        if (data !== undefined) {
            this.showSalesManagerDropdown = data;
            this._canViewAllLoaded = true;
            
            // If they CAN view all, always default to "All Sales Managers" on load
            if (data) {
                this.selectedSalesManager = 'All Sales Managers';
            }
            // If they CANNOT view all, wait for currentUserName wire to set it
        } else if (error) {
            console.error('Error checking view permissions:', error);
            this.showSalesManagerDropdown = false;
            this._canViewAllLoaded = true;
        }
    }

    @wire(getCurrentUserName)
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

    handleDarkModeChange(message) {
        this.darkMode = message.darkModeEnabled;
    }

    get containerClass() {
        return this.darkMode ? 'kanban-container dark-mode' : 'kanban-container';
    }

    get stageClass() {
        return this.darkMode ? 'kanban-stage dark-mode' : 'kanban-stage';
    }

    get candidateCardClass() {
        return this.darkMode ? 'candidate-card dark-mode' : 'candidate-card';
    }

    @wire(getKanbanData, { salesManagerFilter: '$selectedSalesManager' })
    wiredKanban(result) {
        this.wiredKanbanResult = result;
        const { data, error } = result;
        
        if (data) {
            // Transform data to include candidates directly in stage objects
            // Use JSON parse/stringify to avoid proxy object issues
            const stages = JSON.parse(JSON.stringify(data.stages));
            const candidatesByStage = JSON.parse(JSON.stringify(data.candidatesByStage));
            
            this.stagesWithCandidates = stages.map(stage => {
                const candidates = candidatesByStage[stage.value] || [];
                // Add cardClass to each candidate based on contracting status
                const candidatesWithClass = candidates.map(c => ({
                    ...c,
                    cardClass: c.inContracting ? 'candidate-card in-contracting' : 'candidate-card'
                }));
                return {
                    value: stage.value,
                    label: stage.label,
                    count: stage.count,
                    candidates: candidatesWithClass,
                    hasCandidates: candidates.length > 0
                };
            });
            this.isLoading = false;
            this.error = undefined;
        } else if (error) {
            this.error = error.body?.message || 'Error loading kanban data';
            this.isLoading = false;
        }
    }

    get totalCandidates() {
        let total = 0;
        if (this.stagesWithCandidates) {
            this.stagesWithCandidates.forEach(stage => {
                total += stage.count;
            });
        }
        return total;
    }

    // Drag and Drop handlers
    handleDragStart(event) {
        const candidateId = event.target.dataset.id;
        const stageValue = event.target.dataset.stage;
        this.draggedCandidateId = candidateId;
        this.draggedFromStage = stageValue;
        event.target.classList.add('dragging');
    }

    handleDragEnd(event) {
        event.target.classList.remove('dragging');
    }

    handleDragOver(event) {
        event.preventDefault();
        const column = event.currentTarget;
        column.classList.add('drag-over');
    }

    handleDragLeave(event) {
        const column = event.currentTarget;
        column.classList.remove('drag-over');
    }

    async handleDrop(event) {
        event.preventDefault();
        const column = event.currentTarget;
        column.classList.remove('drag-over');
        
        const newStage = column.dataset.stage;
        
        if (this.draggedCandidateId && newStage !== this.draggedFromStage) {
            this.isLoading = true;
            try {
                await updateCandidateStage({ 
                    candidateId: this.draggedCandidateId, 
                    newStage: newStage 
                });
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Candidate stage updated',
                        variant: 'success'
                    })
                );
                
                await refreshApex(this.wiredKanbanResult);
            } catch (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || 'Error updating stage',
                        variant: 'error'
                    })
                );
            }
            this.isLoading = false;
        }
        
        this.draggedCandidateId = null;
        this.draggedFromStage = null;
    }

    // Navigation handlers
    handleCardClick(event) {
        const candidateId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: candidateId,
                objectApiName: 'Candidate__c',
                actionName: 'view'
            }
        });
    }

    handleEmailClick(event) {
        event.stopPropagation();
        const email = event.currentTarget.dataset.email;
        if (email) {
            window.location.href = `mailto:${email}`;
        }
    }

    handlePhoneClick(event) {
        event.stopPropagation();
        const phone = event.currentTarget.dataset.phone;
        if (phone) {
            window.location.href = `tel:${phone}`;
        }
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wiredKanbanResult).then(() => {
            this.isLoading = false;
        });
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
}