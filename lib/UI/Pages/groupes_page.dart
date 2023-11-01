import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/UI/Pages/create_group_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../Models/user_model.dart';
import 'message_page.dart';

class GroupesPages extends StatefulWidget {
  const GroupesPages({super.key});

  @override
  State<GroupesPages> createState() => _GroupesPagesState();
}

class _GroupesPagesState extends State<GroupesPages> {
  late final _listController = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.and([
      Filter.equal('type', 'groups'),
      // Filter.contains('key', value)
      Filter.in_(
        'members',
        [StreamChat.of(context).currentUser!.id],
      ),
    ]),
    sort: const [SortOption('last_message_at')],
    limit: 50,
  );
  @override
  Widget build(BuildContext context) {
    AppColor app = AppColor();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Get.height,
            padding: const EdgeInsets.all(13),
            width: Get.width,
            color: app.changeColor(color: app.purpleColor),
            child: upperCard(context),
          ),
          Positioned(
            top: 100,
            child: Container(
              height: Get.height,
              padding: const EdgeInsets.all(13),
              width: Get.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: lowerCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget lowerCard(context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'My Groups',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Expanded(
          child: StreamChannelListView(
            controller: _listController,
            shrinkWrap: true,
            emptyBuilder: (context) {
              return const Center(
                child: Text('No Groups Yet!'),
              );
            },
            itemBuilder: (context, items, index, defaultWidget) {
              final channel = items[index];

              return defaultWidget.copyWith(
                onTap: () {
                  Get.to(() => StreamChannel(
                      showLoading: false,
                      channel: channel,
                      child: const ChannelPage()));
                },
                channel: channel,
                leading: StreamChannelAvatar(channel: channel),
                contentPadding: const EdgeInsets.only(left: 15, right: 15),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget groupsChatCard(context) {
    final UserModel userModel = Provider.of<UserModel>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(250),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(250),
            child: CachedNetworkImage(
              imageUrl: userModel.imageUrl,
              height: 52,
              width: 52,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          'Graphic Designing',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Ali: Hey how are you?',
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColor().changeColor(color: '797C7B')),
        ),
      ),
    );
  }

  Widget upperCard(context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.search,
              color: Colors.white,
            ),
            Text(
              'Groups',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => const CreateGroupPage());
              },
              icon: const Icon(
                Icons.add,
              ),
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}
