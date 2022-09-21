import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detector/app/modules/home/home.dart';

List<CameraDescription> cameras = List<CameraDescription>.empty(growable: true);

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Detector',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}
