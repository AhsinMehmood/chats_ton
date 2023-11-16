import 'package:chats_ton/Global/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Dialog(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          height: 100,
          width: Get.width * 0.2,
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor:
                  AppColor().changeColor(color: AppColor().purpleColor),
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color loadingColor;

  const LoadingWidget(
      {Key? key,
      required this.backgroundColor,
      this.loadingColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(8),
      width: 60,
      height: 60,
      child: Center(
        child: CircularProgressIndicator(
          color: loadingColor,
        ),
      ),
    );
  }
}
