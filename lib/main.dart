import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:authpages/pages/home.dart';
import 'package:authpages/pages/login.dart';
import 'package:authpages/provider/auth_provider.dart';
import 'package:provider/provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AuthProvider(), //change AuthStatus
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Widget showScreen(context) {
    var prov = Provider.of<AuthProvider>(context);
    switch (prov.authStatus) {
      case AuthStatus.authentecating:
      case AuthStatus.unAuthenticated:
        return login();
      case AuthStatus.authenticated:
        return Home(prov.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: login(),
    );
  }
}
