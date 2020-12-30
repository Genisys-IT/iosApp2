import 'package:flutter/material.dart';
import '../../size_config.dart';

import 'components/body.dart';

class OtpScreen extends StatelessWidget {
  static String routeName = "/otp";

  final String entry_type;
  final String bvn;
  final String phno;

  const OtpScreen(
      {Key key,
      @required this.entry_type,
      @required this.bvn,
      @required this.phno})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Step 1"),
      ),
      body: Body(entry_type: entry_type, bvn: bvn, phno: phno),
    );
  }
}
