import 'package:flutter/material.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthkitWrapper extends StatelessWidget {
  const AuthkitWrapper({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => g<LoginCubit>(),
        ),
        BlocProvider(
          create: (context) => g<LogoutCubit>(),
        ),
      ],
      child: child,
    );
  }
}
