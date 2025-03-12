import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_authkit/src/core/services/dio.dart';

void main() async {
  DioClient().init(
    baseUrl: 'https://dummyjson.com/auth',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final FlutterAuthKit _authKit = FlutterAuthKit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter AuthKit'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                _authKit.login(
                    loginEndpoint: "login",
                    params: {
                      "username": "emilys",
                      "password": "emilyspass",
                    },
                    fromJson: (json) => json);
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
