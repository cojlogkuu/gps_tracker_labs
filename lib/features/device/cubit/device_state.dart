import 'package:equatable/equatable.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {
  const DeviceInitial();
}

class DeviceLoading extends DeviceState {
  const DeviceLoading();
}

class DeviceLoaded extends DeviceState {
  final List<DeviceModel> devices;

  const DeviceLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DeviceError extends DeviceState {
  final String message;
  final List<DeviceModel> cachedDevices;

  const DeviceError(this.message, {this.cachedDevices = const []});

  @override
  List<Object?> get props => [message, cachedDevices];
}
