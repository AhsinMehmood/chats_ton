import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Global/color.dart';

AppColor app = AppColor();

class GroupAcces extends StatelessWidget {
  final GroupModel group;
  final List<UserModel> membersData;
  const GroupAcces({super.key, required this.group, required this.membersData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: app.changeColor(color: app.purpleColor),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Owner Access',
          style: GoogleFonts.poppins(
            color: app.changeColor(color: app.purpleColor),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/user.svg'),
              Text('Set Admin'),
              Icon(
                Icons.keyboard_arrow_right_outlined,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: app.changeColor(color: 'F2F8F7'),
                  ),
                  child: SvgPicture.asset('assets/lock.svg')),
              Text('Set Admin'),
              Icon(
                Icons.keyboard_arrow_right_outlined,
              ),
            ],
          ),
          Row(
            children: [
              SvgPicture.asset('assets/disc.svg'),
              Text('Set Admin'),
              Icon(
                Icons.keyboard_arrow_right_outlined,
              ),
            ],
          )
        ],
      ),
    );
  }
}
