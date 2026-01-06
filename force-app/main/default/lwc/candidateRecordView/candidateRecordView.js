import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { getRecord } from "lightning/uiRecordApi";
import { subscribe, unsubscribe, onError } from "lightning/empApi";
import getCandidateData from "@salesforce/apex/CandidateRecordViewController.getCandidateData";
import getNotes from "@salesforce/apex/CandidateNotesController.getNotes";

// Import a field to wire getRecord for automatic refresh detection
import ID_FIELD from "@salesforce/schema/Candidate__c.Id";

export default class CandidateRecordView extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @track activeTab = "candidate";
  @track notes = [];
  @track candidateData;
  @track error;
  @track isLoading = true;
  refreshInterval;
  subscription = null;
  channelName = "/data/Candidate__ChangeEvent";

  // Wire getRecord to detect standard edit saves
  @wire(getRecord, { recordId: "$recordId", fields: [ID_FIELD] })
  wiredRecord({ data }) {
    if (data) {
      // Record was updated, refresh our custom data
      this.loadCandidateData();
    }
  }

  connectedCallback() {
    this.loadCandidateData();
    this.loadNotes();
    // Set up auto-refresh every 5 seconds to check for new notes
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.refreshInterval = setInterval(() => {
      this.loadNotes();
    }, 5000);
    // Subscribe to Change Data Capture for real-time updates
    this.subscribeToChangeEvents();
  }

  disconnectedCallback() {
    // Clear interval when component is destroyed
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
    // Unsubscribe from CDC
    this.unsubscribeFromChangeEvents();
  }

  subscribeToChangeEvents() {
    // Register error listener
    onError((error) => {
      console.error("EMP API error: ", JSON.stringify(error));
    });

    // Subscribe to Candidate__c change events
    subscribe(this.channelName, -1, (message) => {
      console.log("CDC Event received:", JSON.stringify(message));
      // Check if this event is for our record
      const changeEventHeader = message.data.payload.ChangeEventHeader;
      if (changeEventHeader.recordIds.includes(this.recordId)) {
        this.loadCandidateData();
      }
    })
      .then((response) => {
        this.subscription = response;
        console.log("Successfully subscribed to CDC channel");
      })
      .catch((error) => {
        console.error("CDC subscription error:", JSON.stringify(error));
      });
  }

  unsubscribeFromChangeEvents() {
    if (this.subscription) {
      unsubscribe(this.subscription, () => {
        console.log("Unsubscribed from CDC channel");
      });
    }
  }

  // Public method to allow parent components to trigger refresh
  @api
  refreshData() {
    this.loadCandidateData();
    this.loadNotes();
  }

  loadCandidateData() {
    if (this.recordId) {
      getCandidateData({ recordId: this.recordId })
        .then((data) => {
          this.candidateData = data;
          this.error = undefined;
          this.isLoading = false;
        })
        .catch((error) => {
          this.error = error;
          this.candidateData = undefined;
          this.isLoading = false;
        });
    }
  }

  loadNotes() {
    if (this.recordId) {
      getNotes({ recordId: this.recordId })
        .then((data) => {
          console.log("Notes loaded successfully for record:", this.recordId);
          console.log("Number of notes:", data ? data.length : 0);
          console.log("Notes data:", JSON.stringify(data));
          this.notes = data || [];
        })
        .catch((error) => {
          console.error("Error loading notes for record:", this.recordId);
          console.error("Error details:", JSON.stringify(error));
          if (error.body && error.body.message) {
            console.error("Error message:", error.body.message);
          }
          this.notes = [];
        });
    }
  }

  get errorMessage() {
    if (!this.error) return "";
    if (this.error.body && this.error.body.message) {
      return this.error.body.message;
    }
    if (this.error.message) {
      return this.error.message;
    }
    return JSON.stringify(this.error);
  }

  // Tab Handlers
  handleTabChange(event) {
    this.activeTab = event.target.value;
  }

  get isCandidateTab() {
    return this.activeTab === "candidate";
  }

  get isContractingTab() {
    return this.activeTab === "contracting";
  }

  // Basic Info Getters
  get candidateName() {
    return this.candidateData?.Name || "Candidate";
  }

  get position() {
    return this.candidateData?.Position__c || "Insurance Agent";
  }

  get office() {
    return this.candidateData?.Office_Location_Picklist__c;
  }

  get status() {
    return this.candidateData?.Status__c;
  }

  // Contact Info Getters
  get email() {
    return this.candidateData?.Personal_Email_Formula__c;
  }

  get emailLink() {
    const email = this.email;
    return email ? `mailto:${email}` : null;
  }

  get phone() {
    // Try Mobile__c first, then fall back to Contact's Phone
    return (
      this.candidateData?.Mobile__c || this.candidateData?.Contact__r?.Phone
    );
  }

  get phoneLink() {
    const phone = this.phone;
    return phone ? `tel:${phone}` : null;
  }

  get contactId() {
    return this.candidateData?.Contact__c;
  }

  // Information Tab Field Getters
  get type() {
    return this.candidateData?.Type__c;
  }

  get firstName() {
    return this.candidateData?.First_Name__c;
  }

  get nickname() {
    return this.candidateData?.Nickname__c;
  }

  get middleName() {
    return this.candidateData?.Middle_Name_or_Initial__c;
  }

  get lastName() {
    return this.candidateData?.Last_Name__c;
  }

  get suffix() {
    return this.candidateData?.Suffix__c;
  }

  get agency() {
    return this.candidateData?.Agency__c;
  }

  get targetMarket() {
    return this.candidateData?.Target_Market__c;
  }

  get salesManager() {
    return this.candidateData?.Sales_Manager__c;
  }

  get recruiter() {
    return this.candidateData?.RecruiterPicklist__c;
  }

  get recruitingSource() {
    return this.candidateData?.Recruiting_Source__c;
  }

  get recruitingSubSource() {
    return this.candidateData?.Recruiting_Sub_Source__c;
  }

  get gender() {
    return this.candidateData?.Gender__c;
  }

  get website() {
    return this.candidateData?.Website__c;
  }

  get highestLevel() {
    return this.candidateData?.Highest_Level_Achieved__c;
  }

  // Contracting Tab Field Getters
  get mde200() {
    return this.candidateData?.MDE200__c;
  }

  get ms10() {
    return this.candidateData?.MS_10__c;
  }

  get careerPresentation() {
    return this.candidateData?.Career_Presentation_ppt__c;
  }

  get nextStep() {
    return this.candidateData?.Next_Step__c;
  }

  get nextMeetingDate() {
    return this.candidateData?.Next_Meeting_Date__c;
  }

  get studyingForLifeHealth() {
    return this.candidateData?.Studying_for_Life_Health__c;
  }

  get registered() {
    return this.candidateData?.Registered__c;
  }

  get insuranceLicensed() {
    return this.candidateData?.Insurance_Licensed__c;
  }

  get dateOfBirth() {
    return this.candidateData?.Date_of_Birth__c;
  }

  get relationships() {
    return this.candidateData?.RELATIONSHIPS__c;
  }

  get offerAccepted() {
    return this.candidateData?.Offer_Accepted__c;
  }

  // Notes
  get summary() {
    return this.candidateData?.Candidate_Summary__c;
  }

  get legacyNotes() {
    return this.candidateData?.Notes__c;
  }

  get hasLegacyNotes() {
    return this.legacyNotes && this.legacyNotes.trim().length > 0;
  }

  // Action Button Handlers
  handleEdit() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Candidate__c",
        actionName: "edit"
      }
    });
  }

  handleCreateInterview() {
    // Launch Create Interview quick action
    const defaultValues = encodeDefaultFieldValues({
      Candidate__c: this.recordId
    });

    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Interview__c",
        actionName: "new"
      },
      state: {
        defaultFieldValues: defaultValues,
        useRecordTypeCheck: 1
      }
    });
  }

  handleStartContracting() {
    // Navigate to Start Contracting for Candidate flow
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: `/flow/Start_Contracting_for_Candidate?recordId=${this.recordId}`
      }
    });
  }

  handleDelete() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Candidate__c",
        actionName: "delete"
      }
    });
  }

  navigateToContact() {
    if (this.contactId) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.contactId,
          objectApiName: "Contact",
          actionName: "view"
        }
      });
    }
  }

  get hasNotes() {
    return this.notes && this.notes.length > 0;
  }

  handleCreateNote() {
    // Navigate to the related Files tab where enhanced notes can be created
    this[NavigationMixin.Navigate]({
      type: "standard__recordRelationshipPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Candidate__c",
        relationshipApiName: "AttachedContentNotes",
        actionName: "view"
      }
    });
  }

  handleRefreshNotes() {
    this.loadNotes();
  }
}
