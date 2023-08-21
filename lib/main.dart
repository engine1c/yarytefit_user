import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yarytefit/core/constants.dart';
import 'package:yarytefit/domain/user.dart';
import 'package:yarytefit/screens/landing.dart';
import 'package:yarytefit/services/auth.dart';

/// Old Widget 	Old Theme 	New Widget 	New Theme
// FlatButton 	ButtonTheme 	TextButton 	TextButtonTheme
// RaisedButton 	ButtonTheme 	ElevatedButton 	ElevatedButtonTheme
// OutlineButton 	ButtonTheme 	OutlinedButton 	OutlinedButtonTheme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  runApp(YaryteFit());
}

class YaryteFit extends StatefulWidget {
  @override
  _YaryteFitAppState createState() => _YaryteFitAppState();
}
class _YaryteFitAppState extends State<YaryteFit> {
  StreamSubscription<ProfUser> userStreamSubscription;
  Stream<ProfUser> userDataStream;

StreamSubscription<ProfUser> setUserDataStream(){
  final auth = AuthService();
  return auth.currentUser.listen((user) {
    if (user != null) {
      userDataStream = auth.getCurrentUserWithData(user);
      setState(() {
        // Возможно, здесь вам нужно что-то сделать после получения данных
      });
    } else {
      // Обработка ситуации, когда пользователь не вошел в систему
    }
  });
}


  @override
  void initState() {
    super.initState();
    userStreamSubscription = setUserDataStream();
  }

  @override
  void dispose() {
    super.dispose();
    userStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<ProfUser>.value(
      value: userDataStream,
      initialData: null,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'YaryteFit Fitness',
          theme: ThemeData(
              primaryColor: bgColorPrimary,
              textTheme: TextTheme(titleLarge: TextStyle(color: Colors.white))),
          home: LandingPage()),
    );
  }
}