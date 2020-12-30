import 'package:flutter_native_image/flutter_native_image.dart';

import 'dart:math';
import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FacePage extends StatefulWidget {
  final String entry_type;
  final String bvn;
  final String phno;
  const FacePage(
      {Key key,
      @required this.entry_type,
      @required this.bvn,
      @required this.phno})
      : super(key: key);

  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  PickedFile _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;
  double _smileProb, _rotY, _rotZ, _rightEye, _leftEye;
  var _specificTaskList;

  var taskDict = [
    [1, "Look to the Left", -40],
    [2, "Look to the Right", 40],
    [3, "Close left eye", 0.25],
    [4, "Close right eye", 0.25],
    [5, "Smile", 0.85]
  ];

  bool getStatus(var list) {
    var taskNo = list[0];
    // taskNo = 3;
    var task = list[1];
    var tresholdValue = list[2];
    switch (taskNo) {
      case 1:
        {
          if (_rotY < tresholdValue) {
            return true;
          }
          return false;
        }
      case 2:
        {
          if (_rotY > tresholdValue) {
            return true;
          }
          return false;
        }
      case 3:
        {
          if (_leftEye < tresholdValue) {
            return true;
          }
          return false;
        }
      case 4:
        {
          if (_rightEye < tresholdValue) {
            return true;
          }
          return false;
        }
      case 5:
        {
          if (_smileProb > tresholdValue) {
            return true;
          }
          return false;
        }
    }
  }

  _getImageAndDetectFaces() async {
    final picker = ImagePicker(); // HERE !!!!!!!!
    final imageFile = await picker.getImage(source: ImageSource.camera);
    var path = imageFile.path;
    setState(() {
      isLoading = true;
    });
    var imageResized = await FlutterNativeImage.compressImage(path,
        quality: 100, targetWidth: 120, targetHeight: 120);

    final image1 = FirebaseVisionImage.fromFile(imageResized);
    final faceDetector =
        FirebaseVision.instance.faceDetector(FaceDetectorOptions(
      mode: FaceDetectorMode.fast,
      enableLandmarks: true,
      enableClassification: true,
    ));
    List<Face> faces = await faceDetector.processImage(image1);
    for (Face face in faces) {
      final double smileProb = face.smilingProbability;
      final double rotY = face.headEulerAngleY;
      final double rotZ = face.headEulerAngleZ;
      final double rightEye = face.rightEyeOpenProbability;
      final double leftEye = face.leftEyeOpenProbability;

      setState(() {
        _smileProb = smileProb;
        _rotY = rotY;
        _rotZ = rotZ;
        _rightEye = rightEye;
        _leftEye = leftEye;

        _imageFile = imageFile;
        _faces = faces;
        _loadImage(imageFile);
      });
    }

    if (getStatus(_specificTaskList)) {
      Navigator.pushNamed(context, "/cam");
    } else {
      Navigator.pushNamed(context, "/fail");
    }
  }

  _loadImage(PickedFile file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        _image = value;
        isLoading = false;
      }),
    );
  }

  String getRandomTask() {
    Random random = new Random();
    int randomNumber = random.nextInt(5);
    // int randomNumber = 2;
    var specificTaskList = taskDict[randomNumber];
    setState(() {
      _specificTaskList = specificTaskList;
    });
    return specificTaskList[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (_imageFile == null)
              ? Center(child: Text("${getRandomTask()}"))
              : Center(
                  child: Column(children: [
                    FittedBox(
                      child: SizedBox(
                        width: _image.width.toDouble(),
                        height: _image.height.toDouble(),
                        child: CustomPaint(
                          painter: FacePainter(_image, _faces),
                        ),
                      ),
                    ),
                    Text(
                        "Smile Prob -> $_smileProb \nRotY -> $_rotY \nRotZ -> $_rotZ \nRight Eye -> $_rightEye \nLeft Eye -> $_leftEye"),
                    Text(getStatus(_specificTaskList).toString()),
                    Text(_specificTaskList[1])
                  ]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0
      ..color = Colors.blue;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}
