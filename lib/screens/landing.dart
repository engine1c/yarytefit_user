import 'package:flutter/material.dart';
import 'package:yarytefit/domain/user.dart';
import 'package:yarytefit/screens/auth.dart';
import 'package:yarytefit/screens/home.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfUser user = Provider.of<ProfUser>(context);
    final bool isLoggedIn = user != null;

    return isLoggedIn
      ? HomePage()
      : AuthorizationPage();
  }
}