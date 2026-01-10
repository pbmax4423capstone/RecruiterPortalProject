public with sharing class ContactDuplicatePreviewJsonFormatter {
  @InvocableMethod(label='Format Duplicate Groups for Display')
  public static List<String> formatJson(List<String> inputJson) {
    List<String> output = new List<String>();
    if (inputJson == null || inputJson.isEmpty())
      return output;

    List<Object> groups = (List<Object>) JSON.deserializeUntyped(inputJson[0]);

    for (Object obj : groups) {
      Map<String, Object> grp = (Map<String, Object>) obj;
      String key = (String) grp.get('groupKey');
      List<Object> ids = (List<Object>) grp.get('contactIds');

      output.add(
        'Group Key: ' +
          key +
          '\nContacts:\n- ' +
          String.join((List<String>) ids, '\n- ')
      );
    }

    return output;
  }
}
