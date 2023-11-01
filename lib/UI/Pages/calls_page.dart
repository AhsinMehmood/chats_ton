import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/Pages/other_user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  late StreamVideo video;
  late Result<QueriedCalls> result;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getCalls();
  }

  bool _loading = true;
  getCalls() async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // String userToken = UserProvider()
    //     .createToken(chatApiKey, sharedPreferences.getString('userId')!);

    video = StreamVideo.instance;
    result = await video.queryCalls(filterConditions: {"type": 'video'});
    setState(() {
      _loading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppColor app = AppColor();

    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: Get.height,
          width: Get.width,
          color: app.changeColor(color: app.purpleColor),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CachedNetworkImage(
                    //   imageUrl: userModel.imageUrl,
                    //   height: 44,
                    //   width: 44,
                    //   color: Colors.transparent,
                    //   fit: BoxFit.cover,
                    // ),
                    // const SizedBox(
                    //   width: 4,
                    //   height: 44,
                    // ),
                    Text(
                      'Calls',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    // InkWell(
                    //   onTap: () async {},
                    //   child: SvgPicture.asset('assets/call-user.svg'),
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        Positioned(
          top: 100,
          child: Container(
            height: Get.height,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 2,
                  width: 30,
                  child: Divider(
                    height: 2,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                    child: _loading
                        ? const Center(
                            child: Text(
                                'Egregated queries are not enabled for this collection'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: result.getDataOrNull()!.calls.length,
                            itemBuilder: (context, index) {
                              QueriedCall queriedCall =
                                  result.getDataOrNull()!.calls[index];
                              return callsCard(queriedCall);
                            })),
                const SizedBox(
                  height: 200,
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget callsCard(QueriedCall queriedCall) {
    final UserModel userModel = Provider.of<UserModel>(context);
    // queriedCall.call.details.custom;
    return ListTile(
      onTap: () {
        Get.to(() => const OtherUserInfo());
      },
      contentPadding: const EdgeInsets.only(
        top: 15,
        left: 10,
        right: 10,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(250),
        child: CachedNetworkImage(
          imageUrl: queriedCall.call.details.createdBy.image,
          height: 44,
          width: 44,
          // color: Colors.black,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        'Team Align',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      subtitle: Row(
        children: [
          SvgPicture.asset('assets/Call_green.svg'),
          const SizedBox(
            width: 6,
          ),
          Text(
            'Today 07:30 AM',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColor().changeColor(color: '797C7B'),
            ),
          ),
        ],
      ),
      trailing: SizedBox(
        height: 40,
        width: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset('assets/Call_grey.svg'),
            SvgPicture.asset('assets/Video_grey.svg'),
          ],
        ),
      ),
    );
  }
}
