import 'package:equatable/equatable.dart';

sealed class CommonState extends Equatable {}

class InitialState extends CommonState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends CommonState {
  final bool showLoading;
  LoadingState({this.showLoading = true});
  @override
  List<Object?> get props => [showLoading];
}

class ErrorState extends CommonState {
  final String message;
  final bool isWarning;

  ErrorState({required this.message, this.isWarning = false});

  @override
  List<String> get props => [message];
}

class SuccessState<Type> extends CommonState {
  final Type data;

  SuccessState({required this.data});

  @override
  List<Type> get props => [data];
}

class CommonNoDataState extends CommonState {
  CommonNoDataState();

  @override
  List<Object?> get props => [];
}
