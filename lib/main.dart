import 'dart:io';
import 'package:blip_chat_app/authentication/bloc/authentication_bloc.dart';
import 'package:blip_chat_app/channels/bloc/channels_bloc.dart';
import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/common/models/context_holder.dart';
import 'package:blip_chat_app/common/models/logger.dart';
import 'package:blip_chat_app/common/repository/auth_repository.dart';
import 'package:blip_chat_app/common/repository/chat_repository.dart';
import 'package:blip_chat_app/home/bloc/home_screen_bloc.dart';
import 'package:blip_chat_app/splash/bloc/splash_bloc.dart';
import 'package:blip_chat_app/splash/splash_screen.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  tz.initializeTimeZones();

  WidgetsFlutterBinding.ensureInitialized();

  await getAvailableCameras();

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

  runApp(MultiRepositoryProvider(providers: [
    RepositoryProvider<AuthRepository>(create: (context) => AuthRepository()),
    RepositoryProvider<ChatRepository>(create: (context) => ChatRepository()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => AuthenticationBloc(),
        ),
        BlocProvider<SplashBloc>(
          create: (BuildContext context) => SplashBloc(),
        ),
        BlocProvider<HomeScreenBloc>(
          create: (BuildContext context) => HomeScreenBloc(),
        ),
        BlocProvider<ChannelsBloc>(
          create: (BuildContext context) => ChannelsBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          primarySwatch: Colors.blue,
        ),
        navigatorKey: ContextHolder.key,
        builder: (context, widget) {
          return StreamChatCore(
            client: RepositoryProvider.of<ChatRepository>(context).client,
            child: widget!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}

Future<void> getAvailableCameras() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e, s) {
    LogPrint.error(
      error: e,
      errorMsg: 'Available Cameras',
      stackTrace: s,
    );
  }
}
