import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import '../../../main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? imgCamera;

  loadModel() async {
    await Tflite.loadModel(
      model: 'lib/app/models/mobilenet_v1_1.0_224.tflite',
      labels: 'lib/app/models/mobilenet_v1_1.0_224.txt',
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
        result += '${(response['label'] as String).toUpperCase()} - Label\n${(response['confidence']
            as double).toStringAsFixed(1)} - Confidence';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(7, 54, 51, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              "assets/images/lightning_icon.png",
              height: 36,
              width: 20,
            ),
            const Spacer(),
            const Text(
              "Object Detector",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
            const Spacer(),
            Image.asset(
              "assets/images/lightning_icon.png",
              height: 36,
              width: 20,
            ),
            const Spacer(),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromRGBO(7, 54, 51, 1),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_image.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              TextButton(
                onPressed: () {
                  initCamera();
                },
                child: SizedBox(
                  height: 550,
                  width: double.infinity,
                  child: imgCamera == null ? const SizedBox(
                    height: 550,
                    width: double.infinity,
                    child: Icon(
                      Icons.photo_camera_front,
                      color: Color.fromRGBO(0, 238, 10, 1),
                      size: 40,
                    ),
                  )
                      : AspectRatio(
                    aspectRatio: cameraController!.value.aspectRatio,
                    child: CameraPreview(cameraController!),
                  ),
                ),
              ),
              const Spacer(),
              AppBar(
                toolbarHeight: 100,
                backgroundColor: const Color.fromRGBO(7, 54, 51, 1),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Image.asset(
                      "assets/images/lightning_icon.png",
                      height: 36,
                      width: 20,
                    ),
                    const Spacer(),
                    Text(
                      result,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      "assets/images/lightning_icon.png",
                      height: 36,
                      width: 20,
                    ),
                    const Spacer(),
                  ],
                ),
                centerTitle: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
