import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/app_provider.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/Providers/status_provider.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/splash_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<UserModel>.value(
          value: UserProvider().getUserStream(),
          initialData: UserModel.fromJson({}),
        ),
        ChangeNotifierProvider<AppProvider>(create: (context) => AppProvider()),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
        ChangeNotifierProvider<StatusProvider>(
            create: (context) => StatusProvider()),
        ChangeNotifierProvider<ContactsProvider>(
            create: (context) => ContactsProvider()),
      ],
      child: DevicePreview(
        enabled: true,
        builder: ((context) => const MyApp()),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
    return GetMaterialApp(
      title: 'Chats Ton',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor().changeColor(color: AppColor().purpleColor),
          primary: AppColor().changeColor(color: AppColor().purpleColorDim),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
