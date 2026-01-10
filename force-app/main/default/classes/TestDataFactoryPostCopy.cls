/**
 * Sandbox Post-Copy Script - Automatically generates test data after sandbox creation
 *
 * This class runs automatically when a sandbox is created or refreshed.
 * It generates comprehensive test data using TestDataFactory:
 * - 500 Candidates with linked Contacts
 * - 800 Interviews (distributed across types)
 * - 300 ALC Records
 * - 1000 Opportunities
 *
 * IMPORTANT: Before creating the sandbox, manually deactivate the flow:
 *   Setup → Flows → Candidate_Stage_Email_Automation → Deactivate
 * This prevents email automation errors during test data creation.
 *
 * Usage:
 * 1. Deactivate Candidate_Stage_Email_Automation flow in production (Setup → Flows)
 * 2. Create sandbox in Setup → Sandboxes
 * 3. Specify "TestDataFactoryPostCopy" as the Apex class
 * 4. Reactivate the flow in production if needed
 *
 * @author Patrick Baker
 * @date January 7, 2026
 */
public class TestDataFactoryPostCopy implements SandboxPostCopy {
  /**
   * Executes automatically after sandbox creation/refresh
   * @param context Provides sandbox name and organization ID
   */
  public void runApexClass(SandboxContext context) {
    System.debug('========================================');
    System.debug('=== SANDBOX POST-COPY STARTING ===');
    System.debug('========================================');
    System.debug('Sandbox Name: ' + context.sandboxName());
    System.debug('Organization ID: ' + context.organizationId());
    System.debug('Timestamp: ' + System.now());

    try {
      // Step 1: Check for active flows that may cause issues
      checkFlowStatus();

      // Step 2: Generate test data
      generateTestData();

      System.debug('========================================');
      System.debug('=== SANDBOX POST-COPY COMPLETED ===');
      System.debug('========================================');
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        '========================================'
      );
      System.debug(LoggingLevel.ERROR, '=== SANDBOX POST-COPY ERROR ===');
      System.debug(
        LoggingLevel.ERROR,
        '========================================'
      );
      System.debug(LoggingLevel.ERROR, 'Error Type: ' + e.getTypeName());
      System.debug(LoggingLevel.ERROR, 'Error Message: ' + e.getMessage());
      System.debug(
        LoggingLevel.ERROR,
        'Stack Trace: ' + e.getStackTraceString()
      );
      System.debug(LoggingLevel.ERROR, 'Line Number: ' + e.getLineNumber());

      // Don't throw - allow sandbox creation to succeed even if post-copy fails
      // The sandbox will be usable, just without automated test data
    }
  }

  /**
   * Checks if email automation flows are active and logs warnings
   * Note: Flows cannot be deactivated programmatically from SandboxPostCopy
   * Manual deactivation in production is required before creating sandbox
   */
  private void checkFlowStatus() {
    System.debug('--- Checking Email Automation Flow Status ---');

    try {
      List<FlowDefinitionView> flows = [
        SELECT ApiName, ActiveVersionId, LatestVersionId
        FROM FlowDefinitionView
        WHERE ApiName = 'Candidate_Stage_Email_Automation'
        LIMIT 1
      ];

      if (flows.isEmpty()) {
        System.debug(
          '✓ Flow Candidate_Stage_Email_Automation not found - no email automation issues expected'
        );
        return;
      }

      FlowDefinitionView flow = flows[0];

      if (flow.ActiveVersionId == null) {
        System.debug(
          '✓ Flow is inactive - test data generation will proceed without email issues'
        );
      } else {
        System.debug(
          LoggingLevel.WARN,
          '⚠ WARNING: Flow Candidate_Stage_Email_Automation is ACTIVE'
        );
        System.debug(
          LoggingLevel.WARN,
          '⚠ Email automation may fail during test data creation'
        );
        System.debug(
          LoggingLevel.WARN,
          '⚠ Recommend deactivating flow: Setup → Flows → Candidate_Stage_Email_Automation'
        );
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.WARN,
        '⚠ Could not check flow status: ' + e.getMessage()
      );
    }
  }

  /**
   * Generates comprehensive test data using TestDataFactory
   * Creates 500 Candidates, 800 Interviews, 300 ALCs, 1000 Opportunities
   */
  private void generateTestData() {
    System.debug('--- Generating Test Data ---');

    try {
      // Call the comprehensive test data factory
      TestDataFactory.generateCompleteTestData();

      // Query and log results
      Integer candidateCount = [SELECT COUNT() FROM Candidate__c];
      Integer contactCount = [
        SELECT COUNT()
        FROM Contact
        WHERE Email LIKE '%testfactory%'
      ];
      Integer interviewCount = [SELECT COUNT() FROM Interview__c];
      Integer alcCount = [SELECT COUNT() FROM ALC__c];
      Integer opportunityCount = [
        SELECT COUNT()
        FROM Opportunity
        WHERE Name LIKE '%TestFactory%'
      ];

      System.debug('✓ Test data generation completed successfully');
      System.debug('  - Candidates created: ' + candidateCount);
      System.debug('  - Contacts created: ' + contactCount);
      System.debug('  - Interviews created: ' + interviewCount);
      System.debug('  - ALCs created: ' + alcCount);
      System.debug('  - Opportunities created: ' + opportunityCount);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        '✗ Error generating test data: ' + e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw e; // Re-throw to be caught by outer try-catch
    }
  }
}
