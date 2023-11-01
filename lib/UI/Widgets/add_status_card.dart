import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Global/color.dart';
import '../../Providers/status_provider.dart';

class AddStatusCard extends StatelessWidget {
  const AddStatusCard({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    final StatusProvider statusProvider = Provider.of<StatusProvider>(context);

    AppColor app = AppColor();
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Container(
                height: 58,
                margin: const EdgeInsets.only(right: 0),
                width: 58,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(250),
                    color: Colors.white,
                    border: Border.all(
                      color: app.changeColor(color: app.purpleColor),
                    )),
                child: statusProvider.uploading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: app.changeColor(color: app.purpleColor),
                          strokeWidth: 1.5,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          statusProvider.pickImage(
                              ImageSource.gallery, userModel.contacts);
                          // statusProvider.addStatus();
                        },
                        child: Container(
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(200),
                                border: Border.all(
                                  color: Colors.black,
                                )),
                            child: const Center(child: Icon(Icons.add))),
                      ),
              ),
            ],
          ),
          // Text(
          //   'Add Status',
          //   style: GoogleFonts.poppins(
          //     color: Colors.white,
          //     fontSize: 14,
          //     fontWeight: FontWeight.w400,
          //   ),
          // ),
        ],
      ),
    );
  }
}
