import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Snakbar{
  static showCustomTopSnackBar({required BuildContext context, required Widget child, Duration displayDuration = const Duration(milliseconds: 3000), 
    Duration showOutAnimationDuration = const Duration(milliseconds: 1200), Duration hideOutAnimationDuration = const Duration(milliseconds: 550),}) {

    OverlayState? state = Overlay.of(context);

    if(state != null) {
      showTopSnackBar(
        state,
        child,
        displayDuration: displayDuration,
        reverseAnimationDuration: hideOutAnimationDuration,
        animationDuration: showOutAnimationDuration,
      );
    }
  }

  static void showSuccessSnakbar({required BuildContext context, required String msg, Duration displayDuration = const Duration(milliseconds: 3000), 
    Duration showOutAnimationDuration = const Duration(milliseconds: 1200), Duration hideOutAnimationDuration = const Duration(milliseconds: 550),}){

    showCustomTopSnackBar(
      context: context,
      child: CustomSnackBar.success(
        message:msg,
      ),
    );
  }

  static void showInfoSnakbar({required BuildContext context, required String msg}){
    showCustomTopSnackBar(
      context: context,
      child: CustomSnackBar.info(
        message:msg,
      ),
    );
  }

  static void showErrorSnakbar({required BuildContext context, required String msg}){
    showCustomTopSnackBar(
      context: context,
      child: CustomSnackBar.error(
        message:msg,
      ),
    );
  }
}