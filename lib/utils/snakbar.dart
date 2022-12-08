import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Snakbar{
  static Snakbar? _instance;

  factory Snakbar() {
    _instance ??= Snakbar._();
    return _instance!;
  }

  Snakbar._();

  void showSuccessSnakbar({required BuildContext context, required String success_message}){
    OverlayState? state = Overlay.of(context);
    if(state != null) {
      showTopSnackBar(
        state,
        CustomSnackBar.success(
          message:success_message,
        ),
      );
    }
  }
  void showInfoSnakbar({required BuildContext context, required String info_message}){
    OverlayState? state = Overlay.of(context);
    if(state != null) {
      showTopSnackBar(
        state,
        CustomSnackBar.info(
          message:info_message,
        ),
      );
    }
  }
  void showErrorSnakbar({required BuildContext context, required String error_message}){
    OverlayState? state = Overlay.of(context);
    if(state != null) {
      showTopSnackBar(
        state,
        CustomSnackBar.error(
          message: error_message,
        ),
      );
    }
  }
}