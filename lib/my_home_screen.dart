import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_app/main.dart';
import 'package:tflite/tflite.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({Key? key}) : super(key: key);

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {

  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? imgCamera;

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/models/mobilenet_v1_1.0_224.tflite',
        labels: 'assets/models/mobilenet_v1_1.0_224.txt',
    );
  }

  initCamera() {
    cameraController = CameraController(cameras [0], ResolutionPreset.ultraHigh);
    cameraController?.initialize().
    then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController?.
        startImageStream((imageFromStream) => {
          if (!isWorking) {
            isWorking = true,
            imgCamera = imageFromStream,
            runModelOnStreamFrames(),

          }
        });
      });
    });
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognition = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
      }).toList(),
    imageHeight: imgCamera!.height,
    imageWidth: imgCamera!.width,
    imageMean: 127.5,
    imageStd: 127.5,
    rotation: 90,
    numResults: 1,
    threshold: 0.1,
    asynch: true,
      );

      result = '';
      recognition?.forEach((response) {
        result += response['label']
            + ''
            + (response['confidence']
            as double).toStringAsFixed(2)
            + '\n\n';
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.indigo,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Object Detection App', style: TextStyle(
              color: Colors.indigo,
            ),),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/jarvis.jpg'),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        color: Colors.black,
                        height: 320,
                        width: 360,
                        child: Image.asset('assets/images/camera.jpg'),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          initCamera();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 35),
                          height: 270,
                          width: 360,
                          child: imgCamera == null ? Container(
                            height: 270,
                            width: 360,
                            child: const Icon(
                              Icons.photo_camera_front,
                              color: Colors.blueAccent,
                              size: 40,
                            ),
                          )
                              : AspectRatio(
                            aspectRatio: cameraController!.value.aspectRatio,
                            child: CameraPreview(cameraController!),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: SingleChildScrollView(
                          child: Text(
                            result,
                            style: const TextStyle(
                              backgroundColor: Colors.black87,
                              fontSize: 30.0,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
