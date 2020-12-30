import 'dart:convert';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../components/loader.dart';
import '../../../screens/login_success/login_success_screen.dart';

class CameraScreen extends StatefulWidget {
  final String entry_type;
  final String bvn;
  final String phno;
  const CameraScreen(
      {Key key,
      @required this.entry_type,
      @required this.bvn,
      @required this.phno})
      : super(key: key);
  @override
  _CameraScreenState createState() => _CameraScreenState(bvn);
}

class _CameraScreenState extends State<CameraScreen> {
  String bvn;
  _CameraScreenState(this.bvn);
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Step 2"),
            ),
            backgroundColor: Colors.white,
            body: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Center(
                    child: Text(
                  "Take a picture for Face Recognition",
                  style: TextStyle(fontSize: 20),
                ))),
            floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: FloatingActionButton(
                  onPressed: () async {
                    final picker = ImagePicker(); // HERE !!!!!!!!
                    final pickedFile =
                        await picker.getImage(source: ImageSource.camera);
                    var path = pickedFile.path;

                    print(path);
                    setState(() {
                      loading = true;
                    });

                    var imageResized = await FlutterNativeImage.compressImage(
                        path,
                        quality: 100,
                        targetWidth: 120,
                        targetHeight: 120);
                    List<int> imageBytes = imageResized.readAsBytesSync();
                    var photoBase64 = base64Encode(imageBytes);
                    print(photoBase64);

                    final res = await http.post(
                      'http://52.172.149.74:5001/verify_face',
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, String>{
                        'BVN': bvn.toString(),
                        'Image': photoBase64
                      }),
                    );
                    print(res.body);
                    if (res.statusCode != 200) {
                      print("Face verify fail");
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
                  },
                  child: new Icon(Icons.camera_alt_sharp),
                  backgroundColor: Color(0xFFFF7643),
                )),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
  }
}
