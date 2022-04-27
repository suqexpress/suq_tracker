import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skr_tracker/datelistforsalesman.dart';

class SalesmanList extends StatefulWidget {
  @override
  State<SalesmanList> createState() => _SalesmanListState();
}

class _SalesmanListState extends State<SalesmanList> {
  List name = [];
  List num = [];
  DateTime now = DateTime.now();
  getNumber() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('Salesmen');
    DataSnapshot event = await ref.once();
    var data = event.value;
    data.forEach((key, value) {
      num.add(key.toString());
    });
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNumber();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Center(
            child: Text(
          "Salesman List",
          style: TextStyle(color: Colors.black),
        )),
      ),
      body: Container(
        child: ListView.builder(
            itemCount: num.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.withOpacity(0.5)))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        num[index],
                        style: TextStyle(fontSize: 18),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DateListForSalesman(number: num[index]))),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey.withOpacity(0.5),
                            )),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    ));
  }
}
