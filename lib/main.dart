import 'package:flutter/material.dart';
import 'package:myapp/Screens/WelcomeScreen.dart';
import 'package:myapp/Screens/HomeMainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  WidgetsFlutterBinding .ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Book Sharing',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: (user==null)?WelcomeScreen():MyHomeMain()
    );
  }
}
