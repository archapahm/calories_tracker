import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late String id;
  late String name;
  late String? email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  UserModel.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    id = documentSnapshot.id;
    name = documentSnapshot["name"];
    email = documentSnapshot["email"];
    print('UserModel.fromDocumentSnapshot: name= $name');
  }
}
