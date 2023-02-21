
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';


class CustomCard1 extends StatelessWidget {

  var profileImage;

  CustomCard1(this.profileImage);

  // CustomCard({});

  @override

  Widget build(BuildContext context) {
    return Container(
            margin: EdgeInsets.only(top: 5),
            child: ListTile(
              leading: CircleAvatar(
                radius: 31.00,
                backgroundColor: kPrimaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child:profileImage==false?CircleAvatar(
                    radius: 30.00,
                    backgroundImage: AssetImage('assets/images/account.png'),
                  ): CircleAvatar(
                    radius: 30.00,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                ),
              ),
            )
    );
  }
}