import { LightningElement, api } from 'lwc';

export default class ActivitiesWrapper extends LightningElement {
    @api recordId;
    @api objectApiName = 'Candidate__c';
}
