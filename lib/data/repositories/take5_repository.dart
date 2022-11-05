import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/boxes.dart';
import '../datasources/local_data_source.dart';
import '../models/requests/destination_arrived_request/destination_arrived_request.dart';
import '../models/requests/step_one_complete_request/step_one_complete_request.dart';
import '../models/requests/step_two_start_request/step_two_start_request.dart';
import '../models/requests/trip_start_request/trip_start_request.dart';
import '../models/responses/trip_pending_response/trip_pending_response.dart';
import '../models/responses/trip_start_response/trip_start_response.dart';
import '../models/responses/user_login_response/user_login_response.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote_data_source.dart';
import '../../core/network/device_connectivity.dart';
import '../../core/network/network_availability.dart';

abstract class Take5Repository {
  Future<Either<Failure, UserLoginResponse>> loginUser(
      {required String mobileNo, required String password});

  Future<Either<Failure, Unit>> arrivedToDestination(
      {required DestinationArrivedRequest destinationArrivedRequest});

  Future<Either<Failure, Unit>> completeStepOne(
      {required StepOneCompleteRequest stepOneCompleteRequest});

  Future<Either<Failure, Unit>> completeStepTwo(
      {required StepOneCompleteRequest stepOneCompleteRequest});

  Future<Either<Failure, TripPendingResponse>> getPendingTrip(
      {required String userId});

  Future<Either<Failure, Unit>> startStepTwo(
      {required StepTwoStartRequest stepTwoStartRequest});

  Future<Either<Failure, TripStartResponse>> startTrip(
      {required TripStartRequest tripStartRequest});

  Either<Failure, TakeFiveSurvey?> getCachedTakeFiveSurvey();
}

class Take5RepositoryImpl extends Take5Repository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final DeviceConnectivity deviceConnectivity;
  final NetworkAvailability networkAvailability;

  Take5RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.deviceConnectivity,
    required this.networkAvailability,
  });

  @override
  Future<Either<Failure, UserLoginResponse>> loginUser(
      {required String mobileNo, required String password}) async {
    if (!await deviceConnectivity.isConnected) {
      return const Left(DeviceConnectivityFailure());
    }
    if (!await networkAvailability.isAvailable) {
      return const Left(NetworkAvailabilityFailure());
    }
    try {
      print(await networkAvailability.isAvailable);
      print(await deviceConnectivity.isConnected);
      UserLoginResponse result = await remoteDataSource.loginUser(
          mobileNo: mobileNo, password: password);
      localDataSource.cacheUser(result.data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> arrivedToDestination(
      {required DestinationArrivedRequest destinationArrivedRequest}) async {
    try {
      // ask abanoub about unit
      return Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeStepOne(
      {required StepOneCompleteRequest stepOneCompleteRequest}) async {
    try {
      // ask abanoub about unit
      return Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeStepTwo(
      {required StepOneCompleteRequest stepOneCompleteRequest}) async {
    try {
      // ask abanoub about unit
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TripPendingResponse>> getPendingTrip(
      {required String userId}) async {
    try {
      TripPendingResponse result =
          await remoteDataSource.getPendingTrip(userId: userId);
      localDataSource.cacheTrip(result.data); //missed
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> startStepTwo(
      {required StepTwoStartRequest stepTwoStartRequest}) async {
    try {
      return Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TripStartResponse>> startTrip(
      {required TripStartRequest tripStartRequest}) async {
    try {
      TripStartResponse result =
          await remoteDataSource.startTrip(tripStartRequest: tripStartRequest);
      localDataSource.cacheTakeFiveSurvey(result.data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Either<Failure, TakeFiveSurvey?> getCachedTakeFiveSurvey() {
    try {
      TakeFiveSurvey? result = localDataSource.getCachedTakeFiveSurvey();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
//Future<Either<Failure, TripStrartResponse>>startTrip({required TripStartRequest tripStartRequest})
// @override
// Future<Either<Failure, NewsResponse>> getAllNews() async {
//   try {
//     NewsResponse result = await remoteDataSource.getAllNews();
//     return Right(result);
//   } on ServerException catch (e) {
//     return Left(ServerFailure(e.message));
//   }
// }

}
