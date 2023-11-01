import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/group_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class SelectMembersPage extends StatefulWidget {
  final String appBarText;

  const SelectMembersPage({super.key, required this.appBarText});

  @override
  State<SelectMembersPage> createState() => _SelectMembersPageState();
}

class _SelectMembersPageState extends State<SelectMembersPage> {
  late Stream<List<UserModel>> contactsStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    final UserModel currentUser =
        Provider.of<UserModel>(context, listen: false);

    contactsStream = FirebaseFirestore.instance
        .collection('users')
        .where('contacts', arrayContains: currentUser.phoneNumber)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => UserModel.fromJson(e.data(), e.id)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final UserModel currentUser = Provider.of<UserModel>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarText),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<UserModel>>(
          stream: contactsStream,
          builder: (context, AsyncSnapshot<List<UserModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Text('No Contacts on ChatsTon'),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('No Contacts on ChatsTonError'),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final UserModel contactDetails = snapshot.data![index];

                return ListTile(
                  // onTap: () async {
                  //   groupProvider.selectedMemeber(contactDetails);
                  // },
                  // selected:
                  //     groupProvider.selectedMembers.contains(contactDetails),
                  // selectedColor:
                  //     AppColor().changeColor(color: AppColor().purpleColor),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: CachedNetworkImage(
                      imageUrl: contactDetails.imageUrl,
                      height: 52,
                      width: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    '${contactDetails.firstName} ${contactDetails.lastName}',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                  trailing: Checkbox(
                      value: groupProvider.selectedMembers
                          .contains(contactDetails),
                      onChanged: (value) {
                        groupProvider.selectedMemeber(contactDetails);
                      }),
                  subtitle: Text(
                    contactDetails.bio,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                );
              },
            );
          }),
    );
  }
}
