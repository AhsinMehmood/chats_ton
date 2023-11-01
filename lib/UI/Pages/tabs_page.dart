import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/Pages/calls_page.dart';
import 'package:chats_ton/UI/Pages/chats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../Global/color.dart';
import '../../Global/var.dart';
import '../../Models/language_model.dart';
import '../../Providers/app_provider.dart';
import 'contacts_page.dart';
import 'groupes_page.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    // _connectChatUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);

    AppColor app = AppColor();
    List<Widget> _body = [
      const ChatsPage(),
      const GroupesPages(),
      const CallsPage(),
      const ContactsPage(),
      Container(),
    ];

    return Scaffold(
      body: _body[appProvider.tabIndex],
      bottomNavigationBar: Card(
        elevation: 6.0,
        color: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        margin: const EdgeInsets.only(
          bottom: 0,
        ),
        child: Container(
          height: 60,
          width: Get.width,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 25,
            right: 25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      appProvider.changeTabIndex(0);
                    },
                    child: Image.asset(
                      'assets/chats_icon.png',
                      height: 24,
                      width: 24,
                      color: appProvider.tabIndex == 0
                          ? app.changeColor(color: app.purpleColor)
                          : null,
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  InkWell(
                    onTap: () {
                      appProvider.changeTabIndex(1);
                    },
                    child: Image.asset(
                      'assets/groups.png',
                      height: 24,
                      width: 24,
                      color: appProvider.tabIndex == 1
                          ? app.changeColor(color: app.purpleColor)
                          : null,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      appProvider.changeTabIndex(3);
                    },
                    child: SvgPicture.asset(
                      'assets/people.svg',
                      height: 24,
                      width: 24,
                      color: appProvider.tabIndex == 3
                          ? app.changeColor(color: app.purpleColor)
                          : null,
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  InkWell(
                    onTap: () {
                      appProvider.changeTabIndex(4);
                    },
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(
                            color: app.changeColor(color: app.purpleColor),
                          )),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: CachedNetworkImage(
                          imageUrl: userModel.imageUrl,
                          // color: appProvider.tabIndex == 4
                          //     ? app.changeColor(color: app.purpleColor)
                          //     : null,
                          height: 28,
                          width: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.rotate(
        angle: 45,
        child: Card(
          color: app.changeColor(color: app.purpleColor),
          elevation: 3.0,
          shadowColor: app.changeColor(color: app.purpleColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          child: InkWell(
            onTap: () {
              appProvider.changeTabIndex(2);
            },
            child: Container(
              height: 61,
              width: 60,
              decoration: BoxDecoration(
                color: app.changeColor(color: app.purpleColor),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Center(
                child: Transform.rotate(
                    angle: 5, child: SvgPicture.asset('assets/calls_icon.svg')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
