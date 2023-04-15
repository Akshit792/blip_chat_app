import 'package:auth0_flutter/auth0_flutter.dart';

class Apis {
  Auth0 auth0 =
      Auth0("hasknosiit.us.auth0.com", "FJm34RXXXA5yRsRFf0E3rZsEZker4Q4E");

  Future<void> loginAction() async {
    var credentials = await auth0.webAuthentication(scheme: "hasknosiit").login(
        redirectUrl:
            'hasknosiit://hasknosiit.us.auth0.com/android/com.example.blipchatapp/callback');

    UserProfile user = credentials.user;
    print(credentials.user);
  }
  
}
