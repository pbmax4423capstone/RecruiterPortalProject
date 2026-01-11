import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createALCForCandidate from '@salesforce/apex/ALCRecordViewController.createALCForCandidate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StartContractingAction extends NavigationMixin(LightningElement) {
    @api candidateId;
    @api contactId;
    @api label = 'Start Contracting';
    @api variant = 'success';
    @api iconName = 'utility:contract';
    isLoading = false;

    get isDisabled() {
        return this.isLoading || !this.candidateId || !this.contactId;
    }

    async handleClick() {
        if (!this.candidateId || !this.contactId) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Missing information',
                message: 'Link both Candidate and Contact before starting contracting.',
                variant: 'warning'
            }));
            return;
        }
        this.isLoading = true;
        try {
            const alcId = await createALCForCandidate({ candidateId: this.candidateId, contactId: this.contactId });
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
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Contracting failed',
                message: error?.body?.message || 'An error occurred while starting contracting.',
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }
}
