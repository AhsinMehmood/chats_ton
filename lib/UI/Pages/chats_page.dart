import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Models/chats_model.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/Providers/group_provider.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stf;
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../../Global/color.dart';
import '../../../Models/user_model.dart';

import '../../Global/var.dart';
import '../Widgets/chat_list_widget.dart';
import '../Widgets/status_list.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);

    AppColor app = AppColor();
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          height: Get.height,
          width: Get.width,
          color: app.changeColor(color: app.purpleColor),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        height: 44,
                        width: 44,
                      ),
                      Text(
                        'Chats',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          // SharedPreferences sharedPreferences =
                          //     await SharedPreferences.getInstance();
                          // sharedPreferences.clear();
                          // FirebaseAuth.instance.signOut();
                          // stf.StreamChat.of(context).client.disconnectUser();
                          // StreamVideo.reset(disconnect: true);
                          // Get.offAll(() => SplashScreen());
                          // GroupProvider().saveDataToFirebase();
                          // SharedPreferences
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(250),
                          child: CachedNetworkImage(
                            imageUrl: userModel.imageUrl,
                            height: 44,
                            width: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const StatusList(
                    // userModel: userModel,
                    ),
              ],
            ),
          ),
        ),
        ChatListWidget(app: app),
      ],
    );
  }

  void onUserLogin(String userId, String userName) {
    /// 1.2.1. initialized ZegoUIKitPrebuiltCallInvitationService
    /// when app's user is logged in or re-logged in
    /// We recommend calling this method as soon as the user logs in to your app.
  }
}
