import 'package:example/cubit/startup_cubit.dart';
import 'package:example/homepage.dart';
import 'package:example/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  injectDependecies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => g<LoginCubit>(),
        ),
        BlocProvider(
          create: (context) => StartupCubit()..init(),
        ),
        BlocProvider(
          create: (context) => g<LogoutCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<StartupCubit, Widget>(builder: (context, state) {
          return state;
        }),
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
      body: BlocListener<LoginCubit, CommonState>(
        listener: (context, state) {
          if (state is SuccessState<UserModel>) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const Homepage(),
              ),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<LoginCubit>().login(
                      loginEndpoint: "login",
                      params: {
                        "username": "emilys",
                        "password": "emilyspass",
                        "expiresInMins": 1,
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
      ),
    );
  }
}
