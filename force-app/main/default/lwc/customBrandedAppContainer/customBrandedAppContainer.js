import { LightningElement, track } from 'lwc';

/**
 * Custom Branded App Container
 * Provides custom branding wrapper for Lightning components
 * Use as root component in Lightning App Builder for custom-branded experience
 */
export default class CustomBrandedAppContainer extends LightningElement {
    @track isLoading = false;

    /**
     * Toggle loading state
     */
    showLoading() {
        this.isLoading = true;
    }

    hideLoading() {
        this.isLoading = false;
    }
}
