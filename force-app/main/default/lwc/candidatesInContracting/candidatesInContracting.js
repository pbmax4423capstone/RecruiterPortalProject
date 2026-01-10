import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getALCDataWithConfig from '@salesforce/apex/CandidatesInContractingController.getALCDataWithConfig';
import getAgencyPicklistValues from '@salesforce/apex/CandidatesInContractingController.getAgencyPicklistValues';
import updateCandidateStage from '@salesforce/apex/CandidatesInContractingController.updateCandidateStage';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';

const STORAGE_KEY_AGENCY = 'candidatesInContracting_selectedAgency';
const RECORD_TYPE_ORDER = ['Broker', 'Career', 'NRF', 'Registration', 'Financing'];
const AGENCY_LABELS = {
    'A157': 'Agency 157',
    'A007': 'Agency 007',
    'All': 'All Agencies'
};

export default class CandidatesInContracting extends NavigationMixin(LightningElement) {
    darkMode = false;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    recordTypeTabs = [];
    agencyFilters = [];
    selectedAgency = 'A157';
    activeRecordType = 'Broker';
    error;
    isLoading = true;
    wiredResult;
    draggedCandidateId;
    draggedAlcId;
    draggedFromStage;

    connectedCallback() {
        this.subscribeToMessageChannel();
        // Restore agency filter from localStorage
        const storedAgency = localStorage.getItem(STORAGE_KEY_AGENCY);
        if (storedAgency) {
            this.selectedAgency = storedAgency;
        } else {
            // Default to A157
            this.selectedAgency = 'A157';
        }
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                DARK_MODE_CHANNEL,
                (message) => this.handleDarkModeChange(message)
            );
        }
    }

    handleDarkModeChange(message) {
        this.darkMode = message.darkModeEnabled;
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    @wire(getAgencyPicklistValues)
    wiredAgencies({ error, data }) {
        if (data) {
            // Build agency filter buttons
            this.agencyFilters = data.map(agency => ({
                value: agency,
                label: AGENCY_LABELS[agency] || agency,
                variant: agency === this.selectedAgency ? 'brand' : 'neutral',
                title: `Filter by ${AGENCY_LABELS[agency] || agency}`
            }));
        } else if (error) {
            console.error('Error loading agency picklist:', error);
        }
    }

    @wire(getALCDataWithConfig, { agencyFilter: '$selectedAgency' })
    wiredALCData(result) {
        this.wiredResult = result;
        const { error, data } = result;
        this.isLoading = false;
        
        if (data) {
            this.error = undefined;
            this.buildRecordTypeTabs(data);
        } else if (error) {
            this.error = error;
            this.recordTypeTabs = [];
            this.errorMessage = this.reduceErrors(error).join(', ');
            console.error('Error loading ALC data:', error);
        }
    }

    buildRecordTypeTabs(data) {
        const { alcsByStage, stageConfigs, recordTypeCounts } = data;
        
        // Flatten all candidates from alcsByStage map into a single array
        // Need to create copies because @wire data is read-only
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

        // Build tabs in the specified order
        this.recordTypeTabs = RECORD_TYPE_ORDER.map(recordType => {
            // Get configs for this record type and create copies
            const configList = stageConfigs[recordType] || [];
            const configs = Array.isArray(configList) ? configList.map(c => ({...c})) : [];
            const recordTypeCandidates = allCandidates.filter(c => c.recordTypeName === recordType);
            
            // Build stage columns for this record type
            const stageColumns = configs
                .sort((a, b) => a.sortOrder - b.sortOrder)
                .map(config => {
                    const stageCandidates = recordTypeCandidates.filter(
                        c => c.alcStage === config.stageApiValue
                    );
                    
                    return {
                        stageApiValue: config.stageApiValue,
                        stageDisplayLabel: config.stageDisplayLabel,
                        stageKey: `${recordType}_${config.stageApiValue}`.replace(/[\s\W]/g, '_'),
                        columnColor: config.columnColor,
                        headerStyle: `background-color: ${config.columnColor}; padding: 12px; border-radius: 4px;`,
                        candidates: stageCandidates,
                        count: stageCandidates.length,
                        formattedCount: this.formatCount(stageCandidates.length),
                        isEmpty: stageCandidates.length === 0
                    };
                });

            const totalCount = recordTypeCounts ? (recordTypeCounts[recordType] || 0) : recordTypeCandidates.length;
            const formattedTotal = this.formatCount(totalCount);

            return {
                value: recordType,
                label: recordType,
                tabLabelWithCount: `${recordType} (${formattedTotal})`,
                title: `${recordType} contracting workflow - ${formattedTotal} records`,
                stageColumns: stageColumns,
                hasData: stageColumns.length > 0,
                candidateCount: totalCount
            };
        });
    }

    formatCount(count) {
        return count.toLocaleString();
    }

    handleAgencyFilterChange(event) {
        const agency = event.target.dataset.agency;
        this.selectedAgency = agency;
        localStorage.setItem(STORAGE_KEY_AGENCY, agency);
        
        // Update button variants
        this.agencyFilters = this.agencyFilters.map(filter => ({
            ...filter,
            variant: filter.value === agency ? 'brand' : 'neutral'
        }));
        
        this.isLoading = true;
    }

    handleTabChange(event) {
        this.activeRecordType = event.target.value;
    }

    get selectedAgencyLabel() {
        return AGENCY_LABELS[this.selectedAgency] || this.selectedAgency;
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

    get containerClass() {
        return this.darkMode ? 'container dark-mode' : 'container';
    }
}