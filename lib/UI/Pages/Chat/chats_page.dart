import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../Global/color.dart';
import '../../../Models/user_model.dart';
import '../../../Providers/app_provider.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    AppColor app = AppColor();
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          height: Get.height,
          width: Get.width,
          color: app.changeColor(color: app.purpleColor),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CachedNetworkImage(
                        imageUrl: userModel.imageUrl,
                        height: 44,
                        width: 44,
                        color: Colors.transparent,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        appProvider.languages.first.home,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(250),
                        child: CachedNetworkImage(
                          imageUrl: userModel.imageUrl,
                          height: 44,
                          width: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  height: 85,
                  width: Get.width,
                  // color: Colors.red,
                  child: ListView.builder(
                      itemCount: 0 + 1,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return addStatusCard(context);
                        }
                        return _statusUserCard(context);
                      }),
                )
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 250,
          ),
          height: Get.height - 250,
          width: Get.width,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              )),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 3,
                width: 30,
                color: app.changeColor(color: 'E6E6E6'),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      return chatsCard(context);
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  chatsCard(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    AppColor app = AppColor();
    return ListTile(
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: CachedNetworkImage(
              imageUrl: userModel.imageUrl,
              height: 52,
              width: 52,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Colors.green),
              ))
        ],
      ),
      title: Text(
        'Ahsin Mehmood',
        style: GoogleFonts.poppins(
          color: app.changeColor(color: '000E08'),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        'How are you today?',
        style: GoogleFonts.poppins(
          color: app.changeColor(color: '797C7B'),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '2 min ago',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: app.changeColor(color: '797C7B'),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: app.changeColor(color: '925FE2'),
              ),
              width: 22,
              child: Center(
                  child: Text(
                '3',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ))),
        ],
      ),
    );
  }

  addStatusCard(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    AppColor app = AppColor();
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Container(
                height: 58,
                margin: const EdgeInsets.only(right: 5),
                width: 58,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(250),
                    border: Border.all(
                      color: app.changeColor(color: 'FFC746'),
                    )),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(250),
                    child: CachedNetworkImage(
                      imageUrl: userModel.imageUrl,
                      fit: BoxFit.cover,
                    )),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(
                            color: Colors.black,
                          )),
                      child: Center(child: Icon(Icons.add)))),
            ],
          ),
          Text(
            'My status',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  _statusUserCard(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    AppColor app = AppColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 58,
          margin: const EdgeInsets.only(right: 10),
          width: 58,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(250),
              border: Border.all(
                color: app.changeColor(color: 'FFC746'),
              )),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(250),
              child: CachedNetworkImage(
                imageUrl: userModel.imageUrl,
                fit: BoxFit.cover,
              )),
        ),
        Text('Ahsin'),
      ],
    );
  }
}
