import 'dart:developer';
import 'dart:ui';

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
import '../Widgets/custom_thread_header.dart';
import '../Widgets/message_textfield.dart' as textField;
import 'dart:math' as math;

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

  Message? quotedMessage;
  late final messageInputController = StreamMessageInputController();
  final focusNode = FocusNode();
  @override
  void dispose() {
    focusNode.dispose();

    messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    final UserModel userModel = Provider.of<UserModel>(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          MessageHeader(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: IconButton(
                    onPressed: () async {
                      // Get.to(() => CallScreen(
                      //       isVideo: false,
                      //       channelId: channel.id!,
                      //       members: members,
                      //     ));
                    },
                    icon: SvgPicture.asset('assets/call_icon.svg')),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: IconButton(
                  onPressed: () async {
                    // if (videoInitialized) {

                    // Get.to(() => VideoCallPage(
                    //       channelId: channel.id!,
                    //       isVideo: true,
                    //       members: members,
                    //     ));
                    // channel
                    //     .sendMessage(Message(
                    //   type: 'location',
                    //   text: 'Hello World',

                    // ))
                    //     .then((value) {e
                    //   log(value.message.type);
                    // });
                    // }
                  },
                  icon: SvgPicture.asset('assets/Video_icon.svg'),
                ),
              ),
            ],
            backgroundColor:
                AppColor().changeColor(color: AppColor().purpleColor),
          ),
          Expanded(
            child: StreamMessageListView(
              showConnectionStateTile: true,

              highlightInitialMessage: true,
              threadBuilder: (context, parent) {
                return ThreadPage(
                  parent: parent!,
                  channel: channel,
                  members: members,
                );
              },
              messageBuilder: (context, MessageDetails messageDetails, messages,
                  defaultWidget) {
                const threshold = 0.2;

                final isMyMessage = messageDetails.isMyMessage;

                // The direction in which the message can be swiped.
                final swipeDirection = isMyMessage
                    ? SwipeDirection.endToStart //
                    : SwipeDirection.startToEnd;
                return Swipeable(
                  key: ValueKey(messageDetails.message.id),
                  direction: swipeDirection,
                  swipeThreshold: threshold,
                  onSwiped: (details) => reply(messageDetails.message),
                  backgroundBuilder: (context, details) {
                    // The alignment of the swipe action.
                    final alignment = isMyMessage
                        ? Alignment.centerRight //
                        : Alignment.centerLeft;

                    // The progress of the swipe action.
                    final progress =
                        math.min(details.progress, threshold) / threshold;

                    // The offset for the reply icon.
                    var offset = Offset.lerp(
                      const Offset(-24, 0),
                      const Offset(12, 0),
                      progress,
                    )!;

                    // If the message is mine, we need to flip the offset.
                    if (isMyMessage) {
                      offset = Offset(-offset.dx, -offset.dy);
                    }

                    final streamTheme = StreamChatTheme.of(context);

                    return Align(
                      alignment: alignment,
                      child: Transform.translate(
                        offset: offset,
                        child: Opacity(
                          opacity: progress,
                          child: SizedBox.square(
                            dimension: 30,
                            child: CustomPaint(
                              painter: AnimatedCircleBorderPainter(
                                progress: progress,
                                color: streamTheme.colorTheme.borders,
                              ),
                              child: Center(
                                child: StreamSvgIcon.reply(
                                  size: lerpDouble(0, 18, progress),
                                  color: streamTheme.colorTheme.accentPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: defaultWidget
                      .copyWith(onReplyTap: reply, customAttachmentBuilders: {
                    'call': (context, message, attatchments) {
                      return WrapAttachmentWidget(
                          attachmentWidget: Card(
                            child: Text('Call'),
                          ),
                          attachmentShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ));
                    }
                  }),
                );
              },
              // onMessageSwiped: (message) {
              //   setState(() {
              //     quotedMessage = message;
              //   });
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
            quotedMessageBuilder: (context, messageNew) {
              return Text(messageNew.text ?? '');
            },
            onQuotedMessageCleared: messageInputController.clearQuotedMessage,
            focusNode: focusNode,
            messageInputController: messageInputController,
            onMessageSent: (Message message) async {
              log(message.toString());
              List<Member> withoutCurrentUserMamaber = members
                  .where((element) => element.userId != userModel.userId)
                  .toList();
              for (Member memebr in withoutCurrentUserMamaber) {
                if (message.text == null) {
                  await VoiceCallProvider().sendMessageNotification(
                      groupId: channel.id!,
                      messageId: message.id,
                      recipientToken:
                          memebr.user!.extraData['pushToken'].toString(),
                      userModel: userModel,
                      message: message.text!,
                      messageType: 'File');
                } else {
                  await VoiceCallProvider().sendMessageNotification(
                      groupId: channel.id!,
                      messageId: message.id,
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

  void reply(Message message) {
    messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });
  }
}

class ThreadPage extends StatelessWidget {
  final List<Member> members;
  final Channel channel;
  const ThreadPage({
    super.key,
    required this.channel,
    required this.members,
    required this.parent,
  });

  final Message parent;

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: CustomStreamThreadHeader(
        parent: parent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              parentMessage: parent,
            ),
          ),
          textField.StreamMessageInput(
            messageInputController: StreamMessageInputController(
              message: Message(parentId: parent.id),
            ),
            onMessageSent: (Message message) async {
              log(message.toString());
              List<Member> withoutCurrentUserMamaber = members
                  .where((element) => element.userId != userModel.userId)
                  .toList();
              for (Member memebr in withoutCurrentUserMamaber) {
                if (message.text == null) {
                  await VoiceCallProvider().sendMessageNotification(
                      groupId: channel.id!,
                      messageId: message.id,
                      recipientToken:
                          memebr.user!.extraData['pushToken'].toString(),
                      userModel: userModel,
                      message: message.text!,
                      messageType: 'File');
                } else {
                  await VoiceCallProvider().sendMessageNotification(
                      groupId: channel.id!,
                      messageId: message.id,
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
            centerTitle: false,
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
