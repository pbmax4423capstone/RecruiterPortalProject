import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCandidatesInContracting from '@salesforce/apex/CandidatesInContractingController.getCandidatesInContracting';
import updateCandidateStage from '@salesforce/apex/CandidatesInContractingController.updateCandidateStage';

export default class CandidatesInContracting extends NavigationMixin(LightningElement) {
    stageGroups = [];
    error;
    isLoading = true;
    wiredResult;
    draggedCandidateId;
    draggedAlcId;
    draggedFromStage;

    // Define stage order for Kanban - contracting stages
    stageOrder = [
        'Initial Form Sent',
        'MM ONX sent',
        'In Background',
        'Post Background - Pending Rachyll',
        'Pending SM',
        'Contract Codes (A/B) & DocuSign',
        'Submit to HO',
        'AA Received'
    ];

    getStageColor(stage) {
        const colorMap = {
            'Initial Form Sent': '#1589EE',
            'MM ONX sent': '#0D47A1',
            'In Background': '#9C27B0',
            'Post Background - Pending Rachyll': '#E83A86',
            'Pending SM': '#FF5722',
            'Contract Codes (A/B) & DocuSign': '#673AB7',
            'Submit to HO': '#009688',
            'AA Received': '#E37C06'
        };
        return colorMap[stage] || '#706E6B';
    }

    @wire(getCandidatesInContracting)
    wiredCandidates(result) {
        this.wiredResult = result;
        const { error, data } = result;
        this.isLoading = false;
        if (data) {
            // Convert map to array and sort by stage order
            const stages = this.stageOrder.map(stage => {
                const candidates = data[stage] || [];
                return {
                    stage: stage,
                    candidates: candidates,
                    count: candidates.length,
                    stageKey: stage.replace(/\s+/g, '_'),
                    stageColor: this.getStageColor(stage),
                    headerStyle: `background-color: ${this.getStageColor(stage)}; padding: 12px; border-radius: 4px;`
                };
            });
            this.stageGroups = stages;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.stageGroups = [];
        }
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

    get hasData() {
        return this.stageGroups && this.stageGroups.length > 0;
    }

    get noDataMessage() {
        return 'No candidates in contracting at this time.';
    }
}