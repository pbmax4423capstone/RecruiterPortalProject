// Test if Elizabeth Kagele can execute getCurrentUserInfo()
Map<String, String> result = RecruiterDashboardController.getCurrentUserInfo();
System.debug('===== RESULT =====');
System.debug('Result: ' + result);
System.debug('FirstName: ' + result.get('firstName'));
System.debug('Name: ' + result.get('name'));
System.debug('Email: ' + result.get('email'));
System.debug('UserType: ' + result.get('userType'));
System.debug('==================');
