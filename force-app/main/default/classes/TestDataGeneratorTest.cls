@isTest
public class TestDataGeneratorTest {
  @isTest
  static void testGenerateTestDataForUsers() {
    Test.startTest();
    String result = TestDataGenerator.generateTestDataForUsers();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return a result message');
  }
}
