import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../componets/loadingindicator.dart';
import '../../../constants.dart';
import '../../../models/doctor.dart';

class PendingAppointmentList extends StatefulWidget {
  const PendingAppointmentList({Key? key}) : super(key: key);

  @override
  State<PendingAppointmentList> createState() => _PendingAppointmentListState();
}

class _PendingAppointmentListState extends State<PendingAppointmentList> {
  var _prefService;
  var appointment = FirebaseFirestore.instance;
  DoctorModel loggedInUser = DoctorModel();
  var user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  var today_date = (DateFormat('dd-MM-yyyy')).format(DateTime.now()).toString();
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



    return Scaffold(
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
            stream: appointment
                .collection('pending')
                .orderBy('date', descending: false)
                .orderBy('time', descending: false)
                .where("did", isEqualTo: loggedInUser.uid)
                .where("approve", isEqualTo: false)
                .where('date', isGreaterThanOrEqualTo: today_date)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  margin: EdgeInsets.only(top: size.height * 0.4),
                  child: Center(
                    child: Text("There is no expense"),
                  ),
                );
              } else {
                return isLoading
                    ? Container(
                        margin: EdgeInsets.only(top: size.height * 0.4),
                        child: Center(
                          child: Loading(),
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
                            /*  return ListData(doc['name'], doc['time'], size, doc['phone'],"Confirm",(){
                        FirebaseFirestore firebaseFirestore =
                            FirebaseFirestore.instance;
                        firebaseFirestore
                            .collection('doctor/' + doc['did'] + '/user')
                            .add({
                          'name': doc['name'],
                          'date': doc['date'],
                          'time': doc['time'],
                        }).catchError((e) {
                          print("Error Data " + e.toString());
                        });
                        firebaseFirestore
                            .collection('patient/' +doc['pid']+toString() +
                            '/appointment')
                            .add({
                          'name':loggedInUser.name,
                          'date': doc['date'],
                          'time': doc['time']
                        }).catchError((e) {
                          print('Error Data2' + e.toString());
                        });
                      //  await Future.delayed(Duration(seconds: 2));
                                  appointment.collection('pending').doc(doc.id).delete();

                      });*/

                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                color: kPrimaryLightColor,
                                child: Padding(
                                  padding: const EdgeInsets.only(top:5.0,left: 5),
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
                                        'Date: ' + doc['date'],
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'Time: ' + doc['time'],
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(),
                                         /* Text(
                                            doc['phone'],
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),*/
                                          GestureDetector(
                                            onTap: () async {
                                              /* FirebaseFirestore
                                                  firebaseFirestore =
                                                  FirebaseFirestore
                                                      .instance;
                                              firebaseFirestore
                                                  .collection('doctor/' +
                                                      doc['did'] +
                                                      '/user')
                                                  .add({
                                                'name': doc['name'],
                                                'date': doc['date'],
                                                'time': doc['time'],
                                              }).catchError((e) {
                                                print("Error Data " +
                                                    e.toString());
                                              });
                                              firebaseFirestore
                                                  .collection('patient/' +
                                                      doc['pid'] +
                                                      '/appointment')
                                                  .add({
                                                'name': loggedInUser.name,
                                                'date': doc['date'],
                                                'time': doc['time']
                                              }).catchError((e) {
                                                print('Error Data2' +
                                                    e.toString());
                                              });*/
                                              await Future.delayed(Duration(microseconds: 50));
                                              //  print("data"+doc[index]);

                                              /*  appointment
                                                  .collection('pending')
                                                  .doc(doc.id)
                                                  .delete();*/
                                              appointment
                                                  .collection('pending')
                                                  .doc(doc.id)
                                                  .update(
                                                      {'approve': true});
                                              setState(() {});
                                            },
                                            child: Container(
                                                height: size.height * 0.04,
                                                width: size.width * 0.3,
                                                margin: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  color: kPrimaryColor,
                                                ),
                                                child: Center(
                                                    child: Text(
                                                  'Confirm',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                )) // child widget, replace with your own
                                                ),
                                          ),
                                        ],
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
              }
            }),
      ),
    );
  }
}
