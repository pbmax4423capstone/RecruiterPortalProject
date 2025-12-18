import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCandidatesInContracting from '@salesforce/apex/CandidatesInContractingController.getCandidatesInContracting';

export default class CandidatesInContractingReadOnly extends LightningElement {
    stageGroups = [];
    error;
    isLoading = true;
    wiredResult;

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

    get hasData() {
        return this.stageGroups && this.stageGroups.length > 0;
    }

    get noDataMessage() {
        return 'No candidates in contracting at this time.';
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
}