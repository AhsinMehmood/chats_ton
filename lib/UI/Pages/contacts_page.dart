import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/Providers/voice_call_provider.dart';

import 'package:chats_ton/UI/Pages/message_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../Global/color.dart';
import '../../Models/chats_model.dart';
import '../../Models/user_model.dart';
import '../../Providers/app_provider.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    // getContacts();
  }

  // getContacts() async {
  //   await Provider.of<ContactsProvider>(context, listen: false)
  //       .getContactDetailsFromFirestore();
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    final List<ChatsModel> chatsList = Provider.of<List<ChatsModel>>(context);

    final ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context);

    AppColor app = AppColor();
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          height: Get.height,
          width: Get.width,
          color: app.changeColor(color: app.purpleColor),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/user-add.svg',
                      color: app.changeColor(color: app.purpleColor),
                    ),
                    Text(
                      'Contacts',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    InkWell(
                        onTap: () async {
                          // print('object');
                        },
                        child: SvgPicture.asset('assets/user-add.svg')),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Container(
              height: Get.height - 120,
              width: Get.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  )),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 0,
                  ),
                  Container(
                    height: 3,
                    width: 30,
                    color: app.changeColor(color: 'E6E6E6'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'My Contacts',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                  StreamBuilder<List<UserModel>>(
                      stream: ContactsProvider()
                          .contactsDetailsStream(userModel.contacts),
                      builder:
                          (context, AsyncSnapshot<List<UserModel>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Expanded(
                              child: Center(
                            child: CircularProgressIndicator(),
                          ));
                        }
                        if (!snapshot.hasData) {
                          return const Expanded(
                              child: Center(
                            child: Text('No Contacts on ChatsTon'),
                          ));
                        }
                        List<UserModel> contactDetailsStream = snapshot.data!;
                        print(contactDetailsStream.length);

                        return Expanded(
                          child: ListView.builder(
                            itemCount: contactDetailsStream.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              UserModel contactDetails =
                                  contactDetailsStream[index];

                              return ListTile(
                                onTap: () async {
                                  // Get.to(() => const OtherUserInfo());
                                  final client = StreamChat.of(context).client;

                                  final channel = client.channel(
                                    "messaging",
                                    id: userModel.userId +
                                        contactDetails.userId,
                                    extraData: {
                                      // "name":
                                      //     '${contactDetails.firstName} ${contactDetails.lastName}',
                                      // "image": contactDetails.imageUrl,
                                      "members": [
                                        userModel.userId,
                                        contactDetails.userId
                                      ],
                                    },
                                  );

                                  await channel.watch(presence: true);

                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return StreamChannel(
                                      channel: channel,
                                      child: const ChannelPage(),
                                    );
                                  }));
                                  // VoiceCallProvider().initiateCall(
                                  //     'audio', userModel, contactDetails);
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: CachedNetworkImage(
                                    imageUrl: contactDetails.imageUrl,
                                    height: 52,
                                    width: 52,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  '${contactDetails.firstName} ${contactDetails.lastName}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                subtitle: Text(
                                  contactDetails.bio,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              );
                            },
                          ),
                        );
                      })
                ],
              ),
            ))
      ],
    );
  }
}
