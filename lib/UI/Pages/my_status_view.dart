import 'package:chats_ton/Models/status_model.dart';
import 'package:chats_ton/Models/story_item.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/UI/Widgets/story_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Global/color.dart';

class MyStatusView extends StatelessWidget {
  // final List<StatusModel> statusList;

  const MyStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    AppColor app = AppColor();
    final UserModel userModel = Provider.of<UserModel>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        // width: Get.width,
        height: Get.height,
        child: FlutterStoryView(
            // storyItems: [],
            onComplete: () {
              print("Completed");
              Get.back();
            }, // called when stories completed
            onPageChanged: (index) {
              print("currentPageIndex = $index");
            }, // returns current page index
            caption:
                "This is very beautiful STORY", // optional caption will be show up on first story item.
            // createdAt: DateTime.parse(
            //   userModel.statusList.first.timestamp,
            // ),
            enableOnHoldHide: false, // By default true
            indicatorColor:
                Colors.grey[500], // You can modify it whichever you like :)
            indicatorHeight: 2, // You can modify it whichever you like :)
            indicatorValueColor: app.changeColor(
                color:
                    app.purpleColor), // You can modify it whichever you like :)
            userInfo:
                userModel // if not specified default username and profile would be taken
            ),
      ),
    );
  }
}
