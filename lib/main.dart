// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/app_settings.dart';
import 'package:chats_ton/Models/chats_model.dart';
import 'package:chats_ton/Models/status_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/app_provider.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/Providers/conversation_provider.dart';
import 'package:chats_ton/Providers/group_provider.dart';
import 'package:chats_ton/Providers/message_provider.dart';
import 'package:chats_ton/Providers/status_provider.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/Providers/voice_call_provider.dart';
import 'package:chats_ton/UI/Calling/voice_calling_page.dart';
import 'package:chats_ton/UI/Pages/calls_page.dart';
import 'package:chats_ton/UI/Widgets/social_media_audio_recorder.dart';
import 'package:chats_ton/UI/splash_screen.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as chatClientSDK;
// import 'package:stream_chat_persistence/stream_chat_persistence.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

// import 'package:video_player_media_kit/video_player_media_kit.dart';

// import 'UI/Calling/video_call_page.dart';
import 'UI/Calling/video_calling_page.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  // runApp(MyNewApp());
  final Map<String, dynamic> notificationData = message.data;
  StreamVideo.reset();

  if (notificationData['type'] == 'call') {
    String userToken = UserProvider()
        .createToken(chatApiKey, sharedPreferences.getString('userId')!);
    StreamVideo(chatApiKey,
        user: User(
            info: UserInfo(
                id: sharedPreferences.getString('userId')!,
                name:
                    sharedPreferences.getString('userName') ?? 'Ahsan Mehmood',
                image: sharedPreferences.getString('imageUrl'))),
        userToken: userToken);
    CallKitParams callKitParams = CallKitParams(
      id: notificationData['callerId'],
      nameCaller: notificationData['callerName'],
      appName: 'Chats Ton',
      avatar: notificationData['callerImageUrl'],
      handle: notificationData['callerPhoneNumber'],
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed ${message.data['callType']}',
        callbackText: 'Call back',
      ),
      duration: 30000,
      // extra: <String, dynamic>{
      //   'userId': userModel.userId,
      // },
      // headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: AndroidParams(
          isCustomNotification: true,
          isShowLogo: true,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#925FE2',
          backgroundUrl: notificationData['callerImageUrl'],
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: message.data['callType'],
          missedCallNotificationChannelName: "Missed Call"),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    listenCallKit(message.data);
  } else {
    print('message');
  }

  print("Handling a background message: $message");
}

listenCallKit(Map<String, dynamic> map) async {
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    switch (event!.event) {
      case Event.actionCallIncoming:
        break;
      case Event.actionCallStart:
        break;
      case Event.actionCallAccept:
        if (map['callType'] == 'audio') {
          Navigator.push(navigatorKey.currentState!.context,
              MaterialPageRoute(builder: (context) {
            return CallScreen(
                channelId: map['channelId'], members: [], isVideo: true);
          }));
        } else {
          Navigator.push(navigatorKey.currentState!.context,
              MaterialPageRoute(builder: (context) {
            return VideoCallPage(
                channelId: map['channelId'], members: [], isVideo: true);
          }));
        }
        break;
      case Event.actionCallDecline:
        break;
      case Event.actionCallEnded:
        Navigator.pop(
          navigatorKey.currentState!.context,
        );

        break;
      case Event.actionCallTimeout:
        break;
      case Event.actionCallCallback:
        break;
      case Event.actionCallToggleHold:
        break;
      case Event.actionCallToggleMute:
        break;
      case Event.actionCallToggleDmtf:
        break;
      case Event.actionCallToggleGroup:
        break;
      case Event.actionCallToggleAudioSession:
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
        break;
      case Event.actionCallCustom:
        break;
    }
  });
}

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 15));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final client = chatClientSDK.StreamChatClient(
    chatApiKey,
    logLevel: chatClientSDK.Level.OFF,
  );

//   StreamVideo.in(
//   "us83cfwuhy8n",
//   logLevel: Level.INFO,
// );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<UserModel>.value(
          value: UserProvider().getUserStream(),
          initialData: UserModel.fromJson({}, ''),
        ),
        StreamProvider<List<ChatsModel>>.value(
          value: ConversationProvider().chatsStream(),
          catchError: (context, error) {
            print(error);
            return [];
          },
          initialData: [],
        ),
        ChangeNotifierProvider<AppProvider>(create: (context) => AppProvider()),
        ChangeNotifierProvider<MessageProvider>(
            create: (context) => MessageProvider()),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
        ChangeNotifierProvider<StatusProvider>(
            create: (context) => StatusProvider()),
        ChangeNotifierProvider<ContactsProvider>(
            create: (context) => ContactsProvider()),
        ChangeNotifierProvider<ConversationProvider>(
            create: (context) => ConversationProvider()),
        ChangeNotifierProvider<GroupProvider>(
            create: (context) => GroupProvider()),
      ],
      child: MyApp(
        navigatorKey: navigatorKey,
        client: client,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final chatClientSDK.StreamChatClient client;

  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.client,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final Map<String, dynamic> notificationData = message.data;

      if (notificationData['type'] == 'call') {
        if (notificationData['callType'] == 'audio') {
          Navigator.push(navigatorKey.currentState!.context,
              MaterialPageRoute(builder: (context) {
            return CallScreen(
                channelId: notificationData['channelId'],
                members: [],
                isVideo: true);
          }));
        } else {
          Navigator.push(navigatorKey.currentState!.context,
              MaterialPageRoute(builder: (context) {
            return VideoCallPage(
                channelId: notificationData['channelId'],
                members: [],
                isVideo: true);
          }));
        }
      } else {
        print(notificationData['type']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
    return GetMaterialApp(
      title: 'Chats Ton',
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      navigatorKey: widget.navigatorKey,
      builder: (context, child) => chatClientSDK.StreamChat(
        client: widget.client,
        streamChatThemeData: chatClientSDK.StreamChatThemeData(
          reactionIcons: [
            chatClientSDK.StreamReactionIcon(
                type: 'love',
                builder: (context, value, ss) {
                  return const Icon(Icons.heart_broken);
                })
          ],
          channelHeaderTheme: chatClientSDK.StreamChannelHeaderThemeData(
            subtitleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            titleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          otherMessageTheme: chatClientSDK.StreamMessageThemeData(
              reactionsMaskColor:
                  AppColor().changeColor(color: AppColor().purpleColor)),
          ownMessageTheme: chatClientSDK.StreamMessageThemeData(
              messageTextStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),

              // ignore: deprecated_member_use
              linkBackgroundColor:
                  AppColor().changeColor(color: AppColor().purpleColor),
              messageLinksStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              reactionsMaskColor:
                  AppColor().changeColor(color: AppColor().purpleColor),
              messageBackgroundColor:
                  AppColor().changeColor(color: AppColor().purpleColor)),
          colorTheme: chatClientSDK.StreamColorTheme.light(
              accentPrimary:
                  AppColor().changeColor(color: AppColor().purpleColor)),
        ),
        child: child!,
      ),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor().changeColor(color: AppColor().purpleColor),
          primary: AppColor().changeColor(color: AppColor().purpleColorDim),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(
          // title: '',
          ),
    );
  }
}
