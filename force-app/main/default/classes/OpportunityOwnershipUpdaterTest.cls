@isTest
private class OpportunityOwnershipUpdaterTest {
  @isTest
  static void testUpdateOpportunityOwners_noopWhenSameOwner() {
    // Create an Opportunity owned by the running user
    Opportunity opp = new Opportunity(
      Name = 'Test Opp',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );
    insert opp;

    Id uid = UserInfo.getUserId();

    Test.startTest();
    OpportunityOwnershipUpdater.updateOpportunityOwners(uid, uid);
    Test.stopTest();

    // Verify owner unchanged and record still exists
    Opportunity got = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp.Id];
    System.assertEquals(uid, got.OwnerId, 'Owner should remain the same');
  }
}
