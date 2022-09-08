import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

// General failure
class ServerException extends Failure {}

class CacheException extends Failure {}
