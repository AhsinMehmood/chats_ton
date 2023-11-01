// ignore_for_file: use_build_context_synchronously

import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/UI/Pages/message_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class GroupProvider with ChangeNotifier {
  final List<UserModel> _selectedmembers = [];
  List<UserModel> get selectedMembers => _selectedmembers;
  selectedMemeber(UserModel userModel) async {
    if (_selectedmembers.contains(userModel)) {
      _selectedmembers.remove(userModel);
    } else {
      _selectedmembers.add(userModel);
    }
    notifyListeners();
  }

  Future<void> createNewGroup(
      {required String groupName,
      required String currentUserId,
      required String groupImageUrl,
      required BuildContext context}) async {
    List<String> memebrIds = [];
    for (var element in _selectedmembers) {
      memebrIds.add(element.userId);
    }
    final client = StreamChat.of(context).client;
    memebrIds.add(currentUserId);
    final channel = client.channel(
      "groups",
      extraData: {
        "name": groupName,
        "image": groupImageUrl,
        "members": memebrIds,
      },
    );

    await channel.watch(presence: true);
    Get.close(2);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return StreamChannel(
        channel: channel,
        child: const ChannelPage(),
      );
    }));
  }
}
