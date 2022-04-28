import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skr_tracker/new_salesman/datelistfornewsalesman.dart';
import 'package:skr_tracker/old_salesman/datelistforsalesman.dart';

class NewSalesmanList extends StatefulWidget {
  @override
  State<NewSalesmanList> createState() => _NewSalesmanListState();
}

class _NewSalesmanListState extends State<NewSalesmanList> {
  List name = [];
  List userName = [];
  DateTime now = DateTime.now();
  getNumber() async {
    DatabaseReference ref =
    FirebaseDatabase.instance.reference().child('Salesman');
    DataSnapshot event = await ref.once();
    var data = event.value;
    data.forEach((key, value) {
      userName.add(key.toString());
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
                itemCount: userName.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                            BorderSide(color: Colors.grey.withOpacity(0.5)))),
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewDateListForSalesman(userName: userName[index]))),
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userName[index],
                              style: TextStyle(fontSize: 18),
                            ),
                            CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey.withOpacity(0.5),
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ));
  }
}
