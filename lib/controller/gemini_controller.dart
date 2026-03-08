import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_gemini_ai/controller/shared_preferences.dart';
import 'package:firebase_gemini_ai/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class FirebaseGemini {
  String generatedTitle = '';
  Map<String, dynamic> messageToSave = {};
  List<Map<String, dynamic>> allChat = [];
  final gemini = Gemini.instance;
  List<Content> chats = [];
  List<String> titleLists = [];
  bool showLoading = false;
  Uint8List? selectedImage;
  final sharedPref = SharedPref();

  Future<void> geminiStream(List<Content> message, BuildContext context,
      ScrollController scrollController) async {
    try {
      gemini
          .streamChat(
        modelName: "gemini-3-flash-preview",
        chats,
      )
          .listen(
        (value) {
          // print(value?.output);
          if (chats[chats.length - 1].role == "model") {
            chats[chats.length - 1] = Content(
              role: "model",
              parts: [
                Part.text(
                  "${(chats[chats.length - 1].parts?.last as TextPart?)?.text ?? ''} ${value.output}",
                ),
              ],
            );
            messageToSave['user'] =
                (chats[chats.length - 2].parts?.last as TextPart?)?.text;
            messageToSave['model'] =
                "${(chats[chats.length - 1].parts?.last as TextPart?)?.text ?? ''}${value.output}";
            allChat.removeLast();
            allChat.add(messageToSave);
          } else {
            messageToSave['user'] = (chats.last.parts?.last as TextPart?)?.text;
            chats.add(
              Content(
                role: "model",
                parts: [
                  Part.text(
                    value.output ?? "",
                  ),
                ],
              ),
            );
            messageToSave['model'] = value.output;
            allChat.add(messageToSave);
          }
          messageToSave = {};
          scrollToEnd(scrollController, 500);
          storeChats(generatedTitle, allChat, context);
          final provider = Provider.of<MessageProvider>(context, listen: false);
          showLoading = false;
          provider.updateWidget();
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error Occured : ${e.toString()}",
          ),
        ),
      );
    }
  }

  Future<void> geminiTextAndImage(String text, List<Uint8List> images,
      ScrollController scrollController, BuildContext context) async {
    try {
      gemini.prompt(
        parts: [
          Part.text(text),
          for (var image in images) Part.uint8List(image),
        ],
        model: "gemini-2.0-flash",
      ).then(
        (value) {
          messageToSave['user'] = (chats.last.parts?.last as TextPart?)?.text;
          messageToSave['model'] = value?.output;
          allChat.add(messageToSave);
          chats.add(
            Content(parts: [
              Part.text(
                value?.output ?? "",
              ),
            ], role: "model"),
          );
          scrollToEnd(scrollController, 500);
          storeChats(generatedTitle, allChat, context);
          final provider = Provider.of<MessageProvider>(context, listen: false);
          showLoading = false;
          provider.updateWidget();
          print("message : ${value?.output}");
        },
      );
      messageToSave = {};
    } catch (e) {
      print("Error Occured: $e");
    }
  }

  void scrollToEnd(ScrollController scrollController, int timer) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(
          milliseconds: timer,
        ),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> storeChats(String title, List<Map<String, dynamic>> allData,
      BuildContext context) async {
    try {
      String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
      if (generatedTitle.isNotEmpty) {
        CollectionReference collectionReference =
            FirebaseFirestore.instance.collection("chats");

        String email = await sharedPref.getData("email");

        DocumentSnapshot docSnap = await collectionReference.doc(title).get();
        if (docSnap.exists) {
          collectionReference
              .doc(email)
              .collection("topics")
              .doc(title)
              .update({"chats": allData, "date": date});
        } else {
          collectionReference
              .doc(email)
              .collection("topics")
              .doc(title)
              .set({"chats": allData, "date": date});
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error Occured : $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String generateTitle() {
    if (chats.isNotEmpty) {
      gemini.chat([
        ...chats,
        Content(parts: [
          Part.text(
              "Give me a suitable title for given Conversation with minimum words"),
        ], role: "user"),
      ]).then(
        (value) {
          if (value != null) {
            generatedTitle = value.output ?? "";
            titleLists.add(generatedTitle);
          }
        },
      );
    }

    return generatedTitle;
  }

  Future<void> getHistory() async {
    String email = await sharedPref.getData("email");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("chats")
        .doc(email)
        .collection("topics")
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      titleLists = querySnapshot.docs.map((e) => e.id).toList();
    }
  }

  Future<void> getChats(String title, BuildContext context,
      ScrollController scrollController) async {
    chats.clear();
    String email = await sharedPref.getData("email");
    final provider = Provider.of<MessageProvider>(context, listen: false);
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("chats")
        .doc(email)
        .collection("topics")
        .doc(title)
        .get();
    Map<String, dynamic>? mapData =
        documentSnapshot.data() as Map<String, dynamic>?;
    List<dynamic> messageList = mapData?["chats"] ?? [];

    for (int i = 0; i < messageList.length; i++) {
      chats.add(
        Content(parts: [
          Part.text(messageList[i]["user"]),
        ], role: "user"),
      );
      chats.add(
        Content(parts: [
          Part.text(messageList[i]["model"]),
        ], role: "model"),
      );
    }
    scrollToEnd(scrollController, 1500);
    provider.updateWidget();
  }

  Future<void> pickImage() async {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: [
            'jpg',
            'jpeg',
            'png',
          ]);

      if (result != null) {
        File file = File(result.files.single.path!);
        selectedImage = file.readAsBytesSync();
      }
    }
  }
}
