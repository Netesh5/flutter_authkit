// ignore_for_file: use_build_context_synchronously

import 'package:example/homepage.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';

Future<Widget> wrapper(BuildContext context) async {
  final TokenService tokensService = TokenService();
  final token = await tokensService.getToken();
  if (token != null) {
    if (context.mounted) {
      return const Homepage();
    }
  }

  return const MyHomePage();
}
