import 'package:flutter/material.dart';
import '../../../components/default_button.dart';

import '../../../size_config.dart';

import '../../splash/splash_screen.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.screenHeight * 0.04),
        Image.asset(
          "assets/images/success.png",
          height: SizeConfig.screenHeight * 0.4, //40%
        ),
        SizedBox(
            width: double.infinity, height: SizeConfig.screenHeight * 0.08),
        Text(
          "Face Verification Successful!",
          style: TextStyle(
            fontSize: getProportionateScreenWidth(30),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        Spacer(),
        SizedBox(
          width: SizeConfig.screenWidth * 0.6,
          child: DefaultButton(
            text: "Back to home",
            press: () {
              // Navigator.pushNamed(context, HomeScreen.routeName);
              Navigator.pushNamed(
                context,
                SplashScreen.routeName,
              );
            },
          ),
        ),
        Spacer(),
      ],
    );
  }
}
