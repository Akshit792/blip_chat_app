import 'dart:io';

import 'package:blip_chat_app/authentication/authentication_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCBl_tJoKIoKdWfB4aGAP90B_WxkhIy1k0",
            appId: "1:101881380013:ios:7b37c949b82b9b10ef5a24",
            messagingSenderId: "101881380013",
            projectId: "blip-chat-app-1b25b"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Inter',
        primarySwatch: Colors.blue,
      ),
      home: const AuthenticationScreen(),
    );
  }
}
