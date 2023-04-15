import 'package:blip_chat_app/authentication/apis.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:flutter/material.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SizedBox(
      height: screenHeight,
      child: Column(
        children: [
          _buildAuthScreenImage(screenHeight),
          _buildLogoTextAndLoginButton()
        ],
      ),
    ));
  }

  Widget _buildAuthScreenImage(dynamic screenHeight) {
    return Container(
      height: screenHeight * 0.5,
      color: const Color.fromRGBO(255, 203, 65, 1),
      alignment: Alignment.bottomCenter,
      child: Image.asset(Constants.personImagePlaceHolder),
    );
  }

  Widget _buildLogoTextAndLoginButton() {
    return Expanded(
        child: Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text(
            'Stay connected with your friends and family',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Image.asset(Constants.securityCheckPlaceHolder),
              const SizedBox(
                width: 15,
              ),
              const Text(
                'Secure, private messaging',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          MaterialButton(
            color: Colors.white,
            minWidth: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: Apis().loginAction,
            child: const Text(
              'SignIn/SignUp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    ));
  }
}
