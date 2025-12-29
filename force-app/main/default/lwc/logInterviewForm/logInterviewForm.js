import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class LogInterviewForm extends LightningElement {
    @api recordId; // Candidate__c record ID
    
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Interview logged successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
}
