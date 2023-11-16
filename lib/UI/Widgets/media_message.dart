import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../Providers/group_get_controller.dart';

final AppColor app = AppColor();
DateTime getMessageDate(Message messge) {
  return DateTime.fromMillisecondsSinceEpoch(messge.timestamp * 1000);
}

class MediaMessage extends StatelessWidget {
  final Message message;
  final GroupModel group;
  final bool sameTime;

  const MediaMessage(
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
        if (message.senderId != userModel.userId)
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
              GroupService()
                  .deleteMessage(message.messageId, group.groupChatId);
            },
            child: Column(
              crossAxisAlignment: message.senderId == userModel.userId
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                //  Text(memberData.firstName),

                Container(
                    height: 250,
                    width: 270,
                    margin: message.senderId == userModel.userId
                        ? const EdgeInsets.only(right: 10, top: 10)
                        : const EdgeInsets.only(left: 10, top: 10),
                    // padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: message.senderId == userModel.userId
                            ? app.changeColor(color: app.purpleColor)
                            : app.changeColor(color: 'F2F7FB'),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        )),
                    child: message.medias.values.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: PageView(
                                    children: [
                                      for (Media mediaMessage
                                          in message.medias.values)
                                        InkWell(
                                          onTap: () {
                                            if (mediaMessage.type
                                                .contains('image')) {
                                              Get.to(() => FullScreenMedia(
                                                    index: 0,
                                                    message: message,
                                                  ));
                                            } else {
                                              Get.to(() => FileVideoPlayer(
                                                  url: mediaMessage.fileUrl));
                                            }
                                          },
                                          child: CachedNetworkImage(
                                            imageUrl: mediaMessage.thumbnailUrl,
                                            height: 250,
                                            fit: BoxFit.cover,
                                            width: 270,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, top: 4, bottom: 4, right: 6),
                                  child: Text(
                                    message.status == 'deleted'
                                        ? 'Message Deleted'
                                        : message.text,
                                    style: GoogleFonts.poppins(
                                      color: message.senderId ==
                                              userModel.userId
                                          ? Colors.white
                                          : app.changeColor(color: '000E08'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
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
                              Column(
                                children: [
                                  Container(
                                    height: 4,
                                    margin: const EdgeInsets.all(4),
                                    width: 4,
                                    child: CupertinoActivityIndicator(
                                        color: app.changeColor(
                                            color: app.purpleColor)),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
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

class FullScreenMedia extends StatelessWidget {
  final Message message;
  final int index;
  const FullScreenMedia(
      {super.key, required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: index);
    List<Media> medias = [];
    for (Media element in message.medias.values) {
      medias.add(element);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: pageController,
        itemCount: medias.length,
        itemBuilder: (context, mediaIndex) {
          Media media = medias[mediaIndex];
          if (media.type.contains('video')) {
            return FileVideoPlayer(
              url: media.fileUrl,
              // fit: BoxFit.fitWidth,
              // width: Get.width,
            );
          }
          return CachedNetworkImage(
            imageUrl: media.fileUrl,
            fit: BoxFit.fitWidth,
            // width: Get.width,
          );
        },
      ),
    );
  }
}

class FileVideoPlayer extends StatefulWidget {
  final String url;
  const FileVideoPlayer({super.key, required this.url});

  @override
  // ignore: library_private_types_in_public_api
  _FileVideoPlayerState createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
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
