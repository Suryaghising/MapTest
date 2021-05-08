import 'package:geolocator/geolocator.dart';

class LocationFetcher {

  static Future<Position> determinePosition() async {
    
    bool serviceEnabled;
    LocationPermission permission;

    // check location service enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      //if permission denied
      if (permission == LocationPermission.denied) {
        //open gps location settings
        await Geolocator.openLocationSettings();
        return Future.error('Location permissions are denied');
      }
    }

    //permission denied forever
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    //permission accepted
    return await Geolocator.getCurrentPosition();
  }
}