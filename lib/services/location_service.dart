import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> requestPermissions() async {
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.always || requested == LocationPermission.whileInUse;
    }
    return status == LocationPermission.always || status == LocationPermission.whileInUse;
  }

  Future<Position> getCurrentPosition() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Stream<Position> getPositionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
