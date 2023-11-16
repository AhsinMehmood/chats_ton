import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Providers/group_get_controller.dart';
import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/UI/Pages/camera_view.dart';
import 'package:chats_ton/UI/Pages/group_posts_page.dart';
import 'package:chats_ton/UI/Widgets/media_message.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

import 'package:photo_manager/photo_manager.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../Global/color.dart';
import '../../Models/user_model.dart';

import 'group_info_page.dart';

final AppColor app = AppColor();
DateTime getMessageDate(Message messge) {
  return DateTime.fromMillisecondsSinceEpoch(messge.timestamp * 1000);
}

class GroupChannelPage extends StatefulWidget {
  // final Channel streamChannal;
  final GroupModel groupModel;
  const GroupChannelPage({
    Key? key,
    required this.groupModel,
    // required this.streamChannal,
  }) : super(key: key);

  @override
  State<GroupChannelPage> createState() => _GroupChannelPageState();
}

class _GroupChannelPageState extends State<GroupChannelPage> {
  // late AnimationController _animationController;
  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    getMembersData();
  }

  getMembersData() async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    for (String element in widget.groupModel.members.keys) {
      if (element != userModel.userId) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(element)
            .get()
            .then((value) {
          setState(() {
            memebrsData.add(UserModel.fromJson(value.data()!, value.id));
          });
        });
      }
    }
  }

  ScrollController scrollController = ScrollController();
  String _formatDate(DateTime date) {
    final now = DateTime.now().toLocal();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
    }
  }

  List<UserModel> memebrsData = [];
  final messageInputController = TextEditingController();
  String messageText = '';
  final focusNode = FocusNode();
  @override
  void dispose() {
    focusNode.dispose();

    messageInputController.dispose();
    super.dispose();
  }

  bool expanded = false;

  List<GroupedMessages> groupMessages(List<Message> messages) {
    List<GroupedMessages> groupedMessages = [];

    if (messages.isEmpty) {
      return groupedMessages;
    }

    // Group the first message as "Today"
    DateTime currentDate = getMessageDate(messages[0]);
    List<Message> currentGroup = [messages[0]];

    for (int i = 1; i < messages.length; i++) {
      DateTime messageDate = getMessageDate(messages[i]);

      if (isSameDay(messageDate, currentDate)) {
        // Messages from the same day
        currentGroup.add(messages[i]);
      } else {
        // Messages from a different day, create a new group
        groupedMessages
            .add(GroupedMessages(date: currentDate, messages: currentGroup));

        // Start a new group for the current day
        currentDate = messageDate;
        currentGroup = [messages[i]];
      }
    }

    // Add the last group
    groupedMessages
        .add(GroupedMessages(date: currentDate, messages: currentGroup));

    return groupedMessages;
  }

  List<List<Message>> groupMessagesMinutes(List<Message> messages) {
    List<List<Message>> groupedMessages = [];

    if (messages.isEmpty) {
      return groupedMessages;
    }

    // Sort messages by timestamp
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Group the first message
    List<Message> currentGroup = [messages[0]];

    for (int i = 1; i < messages.length; i++) {
      Message currentMessage = messages[i - 1];
      Message nextMessage = messages[i];

      // Check if the messages have the same sender ID and the time difference is less than 5 minutes
      if (currentMessage.senderId == nextMessage.senderId &&
          getMessageDate(nextMessage)
                  .difference(getMessageDate(currentMessage))
                  .inMinutes <=
              5) {
        currentGroup.add(nextMessage);
      } else {
        // Messages from a different user or a time difference larger than 5 minutes, create a new group
        groupedMessages.add(List.from(currentGroup));

        // Start a new group for the current message
        currentGroup = [nextMessage];
      }
    }

    // Add the last group
    groupedMessages.add(List.from(currentGroup));

    return groupedMessages;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double maxToolbarHeight = 180;
  double minToolbarHeight = 50;
  // late Stream<List<UserModel>> memebrsStream;
  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final GroupService groupService = Provider.of<GroupService>(context);

    return StreamBuilder(
        initialData: widget.groupModel,
        stream: groupService.groupStream(widget.groupModel.groupChatId),
        builder: (context, snapshot) {
          final GroupModel groupModel = snapshot.data!;
          final lastMessage = groupModel.getLastMessage();
          final int unreadCount =
              groupModel.getUnreadMessageCount(userModel.userId);
          final List<Message> messages = [];
          groupService.updateLastReadTimestamp(
              widget.groupModel.groupChatId, userModel.userId);
          groupModel.messages.forEach((key, value) {
            // if(value.senderId != userModel.userId && value.status ==)
            messages.add(value);
          });

          messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          List<GroupedMessages> groupedMessages = groupMessages(messages);
          bool pendingInvite = groupModel.members.values
              .where((eleme) => eleme.memberId == userModel.userId)
              .first
              .pendingInvite;
          return WillPopScope(
            onWillPop: () async {
              groupService.updateLastReadTimestamp(
                  widget.groupModel.groupChatId, userModel.userId);
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: app.changeColor(color: app.purpleColor),
                title: InkWell(
                  onTap: () {
                    if (!pendingInvite) {
                      Get.to(() => GroupInfoPage(
                            groupModel: groupModel,
                            membersData: memebrsData,
                          ));
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        groupModel.groupName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Click here for group info',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                leading: IconButton(
                  onPressed: () {
                    groupService.updateLastReadTimestamp(
                        widget.groupModel.groupChatId, userModel.userId);
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        if (!pendingInvite) {
                          Get.to(() => GroupPosts(
                                groupModel: groupModel,
                                membersData: memebrsData,
                              ));
                        }
                      },
                      icon: SvgPicture.asset('assets/group_post.svg'))
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: pendingInvite
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                messages.last.text,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Invite Pending',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      groupService.leaveGroup(
                                          widget.groupModel.groupChatId,
                                          userModel.userId);
                                      Get.back();
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      groupService.acceptInvite(
                                          widget.groupModel.groupChatId,
                                          userModel.userId);
                                      groupService.sendMessage(
                                          groupModel.groupChatId,
                                          '${userModel.firstName} accepted group invite',
                                          userModel.userId,
                                          'system',
                                          memebrsData,
                                          userModel,
                                          groupModel);
                                    },
                                    icon: Icon(
                                      Icons.done,
                                      color: app.changeColor(
                                          color: app.purpleColor),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        : ListView.builder(
                            controller: scrollController,
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: groupedMessages.length,
                            itemBuilder: (context, index) {
                              List<Message> messages =
                                  groupedMessages[index].messages;

                              // DateTime currentMessageDate =
                              //     groupedMessages[index].date;
                              return Column(
                                children: [
                                  // if()
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Container(
                                          // width: 150,
                                          padding: const EdgeInsets.all(8.0),
                                          margin: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: Center(
                                              child: Text(_formatDate(
                                                  groupedMessages[index]
                                                      .date))),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ListView.builder(
                                      itemCount: messages.length,
                                      shrinkWrap: true,
                                      reverse: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, messageIndex) {
                                        Message message =
                                            messages[messageIndex];
                                        if (message.messageType == 'media') {
                                          return MediaMessage(
                                            group: groupModel,
                                            message: message,
                                            sameTime: false,
                                          );
                                        } else if (message.messageType ==
                                            'system') {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: app
                                                  .changeColor(
                                                      color: app.purpleColor)
                                                  .withOpacity(0.1),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(message.text),
                                              ],
                                            ),
                                          );
                                        }
                                        return MessageItem(
                                          group: groupModel,
                                          message: message,
                                          sameTime: false,
                                        );
                                      }),
                                ],
                              );
                            },
                          ),
                  ),
                  if (!pendingInvite)
                    Container(
                      height: groupService.selectedImages.isNotEmpty
                          ? 200
                          : groupService.imageFromCamers != null
                              ? 200
                              : 60,
                      width: Get.width,
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (groupService.imageFromCamers == null)
                            InkWell(
                              onTap: () async {
                                final PermissionState ps = await PhotoManager
                                    .requestPermissionExtend(); // the method can use optional param `permission`.
                                if (ps.isAuth) {
                                  final List<AssetPathEntity> paths =
                                      await PhotoManager.getAssetPathList(
                                          type: RequestType.image);

                                  Get.bottomSheet(
                                    AttatchmentSheet(paths: paths),
                                    isScrollControlled: true,
                                  );
                                } else if (ps.hasAccess) {
                                } else {}
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color:
                                      app.changeColor(color: app.purpleColor),
                                ),
                                child: Center(
                                    child: SvgPicture.asset(
                                  'assets/Clip_icon.svg',
                                  color: Colors.white,
                                )),
                              ),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                if (groupService.selectedImages.isNotEmpty)
                                  Container(
                                    height: 150,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        shrinkWrap: true,
                                        itemCount:
                                            groupService.selectedImages.length,
                                        itemBuilder: (context, index) {
                                          GalleryPickedMedia file = groupService
                                              .selectedImages[index];
                                          return Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Stack(
                                                  children: [
                                                    Image.memory(file.thumbnail,
                                                        height: 150,
                                                        width: 120,
                                                        fit: BoxFit.cover),
                                                    InkWell(
                                                      onTap: () {
                                                        groupService
                                                            .selectImage(file);
                                                      },
                                                      child: Container(
                                                        height: 22,
                                                        margin: const EdgeInsets
                                                            .only(
                                                            top: 5, left: 10),
                                                        width: 22,
                                                        decoration: BoxDecoration(
                                                            color: app.changeColor(
                                                                color: app
                                                                    .purpleColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        200)),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                if (groupService.imageFromCamers != null)
                                  Container(
                                    height: 150,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          Image.file(
                                            groupService.imageFromCamers!,
                                            height: 150,
                                            width: 120,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              groupService
                                                  .clearImageFromCamera();
                                            },
                                            child: Container(
                                              height: 22,
                                              margin: const EdgeInsets.only(
                                                  top: 5, left: 10),
                                              width: 22,
                                              decoration: BoxDecoration(
                                                  color: app.changeColor(
                                                      color: app.purpleColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          200)),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                CupertinoTextField(
                                  controller: messageInputController,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  onTapOutside: (PointerDownEvent b) {
                                    // FocusScope.of(context).unfocus();
                                  },
                                  maxLines:
                                      12, // Allows the TextField to expand dynamically
                                  placeholder: 'Type here...',
                                  placeholderStyle: GoogleFonts.poppins(
                                      color: Colors.grey, fontSize: 14),
                                  style: GoogleFonts.poppins(
                                      color: Colors.black, fontSize: 14),
                                  onChanged: (text) {
                                    setState(() {
                                      messageText = text;
                                    });
                                  },
                                )
                              ])),
                          if (messageText.isEmpty &&
                              groupService.imageFromCamers == null)
                            const SizedBox(
                              width: 10,
                            ),
                          if (messageText.isEmpty &&
                              groupService.imageFromCamers == null &&
                              groupService.selectedImages.isEmpty)
                            InkWell(
                              onTap: () async {
                                Get.to(() => const CameraApp());
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color:
                                      app.changeColor(color: app.purpleColor),
                                ),
                                child: Center(
                                    child: SvgPicture.asset(
                                  'assets/Camera.svg',
                                  color: Colors.white,
                                )),
                              ),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              if (groupService.imageFromCamers != null ||
                                  groupService.selectedImages.isNotEmpty) {
                                print('One side image selected');
                                groupService.sendMediaMessage(
                                    groupModel.groupChatId,
                                    messageInputController.text.trim(),
                                    userModel.userId,
                                    'media',
                                    memebrsData,
                                    userModel,
                                    groupService.selectedImages);
                                setState(() {
                                  messageInputController.clear();
                                  messageText = '';
                                });
                                scrollController.animateTo(0,
                                    duration: const Duration(milliseconds: 750),
                                    curve: Curves.linear);
                              } else if (messageInputController
                                  .text.isNotEmpty) {
                                groupService.sendMessage(
                                    groupModel.groupChatId,
                                    messageInputController.text.trim(),
                                    userModel.userId,
                                    'text',
                                    memebrsData,
                                    userModel,
                                    groupModel);
                                setState(() {
                                  messageInputController.clear();
                                  messageText = '';
                                });

                                scrollController.animateTo(0,
                                    duration: const Duration(milliseconds: 750),
                                    curve: Curves.linear);
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              padding: const EdgeInsets.only(
                                left: 1,
                                bottom: 1,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: app.changeColor(color: app.purpleColor),
                              ),
                              child: Center(
                                  child: Transform.rotate(
                                angle: 5.5,
                                child: SvgPicture.asset(
                                  'assets/Send_icon.svg',
                                  color: Colors.white,
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}

class AttatchmentSheet extends StatefulWidget {
  const AttatchmentSheet({
    super.key,
    required this.paths,
  });

  final List<AssetPathEntity> paths;

  @override
  State<AttatchmentSheet> createState() => _AttatchmentSheetState();
}

class _AttatchmentSheetState extends State<AttatchmentSheet> {
  List<AssetEntity> _assets = [];
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    if (widget.paths.isNotEmpty) {
      // Get assets from the first album (you can choose a specific album)
      _assets = await widget.paths[selectedIndex]
          .getAssetListPaged(page: 0, size: 200);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final GroupService groupService = Provider.of<GroupService>(context);
    return BottomSheet(
        onClosing: () {},
        builder: (context) {
          return Container(
            height: Get.height * 0.9,
            width: Get.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        groupService.clearGalleryImages();
                        Get.close(1);
                      },
                      icon: const Icon(Icons.close),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.close(1);
                      },
                      icon: Icon(
                        Icons.done,
                        color: app.changeColor(color: app.purpleColor),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  width: Get.width,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < widget.paths.length; i++)
                        InkWell(
                          onTap: () {
                            selectedIndex = i;
                            _fetchGallery();
                          },
                          child: Container(
                            height: 35,
                            margin: const EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                            ),
                            padding: const EdgeInsets.only(left: 7, right: 7),
                            decoration: BoxDecoration(
                              color: selectedIndex == i
                                  ? app.changeColor(color: app.purpleColor)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                widget.paths[i].name,
                                style: GoogleFonts.poppins(
                                  color: selectedIndex == i
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: _assets.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return _assets[index].type == AssetType.image
                          ? ImageItem(asset: _assets[index])
                          : VideoItem(asset: _assets[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class VideoItem extends StatefulWidget {
  final AssetEntity asset;

  const VideoItem({super.key, required this.asset});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  Uint8List? thumbnail;
  File? file;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getThumbnail();
  }

  getThumbnail() async {
    await widget.asset.file.then((fil) {
      setState(() {
        file = fil;
      });
    });
    await widget.asset.thumbnailData.then((value) {
      setState(() {
        thumbnail = value;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final GroupService groupService = Provider.of<GroupService>(context);

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(thumbnail!, fit: BoxFit.cover),
        // if (groupService.selectedImageFromGalleryPaths.contains(file!.path))
        InkWell(
          onTap: () {
            try {
              groupService.selectImage(GalleryPickedMedia(
                  thumbnail: thumbnail!,
                  mediaFile: file!,
                  mimeType: widget.asset.mimeType!));
            } catch (e) {
              print(e);
            }
          },
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 25,
              width: 25,
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: groupService.selectedImages.contains(
                          GalleryPickedMedia(
                              thumbnail: thumbnail!,
                              mediaFile: file!,
                              mimeType: widget.asset.mimeType!))
                      ? app.changeColor(color: app.purpleColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(200),
                  border: groupService.selectedImages.contains(
                          GalleryPickedMedia(
                              thumbnail: thumbnail!,
                              mediaFile: file!,
                              mimeType: widget.asset.mimeType!))
                      ? null
                      : Border.all(
                          color: app.changeColor(color: app.purpleColor))),
              child: groupService.selectedImages.contains(GalleryPickedMedia(
                      thumbnail: thumbnail!,
                      mediaFile: file!,
                      mimeType: widget.asset.mimeType!))
                  ? const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 15,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: IconButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    return app.changeColor(color: app.purpleColor);
                  },
                ),
              ),
              onPressed: () async {
                File? file = await widget.asset.file;
                Get.to(FileVideoPlayer(
                  file: file!,
                ));
              },
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
              )),
        )
      ],
    );
  }
}

class FileVideoPlayer extends StatefulWidget {
  final File file;
  const FileVideoPlayer({super.key, required this.file});

  @override
  // ignore: library_private_types_in_public_api
  _FileVideoPlayerState createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(() {
      setState(() {});
    });
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(_controller.value.position),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return app.changeColor(color: app.purpleColor);
                      },
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                Text(
                  formatDuration(_controller.value.duration),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: _controller.value.position.inSeconds.toDouble(),
            min: 0,
            max: _controller.value.duration.inSeconds.toDouble(),
            onChanged: (value) {
              setState(() {
                _controller.seekTo(Duration(seconds: value.toInt()));
              });
            },
          ),
          // VideoControlPanel(message: message)
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class ImageItem extends StatefulWidget {
  final AssetEntity asset;

  const ImageItem({super.key, required this.asset});

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  Uint8List? thumbnail;
  bool loading = true;
  File? file;
  @override
  void initState() {
    super.initState();
    getThumbnail();
  }

  getThumbnail() async {
    await widget.asset.file.then((fil) {
      setState(() {
        file = fil;
      });
    });
    await widget.asset.thumbnailData.then((value) {
      setState(() {
        thumbnail = value;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final GroupService groupService = Provider.of<GroupService>(context);

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(thumbnail!, fit: BoxFit.cover),
        InkWell(
          onTap: () {
            try {
              groupService.selectImage(GalleryPickedMedia(
                  thumbnail: thumbnail!,
                  mediaFile: file!,
                  mimeType: widget.asset.mimeType!));
            } catch (e) {
              print(e);
            }
          },
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 25,
              width: 25,
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: groupService.selectedImages.contains(
                          GalleryPickedMedia(
                              thumbnail: thumbnail!,
                              mediaFile: file!,
                              mimeType: widget.asset.mimeType!))
                      ? app.changeColor(color: app.purpleColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(200),
                  border: groupService.selectedImages.contains(
                          GalleryPickedMedia(
                              thumbnail: thumbnail!,
                              mediaFile: file!,
                              mimeType: widget.asset.mimeType!))
                      ? null
                      : Border.all(
                          color: app.changeColor(color: app.purpleColor))),
              child: groupService.selectedImages.contains(GalleryPickedMedia(
                      thumbnail: thumbnail!,
                      mediaFile: file!,
                      mimeType: widget.asset.mimeType!))
                  ? const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 15,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final AssetEntity asset;

  const FullScreenImage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.originBytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.contain);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class MessageItem extends StatelessWidget {
  final Message message;
  final GroupModel group;
  final bool sameTime;

  const MessageItem(
      {super.key,
      required this.group,
      required this.sameTime,
      required this.message});

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    return Row(
      mainAxisAlignment: message.senderId == userModel.userId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (message.senderId != userModel.userId && message.status != 'sending')
          StreamBuilder<UserModel>(
              initialData: userModel,
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(message.senderId)
                  .snapshots()
                  .map((event) => UserModel.fromJson(event.data()!, event.id)),
              builder: (context, snapshot) {
                UserModel memberData = snapshot.data == null
                    ? UserModel.fromJson({}, '')
                    : snapshot.data!;
                return Column(
                  crossAxisAlignment: message.senderId == userModel.userId
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (sameTime)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: CachedNetworkImage(
                                imageUrl: memberData.imageUrl,
                                height: 22,
                                width: 22,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              memberData.firstName,
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                        // minWidth: 230,
                      ),
                      child: Container(
                        // width: Get.width * 0.5,
                        margin: message.senderId == userModel.userId
                            ? const EdgeInsets.only(right: 10, top: 10)
                            : const EdgeInsets.only(left: 10, top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message.senderId == userModel.userId
                              ? app.changeColor(color: app.purpleColor)
                              : app.changeColor(color: 'F2F7FB'),
                          borderRadius: message.senderId == userModel.userId
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                )
                              : const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                        ),
                        child: Text(
                          message.status == 'deleted'
                              ? 'Message Deleted'
                              : message.text,
                          style: GoogleFonts.poppins(
                            color: message.senderId == userModel.userId
                                ? Colors.white
                                : app.changeColor(color: '000E08'),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: message.senderId == userModel.userId
                          ? const EdgeInsets.only(right: 10, top: 0)
                          : const EdgeInsets.only(left: 15, top: 0),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('hh:mm a')
                                .format(getMessageDate(message).toLocal()),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        if (message.senderId == userModel.userId)
          InkWell(
            onDoubleTap: () {
              GroupService().updateMessageStatus(
                  message.messageId, group.groupChatId, 'deleted');
            },
            child: Column(
              crossAxisAlignment: message.senderId == userModel.userId
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                //  Text(memberData.firstName),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    // minWidth: 230,
                  ),
                  child: Container(
                    // width: Get.width * 0.5,
                    margin: message.senderId == userModel.userId
                        ? const EdgeInsets.only(right: 10, top: 10)
                        : const EdgeInsets.only(left: 10, top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message.senderId == userModel.userId
                          ? app.changeColor(color: app.purpleColor)
                          : app.changeColor(color: 'F2F7FB'),
                      borderRadius: message.senderId == userModel.userId
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                          : const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                    ),
                    child: Text(
                      message.status == 'deleted'
                          ? 'Message Deleted'
                          : message.text,
                      style: GoogleFonts.poppins(
                        color: message.senderId == userModel.userId
                            ? Colors.white
                            : app.changeColor(color: '000E08'),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: message.senderId == userModel.userId
                      ? const EdgeInsets.only(right: 10, top: 0)
                      : const EdgeInsets.only(left: 10, top: 0),
                  child: Row(
                    children: [
                      // if(getMessageDate(message).toLocal() == )
                      // if (DateTime.now()
                      //         .difference(getMessageDate(message).toLocal())
                      //         .inMinutes >
                      //     1)
                      Text(
                        DateFormat('hh:mm a')
                            .format(getMessageDate(message).toLocal()),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 10,
                        ),
                      ),
                      if (message.senderId == userModel.userId)
                        Column(
                          children: [
                            if (message.status == 'sending')
                              Container(
                                height: 4,
                                width: 4,
                                child: CupertinoActivityIndicator(
                                    color: app.changeColor(
                                        color: app.purpleColor)),
                              ),
                            if (message.status == 'sent')
                              const Icon(
                                Icons.done,
                                size: 14,
                              ),
                            if (message.status == 'delivered')
                              Icon(
                                Icons.done_all,
                                size: 14,
                                color: group.members.values
                                            .where((element) =>
                                                element.memberId !=
                                                userModel.userId)
                                            .first
                                            .lastReadTimestamp ==
                                        message.timestamp
                                    ? app.changeColor(color: app.purpleColor)
                                    : Colors.black,
                              ),
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
