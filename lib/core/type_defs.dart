import 'package:fpdart/fpdart.dart';

import 'package:community_classroom/core/failure.dart';

//defining a user defined datatype which return instance of either class of type error as string and completion with T
typedef FutureEither<T> = Future<Either<Failure, T>>;

typedef FutureVoid = FutureEither<void>;
