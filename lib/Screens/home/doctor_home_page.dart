import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/doctor.dart';
import '../../services/shared_preferences_service.dart';
import '../Chat/Patient_List.dart';

import '../Pages/Doctor/Doctor_RecentList.dart';
import '../Pages/Doctor/PendingAppointmentList.dart';
import '../Pages/Doctor/TodayList.dart';
import '../Profile/docter_profile.dart';
import '../login/loginas.dart';

class Demo extends StatefulWidget {
  const Demo({Key? key}) : super(key: key);

  @override
  State<Demo> createState() => _DemoState();

}

class _DemoState extends State<Demo> with SingleTickerProviderStateMixin {
  late TabController tabController;

  final PrefService _prefService = PrefService();
  var appointment = FirebaseFirestore.instance;
  DoctorModel loggedInUser = DoctorModel();
  static User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this, initialIndex: 0);

    loggedInUser = DoctorModel();
    FirebaseFirestore.instance
        .collection("doctor")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = DoctorModel.fromMap(value.data());
      setState(() {
        print("loggedInUser === "+ loggedInUser.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Container(
            width: 50,
            child: Icon(
              Icons.account_circle,
              size: 35,
            ),
          ),
          onPressed: () {
            if(loggedInUser.uid != null){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Docter_Profile()));
            }

          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                _prefService.removeCache("password");
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Loginas()));
              },
              child: Text(
                "Log Out",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: kPrimaryLightColor),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          labelStyle: TextStyle(fontSize: 18),
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Today',
            ),
            Tab(
              text: 'Recent',
            ),
            Tab(
              text: 'Pending',
            ),
            Tab(
              text: 'Chat',
            ),

          ],
        ),
      ),

      body:loggedInUser.uid == null?Center(child: Container(child: Text("Your Account is under verification.",),)): TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          TodayList(),
          Doctor_RecentList(),
          PendingAppointmentList(),
          Patient_List()
        ],
      ),
      // body: Column(
      //
      //     children: [
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           RaisedButton(
      //             onPressed: () {},
      //             child: Text("Today"),
      //           ),
      //           RaisedButton(
      //             onPressed: () {
      //               setState(() {
      //
      //               });
      //             },
      //             child: Text("Tomorrow"),
      //           ),
      //           RaisedButton(
      //             onPressed: () {},
      //             child: Text("Pending"),
      //           ),
      //         ],
      //       ),
      //       SizedBox(child: Text(DateTime.now().toString())),
      //       StreamBuilder<QuerySnapshot>(
      //           stream: appointment
      //               .collection(
      //                   'docter/' + loggedInUser.uid.toString() + '/user')
      //               .where('date', isEqualTo: today_date)
      //               .snapshots(),
      //           builder: (BuildContext context,
      //               AsyncSnapshot<QuerySnapshot> snapshot) {
      //             if (!snapshot.hasData) {
      //               return new Text("There is no expense");
      //             } else {
      //               return SingleChildScrollView(
      //                 physics: BouncingScrollPhysics(),
      //                 child: ListView.builder(
      //                   physics: NeverScrollableScrollPhysics(),
      //                   shrinkWrap: true,
      //                   scrollDirection: Axis.vertical,
      //                   itemCount: snapshot.data!.docs.length,
      //                   itemBuilder: (BuildContext context, int index) {
      //                     final DocumentSnapshot doc =
      //                         snapshot.data!.docs[index];
      //                     return ListData(doc['name'], doc['time'], size);
      //                   },
      //                 ),
      //               );
      //             }
      //           }),
      //     ],
      //   ),
    );
  }

  Widget listData(var name, var time, Size size) {
    return Card(
      color: kPrimaryLightColor,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                  width: 75,
                  height: 75,
                  image: AssetImage('assets/images/logo.jpg')),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Time: ' + time,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1212121212',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: size.width * 0.16),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                            height: size.height * 0.04,
                            width: size.width * 0.3,
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: kPrimaryColor,
                            ),
                            child: Center(
                                child: Text(
                              "Visited",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            )) // child widget, replace with your own
                            ),
                      ),
                    ),
                  ],
                ),
                // SizedBox(
                //   width: 5,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
