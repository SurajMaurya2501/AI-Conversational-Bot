import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_gemini_ai/controller/gemini_controller.dart';
import 'package:firebase_gemini_ai/controller/login_controller.dart';
import 'package:firebase_gemini_ai/controller/shared_preferences.dart';
import 'package:firebase_gemini_ai/provider/message_provider.dart';
import 'package:firebase_gemini_ai/view/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  State<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  final gemini = FirebaseGemini();
  final _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  final loginController = LoginController();
  late FocusNode _focusNode;
  final _auth = FirebaseAuth.instance;
  bool _isFirstTime = true;
  int _selectedIndex = 0;
  bool showImage = false;

  bool isTitleEmpty = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    gemini.getHistory().whenComplete(
      () {
        setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstTime) {
        FocusScope.of(context).requestFocus(_focusNode);
        _isFirstTime = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessageProvider>(context, listen: true);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "ChatGem",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(
          255,
          21,
          21,
          21,
        ),
        leading: InkWell(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: Image.asset(
            "assets/images/menu.png",
            color: Colors.white,
            scale: 20,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(
          255,
          21,
          21,
          21,
        ),
        child: drawerBody(),
      ),
      backgroundColor: const Color.fromARGB(
        255,
        21,
        21,
        21,
      ),
      body: Column(
        children: [
          Expanded(
            child: gemini.chats.isNotEmpty
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Consumer<MessageProvider>(
                      builder: (context, value, child) {
                        return ListView.builder(
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            final Content content = gemini.chats[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 15.0,
                                    ),
                                    child: content.role == "user"
                                        ? const Text(
                                            "",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        : gemini.chats[index - 1].role !=
                                                "model"
                                            ? const CircleAvatar(
                                                radius: 11,
                                                backgroundColor: Color.fromARGB(
                                                    255, 57, 57, 57),
                                                child: Text(
                                                  "AI",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      letterSpacing: 1,
                                                      fontSize: 12),
                                                ),
                                              )
                                            : Container(),
                                  ),
                                  Expanded(
                                    child: content.role == "user"
                                        ? Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                top: 15.0,
                                                bottom: 15.0,
                                                left: 20.0,
                                                right: 20.0,
                                              ),
                                              margin: const EdgeInsets.only(
                                                right: 10.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  255,
                                                  43,
                                                  41,
                                                  41,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  30.0,
                                                ),
                                              ),
                                              child: SelectableText(
                                                (content.parts?.last
                                                            as TextPart?)
                                                        ?.text ??
                                                    "Sorry Cannot Generate Details!",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                255,
                                                21,
                                                21,
                                                21,
                                              ),
                                            ),

                                            alignment: content.role == "user"
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            // width:
                                            //     MediaQuery.of(context).size.width *
                                            //         0.9,
                                            child: Markdown(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              data: (content.parts?.last
                                                          as TextPart?)
                                                      ?.text ??
                                                  "Sorry Cannot Generate Details!",
                                              selectable: true,
                                              styleSheet: MarkdownStyleSheet(
                                                textAlign:
                                                    content.role == "user"
                                                        ? WrapAlignment.end
                                                        : WrapAlignment.start,
                                                a: const TextStyle(
                                                  color: Colors.blue,
                                                ),
                                                codeblockDecoration:
                                                    BoxDecoration(
                                                  color: Colors.black,
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      53,
                                                      53,
                                                      53,
                                                    ),
                                                  ),
                                                ),
                                                tableBody: const TextStyle(
                                                    color: Colors.white),
                                                blockquote: const TextStyle(
                                                    color: Colors.white),
                                                del: const TextStyle(
                                                    color: Colors.white),
                                                checkbox: const TextStyle(
                                                    color: Colors.white),
                                                listBullet: const TextStyle(
                                                    color: Colors.white),
                                                img: const TextStyle(
                                                    color: Colors.white),
                                                em: const TextStyle(
                                                    color: Colors.white),
                                                strong: const TextStyle(
                                                  color: Colors.white,
                                                  // backgroundColor:
                                                  //     Color.fromARGB(
                                                  //         255, 40, 39, 39),
                                                  letterSpacing: 1.5,
                                                ),
                                                h1: const TextStyle(
                                                    color: Colors.white),
                                                h2: const TextStyle(
                                                    color: Colors.white),
                                                h3: const TextStyle(
                                                    color: Colors.white),
                                                h4: const TextStyle(
                                                    color: Colors.white),
                                                h5: const TextStyle(
                                                    color: Colors.white),
                                                h6: const TextStyle(
                                                    color: Colors.white),
                                                p: const TextStyle(
                                                  color: Colors.white,
                                                  height: 1.5,
                                                  letterSpacing: 0.2,
                                                ),
                                                codeblockPadding:
                                                    const EdgeInsets.all(
                                                  25.0,
                                                ),
                                                code: const TextStyle(
                                                  height: 1.5,
                                                  backgroundColor: Colors.black,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              styleSheetTheme:
                                                  MarkdownStyleSheetBaseTheme
                                                      .cupertino,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            );
                          },
                          shrinkWrap: true,
                          itemCount: gemini.chats.length,
                          reverse: false,
                        );
                      },
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                    controller: scrollController,
                    child: const ClipOval(
                      child: Image(
                        height: 50,
                        image: AssetImage(
                          "assets/images/app_logo.png",
                        ),
                        // fit: BoxFit.contain,
                      ),
                    ),
                  )),
          ),
          if (gemini.showLoading)
            Center(
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(
                  5.0,
                ),
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          Container(
            margin:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
            alignment: Alignment.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                showImage
                    ? Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(
                            right: 20.0, bottom: 10.0, top: 10.0),
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          image: DecorationImage(
                            image: MemoryImage(
                              gemini.selectedImage!,
                            ),
                          ),
                        ),
                      )
                    : Container(),
                TextField(
                  focusNode: _focusNode,
                  autofocus: _isFirstTime,
                  // autofocus: true,
                  // autofocus: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    _focusNode.unfocus();
                  },
                  onSubmitted: (value) async {
                    if (showImage) {
                      showImage = false;
                      if (_controller.text.isNotEmpty) {
                        final searchedText = _controller.text;
                        gemini.chats.add(
                          Content(
                            role: 'user',
                            parts: [
                              Part.text(searchedText),
                            ],
                          ),
                        );

                        _controller.clear();
                        gemini.showLoading = true;
                        provider.updateWidget();

                        gemini.geminiTextAndImage(searchedText,
                            [gemini.selectedImage!], scrollController, context);
                        gemini.scrollToEnd(scrollController, 1500);
                      }
                    } else {
                      gemini.generateTitle(_selectedIndex);
                      if (_controller.text.isNotEmpty) {
                        final searchedText = _controller.text;
                        gemini.chats.add(
                          Content(
                            role: 'user',
                            parts: [
                              Part.text(searchedText),
                            ],
                          ),
                        );
                        // gemini.messageToSave["user"] = searchedText;
                        _controller.clear();
                        gemini.showLoading = true;
                        provider.updateWidget();
                        gemini.geminiStream(
                            gemini.chats, context, scrollController);
                        gemini.scrollToEnd(scrollController, 1500);
                      }
                    }
                  },
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      onPressed: () {
                        showImage = true;
                        gemini.pickImage().whenComplete(
                          () {
                            setState(() {});
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.file_copy_sharp,
                        color: Colors.white,
                      ),
                    ),
                    suffixIcon: AnimatedSwitcher(
                      duration: const Duration(
                        seconds: 1,
                      ),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: gemini.showLoading
                          ? IconButton(
                              onPressed: () {
                                gemini.showLoading = false;
                                gemini.gemini.cancelRequest();
                                gemini.chats.removeAt(gemini.chats.length - 1);
                                provider.updateWidget();
                              },
                              icon: const Icon(
                                Icons.stop,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                if (showImage) {
                                  showImage = false;
                                  if (_controller.text.isNotEmpty) {
                                    final searchedText = _controller.text;
                                    gemini.chats.add(
                                      Content(
                                        role: 'user',
                                        parts: [
                                          Part.text(searchedText),
                                        ],
                                      ),
                                    );

                                    _controller.clear();
                                    gemini.showLoading = true;
                                    provider.updateWidget();

                                    gemini.geminiTextAndImage(
                                        searchedText,
                                        [gemini.selectedImage!],
                                        scrollController,
                                        context);
                                    gemini.scrollToEnd(scrollController, 1500);
                                  }
                                } else {
                                  gemini.generateTitle(_selectedIndex);
                                  if (_controller.text.isNotEmpty) {
                                    final searchedText = _controller.text;
                                    gemini.chats.add(
                                      Content(
                                        role: 'user',
                                        parts: [
                                          Part.text(searchedText),
                                        ],
                                      ),
                                    );
                                    // gemini.messageToSave["user"] = searchedText;
                                    _controller.clear();
                                    gemini.showLoading = true;
                                    provider.updateWidget();
                                    gemini.geminiStream(gemini.chats, context,
                                        scrollController);
                                    gemini.scrollToEnd(scrollController, 1500);
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    hintText: "Search here",
                    hintStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget drawerBody() {
    return Container(
      margin: const EdgeInsets.only(
        top: 30.0,
        left: 5.0,
        bottom: 10.0,
      ),
      child: Column(
        children: [
          ListTile(
            leading: const ClipOval(
              child: Image(
                height: 40,
                image: AssetImage(
                  "assets/images/app_logo.png",
                ),
                // fit: BoxFit.contain,
              ),
            ),
            onTap: () {
              gemini.generatedTitle = "";
              gemini.chats.clear();
              setState(() {});
            },
            hoverColor: Colors.grey,
            title: const Text(
              "ChatGem",
              style: TextStyle(
                  color: Colors.white, fontSize: 18, letterSpacing: 1),
            ),
          ),
          const Divider(
            thickness: 0.3,
          ),
          ListView.builder(
            padding: const EdgeInsets.all(0.0),
            shrinkWrap: true,
            itemCount: gemini.titleLists.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  _selectedIndex = index;
                  gemini.generatedTitle = gemini.titleLists[_selectedIndex];
                  gemini.getChats(gemini.titleLists[_selectedIndex], context,
                      scrollController);
                  _scaffoldKey.currentState?.closeDrawer();
                },
                hoverColor: Colors.grey,
                title: Text(
                  gemini.titleLists[index],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            },
          ),
          const Spacer(),
          ListTile(
              title: Text(
                _auth.currentUser!.displayName ?? "",
                style: const TextStyle(color: Colors.white, letterSpacing: 2),
              ),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  final sharedPref = SharedPref();
                  if (value == "logout") {
                    sharedPref.deleteData("email");
                    sharedPref.deleteData("userName");
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                offset: const Offset(10.0, 10.0),
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
                itemBuilder: (context) {
                  return List.generate(
                    1,
                    (index) {
                      return PopupMenuItem(
                        onTap: () {},
                        value: "logout",
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Logout"),
                            Icon(Icons.power_settings_new)
                          ],
                        ),
                      );
                    },
                  );
                },
              ))
        ],
      ),
    );
  }
}
