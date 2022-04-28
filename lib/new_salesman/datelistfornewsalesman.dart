import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skr_tracker/new_salesman/new_salesman_route.dart';
import 'package:skr_tracker/salesman_route_screen.dart';

class NewDateListForSalesman extends StatefulWidget {
  NewDateListForSalesman({this.userName});
  final userName;

  @override
  State<NewDateListForSalesman> createState() => _NewDateListForSalesmanState();
}

class _NewDateListForSalesmanState extends State<NewDateListForSalesman> {
  List<DateTime> date = [];
  getDate() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('Salesman')
        .child(widget.userName.toString());
    print(widget.userName);
    DataSnapshot event = await ref.once();
    var data = event.value;
    data.forEach((key, value) {
      var day = key.toString().substring(0, 2);
      var month = key.toString().substring(3, 5);
      var year = key.toString().substring(6, 10);
      date.add(DateTime.parse("$year-$month-$day"));
      setState(() {});
    });
    date.sort((a, b) {
      return b.compareTo(a);
    });

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDate();
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
                  "Date List",
                  style: TextStyle(color: Colors.black),
                )),
          ),
          body: Container(
            child: ListView.builder(
                itemCount: date.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                            BorderSide(color: Colors.grey.withOpacity(0.5)))),
                    child: InkWell(
                      onTap: () {
                        var data = date[index];
                        print(date[index]);
                        var day = data.toString().substring(8, 10);
                        var month = data.toString().substring(5, 7);
                        var year = data.toString().substring(0, 4);
                        String curDate = "$day-$month-$year";
                        print(curDate);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewSalesManRoute(
                                  date: curDate,
                                  userName: widget.userName,
                                )));
                      },
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date[index].toString().substring(0, 10),
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
