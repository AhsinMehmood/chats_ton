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
  print(notificationData);
  if (notificationData['type'] == 'call') {
    String userToken = UserProvider()
        .createToken(chatApiKey, sharedPreferences.getString('userId')!);
    StreamVideo(
      chatApiKey,
      user: User(
        info: UserInfo(
          id: sharedPreferences.getString('userId')!,
          name: sharedPreferences.getString('userName') ?? 'Ahsan Mehmood',
          image: sharedPreferences.getString('imageUrl'),
        ),

        // online: user.activeStatus == 'Active' ? true : false,
      ),
      userToken: userToken,
    );
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
          backgroundColor: '#0955fa',
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
    listenCallKitBackGround(message.data);
  } else {
    print('message');
  }

  print("Handling a background message: $message");
}

listenCallKitBackGround(Map<String, dynamic> map) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    switch (event!.event) {
      case Event.actionCallIncoming:
        //  received an incoming call
        VoiceCallProvider().updateCallMessage(map['callId'], 'Incoming');
        log('Call Incoming');
        break;
      case Event.actionCallStart:
        VoiceCallProvider().updateCallMessage(map['callId'], 'Call Started');

        //  started an outgoing call
        //  show screen calling in Flutter
        log('Call Started');

        break;
      case Event.actionCallAccept:
        VoiceCallProvider().updateCallMessage(map['callId'], 'Call Accepted');

        log('Call Accept');
        Call call =
            StreamVideo.instance.makeCall(type: 'video', id: map['callId']);

        await call.getOrCreate(participantIds: [
          sharedPreferences.getString('userId')!,
          map['callerId']
        ]);
        if (map['callType'] == 'audio') {
          Navigator.push(navigatorKey.currentState!.context,
              MaterialPageRoute(builder: (context) {
            return CallScreen(call: call, isVideo: true);
          }));
        } else {
          Navigator.push(navigatorKey.currentState!.context,
              MaterialPageRoute(builder: (context) {
            return VideoCallPage(call: call, isVideo: true);
          }));
        }

        // Get.to(() =>
        //     CallScreen(secondUser: map['callerId'], callId: map['callId']));
        //  accepted an incoming call
        //  show screen calling in Flutter
        break;
      case Event.actionCallDecline:
        log('Call Decline');
        VoiceCallProvider().updateCallMessage(map['callId'], 'Call Declined');

        //  declined an incoming call
        break;
      case Event.actionCallEnded:
        log('Call Call Ended');
        VoiceCallProvider().updateCallMessage(map['callId'], 'Call Ended');
        // Navigator.pop(context);
        //  ended an incoming/outgoing call
        break;
      case Event.actionCallTimeout:
        log('Call Timeout');
        VoiceCallProvider().updateCallMessage(map['callId'], 'Missed Call');

        //  missed an incoming call
        break;
      case Event.actionCallCallback:
        log('Call Call Back android miss notification');

        //  only Android - click action `Call back` from missed call notification
        break;
      case Event.actionCallToggleHold:
        log('Call On Hold');
        VoiceCallProvider().updateCallMessage(map['callId'], 'Call on Hold');

        //  only iOS
        break;
      case Event.actionCallToggleMute:
        log('Call Mute');
        VoiceCallProvider().updateCallMessage(map['callId'], 'Call on Mute');

        //  only iOS
        break;
      case Event.actionCallToggleDmtf:
        log('Call DMTF');

        //  only iOS
        break;
      case Event.actionCallToggleGroup:
        log('Call Incoming');

        //  only iOS
        break;
      case Event.actionCallToggleAudioSession:
        //  only iOS
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
        //  only iOS
        break;
      case Event.actionCallCustom:
        //  for custom action
        break;
    }
  });
}

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 15));

  /// 1.1.1 define a navigator key

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
//   final chatPersistentClient = StreamChatPersistenceClient(
//   logLevel: Level.INFO,
//   connectionMode: ConnectionMode.background,
// );
  final client = chatClientSDK.StreamChatClient(
    chatApiKey,
    logLevel: chatClientSDK.Level.INFO,
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
  listenCallKit(Map<String, dynamic> map) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          //  received an incoming call
          VoiceCallProvider().updateCallMessage(map['callId'], 'Incoming');
          log('Call Incoming');
          break;
        case Event.actionCallStart:
          VoiceCallProvider().updateCallMessage(map['callId'], 'Call Started');

          //  started an outgoing call
          //  show screen calling in Flutter
          log('Call Started');

          break;
        case Event.actionCallAccept:
          VoiceCallProvider().updateCallMessage(map['callId'], 'Call Accepted');

          log('Call Accept');
          Call call =
              StreamVideo.instance.makeCall(type: 'video', id: map['callId']);

          await call.getOrCreate(participantIds: [
            sharedPreferences.getString('userId')!,
            map['callerId']
          ]);
          Navigator.push(context, MaterialPageRoute(builder: (
            context,
          ) {
            return VideoCallPage(
              call: call,
              isVideo: true,
            );
          }));
          // Get.to(() =>
          //     CallScreen(secondUser: map['callerId'], callId: map['callId']));
          //  accepted an incoming call
          //  show screen calling in Flutter
          break;
        case Event.actionCallDecline:
          log('Call Decline');
          VoiceCallProvider().updateCallMessage(map['callId'], 'Call Declined');

          //  declined an incoming call
          break;
        case Event.actionCallEnded:
          log('Call Call Ended');
          VoiceCallProvider().updateCallMessage(map['callId'], 'Call Ended');
          // Navigator.pop(context);
          //  ended an incoming/outgoing call
          break;
        case Event.actionCallTimeout:
          log('Call Timeout');
          VoiceCallProvider().updateCallMessage(map['callId'], 'Missed Call');

          //  missed an incoming call
          break;
        case Event.actionCallCallback:
          log('Call Call Back android miss notification');

          //  only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
          log('Call On Hold');
          VoiceCallProvider().updateCallMessage(map['callId'], 'Call on Hold');

          //  only iOS
          break;
        case Event.actionCallToggleMute:
          log('Call Mute');
          VoiceCallProvider().updateCallMessage(map['callId'], 'Call on Mute');

          //  only iOS
          break;
        case Event.actionCallToggleDmtf:
          log('Call DMTF');

          //  only iOS
          break;
        case Event.actionCallToggleGroup:
          log('Call Incoming');

          //  only iOS
          break;
        case Event.actionCallToggleAudioSession:
          //  only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          //  only iOS
          break;
        case Event.actionCallCustom:
          //  for custom action
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming FCM messages
      // final callType = message.data['callType'];
      // final callId = message.data['callId'];
      final Map<String, dynamic> notificationData = message.data;
      print('Notification Type ${notificationData['type']}');
      if (notificationData['type'] == 'call') {
        CallKitParams callKitParams = CallKitParams(
          id: notificationData['callerId'],
          nameCaller: notificationData['callerName'],
          appName: 'Chats Ton',
          avatar: notificationData['callerImageUrl'],
          handle: notificationData['callerPhoneNumber'],
          type: 0,
          textAccept: 'Accept',
          textDecline: 'Decline',
          missedCallNotification: const NotificationParams(
            showNotification: true,
            isShowCallback: true,
            subtitle: 'Missed call',
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
              backgroundColor: '#0955fa',
              backgroundUrl: notificationData['callerImageUrl'],
              actionColor: '#4CAF50',
              incomingCallNotificationChannelName: "Incoming Call",
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
            supportsDTMF: true,
            supportsHolding: true,
            supportsGrouping: false,
            supportsUngrouping: false,
            ringtonePath: 'system_ringtone_default',
          ),
        );
        FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
        listenCallKit(message.data);
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
