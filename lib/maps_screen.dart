import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import './controllers/maps_controller.dart';
import './models/location.dart';

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapsController controller = Get.put(MapsController());
  var _mapsController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MapsController>(
        builder: (myController) => myController.pickUpLocation != null
            ? Stack(
                children: [
                  Container(
                    height: Get.height,
                    width: Get.width,
                    child: GoogleMap(
                      onMapCreated: onMapCreated,
                      compassEnabled: false,
                      onCameraMove: (data) {
                        if (!myController.hideButton) {
                          myController.setDestinationAddress(null);
                          myController.updateCameraStatus();
                          myController.updateLastCameraLocation(LatLng(
                              data.target.latitude, data.target.longitude));
                        }
                      },
                      onCameraIdle: () async {
                        if (myController.cameraMoved) {
                          if (!myController.hideButton) {
                            myController.fetchNameFromCoordinates(
                                myController.lastCameraLocation,
                                LocationType.DESTINATION);
                          }
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      markers: myController.markers,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(myController.pickUpLocation.latitude,
                              myController.pickUpLocation.longitude),
                          zoom: 16.0),
                    ),
                  ),
                  myController.hideButton
                      ? Container()
                      : Center(
                          child: Image.asset(
                            'assets/pin.png',
                            height: 40,
                            width: 40,
                          ),
                        ),
                  Positioned(
                    right: 16,
                    left: 16,
                    top: Get.height * 0.1,
                    child: (myController.destinationAddress) != null
                        ? Container(
                            color: Colors.grey.withOpacity(0.5),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.gps_fixed),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        myController.pickUpAddress != null
                                            ? myController.pickUpAddress
                                            : 'Loading...',
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 16,
                                  thickness: 2,
                                  color: Colors.black,
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.place),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        myController.destinationAddress,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: Get.width),
                      child: myController.hideButton
                          ? Container()
                          : ElevatedButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(vertical: 16))),
                              onPressed: () {
                                myController.addDestination();
                                moveCamera(
                                    myController.destinationLocation, 15.5);
                              },
                              child: Text('Set Destination'),
                            ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: myController.hideButton
                          ? ElevatedButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(vertical: 16))),
                              onPressed: () {
                                moveCamera(myController.pickUpLocation, 16.0);
                                myController.resetMap();
                                Future.delayed(Duration(seconds: 3)).then(
                                    (value) => moveCamera(
                                        myController.pickUpLocation, 16.0));
                              },
                              child: Text('Reset Map'),
                            )
                          : Container(),
                    ),
                  )
                ],
              )
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Text('Getting your location...'),
                  ],
                ),
              ),
      ),
    );
  }

  void onMapCreated(mapController) {
    _mapsController = mapController;
  }

  void moveCamera(LocationDTO location, zoom) {
    _mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude), zoom: zoom)));
  }
}
