import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getKanbanData from '@salesforce/apex/CandidateKanbanController.getKanbanData';
import updateCandidateStage from '@salesforce/apex/CandidateKanbanController.updateCandidateStage';

export default class CandidateKanban extends NavigationMixin(LightningElement) {
    @track stagesWithCandidates = [];
    @track isLoading = true;
    @track error;
    
    wiredKanbanResult;
    draggedCandidateId;
    draggedFromStage;

    @wire(getKanbanData)
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
}