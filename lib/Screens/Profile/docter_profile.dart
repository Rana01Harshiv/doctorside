import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path/path.dart';

import '../../componets/loadingindicator.dart';
import '../../constants.dart';
import '../../models/doctor.dart';
import 'dart:io';

import '../../widget/Alert_Dialog.dart';
import '../home/doctor_home_page.dart';

class Docter_Profile extends StatefulWidget {
  const Docter_Profile({Key? key}) : super(key: key);

  @override
  State<Docter_Profile> createState() => _Docter_ProfileState();
}

DoctorModel loggedInUser = DoctorModel();

class _Docter_ProfileState extends State<Docter_Profile> {
  User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  var t_address;
  var t_description;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var file;

  var phoneController;

  /* final Stream<DocumentSnapshot<Map<String, dynamic>>> _Shop =
  FirebaseFirestore.instance.collection('docter').doc[''].snapshots();*/


  var subscription;
  bool status = false;
  var result;

  getConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
// I am connected to a mobile network.
      status = true;
      print("Mobile Data Connected !");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Wifi Connected !");
      status = true;
// I am connected to a wifi network.
    } else {
      print("No Internet !");
    }
  }

  Future<bool> getInternetUsingInternetConnectivity() async {
    result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      print('YAY! Free cute dog pics!');
    } else {
      print('No internet :( Reason:');
    }
    return result;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          status = false;
        });
      }
      else {
        setState(() {
          status = true;
        });
      }
    });
    loggedInUser = DoctorModel();
    FirebaseFirestore.instance
        .collection("doctor")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = DoctorModel.fromMap(value.data());
      setState(() {
        isLoading = false;
      });
      print("++++++++++++++++++++++++++++++++++++++++++" + user!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    var margin_left = size.width * 0.07;
    var margin_top = size.width * 0.03;
    var margin_right = size.width * 0.07;
    var boder = size.width * 0.6;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: isLoading
            ? Loading()
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.01),
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 3, color: Colors.black12),
                        ),
                        child: Stack(
                          children: [
                            loggedInUser.profileImage == false
                                ? CircleAvatar(
                              backgroundImage:
                              AssetImage('assets/images/account.png'),
                              radius: 50,
                            )
                                : Container(
                              child: InkWell(
                                onTap: () {
                                  chooseImage();
                                },
                                child: file == null ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      loggedInUser.profileImage),
                                  backgroundColor: Colors.grey,
                                  radius: 50,
                                ) : CircleAvatar(
                                  radius: 50.00,
                                  backgroundImage: FileImage(file),
                                ),
                              ),),
                            Positioned(
                                right: 0,
                                bottom: 5,
                                child: Container(
                                    width: 30,
                                    height: 30,
                                    child: Image.asset(
                                      "assets/images/camera.png",
                                    )))
                          ],
                        )
                    ),
                  ),
                ),
                // ************************************
                // Name Field
                //*************************************
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.01),
                  child: Text(
                    "Dr.${loggedInUser.name}".toString().toUpperCase(),
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                // ************************************
                // Email Field
                //*************************************
                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Email",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1.0, color: Colors.black12),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Text("${loggedInUser.email}".toString()),
                      )
                    ],
                  ),
                ),
                // ************************************
                // address Field
                //*************************************
                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Address",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1.0, color: Colors.black12),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          cursorColor: kPrimaryColor,
                          initialValue: loggedInUser.address,
                          onChanged: (address) {
                            t_address = address;
                          },
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your Address";
                            }
                            return null;
                          },
                          onSaved: (var address) {
                            t_address = address;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                // ************************************
                // Date of Birth Field
                //*************************************
                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "specialist",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1.0, color: Colors.black12),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child:
                        Text("${loggedInUser.specialist}".toString()),
                      )
                    ],
                  ),
                ),
                // ************************************
                // Age Field
                //*************************************
                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "experienc",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: margin_left, right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1.0, color: Colors.black12),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5.0)
                            //                 <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child:
                        Text("${loggedInUser.experience}".toString()),
                      )
                    ],
                  ),
                ),

                // ************************************
                // Countact Number
                //*************************************

                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Contact No",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: margin_right),
                        width: boder,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1.0, color: Colors.black12),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5.0)
                            //  <--- border radius here
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: IntlPhoneField(
                          cursorColor: kPrimaryColor,
                          style: TextStyle(fontSize: 16),
                          disableLengthCheck: false,
                          initialValue: loggedInUser.phone?.substring(3),
                          textAlignVertical: TextAlignVertical.center,
                          dropdownTextStyle: TextStyle(fontSize: 16),
                          dropdownIcon:
                          Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                          initialCountryCode: 'IN',
                          onChanged: (phone) {
                            print(phone.completeNumber);
                            phoneController = phone.completeNumber.toString();
                          },
                        ),
                        //  child: Text("${loggedInUser.phone}"),
                      )
                    ],
                  ),
                ),
                Container(
                  margin:
                  EdgeInsets.only(left: margin_left, top: margin_top),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Description",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: size.width * 0.85,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)
                      //                 <--- border radius here
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "${loggedInUser.description}",
                    textAlign: TextAlign.justify,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: size.width * 0.85,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)
                      //                 <--- border radius here
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Update Description',
                    ),
                    keyboardType: TextInputType.text,
                    cursorColor: kPrimaryColor,
                    onChanged: (description) {
                      t_description = description;
                    },
                  ),
                ),

                Container(
                  width: size.width * 0.8,
                  margin: EdgeInsets.all(10),
                  child: TextButton(
                 /*   shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    color: kPrimaryColor,*/
                    onPressed: () async {
                      var url;
                      if (status == false) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                AdvanceCustomAlert());
                      } else {
                        showLoadingDialog(context: context);
                        if (file != null) {
                          url = await uploadImage();
                          print("URL ===== " + url.toString());
                          //map['profileImage'] = url;
                        }
                        if (_formKey.currentState!.validate()) {
                          print("Done");
                          FirebaseFirestore firebaseFirestore =
                              FirebaseFirestore.instance;
                          firebaseFirestore
                              .collection('doctor')
                              .doc(loggedInUser.uid)
                              .update({

                            'address': t_address == null
                                ? loggedInUser.address
                                : t_address,
                            'phone': phoneController == null ? loggedInUser
                                .phone : phoneController,
                            'description': t_description == null ? loggedInUser
                                .description : t_description,
                            'profileImage': url == null ? loggedInUser
                                .profileImage : url,
                          }).then((value) =>Navigator.pushAndRemoveUntil<dynamic>(
                              context,
                              MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) =>
                                      Demo()),
                                  (route) => false));
                        }
                      }
                    },
                    child: Text(
                      'Update Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  chooseImage() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("file " + xfile!.path);
    file = File(xfile.path);
    setState(() {});
    /*XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);

    file = File(xfile.path);
    setState(() {});*/
  }

  updateProfile(BuildContext context) async {
    var url;
    Map<String, dynamic> map = Map();
    if (file != null) {
      url = await uploadImage();
      print("URL ===== " + url.toString());
      //map['profileImage'] = url;
    }
    print("uid =====" + user!.uid.toString());
    /*await FirebaseFirestore.instance
        .collection("patient")
        .doc(user?.uid)
        .set({'profileImage': url});
    Navigator.pop(context);*/
  }

  Future<String> uploadImage() async {
    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref()
        .child("profile")
        .child(
        FirebaseAuth.instance.currentUser!.uid + "_" + basename(file.path))
        .putFile(file);

    return taskSnapshot.ref.getDownloadURL();
  }
}
