/**
 * LWC Test Utilities
 * Helper functions for testing Lightning Web Components
 */

/**
 * Flush all pending promises
 * Use after triggering async operations in tests
 */
export const flushPromises = () => {
    return new Promise((resolve) => setImmediate(resolve));
};

/**
 * Wait for component to finish rendering
 * @param {number} ms - Milliseconds to wait (default: 0)
 */
export const waitForComponentRender = (ms = 0) => {
    return new Promise((resolve) => setTimeout(resolve, ms));
};

/**
 * Create mock wire adapter data
 * @param {*} data - Data to emit
 * @param {*} error - Error to emit (optional)
 */
export const createMockWireData = (data, error = undefined) => {
    return { data, error };
};

/**
 * Simulate wire adapter emitting data
 * @param {Function} wireAdapter - Registered wire adapter
 * @param {*} data - Data to emit
 */
export const emitWireData = (wireAdapter, data) => {
    wireAdapter.emit(data);
};

/**
 * Simulate wire adapter emitting error
 * @param {Function} wireAdapter - Registered wire adapter
 * @param {*} error - Error to emit
 */
export const emitWireError = (wireAdapter, error) => {
    wireAdapter.error(error);
};

/**
 * Get element by selector with safety check
 * @param {Element} element - Root element
 * @param {string} selector - CSS selector
 */
export const getElementBySelector = (element, selector) => {
    const result = element.shadowRoot.querySelector(selector);
    if (!result) {
        throw new Error(`Element not found: ${selector}`);
    }
    return result;
};

/**
 * Get all elements by selector
 * @param {Element} element - Root element
 * @param {string} selector - CSS selector
 */
export const getAllElementsBySelector = (element, selector) => {
    return element.shadowRoot.querySelectorAll(selector);
};

/**
 * Mock ShowToastEvent
 * Returns array of dispatched toast events for verification
 */
export const mockShowToastEvent = () => {
    const toasts = [];
    return {
        toasts,
        handler: (event) => {
            toasts.push({
                title: event.detail.title,
                message: event.detail.message,
                variant: event.detail.variant,
                mode: event.detail.mode
            });
        }
    };
};

/**
 * Mock Lightning Message Service
 * Returns object with publish/subscribe tracking
 */
export const mockMessageService = () => {
    const published = [];
    const subscribers = new Map();
    
    return {
        published,
        subscribers,
        publish: (context, channel, message) => {
            published.push({ channel, message });
            // Notify subscribers
            if (subscribers.has(channel)) {
                subscribers.get(channel).forEach(callback => callback(message));
            }
        },
        subscribe: (context, channel, callback) => {
            if (!subscribers.has(channel)) {
                subscribers.set(channel, []);
            }
            subscribers.get(channel).push(callback);
            return {}; // Return subscription object
        },
        unsubscribe: (subscription) => {
            // Mock unsubscribe
        }
    };
};

/**
 * Create mock navigation mixin
 */
export const createNavigationMock = () => {
    return jest.fn();
};

/**
 * Verify toast was dispatched
 * @param {Array} toasts - Array from mockShowToastEvent
 * @param {Object} expected - Expected toast properties
 */
export const expectToast = (toasts, expected) => {
    const matching = toasts.find(
        toast =>
            toast.title === expected.title &&
            toast.variant === expected.variant
    );
    expect(matching).toBeTruthy();
};

/**
 * Clean up DOM after test
 */
export const cleanupDOM = () => {
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
};

/**
 * Mock Apex method response
 * @param {Function} apexMethod - Apex method to mock
 * @param {*} response - Response data or Error
 */
export const mockApexResponse = (apexMethod, response) => {
    if (response instanceof Error) {
        apexMethod.mockRejectedValue(response);
    } else {
        apexMethod.mockResolvedValue(response);
    }
};

/**
 * Create mock error for Apex
 * @param {string} message - Error message
 * @param {number} statusCode - HTTP status code
 */
export const createApexError = (message, statusCode = 500) => {
    const error = new Error(message);
    error.body = {
        message,
        statusCode,
        stackTrace: 'Mock stack trace'
    };
    return error;
};

/**
 * Mock drag and drop event
 * @param {string} type - Event type (dragstart, dragover, drop)
 * @param {Object} data - Data transfer payload
 */
export const createDragEvent = (type, data = {}) => {
    const event = new Event(type, { bubbles: true, cancelable: true });
    event.dataTransfer = {
        data: {},
        setData: function(key, value) {
            this.data[key] = value;
        },
        getData: function(key) {
            return this.data[key];
        },
        clearData: function() {
            this.data = {};
        },
        ...data
    };
    return event;
};

/**
 * Wait for element to exist
 * @param {Element} root - Root element
 * @param {string} selector - CSS selector
 * @param {number} timeout - Max wait time in ms
 */
export const waitForElement = async (root, selector, timeout = 1000) => {
    const start = Date.now();
    while (Date.now() - start < timeout) {
        const element = root.shadowRoot.querySelector(selector);
        if (element) {
            return element;
        }
        await waitForComponentRender(50);
    }
    throw new Error(`Element not found after ${timeout}ms: ${selector}`);
};
