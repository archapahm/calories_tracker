// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:calories_tracker/models/user.dart';
import 'package:calories_tracker/services/database.dart';

class Authorization {
  final auth.FirebaseAuth authInst = auth.FirebaseAuth.instance;

  void listen() {
    authInst.authStateChanges().listen((auth.User? user) {
      if (user == null) {
        print('Authorization listen; No User is signed in');
      } else {
        print('Authorization listen; user id: ${user.uid}');
        print('Authorization listen; user email: ${user.email}');
      }
    });
  }

  Future<bool> createUser(String name, String email, String password) async {
    try {
      auth.UserCredential credential =
          await authInst.createUserWithEmailAndPassword(
              email: email.trim(), password: password);
      credential.user!.updateDisplayName(name);
      UserModel userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: credential.user!.email,
      );
      await Database().createNewUser(userModel);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> logIn(String email, String password) async {
    try {
      auth.UserCredential credential = await authInst
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      print('login user ${credential.user}');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> logOut() async {
    try {
      await authInst.signOut();
      print('logout user ${authInst.currentUser}');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
