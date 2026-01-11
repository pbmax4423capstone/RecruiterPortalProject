import { LightningElement, api, track } from 'lwc';
import sendEmail from '@salesforce/apex/CaseEmailController.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseEmailCompose extends LightningElement {
    @api recordId; // Case Id
    @track to = '';
    @track cc = '';
    @track bcc = '';
    @track subject = '';
    @track body = '';
    @track sending = false;
    @track isDictating = false;
    dictationSupported = false;
    recognition;

    get dictationIcon() {
        return this.isDictating ? 'utility:stop' : 'utility:mic';
    }

    handleTo = (e) => this.to = e.detail.value;
    handleCc = (e) => this.cc = e.detail.value;
    handleBcc = (e) => this.bcc = e.detail.value;
    handleSubject = (e) => this.subject = e.detail.value;
    handleBody = (e) => this.body = e.detail.value;

    connectedCallback() {
        // Feature detection for browser SpeechRecognition
        const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (SR) {
            this.dictationSupported = true;
            this.recognition = new SR();
            this.recognition.lang = 'en-US';
            this.recognition.interimResults = false;
            this.recognition.continuous = false;
            this.recognition.onresult = (event) => {
                let transcript = '';
                for (let i = event.resultIndex; i < event.results.length; i++) {
                    if (event.results[i].isFinal) {
                        transcript += event.results[i][0].transcript;
                    }
                }
                if (transcript) {
                    const escaped = this.escapeHtml(transcript.trim());
                    this.body = (this.body ? this.body + '<br/>' : '') + `<p>${escaped}</p>`;
                }
            };
            this.recognition.onend = () => {
                this.isDictating = false;
            };
            this.recognition.onerror = () => {
                this.isDictating = false;
                this.showToast('Dictation error', 'Unable to capture audio. Please try again.', 'error');
            };
        }
    }

    disconnectedCallback() {
        if (this.recognition && this.isDictating) {
            try { this.recognition.stop(); } catch (e) { /* noop */ }
        }
    }

    escapeHtml(str) {
        return str
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }

    toggleDictation() {
        if (!this.dictationSupported) {
            this.showToast('Not supported', 'Speech recognition is not supported in this browser.', 'warning');
            return;
        }
        if (!this.isDictating) {
            this.isDictating = true;
            try { this.recognition.start(); } catch (e) { /* ignore double starts */ }
        } else {
            this.isDictating = false;
            try { this.recognition.stop(); } catch (e) { /* noop */ }
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    @api prefillReply(payload) {
        if (!payload) return;
        const { to, subject, body } = payload;
        if (to) this.to = to;
        if (subject) this.subject = subject.startsWith('Re:') ? subject : `Re: ${subject}`;
        if (body) {
            const quoted = `<br/><br/><blockquote style="border-left:2px solid #ddd;padding-left:8px;">${body}</blockquote>`;
            this.body = quoted;
        }
    }

    clear = () => {
        this.to = '';
        this.cc = '';
        this.bcc = '';
        this.subject = '';
        this.body = '';
    };

    async send() {
        if (!this.recordId || !this.to) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Missing info', message: 'Please provide To and Subject', variant: 'warning' }));
            return;
        }
        this.sending = true;
        try {
            await sendEmail({ caseId: this.recordId, toCsv: this.to, ccCsv: this.cc, bccCsv: this.bcc, subject: this.subject, htmlBody: this.body, orgWideEmailId: null });
            this.dispatchEvent(new ShowToastEvent({ title: 'Email sent', message: 'Your email was sent.', variant: 'success' }));
            this.dispatchEvent(new CustomEvent('emailsent', { bubbles: true, composed: true }));
            this.clear();
        } catch (e) {
            const msg = e?.body?.message || 'Failed to send email';
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: msg, variant: 'error', mode: 'sticky' }));
        } finally {
            this.sending = false;
        }
    }
}
