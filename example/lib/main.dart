import 'package:example/homepage.dart';
import 'package:example/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  injectDependecies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => g<LoginCubit>(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocListener<LoginCubit, CommonState>(
          listener: (context, state) {
            if (state is SuccessState<UserModel>) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Homepage(),
                ),
              );
            }
          },
          child: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
              onPressed: () async {
                context.read<LoginCubit>().login(
                    "login",
                    {
                      "username": "emilys",
                      "password": "emilyspass",
                    },
                    (json) => UserModel.fromMap(json));
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
