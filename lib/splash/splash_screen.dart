import 'package:blip_chat_app/common/constants.dart';
import 'package:blip_chat_app/splash/bloc/splash_bloc.dart';
import 'package:blip_chat_app/splash/bloc/splash_event.dart';
import 'package:blip_chat_app/splash/bloc/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 203, 65, 1),
              borderRadius: BorderRadius.circular(15)),
          child: const Text(
            ('Blip'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 60,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is InitialSplashState) {
            BlocProvider.of<SplashBloc>(context)
                .add(CheckAuthStatusSplashEvent(context: context));
          }

          return state is AuthStatusLoadingSplashState
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 50.0),
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorConstants.black),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
