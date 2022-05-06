import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_app/my_splash_screen.dart';

List<CameraDescription> cameras = List<CameraDescription>.empty(growable: true);

Future <void> main () async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Detection App',
      home: MySplashScreen(),
    );
  }
}
