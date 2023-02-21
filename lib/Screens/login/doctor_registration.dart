import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path/path.dart';

import '../../componets/loadingindicator.dart';
import '../../componets/text_field_container.dart';
import '../../constants.dart';
import '../../widget/Alert_Dialog.dart';
import '../../widget/inputdecoration.dart';
import 'doctorlogin.dart';

class Registration_docter extends StatefulWidget {
  const Registration_docter({Key? key}) : super(key: key);

  @override
  State<Registration_docter> createState() => _Registration_docterState();
}

class _Registration_docterState extends State<Registration_docter> {
  var t_name,
      t_address,
      t_email,
      t_experience,
      t_phone,
      t_password,
      tc_password,
      t_lname,
      t_description;
  var _isObscure = true;
  var _isObscure1 = true;
  var _auth = FirebaseAuth.instance;
  var valu;
  var value2;
  String? errorMessage;
  String dropdownValue = 'Neuro';
  String phoneController = '';
  late UserCredential userCredential;

  List<String> spinnerItems = [
    'Neuro',
    'Ear',
    'Eyes',
    'Hair',
    'Kidney',
    'Skin',
    'Thyroid',
    'Tooth',
    'Ortho',
    'Covid-19',
  ];

  DateTime selectedDate = DateTime.now();

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  var users;
  var file;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var subscription;
  bool status = false;
  var result;
  getConnectivity()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
// I am connected to a mobile network.
      status =true;
      print("Mobile Data Connected !");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Wifi Connected !");
      status =true;
// I am connected to a wifi network.
    }else{
      print("No Internet !");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
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




  /* List<Widget> createRadioListUsers() {
    List<Widget> widgets = [];
    for (User user in users) {
      widgets.add(
        RadioListTile(
          value: user,
          groupValue: user,
          title: Text(user.gender),
          onChanged: (value) {},
        ),
      );
    }
    return widgets;
  }*/

  @override
  Widget build(BuildContext context) {
    bool isPasswordValid(String password) => password.length == 6;

    bool isEmailValid(String email) {
      var pattern =
          r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      return regex.hasMatch(email);
    }


    var size = MediaQuery.of(context).size;
    var container_width = size.width * 0.9;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Container(
                width: size.width * 1,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/white.jpg"),
                      fit: BoxFit.cover),
                ),
                child: Container(

                  child: Column(
                    children: [
                    /*  Container(
                        margin: EdgeInsets.only(top: size.height * 0.09),
                        child: Image.asset("assets/images/logo.jpg",
                            width: size.width * 0.5,
                            height: size.height * 0.20),
                      ),*/

                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          child: Center(
                              child: Text(
                                "Registration",
                                style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 2,
                        width: 150,
                        color: kPrimaryLightColor,
                      ),

                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Stack(children: [
                        CircleAvatar(
                          radius: 50.00,
                          backgroundColor: kPrimaryLightColor,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: file == null
                                ? InkWell(
                              onTap: () {
                                chooseImage();
                              },
                              child: CircleAvatar(
                                radius: 48.00,
                                backgroundImage:
                                AssetImage('assets/images/account.png')
                              ),
                            )
                                : CircleAvatar(
                              radius: 48.00,
                              backgroundImage: FileImage(file),
                            ),
                          ),
                        ),
                        Positioned(
                            right: 0,
                            bottom: 5,
                            child: Container(
                                width: 30,
                                height: 30,
                                child: Image.asset(
                                  "assets/images/camera.png",
                                )))
                      ]),
                      SizedBox(
                        height: size.height * 0.02
                      ),
                      // ************************************
                      // Name Field
                      //*************************************
                      Container(
                        width: container_width,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: kPrimaryColor,
                          decoration:
                              buildInputDecoration(Icons.person, "Name"),
                          //onChanged: (){},
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your Name";
                            }
                            return null;
                          },
                          onSaved: (name) {
                            t_name = name.toString().trim();
                          },
                          onChanged: (var name) {
                            t_name = name.trim();
                          },
                        ),
                      ),
                      Container(
                        width: container_width,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: kPrimaryColor,
                          decoration:
                              buildInputDecoration(Icons.person, "Last Name"),
                          //onChanged: (){},
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your Last Name";
                            }
                            return null;
                          },
                          onSaved: (name) {
                            t_lname = name.toString().trim();
                          },
                          onChanged: (var name) {
                            t_lname = name.trim();
                          },
                        ),
                      ),
                      // ************************************
                      // Address Field
                      //*************************************
                      Container(
                        width: container_width,
                        margin: EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: kPrimaryColor,
                          decoration: buildInputDecoration(
                              Icons.add_location, "Address"),
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
                      ),
                      // ************************************
                      // email Field
                      //*************************************
                      Container(
                        width: container_width,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: kPrimaryColor,
                          decoration:
                              buildInputDecoration(Icons.email, "Your Email "),
                          onChanged: (email) {
                            t_email = email.trim();
                          },
                          validator: (email) {
                            if (isEmailValid(email!))
                              return null;
                            else
                              return 'Enter a valid email address';
                          },
                          onSaved: (var email) {
                            t_email = email.toString().trim();
                          },
                        ),
                      ),
                      // ************************************
                      // Mobile number Field
                      //*************************************
                      Container(
                        width: container_width,
                        margin: EdgeInsets.all(10),
                        child: IntlPhoneField(
                          cursorColor: kPrimaryColor,
                          style: TextStyle(fontSize: 16),
                          disableLengthCheck: false,
                          textAlignVertical: TextAlignVertical.center,
                          dropdownTextStyle: TextStyle(fontSize: 16),
                          dropdownIcon:
                              Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                          decoration: buildInputDecoration(
                              Icons.phone, "Contact Number"),
                          initialCountryCode: 'IN',
                          onChanged: (phone) {
                            print(phone.completeNumber);
                            phoneController = phone.completeNumber.toString();
                          },
                        ),
                      ),
                      // ************************************
                      // Date of Birth Field
                      //*************************************
                      /*  TextFieldContainer(
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Date Of Birth   ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //  crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                  child: c_date == null
                                      ? Text(
                                    "Select Date",
                                    style:
                                    TextStyle(color: Colors.black54),
                                  )
                                      : Text(
                                    c_date,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      mydate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1950),
                                          lastDate: DateTime.now());

                                      setState(() {
                                        final now = DateTime.now();
                                        c_date = DateFormat('dd-MM-yyyy')
                                            .format(mydate);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.calendar_today,
                                      color: kPrimaryColor,
                                      size: 16,
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),*/
                      // ************************************
                      // Age Field
                      //*************************************
                      Container(
                        width: container_width,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          cursorColor: kPrimaryColor,
                          decoration: buildInputDecoration(
                              Icons.accessibility, "Experience"),
                          //onChanged: (){},
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Your Experience";
                            }
                            return null;
                          },
                          onChanged: (experience) {
                            t_experience = experience;
                          },
                          onSaved: (experience) {
                            t_experience = experience;
                          },
                        ),
                      ),

                      TextFieldContainer(
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Specialist",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                            Container(
                              width: size.width * 0.6,
                              margin: EdgeInsets.only(left: 10),
                              child: DropdownButton2(
                                isExpanded: true,
                                value: dropdownValue,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                iconEnabledColor: kPrimaryColor,
                                buttonHeight: 50,
                                buttonPadding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                buttonElevation: 2,
                                itemHeight: 40,
                                itemPadding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                dropdownMaxHeight: 200,
                                dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                scrollbarRadius: const Radius.circular(40),
                                scrollbarThickness: 6,
                                scrollbarAlwaysShow: true,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                                onChanged: (data) {
                                  setState(() {
                                    dropdownValue = data.toString();
                                  });
                                },
                                items: spinnerItems
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: container_width,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: kPrimaryColor,
                          decoration:
                              buildInputDecoration(Icons.person, "Description"),
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return "Enter Description";
                            }
                            return null;
                          },
                          onSaved: (name) {
                            t_description = name.toString().trim();
                          },
                          onChanged: (var name) {
                            t_description = name.trim();
                          },
                        ),
                      ),

                      //************************************
                      //Password
                      //************************************
                      Container(
                        width: container_width,
                        child: TextFormField(
                          obscureText: _isObscure,
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: kPrimaryLightColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: kPrimaryColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: kPrimaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                    print("on password");
                                  });
                                },
                              ),
                              fillColor: kPrimaryLightColor,
                              filled: true,
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide:
                                    BorderSide(color: kPrimaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: kPrimaryLightColor,
                                  width: 2,
                                ),
                              ),
                              hintText: "Password"),
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return ("Password is required for login");
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Enter Valid Password(Min. 6 Character)");
                            }
                          },
                          onChanged: (password) {
                            t_password = password;
                          },
                          onSaved: (var password) {
                            t_password = password;
                          },
                        ),
                      ),
                      Container(
                        width: container_width,
                        margin: EdgeInsets.all(10),
                        child: TextFormField(
                          obscureText: _isObscure1,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: kPrimaryLightColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: kPrimaryColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure1
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: kPrimaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure1 = !_isObscure1;
                                    print("on password");
                                  });
                                },
                              ),
                              fillColor: kPrimaryLightColor,
                              filled: true,
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide:
                                    BorderSide(color: kPrimaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: kPrimaryLightColor,
                                  width: 2,
                                ),
                              ),
                              hintText: "Confirm Password"),
                          onChanged: (value) {
                            tc_password = value;
                          },
                          validator: (value) {
                            if (tc_password != t_password) {
                              return "Password don't match";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            tc_password.text = value!;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      // ************************************
                      // Submit Button
                      //*************************************

                      /*        Container(
                        width: size.width * 0.8,
                        child: RaisedButton(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          color: kPrimaryColor,
                          onPressed: () async {
                            //  signUp(t_email.text,t_password.text);
                            if (_formKey.currentState!.validate()) {
                              FirebaseFirestore firebaseFirestore =
                                  FirebaseFirestore.instance;
                              User? user = _auth.currentUser;
                              await _auth
                                  .createUserWithEmailAndPassword(
                                  email: t_email,
                                  password: t_password)
                                  .then((value) =>
                              {
                                firebaseFirestore
                                    .collection('docter/'+'M7dBjf5f1IetdE3Hn2mHv4beNMy1'+'/user')
                                    .doc(user!.uid)
                                    .set({
                                  //    _taskfirestore.collection('docter/'+user.uid+'/'+'user'+'/').add('user':"ubking"),
                                  'uid': user.uid,
                                  'name': t_name,
                                  'address': t_address,
                                  'email': user.email,
                                 // 'age': t_age,
                                //  'dob': c_date,
                                  'password': t_password
                                }).then((value) => print("Login success"))
                              })
                                  .catchError((e) {
                                print("+++++++++" + e);
                              });
                            }
                          },
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),*/
                      Positioned(
                        top: size.height * 0.62,
                        left: size.width * 0.1,
                        child: Column(
                          children: [
                            Container(
                              width: size.width * 0.8,
                              child: TextButton(
                               /* shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                color: kPrimaryColor,*/
                                onPressed: () async {
                                  //  signUp(t_email.text,t_password.text);
                                  if(status == false){
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>AdvanceCustomAlert());
                                  }else{
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        userCredential = await _auth
                                            .createUserWithEmailAndPassword(
                                          email: t_email!,
                                          password: t_password!,
                                        );
                                        showLoadingDialog(context: context);
                                        /*    await auth
                                      .signInWithEmailAndPassword(
                                      email: t_email, password: t_password)

                                      .then((value) => _prefService.createCache(2))
                                      .then((uid) => {
                                    print("Login Successful"),
                                    Fluttertoast.showToast(
                                        msg: "Login Successful",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: kPrimaryColor,
                                        textColor: Colors.white,
                                        fontSize: 16.0),
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>Demo()
                                        // Docter_Home()
                                      ),
                                    ),
                                  })
                                      .catchError((e) {
                                       hideLoadingDialog(context: context);
                                    print("utsav====="+e);
                                  });*/
                                      } on FirebaseAuthException catch (error) {
                                        print("FirebaseError: " + error.code);
                                        if (error.code == "invalid-email") {
                                          errorMessage =
                                          "Your email address appears to be malformed.";
                                        } else if (error.code ==
                                            "user-disabled") {
                                          errorMessage =
                                          "User with this email has been disabled.";
                                        } else if (error.code ==
                                            "too-many-requests") {
                                          errorMessage = "Too many requests";
                                        } else if (error.code ==
                                            "email-already-in-use") {
                                          errorMessage = "email already in use";
                                        }
                                        Fluttertoast.showToast(
                                            msg: errorMessage.toString());
                                        hideLoadingDialog(context: context);


                                        print("error data" + error.code);
                                        setState(() {});
                                      }


                                      var url;

                                      if (file != null) {
                                        url = await uploadImage();
                                        print("URL ===== " + url.toString());
                                        //map['profileImage'] = url;
                                      }
                                     /* FirebaseFirestore firebaseFirestore =
                                          FirebaseFirestore.instance;
                                      firebaseFirestore
                                          .collection('doctor')
                                          .doc(userCredential.user!.uid)
                                          .set({
                                        'uid': userCredential.user!.uid,
                                        'name': t_name,
                                        'last name': t_lname,
                                        'phone': phoneController,
                                        'address': t_address,
                                        'email': userCredential.user!.email,
                                        'experience': t_experience,
                                        'specialist': dropdownValue,
                                        'password': t_password,
                                        'description': t_description,
                                        'profileImage':url
                                      })
                                          .then((value) => Fluttertoast.showToast(
                                          msg: "Registration Successful",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: kPrimaryColor,
                                          textColor: Colors.white,
                                          fontSize: 16.0))
                                          .then((value) =>Navigator.pushAndRemoveUntil<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) => Docterlogin()),
                                              (route) => false))
                                          .catchError((e) {
                                        print("+++++++++" + e);
                                      });*/

                                      FirebaseFirestore firebaseFirestore =
                                          FirebaseFirestore.instance;
                                      firebaseFirestore
                                          .collection('pending_doctor')
                                       /*   .doc(userCredential.user!.uid)*/
                                          .add({
                                        'uid': userCredential.user!.uid,
                                        'name': t_name,
                                        'last name': t_lname,
                                        'phone': phoneController,
                                        'address': t_address,
                                        'email': userCredential.user!.email,
                                        'experience': t_experience,
                                        'specialist': dropdownValue,
                                        'password': t_password,
                                        'description': t_description,
                                        'profileImage':url == null?false:url,
                                        'rating':'0.0'
                                      })
                                          .then((value) => Fluttertoast.showToast(
                                          msg: "Your data is verify process. Login after A Few time.",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: kPrimaryColor,
                                          textColor: Colors.white,
                                          fontSize: 16.0))
                                          .then((value) =>Navigator.pushAndRemoveUntil<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) => Docterlogin()),
                                              (route) => false))
                                          .catchError((e) {
                                        print("+++++++++" + e);
                                      });

                                    }
                                  }

                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 2,
                              width: 150,
                              color: kPrimaryLightColor,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<String> uploadImage() async {
    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref()
        .child("doctor")
        .child(
        FirebaseAuth.instance.currentUser!.uid + "_" + basename(file.path))
        .putFile(file);

    return taskSnapshot.ref.getDownloadURL();
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
}

