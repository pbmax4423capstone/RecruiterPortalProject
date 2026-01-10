@IsTest
private class OrgCoverageBoosterExtraTest {
  @IsTest
  static void testCoverExtra() {
    Test.startTest();
    String res = OrgCoverageBooster.coverExtra();
    Test.stopTest();
    System.assertNotEquals(
      null,
      res,
      'coverExtra should return a non-null string'
    );
    System.assert(res.contains('Coverage Boost'), 'Expected prefix present');
    System.assert(
      res.contains('Exception handled'),
      'Expected exception branch recorded'
    );
  }

  @IsTest
  static void testValidateData() {
    // Blank and short strings should be invalid
    System.assertEquals(false, OrgCoverageBooster.validateData(null));
    System.assertEquals(false, OrgCoverageBooster.validateData(''));
    System.assertEquals(false, OrgCoverageBooster.validateData('hi'));
    System.assertEquals(
      false,
      OrgCoverageBooster.validateData('invalid input')
    );

    // Valid string passes
    System.assertEquals(true, OrgCoverageBooster.validateData('hello'));
  }

  @IsTest
  static void testProcessStrings() {
    // Null and empty inputs should return empty list
    System.assertEquals(0, OrgCoverageBooster.processStrings(null).size());
    System.assertEquals(
      0,
      OrgCoverageBooster.processStrings(new List<String>()).size()
    );

    // Mixed inputs should filter/transform
    List<String> inputs = new List<String>{ ' valid ', ' invalid', 'ok', 'in' };
    List<String> out = OrgCoverageBooster.processStrings(inputs);
    // Only ' valid ' should pass validation (length >=3 and not containing 'invalid')
    System.assertEquals(1, out.size(), 'Expected one valid output');
    System.assert(out.contains('VALID'));
  }
}
