import 'package:flutter/material.dart';
import 'package:calories_tracker/services/authorization.dart';
import 'package:calories_tracker/views/login.dart';
import 'package:calories_tracker/views/home.dart';

class Root extends StatelessWidget {
  final Authorization auth = Authorization();
  @override
  Widget build(BuildContext context) {
    auth.listen();
    print('User = ${auth.authInst.currentUser}');
    if (auth.authInst.currentUser == null) {
      return Login();
    } else {
      return Home();
    }
  }
}
