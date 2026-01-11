const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
    
    // Test path patterns
    testMatch: [
        '**/force-app/main/default/lwc/**/__tests__/**/*.test.js'
    ],
    
    // Coverage thresholds
    coverageThresholds: {
        global: {
            branches: 60,
            functions: 60,
            lines: 60,
            statements: 60
        }
    },
    
    // Coverage collection
    collectCoverageFrom: [
        'force-app/main/default/lwc/**/*.js',
        '!force-app/main/default/lwc/**/__tests__/**',
        '!force-app/main/default/lwc/**/__mocks__/**'
    ],
    
    // Setup files
    setupFilesAfterEnv: ['<rootDir>/force-app/test-utils/jest-setup.js'],
    
    // Module name mapper for custom paths
    moduleNameMapper: {
        ...jestConfig.moduleNameMapper,
        '^test-utils/(.*)$': '<rootDir>/force-app/test-utils/$1'
    },
    
    // Test environment
    testEnvironment: 'jsdom',
    
    // Transform configuration
    transformIgnorePatterns: [
        'node_modules/(?!(@salesforce)/)'
    ],
    
    // Timing settings
    testTimeout: 10000,
    
    // Clear mocks automatically
    clearMocks: true,
    restoreMocks: true,
    resetMocks: false
};
