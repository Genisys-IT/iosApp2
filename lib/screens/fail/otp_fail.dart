import 'package:flutter/material.dart';
import '../../components/default_button.dart';
import '../../screens/splash/splash_screen.dart';

import '../../size_config.dart';

class OtpFailureScreen extends StatelessWidget {
  static String routeName = "/otp_failure";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: SizedBox(),
          title: Text(""),
        ),
        body: Column(
          children: [
            SizedBox(height: SizeConfig.screenHeight * 0.04),
            Image.asset(
              "assets/images/failure.svg",
              height: SizeConfig.screenHeight * 0.4, //40%
            ),
            SizedBox(
                width: double.infinity, height: SizeConfig.screenHeight * 0.08),
            Text(
              "Failed to Verify OTP",
              style: TextStyle(
                fontSize: getProportionateScreenWidth(30),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Spacer(),
            SizedBox(
              width: SizeConfig.screenWidth * 0.6,
              child: DefaultButton(
                text: "Back to home",
                press: () {
                  Navigator.pushNamed(
                    context,
                    SplashScreen.routeName,
                  );
                },
              ),
            ),
            Spacer(),
          ],
        ));
  }
}
