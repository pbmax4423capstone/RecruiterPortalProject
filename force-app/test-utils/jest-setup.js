/**
 * Jest Setup File
 * Global configuration and utilities for LWC Jest tests
 */

// Suppress specific console warnings in tests
const originalWarn = console.warn;
const originalError = console.error;

console.warn = (...args) => {
    const msg = args[0];
    if (
        typeof msg === 'string' &&
        (msg.includes('registerApexTestWireAdapter is deprecated') ||
         msg.includes('lwc:dynamic') ||
         msg.includes('lwc:spread'))
    ) {
        return;
    }
    originalWarn.apply(console, args);
};

console.error = (...args) => {
    const msg = args[0];
    if (
        typeof msg === 'string' &&
        msg.includes('Invalid "key" attribute')
    ) {
        return;
    }
    originalError.apply(console, args);
};

// Mock localStorage globally
global.localStorage = (() => {
    let store = {};
    return {
        getItem: (key) => store[key] || null,
        setItem: (key, value) => {
            store[key] = value.toString();
        },
        removeItem: (key) => {
            delete store[key];
        },
        clear: () => {
            store = {};
        }
    };
})();

// Mock setInterval/clearInterval for components with auto-refresh
global.flushTimers = () => {
    jest.runAllTimers();
};

// Increase timeout for slow tests
jest.setTimeout(10000);
