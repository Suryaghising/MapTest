import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import './../models/location.dart';
import './../utils/image_byte_converter.dart';
import './../utils/location_fetcher.dart';

enum LocationType { PICKUP, DESTINATION }

class MapsController extends GetxController {
  LocationDTO _pickUpLocation;
  LocationDTO _destinationLocation;
  LocationDTO _lastCameraLocation;
  Set<Marker> _markers = HashSet<Marker>();
  int _markerIdCounter = 1;
  bool _isMarker = false;
  bool _cameraMoved = false;
  String _selectedLocationAddress;
  String _pickUpAddress;
  String _destinationAddress;
  Uint8List _pickUpIcon;
  Uint8List _destinationIcon;
  bool _hideButton = false;

  @override
  void onInit() {
    super.onInit();
    _setIcons();
  }

  void _setIcons() async {
    await loadIcons();
    _fetchLocation();
  }

  LocationDTO get pickUpLocation => _pickUpLocation;

  Set<Marker> get markers => _markers;

  int get markerId => _markerIdCounter;

  String get selectedLocationAddress => _selectedLocationAddress;

  bool get isMarker => _isMarker;

  bool get hideButton => _hideButton;

  String get pickUpAddress => _pickUpAddress;

  String get destinationAddress => _destinationAddress;

  LocationDTO get destinationLocation => _destinationLocation;

  LocationDTO get lastCameraLocation => _lastCameraLocation;

  bool get cameraMoved => _cameraMoved;

  void updatePickUpLocation(LocationDTO location) {
    _pickUpLocation = location;
    update();
  }

  void updateCameraStatus() {
    _cameraMoved = true;
    update();
  }

  void setPickUpAddress(String address) {
    _pickUpAddress = address;
    update();
  }

  void setDestinationAddress(String address) {
    _destinationAddress = address;
    update();
  }

  void updateLastCameraLocation(LatLng latLng) {
    final location =
        LocationDTO(latitude: latLng.latitude, longitude: latLng.longitude);
    _lastCameraLocation = location;
    update();
  }

  void setDestinationLocation() {
    _destinationLocation = _lastCameraLocation;
    update();
  }

  addDestination() {
    setDestinationLocation();
    addMarker(_destinationLocation, LocationType.DESTINATION);
  }

  void incrementMarkerId() {
    _markerIdCounter++;
    update();
  }

  void updateMarker() {
    _isMarker = !_isMarker;
    update();
  }

  void updateDestinationLocation(LocationDTO location) {
    _destinationLocation = location;
    update();
  }

  //add maker in map
  void addMarker(LocationDTO location, LocationType locationType) async {
    _markers.add(Marker(
      markerId: MarkerId('$_markerIdCounter'),
      position: LatLng(location.latitude, location.longitude),
      icon: BitmapDescriptor.fromBytes(
          locationType == LocationType.PICKUP ? _pickUpIcon : _destinationIcon),
    ));
    incrementMarkerId();

    _disableButton();
    update();
  }

  //get address from latlong coordinates
  Future<void> fetchNameFromCoordinates(
      LocationDTO latLng, LocationType locationType) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    for (Placemark placemark in placemarks) {
      String address =
          '${placemark.name} ${placemark.subLocality} ${placemark.locality} ${placemark.administrativeArea} ${placemark.country}';
      if (locationType == LocationType.PICKUP) {
        setPickUpAddress(address);
      } else {
        setDestinationAddress(address);
      }
    }
  }

  // ignore: avoid_void_async
  //get user location
  void _fetchLocation() async {
    LocationFetcher.determinePosition().then((myLocation) {
      final _location = LocationDTO(
          latitude: myLocation.latitude, longitude: myLocation.longitude);
      this._pickUpLocation = _location;
      addMarker(_location, LocationType.PICKUP);
      fetchNameFromCoordinates(_pickUpLocation, LocationType.PICKUP);
      update();
    });
  }

  //load icons to set as marker
  Future<void> loadIcons() async {
    _pickUpIcon =
        await ImageByteConverter.getBytesFromAsset('assets/circle.png', 40);
    _destinationIcon = await ImageByteConverter.getBytesFromAsset(
        'assets/destination.png', 80);
  }

  void _disableButton() {
    if (_pickUpLocation != null && _destinationLocation != null) {
      _hideButton = true;
    } else {
      _hideButton = false;
    }
    update();
  }


  //reset settings
  void resetMap() {
    _destinationLocation = null;
    _lastCameraLocation = null;
    _markers = HashSet<Marker>();
    _markerIdCounter = 1;
    _isMarker = false;
    _cameraMoved = false;
    _selectedLocationAddress = null;
    _pickUpAddress = null;
    _destinationAddress = null;
    _hideButton = false;
    _fetchLocation();
  }
}
