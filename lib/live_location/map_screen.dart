import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skr_tracker/delivery_screen/delivery_list.dart';
import 'package:skr_tracker/delivery_screen/delivery_live_location.dart';
import 'package:skr_tracker/new_salesman/new_salesman_list.dart';
import 'package:skr_tracker/old_salesman/salesman_list_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = new Location();
  bool _serviceEnabled = false;
  LocationData _locationData;
  DateTime now = DateTime.now();
  double lat = 24.845143620775687;
  double long = 67.14359441534076;
  Set<Marker> marker = {};
  bool isLoading = false;
  Completer<GoogleMapController> _controller = Completer();

  getMarker() async {
    setState(() {
      isLoading = true;
    });
    List time = [];
    String formatter = DateFormat('dd-MM-yyyy').format(now);
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('Salesman');
    Stream<Event> stream = ref.onValue;
    stream.listen((Event event) async {
      var data = await event.snapshot.value;
      var todayName;
      data.forEach((key, value) {
        DatabaseReference ref1 =
            FirebaseDatabase.instance.reference().child('Salesman').child(key);
        Stream<Event> stream = ref1.onValue;
        stream.listen((Event event) {
          var data = event.snapshot.value;
          data.forEach((key1, value1) {
            if (key1.toString() == formatter.toString()) {
              todayName = key;
              // print(todayName);
              DatabaseReference ref2 = FirebaseDatabase.instance
                  .reference()
                  .child('Salesman')
                  .child(key)
                  .child(key1);
              Stream<Event> stream = ref2.onValue;
              stream.listen((Event event) {
                var data = event.snapshot.value;
                data.forEach((key2, value2) {
                  time.add(key2);
                  // print(key);
                });
                DatabaseReference ref3 = FirebaseDatabase.instance
                    .reference()
                    .child('Salesman')
                    .child(key)
                    .child(key1)
                    .child(time.last);
                Stream<Event> stream = ref3.onValue;
                stream.listen((Event event) {
                  var data = event.snapshot.value;
                  var pointer = Marker(
                      markerId: MarkerId(data['latitude'].toString()),
                      position: LatLng(data['latitude'], data['longitude']),
                      infoWindow: InfoWindow(
                          title: (data['Name'].toString() == 'null')
                              ? key.toString()
                              : data['Name'].toString()),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ));
                  marker.add(pointer);
                  setState(() {});
                });
                // print(time.last);
                // print('hello');
              });
            }
          });
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    _serviceEnabled = await location.requestService();

    if (!_serviceEnabled) {
      _serviceEnabled = await Permission.location.isGranted;
      print("location permission: " + _serviceEnabled.toString());
      if (!_serviceEnabled) {
        var locationPermission = await Permission.location.request();
        print("permission ${locationPermission}");
        if (locationPermission.isGranted) {
          bool temp = await location.serviceEnabled();
          if (!temp) {
            bool _locationService = await location.requestService();
            // location.hasPermission(locationPermission.);
            if (!_locationService) {
              print('denied');
              return;
            }
          } else {
            print("already enabled");
          }
        } else {
          print('denied');
          return;
        }
      }
    } else {
      _locationData = await location.getLocation();

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_locationData.latitude, _locationData.longitude),
        zoom: 10,
      )));

      lat = _locationData.latitude;
      long = _locationData.longitude;
      setState(() {});
    }
  }
  displayshops() async{
    var pointer = Marker(
        markerId: MarkerId(lat.toString()),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(
            title: 'Hello'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        ));
    marker.add(pointer);
    setState(() {});
  }
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    getMarker();
    getLocation();
    displayshops();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'SUQ - TRACKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.account_circle),
              title: Text('Salesman - Live'),
            ),
            ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewSalesmanList())),
              leading: Icon(Icons.assessment_sharp),
              title: Text('Salesman - List - New'),
            ),
            ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SalesmanList())),
              leading: Icon(Icons.list_alt),
              title: Text('Salesman - List - Old'),
            ),
            ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DeliveryMapScreen())),
              leading: Icon(Icons.label_important),
              title: Text('Delivery - live'),
            ),
            ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DeliveryList())),
              leading: Icon(Icons.label_important_outline_rounded),
              title: Text('Delivery - List'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 15, top: 15),
            child: InkWell(
              onTap: () =>
                  Scaffold.of(context).openDrawer(), // <-- Opens drawer.,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                    child: Text(
                  "Salesman - Live",
                  style: TextStyle(color: Colors.black),
                )),
              )),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 15),
            child: InkWell(
              onTap: () {
                setState(() {
                  getMarker();
                  getLocation();
                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.refresh,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, long),
                zoom: 10,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: marker.map((e) => e).toSet()),
          isLoading ? loader() : Container(),
          // Container(
          //   padding: EdgeInsets.only(top: 20),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       InkWell(
          //       onTap:() => {
          //         ScaffoldState().openDrawer(),
          //         print("error")
          // } ,// <-- Opens drawer.,
          //         child: Container(
          //           padding: EdgeInsets.all(10),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           child: Icon(Icons.menu),
          //         ),
          //       ),
          //       Container(
          //         padding: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Text("Current Location",style: TextStyle(fontSize: 20),),
          //       ),
          //       InkWell(
          //         onTap: (){
          //           setState(() {
          //             getMarker();
          //             getLocation();
          //           });
          //         },
          //         child: Container(
          //           padding: EdgeInsets.all(10),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           child: Icon(Icons.refresh),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    ));
  }
}

class loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          color: Colors.blue,
        ),
      ),
    ));
  }
}
