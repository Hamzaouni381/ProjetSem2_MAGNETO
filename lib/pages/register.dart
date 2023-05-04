import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:authpages/pages/home.dart';
import '../provider/auth_provider.dart';
import 'package:provider/provider.dart';

class register extends StatefulWidget {
  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  String? _name, _email, _password;
  String get fname => _name!;

  var loginKey = GlobalKey<ScaffoldState>();
  FirebaseAuth instance = FirebaseAuth.instance;
  bool ooobscureText = true;
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: loginKey,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'User Registration',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  hintText: "Enter your name",
                ),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                }),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  hintText: "Enter your email",
                ),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                }),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    ooobscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      ooobscureText = !ooobscureText;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
                hintText: "Enter your password",
              ),
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              obscureText: ooobscureText,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 4, 38, 99),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                if (_name == null) {
                  loginKey.currentState!.showBottomSheet(
                      (context) => Text('Enter your name please !'));
                } else if (_email == null) {
                  loginKey.currentState!.showBottomSheet(
                      (context) => const Text('Enter your email please !'));
                } else if (_password == null) {
                  loginKey.currentState!.showBottomSheet(
                      (context) => const Text('Enter your password please !'));
                }

                try {
                  UserCredential credential =
                      await instance.createUserWithEmailAndPassword(
                          email: _email!, password: _password!);

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(prov.user),
                      ));
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    loginKey.currentState!.showBottomSheet(
                        (context) => const Text('Weak password'));
                  } else if (e.code == 'email-already-in-use') {
                    loginKey.currentState!.showBottomSheet(
                        (context) => const Text("Email already in use"));
                  } else if (e.code == 'invalid-email') {
                    loginKey.currentState!.showBottomSheet(
                        (context) => const Text('Your email is invalid'));
                  }
                }
              },
              child: const Text("Register"),
            ),
          ],
        ),
      )),
    );
  }
}
