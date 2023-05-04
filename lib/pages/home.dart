import 'package:authpages/pages/principale.dart';
import 'package:authpages/pages/slogan_animation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:authpages/provider/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'logo_animation.dart';

class Home extends StatelessWidget {
  User? user;
  late final CameraDescription firstCamera;

  Home(this.user) {
    getFirstCamera();
  }
  Future<void> getFirstCamera() async {
    final cameras = await availableCameras();
    firstCamera = cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                color: Color.fromARGB(214, 7, 1, 27),
                onPressed: () {
                  prov.logout();

                  prov.logout();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => login()));
                },
              )
            ],
          ),
          body: Column(
            children: [
              Container(child: Logo()),
              Container(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TypeWrite(
                    textScaleFactor: 1,
                    seconds: 5,
                    word: 'Your personal \n magnetic field',
                    style: GoogleFonts.spaceMono(
                      letterSpacing: 1.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 28.0,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                      child: FractionallySizedBox(
                        alignment: Alignment.center,
                        widthFactor: 1.0,
                        child: Builder(
                          builder: (context) => ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TakePictureScreen(
                                            camera: firstCamera,
                                          )));
                            },
                            child: Text('get started',
                                style: TextStyle(fontSize: 25)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
