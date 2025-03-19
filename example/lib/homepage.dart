import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: BlocListener<LogoutCubit, CommonState>(
        listener: (context, state) {
          if (state is SuccessState) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          }
        },
        child: Center(
          child: Column(
            children: [
              TextButton(
                  onPressed: () async {
                    context.read<LogoutCubit>().logOut();
                  },
                  child: const Text("Log out")),
              TextButton(
                  onPressed: () async {}, child: const Text("Fetch User Info")),
            ],
          ),
        ),
      ),
    );
  }
}
