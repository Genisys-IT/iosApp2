import 'dart:convert';
import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import '../../../../components/loader.dart';
import '../../../../screens/login_success/login_success_screen.dart';

import 'detector_painters.dart';
import 'utils.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as imglib;
// import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';

class Cam3 extends StatefulWidget {
  final String entry_type;
  final String bvn;
  final String phno;
  const Cam3(
      {Key key,
      @required this.entry_type,
      @required this.bvn,
      @required this.phno})
      : super(key: key);
  @override
  Cam3State createState() => Cam3State(bvn);
}

class Cam3State extends State<Cam3> {
  String bvn;
  Cam3State(this.bvn);
  bool _loading;
  String _isSmiling = "";
  String _isBlinking = "";
  String _ryanAppBarText = "No Face Detected";
  File jsonFile;
  dynamic _scanResults;
  CameraController _camera;
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  dynamic data = {};
  double threshold = 1.0;
  Directory tempDir;
  List e1;
  bool _faceFound = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();
  }

  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);

    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera =
        CameraController(description, ResolutionPreset.low, enableAudio: false);
    await _camera.initialize();
    await Future.delayed(Duration(milliseconds: 500));
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);
    if (jsonFile.existsSync()) data = json.decode(jsonFile.readAsStringSync());

    _camera.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();
        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) async {
            if (result.length == 0) {
              _faceFound = false;
              _ryanAppBarText = "No Face Found";
            } else {
              _faceFound = true;
              _ryanAppBarText = "Blink to Take a Picture";
            }
            Face _face;

            for (_face in result) {
              res = "Face Detected";
              finalResult.add(res, _face);

              // if (_face.smilingProbability > 0.70) {
              //   _isSmiling = _isSmiling.toString() + "1";
              // } else {
              //   _isSmiling = _isSmiling.toString() + "0";
              // }

              // if (_isSmiling.length > 100) {
              //   setState(() {
              //     _isSmiling = _isSmiling.substring(30);
              //   });
              // }

              // if (isSmileThresholdOscilate(_isSmiling)) {
              //   var path = (await getApplicationDocumentsDirectory()).path;
              //   var path2 = path + '/ryan.jpg';
              //   await _camera.takePicture(path2);
              //   var imageResized = await FlutterNativeImage.compressImage(path2,
              //       quality: 100, targetWidth: 100, targetHeight: 100);

              //   await _camera.stopImageStream();
              //   await _camera.dispose();

              //   List<int> imageBytes = imageResized.readAsBytesSync();
              //   var photoBase64 = base64Encode(imageBytes);

              //   setState(() {
              //     _loading = true;
              //   });

              //   final res = await http.post(
              //     'http://52.172.149.74:5001/verify_face',
              //     headers: <String, String>{
              //       'Content-Type': 'application/json; charset=UTF-8',
              //     },
              //     body: jsonEncode(<String, String>{
              //       'BVN': bvn.toString(),
              //       'Image': photoBase64.toString()
              //     }),
              //   );
              //   print(res.body);

              //   if (res.statusCode != 200) {
              //     print("Face verify fail + 500");
              //     Navigator.pushNamed(context, '/sign_in_failure');
              //   } else if (json.decode(res.body)["message"] ==
              //       "Face successfully verified.") {
              //     Navigator.pushNamed(
              //       context,
              //       LoginSuccessScreen.routeName,
              //     );
              //   } else {
              //     print("Face verify fail");
              //     Navigator.pushNamed(context, '/sign_in_failure');
              //   }

              //   setState(() {
              //     _isSmiling = "";
              //     _camera = null;
              //     _ryanAppBarText = "You Smiled!!";
              //   });
              // }

              if (_face.leftEyeOpenProbability < 0.05 &&
                  _face.rightEyeOpenProbability < 0.05) {
                _isBlinking = _isBlinking.toString() + "0";
              } else {
                _isBlinking = _isBlinking.toString() + "1";
              }

              if (_isBlinking.length > 100) {
                setState(() {
                  _isBlinking = _isBlinking.substring(20);
                });
              }

              if (isBlinkThresholdOscilate(_isBlinking)) {
                var path = (await getApplicationDocumentsDirectory()).path;
                var path2 = path + '/ryan.jpg';

                await _camera.takePicture(path2);

                var imageResized = await FlutterNativeImage.compressImage(path2,
                    quality: 100, targetWidth: 100, targetHeight: 100);

                await _camera.stopImageStream();
                await _camera.dispose();
                List<int> imageBytes = imageResized.readAsBytesSync();

                var photoBase64 = base64Encode(imageBytes);

                setState(() {
                  _loading = true;
                });

                final res = await http.post(
                  'http://52.172.149.74:5001/verify_face',
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'BVN': bvn.toString(),
                    'Image': photoBase64.toString()
                  }),
                );
                print(res.body);

                if (res.statusCode != 200) {
                  print("Face verify fail + 500");
                  Navigator.pushNamed(context, '/sign_in_failure');
                } else if (json.decode(res.body)["message"] ==
                    "Face successfully verified.") {
                  Navigator.pushNamed(
                    context,
                    LoginSuccessScreen.routeName,
                  );
                } else {
                  print("Face verify fail");
                  Navigator.pushNamed(context, '/sign_in_failure');
                }
                setState(() {
                  _isBlinking = "";
                  _camera = null;
                  _ryanAppBarText = "You Blinked!!";
                });
              }
            }
            print(_isSmiling);
            print((DateTime.now().millisecondsSinceEpoch) / 1000);
            setState(() {
              _scanResults = finalResult;
            });

            _isDetecting = false;
          },
        ).catchError(
          (_) {
            print(_);
            print("ERROR!!!!!!");

            _isDetecting = false;
          },
        );
      }
    });
  }

  bool isSmileThresholdOscilate(String str) {
    RegExp exp = new RegExp(r"01");
    Iterable<Match> matches = exp.allMatches(str);
    if (matches.length > 0) {
      return (true);
    }
    return (false);
  }

  bool isBlinkThresholdOscilate(String str) {
    RegExp exp = new RegExp(r"10+1");

    Iterable<Match> matches = exp.allMatches(str);
    if (matches.length > 0) {
      return (true);
    }
    return (false);
  }

  HandleDetection _getDetectionMethod() {
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        minFaceSize: 1.0,
        mode: FaceDetectorMode.accurate,
      ),
    );
    return faceDetector.processImage;
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    if (_camera == null || !_camera.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _loading == true
          ? null
          : AppBar(
              title: Text("$_ryanAppBarText"),
            ),
      body: _loading == true ? Loading() : _buildImage(),
    );
  }
}
