import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jr_linguist/controllers/providers/user_provider.dart';
import 'package:jr_linguist/screens/authentication/login_screen.dart';
import 'package:jr_linguist/utils/my_print.dart';
import 'package:jr_linguist/utils/snakbar.dart';
import 'package:provider/provider.dart';

//To Perform Authentication Operations
class AuthenticationController {
  static AuthenticationController? _instance;

  factory AuthenticationController() {
    _instance ??= AuthenticationController._();
    return _instance!;
  }

  AuthenticationController._();

  //To Check if User is Login
  //This Method will Check if User is Login and if login and initializeUserid is True then it will Store User data in UserProvider
  //It will Return true or false
  Future<bool> isUserLogin({bool initializeUserid = false, BuildContext? context}) async {
    User? user = FirebaseAuth.instance.currentUser;
    bool isLogin = user != null;
    if(isLogin && initializeUserid && context != null) {
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.userid = user.uid;
      userProvider.firebaseUser = user;
      //clientProvider.clientId = "CI008";
      userProvider.firebaseUser = user;
    }
    MyPrint.printOnConsole("Login:${isLogin}");
    return isLogin;
  }

  //Will Sing in with google
  //If Sign in success, will return User Object else return null
  Future<User?> signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleSignInAccount;

    try {
      googleSignInAccount = await GoogleSignIn().signIn();
    }
    catch(e) {
      MyPrint.printOnConsole("Error in Google Sign In:${e}");
      return null;
    }

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        return userCredential.user!;
      }
      on FirebaseAuthException catch (e) {
        String message = "";

        MyPrint.printOnConsole("Code:${e.code}");
        switch (e.code) {
          case "account-exists-with-different-credential" :
            {
              List<String> methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(e.email!);
              MyPrint.printOnConsole("Methods:${methods}");

              MyPrint.printOnConsole("Message:Account Already Exist With Different Method");
              Snakbar().showErrorSnakbar(context: context, error_message: "Account Already Exist With Different Method");
            }
            break;

          case "invalid-credential" :
            {
              message = "Credential is Invalid";
              MyPrint.printOnConsole("Message:Invalid Credentials");
              Snakbar().showErrorSnakbar(context: context, error_message: "Invalid Credentials");
            }
            break;

          case "operation-not-allowed" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().showErrorSnakbar(context: context, error_message: "${e.message}");
            }
            break;

          case "user-disabled" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().showErrorSnakbar(context: context, error_message: "${e.message}");
            }
            break;

          case "user-not-found" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().showErrorSnakbar(context: context, error_message: "${e.message}");
            }
            break;

          case "wrong-password" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().showErrorSnakbar(context: context, error_message: "${e.message}");
            }
            break;

          default :
            {
              message = "Error in Authentication";
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().showErrorSnakbar(context: context, error_message: "${e.message}");
            }
        }
      }

      return null;
    }
  }

  //Will logout from system and remove data from UserProvider and local memory
  Future<bool> logout(BuildContext context) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.firebaseUser = null;
    userProvider.userModel = null;
    userProvider.userid = "";

    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);

    return true;
  }
}