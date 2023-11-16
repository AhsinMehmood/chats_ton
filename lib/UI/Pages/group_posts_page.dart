import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/Models/group_post_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/group_post_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../Global/color.dart';
import 'add_post_page.dart';
import 'group_info_page.dart';

class GroupPosts extends StatefulWidget {
  final GroupModel groupModel;
  final List<UserModel> membersData;
  const GroupPosts(
      {super.key, required this.groupModel, required this.membersData});

  @override
  State<GroupPosts> createState() => _GroupPostsState();
}

class _GroupPostsState extends State<GroupPosts> {
  late Stream<List<GroupPostModel>> stream;
  @override
  void initState() {
    super.initState();
    stream = FirebaseFirestore.instance
        .collection('groupPosts')
        .where('groupIds', arrayContains: widget.groupModel.groupChatId)
        // .orderBy('createdAt')
        .snapshots()
        .map((event) =>
            event.docs.map((e) => GroupPostModel.fromJson(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final GroupPostProvider groupPostProvider =
        Provider.of<GroupPostProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: InkWell(
          onTap: () {
            Get.to(() => GroupInfoPage(
                  groupModel: widget.groupModel,
                  membersData: widget.membersData,
                ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.groupModel.groupName,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: () async {
                Get.to(() => AddGroupPost(
                      groupModel: widget.groupModel,
                    ));
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor: AppColor().changeColor(color: AppColor().purpleColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<GroupPostModel>>(
                stream: stream,
                builder:
                    (context, AsyncSnapshot<List<GroupPostModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('No'),
                    );
                  } else if (snapshot.data == null) {
                    return const Center(
                      child: Text('No posts'),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final GroupPostModel post = snapshot.data![index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.only(
                              left: 13,
                              right: 13,
                              top: 10,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.black.withOpacity(0.0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: post.imageUrl,
                                      // color: Colors.grey.withOpacity(0.1),
                                      height: 320,
                                      width: Get.width,
                                      fit: BoxFit.cover,
                                    ),
                                    Align(
                                      // alignment: Alignment,
                                      child: Container(
                                        height: 320,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                StreamBuilder<UserModel>(
                                                    initialData: userModel,
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(post.userId)
                                                        .snapshots()
                                                        .map((event) =>
                                                            UserModel.fromJson(
                                                                event.data()!,
                                                                event.id)),
                                                    builder: (context,
                                                        AsyncSnapshot<UserModel>
                                                            snapshot) {
                                                      final UserModel
                                                          ownerUser =
                                                          snapshot.data!;
                                                      return Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            200),
                                                                border: Border.all(
                                                                    color: AppColor()
                                                                        .changeColor(
                                                                            color:
                                                                                AppColor().purpleColor))),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          200),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    ownerUser
                                                                        .imageUrl,
                                                                height: 45,
                                                                width: 45,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${ownerUser.firstName} ${ownerUser.lastName}',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Text(
                                                                widget
                                                                    .groupModel
                                                                    .members[
                                                                        ownerUser
                                                                            .userId]!
                                                                    .role,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                                SizedBox(
                                                  height: 40,
                                                  width: 220,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                post.description,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: InkWell(
                                                onTap: () {
                                                  Get.bottomSheet(
                                                      CommentSheet(post: post));
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                            'assets/comment.svg'),
                                                        Text(
                                                          post.comments.length
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      // height: 65,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (post.likedBy
                                                              .contains(userModel
                                                                  .userId)) {
                                                            groupPostProvider
                                                                .disLikePost(
                                                                    post.id,
                                                                    userModel
                                                                        .userId);
                                                          } else {
                                                            groupPostProvider
                                                                .likePost(
                                                                    post.id,
                                                                    userModel
                                                                        .userId);
                                                          }
                                                        },
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                                'assets/like_heart.svg'),
                                                            Text(
                                                              post.likedBy.length >
                                                                      200
                                                                  ? '200+'
                                                                  : post.likedBy
                                                                      .length
                                                                      .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }
                }),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class CommentSheet extends StatefulWidget {
  final GroupPostModel post;
  const CommentSheet({super.key, required this.post});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);

    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Column(
          children: [
            const SizedBox(
              height: 14,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        // Get.close(1);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.transparent,
                      )),
                  Text(
                    'Comments',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.close(1);
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
            ),
            Expanded(
              child: widget.post.comments.isEmpty
                  ? const Center(
                      child: Text('No Comment!'),
                    )
                  : ListView.builder(
                      itemCount: widget.post.comments.length,
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) {
                        final Comment comment = widget.post.comments[index];
                        return StreamBuilder<UserModel>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(comment.commentOwnerId)
                              .snapshots()
                              .map((event) =>
                                  UserModel.fromJson(event.data()!, event.id)),
                          builder:
                              (context, AsyncSnapshot<UserModel> snapshot) {
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(200),
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data!.imageUrl,
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                comment.commentText,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            );
                          },
                          initialData: userModel,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 15),
              child: TextFormField(
                controller: commentController,
                decoration: InputDecoration(
                    hintText: 'Post a comment',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          if (commentController.text.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection('groupPosts')
                                .doc(widget.post.id)
                                .update({
                              'comments': FieldValue.arrayUnion([
                                {
                                  'commentText': commentController.text.trim(),
                                  'commentedAt':
                                      DateTime.now().toIso8601String(),
                                  'commentOwnerId': userModel.userId,
                                },
                              ]),
                            });
                            commentController.clear();
                            Get.close(1);
                          }
                        },
                        icon: SvgPicture.asset(
                          'assets/share.svg',
                          color: AppColor()
                              .changeColor(color: AppColor().purpleColor),
                        ))),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MessageHeader extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro MessageHeader}
  const MessageHeader({
    super.key,
    this.showBackButton = true,
    required this.channel,
    this.onBackPressed,
    this.onTitleTap,
    this.showTypingIndicator = true,
    this.onImageTap,
    this.showConnectionStateTile = false,
    this.title,
    this.subtitle,
    this.centerTitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation = 1,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  /// Whether to show the leading back button
  ///
  /// Defaults to `true`
  final bool showBackButton;
  final Channel channel;

  /// The action to perform when the back button is pressed.
  ///
  /// By default it calls [Navigator.pop]
  final VoidCallback? onBackPressed;

  /// The action to perform when the header is tapped.
  final VoidCallback? onTitleTap;

  /// The action to perform when the image is tapped.
  final VoidCallback? onImageTap;

  /// Whether to show the typing indicator
  ///
  /// Defaults to `true`
  final bool showTypingIndicator;

  /// Whether to show the connection state tile
  final bool showConnectionStateTile;

  /// Title widget
  final Widget? title;

  /// Subtitle widget
  final Widget? subtitle;

  /// Whether the title should be centered
  final bool? centerTitle;

  /// Leading widget
  final Widget? leading;

  /// {@macro flutter.material.appbar.actions}
  ///
  /// The [StreamChannelAvatar] is shown by default
  final List<Widget>? actions;

  /// The background color for this [StreamChannelHeader].
  final Color? backgroundColor;

  /// The elevation for this [StreamChannelHeader].
  final double elevation;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final channelHeaderTheme = StreamChannelHeaderTheme.of(context);

    final leadingWidget = leading ??
        (showBackButton
            ? StreamBackButton(
                onPressed: onBackPressed,
                showUnreadCount: true,
              )
            : const SizedBox());

    return StreamConnectionStatusBuilder(
      statusBuilder: (context, status) {
        var statusString = '';
        var showStatus = true;

        switch (status) {
          case ConnectionStatus.connected:
            statusString = context.translations.connectedLabel;
            showStatus = false;
            break;
          case ConnectionStatus.connecting:
            statusString = context.translations.reconnectingLabel;
            break;
          case ConnectionStatus.disconnected:
            statusString = context.translations.disconnectedLabel;
            break;
        }

        final theme = Theme.of(context);

        return StreamInfoTile(
          showMessage: showConnectionStateTile && showStatus,
          message: statusString,
          child: AppBar(
            toolbarTextStyle: theme.textTheme.bodyMedium,
            titleTextStyle: theme.textTheme.titleLarge,
            systemOverlayStyle: theme.brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.light,
            elevation: elevation,
            leading: leadingWidget,
            backgroundColor: backgroundColor ?? channelHeaderTheme.color,
            actions: actions ?? <Widget>[],
            centerTitle: true,
            title: InkWell(
              onTap: onTitleTap,
              child: SizedBox(
                height: preferredSize.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Center(
                        child: StreamChannelAvatar(
                          channel: channel,
                          borderRadius:
                              channelHeaderTheme.avatarTheme?.borderRadius,
                          constraints:
                              channelHeaderTheme.avatarTheme?.constraints,
                          onTap: onImageTap,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            StreamChannelName(
                              channel: channel,
                              textOverflow: TextOverflow.ellipsis,
                              textStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Click here for group info',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StreamBackButton extends StatelessWidget {
  /// {@macro streamBackButton}
  const StreamBackButton({
    super.key,
    this.onPressed,
    this.showUnreadCount = false,
    this.channelId,
  });

  /// Callback for when button is pressed
  final VoidCallback? onPressed;

  /// Show unread count
  final bool showUnreadCount;

  /// Channel ID used to retrieve unread count
  final String? channelId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () {
            if (onPressed != null) {
              onPressed!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          padding: const EdgeInsets.all(14),
          icon: SvgPicture.asset('assets/Back_icon.svg'),
        ),
        // if (showUnreadCount)
        //   Positioned(
        //     top: 7,
        //     right: 7,
        //     child: StreamUnreadIndicator(
        //       cid: channelId,
        //     ),
        //   ),
      ],
    );
  }
}
