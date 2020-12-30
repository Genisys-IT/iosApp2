import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'screens/fail/otp_fail.dart';
import 'screens/fail/sign_in_fail.dart';

import 'screens/login_success/login_success_screen.dart';
import 'screens/otp/components/cam3/main.dart';
import 'screens/otp/components/otp_form.dart';
import 'screens/otp/otp_screen.dart';
import 'screens/sign_in/sign_in_screen.dart';
import 'screens/sign_up/components/cam.dart';
import 'screens/sign_up_success/sign_up_success_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/otp/components/cam.dart';
import 'screens/otp/components/cam2.dart';
import 'screens/sign_up/sign_up_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case "/splash":
        if (true) {
          return MaterialPageRoute(
            builder: (_) => SplashScreen(),
          );
        }
        return _errorRoute();

      case "/sign_in":
        if (true) {
          return MaterialPageRoute(
            builder: (_) => SignInScreen(),
          );
        }
        return _errorRoute();
      case "/login_success":
        if (true) {
          return MaterialPageRoute(
            builder: (_) => LoginSuccessScreen(),
          );
        }
        return _errorRoute();

      case "/otp_failure":
        return MaterialPageRoute(
          builder: (_) => OtpFailureScreen(),
        );
      case "/sign_in_failure":
        return MaterialPageRoute(
          builder: (_) => SignInFailureScreen(),
        );
      case "/sign_up_success":
        if (true) {
          return MaterialPageRoute(
            builder: (_) => SignUpSuccessScreen(),
          );
        }
        return _errorRoute();

      case "/sign_up":
        if (true) {
          return MaterialPageRoute(
            builder: (_) => SignUpScreen(),
          );
        }
        return _errorRoute();

      case "/otp":
        return MaterialPageRoute(builder: (_) {
          ScreenArguments argument = args;
          return OtpScreen(
              entry_type: argument.entry_type,
              bvn: argument.bvn,
              phno: argument.phno);
        });

      case "/cam":
        return MaterialPageRoute(builder: (_) {
          ScreenArguments argument = args;
          return CameraScreen(
              entry_type: argument.entry_type,
              bvn: argument.bvn,
              phno: argument.phno);
        });
      case "/cam2":
        return MaterialPageRoute(builder: (_) {
          ScreenArguments argument = args;
          return FacePage(
              entry_type: argument.entry_type,
              bvn: argument.bvn,
              phno: argument.phno);
        });
      case "/cam3":
        return MaterialPageRoute(builder: (_) {
          ScreenArguments argument = args;
          return Cam3(
              entry_type: argument.entry_type,
              bvn: argument.bvn,
              phno: argument.phno);
        });
      case "/uploadPicture":
        return MaterialPageRoute(builder: (_) {
          ScreenArguments argument = args;
          return UploadPictureScreen(
              entry_type: argument.entry_type,
              bvn: argument.bvn,
              phno: argument.phno);
        });

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('FAILED'),
        ),
        body: Center(
          child: Text('UNSUCESSFULL !!'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              (_),
              SplashScreen.routeName,
            );
          },
        ),
      );
    });
  }
}
