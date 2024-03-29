import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jr_linguist/configs/constants.dart';
import 'package:jr_linguist/models/user_model.dart';
import 'package:jr_linguist/providers/user_provider.dart';
import 'package:jr_linguist/utils/my_print.dart';
import 'package:provider/provider.dart';

class UserController {
  static UserController? _instance;

  factory UserController() {
    _instance ??= UserController._();
    return _instance!;
  }

  UserController._();

  Future<bool> isUserExist(BuildContext context, String uid) async {
    if(uid.isEmpty) return false;

    MyPrint.printOnConsole("Uid:${uid}");
    if(uid.isEmpty) return false;

    bool isUserExist = false;

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseNodes.usersDocumentReference(userId: uid).get();

      if(documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
        UserModel userModel = UserModel.fromMap(documentSnapshot.data()!);
        userProvider.userModel = userModel;
        MyPrint.printOnConsole("User Model:${userProvider.userModel}");
        isUserExist = true;
      }
      else {
        UserModel userModel = UserModel();
        userModel.id = uid;
        userModel.name = userProvider.firebaseUser?.displayName ?? "";
        userModel.mobile = userProvider.firebaseUser?.phoneNumber ?? "";
        userModel.email = userProvider.firebaseUser?.email ?? "";
        userModel.image = userProvider.firebaseUser?.photoURL ?? "";
        userModel.createdTime = Timestamp.now();
        userModel.completedQuestionsListLanguageAndTypeWise = {
          LanguagesType.hindi : {
            QuestionType.audio : [],
            QuestionType.image : [],
          },
        };
        bool isSuccess = await UserController().createUser(context, userModel);
        MyPrint.printOnConsole("Insert Client Success:${isSuccess}");
      }
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.isClientExist:${e}");
    }

    return isUserExist;
  }

  Future<bool> createUser(BuildContext context,UserModel userModel) async {
    try {
      /*Map<String, dynamic> data = {
        "ClientId" : clientModel.ClientId,
      };*/
      //if(clientModel.ClientPhoneNo.isNotEmpty) data['ClientPhoneNo'] = clientModel.ClientPhoneNo;
      //if(clientModel.ClientEmailId.isNotEmpty) data['ClientEmailId'] = clientModel.ClientEmailId;
      //data.remove("ClientId");
      Map<String, dynamic> data = userModel.toMap();

      await FirebaseNodes.usersDocumentReference(userId: userModel.id).set(data);

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.userModel = userModel;

      return true;
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.insertClient:${e}");
    }

    return false;
  }
}