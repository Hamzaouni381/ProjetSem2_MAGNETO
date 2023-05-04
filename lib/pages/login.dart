import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:authpages/pages/register.dart';
import 'package:authpages/provider/auth_provider.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  late final CameraDescription camera;
  String? _email, _password;
  var loginKey = GlobalKey<ScaffoldState>();
  bool oobscureText = true;
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<AuthProvider>(context);
    return Scaffold(
        key: loginKey,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  "We're always here, waiting for you!",
                  style: TextStyle(
                    color: Color.fromARGB(255, 4, 38, 99),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      hintText: "Enter your email",
                    ),
                    onChanged: (value) {
                      setState(() {
                        this._email = value;
                      });
                    }),
                SizedBox(height: 10.0),
                TextFormField(
                  obscureText: oobscureText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        oobscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          oobscureText = !oobscureText;
                        });
                      },
                    ),
                    hintText: "Enter your password",
                  ),
                  onChanged: (value) {
                    setState(() {
                      this._password = value;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 4, 38, 99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      if (this._email == null) {
                        loginKey.currentState!.showBottomSheet(
                            (context) => Text('Enter your email please !'));
                      }
                      if (this._password == null && this._email != null) {
                        loginKey.currentState!.showBottomSheet(
                            (context) => Text('Enter your password please !'));
                      }
                      if (this._password != null && this._email == null) {
                        loginKey.currentState!.showBottomSheet(
                            (context) => Text('Enter your email please !'));
                      }
                      if (!await prov.login(_email!, _password!)) {
                        loginKey.currentState!.showBottomSheet(
                            (context) => Text(prov.errorMessage!));
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(prov.user),
                          ),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        prov.authStatus == AuthStatus.authentecating
                            ? CircularProgressIndicator()
                            : Text('Login'),
                      ],
                    )
                    ),
                TextButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 237, 237, 237),
                    shape: RoundedRectangleBorder(
                      // Set the button's border shape
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => register(),
                      ),
                    );
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        )
        );
  }
}
