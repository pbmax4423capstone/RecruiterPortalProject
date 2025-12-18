import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFunnelData from '@salesforce/apex/CandidateFunnelController.getFunnelData';

export default class CandidateFunnelDashboard extends NavigationMixin(LightningElement) {
    @track funnelData;
    @track stages = [];
    @track isLoading = true;
    @track error;

    @wire(getFunnelData)
    wiredFunnel({ data, error }) {
        if (data) {
            this.funnelData = data;
            this.stages = data.stages.map((stage, index) => ({
                ...stage,
                isFirst: index === 0,
                isLast: index === data.stages.length - 1,
                conversionClass: this.getConversionClass(stage.conversionRate),
                dropOffClass: this.getDropOffClass(stage.dropOffRate),
                barStyle: `width: ${stage.widthPercent}%`,
                countBarStyle: `width: ${Math.max(5, stage.percentOfTotal)}%`
            }));
            this.isLoading = false;
            this.error = undefined;
        } else if (error) {
            this.error = error.body?.message || 'Error loading funnel data';
            this.isLoading = false;
        }
    }

    getConversionClass(rate) {
        if (rate >= 80) return 'conversion-excellent';
        if (rate >= 60) return 'conversion-good';
        if (rate >= 40) return 'conversion-fair';
        return 'conversion-poor';
    }

    getDropOffClass(rate) {
        if (rate >= 50) return 'dropoff-critical';
        if (rate >= 30) return 'dropoff-warning';
        return 'dropoff-normal';
    }

    get hasData() {
        return this.funnelData && this.funnelData.totalCandidates > 0;
    }

    get totalCandidates() {
        return this.funnelData?.totalCandidates || 0;
    }

    get totalScheduledInterviews() {
        return this.funnelData?.totalScheduledInterviews || 0;
    }

    get overallConversionRate() {
        return this.funnelData?.overallConversionRate || 0;
    }

    get biggestDropOffStage() {
        return this.funnelData?.biggestDropOffStage || 'N/A';
    }

    get biggestDropOffRate() {
        return this.funnelData?.biggestDropOffRate || 0;
    }

    get completedThisMonth() {
        return this.funnelData?.completedThisMonth || 0;
    }

    handleStageClick(event) {
        const stageValue = event.currentTarget.dataset.stage;
        // Navigate to a list view filtered by this stage
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Candidate__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }
}