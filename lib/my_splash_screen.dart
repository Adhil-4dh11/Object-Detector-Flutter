import 'package:flutter/material.dart';
import 'package:object_detection_app/my_home_screen.dart';
import 'package:splashscreen/splashscreen.dart';

class MySplashScreen extends StatelessWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      navigateAfterSeconds: const MyHomeScreen(),
      imageBackground: Image.asset('assets/images/back.jpg').image,
      useLoader: true,
      loaderColor: Colors.pink,
      loadingText: const Text(
        'Loading Object Detection App...!',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
