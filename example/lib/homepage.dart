import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  final FlutterAuthKit _authKit = FlutterAuthKit();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: Center(
        child: TextButton(
            onPressed: () async {
              await _authKit.logout(logoutEndpoint: "");
            },
            child: const Text("Log out")),
      ),
    );
  }
}
