import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SalesManRoute extends StatefulWidget {
  SalesManRoute({this.number, this.date});
  final number;
  final date;

  @override
  State<SalesManRoute> createState() => _SalesManRouteState();
}

class _SalesManRouteState extends State<SalesManRoute> {
  double lat = 24.845143620775687;
  double long = 67.14359441534076;
  Set<Marker> marker = {};
  List time = [];
  List<LatLng> _poly = [];
  Set<Polyline> polyline = {};
  Completer<GoogleMapController> _controller = Completer();
  getMarker() async {
    DatabaseReference ref2 = FirebaseDatabase.instance
        .reference()
        .child('Salesmen')
        .child(widget.number.toString())
        .child(widget.date.toString());
    DataSnapshot event = await ref2.once();
    var data = event.value;
    data.forEach((key2, value2) async {
      var date = DateTime.fromMillisecondsSinceEpoch(int.parse(key2));
      var times=date.toString().substring(10,16);
      print("time $times");
      time.add(key2);
      DatabaseReference ref3 = FirebaseDatabase.instance
          .reference()
          .child('Salesmen')
          .child(widget.number.toString())
          .child(widget.date.toString())
          .child(key2);
      DataSnapshot event = await ref3.once();
      // var date = DateTime.fromMillisecondsSinceEpoch(eve * 1000);
      var data = event.value;
      var pointer = Marker(
          markerId: MarkerId(data['latitude'].toString()),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(title: times,

              // title: (data['Name'].toString() == 'null')
              //     ? widget.number.toString()
              //     : data['Name'].toString()
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ));
      marker.add(pointer);
      _poly.add(LatLng(data['latitude'], data['longitude']));
      // print(data['latitude']);
      // print(data['longitude']);
      setState(() {});
    });
    setState(() {
      polyline.add(Polyline(
          polylineId: PolylineId("talha"), points: _poly, color: Colors.blue));
    });
    // print(key);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMarker();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: InkWell(
          onTap: ()=>Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 15,top: 15),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_ios,color: Colors.black,),
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
                child: Center(child: Text(widget.number.toString(),style: TextStyle(color: Colors.black),)),
              )),
        ),
      ),
      body: Container(
        child: GoogleMap(
          polylines: polyline,
          markers: marker,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, long),
            zoom: 10,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    ));
  }
}
