import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:skr_tracker/delivery_screen/delivery_list.dart';
import 'package:skr_tracker/old_salesman/salesman_list_screen.dart';

class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({Key key}) : super(key: key);

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  Location location = new Location();
  bool _serviceEnabled = false;
  LocationData _locationData;
  DateTime now = DateTime.now();
  double lat = 24.845143620775687;
  double long = 67.14359441534076;
  Set<Marker> marker = {};
  bool isLoading = false;
  Completer<GoogleMapController> _controller = Completer();

  getDelivery() async {
    List time = [];
    String formatter = DateFormat('dd-MM-yyyy').format(now);
    DatabaseReference ref3 =
        FirebaseDatabase.instance.reference().child('Delivery');
    Stream<Event> streams = ref3.onValue;
    streams.listen((Event event) async {
      var data = await event.snapshot.value;
      var todayName;
      data.forEach((key, value) async {
        print("name: $key");
        DatabaseReference ref4 =
            FirebaseDatabase.instance.reference().child('Delivery').child(key);
        Stream<Event> stream = ref4.onValue;
        stream.listen((Event event) {
          var data = event.snapshot.value;
          data.forEach((key1, value1) {
            if (key1.toString() == formatter.toString()) {
              todayName = key;
              // print(todayName);
              DatabaseReference ref2 = FirebaseDatabase.instance
                  .reference()
                  .child('Delivery')
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
                    .child('Delivery')
                    .child(key)
                    .child(key1)
                    .child(time.last);
                Stream<Event> stream = ref3.onValue;
                stream.listen((Event event) async {
                  var data = await event.snapshot.value;
                  var pointer = Marker(
                      markerId: MarkerId(data['latitude'].toString()),
                      position: LatLng(data['latitude'], data['longitude']),
                      infoWindow: InfoWindow(
                        title: key,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ));
                  print(data['latitude']);
                  print(data['longitude']);
                  marker.add(pointer);
                  print(key);
                  print(marker.length);
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
    setState(() {});
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDelivery();
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
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SalesmanList())),
              leading: Icon(Icons.account_circle),
              title: Text('Salesman - Live'),
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
                  "Delivery - Live",
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
                  getDelivery();
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
