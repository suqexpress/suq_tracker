import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skr_tracker/salesman_route_screen.dart';

class DateList extends StatefulWidget {
  DateList({this.number});
  final number;

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {
  List date=[];
  getDate()async{
    DatabaseReference ref = FirebaseDatabase.instance.reference().child('Salesmen').child(widget.number.toString());
    DataSnapshot event = await ref.once();
    var data = event.value;
    data.forEach((key, value){
     date.add(key.toString());
     setState(() {});
    });


  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Center(child: Text("Date List",style: TextStyle(color: Colors.black),)),
      ),
      body: Container(
        child:ListView.builder(
            itemCount: date.length,
            itemBuilder: (context,index){
              return Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5)))
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(date[index].toString(),style: TextStyle(fontSize: 18),),
                      InkWell(
                        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>SalesManRoute(date: date[index],number: widget.number,))),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.arrow_forward_ios,color: Colors.grey.withOpacity(0.5),)),
                      )
                    ],),
                ),
              );
            }),
      ),
    ));
  }
}
