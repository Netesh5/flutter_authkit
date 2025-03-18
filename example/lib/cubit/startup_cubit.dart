import 'package:example/homepage.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartupCubit extends Cubit<Widget> {
  StartupCubit() : super(const MyHomePage());

  init() async {
    final token = await g<TokenService>().getToken();
    if (token != null) {
      emit(const Homepage());
    } else {
      emit(const MyHomePage());
    }
  }
}
