import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFF7643),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SpinKitChasingDots(color: Colors.white, size: 50),
            ),
            Text("   "),
            Text("VERYFYING FACE....", style: TextStyle(color: Colors.white))
          ],
        )));
  }
}
