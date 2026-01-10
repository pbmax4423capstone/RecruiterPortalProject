@isTest
public class SimpleTestDataGeneratorTest {
  @isTest
  static void testGenerateSimpleTestData() {
    Test.startTest();
    String result = SimpleTestDataGenerator.generateSimpleTestData();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return a result message');
  }
}
