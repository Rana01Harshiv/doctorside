import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../componets/loadingindicator.dart';
import '../../../constants.dart';
import '../../../models/doctor.dart';

class TodayList extends StatefulWidget {
  const TodayList({Key? key}) : super(key: key);

  @override
  State<TodayList> createState() => _TodayListState();
}

var today_date = (new DateFormat('dd-MM-yyyy')).format(DateTime.now()).toString();
List<String> data = [];
var appointment = FirebaseFirestore.instance;

class _TodayListState extends State<TodayList> {
  var _prefService;

  DoctorModel loggedInUser = DoctorModel();
  var user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  var firebase;
  late DocumentSnapshot snapshot;
  var  todayList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loggedInUser = DoctorModel();
    FirebaseFirestore.instance
        .collection("doctor")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = DoctorModel.fromMap(value.data());

      Future<void>.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Check that the widget is still mounted
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    print("Today: " + today_date);
     //use a Async-await function to get the data



    return Scaffold(
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
            stream: appointment
                .collection('pending')
                .orderBy("time", descending: false)
                .where('did', isEqualTo: loggedInUser.uid)
                .where('date', isEqualTo: today_date)
                .where('approve', isEqualTo: true)
                .where('status', isEqualTo: false)
                .snapshots(),

            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                print("==Today Patient found==");

                return isLoading
                    ? Container(
                        margin: EdgeInsets.only(top: size.height * 0.4),
                        child: Center(
                          child: Column(
                            children: [
                              Loading(),


                            ],
                          ),

                        ),
                      )
                    : SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final DocumentSnapshot doc = snapshot.data!.docs[index];
                            return snapshot.hasError
                                ? Center(child: Text("Patient Not Available"))
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      color: kPrimaryLightColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                            ),
                                            Text(
                                              'Time: ' + doc['time'],
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      launch(
                                                          "tel://9265933824");
                                                    },
                                                    child: Container(
                                                        height:
                                                            size.height * 0.04,
                                                        width: size.width * 0.3,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          color: kPrimaryColor,
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                          "Call",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        )) // child widget, replace with your own
                                                        ),
                                                  ),
                                                  /* IconButton(
                                                      onPressed: () async {
                                                        launch("tel://9265933824");
                                                      },
                                                      icon: Icon(Icons.call,size: 30,)),*/
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AdvanceCustomAlert(
                                                                  name: doc[
                                                                          'name']
                                                                      .toString(),
                                                                  bid: doc.id,
                                                                  approve: doc[
                                                                      'approve'],
                                                                  rating: doc[
                                                                      'rating']));
                                                    },
                                                    child: Container(
                                                        height:
                                                            size.height * 0.04,
                                                        width: size.width * 0.3,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          color: kPrimaryColor,
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                          "Visited",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        )) // child widget, replace with your own
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // SizedBox(
                                            //   width: 5,
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                      );
                // else{
                //   return Text("no data utsav");
                // }

              } else {
                print("==Today's Patient Not found==");
                return Container(
                  margin: EdgeInsets.only(top: size.height * 0.4),
                  child: Center(child: Text("Today's Patient Not found")),
                );
              }
            }),
      ),
    );
  }
}

class AdvanceCustomAlert extends StatelessWidget {
  var name;
  var bid;
  var approve;
  var rating;

  AdvanceCustomAlert({this.name, this.bid, this.approve, this.rating});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Stack(
        //    overflow: Overflow.visible,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: size.height * 0.3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Had Patient visited or not visited?',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('pending')
                                    .doc(bid)
                                    .update({
                                  "visited": false,
                                  "rating": false,
                                  "status": true
                                });
                                Navigator.of(context).pop();
                              },
                              //color: kPrimarydark,
                              child: Text(
                                'Not visited',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('pending')
                                    .doc(bid)
                                    .update({
                                  "visited": true,
                                  "rating": true,
                                  "status": true
                                });
                                Navigator.of(context).pop();
                              },
                              //color: kPrimarydark,
                              child: Text(
                                'Visited',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: -40,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFefefef),
                    radius: 50,
                    child: Image.asset('assets/images/logo.jpg'),
                    // Icon(Icons.assistant_photo, color: Colors.white, size: 50,),
                  )),
            ],
          )),
    );
  }
}
