import 'package:chats_ton/Providers/voice_call_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../../Global/color.dart';
import '../../Models/user_model.dart';
import '../Calling/video_calling_page.dart';
import '../Calling/voice_calling_page.dart';
import '../Widgets/message_textfield.dart' as textField;

class ChannelPage extends StatefulWidget {
  // final Channel streamChannal;
  const ChannelPage({
    Key? key,
    // required this.streamChannal,
  }) : super(key: key);

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    queryChannelMembers();
  }

  late List<Member> members = [];
  queryChannelMembers() async {
    final channel = StreamChannel.of(context).channel;

    channel.queryMembers().then((value) {
      setState(() {
        members = value.members;
      });
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
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

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    // final client = StreamChat.of(context).client;
    // final channel = StreamChannel.of(context).channel;
    final UserModel userModel = Provider.of<UserModel>(context);
    // final client = StreamChat.of(context).client;
    // String channelName = widget.streamChannal.image!;
    // channel.watch();
    return Scaffold(
      body: Column(
        children: <Widget>[
          MessageHeader(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: IconButton(
                    onPressed: () async {
                      try {
                        Call call = StreamVideo.instance
                            .makeCall(type: 'video', id: channel.id!);
                        List<Member> withoutCurrentUserMamaber = members
                            .where(
                                (element) => element.userId != userModel.userId)
                            .toList();
                        //  call.update(custom: {'imageUrl': });
                        await call
                            .getOrCreate(participantIds: [userModel.userId]);
                        for (Member element in withoutCurrentUserMamaber) {
                          await VoiceCallProvider().sendCallNotification(
                              element.user!.extraData['pushToken'].toString(),
                              userModel,
                              call.id,
                              'audio');
                        }

                        Get.to(() => CallScreen(
                              call: call,
                              isVideo: false,
                            ));
                      } catch (e) {
                        print('Error joining or creating call: $e');
                        debugPrint(e.toString());
                      }
                    },
                    icon: SvgPicture.asset('assets/call_icon.svg')),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed: () async {
                    try {
                      Call call = StreamVideo.instance
                          .makeCall(type: 'video', id: channel.id!);
                      List<Member> withoutCurrentUserMamaber = members
                          .where(
                              (element) => element.userId != userModel.userId)
                          .toList();
                      await call
                          .getOrCreate(participantIds: [userModel.userId]);
                      for (Member element in withoutCurrentUserMamaber) {
                        await VoiceCallProvider().sendCallNotification(
                            element.user!.extraData['pushToken'].toString(),
                            userModel,
                            call.id,
                            'video');
                      }
                      Get.to(() => VideoCallPage(
                            call: call,
                            isVideo: true,
                          ));
                    } catch (e) {
                      debugPrint('Error joining or creating call: $e');
                      debugPrint(e.toString());
                    }
                  },
                  icon: SvgPicture.asset('assets/Video_icon.svg'),
                ),
              ),
            ],
            backgroundColor:
                AppColor().changeColor(color: AppColor().purpleColor),
          ),
          // MessageUserBar(member: member),
          Expanded(
            child: StreamMessageListView(
              showConnectionStateTile: true,

              highlightInitialMessage: true,

              // onMessageSwiped: (message) {
              //   channel.;
              // },

              dateDividerBuilder: (dateTime) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Container(
                        // width: 20,
                        decoration: BoxDecoration(
                          color: AppColor().changeColor(color: 'F8FBFA'),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _formatDate(dateTime),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },

              //  threadBuilder: (context, parent) => ThreadPage(parent: parent),
              // onMessageSwiped: (message)=> ,
              // parentMessage: ,
              // onMessageSwiped: (message) {},
            ),
          ),
          textField.StreamMessageInput(
            onMessageSent: (Message message) async {
              List<Member> withoutCurrentUserMamaber = members
                  .where((element) => element.userId != userModel.userId)
                  .toList();
              for (Member memebr in withoutCurrentUserMamaber) {
                if (message.text == null) {
                  await VoiceCallProvider().sendMessageNotification(
                      channelId: channel.id!,
                      recipientToken:
                          memebr.user!.extraData['pushToken'].toString(),
                      userModel: userModel,
                      message: message.text!,
                      messageType: 'File');
                } else {
                  await VoiceCallProvider().sendMessageNotification(
                      channelId: channel.id!,
                      recipientToken:
                          memebr.user!.extraData['pushToken'].toString(),
                      userModel: userModel,
                      message: message.text!,
                      messageType: 'text');
                }
              }

              // String messageType;

              // await Future.delayed(const Duration(seconds: 2));

              // await VoiceCallProvider().sendCallNotification(
              //     userModel.pushToken, userModel, 'helloMessage', 'video');
            },

            // actions: [],
          ),
        ],
      ),
    );
  }
}

class MessageHeader extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro MessageHeader}
  const MessageHeader({
    super.key,
    this.showBackButton = true,
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
    final channel = StreamChannel.of(context).channel;
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
                      padding: const EdgeInsets.only(right: 15),
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
                        title ??
                            StreamChannelName(
                              channel: channel,
                              textStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        const SizedBox(height: 2),
                        subtitle ??
                            StreamChannelInfo(
                              showTypingIndicator: true,
                              channel: channel,
                              textStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
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

// class ThreadPage extends StatefulWidget {
//   const ThreadPage({
//     Key? key,
//     this.parent,
//   }) : super(key: key);

//   final Message? parent;

//   @override
//   State<ThreadPage> createState() => _ThreadPageState();
// }

// class _ThreadPageState extends State<ThreadPage> {
//   late final _controller = StreamMessageInputController();

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: StreamThreadHeader(
//         parent: widget.parent!,
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: StreamMessageListView(
//               parentMessage: widget.parent,
//             ),
//           ),
//           StreamMessageInput(
//             messageInputController: _controller,
//           ),
//         ],
//       ),
//     );
//   }
// }

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
        RawMaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
          highlightElevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          onPressed: () {
            if (onPressed != null) {
              onPressed!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset('assets/Back_icon.svg'),
        ),
        if (showUnreadCount)
          Positioned(
            top: 7,
            right: 7,
            child: StreamUnreadIndicator(
              cid: channelId,
            ),
          ),
      ],
    );
  }
}
