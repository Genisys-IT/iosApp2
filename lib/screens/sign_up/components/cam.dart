import 'dart:convert';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../screens/sign_up_success/sign_up_success_screen.dart';

import 'loading.dart';

class UploadPictureScreen extends StatefulWidget {
  final String entry_type;
  final String bvn;
  final String phno;
  const UploadPictureScreen(
      {Key key,
      @required this.entry_type,
      @required this.bvn,
      @required this.phno})
      : super(key: key);
  @override
  _UploadPictureScreenState createState() =>
      _UploadPictureScreenState(bvn, entry_type, phno);
}

class _UploadPictureScreenState extends State<UploadPictureScreen> {
  String bvn;
  String firstName;
  String phno;
  _UploadPictureScreenState(this.bvn, this.firstName, this.phno);
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
                  "Upload your Picture",
                  style: TextStyle(fontSize: 20),
                ))),
            floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: FloatingActionButton(
                  onPressed: () async {
                    final picker = ImagePicker(); // HERE !!!!!!!!
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    var path = pickedFile.path;
                    var imageResized = await FlutterNativeImage.compressImage(
                        path,
                        quality: 100,
                        targetWidth: 120,
                        targetHeight: 120);
                    List<int> bytes = imageResized.readAsBytesSync();

                    String img64 = base64Encode(bytes);

                    setState(() {
                      loading = true;
                    });

                    final res = await http.post(
                      'http://52.172.149.74:5001/register',
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, String>{
                        'BVN': bvn.toString(),
                        'Name': firstName.toString(),
                        "Phone_Number": phno,
                        "Image": img64
                      }),
                    );

                    Navigator.pushNamed(
                      context,
                      SignUpSuccessScreen.routeName,
                    );
                  },
                  child: new Icon(Icons.camera_alt_sharp),
                  backgroundColor: Color(0xFFFF7643),
                )),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
  }
}
