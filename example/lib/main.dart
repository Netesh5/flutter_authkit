import 'package:example/model/user_model.dart';
import 'package:example/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';

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
      // home: MyHomePage(),
      home: FutureBuilder(
          future: wrapper(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data!;
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
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
                _authKit.login<UserModel>(
                    loginEndpoint: "login",
                    params: {
                      "username": "emilys",
                      "password": "emilyspass",
                    },
                    fromJson: (json) => UserModel.fromMap(json));
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
