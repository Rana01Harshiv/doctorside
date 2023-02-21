import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../componets/loadingindicator.dart';
import '../../../constants.dart';
import '../../../models/doctor.dart';

class Doctor_RecentList extends StatefulWidget {
  const Doctor_RecentList({Key? key}) : super(key: key);

  @override
  State<Doctor_RecentList> createState() => _Doctor_RecentListState();
}

var today_date = (DateFormat('dd-MM-yyyy')).format(DateTime.now()).toString();

class _Doctor_RecentListState extends State<Doctor_RecentList> {
  var _prefService;
  var appointment = FirebaseFirestore.instance;
  DoctorModel loggedInUser = DoctorModel();
  var user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  var firebase;
  var t_date;
  var mydate;
  String dropdownValue = 'All';


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

      /* firebase=appointment
          .collection('pending')
          .orderBy('date', descending: true)
      //.orderBy('time', descending: false)
          .where('did', isEqualTo: loggedInUser.uid)
      // .where('approve', isEqualTo: true)
          .where('date', isLessThan: today_date)
      //  .where("approve", isEqualTo: "not visited")
      //  .where('approve', isEqualTo: "visited")
          .snapshots();*/

      setState(() {
        sleep(Duration(seconds: 1));
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    print("today Date" + today_date);
    return Scaffold(
        body: SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width * 1,
            margin: EdgeInsets.only(left: 10),
            child: DropdownButton2(
              isExpanded: true,
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              iconEnabledColor: kPrimaryColor,
              buttonHeight: 50,
              buttonPadding: const EdgeInsets.only(left: 14, right: 14),
              buttonElevation: 2,
              itemHeight: 40,
              itemPadding: const EdgeInsets.only(left: 14, right: 14),
              dropdownMaxHeight: 200,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              scrollbarRadius: const Radius.circular(40),
              scrollbarThickness: 6,
              scrollbarAlwaysShow: true,
              style: TextStyle(color: Colors.black, fontSize: 18),
              onChanged: (data) async {
                setState(() {
                  dropdownValue = data.toString();
                });

                if (data == 'All') {
                  setState(() {
                    t_date = null;
// Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Doctor_RecentList()));
                  });
                } else {
                  mydate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now());

                  setState(() {
                    final now = DateTime.now();
                    t_date = DateFormat('dd-MM-yyyy').format(mydate);
                  });
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
// child: GestureDetector(
//     onTap: () {
//     },
//     child: Text('All')
// ),
                ),
                DropdownMenuItem(
                  value: 'Custom Date',
                  child:  Text('Custom Date'),
// child: GestureDetector(
//     onTap: () async {
//       mydate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(1950),
//           lastDate: DateTime.now());
//
//       setState(() {
//         final now = DateTime.now();
//         t_date = DateFormat('dd-MM-yyyy').format(mydate);
//       });
//     },
//     child: Text('Custom Date')
// ),
                ),
              ],
            ),
          ),
          t_date != null
              ? Container(
                  width: size.width*1,
                  margin: EdgeInsets.only(left: 25),
                  child: Text(t_date,style: TextStyle(fontSize: 18),))
              : SizedBox(),

          Container(
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                  stream: appointment
                      .collection('pending')
                      .orderBy('date', descending: true)
                      .where('did', isEqualTo: loggedInUser.uid)
                      .where('date', isLessThanOrEqualTo: today_date)
                      .where('date', isEqualTo: t_date)
                      .where('status', isEqualTo: true)
                      .snapshots(),

                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                          margin: EdgeInsets.only(top: size.height * 0.4),
                          child: Center(
                            child: Loading(),
                          ));
                    } else {
                      return isLoading
                          ? Container(
                              margin: EdgeInsets.only(top: size.height * 0.4),
                              child: Center(
                                child: Text("You have Not Recent Appointment"),
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
// return Text("Popat");
                                  return Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          color: doc['visited'] == false
                                              ? kPrimarydark
                                              : kPrimarydark //kPrimaryColor,
                                      ),
                                      child: Center(
                                        child: doc['visited'] == false
                                            ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(),
                                                  child: Text(doc['name'],
                                                    /* "Your confirm appointment with Dr." +
                                                            doc['doctor_name'] +
                                                            " is Confirmed at  " +
                                                            doc['date'] +
                                                            " and  " +
                                                            doc['time'].toString(),*/
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ) // child widget, replace with your own
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(top: 3),
                                                  decoration: BoxDecoration(),
                                                  child: Text(
                                                    "Date: " + doc['date'],
                                                    /* "Your confirm appointment with Dr." +
                                                            doc['doctor_name'] +
                                                            " is Confirmed at  " +
                                                            doc['date'] +
                                                            " and  " +
                                                            doc['time'].toString(),*/
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w500),
                                                  ) // child widget, replace with your own
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(),
                                                  child: Text(
                                                    "Time: " + doc['time'],
                                                    /* "Your confirm appointment with Dr." +
                                                            doc['doctor_name'] +
                                                            " is Confirmed at  " +
                                                            doc['date'] +
                                                            " and  " +
                                                            doc['time'].toString(),*/
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w500),
                                                  ) // child widget, replace with your own
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                child: Text(
                                                  "Status : Didn't Visit ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                            : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(),
                                                  child: Text(
                                                    doc['name'],
                                                    /* "Your confirm appointment with Dr." +
                                                            doc['doctor_name'] +
                                                            " is Confirmed at  " +
                                                            doc['date'] +
                                                            " and  " +
                                                            doc['time'].toString(),*/
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ) // child widget, replace with your own
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(top: 3),
                                                  decoration: BoxDecoration(),
                                                  child: Text(
                                                    "Date: " + doc['date'],
                                                    /* "Your confirm appointment with Dr." +
                                                            doc['doctor_name'] +
                                                            " is Confirmed at  " +
                                                            doc['date'] +
                                                            " and  " +
                                                            doc['time'].toString(),*/
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w500),
                                                  ) // child widget, replace with your own
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(),
                                                  child: Text(
                                                    "Time: " + doc['time'],
                                                    /* "Your confirm appointment with Dr." +
                                                            doc['doctor_name'] +
                                                            " is Confirmed at  " +
                                                            doc['date'] +
                                                            " and  " +
                                                            doc['time'].toString(),*/
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w500),
                                                  ) // child widget, replace with your own
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                child: Text(
                                                  "Status : Visited ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ) // child widget, replace with your own
                                  );
                                },
                              ),
                            );
                    }
                  }),
            ),
          ),
// Positioned(
//   top: 0,
//   left: 0,
//   child: Container(
//     color: Colors.white,
//     width: size.width * 1,
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       //  crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Container(
//           margin: EdgeInsets.only(left: 10),
//           child: Center(
//             child: t_date == null
//                 ? Text(
//                     "Select Date",
//                     style: TextStyle(
//                         color: Colors.black54, fontSize: 18),
//                   )
//                 : Text(
//                     t_date,
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//           ),
//         ),
//         IconButton(
//             onPressed: () async {
//               mydate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(1950),
//                   lastDate: DateTime.now());
//
//               setState(() {
//                 final now = DateTime.now();
//                 t_date = DateFormat('dd-MM-yyyy').format(mydate);
//               });
//             },
//             icon: Icon(
//               Icons.calendar_today,
//               color: kPrimaryColor,
//               size: 20,
//             ))
//       ],
//     ),
//   ),
// ),
// Positioned(
//   top: 0,
//   left: 0,
//   child: Container(
//     color: Colors.white,
//     width: size.width * 1,
//     child: DropdownButton(
//       // icon: Container(
//       //   margin: EdgeInsets.only(right: 10),
//       //   child: Icon(
//       //     Icons.calendar_today,
//       //     color: kPrimaryColor,
//       //     size: 20.09,
//       //   ),
//       // ),
//       // isExpanded: true,
//       items: [
//         DropdownMenuItem(
//           value: 'All',
//           child: Text('All'),
//           // child: GestureDetector(
//           //     onTap: () {
//           //     },
//           //     child: Text('All')
//           // ),
//         ),
//         DropdownMenuItem(
//           value: 'Custom Date',
//           child: Text('Custom Date'),
//           // child: GestureDetector(
//           //     onTap: () async {
//           //       mydate = await showDatePicker(
//           //           context: context,
//           //           initialDate: DateTime.now(),
//           //           firstDate: DateTime(1950),
//           //           lastDate: DateTime.now());
//           //
//           //       setState(() {
//           //         final now = DateTime.now();
//           //         t_date = DateFormat('dd-MM-yyyy').format(mydate);
//           //       });
//           //     },
//           //     child: Text('Custom Date')
//           // ),
//         ),
//       ],
//       onChanged: (value) async {
//         setState(() {
//           this.dropdownValue1 = value.toString();
//         });
//         if (value == 'All') {
//           setState(() {
//             t_date = null;
//             // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Doctor_RecentList()));
//           });
//         } else {
//           mydate = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime(1950),
//               lastDate: DateTime.now());
//
//           setState(() {
//             final now = DateTime.now();
//             t_date = DateFormat('dd-MM-yyyy').format(mydate);
//           });
//         }
//       },
//     ),
//   ),
// ),
        ],
      ),
    ));
  }
}

