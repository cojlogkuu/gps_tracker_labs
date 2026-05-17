import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/data/repositories/api_device_repository.dart';
import 'package:gps_tracker/core/data/repositories/device_repository.dart';
import 'package:gps_tracker/features/device/cubit/device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  final ApiDeviceRepository _api;
  final IDeviceRepository _cache;

  DeviceCubit({
    required ApiDeviceRepository api,
    required IDeviceRepository cache,
  }) : _api = api,
       _cache = cache,
       super(const DeviceInitial());

  Future<void> fetchDevices() async {
    emit(const DeviceLoading());
    try {
      final devices = await _api.fetchDevices();
      emit(DeviceLoaded(devices));
    } catch (e) {
      // Fallback to local cache if API fails (offline mode)
      try {
        final cached = await _cache.loadDevices();
        emit(DeviceError(e.toString(), cachedDevices: cached));
      } catch (_) {
        emit(DeviceError(e.toString()));
      }
    }
  }

  Future<void> createDevice(String name) async {
    // Preserve current list while loading new device
    final currentState = state;
    List<DeviceModel> currentDevices = [];
    if (currentState is DeviceLoaded) {
      currentDevices = currentState.devices;
    } else if (currentState is DeviceError) {
      currentDevices = currentState.cachedDevices;
    }

    emit(const DeviceLoading());
    try {
      await _api.createDevice(name);
      final devices = await _api.fetchDevices();
      emit(DeviceLoaded(devices));
    } catch (e) {
      emit(DeviceError(e.toString(), cachedDevices: currentDevices));
    }
  }
}
